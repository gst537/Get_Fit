import Foundation
import ActivityKit

struct RestTimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endTime: Date
        var exerciseName: String
        var currentSet: Int
        var totalSets: Int
        var isResting: Bool
        
        public init(endTime: Date, exerciseName: String = "Rest", currentSet: Int = 0, totalSets: Int = 0, isResting: Bool = true) {
            self.endTime = endTime
            self.exerciseName = exerciseName
            self.currentSet = currentSet
            self.totalSets = totalSets
            self.isResting = isResting
        }
    }
    
    var totalDuration: Int
    
    public init(totalDuration: Int) {
        self.totalDuration = totalDuration
    }
}
