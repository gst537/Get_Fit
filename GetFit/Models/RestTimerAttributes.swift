import Foundation
import ActivityKit

struct RestTimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endTime: Date
        var exerciseName: String
        
        public init(endTime: Date, exerciseName: String = "Rest") {
            self.endTime = endTime
            self.exerciseName = exerciseName
        }
    }
    
    var totalDuration: Int
    
    public init(totalDuration: Int) {
        self.totalDuration = totalDuration
    }
}
