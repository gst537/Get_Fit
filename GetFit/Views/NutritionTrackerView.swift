import SwiftUI
import SwiftData

struct NutritionTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealLog.date, order: .reverse) private var allMeals: [MealLog]
    @Query private var nutritionGoals: [NutritionGoal]
    
    @State private var showAddFoodSheet = false
    @State private var selectedCategoryForAdd = "Breakfast"
    @State private var showEditGoalSheet = false
    @State private var selectedMealPhoto: UIImage? = nil
    @State private var mealToEdit: MealLog? = nil
    
    let paleBlue = MutedEarth.slateBlue
    let warmGold = MutedEarth.terracotta
    let mintGreen = MutedEarth.softSage
    
    private var activeGoal: NutritionGoal {
        if let existing = nutritionGoals.first {
            return existing
        } else {
            let newGoal = NutritionGoal(targetCalories: 2200, targetProtein: 160, targetCarbs: 220, targetFats: 70)
            modelContext.insert(newGoal)
            try? modelContext.save()
            return newGoal
        }
    }
    
    private var todayMeals: [MealLog] {
        let calendar = Calendar.current
        return allMeals.filter { calendar.isDateInToday($0.date) }
    }
    
    private var totalConsumedCalories: Int {
        todayMeals.reduce(0) { $0 + $1.calories }
    }
    
    private var totalConsumedProtein: Int {
        todayMeals.reduce(0) { $0 + $1.proteinGrams }
    }
    
    private var totalConsumedCarbs: Int {
        todayMeals.reduce(0) { $0 + $1.carbsGrams }
    }
    
    private var totalConsumedFats: Int {
        todayMeals.reduce(0) { $0 + $1.fatsGrams }
    }
    
    private var isCalorieOverGoal: Bool {
        totalConsumedCalories > activeGoal.targetCalories
    }
    
    private var remainingCalories: Int {
        activeGoal.targetCalories - totalConsumedCalories
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // 1. Hero Calorie Card
                heroCalorieCard
                
                // 2. Macro Progress Bars
                macroProgressCard
                
                // 3. Meal Categories Logs
                mealCategoriesSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showAddFoodSheet) {
            AddFoodSheet(initialMealType: selectedCategoryForAdd)
        }
        .sheet(isPresented: $showEditGoalSheet) {
            EditNutritionGoalSheet(goal: activeGoal)
        }
        .sheet(item: $mealToEdit) { meal in
            EditLoggedMealSheet(meal: meal)
        }
        .sheet(item: Binding<IdentifiableImage?>(
            get: { selectedMealPhoto.map { IdentifiableImage(image: $0) } },
            set: { selectedMealPhoto = $0?.image }
        )) { item in
            VStack {
                HStack {
                    Spacer()
                    Button("Done") {
                        selectedMealPhoto = nil
                    }
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(paleBlue)
                }
                .padding()
                
                Image(uiImage: item.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding()
                
                Spacer()
            }
            .background(Color.black.ignoresSafeArea())
        }
    }
    
    // MARK: - Hero Calorie Card
    
    private var heroCalorieCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Daily Calories")
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundStyle(Color.gray)
                Spacer()
                Button {
                    showEditGoalSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12))
                        Text("Edit Target")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(paleBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(paleBlue.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            
            let progress = min(1.0, Double(totalConsumedCalories) / Double(max(1, activeGoal.targetCalories)))
            let ringGradients = isCalorieOverGoal
                ? [MutedEarth.terracotta, MutedEarth.terracotta]
                : [paleBlue, paleBlue]
            
            ZStack {
                AnimatedRingView(
                    progress: progress,
                    lineWidth: 12,
                    gradient: ringGradients,
                    size: 140
                )
                
                VStack(spacing: 2) {
                    if isCalorieOverGoal {
                        Text("+\(abs(remainingCalories))")
                            .font(.system(size: 42, weight: .black))
                            .foregroundStyle(MutedEarth.terracotta)
                        Text("kcal over goal")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(MutedEarth.terracotta)
                    } else {
                        Text("\(remainingCalories)")
                            .font(.system(size: 42, weight: .black))
                            .foregroundStyle(.white)
                        Text("kcal left")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(paleBlue)
                    }
                }
            }
            
            HStack {
                Text("\(totalConsumedCalories) consumed")
                    .font(.caption2)
                    .foregroundStyle(Color.gray)
                Spacer()
                Text("Goal: \(activeGoal.targetCalories) kcal")
                    .font(.caption2)
                    .foregroundStyle(Color.gray)
            }
        }
        .padding(20)
        .glassmorphic(cornerRadius: 20)
    }
    
    // MARK: - Macro Progress Card
    
    private var macroProgressCard: some View {
        HStack(spacing: 12) {
            macroRingItem(
                title: "Protein",
                consumed: totalConsumedProtein,
                target: activeGoal.targetProtein,
                unit: "g",
                gradient: [paleBlue, paleBlue]
            )
            
            macroRingItem(
                title: "Carbs",
                consumed: totalConsumedCarbs,
                target: activeGoal.targetCarbs,
                unit: "g",
                gradient: [warmGold, warmGold]
            )
            
            macroRingItem(
                title: "Fats",
                consumed: totalConsumedFats,
                target: activeGoal.targetFats,
                unit: "g",
                gradient: [mintGreen, mintGreen]
            )
        }
    }
    
    private func macroRingItem(title: String, consumed: Int, target: Int, unit: String, gradient: [Color]) -> some View {
        let progress = min(1.0, Double(consumed) / Double(max(1, target)))
        
        return VStack(spacing: 8) {
            ZStack {
                AnimatedRingView(
                    progress: progress,
                    lineWidth: 5,
                    gradient: gradient,
                    size: 52
                )
                
                Text("\(consumed)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(gradient.first ?? .white)
            
            Text("\(consumed)/\(target)\(unit)")
                .font(.system(size: 9))
                .foregroundStyle(Color.gray)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .glassmorphic(cornerRadius: 16)
    }
    
    // MARK: - Meal Categories Section
    
    private var mealCategoriesSection: some View {
        VStack(spacing: 16) {
            mealCategoryBlock(title: "Breakfast", icon: "sunrise.fill", categoryName: "Breakfast")
            mealCategoryBlock(title: "Lunch", icon: "sun.max.fill", categoryName: "Lunch")
            mealCategoryBlock(title: "Dinner", icon: "moon.fill", categoryName: "Dinner")
            mealCategoryBlock(title: "Snacks", icon: "leaf.fill", categoryName: "Snack")
        }
    }
    
    private func mealCategoryBlock(title: String, icon: String, categoryName: String) -> some View {
        let categoryMeals = todayMeals.filter { $0.mealType.lowercased() == categoryName.lowercased() }
        let categoryCalories = categoryMeals.reduce(0) { $0 + $1.calories }
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(paleBlue)
                    
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                if categoryCalories > 0 {
                    Text("\(categoryCalories) kcal")
                        .font(.caption)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.gray)
                }
                
                Button {
                    Haptics.playLightImpact()
                    selectedCategoryForAdd = categoryName
                    showAddFoodSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 12))
                        Text("Add")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(paleBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(paleBlue.opacity(0.12))
                    .clipShape(Capsule())
                }
            }
            
            if categoryMeals.isEmpty {
                Text("No items logged for \(title.lowercased()).")
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundStyle(Color.gray.opacity(0.6))
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 0) {
                    ForEach(categoryMeals) { meal in
                        VStack(spacing: 6) {
                            HStack(spacing: 12) {
                                if let path = meal.imagePath, let uiImg = AIFoodVisionService.shared.loadMealImage(from: path) {
                                    Button {
                                        selectedMealPhoto = uiImg
                                    } label: {
                                        Image(uiImage: uiImg)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 44, height: 44)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(meal.name)
                                        .font(.body)
                                        .fontWeight(.regular)
                                        .foregroundStyle(.white)
                                    
                                    HStack(spacing: 8) {
                                        if meal.proteinGrams > 0 {
                                            Text("P: \(meal.proteinGrams)g")
                                                .font(.caption2)
                                                .foregroundStyle(paleBlue)
                                        }
                                        if meal.carbsGrams > 0 {
                                            Text("C: \(meal.carbsGrams)g")
                                                .font(.caption2)
                                                .foregroundStyle(warmGold)
                                        }
                                        if meal.fatsGrams > 0 {
                                            Text("F: \(meal.fatsGrams)g")
                                                .font(.caption2)
                                                .foregroundStyle(mintGreen)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                Text("\(meal.calories) kcal")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white)
                                
                                // Pencil Button to EDIT already posted meal
                                Button {
                                    mealToEdit = meal
                                } label: {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 12))
                                        .foregroundStyle(paleBlue)
                                        .padding(.leading, 4)
                                }
                                
                                // Trash Button to DELETE posted meal
                                Button {
                                    deleteMeal(meal)
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.red.opacity(0.85))
                                        .padding(.leading, 2)
                                }
                            }
                            
                            // INLINE +/- QUANTITY STEPPER for this individual item
                            HStack {
                                Text("Qty:")
                                    .font(.caption2).foregroundStyle(Color.gray)
                                
                                Spacer()
                                
                                HStack(spacing: 10) {
                                    Button {
                                        Haptics.playLightImpact()
                                        adjustLoggedMealQty(meal, delta: -1)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundStyle(meal.calories <= getBaseCalories(meal) ? Color.gray.opacity(0.4) : paleBlue)
                                    }
                                    .disabled(meal.calories <= getBaseCalories(meal))
                                    
                                    Text("\(getCurrentQty(meal))")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                        .frame(width: 24)
                                        .multilineTextAlignment(.center)
                                    
                                    Button {
                                        Haptics.playLightImpact()
                                        adjustLoggedMealQty(meal, delta: 1)
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundStyle(paleBlue)
                                    }
                                }
                                .padding(.horizontal, 8).padding(.vertical, 2)
                                .background(Color.white.opacity(0.06))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, 8)
                        
                        if meal.id != categoryMeals.last?.id {
                            Divider()
                                .background(Color.gray.opacity(0.2))
                        }
                    }
                }
            }
        }
        .padding(16)
        .glassmorphic(cornerRadius: 18)
    }
    
    // MARK: - Logged Meal Quantity Helpers
    
    /// Get the base per-unit calories (stored calories / current quantity)
    private func getBaseCalories(_ meal: MealLog) -> Int {
        // We assume base = the smallest meaningful unit
        // Since we don't store base separately, use calories as-is for qty=1
        return max(1, meal.calories / max(1, getCurrentQty(meal)))
    }
    
    /// Infer current quantity from the meal name if it contains a number, otherwise 1
    private func getCurrentQty(_ meal: MealLog) -> Int {
        return max(1, meal.calories / max(1, getStoredBaseCalories(meal)))
    }
    
    /// Get base calories per unit — stored in UserDefaults keyed by meal ID
    private func getStoredBaseCalories(_ meal: MealLog) -> Int {
        let key = "mealBase_\(meal.id.uuidString)"
        let stored = UserDefaults.standard.integer(forKey: key)
        if stored > 0 { return stored }
        // First time — set current calories as base (qty=1)
        UserDefaults.standard.set(meal.calories, forKey: key)
        return meal.calories
    }
    
    private func getStoredBaseMacro(_ meal: MealLog, macro: String) -> Int {
        let key = "mealBase\(macro)_\(meal.id.uuidString)"
        let stored = UserDefaults.standard.integer(forKey: key)
        if stored > 0 { return stored }
        let val: Int
        switch macro {
        case "P": val = meal.proteinGrams
        case "C": val = meal.carbsGrams
        case "F": val = meal.fatsGrams
        default: val = 0
        }
        UserDefaults.standard.set(val, forKey: key)
        return val
    }
    
    /// Adjust quantity of a single logged meal by delta (+1 or -1)
    private func adjustLoggedMealQty(_ meal: MealLog, delta: Int) {
        let baseCal = getStoredBaseCalories(meal)
        let baseP = getStoredBaseMacro(meal, macro: "P")
        let baseC = getStoredBaseMacro(meal, macro: "C")
        let baseF = getStoredBaseMacro(meal, macro: "F")
        
        let currentQty = max(1, meal.calories / max(1, baseCal))
        let newQty = max(1, currentQty + delta)
        
        meal.calories = baseCal * newQty
        meal.proteinGrams = baseP * newQty
        meal.carbsGrams = baseC * newQty
        meal.fatsGrams = baseF * newQty
        
        try? modelContext.save()
    }
    
    private func deleteMeal(_ meal: MealLog) {
        modelContext.delete(meal)
        try? modelContext.save()
    }
}

