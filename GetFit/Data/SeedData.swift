import Foundation
import SwiftData

struct SeedData {
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<UserStats>()
        let existingStats = (try? context.fetch(descriptor)) ?? []
        guard existingStats.isEmpty else { return }

        // UserStats
        let stats = UserStats(streakCount: 12, dailySteps: 8420)
        context.insert(stats)

        // Push Exercises
        let flatBenchPress = GymMachine(name: "Flat Bench Press", category: "Push", targetMuscles: ["Chest", "Front Delt", "Triceps"], instructions: "1. Lie flat on the bench with feet planted.\n2. Grip bar slightly wider than shoulder-width.\n3. Lower bar to mid-chest with elbows at 45 degrees.\n4. Press up explosively to full extension.\n5. Keep shoulder blades retracted throughout.", videoURL: "https://www.youtube.com/watch?v=rT7DgCr-3pg", imageURL: "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=800&auto=format&fit=crop", isCustom: false, equipmentType: "Barbell")
        let inclineDumbbellPress = GymMachine(name: "Incline Dumbbell Press", category: "Push", targetMuscles: ["Upper Chest", "Front Delt", "Triceps"], instructions: "1. Set the bench to a 30-45 degree incline.\n2. Hold dumbbells at shoulder level with palms facing forward.\n3. Press the dumbbells upward until arms are fully extended.\n4. Lower slowly to the starting position with control.\n5. Keep your back flat against the bench at all times.", videoURL: nil, isCustom: false, equipmentType: "Dumbbell")
        let cableFlyes = GymMachine(name: "Cable Flyes", category: "Push", targetMuscles: ["Chest", "Front Delt"], instructions: "1. Set the pulleys to the highest position on both sides.\n2. Step forward with a slight lean and grab both handles.\n3. With a slight bend in your elbows, bring your hands together in front of your chest.\n4. Slowly return to the starting position feeling the stretch.\n5. Maintain the same elbow angle throughout the movement.", videoURL: nil, isCustom: false, equipmentType: "Cable")
        let machineChestPress = GymMachine(name: "Machine Chest Press", category: "Push", targetMuscles: ["Chest", "Triceps"], instructions: "1. Adjust the seat so handles align with your mid-chest.\n2. Grip the handles with feet flat on the floor.\n3. Press forward until arms are fully extended.\n4. Return slowly to the starting position.\n5. Keep your back pressed firmly against the pad.", videoURL: nil, isCustom: false, equipmentType: "Machine")
        let overheadPress = GymMachine(name: "Overhead Press", category: "Push", targetMuscles: ["Front Delt", "Lateral Delt", "Triceps"], instructions: "1. Stand with feet shoulder-width apart, bar at collarbone height.\n2. Grip the bar just outside shoulder width.\n3. Press the bar overhead until arms are fully locked out.\n4. Lower the bar back to collarbone height with control.\n5. Engage your core and avoid excessive arching.", videoURL: "https://www.youtube.com/watch?v=2yjwXTZQDDI", isCustom: false, equipmentType: "Barbell")
        let dumbbellShoulderPress = GymMachine(name: "Dumbbell Shoulder Press", category: "Push", targetMuscles: ["Front Delt", "Lateral Delt", "Triceps"], instructions: "1. Sit on a bench with back support, dumbbells at shoulder height.\n2. Press both dumbbells overhead until arms are extended.\n3. Lower the dumbbells back to shoulder level.\n4. Keep your core engaged and back flat against the pad.\n5. Avoid flaring your elbows out too wide.", videoURL: nil, isCustom: false, equipmentType: "Dumbbell")
        let lateralRaises = GymMachine(name: "Lateral Raises", category: "Push", targetMuscles: ["Lateral Delt"], instructions: "1. Stand with dumbbells at your sides, slight bend in elbows.\n2. Raise both arms out to the sides until parallel with the floor.\n3. Pause briefly at the top of the movement.\n4. Lower slowly back to the starting position.\n5. Avoid swinging or using momentum to lift.", videoURL: nil, isCustom: false, equipmentType: "Dumbbell")
        let tricepPushdown = GymMachine(name: "Tricep Pushdown", category: "Push", targetMuscles: ["Triceps"], instructions: "1. Attach a straight bar or rope to the high pulley.\n2. Grip the attachment with palms facing down.\n3. Push the bar down until your arms are fully extended.\n4. Slowly return to the starting position.\n5. Keep your elbows pinned to your sides throughout.", videoURL: nil, isCustom: false, equipmentType: "Cable")
        let skullCrushers = GymMachine(name: "Skull Crushers", category: "Push", targetMuscles: ["Triceps"], instructions: "1. Lie on a flat bench holding an EZ bar with arms extended above your chest.\n2. Lower the bar toward your forehead by bending at the elbows.\n3. Keep your upper arms stationary throughout.\n4. Extend your arms back to the starting position.\n5. Use a controlled tempo and avoid flaring elbows.", videoURL: nil, isCustom: false, equipmentType: "Barbell")
        let dips = GymMachine(name: "Dips", category: "Push", targetMuscles: ["Chest", "Triceps", "Front Delt"], instructions: "1. Grip the parallel bars and lift yourself to the starting position.\n2. Lean slightly forward to target the chest.\n3. Lower your body until your upper arms are parallel to the floor.\n4. Press back up to the starting position.\n5. Keep your core tight and avoid swinging.", videoURL: nil, isCustom: false, equipmentType: "Bodyweight")

