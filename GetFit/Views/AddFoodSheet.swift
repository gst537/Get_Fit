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
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.spellCheckingType = .no
        tf.clearButtonMode = .whileEditing
        tf.textColor = .white
        tf.backgroundColor = UIColor(white: 0.15, alpha: 1)
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(white: 0.3, alpha: 1).cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
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
    
    var initialMealType: MealType = .breakfast
    
    @State private var foodName = ""
    @State private var selectedMealType: MealType = .breakfast
    @State private var caloriesText = ""
    @State private var proteinText = ""
    @State private var carbsText = ""
    @State private var fatsText = ""
    
    // Detected items from AI or manual entry
    @State private var detectedItems: [DetectedFoodItem] = []
    @State private var itemToEdit: DetectedFoodItem? = nil
    @State private var showAddItemSheet = false
    
    enum InputMode: String, CaseIterable {
        case photo = "Smart Photo"
        case text = "Text Log"
        case quick = "Quick Est"
    }
    
    @State private var inputMode: InputMode = .photo
    @State private var textLogInput = ""
    
    // Photo & AI state
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedUIImage: UIImage? = nil
    @State private var showCameraPicker = false
    @State private var isScanningWithAI = false
    @State private var aiSuccessMessage: String? = nil
    @State private var aiErrorMessage: String? = nil
    
    let mealTypes = MealType.allCases
    let tCyan = PremiumColors.neonCyan
    let tWhite = PremiumColors.starkWhite
    let tGray = PremiumColors.midGray

    var body: some View {
        ZStack {
            PremiumColors.deepBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Log Food")
                        .font(PremiumFonts.title)
                        .foregroundStyle(tCyan)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(tGray)
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Input Mode Picker
                        Picker("Input Mode", selection: $inputMode) {
                            ForEach(InputMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom, 8)
                        
                        // Dynamic Input Section
                        if inputMode == .photo {
                            photoSection
                        } else if inputMode == .text {
                            textLogSection
                        } else {
                            quickEstimateSection
                        }
                        
                        // Detected Items with +/- Quantity Steppers
                        itemsBreakdownSection
                        
                        // Meal Type Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Meal Category")
                                .font(PremiumFonts.caption)
                                .foregroundStyle(tGray)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(mealTypes, id: \.self) { type in
                                        Text(type.rawValue.capitalized)
                                            .font(PremiumFonts.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(selectedMealType == type ? PremiumColors.deepBlack : tWhite)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(selectedMealType == type ? tCyan : PremiumColors.glassBackground)
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(selectedMealType == type ? tCyan : PremiumColors.glassBorder, lineWidth: 1))
                                            .onTapGesture { selectedMealType = type }
                                    }
                                }
                            }
                        }
                        
                        // Food Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Food Name")
                                .font(PremiumFonts.caption).foregroundStyle(tGray)
                            TextField("e.g. Crispy Dosa", text: $foodName)
                                .font(PremiumFonts.headline)
                                .padding(14)
                                .background(PremiumColors.glassBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(tWhite)
                        }
                        
                        // Calories
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Calories (kcal)")
                                .font(PremiumFonts.caption).foregroundStyle(tGray)
                            HStack {
                                TextField("0", text: $caloriesText)
                                    .keyboardType(.numbersAndPunctuation)
                                    .submitLabel(.done)
                                    .font(PremiumFonts.headline).foregroundStyle(tWhite)
                                Text("kcal").font(PremiumFonts.caption).foregroundStyle(tGray)
                            }
                            .padding(14)
                            .background(PremiumColors.glassBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Macros
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Macronutrients (Optional)")
                                .font(PremiumFonts.caption).foregroundStyle(tGray)
                            HStack(spacing: 12) {
                                macroField(title: "Pro", color: tCyan, text: $proteinText)
                                macroField(title: "Carbs", color: tWhite, text: $carbsText)
                                macroField(title: "Fat", color: tGray, text: $fatsText)
                            }
                        }
                        
                        // Save Button
                        Button {
                            Haptics.playSuccess()
                            saveMeal()
                        } label: {
                            Text("Save Food Log")
                                .font(PremiumFonts.headline).fontWeight(.bold).foregroundStyle(PremiumColors.deepBlack)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(tCyan)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .opacity(canSave ? 1.0 : 0.5)
                        }
                        .disabled(!canSave)
                        .padding(.top, 8)
                    }
                    .padding(20)
                }
            }
        }
        .onAppear { selectedMealType = initialMealType }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedUIImage = image
                    scanWithDeepAI(image)
                }
            }
        }
        .sheet(isPresented: $showCameraPicker) {
            CameraView(selectedImage: $selectedUIImage) { img in scanWithDeepAI(img) }
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
    
    // MARK: - Text Log Section
    
    private var textLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Describe Meal")
                .font(PremiumFonts.caption)
                .foregroundStyle(tGray)
            
            TextField("e.g. 2 rotis and dal...", text: $textLogInput, axis: .vertical)
                .lineLimit(2...4)
                .font(PremiumFonts.body)
                .padding(14)
                .background(PremiumColors.glassBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(tWhite)
            
            Button {
                Haptics.playLightImpact()
                scanWithTextAI(textLogInput)
            } label: {
                Text(isScanningWithAI ? "Analyzing..." : "Run AI Analysis")
                    .font(PremiumFonts.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(PremiumColors.deepBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(tCyan)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .opacity(textLogInput.isEmpty || isScanningWithAI ? 0.5 : 1.0)
            }
            .disabled(textLogInput.isEmpty || isScanningWithAI)
            
            // Status Messages
            if isScanningWithAI {
                HStack(spacing: 10) {
                    ProgressView().tint(tCyan)
                    Text("AI Processing...").font(PremiumFonts.caption).foregroundStyle(tCyan)
                }
                .padding(12).frame(maxWidth: .infinity)
                .background(tCyan.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if let err = aiErrorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(Color.red)
                    Text(err).font(PremiumFonts.caption).foregroundStyle(Color.red)
                }
                .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Quick Estimate Section
    
    private var quickEstimateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Add")
                .font(PremiumFonts.caption)
                .foregroundStyle(tGray)
            
            VStack(spacing: 12) {
                quickEstimateRow(sizeTitle: "Small Portion (~300 kcal)", cals: 300)
                quickEstimateRow(sizeTitle: "Medium Portion (~600 kcal)", cals: 600)
                quickEstimateRow(sizeTitle: "Large Portion (~900 kcal)", cals: 900)
            }
        }
    }
    
    private func quickEstimateRow(sizeTitle: String, cals: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(sizeTitle).font(PremiumFonts.caption).foregroundStyle(tWhite)
            HStack(spacing: 8) {
                quickButton(title: "Balanced", cals: cals, p: 0.25, c: 0.50, f: 0.25)
                quickButton(title: "High Carb", cals: cals, p: 0.15, c: 0.65, f: 0.20)
                quickButton(title: "High Pro", cals: cals, p: 0.40, c: 0.35, f: 0.25)
            }
        }
    }
    
    private func quickButton(title: String, cals: Int, p: Double, c: Double, f: Double) -> some View {
        Button {
            Haptics.playSuccess()
            let pGrams = Int(Double(cals) * p / 4.0)
            let cGrams = Int(Double(cals) * c / 4.0)
            let fGrams = Int(Double(cals) * f / 9.0)
            
            foodName = "Quick Add \(title)"
            caloriesText = "\(cals)"
            proteinText = "\(pGrams)"
            carbsText = "\(cGrams)"
            fatsText = "\(fGrams)"
            
            detectedItems = []
        } label: {
            Text(title)
                .font(PremiumFonts.caption)
                .fontWeight(.bold)
                .foregroundStyle(tCyan)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(PremiumColors.glassBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(tCyan, lineWidth: 1))
        }
    }

    private var canSave: Bool {
        !foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (Int(caloriesText) ?? 0) > 0
    }
    
    // MARK: - Photo Section
    
    private var galleryPickerLabel: some View {
        HStack(spacing: 8) {
            Image(systemName: "photo.fill")
            Text("Gallery")
        }
        .font(PremiumFonts.headline)
        .fontWeight(.bold)
        .foregroundStyle(tWhite)
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(PremiumColors.glassBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var photoSection: some View {
        VStack(spacing: 16) {
            if let image = selectedUIImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.3), radius: 8)
                    Button {
                        selectedUIImage = nil
                        selectedItem = nil
                        aiSuccessMessage = nil
                        aiErrorMessage = nil
                        detectedItems = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(tWhite)
                            .padding(8)
                            .shadow(radius: 4)
                    }
                }
            } else {
                HStack(spacing: 12) {
                    Button { showCameraPicker = true } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                            Text("Camera")
                        }
                        .font(PremiumFonts.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(tWhite)
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(PremiumColors.glassBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        galleryPickerLabel
                    }
                }
            }
            
            // Status Messages
            if isScanningWithAI {
                HStack(spacing: 10) {
                    ProgressView().tint(tCyan)
                    Text("AI Vision Scanning...").font(PremiumFonts.caption).foregroundStyle(tCyan)
                }
                .padding(12).frame(maxWidth: .infinity)
                .background(tCyan.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if let msg = aiSuccessMessage {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(tCyan)
                    Text(msg).font(PremiumFonts.caption).foregroundStyle(tCyan)
                }
                .padding(12).frame(maxWidth: .infinity)
                .background(tCyan.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if let err = aiErrorMessage {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(Color.red)
                        Text(err).font(PremiumFonts.caption).foregroundStyle(Color.red)
                    }
                }
                .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Items Breakdown with +/- Quantity Steppers
    
    private var itemsBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Food Items")
                    .font(PremiumFonts.headline).foregroundStyle(tWhite)
                Spacer()
                Button { showAddItemSheet = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(tCyan)
                }
            }
            
            if detectedItems.isEmpty {
                Text("No items logged yet.")
                    .font(PremiumFonts.caption).foregroundStyle(tGray).padding(.vertical, 8)
            } else {
                // Total calculation banner
                let totalCals = detectedItems.reduce(0) { $0 + $1.calories }
                let equation = detectedItems.map { "\($0.calories)" }.joined(separator: " + ")
                
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Calories:")
                            .font(PremiumFonts.caption).foregroundStyle(tGray)
                        Text("\(equation) = \(totalCals) kcal")
                            .font(PremiumFonts.body).fontWeight(.bold).foregroundStyle(tCyan)
                    }
                }
                .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                .background(PremiumColors.glassBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Individual items with +/- quantity controls
                ForEach(detectedItems) { item in
                    itemRow(item)
                }
            }
        }
        .padding(20)
        .glassmorphic(cornerRadius: 16)
    }
    
    private func itemRow(_ item: DetectedFoodItem) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Text(item.icon).font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(PremiumFonts.body).fontWeight(.bold).foregroundStyle(tWhite)
                    HStack(spacing: 8) {
                        Text("P:\(item.protein)g").font(.system(size: 11, weight: .bold, design: .rounded)).foregroundStyle(tCyan)
                        Text("C:\(item.carbs)g").font(.system(size: 11, weight: .bold, design: .rounded)).foregroundStyle(tWhite)
                        Text("F:\(item.fats)g").font(.system(size: 11, weight: .bold, design: .rounded)).foregroundStyle(tGray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(item.calories) kcal")
                        .font(PremiumFonts.body).fontWeight(.bold)
                        .foregroundStyle(tWhite)
                    
                    HStack(spacing: 8) {
                        Button { itemToEdit = item } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(tGray)
                        }
                        
                        Button {
                            detectedItems.removeAll { $0.id == item.id }
                            recalcTotals()
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.red)
                        }
                    }
                }
            }
            
            // +/- Quantity Stepper & Slider Row
            VStack(spacing: 12) {
                HStack {
                    Text("Quantity:")
                        .font(PremiumFonts.caption).foregroundStyle(tGray)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button { adjustQty(item, delta: -1) } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(item.quantity <= 1 ? PremiumColors.glassBorder : tWhite)
                        }.disabled(item.quantity <= 1)
                        
                        Text(String(format: "%.1f", item.quantity))
                            .font(.system(size: 16, weight: .bold, design: .rounded)).foregroundStyle(tWhite)
                            .frame(width: 40).multilineTextAlignment(.center)
                        
                        Button { adjustQty(item, delta: 1) } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(tCyan)
                        }
                    }
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
                    .tint(tCyan)
            }
        }
        .padding(14)
        .background(PremiumColors.glassBackground)
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
        
        aiSuccessMessage = detectedItems.isEmpty ? nil : "Calculated: \(cals) kcal"
    }
    
    // MARK: - AI Scan
    
    private func scanWithDeepAI(_ image: UIImage) {
        guard let key = AIFoodVisionService.shared.savedAPIKey, !key.isEmpty else {
            aiErrorMessage = "API Key Required in Settings"
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
                    aiSuccessMessage = "Identified: \(result.plateTitle)"
                }
            }
        }
    }
    
    private func scanWithTextAI(_ text: String) {
        guard let key = AIFoodVisionService.shared.savedAPIKey, !key.isEmpty else {
            aiErrorMessage = "API Key Required in Settings"
            return
        }
        
        isScanningWithAI = true
        aiSuccessMessage = nil
        aiErrorMessage = nil
        detectedItems = []
        
        Task {
            let result = await AIFoodVisionService.shared.analyzeFoodText(text)
            
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
                    aiSuccessMessage = "Identified: \(result.plateTitle)"
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func macroField(title: String, color: Color, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(PremiumFonts.caption).fontWeight(.bold).foregroundStyle(color)
            HStack(spacing: 4) {
                TextField("0", text: text)
                    .keyboardType(.numbersAndPunctuation)
                    .submitLabel(.done).font(PremiumFonts.headline).foregroundStyle(tWhite)
                Text("g").font(PremiumFonts.caption).foregroundStyle(tGray)
            }
            .padding(12)
            .background(PremiumColors.glassBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(color == tGray ? PremiumColors.glassBorder : color.opacity(0.3), lineWidth: 1))
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
    
    var body: some View {
        ZStack {
            PremiumColors.deepBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Add New Item")
                        .font(PremiumFonts.title)
                        .foregroundStyle(PremiumColors.neonCyan)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(PremiumColors.starkWhite)
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 24) {
                        HStack(spacing: 12) {
                            TextField("🍲", text: $iconInput)
                                .font(.system(size: 32))
                                .multilineTextAlignment(.center)
                                .frame(width: 60, height: 60)
                                .background(PremiumColors.glassBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            TextField("e.g. Crispy Dosa", text: $nameInput)
                                .font(PremiumFonts.headline)
                                .padding(14)
                                .frame(height: 60)
                                .background(PremiumColors.glassBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(PremiumColors.starkWhite)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Calories")
                                .font(PremiumFonts.caption)
                                .foregroundStyle(PremiumColors.midGray)
                            TextField("150", text: $caloriesInput)
                                .keyboardType(.numbersAndPunctuation)
                                .font(PremiumFonts.headline)
                                .padding(14)
                                .background(PremiumColors.glassBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(PremiumColors.starkWhite)
                        }
                        
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Protein")
                                    .font(PremiumFonts.caption)
                                    .foregroundStyle(PremiumColors.neonCyan)
                                TextField("5", text: $proteinInput)
                                    .keyboardType(.numbersAndPunctuation)
                                    .font(PremiumFonts.headline)
                                    .padding(14)
                                    .background(PremiumColors.glassBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(PremiumColors.starkWhite)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Carbs")
                                    .font(PremiumFonts.caption)
                                    .foregroundStyle(PremiumColors.starkWhite)
                                TextField("20", text: $carbsInput)
                                    .keyboardType(.numbersAndPunctuation)
                                    .font(PremiumFonts.headline)
                                    .padding(14)
                                    .background(PremiumColors.glassBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(PremiumColors.starkWhite)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Fats")
                                    .font(PremiumFonts.caption)
                                    .foregroundStyle(PremiumColors.midGray)
                                TextField("3", text: $fatsInput)
                                    .keyboardType(.numbersAndPunctuation)
                                    .font(PremiumFonts.headline)
                                    .padding(14)
                                    .background(PremiumColors.glassBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(PremiumColors.starkWhite)
                            }
                        }
                        
                        Button {
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
                        } label: {
                            Text("Add Item")
                                .font(PremiumFonts.headline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(PremiumColors.neonCyan)
                                .foregroundStyle(PremiumColors.deepBlack)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top, 12)
                    }
                    .padding(20)
                }
            }
        }
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
    
    var body: some View {
        ZStack {
            PremiumColors.deepBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Edit Item")
                        .font(PremiumFonts.title)
                        .foregroundStyle(PremiumColors.neonCyan)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(PremiumColors.starkWhite)
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Item Name")
                                .font(PremiumFonts.caption)
                                .foregroundStyle(PremiumColors.midGray)
                            TextField("Name", text: $nameInput)
                                .font(PremiumFonts.headline)
                                .padding(14)
                                .background(PremiumColors.glassBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(PremiumColors.starkWhite)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Calories")
                                .font(PremiumFonts.caption)
                                .foregroundStyle(PremiumColors.midGray)
                            TextField("0", text: $caloriesInput)
                                .keyboardType(.numbersAndPunctuation)
                                .font(PremiumFonts.headline)
                                .padding(14)
                                .background(PremiumColors.glassBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(PremiumColors.starkWhite)
                        }
                        
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Protein")
                                    .font(PremiumFonts.caption)
                                    .foregroundStyle(PremiumColors.neonCyan)
                                TextField("0", text: $proteinInput)
                                    .keyboardType(.numbersAndPunctuation)
                                    .font(PremiumFonts.headline)
                                    .padding(14)
                                    .background(PremiumColors.glassBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(PremiumColors.starkWhite)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Carbs")
                                    .font(PremiumFonts.caption)
                                    .foregroundStyle(PremiumColors.starkWhite)
                                TextField("0", text: $carbsInput)
                                    .keyboardType(.numbersAndPunctuation)
                                    .font(PremiumFonts.headline)
                                    .padding(14)
                                    .background(PremiumColors.glassBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(PremiumColors.starkWhite)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Fats")
                                    .font(PremiumFonts.caption)
                                    .foregroundStyle(PremiumColors.midGray)
                                TextField("0", text: $fatsInput)
                                    .keyboardType(.numbersAndPunctuation)
                                    .font(PremiumFonts.headline)
                                    .padding(14)
                                    .background(PremiumColors.glassBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(PremiumColors.starkWhite)
                            }
                        }
                        
                        Button {
                            var updated = item
                            updated.name = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                            updated.calories = Int(caloriesInput) ?? item.calories
                            updated.protein = Int(proteinInput) ?? item.protein
                            updated.carbs = Int(carbsInput) ?? item.carbs
                            updated.fats = Int(fatsInput) ?? item.fats
                            onSave(updated)
                            dismiss()
                        } label: {
                            Text("Save Changes")
                                .font(PremiumFonts.headline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(PremiumColors.neonCyan)
                                .foregroundStyle(PremiumColors.deepBlack)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top, 12)
                    }
                    .padding(20)
                }
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
}
