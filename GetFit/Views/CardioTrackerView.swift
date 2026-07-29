import SwiftUI
import SwiftData

struct CardioTrackerView: View {
    @Query(sort: \CardioLog.date, order: .reverse) private var logs: [CardioLog]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showLogSheet = false
    
    // Form states
    @State private var selectedActivity = "Treadmill Run"
    @State private var durationMinutes: String = "25"
    @State private var distanceKm: String = "3.0"
    @State private var caloriesBurned: String = "200"
    @State private var notes: String = ""
    
    let activities = ["Treadmill Run", "Outdoor Run", "Stairmaster", "Cycling", "Rowing", "Elliptical", "Walking"]
    
    var weeklyLogs: [CardioLog] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return logs.filter { $0.date >= startOfWeek }
    }
    
    var totalWeeklyDuration: Double {
        weeklyLogs.reduce(0) { $0 + $1.durationMinutes }
    }
    
    var totalWeeklyDistance: Double {
        weeklyLogs.reduce(0) { $0 + $1.distanceKm }
    }
    
    var totalWeeklyCalories: Int {
        weeklyLogs.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // 1. Weekly Stats Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("This Week's Cardio")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(formatDuration(totalWeeklyDuration))
                                .font(.system(size: 28, weight: .light))
                                .foregroundStyle(.white)
                            Text("Total Time")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                        
                        Divider()
                            .frame(height: 36)
                            .background(Color.gray.opacity(0.3))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(format: "%.1f km", totalWeeklyDistance))
                                .font(.system(size: 28, weight: .light))
                                .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                            Text("Distance")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                        
                        Divider()
                            .frame(height: 36)
                            .background(Color.gray.opacity(0.3))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(totalWeeklyCalories)")
                                .font(.system(size: 28, weight: .light))
                                .foregroundStyle(.white)
                            Text("Calories")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // 2. Log Cardio Button
                Button {
                    showLogSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Log Cardio Session")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.68, green: 0.78, blue: 0.90))
                    .clipShape(Capsule())
                }
                
                // 3. Cardio History Logs
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cardio History")
                        .font(.headline)
                        .fontWeight(.light)
                        .foregroundStyle(.white)
                    
                    if logs.isEmpty {
                        HStack {
                            Image(systemName: "figure.run")
                                .font(.title2)
                                .foregroundStyle(Color.gray.opacity(0.5))
                            Text("No cardio logged yet. Perform a 20-30 min finisher or full cardio session!")
                                .font(.caption)
                                .fontWeight(.light)
                                .foregroundStyle(Color.gray)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        ForEach(logs) { log in
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.68, green: 0.78, blue: 0.90).opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: iconForActivity(log.activityType))
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(log.activityType)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.white)
                                    
                                    Text(log.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(Color.gray)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(Int(log.durationMinutes)) min")
                                        .font(.body)
                                        .fontWeight(.regular)
                                        .foregroundStyle(.white)
                                    
                                    if log.distanceKm > 0 {
                                        Text(String(format: "%.1f km", log.distanceKm))
                                            .font(.caption)
                                            .fontWeight(.light)
                                            .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .contextMenu {
                                Button(role: .destructive) {
                                    modelContext.delete(log)
                                    try? modelContext.save()
                                } label: {
                                    Label("Delete Log", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(Color(UIColor.systemBackground))
        .navigationTitle("Cardio Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showLogSheet) {
            logCardioSheet
        }
    }
    
    // MARK: - Log Cardio Sheet
    
    private var logCardioSheet: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Log Cardio")
                        .font(.title2)
                        .fontWeight(.light)
                        .foregroundStyle(.white)
                    Spacer()
                    Button("Cancel") {
                        showLogSheet = false
                    }
                    .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                }
                
                // Activity Type Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Activity Type")
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(activities, id: \.self) { act in
                                Text(act)
                                    .font(.subheadline)
                                    .fontWeight(selectedActivity == act ? .medium : .regular)
                                    .foregroundStyle(selectedActivity == act ? .black : Color.gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedActivity == act ? Color(red: 0.68, green: 0.78, blue: 0.90) : Color(UIColor.secondarySystemBackground))
                                    .clipShape(Capsule())
                                    .onTapGesture {
                                        selectedActivity = act
                                    }
                            }
                        }
                    }
                }
                
                // Duration Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Duration (Minutes)")
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                    
                    HStack(spacing: 12) {
                        ForEach(["15", "20", "25", "30", "45", "60"], id: \.self) { preset in
                            Button(preset + "m") {
                                durationMinutes = preset
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(durationMinutes == preset ? Color(red: 0.68, green: 0.78, blue: 0.90).opacity(0.2) : Color(UIColor.secondarySystemBackground))
                            .foregroundStyle(durationMinutes == preset ? Color(red: 0.68, green: 0.78, blue: 0.90) : .gray)
                            .clipShape(Capsule())
                        }
                    }
                    
                    TextField("Duration (min)", text: $durationMinutes)
                        .keyboardType(.decimalPad)
                        .padding(14)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Distance Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Distance (km)")
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                    
                    TextField("Distance (km)", text: $distanceKm)
                        .keyboardType(.decimalPad)
                        .padding(14)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Calories Input (Optional)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Calories Burned (optional)")
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                    
                    TextField("e.g. 250", text: $caloriesBurned)
                        .keyboardType(.numberPad)
                        .padding(14)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Save Button
                Button {
                    saveCardioLog()
                } label: {
                    Text("Save Cardio Log")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.68, green: 0.78, blue: 0.90))
                        .clipShape(Capsule())
                }
                .padding(.top, 16)
            }
            .padding(24)
        }
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    private func saveCardioLog() {
        let duration = Double(durationMinutes) ?? 25.0
        let distance = Double(distanceKm) ?? 0.0
        let calories = Int(caloriesBurned) ?? 0
        
        let log = CardioLog(
            activityType: selectedActivity,
            durationMinutes: duration,
            distanceKm: distance,
            caloriesBurned: calories,
            notes: notes
        )
        modelContext.insert(log)
        try? modelContext.save()
        showLogSheet = false
    }
    
    private func iconForActivity(_ type: String) -> String {
        switch type {
        case "Treadmill Run", "Outdoor Run": return "figure.run"
        case "Cycling": return "figure.outdoor.cycle"
        case "Stairmaster": return "figure.stair.stepper"
        case "Rowing": return "figure.rower"
        case "Elliptical": return "figure.elliptical"
        case "Walking": return "figure.walk"
        default: return "figure.run"
        }
    }
    
    private func formatDuration(_ minutes: Double) -> String {
        let totalMin = Int(minutes)
        let hours = totalMin / 60
        let mins = totalMin % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins) min"
        }
    }
}

#Preview {
    NavigationStack {
        CardioTrackerView()
            .modelContainer(for: CardioLog.self, inMemory: true)
            .preferredColorScheme(.dark)
    }
}
