import Foundation
import ActivityKit

extension Activity: @unchecked Sendable {}

@MainActor
final class RestTimerActivityManager: ObservableObject {
    static let shared = RestTimerActivityManager()
    
    private var currentActivity: Activity<RestTimerAttributes>? = nil
    
    private init() {}
    
    func startActivity(duration: Int, exerciseName: String = "Rest", currentSet: Int = 0, totalSets: Int = 0, isResting: Bool = true) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        endActivity()
        
        let attributes = RestTimerAttributes(totalDuration: duration)
        let endTime = Date().addingTimeInterval(TimeInterval(duration))
        let state = RestTimerAttributes.ContentState(endTime: endTime, exerciseName: exerciseName, currentSet: currentSet, totalSets: totalSets, isResting: isResting)
        let content = ActivityContent(state: state, staleDate: endTime)
        
        do {
            self.currentActivity = try Activity<RestTimerAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print("[LiveActivity] Failed to start rest timer activity: \(error)")
        }
    }
    
    func endActivity() {
        guard let activity = currentActivity else { return }
        self.currentActivity = nil
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
