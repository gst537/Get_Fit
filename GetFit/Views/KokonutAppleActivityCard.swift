import SwiftUI

struct KokonutAppleActivityCard: View {
    let steps: Int
    let stepGoal: Int
    let todayWorkoutMinutes: Int
    let workoutGoalMinutes: Int
    let weeklyWorkoutDays: Int
    let weeklyGoalDays: Int
    let onSyncAppleHealth: () -> Void
    
    // Kokonut UI Apple Activity Ring Palette
    let redRingColor = Color(red: 0.98, green: 0.22, blue: 0.35)
    let greenRingColor = Color(red: 0.62, green: 0.96, blue: 0.28)
    let blueRingColor = Color(red: 0.0, green: 0.82, blue: 0.98)

    private var stepsRatio: Double {
        min(1.0, Double(steps) / Double(max(1, stepGoal)))
    }
    
    private var workoutRatio: Double {
        min(1.0, Double(todayWorkoutMinutes) / Double(max(1, workoutGoalMinutes)))
    }
    
    private var consistencyRatio: Double {
        min(1.0, Double(weeklyWorkoutDays) / Double(max(1, weeklyGoalDays)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Activity Rings")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.gray)
                        .textCase(.uppercase)
                        .tracking(1.0)
                    
                    Text("Daily Fitness")
                        .font(.title2)
                        .fontWeight(.light)
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Button(action: onSyncAppleHealth) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundStyle(.pink)
                        Text("Fitness Sync")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.pink.opacity(0.18))
                    .clipShape(Capsule())
                }
            }
            
            // Concentric Activity Rings & Stats
            HStack(spacing: 24) {
                // Concentric Activity Rings
                ZStack {
                    // Outer Ring (Daily Steps) - Red
                    Circle()
                        .stroke(redRingColor.opacity(0.2), lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: stepsRatio)
                        .stroke(redRingColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.8), value: stepsRatio)

                    // Middle Ring (Workout & Cardio Time) - Green
                    Circle()
                        .stroke(greenRingColor.opacity(0.2), lineWidth: 10)
                        .frame(width: 96, height: 96)
                    Circle()
                        .trim(from: 0, to: workoutRatio)
                        .stroke(greenRingColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 96, height: 96)
                        .animation(.easeOut(duration: 0.8), value: workoutRatio)

                    // Inner Ring (Weekly Consistency) - Cyan Blue
                    Circle()
                        .stroke(blueRingColor.opacity(0.2), lineWidth: 10)
                        .frame(width: 72, height: 72)
                    Circle()
                        .trim(from: 0, to: consistencyRatio)
                        .stroke(blueRingColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 72, height: 72)
                        .animation(.easeOut(duration: 0.8), value: consistencyRatio)
                }
                .frame(width: 120, height: 120)
                
                // Detailed Activity Breakdown
                VStack(alignment: .leading, spacing: 14) {
                    // Metric 1: Daily Steps
                    HStack(spacing: 10) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(redRingColor)
                            .frame(width: 18)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(steps)")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text("/ \(stepGoal)")
                                    .font(.caption2)
                                    .foregroundStyle(Color.gray)
                            }
                            Text("DAILY STEPS")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color.gray.opacity(0.8))
                        }
                    }
                    
                    // Metric 2: Workout & Cardio Time
                    HStack(spacing: 10) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(greenRingColor)
                            .frame(width: 18)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(todayWorkoutMinutes)m")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text("/ \(workoutGoalMinutes)m")
                                    .font(.caption2)
                                    .foregroundStyle(Color.gray)
                            }
                            Text("WORKOUT TIME")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color.gray.opacity(0.8))
                        }
                    }
                    
                    // Metric 3: Weekly Consistency
                    HStack(spacing: 10) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(blueRingColor)
                            .frame(width: 18)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(weeklyWorkoutDays) days")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text("/ \(weeklyGoalDays)d")
                                    .font(.caption2)
                                    .foregroundStyle(Color.gray)
                            }
                            Text("CONSISTENCY")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color.gray.opacity(0.8))
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(red: 0.08, green: 0.10, blue: 0.14))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

#Preview {
    KokonutAppleActivityCard(
        steps: 8420,
        stepGoal: 10000,
        todayWorkoutMinutes: 45,
        workoutGoalMinutes: 30,
        weeklyWorkoutDays: 4,
        weeklyGoalDays: 5,
        onSyncAppleHealth: {}
    )
    .preferredColorScheme(.dark)
    .padding()
}