        // Pull Exercises
        let deadlift = GymMachine(name: "Deadlift", category: "Pull", targetMuscles: ["Back", "Glutes", "Hamstrings"], instructions: "1. Stand with feet hip-width apart, bar over mid-foot.\n2. Hinge at the hips and grip the bar just outside your knees.\n3. Drive through your heels and extend your hips and knees simultaneously.\n4. Stand tall at the top with shoulders back.\n5. Lower the bar by hinging at the hips first, then bending the knees.", videoURL: "https://www.youtube.com/watch?v=op9kVnSso6Q", isCustom: false, equipmentType: "Barbell")
        let barbellRow = GymMachine(name: "Barbell Row", category: "Pull", targetMuscles: ["Lats", "Rhomboids", "Rear Delt"], instructions: "1. Stand with feet shoulder-width, hinge forward at about 45 degrees.\n2. Grip the bar slightly wider than shoulder width.\n3. Pull the bar toward your lower chest, squeezing your shoulder blades.\n4. Lower the bar with control back to arm's length.\n5. Keep your core braced and back flat throughout.", videoURL: nil, isCustom: false, equipmentType: "Barbell")
        let latPulldown = GymMachine(name: "Lat Pulldown", category: "Pull", targetMuscles: ["Lats", "Biceps"], instructions: "1. Sit with thighs secured under the pad, grip the bar wide.\n2. Pull the bar down to your upper chest, leading with your elbows.\n3. Squeeze your lats at the bottom of the movement.\n4. Slowly return the bar to the starting position.\n5. Avoid leaning too far back or using momentum.", videoURL: nil, isCustom: false, equipmentType: "Cable")
        let seatedCableRow = GymMachine(name: "Seated Cable Row", category: "Pull", targetMuscles: ["Mid Back", "Lats", "Rear Delt"], instructions: "1. Sit with feet on the platform, knees slightly bent.\n2. Grip the handle and sit upright with arms extended.\n3. Pull the handle toward your torso, squeezing your shoulder blades together.\n4. Slowly extend arms back to the starting position.\n5. Maintain an upright posture and avoid rounding your back.", videoURL: nil, isCustom: false, equipmentType: "Cable")
        let facePulls = GymMachine(name: "Face Pulls", category: "Pull", targetMuscles: ["Rear Delt", "Rotator Cuff"], instructions: "1. Set the cable pulley to upper chest height with a rope attachment.\n2. Grip the rope with thumbs pointing back.\n3. Pull toward your face, separating the rope ends past your ears.\n4. Squeeze your rear delts and hold briefly.\n5. Return to start with control, keeping elbows high.", videoURL: nil, isCustom: false, equipmentType: "Cable")
        let dumbbellCurl = GymMachine(name: "Dumbbell Curl", category: "Pull", targetMuscles: ["Biceps"], instructions: "1. Stand with dumbbells at your sides, palms facing forward.\n2. Curl both dumbbells up toward your shoulders.\n3. Squeeze your biceps at the top of the movement.\n4. Lower slowly back to the starting position.\n5. Keep your elbows stationary at your sides.", videoURL: "https://www.youtube.com/shorts/in7PaeYlhrM", isCustom: false, equipmentType: "Dumbbell")
        let barbellCurl = GymMachine(name: "Barbell Curl", category: "Pull", targetMuscles: ["Biceps", "Forearms"], instructions: "1. Stand with feet shoulder-width, grip the barbell underhand.\n2. Curl the bar upward toward your chest.\n3. Squeeze your biceps hard at the top.\n4. Lower the bar with a slow, controlled tempo.\n5. Avoid swinging your torso or using momentum.", videoURL: nil, isCustom: false, equipmentType: "Barbell")
        let hammerCurl = GymMachine(name: "Hammer Curl", category: "Pull", targetMuscles: ["Brachialis", "Biceps", "Forearms"], instructions: "1. Stand with dumbbells at your sides, palms facing your body.\n2. Curl the dumbbells up while keeping palms facing inward.\n3. Squeeze at the top of the movement.\n4. Lower with control back to the starting position.\n5. Maintain a neutral wrist position throughout.", videoURL: nil, isCustom: false, equipmentType: "Dumbbell")
        let pullUps = GymMachine(name: "Pull-Ups", category: "Pull", targetMuscles: ["Lats", "Biceps", "Core"], instructions: "1. Grip the bar with hands slightly wider than shoulder width, palms facing away.\n2. Hang with arms fully extended.\n3. Pull yourself up until your chin clears the bar.\n4. Lower yourself with control back to full arm extension.\n5. Avoid kipping or swinging for momentum.", videoURL: nil, isCustom: false, equipmentType: "Bodyweight")
        let reverseFlyes = GymMachine(name: "Reverse Flyes", category: "Pull", targetMuscles: ["Rear Delt", "Rhomboids"], instructions: "1. Bend forward at the waist, holding dumbbells with arms hanging down.\n2. Raise both arms out to the sides with a slight elbow bend.\n3. Squeeze your shoulder blades together at the top.\n4. Lower slowly back to the starting position.\n5. Keep your back flat and core engaged.", videoURL: nil, isCustom: false, equipmentType: "Dumbbell")

