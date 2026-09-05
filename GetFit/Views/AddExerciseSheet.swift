import SwiftUI
import SwiftData

struct AddExerciseSheet: View {
    let split: WorkoutSplit
    @Query private var allMachines: [GymMachine]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""

    private var existingMachineIds: Set<UUID> {
        Set(split.entries.compactMap { $0.machine?.id })
    }

    private var availableMachines: [GymMachine] {
        let filtered = allMachines.filter { !existingMachineIds.contains($0.id) }
        if searchText.isEmpty { return filtered }
        return filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var groupedByCategory: [(MachineCategory, [GymMachine])] {
        let grouped = Dictionary(grouping: availableMachines, by: { $0.category })
        return grouped.sorted { $0.key.rawValue < $1.key.rawValue }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Add Exercise")
                    .font(.title2)
                    .fontWeight(.light)
                    .foregroundStyle(.white)

                Spacer()

                Button("Done") { dismiss() }
                    .font(.body)
                    .fontWeight(.regular)
                    .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
            }

            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.gray)
                    .font(.system(size: 14))

                TextField("Search exercises", text: $searchText)
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundStyle(.white)
            }
            .padding(12)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Exercise list
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if availableMachines.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 36))
                                .fontWeight(.ultraLight)
                                .foregroundStyle(Color.gray.opacity(0.5))

                            Text("All exercises added")
                                .font(.body)
                                .fontWeight(.light)
                                .foregroundStyle(Color.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(groupedByCategory, id: \.0) { category, machines in
                            VStack(alignment: .leading, spacing: 0) {
                                Text(category.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.light)
                                    .foregroundStyle(Color.gray)
                                    .padding(.bottom, 8)

                                ForEach(machines) { machine in
                                    VStack(spacing: 0) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.25))
                                            .frame(height: 0.5)

                                        Button {
                                            addExercise(machine)
                                        } label: {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(machine.name)
                                                        .font(.body)
                                                        .fontWeight(.regular)
                                                        .foregroundStyle(.white)

                                                    Text(machine.targetMuscles.joined(separator: ", "))
                                                        .font(.caption)
                                                        .fontWeight(.light)
                                                        .foregroundStyle(Color.gray)
                                                        .lineLimit(1)
                                                }

                                                Spacer()

                                                Image(systemName: "plus.circle")
                                                    .font(.system(size: 20))
                                                    .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                                            }
                                            .padding(.vertical, 12)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private func addExercise(_ machine: GymMachine) {
        let nextOrder = (split.entries.map { $0.order }.max() ?? -1) + 1
        let entry = SplitMachineEntry(order: nextOrder, defaultSets: 3, defaultReps: 10, machine: machine)
        entry.split = split
        modelContext.insert(entry)
        try? modelContext.save()
    }
}

// MARK: - Preview

#Preview {
    Text("Preview")
        .sheet(isPresented: .constant(true)) {
            AddExerciseSheet(split: WorkoutSplit(name: "Push Day", status: .active))
                .modelContainer(for: [GymMachine.self, WorkoutSplit.self, SplitMachineEntry.self], inMemory: true)
                .preferredColorScheme(.dark)
        }
}
