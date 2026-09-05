import SwiftUI
import SwiftData
import Charts

struct HeatmapData: Identifiable {
    let id = UUID()
    let weekIdx: Int
    let dayIdx: Int
    let intensity: Double
    let isRestDay: Bool
}

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var weightUnit = WeightUnitManager.shared
    @Query private var userStats: [UserStats]
    @Query private var schedule: [WeeklySchedule]
    @Query(filter: #Predicate<WorkoutSession> { $0.isCompleted == true }) private var completedSessions: [WorkoutSession]
    @Query(filter: #Predicate<WorkoutSession> { $0.isCompleted == false }) private var activeSessions: [WorkoutSession]
    @Query(sort: \BodyWeightEntry.date, order: .reverse) private var weightEntries: [BodyWeightEntry]
    @Query private var splits: [WorkoutSplit]
    @Query(sort: \CardioLog.date, order: .reverse) private var cardioLogs: [CardioLog]
    
    @State private var activeSession: WorkoutSession?
    @State private var selectedExercise: GymMachine?
    @State private var showCreateExercise = false
    @State private var showScanSheet = false
    @State private var selectedEntryToEdit: SplitMachineEntry?
    @State private var showProfileSheet = false
    @State private var showRestDaySheet = false
    @State private var selectedTab = 0 // 0: Workouts, 1: Nutrition
    
    private var stats: UserStats? {
        userStats.first
    }
    
    private var todayDayOfWeek: Int {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return weekday == 1 ? 7 : weekday - 1
    }
    
    private var todaySchedule: WeeklySchedule? {
        schedule.first { $0.dayOfWeek == todayDayOfWeek }
    }
    
    private var todaySplit: WorkoutSplit? {
        todaySchedule?.assignedSplit
    }
    
    private var isRestDay: Bool {
        todaySplit == nil
    }
    
    private var calculatedStreak: Int {
        let calendar = Calendar.current
        var activityDates = Set<Date>()
        
        for session in completedSessions {
            activityDates.insert(calendar.startOfDay(for: session.date))
        }
        for cardio in cardioLogs {
            activityDates.insert(calendar.startOfDay(for: cardio.date))
        }
        
        guard !activityDates.isEmpty else { return 0 }
        
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        if !activityDates.contains(checkDate) {
            guard let prevDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = prevDay
        }
        
        while activityDates.contains(checkDate) {
            streak += 1
            guard let prevDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prevDay
        }
        
        // Sync with UserStats model
        if let stats = stats, stats.streakCount != streak {
            stats.streakCount = streak
            try? modelContext.save()
        }
        
        return streak
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("View", selection: $selectedTab) {
                Text("Workouts").tag(0)
                Text("Nutrition").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 12)
            
            if selectedTab == 0 {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        activityGraphSection
                        
                        // 2x2 Metric Cards Grid
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                            stepsCard
                            bodyWeightCard
                            historyCard
                            cardioCard
                        }
                        
                        WeeklyScheduleView()
                        if let split = todaySplit {
                            splitSection(split)
                        } else {
                            restDaySection
                        }
                        if !isRestDay {
                            startWorkoutButton
                                .padding(.top, 8)
                        }
                        
                        HStack(spacing: 12) {
                            Button {
                                Haptics.playLightImpact()
                                showScanSheet = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "camera.viewfinder")
                                        .font(.system(size: 16))
                                    Text("Scan Machine")
                                        .font(.body)
                                        .fontWeight(.regular)
                                }
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(MutedEarth.slateBlue)
                                .clipShape(Capsule())
                            }
                            
                            Button {
                                Haptics.playLightImpact()
                                showCreateExercise = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 16))
                                    Text("Custom")
                                        .font(.body)
                                        .fontWeight(.regular)
                                }
                                .foregroundStyle(MutedEarth.slateBlue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(MutedEarth.slateBlue.opacity(0.15))
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            } else {
                NutritionTrackerView()
            }
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            SeedData.seedIfNeeded(context: modelContext)
            cleanupStaleSessions()
            if healthKitManager.isAuthorized {
                healthKitManager.fetchTodaySteps { steps in
                    stats?.dailySteps = steps
                }
            }
        }
        .fullScreenCover(item: $activeSession) { session in
            if let split = todaySplit {
                ActiveWorkoutView(session: session, split: split)
            }
        }
        .sheet(item: $selectedExercise) { exercise in
            ExerciseDetailSheet(exercise: exercise)
        }
        .sheet(isPresented: $showCreateExercise) {
            CreateExerciseSheet()
        }
        .sheet(isPresented: $showScanSheet) {
            ScanMachineSheet()
        }
        .sheet(item: $selectedEntryToEdit) { entry in
            EditSetsRepsSheet(entry: entry)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Haptics.playLightImpact()
                    showProfileSheet = true
                } label: {
                    Image(systemName: "person.circle")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                }
            }
        }
        .sheet(isPresented: $showProfileSheet) {
            ProfileView()
        }
    }
    
    // MARK: - Activity Graph (LeetCode Style)
    
    private var activityGraphSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            let vibrantBlue = Color(red: 0.35, green: 0.65, blue: 0.95)
            HStack {
                Text("Activity")
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundStyle(Color.gray)
                Spacer()
                
                // Keep the rank badge
                Text("Rookie Athlete")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(vibrantBlue.opacity(0.2))
                    .foregroundStyle(vibrantBlue)
                    .clipShape(Capsule())
                
                // Restore Profile Button
                Button {
                    Haptics.playLightImpact()
                    showProfileSheet = true
                } label: {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }
                .padding(.leading, 4)
            }
            
            // Heatmap calculation
            let today = Calendar.current.startOfDay(for: Date())
            let daysToShow = 7 * 10 // 10 weeks to make boxes bigger
            
            // Align start date to Sunday
            let earliestDate = Calendar.current.date(byAdding: .day, value: -(daysToShow - 1), to: today)!
            let weekdayOffset = Calendar.current.component(.weekday, from: earliestDate) - 1
            let alignedStartDate = Calendar.current.date(byAdding: .day, value: -weekdayOffset, to: earliestDate)!
            let totalDays = Calendar.current.dateComponents([.day], from: alignedStartDate, to: today).day! + 1
            
            let gridData: [Date] = (0..<totalDays).map { offset in
                Calendar.current.date(byAdding: .day, value: offset, to: alignedStartDate)!
            }
            
            let volumeMap: [Date: Double] = completedSessions.reduce(into: [:]) { dict, session in
                let startOfDay = Calendar.current.startOfDay(for: session.date)
                let volume = session.setLogs.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
                dict[startOfDay, default: 0] += volume
            }
            
            let maxVolume = volumeMap.values.max() ?? 1000.0
            
            let heatmapData: [HeatmapData] = {
                var result: [HeatmapData] = []
                for (index, date) in gridData.enumerated() {
                    let weekIdx = index / 7
                    let dayIdx = Calendar.current.component(.weekday, from: date) - 1 // 0 (Sun) to 6 (Sat)
                    
                    let isFuture = date > today
                    
                    let vol = volumeMap[date] ?? 0
                    let intensity = vol > 0 ? max(0.2, min(1.0, vol / maxVolume)) : 0.0
                    
                    if !isFuture {
                        result.append(HeatmapData(weekIdx: weekIdx, dayIdx: dayIdx, intensity: intensity, isRestDay: false))
                    }
                }
                return result
            }()
            
            let dayLabels = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
            
            NavigationLink {
                WorkoutHistoryView()
            } label: {
                Chart {
                    ForEach(heatmapData) { data in
                        RectangleMark(
                            x: .value("Week", data.weekIdx),
                            y: .value("Day", data.dayIdx),
                            width: 18,
                            height: 18
                        )
                        .foregroundStyle(data.intensity > 0 
                                         ? vibrantBlue.opacity(data.intensity) 
                                         : Color.white.opacity(0.05))
                        .cornerRadius(4)
                    }
                }
                .frame(height: 200) // Made bigger to fit the larger boxes
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .leading, values: .stride(by: 1)) { value in
                        if let dayIdx = value.as(Int.self), dayIdx >= 0 && dayIdx < 7 {
                            AxisValueLabel {
                                Text(dayLabels[dayIdx])
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(Color.gray.opacity(0.8))
                                    .frame(width: 28, alignment: .leading)
                            }
                        }
                    }
                }
                .chartYScale(domain: .automatic(includesZero: false, reversed: true))
            }
            .buttonStyle(.plain)
            
            HStack {
                Spacer()
                Text("Tap graph to view history")
                    .font(.caption2)
                    .foregroundStyle(Color.gray.opacity(0.7))
            }
        }
        .padding(16)
        .glassmorphic(cornerRadius: 18)
    }
    
    // MARK: - Daily Steps Card
    
    private var stepsCard: some View {
        NavigationLink {
            StepTrackerView()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Daily Steps")
                        .font(.caption)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    Spacer()
                    if healthKitManager.isAuthorized {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundStyle(.pink)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.gray.opacity(0.5))
                }
                
                Text("\(stats?.dailySteps ?? 0)")
                    .font(.system(size: 26, weight: .light))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                HStack(spacing: 12) {
                    Button(action: {
                        Haptics.playLightImpact()
                        updateSteps(by: -500)
                    }) {
                        Image(systemName: "minus.circle")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.gray)
                    }
                    
                    Button(action: {
                        Haptics.playLightImpact()
                        updateSteps(by: 500)
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    if !healthKitManager.isAuthorized {
                        Button(action: {
                            Haptics.playLightImpact()
                            syncHealthKitSteps()
                        }) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.pink)
                        }
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 130, maxHeight: 130, alignment: .topLeading)
            .monochromeCard()
            .shimmerGlow()
        }
    }
    
    private func syncHealthKitSteps() {
        if !healthKitManager.isAuthorized {
            healthKitManager.requestAuthorizationAndFetch { steps in
                if let stats = stats {
                    stats.dailySteps = steps
                    try? modelContext.save()
                }
            }
        } else {
            healthKitManager.fetchTodaySteps { steps in
                if let stats = stats {
                    stats.dailySteps = steps
                    try? modelContext.save()
                }
            }
        }
    }
    
    private func updateSteps(by amount: Int) {
        if let stats = stats {
            stats.dailySteps = max(0, stats.dailySteps + amount)
            try? modelContext.save()
        }
    }

    // MARK: - Body Weight Card
    
    private var bodyWeightCard: some View {
        NavigationLink {
            BodyWeightView()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Body Weight")
                        .font(.caption)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.gray.opacity(0.5))
                }
                
                if let latest = weightEntries.first {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(weightUnit.formatWeight(latest.weight))
                            .font(.system(size: 26, weight: .light))
                            .foregroundStyle(.white)
                        
                        if weightEntries.count >= 2 {
                            let previous = weightEntries[1].weight
                            let diff = latest.weight - previous
                            let displayDiff = weightUnit.displayWeight(diff)
                            let absDisplayDiff = abs(displayDiff)
                            
                            if absDisplayDiff >= 0.1 {
                                HStack(spacing: 2) {
                                    Image(systemName: diff < 0 ? "arrow.down" : "arrow.up")
                                        .font(.caption2)
                                    Text(String(format: "%.1f %@", absDisplayDiff, weightUnit.unitLabel))
                                        .font(.caption2)
                                }
                                .foregroundStyle(diff < 0 ? Color.green.opacity(0.8) : Color.orange.opacity(0.8))
                            } else {
                                Text("Maintained")
                                    .font(.caption2)
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }
                } else {
                    Text("Tap to log")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 130, maxHeight: 130, alignment: .topLeading)
            .monochromeCard()
        }
    }

    // MARK: - Workout History & Analytics Card
    
    private var historyCard: some View {
        NavigationLink {
            WorkoutHistoryView()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("History")
                        .font(.caption)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.gray.opacity(0.5))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(completedSessions.count)")
                        .font(.system(size: 26, weight: .light))
                        .foregroundStyle(.white)
                    
                    Text(completedSessions.count == 1 ? "Workout Done" : "Workouts Done")
                        .font(.caption2)
                        .fontWeight(.light)
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 130, maxHeight: 130, alignment: .topLeading)
            .monochromeCard()
        }
    }
    
    // MARK: - Cardio Tracker Card
    
    private var cardioCard: some View {
        NavigationLink {
            CardioTrackerView()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Cardio Log")
                        .font(.caption)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.gray.opacity(0.5))
                }
                
                let weeklyDuration = cardioLogs.filter {
                    Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear)
                }.reduce(0.0) { $0 + $1.durationMinutes }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(Int(weeklyDuration)) min")
                        .font(.system(size: 26, weight: .light))
                        .foregroundStyle(.white)
                    
                    Text("Logged This Week")
                        .font(.caption2)
                        .fontWeight(.light)
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 130, maxHeight: 130, alignment: .topLeading)
            .monochromeCard()
        }
    }
    
    // MARK: - Rest Day Section
    
    private var restDaySection: some View {
        Button {
            Haptics.playLightImpact()
            showRestDaySheet = true
        } label: {
            VStack(spacing: 16) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 40))
                    .fontWeight(.ultraLight)
                    .foregroundStyle(.white)
                
                Text("Rest Day")
                    .font(.title2)
                    .fontWeight(.light)
                    .foregroundStyle(.white)
                
                HStack(spacing: 4) {
                    Text("Tap for Recovery Quote & Options")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(Color.gray.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 36)
            .monochromeCard()
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showRestDaySheet) {
            RestDaySheet(scheduleEntry: todaySchedule)
        }
    }
    
    // MARK: - Workout Split Section
    
    private func splitSection(_ split: WorkoutSplit) -> some View {
        let sortedEntries = split.entries.sorted { $0.order < $1.order }
        
        return VStack(alignment: .leading, spacing: 0) {
            // Split header
            HStack(alignment: .firstTextBaseline) {
                if let todaySchedule {
                    QuickSwapSplitMenu(scheduleEntry: todaySchedule)
                } else {
                    Text(split.name)
                        .font(.title2)
                        .fontWeight(.light)
                        .foregroundStyle(.white)
                }
                
                NavigationLink {
                    SplitDetailView(split: split)
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 0.35, green: 0.65, blue: 0.95))
                }
                
                Spacer()
                
                Text("\(sortedEntries.count) exercises")
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundStyle(Color.gray)
            }
            .padding(.bottom, 16)
            
            // Muscle group badges
            let allMuscles = Array(Set(sortedEntries.compactMap { $0.machine?.targetMuscles }.flatMap { $0 }))
            if !allMuscles.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(allMuscles, id: \.self) { muscle in
                            MuscleGroupBadge(muscle: muscle, color: MuscleGroupBadge.colorForMuscle(muscle))
                        }
                    }
                }
                .padding(.bottom, 8)
            }
            
            // Exercise rows
            ForEach(sortedEntries) { entry in
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 0.5)
                    
                    HStack {
                        Button {
                            selectedExercise = entry.machine
                        } label: {
                            HStack {
                                Text(entry.machine?.name ?? "Unknown")
                                    .font(.body)
                                    .fontWeight(.regular)
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                        }
                        
                        Button {
                            selectedEntryToEdit = entry
                        } label: {
                            HStack(spacing: 8) {
                                if entry.defaultWeight > 0 {
                                    Text(weightUnit.formatWeight(entry.defaultWeight))
                                        .font(.subheadline)
                                        .fontWeight(.light)
                                        .foregroundStyle(Color(red: 0.35, green: 0.65, blue: 0.95))
                                }
                                
                                Text("\(entry.defaultSets) × \(entry.defaultReps)")
                                    .font(.subheadline)
                                    .fontWeight(.light)
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .padding(20)
        .glassmorphic(cornerRadius: 18)
    }
    
    private func cleanupStaleSessions() {
        let calendar = Calendar.current
        for session in activeSessions {
            if !calendar.isDateInToday(session.date) {
                if session.setLogs.isEmpty {
                    modelContext.delete(session)
                } else {
                    session.isCompleted = true
                }
            }
        }
        try? modelContext.save()
    }
    
    private func formatWeight(_ weight: Double) -> String {
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        } else {
            return String(format: "%.1f", weight)
        }
    }
    
    // MARK: - Start Workout Button
    
    private var startWorkoutButton: some View {
        Button {
            Haptics.playLightImpact()
            guard let split = todaySplit else { return }
            let session = activeSessions.first ?? WorkoutSession(splitName: split.name)
            if activeSessions.isEmpty {
                modelContext.insert(session)
                try? modelContext.save()
            }
            activeSession = session
        } label: {
            Text(activeSessions.isEmpty ? "Start Workout" : "Resume Workout")
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(MutedEarth.slateBlue)
                .clipShape(Rectangle())
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView()
            .modelContainer(for: [GymMachine.self, WorkoutSplit.self, SplitMachineEntry.self, WorkoutSession.self, SetLog.self, UserStats.self, WeeklySchedule.self, BodyWeightEntry.self, CardioLog.self], inMemory: true)
            .preferredColorScheme(.dark)
    }
}
