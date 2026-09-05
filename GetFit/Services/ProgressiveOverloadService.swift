import Foundation
import SwiftData

struct ProgressiveOverloadRecommendation: Sendable {
    let exerciseName: String
    let previousWeight: Double
    let recommendedWeight: Double
    let weightDelta: Double
    let targetReps: Int
    let reason: String
    let isOverloadTriggered: Bool
    let isDeloadTriggered: Bool
}

final class ProgressiveOverloadService: @unchecked Sendable {
    static let shared = ProgressiveOverloadService()
    
    private init() {}
    
    /// Analyzes historical completed sessions for an exercise and returns a smart overload recommendation.
    func calculateRecommendation(
        for exerciseName: String,
        equipmentType: EquipmentType = .barbell,
        category: MachineCategory = .push,
        defaultWeight: Double = 0.0,
        defaultReps: Int = 12,
        completedSessions: [WorkoutSession]
    ) -> ProgressiveOverloadRecommendation {
        
        let targetRepsCap = defaultReps > 0 ? defaultReps : 12
        
        // Filter completed sessions that contain set logs for this exercise
        let relevantSessions = completedSessions
            .filter { $0.isCompleted }
            .sorted { $0.date > $1.date } // Newest first
        
        // Find set logs for this exercise across historical sessions
        var historyLogs: [[SetLog]] = []
        for session in relevantSessions {
            let logs = session.setLogs.filter { $0.machineName.lowercased() == exerciseName.lowercased() && $0.weight > 0 }
            if !logs.isEmpty {
                historyLogs.append(logs)
            }
        }
        
        // If no history exists, return default baseline
        guard let lastSessionLogs = historyLogs.first, let maxWeightLog = lastSessionLogs.max(by: { $0.weight < $1.weight }) else {
            let baseWeight = defaultWeight > 0 ? defaultWeight : 20.0
            return ProgressiveOverloadRecommendation(
                exerciseName: exerciseName,
                previousWeight: baseWeight,
                recommendedWeight: baseWeight,
                weightDelta: 0.0,
                targetReps: targetRepsCap,
                reason: "First session baseline recorded.",
                isOverloadTriggered: false,
                isDeloadTriggered: false
            )
        }
        
        var increment: Double = 0.0
        
        switch equipmentType {
        case .dumbbell, .kettlebell:
            increment = 2.5
        case .barbell, .machine, .cable:
            increment = category == .legs ? 5.0 : 2.5
        case .bodyweight, .other:
            increment = 0.0 // progression via reps/form for bodyweight
        }
        
        let previousWeight = maxWeightLog.weight
        let minRepsHit = lastSessionLogs.map { $0.reps }.min() ?? 0
        
        
        // Rule 1: Double Progression - If all sets hit >= 12 reps (or targetRepsCap)
        if minRepsHit >= targetRepsCap {
            let newWeight = previousWeight + increment
            return ProgressiveOverloadRecommendation(
                exerciseName: exerciseName,
                previousWeight: previousWeight,
                recommendedWeight: newWeight,
                weightDelta: increment,
                targetReps: targetRepsCap,
                reason: "Hit \(targetRepsCap)/\(targetRepsCap) reps on all sets! Ready for +\(String(format: "%.1f", increment)) kg overload.",
                isOverloadTriggered: true,
                isDeloadTriggered: false
            )
        }
        
        // Rule 2: Check for 2 consecutive struggling sessions (< 8 reps hit)
        if historyLogs.count >= 2 {
            let prevSessionLogs = historyLogs[1]
            let prevMinReps = prevSessionLogs.map { $0.reps }.min() ?? 0
            
            if minRepsHit < 8 && prevMinReps < 8 {
                let deloadWeight = max(0.0, (previousWeight * 0.90).roundedToNearestHalf())
                let delta = previousWeight - deloadWeight
                return ProgressiveOverloadRecommendation(
                    exerciseName: exerciseName,
                    previousWeight: previousWeight,
                    recommendedWeight: deloadWeight,
                    weightDelta: -delta,
                    targetReps: targetRepsCap,
                    reason: "Hit under 8 reps for 2 workouts. Auto-resetting -10% weight to rebuild form.",
                    isOverloadTriggered: false,
                    isDeloadTriggered: true
                )
            }
        }
        
        // Rule 3: Working Range (8-12 reps) - Keep current weight & build back up to 12 reps
        return ProgressiveOverloadRecommendation(
            exerciseName: exerciseName,
            previousWeight: previousWeight,
            recommendedWeight: previousWeight,
            weightDelta: 0.0,
            targetReps: targetRepsCap,
            reason: "Current Target: \(previousWeight) kg. Build up from \(minRepsHit) to \(targetRepsCap) reps to unlock +\(String(format: "%.1f", increment)) kg.",
            isOverloadTriggered: false,
            isDeloadTriggered: false
        )
    }
}

extension Double {
    func roundedToNearestHalf() -> Double {
        return (self * 2.0).rounded() / 2.0
    }
}
