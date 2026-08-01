import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var weightUnit = WeightUnitManager.shared
    
    @Query private var userStats: [UserStats]
    @Query(filter: #Predicate<WorkoutSession> { $0.isCompleted == true }) private var completedSessions: [WorkoutSession]
    @Query(sort: \CardioLog.date, order: .reverse) private var cardioLogs: [CardioLog]
    
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    
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
        stats?.streakCount ?? 1
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
                    
                    // 1. Profile Header
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(paleBlue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Get Fit Athlete")
                                .font(.title2)
                                .fontWeight(.light)
                                .foregroundStyle(.white)
                            
                            Text("Consistent & Growing")
                                .font(.subheadline)
                                .fontWeight(.light)
                                .foregroundStyle(Color.gray)
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
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
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            
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
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            // Total Cardio Time
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Total Cardio")
                                    .font(.caption)
                                    .fontWeight(.light)
                                    .foregroundStyle(Color.gray)
                                
                                Text("\(Int(totalCardioMinutes)) min")
                                    .font(.title2)
                                    .fontWeight(.light)
                                    .foregroundStyle(Color.green.opacity(0.8))
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            // Current Streak
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Active Streak")
                                    .font(.caption)
                                    .fontWeight(.light)
                                    .foregroundStyle(Color.gray)
                                
                                Text("\(streakDays) Days")
                                    .font(.title2)
                                    .fontWeight(.light)
                                    .foregroundStyle(Color.orange.opacity(0.8))
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
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
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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
        }
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

#Preview {
    ProfileView()
        .modelContainer(for: [UserStats.self, WorkoutSession.self, CardioLog.self], inMemory: true)
        .preferredColorScheme(.dark)
}
