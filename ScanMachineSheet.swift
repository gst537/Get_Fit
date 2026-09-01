import SwiftUI
import SwiftData
import PhotosUI

struct ScanMachineSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Optional closure if this was invoked from a specific split to instantly add it
    var onAddMachineToSplit: ((GymMachine) -> Void)?
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var inputImage: UIImage? = nil
    
    @State private var isAnalyzing = false
    @State private var analysisResult: MachineAnalysisResult? = nil
    
    let slateBlue = MutedEarth.slateBlue
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Image Picker / Preview Area
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .frame(height: 250)
                            
                            if let img = inputImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 250)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.viewfinder")
                                        .font(.system(size: 40, weight: .ultraLight))
                                    Text("Take a photo of any gym machine")
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                }
                                .foregroundStyle(slateBlue)
                            }
                        }
                        .padding(.horizontal)
                        .overlay(
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Color.clear
                            }
                        )
                        .onChange(of: selectedPhotoItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    inputImage = uiImage
                                    analyzeImage(uiImage)
                                }
                            }
                        }
                        
                        // Analysis State
                        if isAnalyzing {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .tint(slateBlue)
                                Text("Identifying Machine...")
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.top, 40)
                        } else if let result = analysisResult {
                            if let error = result.errorMessage {
                                Text(error)
                                    .font(.callout)
                                    .foregroundStyle(MutedEarth.terracotta)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            } else if let machine = result.machine {
                                // Render the detected machine
                                machineResultCard(machine)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Identify Equipment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(slateBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let img = inputImage, !isAnalyzing {
                        Button("Re-Scan") {
                            analyzeImage(img)
                        }
                        .foregroundStyle(slateBlue)
                    }
                }
            }
        }
    }
    
    private func analyzeImage(_ image: UIImage) {
        isAnalyzing = true
        analysisResult = nil
        
        Task {
            let result = await AIMachineVisionService.shared.analyzeMachineImage(image)
            await MainActor.run {
                self.analysisResult = result
                self.isAnalyzing = false
            }
        }
    }
    
    @ViewBuilder
    private func machineResultCard(_ detected: DetectedMachine) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("MATCH FOUND")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(slateBlue)
            
            Text(detected.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            HStack(spacing: 12) {
                Label(detected.category, systemImage: "figure.strengthtraining.traditional")
                Label(detected.equipmentType, systemImage: "dumbbell")
            }
            .font(.caption)
            .foregroundStyle(.gray)
            
            Text("Target Muscles")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.top, 8)
            
            FlowLayout(spacing: 6) {
                ForEach(detected.targetMuscles, id: \.self) { muscle in
                    MuscleGroupBadge(muscle: muscle, color: MuscleGroupBadge.colorForMuscle(muscle))
                }
            }
            
            Text("How to Use")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.top, 8)
            
            Text(detected.instructions)
                .font(.caption)
                .foregroundStyle(.gray)
                .lineSpacing(4)
            
            Button {
                saveAndAddMachine(detected)
            } label: {
                Text(onAddMachineToSplit != nil ? "Add to Routine" : "Save to Database")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(slateBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 16)
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    private func saveAndAddMachine(_ detected: DetectedMachine) {
        // Fetch existing machine to avoid duplicates
        let name = detected.name
        let descriptor = FetchDescriptor<GymMachine>(predicate: #Predicate { $0.name == name })
        let existing = try? modelContext.fetch(descriptor).first
        
        let machineToUse: GymMachine
        if let existing = existing {
            machineToUse = existing
        } else {
            let newMachine = GymMachine(
                name: detected.name,
                category: detected.category,
                targetMuscles: detected.targetMuscles,
                instructions: detected.instructions,
                isCustom: true,
                equipmentType: detected.equipmentType
            )
            modelContext.insert(newMachine)
            machineToUse = newMachine
        }
        
        try? modelContext.save()
        
        if let addAction = onAddMachineToSplit {
            addAction(machineToUse)
        }
        
        dismiss()
    }
}
