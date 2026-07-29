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
            CardioLog.self
        ])
        do {
            container = try ModelContainer(for: schema)
        } catch {
            let config = ModelConfiguration()
            if let url = config.url as URL? {
                try? FileManager.default.removeItem(at: url)
            }
            container = try! ModelContainer(for: schema)
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
