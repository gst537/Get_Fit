import SwiftUI
import SwiftData

struct MuscleVolumeAnalyticsView: View {
    @Query(filter: #Predicate<WorkoutSession> { $0.isCompleted == true }) private var completedSessions: [WorkoutSession]
    @Query private var allMachines: [GymMachine]
    
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    let targetMuscles = ["Chest", "Front Delt", "Lateral Delt", "Rear Delt", "Triceps", "Lats", "Rhomboids", "Lower Back", "Biceps", "Quads", "Hamstrings", "Glutes", "Calves", "Abs"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                let volumes = calculateVolume()
                ForEach(targetMuscles, id: \.self) { muscle in
                    if let sets = volumes[muscle], sets > 0 {
                        volumeCard(muscle: muscle, sets: sets)
                    } else {
                        volumeCard(muscle: muscle, sets: 0)
                    }
                }
            }
            .padding()
        }
        .background(Color(uiColor: .systemBackground))
    }
    
    private func volumeCard(muscle: String, sets: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(muscle)
                    .font(.body.weight(.light))
                    .foregroundColor(.white)
                Spacer()
                Text("\(sets) sets / wk")
                    .font(.subheadline.weight(.light))
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(uiColor: .secondarySystemBackground))
                        .frame(height: 12)
                    
                    let progress = min(CGFloat(sets) / 20.0, 1.0)
                    Capsule()
                        .fill(paleBlue)
                        .frame(width: geometry.size.width * progress, height: 12)
                    
                    // Optimal range indicator (10-20 sets)
                    if sets >= 10 && sets <= 20 {
                        Text("Optimal")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .background(Color.green.opacity(0.6))
                            .cornerRadius(4)
                            .position(x: geometry.size.width * 0.75, y: -10)
                    }
                }
            }
            .frame(height: 24)
        }
        .padding()
        .background(Color(uiColor: .systemBackground)) // We apply secondary background inside the card itself or on the capsule
        .cornerRadius(12)
    }
    
    private func calculateVolume() -> [String: Int] {
        var volumeMap: [String: Int] = [:]
        
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        let recentSessions = completedSessions.filter { $0.date >= sevenDaysAgo }
        
        for session in recentSessions {
            for setLog in session.setLogs {
                // Find machine
                var matchingMachine: GymMachine?
                if let mId = setLog.machineId {
                    matchingMachine = allMachines.first { $0.id == mId }
                }
                if matchingMachine == nil {
                    matchingMachine = allMachines.first { $0.name == setLog.machineName }
                }
                
                if let machine = matchingMachine {
                    for muscle in machine.targetMuscles {
                        volumeMap[muscle, default: 0] += 1
                    }
                }
            }
        }
        
        return volumeMap
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: WorkoutSession.self, SetLog.self, GymMachine.self, configurations: config)
        return MuscleVolumeAnalyticsView()
            .modelContainer(container)
            .preferredColorScheme(.dark)
    } catch {
        fatalError("Failed to create model container.")
    }
}
