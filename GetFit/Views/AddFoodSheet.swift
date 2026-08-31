import SwiftUI
import SwiftData
import PhotosUI
import Vision
import CoreML

// MARK: - UIKit TextField Wrapper (guaranteed paste support on iPhone)
struct PasteFriendlyTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    
    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.spellCheckingType = .no
        tf.clearButtonMode = .whileEditing
        tf.textColor = .white
        tf.backgroundColor = UIColor.tertiarySystemBackground
        tf.layer.cornerRadius = 10
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        tf.rightViewMode = .always
        tf.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        tf.setContentHuggingPriority(.defaultLow, for: .horizontal)
        tf.clipsToBounds = true
        tf.delegate = context.coordinator
        tf.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        return tf
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: PasteFriendlyTextField
        init(_ parent: PasteFriendlyTextField) { self.parent = parent }
        
        @objc func textChanged(_ sender: UITextField) {
            let val = (sender.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            parent.text = val
            AIFoodVisionService.shared.savedAPIKey = val.isEmpty ? nil : val
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}

// MARK: - Camera Wrapper
struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var onImageCaptured: ((UIImage) -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        init(_ parent: CameraView) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.onImageCaptured?(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Add Food Sheet

struct AddFoodSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var initialMealType: String = "Breakfast"
    
    @State private var foodName = ""
    @State private var selectedMealType = "Breakfast"
    @State private var caloriesText = ""
    @State private var proteinText = ""
    @State private var carbsText = ""
    @State private var fatsText = ""
    
    // Detected items from AI or manual entry
    @State private var detectedItems: [DetectedFoodItem] = []
    @State private var itemToEdit: DetectedFoodItem? = nil
    @State private var showAddItemSheet = false
    
    // Photo & AI state
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedUIImage: UIImage? = nil
    @State private var showCameraPicker = false
    @State private var isScanningWithAI = false
    @State private var aiSuccessMessage: String? = nil
    @State private var aiErrorMessage: String? = nil
    

    
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    let paleBlue = MutedEarth.slateBlue

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Header
                HStack {
                    Text("Log Food & Calories")
                        .font(.title2)
                        .fontWeight(.light)
                        .foregroundStyle(.white)
                    Spacer()
                    Button("Cancel") { dismiss() }
                        .font(.body)
                        .foregroundStyle(paleBlue)
                }
                

                
                // Photo / Camera Section
                photoSection
                
                // Detected Items with +/- Quantity Steppers
                itemsBreakdownSection
                
                // Meal Type Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meal Category")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    HStack(spacing: 8) {
                        ForEach(mealTypes, id: \.self) { type in
                            Text(type)
                                .font(.subheadline)
                                .fontWeight(selectedMealType == type ? .medium : .regular)
                                .foregroundStyle(selectedMealType == type ? .black : Color.gray)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedMealType == type ? paleBlue : Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.3), lineWidth: 0.5))
                                .onTapGesture { selectedMealType = type }
                        }
                    }
                }
                
                // Food Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Food / Dish Name")
                        .font(.subheadline).fontWeight(.light).foregroundStyle(Color.gray)
                    TextField("e.g., Dosa & Coffee Breakfast", text: $foodName)
                        .font(.body)
                        .padding(14)
                        .monochromeCard(cornerRadius: 12)
                }
                
                // Calories
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Calories (kcal)")
                        .font(.subheadline).fontWeight(.light).foregroundStyle(Color.gray)
                    HStack {
                        TextField("0", text: $caloriesText)
                            .keyboardType(.numberPad)
                            .font(.title3).fontWeight(.medium).foregroundStyle(.white)
                        Text("kcal").font(.subheadline).foregroundStyle(Color.gray)
                    }
                    .padding(14)
                    .monochromeCard(cornerRadius: 12)
                }
                
                // Macros
                VStack(alignment: .leading, spacing: 12) {
                    Text("Macros (Optional)")
                        .font(.subheadline).fontWeight(.light).foregroundStyle(Color.gray)
                    HStack(spacing: 12) {
                        macroField(title: "Protein", color: paleBlue, text: $proteinText)
                        macroField(title: "Carbs", color: MutedEarth.terracotta, text: $carbsText)
                        macroField(title: "Fats", color: MutedEarth.softSage, text: $fatsText)
                    }
                }
                
                // Save Button
                Button {
                    Haptics.playSuccess()
                    saveMeal()
                } label: {
                    Text("Save Food Entry")
                        .font(.body).fontWeight(.medium).foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(paleBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .opacity(canSave ? 1.0 : 0.5)
                }
                .disabled(!canSave)
                .padding(.top, 8)
            }
            .padding(24)
        }
        .background(Color.black.ignoresSafeArea())
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear { selectedMealType = initialMealType }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedUIImage = image
                    scanWithAI(image)
                }
            }
        }
        .sheet(isPresented: $showCameraPicker) {
            CameraView(selectedImage: $selectedUIImage) { img in scanWithAI(img) }
        }
        .sheet(isPresented: $showAddItemSheet) {
            AddNewItemSheet { newItem in
                detectedItems.append(newItem)
                recalcTotals()
            }
        }
        .sheet(item: $itemToEdit) { item in
            EditDetectedItemSheet(item: item) { updated in
                if let idx = detectedItems.firstIndex(where: { $0.id == updated.id }) {
                    detectedItems[idx] = updated
                    recalcTotals()
                }
            }
        }
    }
    
    private var canSave: Bool {
        !foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (Int(caloriesText) ?? 0) > 0
    }
    

    
    // MARK: - Photo Section
    
    private var galleryPickerLabel: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle().fill(paleBlue.opacity(0.15)).frame(width: 36, height: 36)
                Image(systemName: "photo.on.rectangle").font(.system(size: 16)).foregroundStyle(paleBlue)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Gallery").font(.subheadline).fontWeight(.medium).foregroundStyle(.white)
                Text("Choose Photo").font(.caption2).foregroundStyle(Color.gray)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .monochromeCard(cornerRadius: 16)
    }

    private var photoSection: some View {
        VStack(spacing: 12) {
            if let image = selectedUIImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    Button {
                        selectedUIImage = nil
                        selectedItem = nil
                        aiSuccessMessage = nil
                        aiErrorMessage = nil
                        detectedItems = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white, Color.black.opacity(0.6))
                            .padding(8)
                    }
                }
            } else {
                HStack(spacing: 12) {
                    Button { showCameraPicker = true } label: {
                        HStack(spacing: 8) {
                            ZStack {
                                Circle().fill(paleBlue.opacity(0.15)).frame(width: 36, height: 36)
                                Image(systemName: "camera.fill").font(.system(size: 16)).foregroundStyle(paleBlue)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Take Photo").font(.subheadline).fontWeight(.medium).foregroundStyle(.white)
                                Text("Use Camera").font(.caption2).foregroundStyle(Color.gray)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .monochromeCard(cornerRadius: 16)
                    }
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        galleryPickerLabel
                    }
                }
            }
            
            // Status Messages
            if isScanningWithAI {
                HStack(spacing: 10) {
                    ProgressView().tint(paleBlue)
                    Text("Gemini AI scanning your plate...").font(.caption).foregroundStyle(paleBlue)
                }
                .padding(10).frame(maxWidth: .infinity)
                .background(paleBlue.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 10))
            } else if let msg = aiSuccessMessage {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.green)
                    Text(msg).font(.caption).fontWeight(.medium).foregroundStyle(.white)
                }
                .padding(10).frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 10))
            } else if let err = aiErrorMessage {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(Color.orange)
                        Text(err).font(.caption).fontWeight(.medium).foregroundStyle(.white)
                    }
                    if err.contains("Deep Scan") || err.contains("confident") {
                        Button {
                            if let img = selectedUIImage {
                                scanWithDeepAI(img)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Run Deep Scan (Cloud AI)")
                            }
                            .font(.caption2).fontWeight(.bold).foregroundStyle(paleBlue)
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(10).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    // MARK: - Items Breakdown with +/- Quantity Steppers
    
    private var itemsBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("🍽️ Plate Breakdown")
                    .font(.caption).fontWeight(.medium).foregroundStyle(paleBlue)
                Spacer()
                Button { showAddItemSheet = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus").font(.system(size: 10))
                        Text("Add Item").font(.caption2).fontWeight(.medium)
                    }
                    .foregroundStyle(paleBlue)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(paleBlue.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            
            if detectedItems.isEmpty {
                Text("Scan a photo or tap '+ Add Item' to add food items.")
                    .font(.caption2).foregroundStyle(Color.gray).padding(.vertical, 4)
            } else {
                // Total calculation banner
                let totalCals = detectedItems.reduce(0) { $0 + $1.calories }
                let equation = detectedItems.map { "\($0.calories)" }.joined(separator: " + ")
                
                HStack(spacing: 8) {
                    Image(systemName: "calculator").font(.caption).foregroundStyle(paleBlue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total:").font(.caption2).foregroundStyle(Color.gray)
                        Text("\(equation) = \(totalCals) kcal")
                            .font(.subheadline).fontWeight(.medium).foregroundStyle(.white)
                    }
                }
                .padding(10).frame(maxWidth: .infinity, alignment: .leading)
                .background(paleBlue.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 10))
                
                // Individual items with +/- quantity controls
                ForEach(detectedItems) { item in
                    itemRow(item)
                }
            }
        }
        .padding(14)
        .monochromeCard(cornerRadius: 16)
    }
    
    private func itemRow(_ item: DetectedFoodItem) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                Text(item.icon).font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.subheadline).foregroundStyle(.white)
                    HStack(spacing: 6) {
                        Text("P:\(item.protein)g").font(.caption2).foregroundStyle(paleBlue)
                        Text("C:\(item.carbs)g").font(.caption2).foregroundStyle(MutedEarth.terracotta)
                        Text("F:\(item.fats)g").font(.caption2).foregroundStyle(MutedEarth.softSage)
                    }
                }
                
                Spacer()
                
                Text("\(item.calories) kcal")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(paleBlue)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(paleBlue.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 6))
                
                // Edit button
                Button { itemToEdit = item } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 11)).foregroundStyle(paleBlue)
                        .padding(6).background(paleBlue.opacity(0.12)).clipShape(Circle())
                }
                
                // Delete button
                Button {
                    detectedItems.removeAll { $0.id == item.id }
                    recalcTotals()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 11)).foregroundStyle(Color.red.opacity(0.85))
                        .padding(6).background(Color.red.opacity(0.12)).clipShape(Circle())
                }
            }
            
            // +/- Quantity Stepper & Slider Row
            VStack(spacing: 12) {
                HStack {
                    Text("Qty:")
                        .font(.caption2).foregroundStyle(Color.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 10) {
                        // MINUS button
                        Button {
                            adjustQty(item, delta: -1)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(item.quantity <= 1 ? Color.gray.opacity(0.4) : paleBlue)
                        }
                        .disabled(item.quantity <= 1)
                        
                        // Current quantity display
                        Text(String(format: "%.1f", item.quantity))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 34)
                            .multilineTextAlignment(.center)
                        
                        // PLUS button
                        Button {
                            adjustQty(item, delta: 1)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(paleBlue)
                        }
                    }
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                // Slider
                let qtyBinding = Binding<Double>(
                    get: { item.quantity },
                    set: { newValue in
                        guard let idx = detectedItems.firstIndex(where: { $0.id == item.id }) else { return }
                        detectedItems[idx].quantity = newValue
                        detectedItems[idx].calories = Int(round(Double(detectedItems[idx].baseCalories) * newValue))
                        detectedItems[idx].protein = Int(round(Double(detectedItems[idx].baseProtein) * newValue))
                        detectedItems[idx].carbs = Int(round(Double(detectedItems[idx].baseCarbs) * newValue))
                        detectedItems[idx].fats = Int(round(Double(detectedItems[idx].baseFats) * newValue))
                        recalcTotals()
                    }
                )
                Slider(value: qtyBinding, in: 0.5...10.0, step: 0.5)
                    .tint(paleBlue)
            }
        }
        .padding(10)
        .background(Color(UIColor.tertiarySystemBackground).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Quantity Adjustment (Per-Item Independent)
    
    private func adjustQty(_ item: DetectedFoodItem, delta: Int) {
        guard let idx = detectedItems.firstIndex(where: { $0.id == item.id }) else { return }
        let newQty = max(1.0, detectedItems[idx].quantity + Double(delta))
        
        detectedItems[idx].quantity = newQty
        detectedItems[idx].calories = Int(round(Double(detectedItems[idx].baseCalories) * newQty))
        detectedItems[idx].protein = Int(round(Double(detectedItems[idx].baseProtein) * newQty))
        detectedItems[idx].carbs = Int(round(Double(detectedItems[idx].baseCarbs) * newQty))
        detectedItems[idx].fats = Int(round(Double(detectedItems[idx].baseFats) * newQty))
        
        recalcTotals()
        Haptics.playLightImpact()
    }
    
    private func recalcTotals() {
        let cals = detectedItems.reduce(0) { $0 + $1.calories }
        let p = detectedItems.reduce(0) { $0 + $1.protein }
        let c = detectedItems.reduce(0) { $0 + $1.carbs }
        let f = detectedItems.reduce(0) { $0 + $1.fats }
        
        caloriesText = "\(cals)"
        proteinText = "\(p)"
        carbsText = "\(c)"
        fatsText = "\(f)"
        
        if foodName.isEmpty && !detectedItems.isEmpty {
            foodName = detectedItems.map { $0.name }.joined(separator: ", ")
        }
        
        aiSuccessMessage = detectedItems.isEmpty ? nil : "Total: \(cals) kcal"
    }
    
    // MARK: - AI Scan
    
    private func scanWithDeepAI(_ image: UIImage) {
        guard let key = AIFoodVisionService.shared.savedAPIKey, !key.isEmpty else {
            aiErrorMessage = "Deep Scan requires Gemini API Key in Profile Settings."
            return
        }
        
        isScanningWithAI = true
        aiSuccessMessage = nil
        aiErrorMessage = nil
        detectedItems = []
        
        Task {
            let result = await AIFoodVisionService.shared.analyzeFoodImage(image)
            
            await MainActor.run {
                isScanningWithAI = false
                if let err = result.errorMessage {
                    aiErrorMessage = err
                } else {
                    foodName = result.plateTitle
                    caloriesText = "\(result.totalCalories)"
                    proteinText = "\(result.totalProtein)"
                    carbsText = "\(result.totalCarbs)"
                    fatsText = "\(result.totalFats)"
                    detectedItems = result.detectedItems
                    aiSuccessMessage = "Deep Scan Identified '\(result.plateTitle)'"
                }
            }
        }
    }
    
    private func scanWithAI(_ image: UIImage) {
        isScanningWithAI = true
        aiSuccessMessage = nil
        aiErrorMessage = nil
        detectedItems = []
        
        Task {
            let ciImage: CIImage?
            if let ci = CIImage(image: image) {
                ciImage = ci
            } else if let cg = image.cgImage {
                ciImage = CIImage(cgImage: cg)
            } else {
                ciImage = nil
            }
            
            guard let validCIImage = ciImage else {
                await MainActor.run {
                    isScanningWithAI = false
                    aiErrorMessage = "Could not process image."
                }
                return
            }
            
            do {
                let config = MLModelConfiguration()
                let model = try NutriLens_v2(configuration: config)
                let visionModel = try VNCoreMLModel(for: model.model)
                
                let request = VNCoreMLRequest(model: visionModel) { request, error in
                    Task {
                        await MainActor.run {
                            self.handleCoreMLResults(request: request, error: error)
                        }
                    }
                }
                
                let handler = VNImageRequestHandler(ciImage: validCIImage, options: [:])
                try handler.perform([request])
            } catch {
                await MainActor.run {
                    isScanningWithAI = false
                    aiErrorMessage = "Failed to load NutriLens model: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func handleCoreMLResults(request: VNRequest, error: Error?) {
        isScanningWithAI = false
        if let error = error {
            aiErrorMessage = "Scan failed: \(error.localizedDescription)"
            return
        }
        
        guard let results = request.results as? [VNClassificationObservation],
              let topResult = results.first else {
            aiErrorMessage = "Could not identify any food."
            return
        }
        
        // Ensure standard formatting from the label
        let label = topResult.identifier.replacingOccurrences(of: "_", with: " ").capitalized
        let confidence = Int(topResult.confidence * 100)
        
        if confidence < 75 {
            aiErrorMessage = "Local AI is only \(confidence)% confident it's \(label). Please use Deep Scan."
            return
        }
        
        let matchedItem = getMacrosFor(label: label)
        detectedItems = [matchedItem]
        
        foodName = matchedItem.name
        caloriesText = "\(matchedItem.calories)"
        proteinText = "\(matchedItem.protein)"
        carbsText = "\(matchedItem.carbs)"
        fatsText = "\(matchedItem.fats)"
        
        aiSuccessMessage = "CoreML Identified '\(label)' (\(confidence)%)"
    }
    
    private func getMacrosFor(label: String) -> DetectedFoodItem {
        let l = label.lowercased()
        if l.contains("biryani") { return DetectedFoodItem(name: "Chicken Biryani", calories: 450, protein: 30, carbs: 45, fats: 15, icon: "🍗") }
        if l.contains("chapati") || l.contains("roti") { return DetectedFoodItem(name: "Chapati", calories: 100, protein: 3, carbs: 18, fats: 2, icon: "🫓") }
        if l.contains("dosa") { return DetectedFoodItem(name: "Dosa", calories: 150, protein: 4, carbs: 30, fats: 3, icon: "🫓") }
        if l.contains("idli") { return DetectedFoodItem(name: "Idli", calories: 60, protein: 2, carbs: 12, fats: 0, icon: "⚪") }
        if l.contains("samosa") { return DetectedFoodItem(name: "Samosa", calories: 250, protein: 3, carbs: 24, fats: 15, icon: "🥟") }
        if l.contains("paneer") { return DetectedFoodItem(name: "Paneer Dish", calories: 350, protein: 14, carbs: 12, fats: 25, icon: "🥘") }
        if l.contains("chicken") { return DetectedFoodItem(name: "Chicken Curry", calories: 300, protein: 25, carbs: 10, fats: 15, icon: "🍗") }
        if l.contains("dal") { return DetectedFoodItem(name: "Dal", calories: 200, protein: 10, carbs: 30, fats: 5, icon: "🍲") }
        if l.contains("chole") || l.contains("channa") { return DetectedFoodItem(name: "Chole", calories: 250, protein: 12, carbs: 35, fats: 8, icon: "🥘") }
        
        return DetectedFoodItem(name: label.capitalized, calories: 200, protein: 5, carbs: 25, fats: 10, icon: "🍽️")
    }
    
    // MARK: - Helpers
    
    private func macroField(title: String, color: Color, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).fontWeight(.medium).foregroundStyle(color)
            HStack(spacing: 2) {
                TextField("0", text: text)
                    .keyboardType(.numberPad).font(.body).fontWeight(.medium).foregroundStyle(.white)
                Text("g").font(.caption2).foregroundStyle(Color.gray)
            }
            .padding(10)
            .monochromeCard(cornerRadius: 12)
        }
    }
    
    private func saveMeal() {
        let name = foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        let calories = Int(caloriesText) ?? 0
        let protein = Int(proteinText) ?? 0
        let carbs = Int(carbsText) ?? 0
        let fats = Int(fatsText) ?? 0
        
        guard !name.isEmpty, calories > 0 else { return }
        
        var imagePath: String? = nil
        if let image = selectedUIImage {
            imagePath = AIFoodVisionService.shared.saveMealImageLocally(image)
        }
        
        if !detectedItems.isEmpty {
            for item in detectedItems {
                let entry = MealLog(
                    name: item.name,
                    mealType: selectedMealType,
                    calories: item.calories,
                    proteinGrams: item.protein,
                    carbsGrams: item.carbs,
                    fatsGrams: item.fats,
                    imagePath: imagePath
                )
                modelContext.insert(entry)
            }
        } else {
            let entry = MealLog(
                name: name,
                mealType: selectedMealType,
                calories: calories,
                proteinGrams: protein,
                carbsGrams: carbs,
                fatsGrams: fats,
                imagePath: imagePath
            )
            modelContext.insert(entry)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Add New Item Sheet

struct AddNewItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onAdd: (DetectedFoodItem) -> Void
    
    @State private var nameInput = ""
    @State private var caloriesInput = "150"
    @State private var proteinInput = "5"
    @State private var carbsInput = "20"
    @State private var fatsInput = "3"
    @State private var iconInput = "🍲"
    
    let paleBlue = MutedEarth.slateBlue
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Name & Emoji") {
                    HStack {
                        TextField("🍲", text: $iconInput).frame(width: 44)
                        TextField("e.g. Crispy Dosa", text: $nameInput)
                    }
                }
                Section("Calories & Macros") {
                    HStack { Text("Calories"); Spacer(); TextField("150", text: $caloriesInput).keyboardType(.numberPad).multilineTextAlignment(.trailing) }
                    HStack { Text("Protein (g)"); Spacer(); TextField("5", text: $proteinInput).keyboardType(.numberPad).multilineTextAlignment(.trailing) }
                    HStack { Text("Carbs (g)"); Spacer(); TextField("20", text: $carbsInput).keyboardType(.numberPad).multilineTextAlignment(.trailing) }
                    HStack { Text("Fats (g)"); Spacer(); TextField("3", text: $fatsInput).keyboardType(.numberPad).multilineTextAlignment(.trailing) }
                }
            }
            .navigationTitle("Add Plate Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let name = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !name.isEmpty else { return }
                        onAdd(DetectedFoodItem(
                            name: name,
                            calories: Int(caloriesInput) ?? 150,
                            protein: Int(proteinInput) ?? 5,
                            carbs: Int(carbsInput) ?? 20,
                            fats: Int(fatsInput) ?? 3,
                            icon: iconInput.isEmpty ? "🍲" : iconInput
                        ))
                        dismiss()
                    }
                    .fontWeight(.bold).foregroundStyle(paleBlue)
                }
            }
        }
        .presentationDetents([.height(340)])
    }
}