        // Legs Exercises
        let barbellSquat = GymMachine(name: "Barbell Squat", category: "Legs", targetMuscles: ["Quads", "Glutes", "Core"], instructions: "1. Position the bar on your upper traps, feet shoulder-width apart.\n2. Brace your core and unrack the bar.\n3. Descend by pushing your hips back and bending your knees.\n4. Go to parallel or below, then drive up through your heels.\n5. Keep your chest up and knees tracking over your toes.", videoURL: "https://www.youtube.com/watch?v=gcNh17Ckjgg", isCustom: false, equipmentType: "Barbell")
        let legPress = GymMachine(name: "Leg Press", category: "Legs", targetMuscles: ["Quads", "Glutes"], instructions: "1. Sit in the leg press with your back flat against the pad.\n2. Place feet shoulder-width apart on the platform.\n3. Lower the platform by bending your knees toward your chest.\n4. Press back up until legs are nearly extended.\n5. Do not lock out your knees at the top.", videoURL: nil, isCustom: false, equipmentType: "Machine")
        let romanianDeadlift = GymMachine(name: "Romanian Deadlift", category: "Legs", targetMuscles: ["Hamstrings", "Glutes", "Lower Back"], instructions: "1. Stand with feet hip-width, holding the bar at thigh level.\n2. Hinge at the hips, pushing them backward.\n3. Lower the bar along your legs until you feel a deep hamstring stretch.\n4. Drive your hips forward to return to standing.\n5. Keep the bar close to your body and maintain a flat back.", videoURL: nil, isCustom: false, equipmentType: "Barbell")
        let legCurl = GymMachine(name: "Leg Curl", category: "Legs", targetMuscles: ["Hamstrings"], instructions: "1. Lie face down on the leg curl machine, pad above your heels.\n2. Curl your heels toward your glutes.\n3. Squeeze your hamstrings at the top.\n4. Lower slowly back to the starting position.\n5. Avoid lifting your hips off the pad.", videoURL: nil, isCustom: false, equipmentType: "Machine")
        let legExtension = GymMachine(name: "Leg Extension", category: "Legs", targetMuscles: ["Quads"], instructions: "1. Sit on the machine with your back against the pad.\n2. Hook your ankles under the roller pad.\n3. Extend your legs until fully straightened.\n4. Squeeze your quads at the top.\n5. Lower back with control, stopping before the weight stack touches.", videoURL: nil, isCustom: false, equipmentType: "Machine")
        let bulgarianSplitSquat = GymMachine(name: "Bulgarian Split Squat", category: "Legs", targetMuscles: ["Quads", "Glutes"], instructions: "1. Stand a couple feet in front of a bench, place one foot behind you on it.\n2. Hold dumbbells at your sides.\n3. Lower your back knee toward the floor.\n4. Push through your front heel to return to standing.\n5. Keep your torso upright and front knee over your toes.", videoURL: nil, isCustom: false, equipmentType: "Dumbbell")
        let calfRaises = GymMachine(name: "Calf Raises", category: "Legs", targetMuscles: ["Calves"], instructions: "1. Stand on the edge of a step or calf raise machine.\n2. Lower your heels below the platform for a full stretch.\n3. Push up onto your toes as high as possible.\n4. Squeeze your calves at the top.\n5. Lower slowly back to the stretched position.", videoURL: nil, isCustom: false, equipmentType: "Machine")
        let hipThrust = GymMachine(name: "Hip Thrust", category: "Legs", targetMuscles: ["Glutes", "Hamstrings"], instructions: "1. Sit on the floor with your upper back against a bench, barbell over your hips.\n2. Plant feet flat, shoulder-width apart.\n3. Drive through your heels, lifting your hips until your body forms a straight line.\n4. Squeeze your glutes hard at the top.\n5. Lower your hips back down with control.", videoURL: nil, isCustom: false, equipmentType: "Barbell")

