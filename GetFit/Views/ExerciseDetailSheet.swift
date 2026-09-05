import SwiftUI
import SwiftData
import PhotosUI

struct ExerciseDetailSheet: View {
    let exercise: GymMachine
    @Environment(\.modelContext) private var modelContext
    @State private var isEditingVideo = false
    @State private var videoURLInput = ""
    @State private var isEditingImage = false
    @State private var imageURLInput = ""
    @State private var showInAppSafari = false
    
    // Photo Library & Camera State
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var showCameraPicker = false
    @State private var loadedUIImage: UIImage? = nil
    
    @Query private var allSetLogs: [SetLog]
    @StateObject private var weightUnit = WeightUnitManager.shared
    
    let slateBlue = MutedEarth.slateBlue
    
    private var max1RM: Double {
        let historicalSets = allSetLogs.filter { $0.machineId == exercise.id }
        return historicalSets.map { $0.estimated1RM }.max() ?? 0.0
    }

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
                        Text(exercise.category.rawValue.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.0)
                            .foregroundStyle(slateBlue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(slateBlue.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(slateBlue.opacity(0.35), lineWidth: 0.8))
                        
                        HStack(spacing: 6) {
                            Image(systemName: iconForEquipment(exercise.equipmentType))
                                .font(.system(size: 12))
                                .foregroundStyle(slateBlue)
                            Text(exercise.equipmentType.rawValue)
                                .font(.caption)
                                .fontWeight(.regular)
                                .foregroundStyle(Color.gray)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                
                if max1RM > 0 {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ALL-TIME EST. 1RM")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1.0)
                                .foregroundStyle(Color.gray)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(weightUnit.formatNumber(weightUnit.displayWeight(max1RM)))")
                                    .font(.system(size: 28, weight: .light, design: .rounded))
                                    .foregroundStyle(.white)
                                Text(weightUnit.unitLabel)
                                    .font(.callout)
                                    .fontWeight(.medium)
                                    .foregroundStyle(slateBlue)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "trophy")
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(slateBlue.opacity(0.8))
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemBackground).opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [slateBlue.opacity(0.6), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                }
                
                // Section 2: Body Part Activation & Step-by-Step Form Guide
                BodyPartActivationCard(
                    machineName: exercise.name,
                    targetMuscles: exercise.targetMuscles,
                    instructions: exercise.instructions,
                    equipmentType: exercise.equipmentType.rawValue
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
                        .foregroundStyle(slateBlue)
                    }
                    
                    if isEditingVideo {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Paste YouTube or Shorts URL", text: $videoURLInput)
                                .font(.body)
                                .padding(12)
                                .background(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.3), lineWidth: 0.5))
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
                                        .fill(slateBlue.opacity(0.12))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(slateBlue)
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
                            .matteBlack(cornerRadius: 14, accentColor: slateBlue)
                        }
                    } else {
                        HStack {
                            Image(systemName: "play.rectangle")
                                .font(.system(size: 20))
                                .foregroundStyle(slateBlue.opacity(0.6))
                            Text("No video added yet. Tap '+ Add Video' to attach a YouTube Short or tutorial.")
                                .font(.caption)
                                .fontWeight(.light)
                                .foregroundStyle(Color.gray)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .matteBlack(cornerRadius: 12, accentColor: slateBlue)
                    }
                }
                
                // Section 5: Photo Library & Camera Setup Photo Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Posture & Setup Photo")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.gray)
                        
                        Spacer()
                        
                        if exercise.imageURL != nil && exercise.imageURL?.isEmpty == false {
                            Button("Remove Photo") {
                                exercise.imageURL = nil
                                loadedUIImage = nil
                                try? modelContext.save()
                            }
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.red.opacity(0.8))
                        }
                    }
                    
                    // Display Current Image (Local File or Web URL)
                    if let loadedUIImage {
                        Image(uiImage: loadedUIImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(slateBlue.opacity(0.3), lineWidth: 0.8)
                            )
                    } else if let imgStr = exercise.imageURL, !imgStr.isEmpty, imgStr.hasPrefix("http"), let url = URL(string: imgStr) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 160)
                                    .matteBlack(cornerRadius: 14, accentColor: slateBlue)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity, maxHeight: 220)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            case .failure:
                                Text("Failed to load web photo.")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        // Empty State Photo Picker Box
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 24))
                                    .foregroundStyle(slateBlue)
                                Text("Attach Exercise Photo or Form Diagram")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white)
                            }
                            
                            HStack(spacing: 12) {
                                // Photo Library Picker Button
                                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "photo.on.rectangle")
                                            .font(.caption)
                                        Text("Photo Library")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(slateBlue)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                                
                                // Camera Button
                                Button {
                                    showCameraPicker = true
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "camera")
                                            .font(.caption)
                                        Text("Take Photo")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundStyle(slateBlue)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(slateBlue.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(slateBlue.opacity(0.4), lineWidth: 0.8))
                                }
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .matteBlack(cornerRadius: 14, accentColor: slateBlue)
                    }
                    
                    // Replace/Change Photo Button when image exists
                    if loadedUIImage != nil || (exercise.imageURL != nil && exercise.imageURL?.isEmpty == false) {
                        HStack(spacing: 12) {
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                HStack(spacing: 6) {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.caption)
                                    Text("Change Photo")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(slateBlue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(slateBlue.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(slateBlue.opacity(0.35), lineWidth: 0.8))
                            }
                            
                            Button {
                                showCameraPicker = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "camera")
                                        .font(.caption)
                                    Text("Retake Photo")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(slateBlue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(slateBlue.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(slateBlue.opacity(0.35), lineWidth: 0.8))
                            }
                        }
                    }
                }
                
                // Section 6: View Progress Chart Button
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
                    .background(slateBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.black.ignoresSafeArea())
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            videoURLInput = exercise.videoURL ?? ""
            imageURLInput = exercise.imageURL ?? ""
            loadLocalImage()
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    saveAndApplyImage(image)
                }
            }
        }
        .sheet(isPresented: $showCameraPicker) {
            CameraPicker { capturedImage in
                saveAndApplyImage(capturedImage)
            }
        }
        .sheet(isPresented: $showInAppSafari) {
            if let videoURL = exercise.videoURL, let url = URL(string: videoURL) {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
    
    // MARK: - Image Saving & Loading Helpers
    
    private func saveAndApplyImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let filename = "exercise_\(exercise.id.uuidString).jpg"
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docs.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            exercise.imageURL = fileURL.path
            try? modelContext.save()
            loadedUIImage = image
        } catch {
            print("Failed to save exercise photo: \(error)")
        }
    }
    
    private func loadLocalImage() {
        guard let path = exercise.imageURL, !path.isEmpty else { return }
        if FileManager.default.fileExists(atPath: path), let img = UIImage(contentsOfFile: path) {
            loadedUIImage = img
        }
    }
    
    private func iconForEquipment(_ type: EquipmentType) -> String {
        switch type {
        case .barbell: return "figure.strengthtraining.traditional"
        case .dumbbell: return "dumbbell"
        case .cable: return "cable.connector"
        case .machine: return "gearshape"
        case .bodyweight: return "figure.walk"
        default: return "dumbbell"
        }
    }
}
