import SwiftUI

struct ExerciseDetailSheet: View {
    let exercise: GymMachine
    @Environment(\.modelContext) private var modelContext
    @State private var isEditingVideo = false
    @State private var videoURLInput = ""
    @State private var isEditingImage = false
    @State private var imageURLInput = ""
    @State private var showInAppSafari = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Section 1: Exercise name & category
                VStack(alignment: .leading, spacing: 8) {
                    Text(exercise.name)
                        .font(.title)
                        .fontWeight(.light)
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 8) {
                        Text(exercise.category)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Capsule())
                        
                        HStack(spacing: 6) {
                            Image(systemName: iconForEquipment(exercise.equipmentType))
                                .font(.system(size: 12))
                                .foregroundStyle(Color.gray)
                            Text(exercise.equipmentType)
                                .font(.caption)
                                .fontWeight(.regular)
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
                
                // Section 2: Video / Shorts Demo Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Form Video & Demo")
                            .font(.subheadline)
                            .foregroundStyle(Color.gray)
                        
                        Spacer()
                        
                        Button(isEditingVideo ? "Save" : (exercise.videoURL == nil || exercise.videoURL?.isEmpty == true) ? "+ Add Video" : "Edit Video") {
                            if isEditingVideo {
                                exercise.videoURL = videoURLInput.trimmingCharacters(in: .whitespacesAndNewlines)
                                try? modelContext.save()
                                isEditingVideo = false
                            } else {
                                videoURLInput = exercise.videoURL ?? ""
                                isEditingVideo = true
                            }
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                    }
                    
                    if isEditingVideo {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Paste YouTube or Shorts URL", text: $videoURLInput)
                                .font(.body)
                                .padding(12)
                                .background(Color(UIColor.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                            
                            Text("Supports links like: youtube.com/shorts/... or youtu.be/...")
                                .font(.caption2)
                                .foregroundStyle(Color.gray)
                        }
                    } else if let videoURL = exercise.videoURL, !videoURL.isEmpty, URL(string: videoURL) != nil {
                        Button {
                            showInAppSafari = true
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.68, green: 0.78, blue: 0.90).opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Watch Form Video")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.white)
                                    
                                    Text("Tap to play tutorial fullscreen in-app")
                                        .font(.caption)
                                        .fontWeight(.light)
                                        .foregroundStyle(Color.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.gray.opacity(0.5))
                            }
                            .padding(16)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    } else {
                        HStack {
                            Image(systemName: "play.rectangle")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.gray.opacity(0.6))
                            Text("No video added yet. Tap '+ Add Video' to attach a YouTube Short or tutorial.")
                                .font(.caption)
                                .fontWeight(.light)
                                .foregroundStyle(Color.gray)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                // Section 3: Photo & Form Diagram Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Posture & Setup Photo")
                            .font(.subheadline)
                            .foregroundStyle(Color.gray)
                        
                        Spacer()
                        
                        Button(isEditingImage ? "Save" : (exercise.imageURL == nil || exercise.imageURL?.isEmpty == true) ? "+ Add Photo" : "Edit Photo") {
                            if isEditingImage {
                                exercise.imageURL = imageURLInput.trimmingCharacters(in: .whitespacesAndNewlines)
                                try? modelContext.save()
                                isEditingImage = false
                            } else {
                                imageURLInput = exercise.imageURL ?? ""
                                isEditingImage = true
                            }
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                    }
                    
                    if isEditingImage {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Paste image URL (e.g. https://...)", text: $imageURLInput)
                                .font(.body)
                                .padding(12)
                                .background(Color(UIColor.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                            
                            Text("Enter web image link or machine setup diagram URL")
                                .font(.caption2)
                                .foregroundStyle(Color.gray)
                        }
                    } else if let imgStr = exercise.imageURL, !imgStr.isEmpty, let url = URL(string: imgStr) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 160)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity, maxHeight: 220)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            case .failure:
                                HStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color.gray.opacity(0.6))
                                    Text("Failed to load image. Tap 'Edit Photo' to update link.")
                                        .font(.caption)
                                        .foregroundStyle(Color.gray)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColor.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        HStack {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.gray.opacity(0.6))
                            Text("No photo added yet. Tap '+ Add Photo' to attach a setup diagram.")
                                .font(.caption)
                                .fontWeight(.light)
                                .foregroundStyle(Color.gray)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                // Section 4: Target Muscles
                VStack(alignment: .leading, spacing: 12) {
                    Text("Target Muscles")
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(exercise.targetMuscles, id: \.self) { muscle in
                            Text(muscle)
                                .font(.caption)
                                .fontWeight(.regular)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color(UIColor.tertiarySystemBackground))
                                .clipShape(Capsule())
                        }
                    }
                }
                
                // Section 5: Proper Form & Execution
                VStack(alignment: .leading, spacing: 12) {
                    Text("Proper Form & Execution")
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                    
                    Text(exercise.instructions)
                        .font(.body)
                        .fontWeight(.light)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineSpacing(6)
                }
                
                // Section 6: View Progress
                NavigationLink {
                    ProgressionChartView(exercise: exercise)
                } label: {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 16))
                        Text("View Progress")
                            .font(.body)
                            .fontWeight(.regular)
                    }
                    .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            videoURLInput = exercise.videoURL ?? ""
            imageURLInput = exercise.imageURL ?? ""
        }
        .sheet(isPresented: $showInAppSafari) {
            if let videoURL = exercise.videoURL, let url = URL(string: videoURL) {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
    
    private func iconForEquipment(_ type: String) -> String {
        switch type {
        case "Barbell": return "figure.strengthtraining.traditional"
        case "Dumbbell": return "dumbbell"
        case "Cable": return "cable.connector"
        case "Machine": return "gearshape"
        case "Bodyweight": return "figure.walk"
        default: return "dumbbell"
        }
    }
}

private struct FlowLayout: Layout {
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
    NavigationStack {
        ExerciseDetailSheet(exercise: GymMachine(
            name: "Flat Bench Press",
            category: "Push",
            targetMuscles: ["Chest", "Front Delt", "Triceps"],
            instructions: "1. Lie flat on the bench.\n2. Grip the bar wider than shoulder width.\n3. Lower to chest.\n4. Press up to lockout.",
            videoURL: "https://www.youtube.com/watch?v=rT7DgCr-3pg",
            equipmentType: "Barbell"
        ))
    }
    .preferredColorScheme(.dark)
}
