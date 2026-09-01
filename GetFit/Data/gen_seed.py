import json
import random

categories = {
    "Push": [
        "Flat Bench Press", "Incline Dumbbell Press", "Decline Bench Press", "Machine Chest Press", 
        "Pec Deck Flye", "Cable Crossover", "Push-Ups", "Dumbbell Pullover", "Incline Barbell Press",
        "Smith Machine Bench Press", "Incline Cable Flye", "Dumbbell Floor Press", "Spoto Press",
        "Overhead Press", "Dumbbell Shoulder Press", "Arnold Press", "Lateral Raises", 
        "Front Raises", "Machine Shoulder Press", "Upright Row", "Cable Lateral Raises",
        "Smith Machine Overhead Press", "Plate Front Raise", "Landmine Press", "Push Press",
        "Tricep Pushdown", "Skull Crushers", "Dips", "Overhead Tricep Extension", "Close-Grip Bench Press",
        "Rope Tricep Pushdown", "Kickbacks", "JM Press", "Diamond Push-Ups", "Machine Tricep Extension",
        "Cable Overhead Extension", "Tate Press", "Single-Arm Cable Pushdown", "Bench Dips"
    ],
    "Pull": [
        "Deadlift", "Barbell Row", "Lat Pulldown", "Seated Cable Row", "Face Pulls", 
        "Pull-Ups", "Chin-Ups", "T-Bar Row", "Meadows Row", "Single-Arm Dumbbell Row",
        "Straight-Arm Pulldown", "Pendlay Row", "Chest-Supported Row", "Rack Pulls",
        "Reverse Pec Deck", "Cable Face Pulls", "Renegade Row", "Machine Row", "V-Bar Pulldown",
        "Underhand Lat Pulldown", "Wide-Grip Cable Row", "Inverted Row", "Seal Row",
        "Bicep Curl", "Dumbbell Curl", "Barbell Curl", "Hammer Curl", "Preacher Curl",
        "Concentration Curl", "Cable Curl", "EZ-Bar Curl", "Reverse Curl", "Spider Curl",
        "Incline Dumbbell Curl", "Zottman Curl", "Drag Curl", "Machine Bicep Curl",
        "High Cable Curl", "Cross-Body Hammer Curl", "Plate Curl", "Bayesian Curl"
    ],
    "Legs": [
        "Barbell Squat", "Leg Press", "Romanian Deadlift", "Leg Curl", "Leg Extension",
        "Bulgarian Split Squat", "Calf Raises", "Hip Thrust", "Hack Squat", "Pendulum Squat",
        "Front Squat", "Goblet Squat", "Lunges", "Walking Lunges", "Sumo Deadlift",
        "Stiff-Legged Deadlift", "Good Mornings", "Glute Ham Raise", "Sissy Squat",
        "Seated Calf Raise", "Donkey Calf Raise", "Standing Calf Raise", "Leg Press Calf Raise",
        "Glute Kickbacks", "Cable Pull-Through", "Hip Abductor Machine", "Hip Adductor Machine",
        "Step-Ups", "Box Jumps", "Pistol Squat", "Jefferson Squat", "Zercher Squat",
        "Smith Machine Squat", "Belt Squat", "Reverse Lunges", "Curtsy Lunges", "Nordic Hamstring Curl",
        "Single-Leg Press", "Single-Leg Leg Curl", "Single-Leg Leg Extension"
    ],
    "Core": [
        "Cable Crunches", "Hanging Leg Raise", "Plank", "Russian Twist", "Ab Wheel Rollout",
        "Bicycle Crunches", "Decline Crunches", "Toe Touches", "V-Ups", "Flutter Kicks",
        "Mountain Climbers", "Side Plank", "Woodchoppers", "Pallof Press", "Dragon Flag",
        "Hollow Body Hold", "Dead Bug", "L-Sit", "Sit-Ups", "Crunch Machine",
        "Reverse Crunches", "Oblique Crunches", "Windshield Wipers", "Hanging Knee Raise",
        "Captain's Chair Leg Raise", "Medicine Ball Slams", "Kettlebell Swings", "Suitcase Carry",
        "Farmer's Walk", "Turkish Get-Up"
    ]
}

equipments = ["Barbell", "Dumbbell", "Cable", "Machine", "Bodyweight", "Kettlebell"]

muscles_push = ["Chest", "Front Delt", "Triceps", "Upper Chest", "Lower Chest", "Lateral Delt"]
muscles_pull = ["Lats", "Rhomboids", "Rear Delt", "Biceps", "Forearms", "Mid Back", "Traps", "Lower Back"]
muscles_legs = ["Quads", "Glutes", "Hamstrings", "Calves", "Adductors", "Abductors"]
muscles_core = ["Abs", "Obliques", "Core", "Lower Abs", "Hip Flexors"]

swift_lines = []
swift_lines.append("import Foundation")
swift_lines.append("import SwiftData\n")
swift_lines.append("struct SeedData {")

# Generate instances
instances = []

def make_instructions(ex):
    return f'"1. Set up properly for {ex}.\\n2. Engage the target muscles.\\n3. Perform the concentric phase with control.\\n4. Perform the eccentric phase slowly.\\n5. Repeat for desired reps."'

