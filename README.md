# Get Fit

Get Fit is a native, local-first iOS fitness application built with SwiftUI, SwiftData, and ActivityKit. It provides progressive overload tracking, Live Activity rest timers, and on-device food photo recognition without cloud dependencies, advertisements, or mandatory user accounts.

## Key Features

### Workout Engine & Progressive Overload
- **Split Management**: Support for Push/Pull/Legs, Upper/Lower, and custom workout splits.
- **Automatic Target Calculation**: Recommends target weights for upcoming sets based on historical exercise maxes.
- **Fractional Weight Precision**: Supports exact decimal weight entries (e.g. `7.5 kg`, `12.5 kg`) with configurable increment steppers.

### Live Activity Rest Timers
- **Dynamic Island & Lock Screen**: Displays real-time rest countdowns via Apple's ActivityKit when the app is backgrounded.
- **Haptic Alerts**: Triggers tactile feedback upon rest timer completion.

### Nutrition & Macro Tracker
- **Calorie & Macro Goals**: Tracks daily calorie intake alongside Protein, Carbs, and Fats progress.
- **Meal Category Logs**: Categorizes food entries under Breakfast, Lunch, Dinner, and Snacks.
- **AI Food Photo Recognition**: On-device image classification powered by Apple's Vision framework (`VNClassifyImageRequest`). Automatically detects dishes, breaks down multi-item plates, and estimates macros with full manual review before saving.

### Activity Rings & Metrics
- **3-Ring Dashboard**:
  - 🔴 **Daily Steps**: Auto-synced with Apple HealthKit.
  - 🟢 **Workout & Cardio Time**: Sums focused lifting and cardio minutes.
  - 🔵 **Weekly Consistency**: Tracks active training days against weekly targets.
- **Body Weight Charts**: Equal-spaced indexed trend charts to visualize weight progression without date compression issues.
- **Cardio Log**: Dedicated cardio finisher tracker for treadmill, stairmaster, or outdoor sessions.

### Utilities & Exporting
- **Shareable Summary Cards**: Generates high-resolution dark-mode summary graphics using `ImageRenderer` for native iOS export (`ShareLink`).
- **In-App Tutorial Player**: View exercise posture videos and YouTube Shorts directly inside the app using `SFSafariViewController`.
- **Rest Day Management**: Interactive recovery sheet with quick-swap split reassignment.

## Architecture & Technology Stack

| Component | Technology |
|---|---|
| **UI Framework** | SwiftUI (iOS 18.0+) |
| **Persistence** | SwiftData (`@Model`, `@Query`, `@Relationship`) |
| **Live Activities** | ActivityKit & WidgetKit |
| **Health Integration** | HealthKit (`HKHealthStore`) |
| **Computer Vision** | Vision Framework (`VNClassifyImageRequest`) |
| **Project Build System** | XcodeGen (`project.yml`) |
| **In-App Web Player** | `SFSafariViewController` |

## Local Setup

### Prerequisites
- macOS 14.0+
- Xcode 16.0+
- XcodeGen (`brew install xcodegen`)

### Instructions

1. Clone the repository:
   ```bash
   git clone git@github.com:gst537/Get_Fit.git
   cd Get_Fit
   ```

2. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```

3. Open and run in Xcode:
   ```bash
   open GetFit.xcodeproj
   ```
   Select an iOS Simulator (or connected physical iPhone) and press `⌘R`.

## License

Distributed under the MIT License.
