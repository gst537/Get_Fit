import SwiftUI
import SwiftData

@main
struct GetFitApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([
            GymMachine.self,
            WorkoutSplit.self,
            SplitMachineEntry.self,
            WorkoutSession.self,
            SetLog.self,
            UserStats.self,
            WeeklySchedule.self,
            BodyWeightEntry.self,
            CardioLog.self,
            NutritionGoal.self,
            MealLog.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}
