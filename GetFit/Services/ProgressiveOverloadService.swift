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
        equipmentType: String = "Barbell",
        category: String = "Chest",
        defaultWeight: Double = 0.0,
        defaultReps: Int = 10,
        completedSessions: [WorkoutSession]
    ) -> ProgressiveOverloadRecommendation {
        
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
                targetReps: defaultReps,
                reason: "First session baseline recorded.",
                isOverloadTriggered: false,
                isDeloadTriggered: false
            )
        }
        
        let previousWeight = maxWeightLog.weight
        let minRepsHit = lastSessionLogs.map { $0.reps }.min() ?? 0
        
        // Determine upper vs lower body increment (+2.5 kg vs +5.0 kg)
        let lowerBodyCategories = ["legs", "quads", "hamstrings", "glutes", "calves", "squat", "deadlift", "leg press"]
        let isLowerBody = lowerBodyCategories.contains { category.lowercased().contains($0) || exerciseName.lowercased().contains($0) }
        let increment = isLowerBody ? 5.0 : 2.5
        
        // Rule 1: Double Progression - If all sets hit >= defaultReps (e.g. 10 reps)
        if minRepsHit >= defaultReps {
            let newWeight = previousWeight + increment
            return ProgressiveOverloadRecommendation(
                exerciseName: exerciseName,
                previousWeight: previousWeight,
                recommendedWeight: newWeight,
                weightDelta: increment,
                targetReps: defaultReps,
                reason: "Hit target \(defaultReps) reps on all sets! Ready for +\(String(format: "%.1f", increment)) kg overload.",
                isOverloadTriggered: true,
                isDeloadTriggered: false
            )
        }
        
        // Rule 2: Check for 2 consecutive failed sessions (stagnation guard -> -10% deload)
        if historyLogs.count >= 2 {
            let prevSessionLogs = historyLogs[1]
            let prevMinReps = prevSessionLogs.map { $0.reps }.min() ?? 0
            
            if minRepsHit < (defaultReps - 2) && prevMinReps < (defaultReps - 2) {
                let deloadWeight = max(0.0, (previousWeight * 0.90).roundedToNearestHalf())
                let delta = previousWeight - deloadWeight
                return ProgressiveOverloadRecommendation(
                    exerciseName: exerciseName,
                    previousWeight: previousWeight,
                    recommendedWeight: deloadWeight,
                    weightDelta: -delta,
                    targetReps: defaultReps,
                    reason: "Missed target reps for 2 workouts. Auto-deloading -10% to reset form.",
                    isOverloadTriggered: false,
                    isDeloadTriggered: true
                )
            }
        }
        
        // Rule 3: Maintenance / Working towards target reps
        return ProgressiveOverloadRecommendation(
            exerciseName: exerciseName,
            previousWeight: previousWeight,
            recommendedWeight: previousWeight,
            weightDelta: 0.0,
            targetReps: defaultReps,
            reason: "Current target: \(previousWeight) kg. Hit all \(defaultReps) reps to unlock +\(String(format: "%.1f", increment)) kg.",
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
