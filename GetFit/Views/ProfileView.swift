import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var weightUnit = WeightUnitManager.shared
    
    // User Profile Storage
    @AppStorage("userName") private var userName: String = "Tarun"
    @AppStorage("userAge") private var userAge: Int = 19
    @AppStorage("userHeight") private var userHeight: Int = 170
    @AppStorage("targetWeightKg") private var targetWeightKg: Double = 64.0
    
    @Query private var userStats: [UserStats]
    @Query(filter: #Predicate<WorkoutSession> { $0.isCompleted == true }) private var completedSessions: [WorkoutSession]
    @Query(sort: \CardioLog.date, order: .reverse) private var cardioLogs: [CardioLog]
    @Query(sort: \BodyWeightEntry.date, order: .reverse) private var weightEntries: [BodyWeightEntry]
    
    @State private var showEditProfileSheet = false
    
    let slateBlue = MutedEarth.slateBlue
    
    private var currentWeightKg: Double {
        weightEntries.first?.weight ?? 70.0
    }
    
    private var stats: UserStats? {
        userStats.first
    }
    
    private var totalTonnage: Double {
        completedSessions.reduce(0.0) { sessionSum, session in
            sessionSum + session.setLogs.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
        }
    }
    
    private var totalCardioMinutes: Double {
        cardioLogs.reduce(0.0) { $0 + $1.durationMinutes }
    }
    
    private var streakDays: Int {
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
    
    private var athleteRank: (title: String, icon: String, color: Color) {
        let tonnes = totalTonnage / 1000.0
        if tonnes >= 100 {
            return ("DIAMOND ATHLETE", "diamond.fill", Color.white)
        } else if tonnes >= 50 {
            return ("PLATINUM ATHLETE", "crown.fill", Color.gray)
        } else if tonnes >= 10 {
            return ("GOLD ATHLETE", "trophy.fill", MutedEarth.slateBlue)
        } else if tonnes >= 1 {
            return ("SILVER ATHLETE", "star.fill", Color.gray)
        } else {
            return ("ROOKIE ATHLETE", "flame.fill", MutedEarth.slateBlue)
        }
    }
    
    private var todayWorkoutMinutes: Int {
        let calendar = Calendar.current
        let today = Date()
        let todaySessions = completedSessions.filter { calendar.isDate($0.date, inSameDayAs: today) }
        let workoutMins = todaySessions.reduce(0.0) { $0 + ($1.duration / 60.0) }
        
        let todayCardio = cardioLogs.filter { calendar.isDate($0.date, inSameDayAs: today) }
        let cardioMins = todayCardio.reduce(0.0) { $0 + $1.durationMinutes }
        
        return Int(workoutMins + cardioMins)
    }
    
    private var weeklyWorkoutDays: Int {
        let calendar = Calendar.current
        let today = Date()
        
        let workoutDates = completedSessions.filter {
            calendar.isDate($0.date, equalTo: today, toGranularity: .weekOfYear)
        }.map { calendar.startOfDay(for: $0.date) }
        
        let cardioDates = cardioLogs.filter {
            calendar.isDate($0.date, equalTo: today, toGranularity: .weekOfYear)
        }.map { calendar.startOfDay(for: $0.date) }
        
        let uniqueDays = Set(workoutDates + cardioDates)
        return uniqueDays.count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // 1. Interactive Athlete Profile Card
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            ZStack {
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: 60, height: 60)
                                    .border(slateBlue, width: 1.0)
                                
                                Text(userName.prefix(1).uppercased())
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundStyle(slateBlue)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(userName.isEmpty ? "Get Fit Athlete" : userName)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                                
                                HStack(spacing: 6) {
                                    Image(systemName: athleteRank.icon)
                                        .font(.system(size: 10))
                                    Text(athleteRank.title)
                                        .font(.system(size: 9, weight: .bold))
                                        .tracking(0.8)
                                }
                                .foregroundStyle(athleteRank.color)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.black)
                                .border(athleteRank.color, width: 1.0)
                            }
                            
                            Spacer()
                            
                            Button {
                                showEditProfileSheet = true
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(slateBlue)
                                    .padding(8)
                                    .background(Color.black)
                                    .border(slateBlue, width: 1.0)
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        // Body Stats Summary Grid
                        HStack(spacing: 12) {
                            statItem(label: "AGE", value: "\(userAge) yrs")
                            statItem(label: "HEIGHT", value: "\(userHeight) cm")
                            statItem(label: "CURRENT", value: weightUnit.formatWeight(currentWeightKg))
                            statItem(label: "TARGET", value: weightUnit.formatWeight(targetWeightKg))
                        }
                    }
                    .padding(18)
                    .monochromeCard()
                    
                    // 2. Kokonut Activity Rings Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Activity Rings")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        
                        KokonutAppleActivityCard(
                            steps: stats?.dailySteps ?? 0,
                            stepGoal: 10000,
                            todayWorkoutMinutes: todayWorkoutMinutes,
                            workoutGoalMinutes: 30,
                            weeklyWorkoutDays: weeklyWorkoutDays,
                            weeklyGoalDays: 5,
                            onSyncAppleHealth: syncAppleHealth
                        )
                    }
                    
                    // 3. Lifetime Stats Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Lifetime Overview")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                            // Total Tonnage
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Total Lifted")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.gray)
                                
                                Text(formatTonnage(totalTonnage))
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(slateBlue)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .monochromeCard()
                            
                            // Workouts Completed
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Workouts Done")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.gray)
                                
                                Text("\(completedSessions.count)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .monochromeCard()
                            
                            // Total Cardio Time
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Total Cardio")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.gray)
                                
                                Text("\(Int(totalCardioMinutes)) min")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(slateBlue)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .monochromeCard()
                            
                            // Current Streak
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Active Streak")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.gray)
                                
                                Text("\(streakDays) Days")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(MutedEarth.terracotta)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .monochromeCard()
                        }
                    }
                    
                    // 4. Preferences Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Preferences")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weight Unit")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.gray)
                            
                            Picker("Unit", selection: $weightUnit.unit) {
                                Text("kg").tag(WeightUnitManager.WeightUnit.kg)
                                Text("lb").tag(WeightUnitManager.WeightUnit.lb)
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(16)
                        .monochromeCard()
                    }
                }
                .padding(20)
            }
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
            .navigationTitle("Profile & Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(slateBlue)
                }
            }
            .sheet(isPresented: $showEditProfileSheet) {
                EditProfileSheet(
                    name: $userName,
                    age: $userAge,
                    height: $userHeight,
                    targetWeight: $targetWeightKg
                )
            }
        }
    }
    
    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color.gray)
            
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .monochromeCard()
    }
    
    private func syncAppleHealth() {
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
    
    private func formatTonnage(_ weight: Double) -> String {
        if weight >= 1000 {
            return String(format: "%.1f tonnes", weight / 1000.0)
        } else {
            return String(format: "%.0f kg", weight)
        }
    }
}

