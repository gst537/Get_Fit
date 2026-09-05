import Foundation
import SwiftData

@MainActor
struct SeedData {
    static let flatBenchPress = GymMachine(name: "Flat Bench Press", category: .push, targetMuscles: ["Front Delt", "Lateral Delt", "Chest"], instructions: "1. Set up properly for Flat Bench Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let inclineDumbbellPress = GymMachine(name: "Incline Dumbbell Press", category: .push, targetMuscles: ["Triceps"], instructions: "1. Set up properly for Incline Dumbbell Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let declineBenchPress = GymMachine(name: "Decline Bench Press", category: .push, targetMuscles: ["Lateral Delt", "Chest"], instructions: "1. Set up properly for Decline Bench Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let machineChestPress = GymMachine(name: "Machine Chest Press", category: .push, targetMuscles: ["Triceps"], instructions: "1. Set up properly for Machine Chest Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let pecDeckFlye = GymMachine(name: "Pec Deck Flye", category: .push, targetMuscles: ["Front Delt", "Lower Chest", "Lateral Delt"], instructions: "1. Set up properly for Pec Deck Flye.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let cableCrossover = GymMachine(name: "Cable Crossover", category: .push, targetMuscles: ["Front Delt", "Triceps", "Chest"], instructions: "1. Set up properly for Cable Crossover.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let pushUps = GymMachine(name: "Push-Ups", category: .push, targetMuscles: ["Chest"], instructions: "1. Set up properly for Push-Ups.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let dumbbellPullover = GymMachine(name: "Dumbbell Pullover", category: .push, targetMuscles: ["Triceps"], instructions: "1. Set up properly for Dumbbell Pullover.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let inclineBarbellPress = GymMachine(name: "Incline Barbell Press", category: .push, targetMuscles: ["Chest", "Triceps", "Upper Chest"], instructions: "1. Set up properly for Incline Barbell Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let smithMachineBenchPress = GymMachine(name: "Smith Machine Bench Press", category: .push, targetMuscles: ["Upper Chest", "Front Delt"], instructions: "1. Set up properly for Smith Machine Bench Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let inclineCableFlye = GymMachine(name: "Incline Cable Flye", category: .push, targetMuscles: ["Lower Chest", "Front Delt", "Triceps"], instructions: "1. Set up properly for Incline Cable Flye.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let dumbbellFloorPress = GymMachine(name: "Dumbbell Floor Press", category: .push, targetMuscles: ["Triceps", "Chest"], instructions: "1. Set up properly for Dumbbell Floor Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let spotoPress = GymMachine(name: "Spoto Press", category: .push, targetMuscles: ["Triceps"], instructions: "1. Set up properly for Spoto Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let overheadPress = GymMachine(name: "Overhead Press", category: .push, targetMuscles: ["Upper Chest", "Lower Chest", "Front Delt"], instructions: "1. Set up properly for Overhead Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let dumbbellShoulderPress = GymMachine(name: "Dumbbell Shoulder Press", category: .push, targetMuscles: ["Triceps", "Upper Chest"], instructions: "1. Set up properly for Dumbbell Shoulder Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let arnoldPress = GymMachine(name: "Arnold Press", category: .push, targetMuscles: ["Front Delt", "Triceps"], instructions: "1. Set up properly for Arnold Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let lateralRaises = GymMachine(name: "Lateral Raises", category: .push, targetMuscles: ["Chest", "Lower Chest"], instructions: "1. Set up properly for Lateral Raises.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let frontRaises = GymMachine(name: "Front Raises", category: .push, targetMuscles: ["Upper Chest", "Triceps", "Lower Chest"], instructions: "1. Set up properly for Front Raises.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let machineShoulderPress = GymMachine(name: "Machine Shoulder Press", category: .push, targetMuscles: ["Upper Chest", "Lower Chest", "Front Delt"], instructions: "1. Set up properly for Machine Shoulder Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let uprightRow = GymMachine(name: "Upright Row", category: .push, targetMuscles: ["Front Delt", "Chest"], instructions: "1. Set up properly for Upright Row.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let cableLateralRaises = GymMachine(name: "Cable Lateral Raises", category: .push, targetMuscles: ["Triceps", "Lateral Delt"], instructions: "1. Set up properly for Cable Lateral Raises.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let smithMachineOverheadPress = GymMachine(name: "Smith Machine Overhead Press", category: .push, targetMuscles: ["Upper Chest", "Lower Chest"], instructions: "1. Set up properly for Smith Machine Overhead Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let plateFrontRaise = GymMachine(name: "Plate Front Raise", category: .push, targetMuscles: ["Triceps", "Lateral Delt", "Lower Chest"], instructions: "1. Set up properly for Plate Front Raise.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let landminePress = GymMachine(name: "Landmine Press", category: .push, targetMuscles: ["Lower Chest", "Chest", "Upper Chest"], instructions: "1. Set up properly for Landmine Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let pushPress = GymMachine(name: "Push Press", category: .push, targetMuscles: ["Chest"], instructions: "1. Set up properly for Push Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let tricepPushdown = GymMachine(name: "Tricep Pushdown", category: .push, targetMuscles: ["Lower Chest", "Front Delt", "Triceps"], instructions: "1. Set up properly for Tricep Pushdown.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let skullCrushers = GymMachine(name: "Skull Crushers", category: .push, targetMuscles: ["Front Delt", "Lower Chest", "Chest"], instructions: "1. Set up properly for Skull Crushers.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let dips = GymMachine(name: "Dips", category: .push, targetMuscles: ["Chest"], instructions: "1. Set up properly for Dips.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let overheadTricepExtension = GymMachine(name: "Overhead Tricep Extension", category: .push, targetMuscles: ["Lower Chest"], instructions: "1. Set up properly for Overhead Tricep Extension.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let closeGripBenchPress = GymMachine(name: "Close-Grip Bench Press", category: .push, targetMuscles: ["Lateral Delt", "Triceps"], instructions: "1. Set up properly for Close-Grip Bench Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let ropeTricepPushdown = GymMachine(name: "Rope Tricep Pushdown", category: .push, targetMuscles: ["Lower Chest"], instructions: "1. Set up properly for Rope Tricep Pushdown.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let kickbacks = GymMachine(name: "Kickbacks", category: .push, targetMuscles: ["Chest"], instructions: "1. Set up properly for Kickbacks.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let jmPress = GymMachine(name: "JM Press", category: .push, targetMuscles: ["Chest"], instructions: "1. Set up properly for JM Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let diamondPushUps = GymMachine(name: "Diamond Push-Ups", category: .push, targetMuscles: ["Chest", "Upper Chest", "Lateral Delt"], instructions: "1. Set up properly for Diamond Push-Ups.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let machineTricepExtension = GymMachine(name: "Machine Tricep Extension", category: .push, targetMuscles: ["Front Delt", "Chest"], instructions: "1. Set up properly for Machine Tricep Extension.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let cableOverheadExtension = GymMachine(name: "Cable Overhead Extension", category: .push, targetMuscles: ["Triceps"], instructions: "1. Set up properly for Cable Overhead Extension.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let tatePress = GymMachine(name: "Tate Press", category: .push, targetMuscles: ["Lateral Delt", "Upper Chest", "Lower Chest"], instructions: "1. Set up properly for Tate Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let singleArmCablePushdown = GymMachine(name: "Single-Arm Cable Pushdown", category: .push, targetMuscles: ["Triceps"], instructions: "1. Set up properly for Single-Arm Cable Pushdown.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let benchDips = GymMachine(name: "Bench Dips", category: .push, targetMuscles: ["Lower Chest"], instructions: "1. Set up properly for Bench Dips.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let deadlift = GymMachine(name: "Deadlift", category: .pull, targetMuscles: ["Rhomboids", "Biceps"], instructions: "1. Set up properly for Deadlift.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let barbellRow = GymMachine(name: "Barbell Row", category: .pull, targetMuscles: ["Rhomboids"], instructions: "1. Set up properly for Barbell Row.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let latPulldown = GymMachine(name: "Lat Pulldown", category: .pull, targetMuscles: ["Traps", "Rhomboids"], instructions: "1. Set up properly for Lat Pulldown.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let seatedCableRow = GymMachine(name: "Seated Cable Row", category: .pull, targetMuscles: ["Rear Delt", "Biceps"], instructions: "1. Set up properly for Seated Cable Row.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let facePulls = GymMachine(name: "Face Pulls", category: .pull, targetMuscles: ["Traps"], instructions: "1. Set up properly for Face Pulls.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let pullUps = GymMachine(name: "Pull-Ups", category: .pull, targetMuscles: ["Mid Back"], instructions: "1. Set up properly for Pull-Ups.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let chinUps = GymMachine(name: "Chin-Ups", category: .pull, targetMuscles: ["Traps", "Rhomboids", "Lats"], instructions: "1. Set up properly for Chin-Ups.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let tBarRow = GymMachine(name: "T-Bar Row", category: .pull, targetMuscles: ["Forearms"], instructions: "1. Set up properly for T-Bar Row.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let meadowsRow = GymMachine(name: "Meadows Row", category: .pull, targetMuscles: ["Rear Delt"], instructions: "1. Set up properly for Meadows Row.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let singleArmDumbbellRow = GymMachine(name: "Single-Arm Dumbbell Row", category: .pull, targetMuscles: ["Mid Back", "Biceps", "Lats"], instructions: "1. Set up properly for Single-Arm Dumbbell Row.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let straightArmPulldown = GymMachine(name: "Straight-Arm Pulldown", category: .pull, targetMuscles: ["Rhomboids"], instructions: "1. Set up properly for Straight-Arm Pulldown.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let pendlayRow = GymMachine(name: "Pendlay Row", category: .pull, targetMuscles: ["Lower Back"], instructions: "1. Set up properly for Pendlay Row.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let chestSupportedRow = GymMachine(name: "Chest-Supported Row", category: .pull, targetMuscles: ["Lats"], instructions: "1. Set up properly for Chest-Supported Row.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let rackPulls = GymMachine(name: "Rack Pulls", category: .pull, targetMuscles: ["Rear Delt", "Rhomboids"], instructions: "1. Set up properly for Rack Pulls.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let reversePecDeck = GymMachine(name: "Reverse Pec Deck", category: .pull, targetMuscles: ["Forearms", "Lats"], instructions: "1. Set up properly for Reverse Pec Deck.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let cableFacePulls = GymMachine(name: "Cable Face Pulls", category: .pull, targetMuscles: ["Traps"], instructions: "1. Set up properly for Cable Face Pulls.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let renegadeRow = GymMachine(name: "Renegade Row", category: .pull, targetMuscles: ["Biceps", "Rhomboids"], instructions: "1. Set up properly for Renegade Row.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let machineRow = GymMachine(name: "Machine Row", category: .pull, targetMuscles: ["Traps", "Rear Delt", "Forearms"], instructions: "1. Set up properly for Machine Row.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let vBarPulldown = GymMachine(name: "V-Bar Pulldown", category: .pull, targetMuscles: ["Biceps", "Rhomboids", "Lower Back"], instructions: "1. Set up properly for V-Bar Pulldown.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let underhandLatPulldown = GymMachine(name: "Underhand Lat Pulldown", category: .pull, targetMuscles: ["Rear Delt", "Forearms", "Mid Back"], instructions: "1. Set up properly for Underhand Lat Pulldown.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let wideGripCableRow = GymMachine(name: "Wide-Grip Cable Row", category: .pull, targetMuscles: ["Biceps", "Rear Delt", "Lower Back"], instructions: "1. Set up properly for Wide-Grip Cable Row.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let invertedRow = GymMachine(name: "Inverted Row", category: .pull, targetMuscles: ["Traps", "Biceps"], instructions: "1. Set up properly for Inverted Row.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let sealRow = GymMachine(name: "Seal Row", category: .pull, targetMuscles: ["Rear Delt"], instructions: "1. Set up properly for Seal Row.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let bicepCurl = GymMachine(name: "Bicep Curl", category: .pull, targetMuscles: ["Rhomboids"], instructions: "1. Set up properly for Bicep Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let dumbbellCurl = GymMachine(name: "Dumbbell Curl", category: .pull, targetMuscles: ["Lower Back", "Forearms", "Rear Delt"], instructions: "1. Set up properly for Dumbbell Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let barbellCurl = GymMachine(name: "Barbell Curl", category: .pull, targetMuscles: ["Rhomboids"], instructions: "1. Set up properly for Barbell Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let hammerCurl = GymMachine(name: "Hammer Curl", category: .pull, targetMuscles: ["Traps"], instructions: "1. Set up properly for Hammer Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let preacherCurl = GymMachine(name: "Preacher Curl", category: .pull, targetMuscles: ["Rhomboids"], instructions: "1. Set up properly for Preacher Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let concentrationCurl = GymMachine(name: "Concentration Curl", category: .pull, targetMuscles: ["Forearms", "Lower Back"], instructions: "1. Set up properly for Concentration Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let cableCurl = GymMachine(name: "Cable Curl", category: .pull, targetMuscles: ["Rhomboids"], instructions: "1. Set up properly for Cable Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let ezBarCurl = GymMachine(name: "EZ-Bar Curl", category: .pull, targetMuscles: ["Lats", "Rhomboids"], instructions: "1. Set up properly for EZ-Bar Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let reverseCurl = GymMachine(name: "Reverse Curl", category: .pull, targetMuscles: ["Lower Back", "Biceps"], instructions: "1. Set up properly for Reverse Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let spiderCurl = GymMachine(name: "Spider Curl", category: .pull, targetMuscles: ["Lats", "Mid Back"], instructions: "1. Set up properly for Spider Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let inclineDumbbellCurl = GymMachine(name: "Incline Dumbbell Curl", category: .pull, targetMuscles: ["Forearms"], instructions: "1. Set up properly for Incline Dumbbell Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let zottmanCurl = GymMachine(name: "Zottman Curl", category: .pull, targetMuscles: ["Lats"], instructions: "1. Set up properly for Zottman Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let dragCurl = GymMachine(name: "Drag Curl", category: .pull, targetMuscles: ["Mid Back", "Lats", "Rear Delt"], instructions: "1. Set up properly for Drag Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let machineBicepCurl = GymMachine(name: "Machine Bicep Curl", category: .pull, targetMuscles: ["Rear Delt"], instructions: "1. Set up properly for Machine Bicep Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let highCableCurl = GymMachine(name: "High Cable Curl", category: .pull, targetMuscles: ["Forearms", "Lats"], instructions: "1. Set up properly for High Cable Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let crossBodyHammerCurl = GymMachine(name: "Cross-Body Hammer Curl", category: .pull, targetMuscles: ["Lower Back"], instructions: "1. Set up properly for Cross-Body Hammer Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let plateCurl = GymMachine(name: "Plate Curl", category: .pull, targetMuscles: ["Rear Delt"], instructions: "1. Set up properly for Plate Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let bayesianCurl = GymMachine(name: "Bayesian Curl", category: .pull, targetMuscles: ["Biceps", "Lower Back", "Rear Delt"], instructions: "1. Set up properly for Bayesian Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let barbellSquat = GymMachine(name: "Barbell Squat", category: .legs, targetMuscles: ["Adductors", "Quads", "Glutes"], instructions: "1. Set up properly for Barbell Squat.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let legPress = GymMachine(name: "Leg Press", category: .legs, targetMuscles: ["Abductors"], instructions: "1. Set up properly for Leg Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let romanianDeadlift = GymMachine(name: "Romanian Deadlift", category: .legs, targetMuscles: ["Calves", "Glutes"], instructions: "1. Set up properly for Romanian Deadlift.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let legCurl = GymMachine(name: "Leg Curl", category: .legs, targetMuscles: ["Glutes"], instructions: "1. Set up properly for Leg Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let legExtension = GymMachine(name: "Leg Extension", category: .legs, targetMuscles: ["Quads"], instructions: "1. Set up properly for Leg Extension.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let bulgarianSplitSquat = GymMachine(name: "Bulgarian Split Squat", category: .legs, targetMuscles: ["Hamstrings"], instructions: "1. Set up properly for Bulgarian Split Squat.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let calfRaises = GymMachine(name: "Calf Raises", category: .legs, targetMuscles: ["Adductors", "Glutes", "Quads"], instructions: "1. Set up properly for Calf Raises.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let hipThrust = GymMachine(name: "Hip Thrust", category: .legs, targetMuscles: ["Quads", "Abductors"], instructions: "1. Set up properly for Hip Thrust.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let hackSquat = GymMachine(name: "Hack Squat", category: .legs, targetMuscles: ["Glutes"], instructions: "1. Set up properly for Hack Squat.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let pendulumSquat = GymMachine(name: "Pendulum Squat", category: .legs, targetMuscles: ["Abductors", "Adductors"], instructions: "1. Set up properly for Pendulum Squat.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let frontSquat = GymMachine(name: "Front Squat", category: .legs, targetMuscles: ["Glutes"], instructions: "1. Set up properly for Front Squat.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let gobletSquat = GymMachine(name: "Goblet Squat", category: .legs, targetMuscles: ["Adductors", "Hamstrings", "Abductors"], instructions: "1. Set up properly for Goblet Squat.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let lunges = GymMachine(name: "Lunges", category: .legs, targetMuscles: ["Calves", "Quads"], instructions: "1. Set up properly for Lunges.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let walkingLunges = GymMachine(name: "Walking Lunges", category: .legs, targetMuscles: ["Glutes"], instructions: "1. Set up properly for Walking Lunges.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let sumoDeadlift = GymMachine(name: "Sumo Deadlift", category: .legs, targetMuscles: ["Adductors", "Abductors"], instructions: "1. Set up properly for Sumo Deadlift.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let stiffLeggedDeadlift = GymMachine(name: "Stiff-Legged Deadlift", category: .legs, targetMuscles: ["Hamstrings"], instructions: "1. Set up properly for Stiff-Legged Deadlift.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let goodMornings = GymMachine(name: "Good Mornings", category: .legs, targetMuscles: ["Calves"], instructions: "1. Set up properly for Good Mornings.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let gluteHamRaise = GymMachine(name: "Glute Ham Raise", category: .legs, targetMuscles: ["Glutes", "Hamstrings", "Quads"], instructions: "1. Set up properly for Glute Ham Raise.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let sissySquat = GymMachine(name: "Sissy Squat", category: .legs, targetMuscles: ["Hamstrings"], instructions: "1. Set up properly for Sissy Squat.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let seatedCalfRaise = GymMachine(name: "Seated Calf Raise", category: .legs, targetMuscles: ["Abductors", "Quads", "Adductors"], instructions: "1. Set up properly for Seated Calf Raise.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let donkeyCalfRaise = GymMachine(name: "Donkey Calf Raise", category: .legs, targetMuscles: ["Abductors"], instructions: "1. Set up properly for Donkey Calf Raise.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let standingCalfRaise = GymMachine(name: "Standing Calf Raise", category: .legs, targetMuscles: ["Quads", "Abductors", "Hamstrings"], instructions: "1. Set up properly for Standing Calf Raise.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let legPressCalfRaise = GymMachine(name: "Leg Press Calf Raise", category: .legs, targetMuscles: ["Adductors"], instructions: "1. Set up properly for Leg Press Calf Raise.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let gluteKickbacks = GymMachine(name: "Glute Kickbacks", category: .legs, targetMuscles: ["Adductors"], instructions: "1. Set up properly for Glute Kickbacks.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let cablePullThrough = GymMachine(name: "Cable Pull-Through", category: .legs, targetMuscles: ["Adductors", "Abductors", "Calves"], instructions: "1. Set up properly for Cable Pull-Through.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let hipAbductorMachine = GymMachine(name: "Hip Abductor Machine", category: .legs, targetMuscles: ["Glutes"], instructions: "1. Set up properly for Hip Abductor Machine.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let hipAdductorMachine = GymMachine(name: "Hip Adductor Machine", category: .legs, targetMuscles: ["Calves", "Adductors"], instructions: "1. Set up properly for Hip Adductor Machine.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let stepUps = GymMachine(name: "Step-Ups", category: .legs, targetMuscles: ["Adductors", "Glutes", "Quads"], instructions: "1. Set up properly for Step-Ups.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let boxJumps = GymMachine(name: "Box Jumps", category: .legs, targetMuscles: ["Calves", "Abductors", "Glutes"], instructions: "1. Set up properly for Box Jumps.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let pistolSquat = GymMachine(name: "Pistol Squat", category: .legs, targetMuscles: ["Adductors", "Calves"], instructions: "1. Set up properly for Pistol Squat.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let jeffersonSquat = GymMachine(name: "Jefferson Squat", category: .legs, targetMuscles: ["Hamstrings", "Calves", "Abductors"], instructions: "1. Set up properly for Jefferson Squat.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let zercherSquat = GymMachine(name: "Zercher Squat", category: .legs, targetMuscles: ["Abductors", "Calves"], instructions: "1. Set up properly for Zercher Squat.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let smithMachineSquat = GymMachine(name: "Smith Machine Squat", category: .legs, targetMuscles: ["Adductors", "Glutes"], instructions: "1. Set up properly for Smith Machine Squat.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let beltSquat = GymMachine(name: "Belt Squat", category: .legs, targetMuscles: ["Calves", "Abductors", "Quads"], instructions: "1. Set up properly for Belt Squat.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let reverseLunges = GymMachine(name: "Reverse Lunges", category: .legs, targetMuscles: ["Adductors", "Glutes"], instructions: "1. Set up properly for Reverse Lunges.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let curtsyLunges = GymMachine(name: "Curtsy Lunges", category: .legs, targetMuscles: ["Adductors", "Hamstrings"], instructions: "1. Set up properly for Curtsy Lunges.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let nordicHamstringCurl = GymMachine(name: "Nordic Hamstring Curl", category: .legs, targetMuscles: ["Adductors"], instructions: "1. Set up properly for Nordic Hamstring Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let singleLegPress = GymMachine(name: "Single-Leg Press", category: .legs, targetMuscles: ["Glutes", "Calves", "Adductors"], instructions: "1. Set up properly for Single-Leg Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let singleLegLegCurl = GymMachine(name: "Single-Leg Leg Curl", category: .legs, targetMuscles: ["Abductors", "Calves", "Quads"], instructions: "1. Set up properly for Single-Leg Leg Curl.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let singleLegLegExtension = GymMachine(name: "Single-Leg Leg Extension", category: .legs, targetMuscles: ["Abductors"], instructions: "1. Set up properly for Single-Leg Leg Extension.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let cableCrunches = GymMachine(name: "Cable Crunches", category: .core, targetMuscles: ["Lower Abs", "Obliques"], instructions: "1. Set up properly for Cable Crunches.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let hangingLegRaise = GymMachine(name: "Hanging Leg Raise", category: .core, targetMuscles: ["Abs", "Core", "Hip Flexors"], instructions: "1. Set up properly for Hanging Leg Raise.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let plank = GymMachine(name: "Plank", category: .core, targetMuscles: ["Core"], instructions: "1. Set up properly for Plank.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .dumbbell)
    static let russianTwist = GymMachine(name: "Russian Twist", category: .core, targetMuscles: ["Obliques"], instructions: "1. Set up properly for Russian Twist.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let abWheelRollout = GymMachine(name: "Ab Wheel Rollout", category: .core, targetMuscles: ["Core", "Hip Flexors", "Obliques"], instructions: "1. Set up properly for Ab Wheel Rollout.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let bicycleCrunches = GymMachine(name: "Bicycle Crunches", category: .core, targetMuscles: ["Lower Abs", "Core"], instructions: "1. Set up properly for Bicycle Crunches.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let declineCrunches = GymMachine(name: "Decline Crunches", category: .core, targetMuscles: ["Abs", "Core"], instructions: "1. Set up properly for Decline Crunches.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let toeTouches = GymMachine(name: "Toe Touches", category: .core, targetMuscles: ["Abs", "Core"], instructions: "1. Set up properly for Toe Touches.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .machine)
    static let vUps = GymMachine(name: "V-Ups", category: .core, targetMuscles: ["Hip Flexors"], instructions: "1. Set up properly for V-Ups.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let flutterKicks = GymMachine(name: "Flutter Kicks", category: .core, targetMuscles: ["Lower Abs", "Abs"], instructions: "1. Set up properly for Flutter Kicks.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let mountainClimbers = GymMachine(name: "Mountain Climbers", category: .core, targetMuscles: ["Core", "Lower Abs", "Hip Flexors"], instructions: "1. Set up properly for Mountain Climbers.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let sidePlank = GymMachine(name: "Side Plank", category: .core, targetMuscles: ["Lower Abs", "Obliques"], instructions: "1. Set up properly for Side Plank.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let woodchoppers = GymMachine(name: "Woodchoppers", category: .core, targetMuscles: ["Lower Abs", "Obliques"], instructions: "1. Set up properly for Woodchoppers.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let pallofPress = GymMachine(name: "Pallof Press", category: .core, targetMuscles: ["Core"], instructions: "1. Set up properly for Pallof Press.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let dragonFlag = GymMachine(name: "Dragon Flag", category: .core, targetMuscles: ["Obliques", "Core"], instructions: "1. Set up properly for Dragon Flag.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let hollowBodyHold = GymMachine(name: "Hollow Body Hold", category: .core, targetMuscles: ["Abs"], instructions: "1. Set up properly for Hollow Body Hold.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let deadBug = GymMachine(name: "Dead Bug", category: .core, targetMuscles: ["Hip Flexors", "Core", "Lower Abs"], instructions: "1. Set up properly for Dead Bug.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let lSit = GymMachine(name: "L-Sit", category: .core, targetMuscles: ["Obliques"], instructions: "1. Set up properly for L-Sit.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let sitUps = GymMachine(name: "Sit-Ups", category: .core, targetMuscles: ["Lower Abs"], instructions: "1. Set up properly for Sit-Ups.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let crunchMachine = GymMachine(name: "Crunch Machine", category: .core, targetMuscles: ["Hip Flexors", "Lower Abs"], instructions: "1. Set up properly for Crunch Machine.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let reverseCrunches = GymMachine(name: "Reverse Crunches", category: .core, targetMuscles: ["Obliques", "Abs", "Hip Flexors"], instructions: "1. Set up properly for Reverse Crunches.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let obliqueCrunches = GymMachine(name: "Oblique Crunches", category: .core, targetMuscles: ["Obliques"], instructions: "1. Set up properly for Oblique Crunches.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)
    static let windshieldWipers = GymMachine(name: "Windshield Wipers", category: .core, targetMuscles: ["Obliques"], instructions: "1. Set up properly for Windshield Wipers.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let hangingKneeRaise = GymMachine(name: "Hanging Knee Raise", category: .core, targetMuscles: ["Obliques"], instructions: "1. Set up properly for Hanging Knee Raise.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let captainsChairLegRaise = GymMachine(name: "Captain's Chair Leg Raise", category: .core, targetMuscles: ["Hip Flexors", "Core", "Abs"], instructions: "1. Set up properly for Captain's Chair Leg Raise.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let medicineBallSlams = GymMachine(name: "Medicine Ball Slams", category: .core, targetMuscles: ["Obliques"], instructions: "1. Set up properly for Medicine Ball Slams.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let kettlebellSwings = GymMachine(name: "Kettlebell Swings", category: .core, targetMuscles: ["Obliques"], instructions: "1. Set up properly for Kettlebell Swings.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .cable)
    static let suitcaseCarry = GymMachine(name: "Suitcase Carry", category: .core, targetMuscles: ["Abs"], instructions: "1. Set up properly for Suitcase Carry.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .barbell)
    static let farmersWalk = GymMachine(name: "Farmer's Walk", category: .core, targetMuscles: ["Core", "Abs"], instructions: "1. Set up properly for Farmer's Walk.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .bodyweight)
    static let turkishGetUp = GymMachine(name: "Turkish Get-Up", category: .core, targetMuscles: ["Core", "Obliques", "Hip Flexors"], instructions: "1. Set up properly for Turkish Get-Up.\n2. Engage the target muscles.\n3. Perform the concentric phase with control.\n4. Perform the eccentric phase slowly.\n5. Repeat for desired reps.", videoURL: nil, isCustom: false, equipmentType: .kettlebell)

    static let allDefaultMachines: [GymMachine] = [
        flatBenchPress,
        inclineDumbbellPress,
        declineBenchPress,
        machineChestPress,
        pecDeckFlye,
        cableCrossover,
        pushUps,
        dumbbellPullover,
        inclineBarbellPress,
        smithMachineBenchPress,
        inclineCableFlye,
        dumbbellFloorPress,
        spotoPress,
        overheadPress,
        dumbbellShoulderPress,
        arnoldPress,
        lateralRaises,
        frontRaises,
        machineShoulderPress,
        uprightRow,
        cableLateralRaises,
        smithMachineOverheadPress,
        plateFrontRaise,
        landminePress,
        pushPress,
        tricepPushdown,
        skullCrushers,
        dips,
        overheadTricepExtension,
        closeGripBenchPress,
        ropeTricepPushdown,
        kickbacks,
        jmPress,
        diamondPushUps,
        machineTricepExtension,
        cableOverheadExtension,
        tatePress,
        singleArmCablePushdown,
        benchDips,
        deadlift,
        barbellRow,
        latPulldown,
        seatedCableRow,
        facePulls,
        pullUps,
        chinUps,
        tBarRow,
        meadowsRow,
        singleArmDumbbellRow,
        straightArmPulldown,
        pendlayRow,
        chestSupportedRow,
        rackPulls,
        reversePecDeck,
        cableFacePulls,
        renegadeRow,
        machineRow,
        vBarPulldown,
        underhandLatPulldown,
        wideGripCableRow,
        invertedRow,
        sealRow,
        bicepCurl,
        dumbbellCurl,
        barbellCurl,
        hammerCurl,
        preacherCurl,
        concentrationCurl,
        cableCurl,
        ezBarCurl,
        reverseCurl,
        spiderCurl,
        inclineDumbbellCurl,
        zottmanCurl,
        dragCurl,
        machineBicepCurl,
        highCableCurl,
        crossBodyHammerCurl,
        plateCurl,
        bayesianCurl,
        barbellSquat,
        legPress,
        romanianDeadlift,
        legCurl,
        legExtension,
        bulgarianSplitSquat,
        calfRaises,
        hipThrust,
        hackSquat,
        pendulumSquat,
        frontSquat,
        gobletSquat,
        lunges,
        walkingLunges,
        sumoDeadlift,
        stiffLeggedDeadlift,
        goodMornings,
        gluteHamRaise,
        sissySquat,
        seatedCalfRaise,
        donkeyCalfRaise,
        standingCalfRaise,
        legPressCalfRaise,
        gluteKickbacks,
        cablePullThrough,
        hipAbductorMachine,
        hipAdductorMachine,
        stepUps,
        boxJumps,
        pistolSquat,
        jeffersonSquat,
        zercherSquat,
        smithMachineSquat,
        beltSquat,
        reverseLunges,
        curtsyLunges,
        nordicHamstringCurl,
        singleLegPress,
        singleLegLegCurl,
        singleLegLegExtension,
        cableCrunches,
        hangingLegRaise,
        plank,
        russianTwist,
        abWheelRollout,
        bicycleCrunches,
        declineCrunches,
        toeTouches,
        vUps,
        flutterKicks,
        mountainClimbers,
        sidePlank,
        woodchoppers,
        pallofPress,
        dragonFlag,
        hollowBodyHold,
        deadBug,
        lSit,
        sitUps,
        crunchMachine,
        reverseCrunches,
        obliqueCrunches,
        windshieldWipers,
        hangingKneeRaise,
        captainsChairLegRaise,
        medicineBallSlams,
        kettlebellSwings,
        suitcaseCarry,
        farmersWalk,
        turkishGetUp
    ]

    static func syncExercisesIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<GymMachine>()
        let existing = (try? context.fetch(descriptor)) ?? []
        let existingNames = Set(existing.map { $0.name })
        for machine in allDefaultMachines {
            if !existingNames.contains(machine.name) {
                context.insert(machine)
            }
        }
        try? context.save()
    }

    static func seedIfNeeded(context: ModelContext) {
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
        let pushDay = WorkoutSplit(name: "Push Day", status: .active)
        let pullDay = WorkoutSplit(name: "Pull Day", status: .active)
        let legDay = WorkoutSplit(name: "Leg Day", status: .active)
        let coreDay = WorkoutSplit(name: "Core Day", status: .inDevelopment)

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

