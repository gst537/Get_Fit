import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NavigationStack {
            DashboardView()
                .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            GymMachine.self, WorkoutSplit.self, SplitMachineEntry.self,
            WorkoutSession.self, SetLog.self, UserStats.self,
            WeeklySchedule.self, BodyWeightEntry.self
        ], inMemory: true)
        .preferredColorScheme(.dark)
}
