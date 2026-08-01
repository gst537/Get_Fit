import SwiftUI
import SwiftData

struct CreateExerciseSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var category = "Push"
    @State private var equipmentType = "Barbell"
    @State private var selectedMuscles: Set<String> = []
    @State private var instructions = ""
    @State private var videoURL = ""
    @State private var imageURL = ""
    
    let categories = ["Push", "Pull", "Legs", "Core"]
    let equipmentTypes = ["Barbell", "Dumbbell", "Cable", "Machine", "Bodyweight"]
    let muscleGroups = ["Chest", "Upper Chest", "Front Delt", "Lateral Delt", "Rear Delt", "Triceps", "Biceps", "Forearms", "Lats", "Rhomboids", "Mid Back", "Lower Back", "Quads", "Hamstrings", "Glutes", "Calves", "Abs", "Obliques", "Core", "Hip Flexors", "Rotator Cuff"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // 1. Header
                HStack {
                    Text("New Exercise")
                        .font(.title2)
                        .fontWeight(.light)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.body)
                    .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                }
                
                // 2. Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Exercise Name")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    
                    TextField("e.g., Incline Smith Machine Press", text: $name)
                        .font(.body)
                        .fontWeight(.regular)
                        .padding(14)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // 3. Category Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { cat in
                                Text(cat)
                                    .font(.subheadline)
                                    .fontWeight(category == cat ? .medium : .regular)
                                    .foregroundStyle(category == cat ? .black : Color.gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(category == cat ? Color(red: 0.68, green: 0.78, blue: 0.90) : Color(UIColor.secondarySystemBackground))
                                    .clipShape(Capsule())
                                    .onTapGesture {
                                        category = cat
                                    }
                            }
                        }
                    }
                }
                
                // 4. Equipment Type Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Equipment")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(equipmentTypes, id: \.self) { equip in
                                Text(equip)
                                    .font(.subheadline)
                                    .fontWeight(equipmentType == equip ? .medium : .regular)
                                    .foregroundStyle(equipmentType == equip ? .black : Color.gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(equipmentType == equip ? Color(red: 0.68, green: 0.78, blue: 0.90) : Color(UIColor.secondarySystemBackground))
                                    .clipShape(Capsule())
                                    .onTapGesture {
                                        equipmentType = equip
                                    }
                            }
                        }
                    }
                }
                
                // 5. Target Muscles
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Muscles")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(muscleGroups, id: \.self) { muscle in
                            let isSelected = selectedMuscles.contains(muscle)
                            Text(muscle)
                                .font(.caption)
                                .fontWeight(.regular)
                                .foregroundStyle(isSelected ? .black : .white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(isSelected ? Color(red: 0.68, green: 0.78, blue: 0.90) : Color(UIColor.tertiarySystemBackground))
                                .clipShape(Capsule())
                                .onTapGesture {
                                    if isSelected {
                                        selectedMuscles.remove(muscle)
                                    } else {
                                        selectedMuscles.insert(muscle)
                                    }
                                }
                        }
                    }
                }
                
                // 6. Form Video URL Field (Optional)
                VStack(alignment: .leading, spacing: 8) {
                    Text("YouTube Video or Short URL (optional)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    
                    TextField("e.g., https://youtube.com/shorts/...", text: $videoURL)
                        .font(.body)
                        .fontWeight(.regular)
                        .padding(14)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                
                // 6b. Posture / Setup Photo URL Field (Optional)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Posture / Setup Photo URL (optional)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    
                    TextField("e.g., https://images.unsplash.com/...", text: $imageURL)
                        .font(.body)
                        .fontWeight(.regular)
                        .padding(14)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                
                // 7. Instructions Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Form Instructions (optional)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    
                    TextEditor(text: $instructions)
                        .font(.body)
                        .fontWeight(.light)
                        .padding(12)
                        .scrollContentBackground(.hidden)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(minHeight: 120)
                }
                
                // 8. Save Button
                Button {
                    let newMachine = GymMachine(
                        name: name,
                        category: category,
                        targetMuscles: Array(selectedMuscles),
                        instructions: instructions,
                        videoURL: videoURL.isEmpty ? nil : videoURL.trimmingCharacters(in: .whitespacesAndNewlines),
                        imageURL: imageURL.isEmpty ? nil : imageURL.trimmingCharacters(in: .whitespacesAndNewlines),
                        isCustom: true,
                        equipmentType: equipmentType
                    )
                    modelContext.insert(newMachine)
                    try? modelContext.save()
                    dismiss()
                } label: {
                    Text("Create Exercise")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.68, green: 0.78, blue: 0.90))
                        .clipShape(Capsule())
                        .opacity(name.isEmpty || selectedMuscles.isEmpty ? 0.5 : 1.0)
                }
                .disabled(name.isEmpty || selectedMuscles.isEmpty)
                .padding(.top, 16)
                
            }
            .padding(24)
        }
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(in: bounds.width, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    private func arrange(in maxWidth: CGFloat, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }
        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}

#Preview {
    Text("Preview")
        .sheet(isPresented: .constant(true)) {
            CreateExerciseSheet()
                .modelContainer(for: GymMachine.self, inMemory: true)
                .preferredColorScheme(.dark)
        }
}
