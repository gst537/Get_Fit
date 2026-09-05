import WidgetKit
import SwiftUI
import ActivityKit

struct RestTimerLiveActivity: Widget {
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RestTimerAttributes.self) { context in
            // Lock Screen Banner View
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                    Image(systemName: "timer")
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(paleBlue)
                }
                .frame(width: 38, height: 38)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.state.isResting ? "Resting — Set \(context.state.currentSet)/\(context.state.totalSets)" : "Active Set \(context.state.currentSet)/\(context.state.totalSets)")
                        .font(.caption)
                        .fontWeight(.light)
                        .foregroundStyle(.gray)
                    
                    Text(context.state.exerciseName)
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                    .font(.system(size: 28, weight: .light, design: .monospaced))
                    .foregroundStyle(paleBlue)
            }
            .padding(16)
            .activityBackgroundTint(Color(UIColor.systemBackground))
            .activitySystemActionForegroundColor(paleBlue)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Dynamic Island View
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .foregroundStyle(paleBlue)
                        Text(context.state.isResting ? "Resting" : "Active Set")
                            .font(.subheadline)
                            .fontWeight(.light)
                            .foregroundStyle(.gray)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                        .font(.system(size: 20, weight: .light, design: .monospaced))
                        .foregroundStyle(paleBlue)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("Set \(context.state.currentSet) of \(context.state.totalSets) — \(context.state.exerciseName)")
                            .font(.caption2)
                            .foregroundStyle(.gray.opacity(0.5))
                        Spacer()
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(paleBlue)
            } compactTrailing: {
                Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                    .font(.system(size: 13, weight: .light, design: .monospaced))
                    .foregroundStyle(paleBlue)
                    .frame(width: 42)
            } minimal: {
                Image(systemName: "timer")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(paleBlue)
            }
        }
    }
}
