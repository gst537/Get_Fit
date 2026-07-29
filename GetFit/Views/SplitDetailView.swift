import SwiftUI
import SwiftData

struct SplitDetailView: View {
    let split: WorkoutSplit
    @Environment(\.modelContext) private var modelContext
    @State private var selectedEntry: SplitMachineEntry?
    @State private var showAddExercise = false

    private var sortedEntries: [SplitMachineEntry] {
        split.entries.sorted { $0.order < $1.order }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(split.name)
                        .font(.largeTitle)
                        .fontWeight(.light)
                        .foregroundStyle(.white)

                    Spacer()

                    let isActive = split.status == "Active"
                    Text(split.status)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(isActive ? .green : .gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isActive ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                        .clipShape(Capsule())
                }

                Text("\(sortedEntries.count) exercises")
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundStyle(Color.gray)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)

            if sortedEntries.isEmpty {
                // Empty state
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "dumbbell")
                        .font(.system(size: 48))
                        .fontWeight(.ultraLight)
                        .foregroundStyle(Color.gray.opacity(0.4))

                    Text("Routine in Development")
                        .font(.title3)
                        .fontWeight(.light)
                        .foregroundStyle(.white)

                    Text("Tap to Add Exercises")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)

                    Button {
                        showAddExercise = true
                    } label: {
                        Text("Add Exercise")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.68, green: 0.78, blue: 0.90))
                            .clipShape(Capsule())
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)

                Spacer()
            } else {
                // Exercise list
                List {
                    ForEach(sortedEntries) { entry in
                        Button {
                            selectedEntry = entry
                        } label: {
                            HStack {
                                Text(entry.machine?.name ?? "Unknown")
                                    .font(.body)
                                    .fontWeight(.regular)
                                    .foregroundStyle(.white)

                                Spacer()

                                HStack(spacing: 12) {
                                    if entry.defaultWeight > 0 {
                                        Text("\(formatWeight(entry.defaultWeight)) kg")
                                            .font(.body)
                                            .fontWeight(.light)
                                            .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                                    }
                                    Text("\(entry.defaultSets) × \(entry.defaultReps)")
                                        .font(.body)
                                        .fontWeight(.light)
                                        .foregroundStyle(Color.gray)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparatorTint(Color.gray.opacity(0.25))
                    }
                    .onDelete(perform: deleteEntries)
                    .onMove(perform: moveEntries)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

                // Add exercise button
                Button {
                    showAddExercise = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 18))
                        Text("Add Exercise")
                            .font(.body)
                            .fontWeight(.regular)
                    }
                    .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !sortedEntries.isEmpty {
                EditButton()
                    .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
            }
        }
        .sheet(item: $selectedEntry) { entry in
            EditSetsRepsSheet(entry: entry)
        }
        .sheet(isPresented: $showAddExercise) {
            AddExerciseSheet(split: split)
        }
    }

    private func formatWeight(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    // MARK: - List Operations

    private func deleteEntries(at offsets: IndexSet) {
        let sorted = sortedEntries
        for index in offsets {
            modelContext.delete(sorted[index])
        }
        // Re-order remaining entries
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let remaining = split.entries.sorted { $0.order < $1.order }
            for (i, entry) in remaining.enumerated() {
                entry.order = i
            }
        }
    }

    private func moveEntries(from source: IndexSet, to destination: Int) {
        var entries = sortedEntries
        entries.move(fromOffsets: source, toOffset: destination)
        for (index, entry) in entries.enumerated() {
            entry.order = index
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SplitDetailView(split: WorkoutSplit(name: "Push Day", status: "Active"))
            .modelContainer(for: [WorkoutSplit.self, SplitMachineEntry.self, GymMachine.self], inMemory: true)
            .preferredColorScheme(.dark)
    }
}
