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
        ZStack {
            // Solid Background
            PremiumColors.deepBlack
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top header from Stitch
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("GetFit")
                                .font(PremiumFonts.title)
                                .foregroundStyle(PremiumColors.starkWhite)
                            Circle()
                                .fill(PremiumColors.neonCyan)
                                .frame(width: 6, height: 6)
                        }
                        Text(selectedTab == 0 ? "Workouts" : "Nutrition")
                            .font(PremiumFonts.caption)
                            .foregroundStyle(PremiumColors.midGray)
                    }
                    Spacer()
                    Button {
                        Haptics.playLightImpact()
                        showProfileSheet = true
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(PremiumColors.neonCyan)
                            .shadow(color: PremiumColors.neonCyan.opacity(0.3), radius: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .background(PremiumColors.deepBlack)
                
                // Custom Segmented Control
                HStack(spacing: 0) {
                    Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 0 } }) {
                        Text("Workouts")
                            .font(PremiumFonts.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(selectedTab == 0 ? PremiumColors.deepBlack : PremiumColors.starkWhite)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 24)
                            .background(selectedTab == 0 ? PremiumColors.starkWhite : Color.clear)
                            .clipShape(Capsule())
                    }
                    
                    Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 1 } }) {
                        Text("Nutrition")
                            .font(PremiumFonts.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(selectedTab == 1 ? PremiumColors.deepBlack : PremiumColors.starkWhite)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 24)
                            .background(selectedTab == 1 ? PremiumColors.starkWhite : Color.clear)
                            .clipShape(Capsule())
                    }
                }
                .padding(4)
                .background(PremiumColors.glassBorder.opacity(0.1))
                .clipShape(Capsule())
                .padding(.vertical, 12)

                
                if selectedTab == 0 {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            
                            // Streak logic moved inline for now or kept as badge
                            
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
                                            .font(PremiumFonts.caption)
                                            .fontWeight(.bold)
                                    }
                                    .foregroundStyle(PremiumColors.deepBlack)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(PremiumColors.neonCyan)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .shadow(color: PremiumColors.neonCyan.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                
                                Button {
                                    Haptics.playLightImpact()
                                    showCreateExercise = true
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "plus.square.fill")
                                            .font(.system(size: 16))
                                        Text("Custom Exercise")
                                            .font(PremiumFonts.caption)
                                            .fontWeight(.bold)
                                    }
                                    .foregroundStyle(PremiumColors.starkWhite)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .glassmorphic(cornerRadius: 12)
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
        }
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
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showProfileSheet) {
            ProfileView()
        }
    }
    
    // MARK: - Top Bar Section
    // (Replaced by Stitch custom header)
    
    // MARK: - Activity Graph (Premium Style)
    
    private var activityGraphSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Activity Matrix")
                    .font(PremiumFonts.headline)
                    .foregroundStyle(PremiumColors.starkWhite)
                Spacer()
                Text("Rookie")
                    .font(PremiumFonts.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(PremiumColors.neonCyan.opacity(0.2))
                    .foregroundStyle(PremiumColors.neonCyan)
                    .clipShape(Capsule())
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
            
            let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
            
            NavigationLink {
                WorkoutHistoryView()
            } label: {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(0..<7, id: \.self) { dayIdx in
                            Text(dayLabels[dayIdx])
                                .font(PremiumFonts.caption)
                                .foregroundStyle(PremiumColors.midGray)
                                .frame(height: 12)
                        }
                    }
                    .padding(.trailing, 4)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(0..<10, id: \.self) { weekIdx in
                                VStack(spacing: 6) {
                                    ForEach(0..<7, id: \.self) { dayIdx in
                                        if let data = heatmapData.first(where: { $0.weekIdx == weekIdx && $0.dayIdx == dayIdx }) {
                                            Circle()
                                                .fill(data.intensity > 0 
                                                      ? PremiumColors.neonCyan.opacity(max(0.3, data.intensity))
                                                      : PremiumColors.glassBorder.opacity(0.3))
                                                .frame(width: 12, height: 12)
                                        } else {
                                            Circle()
                                                .fill(Color.clear)
                                                .frame(width: 12, height: 12)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            
            HStack {
                Text("\(completedSessions.count) Sessions")
                    .font(PremiumFonts.caption)
                    .foregroundStyle(PremiumColors.starkWhite)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(PremiumColors.midGray)
            }
        }
        .padding(16)
        .glassmorphic(cornerRadius: 16)
    }
    
    // MARK: - Daily Steps Card
    
    private var stepsCard: some View {
        NavigationLink {
            StepTrackerView()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Steps")
                        .font(PremiumFonts.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(PremiumColors.midGray)
                    Spacer()
                    if healthKitManager.isAuthorized {
                        Image(systemName: "figure.walk")
                            .font(.caption)
                            .foregroundStyle(PremiumColors.neonCyan)
                    }
                }
                
                Spacer()
                
                Text("\(stats?.dailySteps ?? 0)")
                    .font(PremiumFonts.title)
                    .foregroundStyle(PremiumColors.starkWhite)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                HStack(spacing: 8) {
                    Button(action: {
                        Haptics.playLightImpact()
                        updateSteps(by: -500)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(PremiumColors.midGray)
                    }
                    
                    Button(action: {
                        Haptics.playLightImpact()
                        updateSteps(by: 500)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(PremiumColors.neonCyan)
                    }
                    
                    Spacer()
                    
                    if !healthKitManager.isAuthorized {
                        Button(action: {
                            Haptics.playLightImpact()
                            syncHealthKitSteps()
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.caption)
                                .foregroundStyle(PremiumColors.midGray)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 144, maxHeight: 144, alignment: .topLeading)
            .glassmorphic(cornerRadius: 16)
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
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Weight")
                        .font(PremiumFonts.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(PremiumColors.midGray)
                    Spacer()
                    Image(systemName: "scalemass.fill")
                        .font(.caption)
                        .foregroundStyle(PremiumColors.neonCyan)
                }
                
                Spacer()
                
                if let latest = weightEntries.first {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(weightUnit.formatWeight(latest.weight))
                            .font(PremiumFonts.title)
                            .foregroundStyle(PremiumColors.starkWhite)
                        
                        if weightEntries.count >= 2 {
                            let previous = weightEntries[1].weight
                            let diff = latest.weight - previous
                            let displayDiff = weightUnit.displayWeight(diff)
                            let absDisplayDiff = abs(displayDiff)
                            
                            if absDisplayDiff >= 0.1 {
                                HStack(spacing: 2) {
                                    Image(systemName: diff < 0 ? "arrow.down.right" : "arrow.up.right")
                                    Text(String(format: "%.1f %@", absDisplayDiff, weightUnit.unitLabel))
                                }
                                .font(PremiumFonts.caption)
                                .foregroundStyle(diff < 0 ? .green : .red)
                            } else {
                                Text("No change")
                                    .font(PremiumFonts.caption)
                                    .foregroundStyle(PremiumColors.midGray)
                            }
                        } else {
                            Text("No change")
                                .font(PremiumFonts.caption)
                                .foregroundStyle(PremiumColors.midGray)
                        }
                    }
                } else {
                    Text("No Data")
                        .font(PremiumFonts.caption)
                        .foregroundStyle(PremiumColors.midGray)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 144, maxHeight: 144, alignment: .topLeading)
            .glassmorphic(cornerRadius: 16)
        }
    }

    // MARK: - Workout History & Analytics Card
    
    private var historyCard: some View {
        NavigationLink {
            WorkoutHistoryView()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Sessions")
                        .font(PremiumFonts.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(PremiumColors.midGray)
                    Spacer()
                    Image(systemName: "dumbbell.fill")
                        .font(.caption)
                        .foregroundStyle(PremiumColors.neonCyan)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(completedSessions.count)")
                        .font(PremiumFonts.title)
                        .foregroundStyle(PremiumColors.starkWhite)
                    
                    Text("Completed")
                        .font(PremiumFonts.caption)
                        .foregroundStyle(PremiumColors.midGray)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 144, maxHeight: 144, alignment: .topLeading)
            .glassmorphic(cornerRadius: 16)
        }
    }
    
    // MARK: - Cardio Tracker Card
    
    private var cardioCard: some View {
        NavigationLink {
            CardioTrackerView()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Cardio")
                        .font(PremiumFonts.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(PremiumColors.midGray)
                    Spacer()
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(Color.red)
                        .shadow(color: Color.red.opacity(0.5), radius: 2)
                }
                
                Spacer()
                
                let weeklyDuration = cardioLogs.filter {
                    Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear)
                }.reduce(0.0) { $0 + $1.durationMinutes }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(Int(weeklyDuration))m")
                        .font(PremiumFonts.title)
                        .foregroundStyle(PremiumColors.starkWhite)
                    
                    Text("This Week")
                        .font(PremiumFonts.caption)
                        .foregroundStyle(PremiumColors.midGray)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 144, maxHeight: 144, alignment: .topLeading)
            .glassmorphic(cornerRadius: 16)
        }
    }
    
    // MARK: - Rest Day Section
    
    private var restDaySection: some View {
        Button {
            Haptics.playLightImpact()
            showRestDaySheet = true
        } label: {
            VStack(spacing: 16) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(PremiumColors.neonCyan)
                    .shadow(color: PremiumColors.neonCyan.opacity(0.6), radius: 10)
                
                VStack(spacing: 4) {
                    Text("Rest & Recover")
                        .font(PremiumFonts.headline)
                        .foregroundStyle(PremiumColors.starkWhite)
                    Text("Your muscles grow when you rest.")
                        .font(PremiumFonts.caption)
                        .foregroundStyle(PremiumColors.midGray)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 36)
            .glassmorphic(cornerRadius: 16)
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
                        .font(PremiumFonts.headline)
                        .foregroundStyle(PremiumColors.starkWhite)
                }
                
                NavigationLink {
                    SplitDetailView(split: split)
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundStyle(PremiumColors.neonCyan)
                }
                
                Spacer()
                
                Text("\(sortedEntries.count) Exercises")
                    .font(PremiumFonts.caption)
                    .foregroundStyle(PremiumColors.midGray)
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
                .padding(.bottom, 12)
            }
            
            // Exercise rows
            ForEach(sortedEntries) { entry in
                VStack(spacing: 0) {
                    Divider().background(PremiumColors.glassBorder)
                    
                    HStack {
                        Button {
                            selectedExercise = entry.machine
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundStyle(PremiumColors.neonCyan)
                                
                                Text(entry.machine?.name ?? "Unknown")
                                    .font(PremiumFonts.body)
                                    .foregroundStyle(PremiumColors.starkWhite)
                                Spacer()
                            }
                        }
                        
                        Button {
                            selectedEntryToEdit = entry
                        } label: {
                            HStack(spacing: 8) {
                                if entry.defaultWeight > 0 {
                                    Text(weightUnit.formatWeight(entry.defaultWeight))
                                        .font(PremiumFonts.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(PremiumColors.neonCyan)
                                }
                                
                                Text("\(entry.defaultSets) × \(entry.defaultReps)")
                                    .font(PremiumFonts.caption)
                                    .foregroundStyle(PremiumColors.starkWhite)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(PremiumColors.glassBorder)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.vertical, 14)
                }
            }
        }
        .padding(20)
        .glassmorphic(cornerRadius: 16)
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
            HStack {
                Text(activeSessions.isEmpty ? "Start Session" : "Resume Session")
                    .font(PremiumFonts.headline)
                Image(systemName: "play.fill")
            }
            .foregroundStyle(PremiumColors.deepBlack)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(PremiumColors.neonCyan)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: PremiumColors.neonCyan.opacity(0.4), radius: 10, y: 5)
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