// MARK: - Edit Item Sheet

struct EditDetectedItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    var item: DetectedFoodItem
    var onSave: (DetectedFoodItem) -> Void
    
    @State private var nameInput = ""
    @State private var caloriesInput = ""
    @State private var proteinInput = ""
    @State private var carbsInput = ""
    @State private var fatsInput = ""
    
    let paleBlue = MutedEarth.slateBlue
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Name") {
                    TextField("e.g. 1 Dosa", text: $nameInput)
                }
                Section("Calories & Macros") {
                    HStack { Text("Calories"); Spacer(); TextField("0", text: $caloriesInput).keyboardType(.numberPad).multilineTextAlignment(.trailing) }
                    HStack { Text("Protein (g)"); Spacer(); TextField("0", text: $proteinInput).keyboardType(.numberPad).multilineTextAlignment(.trailing) }
                    HStack { Text("Carbs (g)"); Spacer(); TextField("0", text: $carbsInput).keyboardType(.numberPad).multilineTextAlignment(.trailing) }
                    HStack { Text("Fats (g)"); Spacer(); TextField("0", text: $fatsInput).keyboardType(.numberPad).multilineTextAlignment(.trailing) }
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = item
                        updated.name = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                        updated.calories = Int(caloriesInput) ?? item.calories
                        updated.protein = Int(proteinInput) ?? item.protein
                        updated.carbs = Int(carbsInput) ?? item.carbs
                        updated.fats = Int(fatsInput) ?? item.fats
                        onSave(updated)
                        dismiss()
                    }
                    .fontWeight(.bold).foregroundStyle(paleBlue)
                }
            }
            .onAppear {
                nameInput = item.name
                caloriesInput = "\(item.calories)"
                proteinInput = "\(item.protein)"
                carbsInput = "\(item.carbs)"
                fatsInput = "\(item.fats)"
            }
        }
        .presentationDetents([.height(340)])
    }
}
