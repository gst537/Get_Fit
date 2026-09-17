import SwiftUI
import SwiftData

struct NutritionTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealLog.date, order: .reverse) private var allMeals: [MealLog]
    @Query private var nutritionGoals: [NutritionGoal]
    
    @State private var showAddFoodSheet = false
    @State private var selectedCategoryForAdd: MealType = .breakfast
    @State private var showEditGoalSheet = false
    @State private var selectedMealPhoto: UIImage? = nil
    @State private var mealToEdit: MealLog? = nil
    
    // Premium Colors for macros
    let pColor = PremiumColors.neonCyan
    let cColor = PremiumColors.starkWhite
    let fColor = PremiumColors.midGray
    
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
        ZStack {
            // Background
            PremiumColors.deepBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    HStack {
                        Spacer()
                        Text("Nutrition & Macros")
                            .font(PremiumFonts.headline)
                            .foregroundStyle(PremiumColors.starkWhite)
                        Spacer()
                    }
                    .padding(.top, 16)
                    
                    // 1. Hero Calorie Card
                    heroCalorieCard
                    
                    // 2. Macro Progress Bars
                    macroProgressCard
                    
                    // 3. Meal Categories Logs
                    mealCategoriesSection
                }
                .padding(.bottom, 40)
            }
        }
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
            ZStack {
                PremiumColors.deepBlack.ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            selectedMealPhoto = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(PremiumColors.midGray)
                        }
                    }
                    .padding()
                    
                    Image(uiImage: item.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: PremiumColors.neonCyan.opacity(0.3), radius: 10)
                        .padding()
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Hero Calorie Card
    
    private var heroCalorieCard: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Energy Balance")
                    .font(PremiumFonts.headline)
                    .foregroundStyle(PremiumColors.starkWhite)
                Spacer()
                Button {
                    showEditGoalSheet = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 20))
                        .foregroundStyle(PremiumColors.neonCyan)
                }
            }
            
            let progress = min(1.0, Double(totalConsumedCalories) / Double(max(1, activeGoal.targetCalories)))
            let ringGradients = isCalorieOverGoal
                ? [Color.red, Color.orange]
                : [PremiumColors.neonCyan, PremiumColors.neonCyan.opacity(0.6)]
            
            ZStack {
                AnimatedRingView(
                    progress: progress,
                    lineWidth: 16,
                    gradient: ringGradients,
                    size: 180
                )
                
                VStack(spacing: 2) {
                    if isCalorieOverGoal {
                        Text("+\(abs(remainingCalories))")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(Color.red)
                        Text("Over Goal")
                            .font(PremiumFonts.caption)
                            .foregroundStyle(Color.red)
                    } else {
                        Text("\(remainingCalories)")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(PremiumColors.starkWhite)
                        Text("Remaining")
                            .font(PremiumFonts.caption)
                            .foregroundStyle(PremiumColors.neonCyan)
                    }
                }
            }
            .padding(.vertical, 10)
            
            HStack {
                VStack(spacing: 4) {
                    Text("Consumed")
                        .font(PremiumFonts.caption)
                        .foregroundStyle(PremiumColors.midGray)
                    Text("\(totalConsumedCalories) kcal")
                        .font(PremiumFonts.headline)
                        .foregroundStyle(PremiumColors.starkWhite)
                }
                Spacer()
                VStack(spacing: 4) {
                    Text("Target")
                        .font(PremiumFonts.caption)
                        .foregroundStyle(PremiumColors.midGray)
                    Text("\(activeGoal.targetCalories) kcal")
                        .font(PremiumFonts.headline)
                        .foregroundStyle(PremiumColors.starkWhite)
                }
            }
        }
        .padding(20)
        .background(PremiumColors.glassBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }
    
    // MARK: - Macro Progress Card
    
    private var macroProgressCard: some View {
        HStack(spacing: 12) {
            macroRingItem(
                title: "Protein",
                consumed: totalConsumedProtein,
                target: activeGoal.targetProtein,
                unit: "g",
                gradient: [pColor, pColor.opacity(0.7)]
            )
            
            macroRingItem(
                title: "Carbs",
                consumed: totalConsumedCarbs,
                target: activeGoal.targetCarbs,
                unit: "g",
                gradient: [cColor, cColor.opacity(0.7)]
            )
            
            macroRingItem(
                title: "Fats",
                consumed: totalConsumedFats,
                target: activeGoal.targetFats,
                unit: "g",
                gradient: [fColor, fColor.opacity(0.7)]
            )
        }
        .padding(.horizontal, 20)
    }
    
    private func macroRingItem(title: String, consumed: Int, target: Int, unit: String, gradient: [Color]) -> some View {
        let progress = min(1.0, Double(consumed) / Double(max(1, target)))
        
        return VStack(spacing: 10) {
            ZStack {
                AnimatedRingView(
                    progress: progress,
                    lineWidth: 6,
                    gradient: gradient,
                    size: 64
                )
                
                Text("\(consumed)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(PremiumColors.starkWhite)
            }
            
            VStack(spacing: 2) {
                Text(title)
                    .font(PremiumFonts.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(gradient.first ?? .white)
                
                Text("\(consumed)/\(target)\(unit)")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(PremiumColors.midGray)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(PremiumColors.glassBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Meal Categories Section
    
    private var mealCategoriesSection: some View {
        VStack(spacing: 16) {
            mealCategoryBlock(title: "Breakfast", icon: "sunrise.fill", categoryName: .breakfast)
            mealCategoryBlock(title: "Lunch", icon: "sun.max.fill", categoryName: .lunch)
            mealCategoryBlock(title: "Dinner", icon: "moon.fill", categoryName: .dinner)
            mealCategoryBlock(title: "Snacks", icon: "takeoutbag.and.cup.and.straw.fill", categoryName: .snack)
        }
        .padding(.horizontal, 20)
    }
    
    private func mealCategoryBlock(title: String, icon: String, categoryName: MealType) -> some View {
        let categoryMeals = todayMeals.filter { $0.mealType == categoryName }
        let categoryCalories = categoryMeals.reduce(0) { $0 + $1.calories }
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(PremiumColors.starkWhite)
                        .frame(width: 40, height: 40)
                        .background(PremiumColors.glassBorder.opacity(0.5))
                        .clipShape(Circle())
                    
                    Text(title)
                        .font(PremiumFonts.headline)
                        .foregroundStyle(PremiumColors.starkWhite)
                }
                
                Spacer()
                
                if categoryCalories > 0 {
                    Text("\(categoryCalories) kcal")
                        .font(PremiumFonts.caption)
                        .foregroundStyle(PremiumColors.midGray)
                        .padding(.trailing, 8)
                }
                
                Button {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    selectedCategoryForAdd = categoryName
                    showAddFoodSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(PremiumColors.deepBlack)
                        .frame(width: 36, height: 36)
                        .background(PremiumColors.neonCyan)
                        .clipShape(Circle())
                }
            }
            
            if categoryMeals.isEmpty {
                Text("No data logged")
                    .font(PremiumFonts.caption)
                    .foregroundStyle(PremiumColors.midGray)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 0) {
                    ForEach(categoryMeals) { meal in
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                if let path = meal.imagePath, let uiImg = AIFoodVisionService.shared.loadMealImage(from: path) {
                                    Button {
                                        selectedMealPhoto = uiImg
                                    } label: {
                                        Image(uiImage: uiImg)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 48, height: 48)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(PremiumColors.glassBorder, lineWidth: 1))
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(meal.name)
                                        .font(PremiumFonts.body)
                                        .fontWeight(.bold)
                                        .foregroundStyle(PremiumColors.starkWhite)
                                    
                                    HStack(spacing: 8) {
                                        if meal.proteinGrams > 0 {
                                            Text("P:\(meal.proteinGrams)g")
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .foregroundStyle(pColor)
                                        }
                                        if meal.carbsGrams > 0 {
                                            Text("C:\(meal.carbsGrams)g")
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .foregroundStyle(cColor)
                                        }
                                        if meal.fatsGrams > 0 {
                                            Text("F:\(meal.fatsGrams)g")
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .foregroundStyle(fColor)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(meal.calories) kcal")
                                        .font(PremiumFonts.body)
                                        .fontWeight(.bold)
                                        .foregroundStyle(PremiumColors.starkWhite)
                                    
                                    HStack(spacing: 8) {
                                        Button {
                                            mealToEdit = meal
                                        } label: {
                                            Image(systemName: "pencil.circle.fill")
                                                .foregroundStyle(PremiumColors.midGray)
                                                .font(.system(size: 20))
                                        }
                                        
                                        Button {
                                            deleteMeal(meal)
                                        } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundStyle(Color.red)
                                                .font(.system(size: 20))
                                        }
                                    }
                                }
                            }
                            
                            // INLINE +/- QUANTITY STEPPER for this individual item
                            HStack {
                                Text("Quantity:")
                                    .font(PremiumFonts.caption)
                                    .foregroundStyle(PremiumColors.midGray)
                                
                                Spacer()
                                
                                HStack(spacing: 12) {
                                    Button {
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                        impactFeedback.impactOccurred()
                                        adjustLoggedMealQty(meal, delta: -1)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundStyle(meal.calories <= getBaseCalories(meal) ? PremiumColors.glassBorder : PremiumColors.starkWhite)
                                    }
                                    .disabled(meal.calories <= getBaseCalories(meal))
                                    
                                    Text("\(getCurrentQty(meal))")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(PremiumColors.starkWhite)
                                        .frame(width: 32)
                                        .multilineTextAlignment(.center)
                                    
                                    Button {
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                        impactFeedback.impactOccurred()
                                        adjustLoggedMealQty(meal, delta: 1)
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundStyle(PremiumColors.neonCyan)
                                    }
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(PremiumColors.glassBackground)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, 12)
                        
                        if meal.id != categoryMeals.last?.id {
                            Divider()
                                .background(PremiumColors.glassBorder)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(PremiumColors.glassBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Logged Meal Quantity Helpers
    
    private func getBaseCalories(_ meal: MealLog) -> Int {
        return max(1, meal.calories / max(1, getCurrentQty(meal)))
    }
    
    private func getCurrentQty(_ meal: MealLog) -> Int {
        return max(1, meal.calories / max(1, getStoredBaseCalories(meal)))
    }
    
    private func getStoredBaseCalories(_ meal: MealLog) -> Int {
        let key = "mealBase_\(meal.id.uuidString)"
        let stored = UserDefaults.standard.integer(forKey: key)
        if stored > 0 { return stored }
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

// MARK: - Edit Already Logged Meal Sheet
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
    
    var body: some View {
        ZStack {
            PremiumColors.deepBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Edit Log")
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
                            Text("Meal Name")
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
                            Text("Quantity Multiplier")
                                .font(PremiumFonts.caption)
                                .foregroundStyle(PremiumColors.midGray)
                            HStack {
                                Button {
                                    adjustQuantity(by: -0.5)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(PremiumColors.starkWhite)
                                }
                                Spacer()
                                Text(String(format: "%.1fx", quantityMultiplier))
                                    .font(PremiumFonts.headline)
                                    .foregroundStyle(PremiumColors.starkWhite)
                                Spacer()
                                Button {
                                    adjustQuantity(by: 0.5)
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(PremiumColors.neonCyan)
                                }
                            }
                            .padding(14)
                            .background(PremiumColors.glassBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
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
                            meal.name = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                            meal.calories = Int(caloriesInput) ?? meal.calories
                            meal.proteinGrams = Int(proteinInput) ?? meal.proteinGrams
                            meal.carbsGrams = Int(carbsInput) ?? meal.carbsGrams
                            meal.fatsGrams = Int(fatsInput) ?? meal.fatsGrams
                            try? modelContext.save()
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
                    .padding()
                }
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
    
    var body: some View {
        ZStack {
            PremiumColors.deepBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Targets")
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
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Energy Target (KCAL)")
                            .font(PremiumFonts.caption)
                            .foregroundStyle(PremiumColors.midGray)
                        TextField("2200", text: $calsText)
                            .keyboardType(.numbersAndPunctuation)
                            .font(PremiumFonts.headline)
                            .padding(14)
                            .background(PremiumColors.glassBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(PremiumColors.starkWhite)
                    }
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Protein (g)")
                                .font(PremiumFonts.caption)
                                .foregroundStyle(PremiumColors.neonCyan)
                            TextField("160", text: $proteinText)
                                .keyboardType(.numbersAndPunctuation)
                                .font(PremiumFonts.headline)
                                .padding(14)
                                .background(PremiumColors.glassBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(PremiumColors.starkWhite)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Carbs (g)")
                                .font(PremiumFonts.caption)
                                .foregroundStyle(PremiumColors.starkWhite)
                            TextField("220", text: $carbsText)
                                .keyboardType(.numbersAndPunctuation)
                                .font(PremiumFonts.headline)
                                .padding(14)
                                .background(PremiumColors.glassBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(PremiumColors.starkWhite)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Fats (g)")
                                .font(PremiumFonts.caption)
                                .foregroundStyle(PremiumColors.midGray)
                            TextField("70", text: $fatsText)
                                .keyboardType(.numbersAndPunctuation)
                                .font(PremiumFonts.headline)
                                .padding(14)
                                .background(PremiumColors.glassBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(PremiumColors.starkWhite)
                        }
                    }
                    
                    Button {
                        goal.targetCalories = Int(calsText) ?? goal.targetCalories
                        goal.targetProtein = Int(proteinText) ?? goal.targetProtein
                        goal.targetCarbs = Int(carbsText) ?? goal.targetCarbs
                        goal.targetFats = Int(fatsText) ?? goal.targetFats
                        try? modelContext.save()
                        dismiss()
                    } label: {
                        Text("Save Targets")
                            .font(PremiumFonts.headline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(PremiumColors.neonCyan)
                            .foregroundStyle(PremiumColors.deepBlack)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 10)
                    Spacer()
                }
                .padding(20)
            }
        }
        .onAppear {
            calsText = "\(goal.targetCalories)"
            proteinText = "\(goal.targetProtein)"
            carbsText = "\(goal.targetCarbs)"
            fatsText = "\(goal.targetFats)"
        }
    }
}

// MARK: - Identifiable Image Wrapper
struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