        // Core Exercises
        let cableCrunches = GymMachine(name: "Cable Crunches", category: "Core", targetMuscles: ["Abs"], instructions: "1. Kneel in front of a high pulley with rope attachment.\n2. Hold the rope behind your head.\n3. Crunch downward, bringing your elbows toward your knees.\n4. Squeeze your abs at the bottom.\n5. Return to the starting position with control.", videoURL: nil, isCustom: false, equipmentType: "Cable")
        let hangingLegRaise = GymMachine(name: "Hanging Leg Raise", category: "Core", targetMuscles: ["Lower Abs", "Hip Flexors"], instructions: "1. Hang from a pull-up bar with arms fully extended.\n2. Keep your legs straight and raise them to hip height or above.\n3. Pause at the top and squeeze your abs.\n4. Lower your legs slowly back to hanging.\n5. Avoid swinging or using momentum.", videoURL: nil, isCustom: false, equipmentType: "Bodyweight")
        let plank = GymMachine(name: "Plank", category: "Core", targetMuscles: ["Core", "Shoulders"], instructions: "1. Start in a forearm plank position, elbows under shoulders.\n2. Keep your body in a straight line from head to heels.\n3. Engage your core and squeeze your glutes.\n4. Hold the position for the prescribed duration.\n5. Avoid letting your hips sag or pike up.", videoURL: nil, isCustom: false, equipmentType: "Bodyweight")
        let russianTwist = GymMachine(name: "Russian Twist", category: "Core", targetMuscles: ["Obliques", "Core"], instructions: "1. Sit on the floor with knees bent, lean back slightly.\n2. Hold a weight or medicine ball at your chest.\n3. Rotate your torso to one side, bringing the weight beside your hip.\n4. Rotate to the opposite side in a controlled motion.\n5. Keep your feet off the floor for added difficulty.", videoURL: nil, isCustom: false, equipmentType: "Dumbbell")

        let allMachines = [
            flatBenchPress, inclineDumbbellPress, cableFlyes, machineChestPress, overheadPress, dumbbellShoulderPress, lateralRaises, tricepPushdown, skullCrushers, dips,
            deadlift, barbellRow, latPulldown, seatedCableRow, facePulls, dumbbellCurl, barbellCurl, hammerCurl, pullUps, reverseFlyes,
            barbellSquat, legPress, romanianDeadlift, legCurl, legExtension, bulgarianSplitSquat, calfRaises, hipThrust,
            cableCrunches, hangingLegRaise, plank, russianTwist
        ]

        for machine in allMachines {
            context.insert(machine)
        }

        // Splits
        let pushDay = WorkoutSplit(name: "Push Day", status: "Active")
        let pullDay = WorkoutSplit(name: "Pull Day", status: "Active")
        let legDay = WorkoutSplit(name: "Leg Day", status: "Active")
        let coreDay = WorkoutSplit(name: "Core Day", status: "In Development")