// MARK: - Edit Already Logged Meal Sheet (Modify Name, Calories, Portion, Macros)

struct EditLoggedMealSheet: View {
    let meal: MealLog
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var nameInput: String = ""
    @State private var caloriesInput: String = ""
    @State private var proteinInput: String = ""
    @State private var carbsInput: String = ""
    @State private var fatsInput: String = ""
    @State private var quantityMultiplier: Double = 1.0
    
    @State private var baseCalories: Double = 0.0
    @State private var baseProtein: Double = 0.0
    @State private var baseCarbs: Double = 0.0
    @State private var baseFats: Double = 0.0
    
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dish Name & Category") {
                    TextField("Dish Name", text: $nameInput)
                    
                    Picker("Meal Category", selection: Binding(
                        get: { meal.mealType },
                        set: { meal.mealType = $0 }
                    )) {
                        Text("Breakfast").tag("Breakfast")
                        Text("Lunch").tag("Lunch")
                        Text("Dinner").tag("Dinner")
                        Text("Snack").tag("Snack")
                    }
                }
                
                Section("Modify Portion Quantity") {
                    HStack {
                        Text("Portion Multiplier")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button {
                                adjustQuantity(by: -0.5)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(paleBlue)
                            }
                            
                            Text(String(format: "%.1fx", quantityMultiplier))
                                .font(.body)
                                .fontWeight(.bold)
                                .frame(width: 44)
                            
                            Button {
                                adjustQuantity(by: 0.5)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(paleBlue)
                            }
                        }
                    }
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
            .navigationTitle("Modify Posted Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Changes") {
                        meal.name = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                        meal.calories = Int(caloriesInput) ?? meal.calories
                        meal.proteinGrams = Int(proteinInput) ?? meal.proteinGrams
                        meal.carbsGrams = Int(carbsInput) ?? meal.carbsGrams
                        meal.fatsGrams = Int(fatsInput) ?? meal.fatsGrams
                        
                        try? modelContext.save()
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(paleBlue)
                }
            }
            .onAppear {
                nameInput = meal.name
                caloriesInput = "\(meal.calories)"
                proteinInput = "\(meal.proteinGrams)"
                carbsInput = "\(meal.carbsGrams)"
                fatsInput = "\(meal.fatsGrams)"
                
                baseCalories = Double(meal.calories)
                baseProtein = Double(meal.proteinGrams)
                baseCarbs = Double(meal.carbsGrams)
                baseFats = Double(meal.fatsGrams)
            }
        }
    }
    
    private func adjustQuantity(by delta: Double) {
        let newQty = max(0.5, quantityMultiplier + delta)
        quantityMultiplier = newQty
        
        caloriesInput = "\(Int(baseCalories * newQty))"
        proteinInput = "\(Int(baseProtein * newQty))"
        carbsInput = "\(Int(baseCarbs * newQty))"
        fatsInput = "\(Int(baseFats * newQty))"
    }
}

