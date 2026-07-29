import SwiftUI
import SwiftData

struct WeeklyScheduleView: View {
    @Query(sort: \WeeklySchedule.dayOfWeek) private var schedule: [WeeklySchedule]
    @State private var selectedDay: WeeklySchedule?
    @State private var showCustomizer = false
    @State private var showDaySplit = false
    @State private var showRestSheet = false
    
    private var todayDayOfWeek: Int {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return weekday == 1 ? 7 : weekday - 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(schedule) { day in
                        let isToday = day.dayOfWeek == todayDayOfWeek
                        let isSelected = selectedDay?.id == day.id && showDaySplit
                        
                        VStack(spacing: 6) {
                            Text(String(day.dayName.prefix(3)))
                                .font(.caption)
                                .fontWeight(isToday ? .medium : .light)
                                .foregroundStyle(isToday ? .black : isSelected ? .black : .white)
                            
                            Text(day.assignedSplit?.name.replacingOccurrences(of: " Day", with: "") ?? "Rest")
                                .font(.system(size: 10))
                                .fontWeight(.light)
                                .foregroundStyle(isToday ? Color.black.opacity(0.7) : isSelected ? Color.black.opacity(0.7) : Color.gray)
                                .lineLimit(1)
                        }
                        .frame(width: 52, height: 58)
                        .background(
                            isToday ? Color(red: 0.68, green: 0.78, blue: 0.90) :
                            isSelected ? Color(red: 0.68, green: 0.78, blue: 0.90).opacity(0.6) :
                            Color(UIColor.secondarySystemBackground)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .onTapGesture {
                            selectedDay = day
                            if day.assignedSplit != nil {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if selectedDay?.id == day.id && showDaySplit {
                                        showDaySplit = false
                                    } else {
                                        showDaySplit = true
                                    }
                                }
                            } else {
                                showRestSheet = true
                            }
                        }
                        .onLongPressGesture {
                            selectedDay = day
                            showCustomizer = true
                        }
                    }
                }
            }
            
            // Inline split preview for selected day
            if showDaySplit, let day = selectedDay, let split = day.assignedSplit {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(day.dayName) —")
                            .font(.subheadline)
                            .fontWeight(.regular)
                            .foregroundStyle(.white)
                        
                        QuickSwapSplitMenu(scheduleEntry: day)
                        
                        Spacer()
                        
                        NavigationLink {
                            SplitDetailView(split: split)
                        } label: {
                            Text("Edit")
                                .font(.caption)
                                .fontWeight(.regular)
                                .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                        }
                    }
                    .padding(.bottom, 12)
                    
                    let sortedEntries = split.entries.sorted { $0.order < $1.order }
                    ForEach(sortedEntries) { entry in
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.25))
                                .frame(height: 0.5)
                            
                            HStack {
                                Text(entry.machine?.name ?? "Unknown")
                                    .font(.caption)
                                    .fontWeight(.regular)
                                    .foregroundStyle(.white)
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    if entry.defaultWeight > 0 {
                                        Text("\(formatWeight(entry.defaultWeight)) kg")
                                            .font(.caption)
                                            .fontWeight(.light)
                                            .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                                    }
                                    Text("\(entry.defaultSets) × \(entry.defaultReps)")
                                        .font(.caption)
                                        .fontWeight(.light)
                                        .foregroundStyle(Color.gray)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                    }
                }
                .padding(16)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Hint text
            if !showDaySplit {
                Text("Tap a day to preview · Long-press to edit")
                    .font(.system(size: 10))
                    .fontWeight(.light)
                    .foregroundStyle(Color.gray.opacity(0.5))
            }
        }
        .sheet(isPresented: $showCustomizer) {
            if let selectedDay {
                ScheduleCustomizerSheet(scheduleEntry: selectedDay)
            }
        }
        .sheet(isPresented: $showRestSheet) {
            if let selectedDay {
                RestDaySheet(scheduleEntry: selectedDay)
            }
        }
    }
    
    private func formatWeight(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
}

#Preview {
    NavigationStack {
        WeeklyScheduleView()
    }
    .modelContainer(for: [
        WeeklySchedule.self, WorkoutSplit.self, SplitMachineEntry.self,
        GymMachine.self, WorkoutSession.self, SetLog.self, UserStats.self,
        BodyWeightEntry.self
    ], inMemory: true)
    .preferredColorScheme(.dark)
}