// MARK: - Edit Profile Sheet

struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var name: String
    @Binding var age: Int
    @Binding var height: Int
    @Binding var targetWeight: Double
    
    @State private var inputName: String = ""
    @State private var inputAgeStr: String = ""
    @State private var inputHeightStr: String = ""
    @State private var inputTargetWeightStr: String = ""
    
    let slateBlue = MutedEarth.slateBlue
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Info") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Your Name", text: $inputName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Age")
                        Spacer()
                        TextField("Age", text: $inputAgeStr)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Height (cm)")
                        Spacer()
                        TextField("Height in cm", text: $inputHeightStr)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Body Recomp Target") {
                    HStack {
                        Text("Target Weight (kg)")
                        Spacer()
                        TextField("Target Weight", text: $inputTargetWeightStr)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Edit Athlete Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        name = inputName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if let a = Int(inputAgeStr) { age = a }
                        if let h = Int(inputHeightStr) { height = h }
                        if let w = Double(inputTargetWeightStr) { targetWeight = w }
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(slateBlue)
                }
            }
            .onAppear {
                inputName = name
                inputAgeStr = "\(age)"
                inputHeightStr = "\(height)"
                inputTargetWeightStr = String(format: "%.1f", targetWeight)
            }
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [UserStats.self, WorkoutSession.self, CardioLog.self, BodyWeightEntry.self], inMemory: true)
        .preferredColorScheme(.dark)
}
