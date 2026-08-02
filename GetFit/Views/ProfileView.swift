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
    
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    
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
            return ("DIAMOND ATHLETE", "diamond.fill", Color(red: 0.60, green: 0.85, blue: 1.00))
        } else if tonnes >= 50 {
            return ("PLATINUM ATHLETE", "crown.fill", Color(red: 0.85, green: 0.85, blue: 0.95))
        } else if tonnes >= 10 {
            return ("GOLD ATHLETE", "trophy.fill", Color(red: 0.95, green: 0.80, blue: 0.30))
        } else if tonnes >= 1 {
            return ("SILVER ATHLETE", "star.fill", Color(red: 0.75, green: 0.80, blue: 0.85))
        } else {
            return ("ROOKIE ATHLETE", "flame.fill", paleBlue)
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
                                Circle()
                                    .fill(paleBlue.opacity(0.15))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Circle()
                                            .stroke(paleBlue.opacity(0.4), lineWidth: 1.0)
                                    )
                                
                                Text(userName.prefix(1).uppercased())
                                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                                    .foregroundStyle(paleBlue)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(userName.isEmpty ? "Get Fit Athlete" : userName)
                                    .font(.title2)
                                    .fontWeight(.medium)
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
                                .background(athleteRank.color.opacity(0.12))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(athleteRank.color.opacity(0.35), lineWidth: 0.8)
                                )
                            }
                            
                            Spacer()
                            
                            Button {
                                showEditProfileSheet = true
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(paleBlue)
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
                    .matteBlack(cornerRadius: 20, accentColor: paleBlue)
                    
                    // 2. Kokonut Activity Rings Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Activity Rings")
                            .font(.headline)
                            .fontWeight(.light)
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
                            .font(.headline)
                            .fontWeight(.light)
                            .foregroundStyle(.white)
                        
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                            // Total Tonnage
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Total Lifted")
                                    .font(.caption)
                                    .fontWeight(.light)
                                    .foregroundStyle(Color.gray)
                                
                                Text(formatTonnage(totalTonnage))
                                    .font(.title2)
                                    .fontWeight(.light)
                                    .foregroundStyle(paleBlue)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .matteBlack(cornerRadius: 16, accentColor: paleBlue)
                            
                            // Workouts Completed
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Workouts Done")
                                    .font(.caption)
                                    .fontWeight(.light)
                                    .foregroundStyle(Color.gray)
                                
                                Text("\(completedSessions.count)")
                                    .font(.title2)
                                    .fontWeight(.light)
                                    .foregroundStyle(.white)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .matteBlack(cornerRadius: 16, accentColor: paleBlue)
                            
                            // Total Cardio Time
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Total Cardio")
                                    .font(.caption)
                                    .fontWeight(.light)
                                    .foregroundStyle(Color.gray)
                                
                                Text("\(Int(totalCardioMinutes)) min")
                                    .font(.title2)
                                    .fontWeight(.light)
                                    .foregroundStyle(Color(red: 0.55, green: 0.82, blue: 0.68))
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .matteBlack(cornerRadius: 16, accentColor: paleBlue)
                            
                            // Current Streak
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Active Streak")
                                    .font(.caption)
                                    .fontWeight(.light)
                                    .foregroundStyle(Color.gray)
                                
                                Text("\(streakDays) Days")
                                    .font(.title2)
                                    .fontWeight(.light)
                                    .foregroundStyle(Color(red: 0.92, green: 0.70, blue: 0.50))
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .matteBlack(cornerRadius: 16, accentColor: paleBlue)
                        }
                    }
                    
                    // 4. Preferences Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Preferences")
                            .font(.headline)
                            .fontWeight(.light)
                            .foregroundStyle(.white)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weight Unit")
                                .font(.subheadline)
                                .fontWeight(.light)
                                .foregroundStyle(Color.gray)
                            
                            Picker("Unit", selection: $weightUnit.unit) {
                                Text("kg").tag(WeightUnitManager.WeightUnit.kg)
                                Text("lb").tag(WeightUnitManager.WeightUnit.lb)
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(16)
                        .matteBlack(cornerRadius: 14, accentColor: paleBlue)
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
                        .foregroundColor(paleBlue)
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
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
    
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    
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
                    .foregroundStyle(paleBlue)
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
