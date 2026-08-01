import Foundation
import SwiftData

// MARK: - GymMachine

@Model
final class GymMachine {
    var id: UUID
    var name: String
    var category: String
    var targetMuscles: [String]
    var instructions: String
    var videoURL: String?
    var imageURL: String?
    var isCustom: Bool
    var equipmentType: String

    @Relationship(inverse: \SplitMachineEntry.machine)
    var splitEntries: [SplitMachineEntry]

    init(name: String, category: String, targetMuscles: [String] = [], instructions: String = "", videoURL: String? = nil, imageURL: String? = nil, isCustom: Bool = false, equipmentType: String = "Barbell") {
        self.id = UUID()
        self.name = name
        self.category = category
        self.targetMuscles = targetMuscles
        self.instructions = instructions
        self.videoURL = videoURL
        self.imageURL = imageURL
        self.isCustom = isCustom
        self.equipmentType = equipmentType
        self.splitEntries = []
    }
}

// MARK: - WorkoutSplit

@Model
final class WorkoutSplit {
    var id: UUID
    var name: String
    var status: String

    @Relationship(deleteRule: .cascade, inverse: \SplitMachineEntry.split)
    var entries: [SplitMachineEntry]

    @Relationship(inverse: \WeeklySchedule.assignedSplit)
    var scheduleEntries: [WeeklySchedule]

    init(name: String, status: String = "Active") {
        self.id = UUID()
        self.name = name
        self.status = status
        self.entries = []
        self.scheduleEntries = []
    }
}

// MARK: - SplitMachineEntry (Join Model)

@Model
final class SplitMachineEntry {
    var id: UUID
    var order: Int
    var defaultSets: Int
    var defaultReps: Int
    var defaultWeight: Double

    var machine: GymMachine?
    var split: WorkoutSplit?

    init(order: Int, defaultSets: Int, defaultReps: Int, defaultWeight: Double = 0.0, machine: GymMachine? = nil) {
        self.id = UUID()
        self.order = order
        self.defaultSets = defaultSets
        self.defaultReps = defaultReps
        self.defaultWeight = defaultWeight
        self.machine = machine
    }
}

// MARK: - WeeklySchedule

@Model
final class WeeklySchedule {
    var id: UUID
    var dayOfWeek: Int
    var dayName: String
    var assignedSplit: WorkoutSplit?

    init(dayOfWeek: Int, dayName: String, assignedSplit: WorkoutSplit? = nil) {
        self.id = UUID()
        self.dayOfWeek = dayOfWeek
        self.dayName = dayName
        self.assignedSplit = assignedSplit
    }
}

// MARK: - WorkoutSession

@Model
final class WorkoutSession {
    var id: UUID
    var date: Date
    var splitName: String
    var isCompleted: Bool
    var duration: Double

    @Relationship(deleteRule: .cascade, inverse: \SetLog.session)
    var setLogs: [SetLog]

    init(splitName: String, date: Date = .now) {
        self.id = UUID()
        self.date = date
        self.splitName = splitName
        self.isCompleted = false
        self.duration = 0
        self.setLogs = []
    }
}

// MARK: - SetLog

@Model
final class SetLog {
    var id: UUID
    var setNumber: Int
    var reps: Int
    var weight: Double
    var machineName: String
    var machineId: UUID?
    var equipmentType: String

    var session: WorkoutSession?

    init(setNumber: Int, reps: Int, weight: Double, machineName: String = "", machineId: UUID? = nil, equipmentType: String = "Barbell") {
        self.id = UUID()
        self.setNumber = setNumber
        self.reps = reps
        self.weight = weight
        self.machineName = machineName
        self.machineId = machineId
        self.equipmentType = equipmentType
    }
}

// MARK: - BodyWeightEntry

@Model
final class BodyWeightEntry {
    var id: UUID
    var date: Date
    var weight: Double
    var unit: String

    init(weight: Double, unit: String = "kg", date: Date = .now) {
        self.id = UUID()
        self.date = date
        self.weight = weight
        self.unit = unit
    }
}

// MARK: - UserStats

@Model
final class UserStats {
    var id: UUID
    var streakCount: Int
    var dailySteps: Int

    init(streakCount: Int = 0, dailySteps: Int = 0) {
        self.id = UUID()
        self.streakCount = streakCount
        self.dailySteps = dailySteps
    }
}

// MARK: - CardioLog

@Model
final class CardioLog {
    var id: UUID
    var date: Date
    var activityType: String
    var durationMinutes: Double
    var distanceKm: Double
    var caloriesBurned: Int
    var notes: String

    init(activityType: String = "Treadmill Run", durationMinutes: Double = 25.0, distanceKm: Double = 0.0, caloriesBurned: Int = 0, notes: String = "", date: Date = .now) {
        self.id = UUID()
        self.date = date
        self.activityType = activityType
        self.durationMinutes = durationMinutes
        self.distanceKm = distanceKm
        self.caloriesBurned = caloriesBurned
        self.notes = notes
    }
}

// MARK: - NutritionGoal

@Model
final class NutritionGoal {
    var id: UUID
    var targetCalories: Int
    var targetProtein: Int
    var targetCarbs: Int
    var targetFats: Int

    init(targetCalories: Int = 2200, targetProtein: Int = 160, targetCarbs: Int = 220, targetFats: Int = 70) {
        self.id = UUID()
        self.targetCalories = targetCalories
        self.targetProtein = targetProtein
        self.targetCarbs = targetCarbs
        self.targetFats = targetFats
    }
}

// MARK: - MealLog

@Model
final class MealLog {
    var id: UUID
    var date: Date
    var name: String
    var mealType: String // "Breakfast", "Lunch", "Dinner", "Snack"
    var calories: Int
    var proteinGrams: Int
    var carbsGrams: Int
    var fatsGrams: Int
    var imagePath: String?

    init(name: String, mealType: String = "Breakfast", calories: Int = 0, proteinGrams: Int = 0, carbsGrams: Int = 0, fatsGrams: Int = 0, imagePath: String? = nil, date: Date = .now) {
        self.id = UUID()
        self.date = date
        self.name = name
        self.mealType = mealType
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatsGrams = fatsGrams
        self.imagePath = imagePath
    }
}
