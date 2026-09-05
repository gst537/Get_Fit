import SwiftUI
import SwiftData

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var selectedTab = 0 // 0: Workouts, 1: Nutrition
    @Published var activeSession: WorkoutSession?
    @Published var selectedExercise: GymMachine?
    @Published var showCreateExercise = false
    @Published var showScanSheet = false
    @Published var selectedEntryToEdit: SplitMachineEntry?
    @Published var showProfileSheet = false
    @Published var showRestDaySheet = false
    
    // Derived states
    func todayDayOfWeek() -> Int {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return weekday == 1 ? 7 : weekday - 1
    }
    
    func todaySchedule(schedule: [WeeklySchedule]) -> WeeklySchedule? {
        let dayOfWeek = todayDayOfWeek()
        return schedule.first { $0.dayOfWeek == dayOfWeek }
    }
    
    func todaySplit(schedule: [WeeklySchedule]) -> WorkoutSplit? {
        todaySchedule(schedule: schedule)?.assignedSplit
    }
    
    func isRestDay(schedule: [WeeklySchedule]) -> Bool {
        todaySplit(schedule: schedule) == nil
    }
    
    func calculatedStreak(
        completedSessions: [WorkoutSession],
        cardioLogs: [CardioLog],
        stats: UserStats?,
        modelContext: ModelContext
    ) -> Int {
        let calendar = Calendar.current
        var activityDates = Set<Date>()
        
        for session in completedSessions {
            activityDates.insert(calendar.startOfDay(for: session.date))
        }
        for cardio in cardioLogs {
            activityDates.insert(calendar.startOfDay(for: cardio.date))
        }
        
        guard !activityDates.isEmpty else { return 0 }
        
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        if !activityDates.contains(checkDate) {
            guard let prevDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = prevDay
        }
        
        while activityDates.contains(checkDate) {
            streak += 1
            guard let prevDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prevDay
        }
        
        // Sync with UserStats model
        if let stats = stats, stats.streakCount != streak {
            stats.streakCount = streak
            try? modelContext.save()
        }
        
        return streak
    }
}
