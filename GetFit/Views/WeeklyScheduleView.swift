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
    
    let tCyan = PremiumColors.neonCyan
    let tWhite = PremiumColors.starkWhite
    let tGray = PremiumColors.midGray
    let tBlack = PremiumColors.deepBlack
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(schedule) { day in
                        let isToday = day.dayOfWeek == todayDayOfWeek
                        let isSelected = selectedDay?.id == day.id && showDaySplit
                        
                        VStack(spacing: 8) {
                            Text(String(day.dayName.prefix(3)))
                                .font(PremiumFonts.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(isToday ? tBlack : isSelected ? tBlack : tWhite)
                            
                            Text(day.assignedSplit?.name.replacingOccurrences(of: " Day", with: "") ?? "Rest")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(isToday ? tBlack : isSelected ? tBlack : tGray)
                                .lineLimit(1)
                        }
                        .frame(width: 60, height: 68)
                        .background(
                            isToday ? tCyan :
                            isSelected ? tWhite :
                            PremiumColors.glassBackground
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(isToday ? tCyan : isSelected ? tWhite : PremiumColors.glassBorder, lineWidth: 1)
                        )
                        .shadow(color: isToday ? tCyan.opacity(0.4) : .clear, radius: 4)
                        .onTapGesture {
                            selectedDay = day
                            if day.assignedSplit != nil {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
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
            if showDaySplit, let selectedId = selectedDay?.id, let day = schedule.first(where: { $0.id == selectedId }), let split = day.assignedSplit {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(day.dayName) —")
                            .font(PremiumFonts.headline)
                            .foregroundStyle(tWhite)
                        
                        QuickSwapSplitMenu(scheduleEntry: day)
                        
                        Spacer()
                        
                        NavigationLink {
                            SplitDetailView(split: split)
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(tCyan)
                        }
                    }
                    .padding(.bottom, 16)
                    
                    let sortedEntries = split.entries.sorted { $0.order < $1.order }
                    ForEach(sortedEntries) { entry in
                        VStack(spacing: 0) {
                            Divider().background(PremiumColors.glassBorder)
                            
                            HStack {
                                Text(entry.machine?.name ?? "Unknown")
                                    .font(PremiumFonts.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(tWhite)
                                
                                Spacer()
                                
                                HStack(spacing: 12) {
                                    if entry.defaultWeight > 0 {
                                        Text("\(formatWeight(entry.defaultWeight)) kg")
                                            .font(PremiumFonts.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(tCyan)
                                    }
                                    Text("\(entry.defaultSets) × \(entry.defaultReps)")
                                        .font(PremiumFonts.caption)
                                        .foregroundStyle(tGray)
                                }
                            }
                            .padding(.vertical, 12)
                        }
                    }
                }
                .padding(20)
                .glassmorphic(cornerRadius: 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Hint text
            if !showDaySplit {
                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                    Text("Tap to preview, Long-press to edit")
                }
                .font(PremiumFonts.caption)
                .foregroundStyle(tGray)
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
