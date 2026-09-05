import SwiftUI
import SwiftData
import Charts

struct ProgressionChartView: View {
    let exercise: GymMachine
    @Query(filter: #Predicate<WorkoutSession> { $0.isCompleted == true }, sort: \WorkoutSession.date) private var sessions: [WorkoutSession]
    @State private var selectedRange: TimeRange = .threeMonths
    
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    
    var relevantLogs: [(date: Date, maxWeight: Double, maxReps: Int)] {
        var groupedByDate: [Date: (maxWeight: Double, maxReps: Int)] = [:]
        
        for session in sessions {
            let sessionLogs = session.setLogs.filter { $0.machineId == exercise.id }
            if !sessionLogs.isEmpty {
                if let maxLog = sessionLogs.max(by: { $0.weight < $1.weight }) {
                    groupedByDate[session.date] = (maxWeight: maxLog.weight, maxReps: maxLog.reps)
                }
            }
        }
        
        return groupedByDate.map { (date: $0.key, maxWeight: $0.value.maxWeight, maxReps: $0.value.maxReps) }
            .sorted { $0.date < $1.date }
    }
    
    var personalRecord: (date: Date, maxWeight: Double, maxReps: Int)? {
        relevantLogs.max { $0.maxWeight < $1.maxWeight }
    }
    
    var filteredLogs: [(date: Date, maxWeight: Double, maxReps: Int)] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date?
        
        switch selectedRange {
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: now)
        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: now)
        case .all:
            startDate = nil
        }
        
        if let start = startDate {
            return relevantLogs.filter { $0.date >= start }
        }
        return relevantLogs
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 1. Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(exercise.name)
                        .font(.title2)
                        .fontWeight(.light)
                        .foregroundColor(.white)
                    
                    Text(exercise.equipmentType.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Capsule())
                        .foregroundColor(.white)
                }
                
                // 2. Stats Row
                HStack(spacing: 12) {
                    StatCard(title: "Current Max", value: relevantLogs.last.map { String(format: "%.1f", $0.maxWeight) } ?? "--")
                    StatCard(title: "All-Time PR", value: personalRecord.map { "🏆 " + String(format: "%.1f", $0.maxWeight) } ?? "--")
                    StatCard(title: "Total Sets", value: "\(sessions.flatMap({ $0.setLogs }).filter({ $0.machineId == exercise.id }).count)")
                }
                
                // 3. Chart
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue)
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(selectedRange == range ? paleBlue : Color(UIColor.secondarySystemBackground))
                                .foregroundColor(selectedRange == range ? .black : .gray)
                                .clipShape(Capsule())
                                .onTapGesture {
                                    selectedRange = range
                                }
                        }
                    }
                    
                    if filteredLogs.isEmpty {
                        Text("Complete workouts to track progress")
                            .foregroundColor(.gray)
                            .frame(height: 250)
                            .frame(maxWidth: .infinity)
                    } else {
                        Chart {
                            ForEach(filteredLogs, id: \.date) { log in
                                LineMark(
                                    x: .value("Date", log.date),
                                    y: .value("Weight", log.maxWeight)
                                )
                                .foregroundStyle(paleBlue)
                                
                                PointMark(
                                    x: .value("Date", log.date),
                                    y: .value("Weight", log.maxWeight)
                                )
                                .foregroundStyle(paleBlue)
                            }
                            
                            if let pr = personalRecord {
                                RuleMark(y: .value("PR", pr.maxWeight))
                                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                                    .foregroundStyle(Color.yellow)
                                    .annotation(position: .top, alignment: .leading) {
                                        Text("PR")
                                            .font(.caption)
                                            .foregroundColor(.yellow)
                                    }
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic) { value in
                                AxisValueLabel().foregroundStyle(Color.gray)
                            }
                        }
                        .chartYAxis {
                            AxisMarks { value in
                                AxisValueLabel().foregroundStyle(Color.gray)
                                AxisGridLine().foregroundStyle(Color.gray.opacity(0.2))
                            }
                        }
                        .frame(height: 250)
                    }
                }
                
                // 4. Session History
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Sessions")
                        .font(.headline)
                        .fontWeight(.light)
                        .foregroundColor(.white)
                    
                    let history = filteredLogs.reversed().prefix(10)
                    ForEach(Array(history), id: \.date) { log in
                        HStack {
                            Text(log.date.formatted(.dateTime.month().day().year()))
                                .font(.body)
                                .fontWeight(.regular)
                                .foregroundColor(.white)
                            Spacer()
                            Text(String(format: "%.1f", log.maxWeight))
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(paleBlue)
                            Text("× \(log.maxReps)")
                                .font(.body)
                                .fontWeight(.light)
                                .foregroundColor(.gray)
                        }
                        Divider().background(Color.gray.opacity(0.3))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Text(value)
                .font(.body)
                .fontWeight(.light)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    // Assuming GymMachine can be initialized this way
    // ProgressionChartView(exercise: GymMachine(id: UUID(), name: "Bench Press", category: "Chest", equipmentType: "Barbell"))
    //     .modelContainer(for: [WorkoutSession.self, GymMachine.self], inMemory: true)
    Text("Preview temporarily disabled to prevent init errors. Uncomment to test.")
}
