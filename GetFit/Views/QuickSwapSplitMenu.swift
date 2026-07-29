import SwiftUI
import SwiftData

struct QuickSwapSplitMenu: View {
    let scheduleEntry: WeeklySchedule
    @Query private var splits: [WorkoutSplit]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showCustomSplitAlert = false
    @State private var customSplitName = ""
    
    var currentSplitName: String {
        scheduleEntry.assignedSplit?.name ?? "Rest Day"
    }
    
    var body: some View {
        Menu {
            // Preset & Existing Splits
            ForEach(splits) { split in
                Button {
                    reassignSplit(to: split)
                } label: {
                    HStack {
                        Text(split.name)
                        if scheduleEntry.assignedSplit?.id == split.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            
            Divider()
            
            // Rest Day Option
            Button {
                reassignSplit(to: nil)
            } label: {
                HStack {
                    Text("Rest Day")
                    if scheduleEntry.assignedSplit == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Divider()
            
            // Custom Split Option
            Button {
                showCustomSplitAlert = true
            } label: {
                Label("Custom Split...", systemImage: "plus")
            }
        } label: {
            HStack(spacing: 6) {
                Text(currentSplitName)
                    .font(.title2)
                    .fontWeight(.light)
                    .foregroundStyle(.white)
                
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
            }
        }
        .alert("New Custom Split", isPresented: $showCustomSplitAlert) {
            TextField("e.g., Upper Body", text: $customSplitName)
            Button("Cancel", role: .cancel) { customSplitName = "" }
            Button("Assign") {
                createAndAssignCustomSplit(name: customSplitName)
            }
        } message: {
            Text("Enter a name for your new workout split.")
        }
    }
    
    private func reassignSplit(to split: WorkoutSplit?) {
        scheduleEntry.assignedSplit = split
        try? modelContext.save()
    }
    
    private func createAndAssignCustomSplit(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let newSplit = WorkoutSplit(name: trimmed, status: "Active")
        modelContext.insert(newSplit)
        scheduleEntry.assignedSplit = newSplit
        try? modelContext.save()
        customSplitName = ""
    }
}

#Preview {
    let day = WeeklySchedule(dayOfWeek: 1, dayName: "Monday")
    return QuickSwapSplitMenu(scheduleEntry: day)
        .modelContainer(for: [WeeklySchedule.self, WorkoutSplit.self], inMemory: true)
        .preferredColorScheme(.dark)
}
