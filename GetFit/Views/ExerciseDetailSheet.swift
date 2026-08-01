import SwiftUI

struct ExerciseDetailSheet: View {
    let exercise: GymMachine
    @Environment(\.modelContext) private var modelContext
    @State private var isEditingVideo = false
    @State private var videoURLInput = ""
    @State private var isEditingImage = false
    @State private var imageURLInput = ""
    @State private var showInAppSafari = false
    
    let iceBlue = Color(red: 0.55, green: 0.88, blue: 1.00)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Section 1: Exercise name & category
                VStack(alignment: .leading, spacing: 10) {
                    Text(exercise.name)
                        .font(.title)
                        .fontWeight(.light)
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 8) {
                        Text(exercise.category.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.0)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(iceBlue)
                            .clipShape(Capsule())
                        
                        HStack(spacing: 6) {
                            Image(systemName: iconForEquipment(exercise.equipmentType))
                                .font(.system(size: 12))
                                .foregroundStyle(iceBlue)
                            Text(exercise.equipmentType)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.white.opacity(0.8))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())
                    }
                }
                
                // Section 2: Body Part Activation & Colorful Step-by-Step Form Guide
                BodyPartActivationCard(
                    machineName: exercise.name,
                    targetMuscles: exercise.targetMuscles,
                    instructions: exercise.instructions,
                    equipmentType: exercise.equipmentType
                )
                
                // Section 3: Target Muscles Badges
                VStack(alignment: .leading, spacing: 12) {
                    Text("Targeted Body Parts")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.gray)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(exercise.targetMuscles, id: \.self) { muscle in
                            MuscleGroupBadge(muscle: muscle)
                        }
                    }
                }
                
                // Section 4: Video / Shorts Demo Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Form Video & Demo")
                            .font(.subheadline)
                            .fontWeight(.medium)
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
                        .foregroundStyle(iceBlue)
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
                                        .fill(iceBlue.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(iceBlue)
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
                            .liquidGlass(cornerRadius: 14)
                        }
                    } else {
                        HStack {
                            Image(systemName: "play.rectangle")
                                .font(.system(size: 20))
                                .foregroundStyle(iceBlue.opacity(0.6))
                            Text("No video added yet. Tap '+ Add Video' to attach a YouTube Short or tutorial.")
                                .font(.caption)
                                .fontWeight(.light)
                                .foregroundStyle(Color.gray)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .liquidGlass(cornerRadius: 12)
                    }
                }
                
                // Section 5: Photo & Form Diagram Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Posture & Setup Photo")
                            .font(.subheadline)
                            .fontWeight(.medium)
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
                        .foregroundStyle(iceBlue)
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
                                    .liquidGlass(cornerRadius: 14)
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
                                .liquidGlass(cornerRadius: 12)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        HStack {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 20))
                                .foregroundStyle(iceBlue.opacity(0.6))
                            Text("No photo added yet. Tap '+ Add Photo' to attach a setup diagram.")
                                .font(.caption)
                                .fontWeight(.light)
                                .foregroundStyle(Color.gray)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .liquidGlass(cornerRadius: 12)
                    }
                }
                
                // Section 6: View Progress Chart
                NavigationLink {
                    ProgressionChartView(exercise: exercise)
                } label: {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 16))
                        Text("View Progress Chart")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(iceBlue)
                    .clipShape(Capsule())
                    .shadow(color: iceBlue.opacity(0.3), radius: 8, x: 0, y: 4)
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
