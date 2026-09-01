import SwiftUI
import SwiftData

struct EditSetsRepsSheet: View {
    let entry: SplitMachineEntry
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var weightUnit = WeightUnitManager.shared
    @State private var sets: Int
    @State private var reps: Int
    @State private var weight: Double
    @State private var weightString: String

    init(entry: SplitMachineEntry) {
        self.entry = entry
        _sets = State(initialValue: entry.defaultSets)
        _reps = State(initialValue: entry.defaultReps)
        
        let initialWeightDisplay = WeightUnitManager.shared.displayWeight(entry.defaultWeight)
        _weight = State(initialValue: initialWeightDisplay)
        _weightString = State(initialValue: WeightUnitManager.shared.formatNumber(initialWeightDisplay))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            // Header
            Text(entry.machine?.name ?? "Exercise")
                .font(.title2)
                .fontWeight(.light)
                .foregroundStyle(.white)

            // Sets row
            counterRow(label: "Sets", value: $sets, minimum: 1)

            Rectangle()
                .fill(Color.gray.opacity(0.25))
                .frame(height: 0.5)

            // Reps row
            counterRow(label: "Reps", value: $reps, minimum: 1)

            Rectangle()
                .fill(Color.gray.opacity(0.25))
                .frame(height: 0.5)

            // Weight row
            weightRow(label: "Target Weight (\(weightUnit.unitLabel))", value: $weight, textValue: $weightString, step: weightUnit.stepSize(for: entry.machine?.equipmentType ?? "Barbell"))

            Spacer()

            // Save button
            Button {
                entry.defaultSets = sets
                entry.defaultReps = reps
                entry.defaultWeight = weightUnit.toKg(weight)
                dismiss()
            } label: {
                Text("Save")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.68, green: 0.78, blue: 0.90))
                    .clipShape(Capsule())
            }

            // Remove button
            Button {
                modelContext.delete(entry)
                dismiss()
            } label: {
                Text("Remove from Split")
                    .font(.body)
                    .fontWeight(.regular)
                    .foregroundStyle(.red.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
        }
        .padding(24)
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Counter Row

    private func counterRow(label: String, value: Binding<Int>, minimum: Int) -> some View {
        HStack {
            Text(label)
                .font(.body)
                .fontWeight(.light)
                .foregroundStyle(Color.gray)

            Spacer()

            HStack(spacing: 16) {
                Button {
                    if value.wrappedValue > minimum { value.wrappedValue -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                        .frame(width: 36, height: 36)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .clipShape(Circle())
                }

                Text("\(value.wrappedValue)")
                    .font(.title3)
                    .fontWeight(.light)
                    .foregroundStyle(.white)
                    .frame(width: 36, alignment: .center)

                Button {
                    value.wrappedValue += 1
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                        .frame(width: 36, height: 36)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .clipShape(Circle())
                }
            }
        }
    }

    private func weightRow(label: String, value: Binding<Double>, textValue: Binding<String>, step: Double) -> some View {
        HStack {
            Text(label)
                .font(.body)
                .fontWeight(.light)
                .foregroundStyle(Color.gray)

            Spacer()

            HStack(spacing: 16) {
                Button {
                    if value.wrappedValue - step >= 0 {
                        value.wrappedValue -= step
                        textValue.wrappedValue = weightUnit.formatNumber(value.wrappedValue)
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                        .frame(width: 36, height: 36)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .clipShape(Circle())
                }

                TextField("0", text: textValue)
                    .keyboardType(.numbersAndPunctuation)
                    .submitLabel(.done)
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .fontWeight(.light)
                    .foregroundColor(.white)
                    .frame(width: 60)

                Button {
                    value.wrappedValue += step
                    textValue.wrappedValue = weightUnit.formatNumber(value.wrappedValue)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                        .frame(width: 36, height: 36)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .clipShape(Circle())
                }
            }
        }
    }

    private func formatWeight(_ value: Double) -> String {
        return weightUnit.formatNumber(value)
    }
}

// MARK: - Preview

#Preview {
    Text("Preview")
        .sheet(isPresented: .constant(true)) {
            EditSetsRepsSheet(entry: SplitMachineEntry(order: 0, defaultSets: 4, defaultReps: 10))
                .preferredColorScheme(.dark)
        }
}