// MARK: - Edit Nutrition Goal Sheet

struct EditNutritionGoalSheet: View {
    let goal: NutritionGoal
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var calsText = ""
    @State private var proteinText = ""
    @State private var carbsText = ""
    @State private var fatsText = ""
    
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Edit Daily Nutrition Goals")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button("Cancel") { dismiss() }
                    .font(.body)
                    .foregroundStyle(paleBlue)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Target Calories (kcal)")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                TextField("2200", text: $calsText)
                    .keyboardType(.numberPad)
                    .font(.body)
                    .padding(12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Protein (g)")
                        .font(.caption)
                        .foregroundStyle(paleBlue)
                    TextField("160", text: $proteinText)
                        .keyboardType(.numberPad)
                        .font(.body)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Carbs (g)")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.95, green: 0.75, blue: 0.40))
                    TextField("220", text: $carbsText)
                        .keyboardType(.numberPad)
                        .font(.body)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Fats (g)")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.45, green: 0.85, blue: 0.65))
                    TextField("70", text: $fatsText)
                        .keyboardType(.numberPad)
                        .font(.body)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            Button("Save Targets") {
                goal.targetCalories = Int(calsText) ?? goal.targetCalories
                goal.targetProtein = Int(proteinText) ?? goal.targetProtein
                goal.targetCarbs = Int(carbsText) ?? goal.targetCarbs
                goal.targetFats = Int(fatsText) ?? goal.targetFats
                try? modelContext.save()
                dismiss()
            }
            .font(.body)
            .fontWeight(.medium)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(paleBlue)
            .clipShape(Capsule())
            .padding(.top, 10)
        }
        .padding(24)
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.height(340)])
        .presentationDragIndicator(.visible)
        .onAppear {
            calsText = "\(goal.targetCalories)"
            proteinText = "\(goal.targetProtein)"
            carbsText = "\(goal.targetCarbs)"
            fatsText = "\(goal.targetFats)"
        }
    }
}

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

#Preview {
    NutritionTrackerView()
        .modelContainer(for: [MealLog.self, NutritionGoal.self], inMemory: true)
        .preferredColorScheme(.dark)
}
