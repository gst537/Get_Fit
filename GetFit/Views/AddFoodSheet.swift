import SwiftUI
import SwiftData
import PhotosUI

// MARK: - Native Camera View Wrapper
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
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
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
    
    // Per-item breakdown state
    @State private var detectedItems: [DetectedFoodItem] = []
    @State private var itemToEdit: DetectedFoodItem? = nil
    
    // Photo & AI Recognition state
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedUIImage: UIImage? = nil
    @State private var showCameraPicker = false
    @State private var isScanningWithAI = false
    @State private var aiSuccessMessage: String? = nil
    @State private var aiErrorMessage: String? = nil
    
    // Gemini API Key state
    @State private var geminiKeyInput = AIFoodVisionService.shared.savedAPIKey ?? ""
    @State private var showKeySettings = false
    
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)

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
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.body)
                    .foregroundStyle(paleBlue)
                }
                
                // Gemini API Key Banner / Settings Toggle
                geminiKeyBar
                
                // Photo Picker & AI Scanner Banner
                photoScanSection
                
                // Individual Item Breakdown Card with Per-Item Quantity Steppers [-] 1.0x [+]
                if !detectedItems.isEmpty {
                    detectedItemsBreakdownCard
                }
                
                // Meal Type Category Picker
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
                                .background(selectedMealType == type ? paleBlue : Color(UIColor.secondarySystemBackground))
                                .clipShape(Capsule())
                                .onTapGesture {
                                    selectedMealType = type
                                }
                        }
                    }
                }
                
                // Food Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Food / Dish Name")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    
                    TextField("e.g., Dosa & Coffee Breakfast", text: $foodName)
                        .font(.body)
                        .padding(14)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Calories Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Meal Calories (kcal)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    
                    HStack {
                        TextField("0", text: $caloriesText)
                            .keyboardType(.numberPad)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                        
                        Text("kcal")
                            .font(.subheadline)
                            .foregroundStyle(Color.gray)
                    }
                    .padding(14)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Macro Inputs Grid
                VStack(alignment: .leading, spacing: 12) {
                    Text("Macros (Optional)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    
                    HStack(spacing: 12) {
                        macroInputField(title: "Protein", color: paleBlue, text: $proteinText)
                        macroInputField(title: "Carbs", color: Color(red: 0.95, green: 0.75, blue: 0.40), text: $carbsText)
                        macroInputField(title: "Fats", color: Color(red: 0.45, green: 0.85, blue: 0.65), text: $fatsText)
                    }
                }
                
                // Save Button
                Button {
                    saveMeal()
                } label: {
                    Text("Save Food Entry")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(paleBlue)
                        .clipShape(Capsule())
                        .opacity(foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (Int(caloriesText) ?? 0) <= 0 ? 0.5 : 1.0)
                }
                .disabled(foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (Int(caloriesText) ?? 0) <= 0)
                .padding(.top, 8)
            }
            .padding(24)
        }
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            selectedMealType = initialMealType
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                    selectedUIImage = image
                    scanMealWithAI(image)
                }
            }
        }
        .sheet(isPresented: $showCameraPicker) {
            CameraView(selectedImage: $selectedUIImage) { capturedImage in
                scanMealWithAI(capturedImage)
            }
        }
        .sheet(item: $itemToEdit) { item in
            EditDetectedItemSheet(item: item) { updated in
                if let idx = detectedItems.firstIndex(where: { $0.id == updated.id }) {
                    detectedItems[idx] = updated
                    recalculateTotalsFromDetectedItems()
                }
            }
        }
    }
    
    // MARK: - Per-Item Quantity Breakdown Card
    
    private var detectedItemsBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Text("🍽️ Plate Items & Quantities")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(paleBlue)
                Spacer()
                Text("\(detectedItems.count) Items")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.gray)
            }
            
            // Sum Banner Equation
            let totalCalsCalculated = detectedItems.reduce(0) { $0 + $1.calories }
            let equationString = detectedItems.map { "\($0.calories)" }.joined(separator: " + ")
            
            HStack(spacing: 8) {
                Image(systemName: "calculator")
                    .font(.caption)
                    .foregroundStyle(paleBlue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Meal Calculation:")
                        .font(.caption2)
                        .foregroundStyle(Color.gray)
                    Text("\(equationString) = \(totalCalsCalculated) kcal")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(paleBlue.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // List of Items — EACH HAS ITS OWN INDIVIDUAL QUANTITY STEPPER [-] Qty [+]
            VStack(spacing: 10) {
                ForEach(detectedItems) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            Text(item.icon)
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.subheadline)
                                    .fontWeight(.regular)
                                    .foregroundStyle(.white)
                                
                                HStack(spacing: 6) {
                                    Text("P: \(item.protein)g")
                                        .font(.caption2)
                                        .foregroundStyle(paleBlue)
                                    Text("C: \(item.carbs)g")
                                        .font(.caption2)
                                        .foregroundStyle(Color(red: 0.95, green: 0.75, blue: 0.40))
                                    Text("F: \(item.fats)g")
                                        .font(.caption2)
                                        .foregroundStyle(Color(red: 0.45, green: 0.85, blue: 0.65))
                                }
                            }
                            
                            Spacer()
                            
                            // Edit Item Pencil
                            Button {
                                itemToEdit = item
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 10))
                                    Text("\(item.calories) kcal")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundStyle(paleBlue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(paleBlue.opacity(0.15))
                                .clipShape(Capsule())
                            }
                            
                            // Delete Item Trash
                            Button {
                                detectedItems.removeAll { $0.id == item.id }
                                recalculateTotalsFromDetectedItems()
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.red.opacity(0.85))
                                    .padding(6)
                                    .background(Color.red.opacity(0.12))
                                    .clipShape(Circle())
                            }
                        }
                        
                        // INDIVIDUAL ITEM QUANTITY STEPPER [-] Qty [+]
                        HStack {
                            Text("Quantity for \(item.name):")
                                .font(.caption2)
                                .foregroundStyle(Color.gray)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Button {
                                    adjustIndividualItemQuantity(item, delta: -0.5)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(paleBlue)
                                }
                                
                                Text(String(format: "%.1fx", item.quantity))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .frame(width: 36)
                                
                                Button {
                                    adjustIndividualItemQuantity(item, delta: 0.5)
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(paleBlue)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.06))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(10)
                    .background(Color(UIColor.tertiarySystemBackground).opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Adjust ONLY the selected item's quantity
    
    private func adjustIndividualItemQuantity(_ item: DetectedFoodItem, delta: Double) {
        guard let idx = detectedItems.firstIndex(where: { $0.id == item.id }) else { return }
        let currentQty = detectedItems[idx].quantity
        let newQty = max(0.5, currentQty + delta)
        guard currentQty != newQty else { return }
        
        let unitCals = item.unitCalories
        let unitP = item.unitProtein
        let unitC = item.unitCarbs
        let unitF = item.unitFats
        
        detectedItems[idx].quantity = newQty
        detectedItems[idx].calories = max(1, Int(round(unitCals * newQty)))
        detectedItems[idx].protein = max(0, Int(round(unitP * newQty)))
        detectedItems[idx].carbs = max(0, Int(round(unitC * newQty)))
        detectedItems[idx].fats = max(0, Int(round(unitF * newQty)))
        
        recalculateTotalsFromDetectedItems()
    }
    
    private func recalculateTotalsFromDetectedItems() {
        let totalCals = detectedItems.reduce(0) { $0 + $1.calories }
        let totalP = detectedItems.reduce(0) { $0 + $1.protein }
        let totalC = detectedItems.reduce(0) { $0 + $1.carbs }
        let totalF = detectedItems.reduce(0) { $0 + $1.fats }
        
        caloriesText = "\(totalCals)"
        proteinText = "\(totalP)"
        carbsText = "\(totalC)"
        fatsText = "\(totalF)"
        
        if detectedItems.isEmpty {
            aiSuccessMessage = nil
        } else {
            aiSuccessMessage = "Recalculated totals: \(totalCals) kcal"
        }
    }
    
    // MARK: - Gemini Vision AI Key Bar
    
    private var geminiKeyBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundStyle(paleBlue)
                
                Text(AIFoodVisionService.shared.savedAPIKey != nil ? "Google Gemini Vision AI Active" : "Paste Free Gemini Key for AI Photo Scanning")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button(showKeySettings ? "Done" : (AIFoodVisionService.shared.savedAPIKey != nil ? "Key Saved ✓" : "+ Add Free Key")) {
                    withAnimation {
                        showKeySettings.toggle()
                    }
                }
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(paleBlue)
            }
            .padding(10)
            .background(paleBlue.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            if showKeySettings {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Paste Free Google Gemini API Key (aistudio.google.com):")
                        .font(.caption2)
                        .foregroundStyle(Color.gray)
                    
                    HStack {
                        SecureField("AIzaSy...", text: $geminiKeyInput)
                            .font(.caption)
                            .padding(8)
                            .background(Color(UIColor.tertiarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Button("Save") {
                            let cleanKey = geminiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
                            AIFoodVisionService.shared.savedAPIKey = cleanKey.isEmpty ? nil : cleanKey
                            aiErrorMessage = nil
                            withAnimation {
                                showKeySettings = false
                            }
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(paleBlue)
                        .clipShape(Capsule())
                    }
                }
                .padding(10)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    // MARK: - Photo & AI Scanner UI
    
    private var photoScanSection: some View {
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
                // Dual Options: Take Photo with Camera OR Choose from Gallery
                HStack(spacing: 12) {
                    // Direct Camera Button
                    Button {
                        showCameraPicker = true
                    } label: {
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(paleBlue.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(paleBlue)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Take Photo")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white)
                                Text("Use Camera")
                                    .font(.caption2)
                                    .foregroundStyle(Color.gray)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Gallery PhotosPicker Button
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(paleBlue.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 16))
                                    .foregroundStyle(paleBlue)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Gallery")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white)
                                Text("Choose Photo")
                                    .font(.caption2)
                                    .foregroundStyle(Color.gray)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            
            if isScanningWithAI {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(paleBlue)
                    Text("Google Gemini Vision AI scanning plate items...")
                        .font(.caption)
                        .foregroundStyle(paleBlue)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(paleBlue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else if let msg = aiSuccessMessage {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.green)
                    Text(msg)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else if let err = aiErrorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.orange)
                    Text(err)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.orange.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    private func scanMealWithAI(_ image: UIImage) {
        isScanningWithAI = true
        aiSuccessMessage = nil
        aiErrorMessage = nil
        detectedItems = []
        
        Task {
            let result = await AIFoodVisionService.shared.analyzeFoodImage(image)
            
            isScanningWithAI = false
            if let errorMsg = result.errorMessage {
                aiErrorMessage = errorMsg
                showKeySettings = true
            } else {
                foodName = result.plateTitle
                caloriesText = "\(result.totalCalories)"
                proteinText = "\(result.totalProtein)"
                carbsText = "\(result.totalCarbs)"
                fatsText = "\(result.totalFats)"
                detectedItems = result.detectedItems
                aiSuccessMessage = "Gemini identified '\(result.plateTitle)' (\(result.totalCalories) kcal)"
            }
        }
    }
    
    private func macroInputField(title: String, color: Color, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(color)
            
            HStack(spacing: 2) {
                TextField("0", text: text)
                    .keyboardType(.numberPad)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                
                Text("g")
                    .font(.caption2)
                    .foregroundStyle(Color.gray)
            }
            .padding(10)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    private func saveMeal() {
        let name = foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        let calories = Int(caloriesText) ?? 0
        let protein = Int(proteinText) ?? 0
        let carbs = Int(carbsText) ?? 0
        let fats = Int(fatsText) ?? 0
        
        guard !name.isEmpty, calories > 0 else { return }
        
        var localImagePath: String? = nil
        if let image = selectedUIImage {
            localImagePath = AIFoodVisionService.shared.saveMealImageLocally(image)
        }
        
        if !detectedItems.isEmpty {
            for item in detectedItems {
                let mealEntry = MealLog(
                    name: item.name,
                    mealType: selectedMealType,
                    calories: item.calories,
                    proteinGrams: item.protein,
                    carbsGrams: item.carbs,
                    fatsGrams: item.fats,
                    imagePath: localImagePath
                )
                modelContext.insert(mealEntry)
            }
        } else {
            let newMeal = MealLog(
                name: name,
                mealType: selectedMealType,
                calories: calories,
                proteinGrams: protein,
                carbsGrams: carbs,
                fatsGrams: fats,
                imagePath: localImagePath
            )
            modelContext.insert(newMeal)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Edit Individual Detected Food Item Sheet

struct EditDetectedItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    var item: DetectedFoodItem
    var onSave: (DetectedFoodItem) -> Void
    
    @State private var nameInput: String = ""
    @State private var caloriesInput: String = ""
    @State private var proteinInput: String = ""
    @State private var carbsInput: String = ""
    @State private var fatsInput: String = ""
    
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Name & Portion") {
                    TextField("e.g. 1 Dosa, 1 Coffee", text: $nameInput)
                }
                
                Section("Calories & Macros") {
                    HStack {
                        Text("Calories (kcal)")
                        Spacer()
                        TextField("0", text: $caloriesInput)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Protein (g)")
                        Spacer()
                        TextField("0", text: $proteinInput)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Carbs (g)")
                        Spacer()
                        TextField("0", text: $carbsInput)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Fats (g)")
                        Spacer()
                        TextField("0", text: $fatsInput)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Edit Item & Calories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
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
                    .fontWeight(.bold)
                    .foregroundStyle(paleBlue)
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

#Preview {
    Text("Preview")
        .sheet(isPresented: .constant(true)) {
            AddFoodSheet()
                .preferredColorScheme(.dark)
        }
}
