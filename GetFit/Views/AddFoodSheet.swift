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

struct QuickMealPreset: Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fats: Int
    let icon: String
    let category: String
    let items: [DetectedFoodItem]
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
    
    // Photo & AI Recognition state
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedUIImage: UIImage? = nil
    @State private var showCameraPicker = false
    @State private var isScanningWithAI = false
    @State private var aiSuccessMessage: String? = nil
    @State private var aiErrorMessage: String? = nil
    @State private var detectedItems: [DetectedFoodItem] = []
    
    // Gemini API Key state
    @State private var geminiKeyInput = AIFoodVisionService.shared.savedAPIKey ?? ""
    @State private var showKeySettings = false
    
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    
    // ⚡ 1-Tap Quick Meal Presets
    let quickPresets: [QuickMealPreset] = [
        QuickMealPreset(
            name: "Crispy Dosa, Sambar & Chutney",
            calories: 380, protein: 11, carbs: 63, fats: 14, icon: "🥞", category: "Breakfast",
            items: [
                DetectedFoodItem(name: "Crispy Dosa (2 pcs)", calories: 240, protein: 6, carbs: 48, fats: 5, icon: "🥞"),
                DetectedFoodItem(name: "Sambar & Coconut Chutney", calories: 140, protein: 5, carbs: 15, fats: 9, icon: "🍲")
            ]
        ),
        QuickMealPreset(
            name: "Steamed Idli, Sambar & Chutney",
            calories: 340, protein: 11, carbs: 54, fats: 10, icon: "🍡", category: "Breakfast",
            items: [
                DetectedFoodItem(name: "Steamed Idli (3 pcs)", calories: 180, protein: 6, carbs: 39, fats: 1, icon: "🍡"),
                DetectedFoodItem(name: "Sambar & Coconut Chutney", calories: 160, protein: 5, carbs: 15, fats: 9, icon: "🍲")
            ]
        ),
        QuickMealPreset(
            name: "Eggs, Toast & Filter Coffee",
            calories: 380, protein: 19, carbs: 32, fats: 16, icon: "🍳", category: "Breakfast",
            items: [
                DetectedFoodItem(name: "Fried / Boiled Eggs (2 pcs)", calories: 140, protein: 12, carbs: 1, fats: 10, icon: "🥚"),
                DetectedFoodItem(name: "Toast / Paratha (2 pcs)", calories: 160, protein: 4, carbs: 21, fats: 3, icon: "🍞"),
                DetectedFoodItem(name: "South Indian Filter Coffee", calories: 80, protein: 3, carbs: 10, fats: 3, icon: "☕")
            ]
        ),
        QuickMealPreset(
            name: "Chicken Biryani Portion",
            calories: 650, protein: 38, carbs: 75, fats: 20, icon: "🍛", category: "Lunch",
            items: [
                DetectedFoodItem(name: "Chicken Biryani Portion", calories: 570, protein: 35, carbs: 69, fats: 16, icon: "🍛"),
                DetectedFoodItem(name: "Onion Cucumber Raita", calories: 80, protein: 3, carbs: 6, fats: 4, icon: "🍧")
            ]
        ),
        QuickMealPreset(
            name: "Whole Wheat Roti & Curry Bowl",
            calories: 420, protein: 18, carbs: 58, fats: 14, icon: "🫓", category: "Dinner",
            items: [
                DetectedFoodItem(name: "Whole Wheat Roti (2 pcs)", calories: 180, protein: 6, carbs: 36, fats: 2, icon: "🫓"),
                DetectedFoodItem(name: "Chicken / Paneer Curry (1 bowl)", calories: 240, protein: 12, carbs: 22, fats: 12, icon: "🍲")
            ]
        ),
        QuickMealPreset(
            name: "Curd Rice & Pickle Bowl",
            calories: 320, protein: 8, carbs: 48, fats: 11, icon: "🍚", category: "Lunch",
            items: [
                DetectedFoodItem(name: "South Indian Curd Rice Bowl", calories: 320, protein: 8, carbs: 48, fats: 11, icon: "🍚")
            ]
        ),
        QuickMealPreset(
            name: "Chana & Vegetable Sundal Salad",
            calories: 280, protein: 14, carbs: 38, fats: 6, icon: "🥗", category: "Snack",
            items: [
                DetectedFoodItem(name: "Spicy Chana & Veggie Sundal", calories: 280, protein: 14, carbs: 38, fats: 6, icon: "🥗")
            ]
        ),
        QuickMealPreset(
            name: "South Indian Filter Coffee",
            calories: 90, protein: 3, carbs: 12, fats: 3, icon: "☕", category: "Snack",
            items: [
                DetectedFoodItem(name: "Hot Filter Coffee (1 cup)", calories: 90, protein: 3, carbs: 12, fats: 3, icon: "☕")
            ]
        )
    ]
    
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
                
                // ⚡ 1-Tap Quick Presets Carousel
                VStack(alignment: .leading, spacing: 8) {
                    Text("⚡ 1-Tap Instant Meal Presets")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(paleBlue)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(quickPresets) { preset in
                                Button {
                                    applyPreset(preset)
                                } label: {
                                    HStack(spacing: 8) {
                                        Text(preset.icon)
                                            .font(.title3)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(preset.name)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundStyle(.white)
                                                .lineLimit(1)
                                            
                                            Text("\(preset.calories) kcal")
                                                .font(.caption2)
                                                .foregroundStyle(paleBlue)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(paleBlue.opacity(0.2), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                }
                
                // Gemini API Key Banner / Settings Toggle
                geminiKeyBar
                
                // Photo Picker & AI Scanner Banner
                photoScanSection
                
                // Detected Items Breakdown Card (Shows how total calories are reached)
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
                    
                    TextField("e.g., Dosa, Sambar & Eggs Plate", text: $foodName)
                        .font(.body)
                        .padding(14)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Calories Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Calories (kcal)")
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
    }
    
    private func applyPreset(_ preset: QuickMealPreset) {
        foodName = preset.name
        caloriesText = "\(preset.calories)"
        proteinText = "\(preset.protein)"
        carbsText = "\(preset.carbs)"
        fatsText = "\(preset.fats)"
        selectedMealType = preset.category
        detectedItems = preset.items
        aiSuccessMessage = "Applied preset '\(preset.name)'"
        aiErrorMessage = nil
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
    
    // MARK: - Detected Items Breakdown & Calorie Equation Card
    
    private var detectedItemsBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section Title
            HStack {
                Text("🍽️ Itemized Calorie & Macro Breakdown")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(paleBlue)
                Spacer()
                Text("\(detectedItems.count) Items")
                    .font(.caption2)
                    .foregroundStyle(Color.gray)
            }
            
            // Calorie Calculation Sum Equation Banner
            let totalCalsCalculated = detectedItems.reduce(0) { $0 + $1.calories }
            let equationString = detectedItems.map { "\($0.calories)" }.joined(separator: " + ")
            
            HStack(spacing: 8) {
                Image(systemName: "calculator")
                    .font(.caption)
                    .foregroundStyle(paleBlue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Calorie Calculation:")
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
            
            // Individual Food Items List
            VStack(spacing: 8) {
                ForEach(detectedItems) { item in
                    HStack(spacing: 12) {
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
                        
                        // Per-Item Calorie Badge
                        Text("\(item.calories) kcal")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(paleBlue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(UIColor.tertiarySystemBackground))
                            .clipShape(Capsule())
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
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    Text("Preview")
        .sheet(isPresented: .constant(true)) {
            AddFoodSheet()
                .preferredColorScheme(.dark)
        }
}