        context.insert(pushDay)
        context.insert(pullDay)
        context.insert(legDay)
        context.insert(coreDay)

        // Entries - Push Day
        let pushEntries = [
            SplitMachineEntry(order: 0, defaultSets: 4, defaultReps: 8, machine: flatBenchPress),
            SplitMachineEntry(order: 1, defaultSets: 4, defaultReps: 10, machine: inclineDumbbellPress),
            SplitMachineEntry(order: 2, defaultSets: 3, defaultReps: 12, machine: cableFlyes),
            SplitMachineEntry(order: 3, defaultSets: 4, defaultReps: 8, machine: machineChestPress),
            SplitMachineEntry(order: 4, defaultSets: 3, defaultReps: 10, machine: overheadPress),
            SplitMachineEntry(order: 5, defaultSets: 3, defaultReps: 10, machine: dumbbellShoulderPress),
            SplitMachineEntry(order: 6, defaultSets: 3, defaultReps: 15, machine: lateralRaises),
            SplitMachineEntry(order: 7, defaultSets: 4, defaultReps: 12, machine: tricepPushdown),
            SplitMachineEntry(order: 8, defaultSets: 3, defaultReps: 10, machine: skullCrushers),
            SplitMachineEntry(order: 9, defaultSets: 3, defaultReps: 12, machine: dips)
        ]
        for entry in pushEntries {
            entry.split = pushDay
            context.insert(entry)
        }

        // Entries - Pull Day
        let pullEntries = [
            SplitMachineEntry(order: 0, defaultSets: 4, defaultReps: 6, machine: deadlift),
            SplitMachineEntry(order: 1, defaultSets: 4, defaultReps: 8, machine: barbellRow),
            SplitMachineEntry(order: 2, defaultSets: 3, defaultReps: 10, machine: latPulldown),
            SplitMachineEntry(order: 3, defaultSets: 3, defaultReps: 12, machine: seatedCableRow),
            SplitMachineEntry(order: 4, defaultSets: 3, defaultReps: 15, machine: facePulls),
            SplitMachineEntry(order: 5, defaultSets: 3, defaultReps: 12, machine: dumbbellCurl),
            SplitMachineEntry(order: 6, defaultSets: 3, defaultReps: 10, machine: barbellCurl),
            SplitMachineEntry(order: 7, defaultSets: 3, defaultReps: 12, machine: hammerCurl),
            SplitMachineEntry(order: 8, defaultSets: 3, defaultReps: 8, machine: pullUps),
            SplitMachineEntry(order: 9, defaultSets: 3, defaultReps: 15, machine: reverseFlyes)
        ]
        for entry in pullEntries {
            entry.split = pullDay
            context.insert(entry)
        }

        // Entries - Leg Day
        let legEntries = [
            SplitMachineEntry(order: 0, defaultSets: 4, defaultReps: 8, machine: barbellSquat),
            SplitMachineEntry(order: 1, defaultSets: 4, defaultReps: 10, machine: legPress),
            SplitMachineEntry(order: 2, defaultSets: 3, defaultReps: 10, machine: romanianDeadlift),
            SplitMachineEntry(order: 3, defaultSets: 3, defaultReps: 12, machine: legCurl),
            SplitMachineEntry(order: 4, defaultSets: 3, defaultReps: 12, machine: legExtension),
            SplitMachineEntry(order: 5, defaultSets: 3, defaultReps: 10, machine: bulgarianSplitSquat),
            SplitMachineEntry(order: 6, defaultSets: 4, defaultReps: 15, machine: calfRaises),
            SplitMachineEntry(order: 7, defaultSets: 3, defaultReps: 12, machine: hipThrust)
        ]
        for entry in legEntries {
            entry.split = legDay
            context.insert(entry)
        }

        // Entries - Core Day
        let coreEntries = [
            SplitMachineEntry(order: 0, defaultSets: 3, defaultReps: 15, machine: cableCrunches),
            SplitMachineEntry(order: 1, defaultSets: 3, defaultReps: 12, machine: hangingLegRaise),
            SplitMachineEntry(order: 2, defaultSets: 3, defaultReps: 60, machine: plank),
            SplitMachineEntry(order: 3, defaultSets: 3, defaultReps: 20, machine: russianTwist)
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
