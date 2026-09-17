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
    @AppStorage("keepScreenAwake") private var keepScreenAwake: Bool = true
    
    @Query private var userStats: [UserStats]
    @Query(filter: #Predicate<WorkoutSession> { $0.isCompleted == true }) private var completedSessions: [WorkoutSession]
    @Query(sort: \CardioLog.date, order: .reverse) private var cardioLogs: [CardioLog]
    @Query(sort: \BodyWeightEntry.date, order: .reverse) private var weightEntries: [BodyWeightEntry]
    
    @State private var showEditProfileSheet = false
    @State private var geminiKeyInput = AIFoodVisionService.shared.savedAPIKey ?? ""
    
    let tCyan = PremiumColors.neonCyan
    let tWhite = PremiumColors.starkWhite
    let tGray = PremiumColors.midGray
    let tBlack = PremiumColors.deepBlack
    
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
            return ("Diamond Athlete", "diamond.fill", tCyan)
        } else if tonnes >= 50 {
            return ("Platinum Athlete", "star.fill", tGray)
        } else if tonnes >= 10 {
            return ("Gold Athlete", "medal.fill", .yellow)
        } else if tonnes >= 1 {
            return ("Silver Athlete", "medal", tGray)
        } else {
            return ("Rookie", "figure.walk", tCyan)
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
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.05, green: 0.1, blue: 0.15), PremiumColors.deepBlack]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Profile")
                        .font(PremiumFonts.title)
                        .foregroundStyle(tCyan)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(tGray)
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // 1. Interactive Athlete Profile Card
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(PremiumColors.glassBackground)
                                        .frame(width: 72, height: 72)
                                        .overlay(Circle().stroke(tCyan, lineWidth: 2))
                                        .shadow(color: tCyan.opacity(0.4), radius: 8)
                                    
                                    Text(userName.prefix(1).uppercased())
                                        .font(PremiumFonts.title)
                                        .foregroundStyle(tCyan)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(userName.isEmpty ? "Get Fit Athlete" : userName)
                                        .font(PremiumFonts.title)
                                        .foregroundStyle(tWhite)
                                    
                                    HStack(spacing: 6) {
                                        Image(systemName: athleteRank.icon)
                                            .font(.caption)
                                        Text(athleteRank.title)
                                            .font(PremiumFonts.caption)
                                            .fontWeight(.bold)
                                    }
                                    .foregroundStyle(athleteRank.color)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(PremiumColors.glassBackground)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(athleteRank.color, lineWidth: 1))
                                }
                                
                                Spacer()
                                
                                Button {
                                    showEditProfileSheet = true
                                } label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundStyle(tCyan)
                                        .shadow(color: tCyan.opacity(0.4), radius: 4)
                                }
                            }
                            
                            Divider()
                                .background(PremiumColors.glassBorder)
                            
                            // Body Stats Summary Grid
                            HStack(spacing: 12) {
                                statItem(label: "Age", value: "\(userAge) YRS")
                                statItem(label: "Height", value: "\(userHeight) CM")
                                statItem(label: "Weight", value: weightUnit.formatWeight(currentWeightKg))
                                statItem(label: "Target", value: weightUnit.formatWeight(targetWeightKg))
                            }
                        }
                        .padding(20)
                        .glassmorphic(cornerRadius: 16)
                        
                        // 2. Kokonut Activity Rings Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Daily Activity")
                                .font(PremiumFonts.headline)
                                .foregroundStyle(tWhite)
                            
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
                            Text("Lifetime Stats")
                                .font(PremiumFonts.headline)
                                .foregroundStyle(tWhite)
                            
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                                // Total Tonnage
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Volume Lifted")
                                        .font(PremiumFonts.caption)
                                        .foregroundStyle(tGray)
                                    
                                    Text(formatTonnage(totalTonnage))
                                        .font(PremiumFonts.headline)
                                        .foregroundStyle(tCyan)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .glassmorphic(cornerRadius: 16)
                                
                                // Workouts Completed
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Workouts")
                                        .font(PremiumFonts.caption)
                                        .foregroundStyle(tGray)
                                    
                                    Text("\(completedSessions.count)")
                                        .font(PremiumFonts.headline)
                                        .foregroundStyle(tWhite)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .glassmorphic(cornerRadius: 16)
                                
                                // Total Cardio Time
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Cardio Time")
                                        .font(PremiumFonts.caption)
                                        .foregroundStyle(tGray)
                                    
                                    Text("\(Int(totalCardioMinutes)) Min")
                                        .font(PremiumFonts.headline)
                                        .foregroundStyle(tCyan)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .glassmorphic(cornerRadius: 16)
                                
                                // Current Streak
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Active Streak")
                                        .font(PremiumFonts.caption)
                                        .foregroundStyle(tGray)
                                    
                                    Text("\(streakDays) Days")
                                        .font(PremiumFonts.headline)
                                        .foregroundStyle(tWhite)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .glassmorphic(cornerRadius: 16)
                            }
                        }
                        
                        // 4. Preferences Section
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Preferences")
                                .font(PremiumFonts.headline)
                                .foregroundStyle(tWhite)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Weight Unit")
                                    .font(PremiumFonts.caption)
                                    .foregroundStyle(tGray)
                                
                                HStack(spacing: 8) {
                                    ForEach([WeightUnitManager.WeightUnit.kg, WeightUnitManager.WeightUnit.lb], id: \.self) { unit in
                                        Text(unit == .kg ? "Kilograms" : "Pounds")
                                            .font(PremiumFonts.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(weightUnit.unit == unit ? tBlack : tWhite)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(weightUnit.unit == unit ? tCyan : PremiumColors.glassBackground)
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(weightUnit.unit == unit ? tCyan : PremiumColors.glassBorder, lineWidth: 1))
                                            .shadow(color: weightUnit.unit == unit ? tCyan.opacity(0.4) : .clear, radius: 4)
                                            .onTapGesture {
                                                weightUnit.unit = unit
                                            }
                                    }
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassmorphic(cornerRadius: 16)
                        }
                        
                        // 5. Workout Preferences Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Settings")
                                .font(PremiumFonts.headline)
                                .foregroundStyle(tWhite)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "sun.max.fill")
                                    .foregroundStyle(tCyan)
                                    .font(.title3)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Keep Screen On")
                                        .font(PremiumFonts.body)
                                        .fontWeight(.bold)
                                        .foregroundStyle(tWhite)
                                    Text("Prevents lock screen during workouts")
                                        .font(PremiumFonts.caption)
                                        .foregroundStyle(tGray)
                                }
                                Spacer()
                                Toggle("", isOn: $keepScreenAwake)
                                    .labelsHidden()
                                    .tint(tCyan)
                            }
                            .padding(16)
                            .glassmorphic(cornerRadius: 16)
                        }
                        
                        // 6. AI Features Section
                        VStack(alignment: .leading, spacing: 14) {
                            Text("AI Integration")
                                .font(PremiumFonts.headline)
                                .foregroundStyle(tWhite)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Gemini API Key (Vision Scan)")
                                    .font(PremiumFonts.caption)
                                    .foregroundStyle(tGray)
                                
                                PasteFriendlyTextField(text: $geminiKeyInput, placeholder: "Enter API Key")
                                    .frame(height: 44)
                                
                                HStack {
                                    PasteButton(payloadType: String.self) { strings in
                                        if let text = strings.first {
                                            geminiKeyInput = text.trimmingCharacters(in: .whitespacesAndNewlines)
                                            AIFoodVisionService.shared.savedAPIKey = geminiKeyInput
                                        }
                                    }
                                    .labelStyle(.titleOnly)
                                    .tint(tCyan)
                                    .clipShape(Capsule())
                                    
                                    Spacer()
                                    
                                    Button {
                                        AIFoodVisionService.shared.savedAPIKey = geminiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
                                    } label: {
                                        Text("Save Key")
                                            .font(PremiumFonts.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(tBlack)
                                            .padding(.horizontal, 16).padding(.vertical, 10)
                                            .background(tCyan)
                                            .clipShape(Capsule())
                                            .shadow(color: tCyan.opacity(0.4), radius: 4)
                                    }
                                }
                            }
                            .padding(16)
                            .glassmorphic(cornerRadius: 16)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showEditProfileSheet) {
            EditProfileSheet(
                name: $userName,
                age: $userAge,
                height: $userHeight,
                targetWeight: $targetWeightKg
            )
        }
    }
    
    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(PremiumFonts.caption)
                .foregroundStyle(tGray)
            
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(tWhite)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(PremiumColors.glassBorder.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
            return String(format: "%.1f TN", weight / 1000.0)
        } else {
            return String(format: "%.0f KG", weight)
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
    
    let tCyan = PremiumColors.neonCyan
    let tWhite = PremiumColors.starkWhite
    let tGray = PremiumColors.midGray
    let tBlack = PremiumColors.deepBlack
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.05, green: 0.1, blue: 0.15), PremiumColors.deepBlack]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Edit Profile")
                        .font(PremiumFonts.title)
                        .foregroundStyle(tCyan)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(tGray)
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Personal Details")
                                .font(PremiumFonts.caption)
                                .foregroundStyle(tGray)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Name")
                                        .font(PremiumFonts.caption)
                                        .foregroundStyle(tWhite)
                                    Spacer()
                                    TextField("Name", text: $inputName)
                                        .font(PremiumFonts.headline)
                                        .multilineTextAlignment(.trailing)
                                        .foregroundStyle(tCyan)
                                }
                                .padding(16)
                                
                                Divider().background(PremiumColors.glassBorder)
                                
                                HStack {
                                    Text("Age")
                                        .font(PremiumFonts.caption)
                                        .foregroundStyle(tWhite)
                                    Spacer()
                                    TextField("Yrs", text: $inputAgeStr)
                                        .font(PremiumFonts.headline)
                                        .keyboardType(.numbersAndPunctuation)
                                        .submitLabel(.done)
                                        .multilineTextAlignment(.trailing)
                                        .foregroundStyle(tCyan)
                                }
                                .padding(16)
                                
                                Divider().background(PremiumColors.glassBorder)
                                
                                HStack {
                                    Text("Height (cm)")
                                        .font(PremiumFonts.caption)
                                        .foregroundStyle(tWhite)
                                    Spacer()
                                    TextField("cm", text: $inputHeightStr)
                                        .font(PremiumFonts.headline)
                                        .keyboardType(.numbersAndPunctuation)
                                        .submitLabel(.done)
                                        .multilineTextAlignment(.trailing)
                                        .foregroundStyle(tCyan)
                                }
                                .padding(16)
                            }
                            .glassmorphic(cornerRadius: 16)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Goals")
                                .font(PremiumFonts.caption)
                                .foregroundStyle(tGray)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Target Weight")
                                        .font(PremiumFonts.caption)
                                        .foregroundStyle(tWhite)
                                    Spacer()
                                    TextField("kg/lb", text: $inputTargetWeightStr)
                                        .font(PremiumFonts.headline)
                                        .keyboardType(.numbersAndPunctuation)
                                        .submitLabel(.done)
                                        .multilineTextAlignment(.trailing)
                                        .foregroundStyle(tCyan)
                                }
                                .padding(16)
                            }
                            .glassmorphic(cornerRadius: 16)
                        }
                        
                        Button {
                            name = inputName.trimmingCharacters(in: .whitespacesAndNewlines)
                            if let a = Int(inputAgeStr) { age = a }
                            if let h = Int(inputHeightStr) { height = h }
                            if let w = Double(inputTargetWeightStr) { targetWeight = w }
                            dismiss()
                        } label: {
                            Text("Save Changes")
                                .font(PremiumFonts.headline)
                                .foregroundStyle(tBlack)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(tCyan)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: tCyan.opacity(0.4), radius: 8, y: 4)
                        }
                    }
                    .padding(20)
                }
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
