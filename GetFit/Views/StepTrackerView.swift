import SwiftUI
import SwiftData

struct StepTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var healthKitManager = HealthKitManager.shared
    @Query private var userStats: [UserStats]
    
    @State private var stepGoal: Int = 10000
    @State private var customStepInput: String = ""
    
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    
    private var stats: UserStats? {
        userStats.first
    }
    
    private var todaySteps: Int {
        stats?.dailySteps ?? 0
    }
    
    private var progressRatio: Double {
        min(1.0, Double(todaySteps) / Double(stepGoal))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                
                // 1. Header Title
                Text("Step Tracker")
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .foregroundColor(.white)
                
                // 2. Today's Progress Ring & Counter
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                        
                        Circle()
                            .trim(from: 0, to: progressRatio)
                            .stroke(
                                LinearGradient(colors: [paleBlue, Color.blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.easeOut(duration: 0.8), value: progressRatio)
                        
                        VStack(spacing: 4) {
                            Text("\(todaySteps)")
                                .font(.system(size: 44, weight: .light))
                                .foregroundStyle(.white)
                            
                            Text("of \(stepGoal) steps")
                                .font(.caption)
                                .fontWeight(.light)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .frame(width: 180, height: 180)
                    .padding(.top, 8)
                    
                    // Steppers & Manual adjustment
                    HStack(spacing: 20) {
                        Button(action: { updateSteps(by: -500) }) {
                            HStack(spacing: 6) {
                                Image(systemName: "minus")
                                Text("500")
                            }
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(UIColor.secondarySystemBackground))
                            .foregroundColor(.gray)
                            .clipShape(Capsule())
                        }
                        
                        Button(action: { updateSteps(by: 500) }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                Text("500")
                            }
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(UIColor.secondarySystemBackground))
                            .foregroundColor(paleBlue)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // 3. Apple Health Connection Card
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.pink)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Apple Fitness & Health")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                            
                            Text(healthKitManager.isAuthorized ? "Automatically syncing step data" : "Connect to auto-sync your daily steps")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                        
                        Spacer()
                    }
                    
                    Button(action: syncAppleHealth) {
                        HStack {
                            Image(systemName: healthKitManager.isAuthorized ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
                            Text(healthKitManager.isAuthorized ? "Synced with Apple Health" : "Connect Apple Health")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(healthKitManager.isAuthorized ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(healthKitManager.isAuthorized ? Color.pink.opacity(0.3) : paleBlue)
                        .clipShape(Capsule())
                    }
                }
                .padding(20)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // 4. Quick Set Exact Steps
                VStack(alignment: .leading, spacing: 12) {
                    Text("Set Exact Step Count")
                        .font(.headline)
                        .fontWeight(.light)
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 12) {
                        TextField("Enter steps (e.g. 10000)", text: $customStepInput)
                            .keyboardType(.numbersAndPunctuation)
                    .submitLabel(.done)
                            .padding(14)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Button("Save") {
                            if let parsed = Int(customStepInput) {
                                if let stats = stats {
                                    stats.dailySteps = max(0, parsed)
                                    try? modelContext.save()
                                }
                                customStepInput = ""
                            }
                        }
                        .font(.body)
                        .fontWeight(.medium)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(paleBlue)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(20)
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
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
    
    private func updateSteps(by amount: Int) {
        if let stats = stats {
            stats.dailySteps = max(0, stats.dailySteps + amount)
            try? modelContext.save()
        }
    }
}

#Preview {
    NavigationStack {
        StepTrackerView()
            .modelContainer(for: UserStats.self, inMemory: true)
            .preferredColorScheme(.dark)
    }
}
