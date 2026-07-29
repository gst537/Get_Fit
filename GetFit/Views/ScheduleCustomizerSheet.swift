import SwiftUI
import SwiftData

struct ScheduleCustomizerSheet: View {
    let scheduleEntry: WeeklySchedule
    @Query private var splits: [WorkoutSplit]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Assign Routine")
                    .font(.title2)
                    .fontWeight(.light)
                    .foregroundStyle(.white)
                
                Text(scheduleEntry.dayName)
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundStyle(Color.gray)
            }
            
            VStack(spacing: 0) {
                // Rest Day option
                Button {
                    scheduleEntry.assignedSplit = nil
                    dismiss()
                } label: {
                    HStack {
                        Text("Rest Day")
                            .font(.body)
                            .fontWeight(.regular)
                            .foregroundStyle(.white)
                        Spacer()
                        if scheduleEntry.assignedSplit == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                        }
                    }
                    .padding(.vertical, 15)
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 0.5)
                
                // Split options
                ForEach(splits) { split in
                    Button {
                        scheduleEntry.assignedSplit = split
                        dismiss()
                    } label: {
                        HStack {
                            Text(split.name)
                                .font(.body)
                                .fontWeight(.regular)
                                .foregroundStyle(.white)
                            Spacer()
                            if scheduleEntry.assignedSplit?.id == split.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                            }
                        }
                        .padding(.vertical, 15)
                    }
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.25))
                        .frame(height: 0.5)
                }
            }
            
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    Text("Preview")
        .sheet(isPresented: .constant(true)) {
            ScheduleCustomizerSheet(scheduleEntry: WeeklySchedule(dayOfWeek: 1, dayName: "Monday", assignedSplit: nil))
                .modelContainer(for: [WorkoutSplit.self, SplitMachineEntry.self, GymMachine.self], inMemory: true)
                .preferredColorScheme(.dark)
        }
}
