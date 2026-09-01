import SwiftUI
import SwiftData
import Charts

enum TimeRange: String, CaseIterable {
    case month = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case all = "All"
}

struct BodyWeightView: View {
    @Query(sort: \BodyWeightEntry.date, order: .reverse) private var entries: [BodyWeightEntry]
    @Environment(\.modelContext) private var modelContext
    @StateObject private var weightUnit = WeightUnitManager.shared
    @State private var inputWeight: Double = 70.0
    @State private var weightText: String = ""
    @State private var selectedRange: TimeRange = .month
    
    private func formatDisplayWeight(_ weight: Double) -> String {
        return String(format: "%.1f", weight)
    }
    
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    
    var filteredEntries: [BodyWeightEntry] {
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
            return entries.filter { $0.date >= start }.sorted { $0.date < $1.date }
        } else {
            return entries.sorted { $0.date < $1.date }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                
                // 1. Header
                Text("Body Weight")
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .foregroundColor(.white)
                
                // 2. Log Card
                VStack(spacing: 16) {
                    Text("Log Today's Weight")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .lastTextBaseline) {
                        TextField("Weight", text: $weightText)
                            .keyboardType(.numbersAndPunctuation)
                    .submitLabel(.done)
                            .onChange(of: weightText) { oldValue, newValue in
                                if let val = Double(newValue) {
                                    inputWeight = val
                                }
                            }
                            .font(.system(size: 40))
                            .fontWeight(.light)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(width: 120)
                        
                        Text(weightUnit.unitLabel)
                            .font(.title3)
                            .fontWeight(.light)
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 24) {
                        Button(action: {
                            if inputWeight > weightUnit.bodyWeightStep { 
                                inputWeight -= weightUnit.bodyWeightStep 
                                weightText = formatDisplayWeight(inputWeight)
                            }
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 20, weight: .light))
                                .frame(width: 44, height: 44)
                                .foregroundColor(.white)
                                .background(Color(UIColor.systemBackground))
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            inputWeight += weightUnit.bodyWeightStep
                            weightText = formatDisplayWeight(inputWeight)
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .light))
                                .frame(width: 44, height: 44)
                                .foregroundColor(.white)
                                .background(Color(UIColor.systemBackground))
                                .clipShape(Circle())
                        }
                    }
                    
                    Button(action: {
                        let storedWeight = weightUnit.toKg(inputWeight)
                        let newEntry = BodyWeightEntry(weight: storedWeight, unit: "kg", date: .now)
                        modelContext.insert(newEntry)
                        try? modelContext.save()
                    }) {
                        Text("Log Weight")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(paleBlue)
                            .clipShape(Capsule())
                    }
                }
                .padding(20)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                
                // 3. Trend Chart
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
                    
                    if filteredEntries.isEmpty {
                        Text("Start logging to see your trend")
                            .foregroundColor(.gray)
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                    } else {
                        let weights = filteredEntries.map { $0.weight }
                        let minWeight = max(0, (weights.min() ?? 60) - 5)
                        let maxWeight = (weights.max() ?? 80) + 5
                        let indexedEntries = Array(filteredEntries.enumerated())
                        
                        Chart(indexedEntries, id: \.element.id) { index, entry in
                            if filteredEntries.count >= 2 {
                                LineMark(
                                    x: .value("Index", index),
                                    y: .value("Weight", entry.weight)
                                )
                                .foregroundStyle(paleBlue)
                                .interpolationMethod(.monotone)
                                .lineStyle(StrokeStyle(lineWidth: 2.5))
                                
                                AreaMark(
                                    x: .value("Index", index),
                                    yStart: .value("Min", minWeight),
                                    yEnd: .value("Weight", entry.weight)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [paleBlue.opacity(0.2), paleBlue.opacity(0.0)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .interpolationMethod(.monotone)
                            }
                            
                            PointMark(
                                x: .value("Index", index),
                                y: .value("Weight", entry.weight)
                            )
                            .foregroundStyle(paleBlue)
                            .symbolSize(36)
                        }
                        .chartYScale(domain: minWeight...maxWeight)
                        .chartXAxis(.hidden)
                        .chartYAxis {
                            AxisMarks { value in
                                AxisValueLabel().foregroundStyle(Color.gray)
                                AxisGridLine().foregroundStyle(Color.gray.opacity(0.15))
                            }
                        }
                        .frame(height: 200)
                        .clipped()
                    }
                }
                
                // 4. Stats Row
                HStack(spacing: 0) {
                    let current = entries.first?.weight ?? 0.0
                    let lowest = filteredEntries.map({ $0.weight }).min() ?? 0.0
                    let firstWeight = filteredEntries.first?.weight ?? current
                    let change = current - firstWeight
                    
                    let displayCurrent = weightUnit.displayWeight(current)
                    let displayLowest = weightUnit.displayWeight(lowest)
                    let displayChange = weightUnit.displayWeight(change)
                    
                    StatItem(label: "Current", value: "\(String(format: "%.1f", displayCurrent)) \(weightUnit.unitLabel)")
                    Spacer()
                    StatItem(label: "Lowest", value: "\(String(format: "%.1f", displayLowest)) \(weightUnit.unitLabel)")
                    Spacer()
                    StatItemChange(label: "Change", change: displayChange, unitLabel: weightUnit.unitLabel)
                }
                .padding(.top, 8)
                
                // 5. History List
                VStack(alignment: .leading, spacing: 12) {
                    Text("History")
                        .font(.headline)
                        .fontWeight(.light)
                        .foregroundColor(.white)
                    
                    let history = entries.prefix(20)
                    ForEach(history) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.date.formatted(.dateTime.day().month().year()))
                                    .font(.body)
                                    .fontWeight(.regular)
                                    .foregroundColor(.white)
                                Text(entry.date.formatted(.dateTime.hour().minute()))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text(weightUnit.formatWeight(entry.weight))
                                .font(.body)
                                .fontWeight(.light)
                                .foregroundColor(.gray)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                modelContext.delete(entry)
                                try? modelContext.save()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
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
        .onAppear {
            if let latest = entries.first {
                inputWeight = weightUnit.displayWeight(latest.weight)
                weightText = formatDisplayWeight(inputWeight)
            } else {
                weightText = formatDisplayWeight(inputWeight)
            }
        }
    }
}

struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
                .fontWeight(.light)
                .foregroundColor(.white)
        }
    }
}

struct StatItemChange: View {
    let label: String
    let change: Double
    let unitLabel: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack(spacing: 4) {
                let arrow = change > 0 ? "↑" : change < 0 ? "↓" : "→"
                let color: Color = change > 0 ? .red.opacity(0.7) : change < 0 ? .green.opacity(0.7) : .gray
                Text("\(arrow) \(String(format: "%.1f", abs(change))) \(unitLabel)")
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundColor(color)
            }
        }
    }
}

#Preview {
    NavigationStack {
        BodyWeightView()
    }
    .modelContainer(for: [BodyWeightEntry.self], inMemory: true)
    .preferredColorScheme(.dark)
}