for cat, ex_list in categories.items():
    for ex in ex_list:
        var_name = "".join(x.capitalize() for x in ex.replace("-", " ").replace("'", "").split(" "))
        var_name = var_name[0].lower() + var_name[1:]
        
        eq = random.choice(equipments)
        if cat == "Push": m = random.sample(muscles_push, random.randint(1, 3))
        elif cat == "Pull": m = random.sample(muscles_pull, random.randint(1, 3))
        elif cat == "Legs": m = random.sample(muscles_legs, random.randint(1, 3))
        else: m = random.sample(muscles_core, random.randint(1, 3))
        
        m_str = "[" + ", ".join(f'"{x}"' for x in m) + "]"
        
        steps = make_instructions(ex)
        
        line = f'    static let {var_name} = GymMachine(name: "{ex}", category: "{cat}", targetMuscles: {m_str}, instructions: {steps}, videoURL: nil, isCustom: false, equipmentType: "{eq}")'
        instances.append((var_name, line))

# Write instances
for v, line in instances:
    swift_lines.append(line)

# Write allDefaultMachines
swift_lines.append("\n    static let allDefaultMachines: [GymMachine] = [")
swift_lines.append("        " + ",\n        ".join(v for v, _ in instances))
swift_lines.append("    ]\n")

# Write syncExercisesIfNeeded
swift_lines.append("    static func syncExercisesIfNeeded(context: ModelContext) {")
swift_lines.append("        let descriptor = FetchDescriptor<GymMachine>()")
swift_lines.append("        let existing = (try? context.fetch(descriptor)) ?? []")
swift_lines.append("        let existingNames = Set(existing.map { $0.name })")
swift_lines.append("        for machine in allDefaultMachines {")
swift_lines.append("            if !existingNames.contains(machine.name) {")
swift_lines.append("                context.insert(machine)")
swift_lines.append("            }")
swift_lines.append("        }")
swift_lines.append("        try? context.save()")
swift_lines.append("    }\n")

# Write seedIfNeeded
swift_lines.append("""    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<UserStats>()
        let existingStats = (try? context.fetch(descriptor)) ?? []
        guard existingStats.isEmpty else { 
            syncExercisesIfNeeded(context: context)
            return 
        }

        // UserStats
        let stats = UserStats(streakCount: 12, dailySteps: 8420)
        context.insert(stats)
        
        syncExercisesIfNeeded(context: context)

        // Splits
        let pushDay = WorkoutSplit(name: "Push Day", status: "Active")
        let pullDay = WorkoutSplit(name: "Pull Day", status: "Active")
        let legDay = WorkoutSplit(name: "Leg Day", status: "Active")
        let coreDay = WorkoutSplit(name: "Core Day", status: "In Development")

        context.insert(pushDay)
        context.insert(pullDay)
        context.insert(legDay)
        context.insert(coreDay)

        // Entries
        let pushEntries = [
            SplitMachineEntry(order: 0, defaultSets: 4, defaultReps: 8, machine: flatBenchPress),
            SplitMachineEntry(order: 1, defaultSets: 4, defaultReps: 10, machine: inclineDumbbellPress),
            SplitMachineEntry(order: 2, defaultSets: 3, defaultReps: 12, machine: cableCrossover)
        ]
        for entry in pushEntries {
            entry.split = pushDay
            context.insert(entry)
        }

        let pullEntries = [
            SplitMachineEntry(order: 0, defaultSets: 4, defaultReps: 6, machine: deadlift),
            SplitMachineEntry(order: 1, defaultSets: 4, defaultReps: 8, machine: barbellRow)
        ]
        for entry in pullEntries {
            entry.split = pullDay
            context.insert(entry)
        }

        let legEntries = [
            SplitMachineEntry(order: 0, defaultSets: 4, defaultReps: 8, machine: barbellSquat),
            SplitMachineEntry(order: 1, defaultSets: 4, defaultReps: 10, machine: legPress)
        ]
        for entry in legEntries {
            entry.split = legDay
            context.insert(entry)
        }

        let coreEntries = [
            SplitMachineEntry(order: 0, defaultSets: 3, defaultReps: 15, machine: cableCrunches),
            SplitMachineEntry(order: 1, defaultSets: 3, defaultReps: 12, machine: hangingLegRaise)
        ]
        for entry in coreEntries {
            entry.split = coreDay
            context.insert(entry)
        }

        // Weekly Schedule
        let monday = WeeklySchedule(dayOfWeek: 1, dayName: "Monday", assignedSplit: pushDay)
        let tuesday = WeeklySchedule(dayOfWeek: 2, dayName: "Tuesday", assignedSplit: pullDay)
        let wednesday = WeeklySchedule(dayOfWeek: 3, dayName: "Wednesday", assignedSplit: nil)
        let thursday = WeeklySchedule(dayOfWeek: 4, dayName: "Thursday", assignedSplit: legDay)
        let friday = WeeklySchedule(dayOfWeek: 5, dayName: "Friday", assignedSplit: pushDay)
        let saturday = WeeklySchedule(dayOfWeek: 6, dayName: "Saturday", assignedSplit: pullDay)
        let sunday = WeeklySchedule(dayOfWeek: 7, dayName: "Sunday", assignedSplit: nil)

        let week = [monday, tuesday, wednesday, thursday, friday, saturday, sunday]
        for day in week {
            context.insert(day)
        }

        try? context.save()
    }
}
""")

out = ""
for line in swift_lines:
    out += line + "\\n"

with open("/Users/tarungs/PERSONAL/Get_Fit/GetFit/Data/SeedData.swift", "w") as f:
    f.write(out)
