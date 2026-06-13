# Worked Example: Fitness Tracking App

End-to-end walkthrough building "LiftLog" — a fitness tracking app with workout logging, progress charts, and HealthKit sync — from concept through TestFlight distribution.

> This example targets iOS 17+ and uses SwiftUI, SwiftData, HealthKit, CloudKit, and Swift Charts.

## Brief

**App:** LiftLog — track strength training workouts, visualize progress over time, sync with Apple Health.

**Core features:**
- Log workouts with exercises, sets, reps, and weight
- View workout history with search and filtering
- Progress charts showing volume and max weight per exercise over time
- HealthKit integration: read/write workout data so it appears in Apple Health
- CloudKit sync for cross-device access (iPhone + iPad)

**Target user:** Intermediate lifter who wants simple logging without the complexity of apps like Strong or Hevy.

**Why native iOS (not web):** HealthKit has no web API. Background sync, widgets, and Watch complications are impossible from a browser. The data is deeply personal and benefits from on-device persistence with optional cloud sync — the offline-first model that iOS does natively.

## Architecture Decision: MVVM + @Observable

**Chosen:** MVVM with `@Observable` classes as view models.

**Rationale:**
- SwiftData handles persistence — no need for a repository layer
- `@Observable` (iOS 17+) eliminates the boilerplate of `ObservableObject` + `@Published`
- View models own business logic (validation, HealthKit calls, derived computations)
- Views stay declarative — they read state and send actions, nothing else
- Testing is straightforward — instantiate view model, call methods, assert state

**Rejected:** TCA (heavy for CRUD apps), MV without view models (HealthKit logic needs a home), VIPER (over-engineered for solo dev).

**Flow:** Views (`@Query` reads) --> ViewModels (`@Observable`, owns mutations + side effects) --> SwiftData Models --> CloudKit (auto-sync).

## Project Setup

### Xcode Project Creation

1. **File > New > Project > App**
2. Interface: SwiftUI, Language: Swift, Storage: SwiftData
3. Team: your Apple Developer account
4. Bundle ID: `com.yourname.liftlog`
5. Check "Include Tests"

### Folder Structure

Organize by role: `Models/` (SwiftData), `ViewModels/` (@Observable classes), `Views/` (SwiftUI, with `Components/` for reusable pieces), `Services/` (HealthKit manager, exercise database). Tests mirror the ViewModels directory.

### SPM Dependencies

None required for the MVP. Swift Charts, HealthKit, SwiftData, and CloudKit are all first-party frameworks. The features that would require 3-5 npm packages on web ship with the SDK.

## Data Model

### SwiftData Models

Three models with cascade relationships: `Workout` has many `Exercise`, each has many `ExerciseSet` (renamed from "Set" — it is a reserved word in Swift).

```swift
// Models/Workout.swift — the root model
import SwiftData

@Model
final class Workout {
    var id: UUID
    var name: String
    var date: Date
    var notes: String
    var durationSeconds: Int
    @Relationship(deleteRule: .cascade) var exercises: [Exercise]
    
    var totalVolume: Double {
        exercises.reduce(0) { $0 + $1.totalVolume }
    }
    
    init(name: String, date: Date = .now, notes: String = "") {
        self.id = UUID()
        self.name = name
        self.date = date
        self.notes = notes
        self.durationSeconds = 0
        self.exercises = []
    }
}

// Models/Exercise.swift — inverse relationship to Workout
@Model
final class Exercise {
    var id: UUID
    var name: String
    var order: Int
    @Relationship(deleteRule: .cascade) var sets: [ExerciseSet]
    @Relationship(inverse: \Workout.exercises) var workout: Workout?
    
    var totalVolume: Double {
        sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
    
    init(name: String, order: Int) {
        self.id = UUID(); self.name = name; self.order = order; self.sets = []
    }
}

// Models/ExerciseSet.swift — leaf model
@Model
final class ExerciseSet {
    var id: UUID
    var reps: Int
    var weight: Double  // user's preferred unit (kg or lbs)
    var isWarmup: Bool
    var order: Int
    var isCompleted: Bool
    @Relationship(inverse: \Exercise.sets) var exercise: Exercise?
    
    init(reps: Int, weight: Double, order: Int, isWarmup: Bool = false) {
        self.id = UUID(); self.reps = reps; self.weight = weight
        self.order = order; self.isWarmup = isWarmup; self.isCompleted = false
    }
}
```

**Key difference from web ORMs:** No migration files, no schema DSL. The `@Model` macro generates persistence. Relationships use `@Relationship` with explicit inverses. Closer to Core Data than Prisma or TypeORM.

## Core Views

### WorkoutListView — The Main Screen

```swift
struct WorkoutListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    @State private var showingAddWorkout = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(workouts) { workout in
                    NavigationLink(value: workout) { WorkoutRow(workout: workout) }
                }
                .onDelete { offsets in
                    offsets.map { workouts[$0] }.forEach(modelContext.delete)
                }
            }
            .navigationTitle("Workouts")
            .navigationDestination(for: Workout.self) { WorkoutDetailView(workout: $0) }
            .toolbar { Button("Add", systemImage: "plus") { showingAddWorkout = true } }
            .sheet(isPresented: $showingAddWorkout) { AddWorkoutView() }
            .overlay {
                if workouts.isEmpty {
                    ContentUnavailableView("No Workouts Yet",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("Tap + to log your first workout"))
                }
            }
        }
    }
}
```

**Web developer note:** `@Query` automatically fetches from SwiftData and re-renders when data changes. No `useEffect` + `fetch` + `setState` cycle. The query is live — insert a workout anywhere and this list updates instantly.

### ProgressChartView — Swift Charts

```swift
import Charts

struct ProgressChartView: View {
    @State private var viewModel: ProgressViewModel
    @State private var selectedExercise: String = "Bench Press"
    @State private var timeRange: TimeRange = .threeMonths
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Exercise", selection: $selectedExercise) {
                ForEach(viewModel.exerciseNames, id: \.self) { Text($0).tag($0) }
            }
            Picker("Range", selection: $timeRange) {
                ForEach(TimeRange.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)
            
            Chart(viewModel.dataPoints(for: selectedExercise, range: timeRange)) { point in
                LineMark(x: .value("Date", point.date), y: .value("Max Weight", point.maxWeight))
                    .interpolationMethod(.catmullRom)
                AreaMark(x: .value("Date", point.date), y: .value("Max Weight", point.maxWeight))
                    .foregroundStyle(.blue.opacity(0.1))
            }
            .chartYAxisLabel("Weight (lbs)")
            .frame(height: 250)
        }
        .padding()
        .navigationTitle("Progress")
    }
}
```

## HealthKit Integration

### Requesting Permission

HealthKit requires explicit user permission and an entitlement in Xcode. This is not optional — the app will crash without it.

**Setup steps:**
1. **Xcode > Signing & Capabilities > + HealthKit**
2. Add `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription` to Info.plist
3. Request authorization at runtime before any read/write

```swift
// Services/HealthKitManager.swift
import HealthKit

@Observable
final class HealthKitManager {
    private let store = HKHealthStore()
    var isAuthorized = false
    
    static let shared = HealthKitManager()
    
    private let typesToRead: Set<HKObjectType> = [
        HKObjectType.workoutType(),
        HKQuantityType(.activeEnergyBurned)
    ]
    
    private let typesToWrite: Set<HKSampleType> = [
        HKObjectType.workoutType(),
        HKQuantityType(.activeEnergyBurned)
    ]
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        try await store.requestAuthorization(toShare: typesToWrite, read: typesToRead)
        isAuthorized = true
    }
    
    func saveWorkout(_ workout: Workout) async throws {
        let hkWorkout = HKWorkout(
            activityType: .traditionalStrengthTraining,
            start: workout.date,
            end: workout.date.addingTimeInterval(TimeInterval(workout.durationSeconds)),
            workoutEvents: nil, totalEnergyBurned: nil, totalDistance: nil,
            metadata: ["LiftLogWorkoutID": workout.id.uuidString]
        )
        try await store.save(hkWorkout)
    }
}
```

**Critical gotcha:** HealthKit authorization is per-type, not all-or-nothing. The user can grant read access to workouts but deny write access. You cannot check whether a specific permission was granted (Apple considers this a privacy leak) — you can only check if you *requested* it. Design defensively: attempt the operation and handle the error.

## State Management

**Data flow:** SwiftData's `@Query` in views handles read-path reactivity automatically. View models handle write-path logic — validation, HealthKit sync, delete operations. The VM does not re-implement query logic that SwiftData provides for free. This split keeps view models thin: they own side effects and mutations, not data fetching.

## Backend: CloudKit Sync

SwiftData with CloudKit is the lowest-friction cross-device sync available on Apple platforms. It requires zero server code.

Enable iCloud capability in Xcode, create a CloudKit container (`iCloud.com.yourname.liftlog`), and SwiftData's ModelContainer automatically uses `NSPersistentCloudKitContainer` under the hood. Zero code changes beyond the capability toggle.

**Limitations:** Sync latency is 5-30 seconds (not real-time). All model properties must have defaults or be optional (required by merge policy). Unique constraints are unsupported. No server-side logic.

## Testing

### Unit Tests for ViewModel

```swift
// LiftLogTests/AddWorkoutViewModelTests.swift
import Testing
import SwiftData
@testable import LiftLog

@Suite("AddWorkoutViewModel")
struct AddWorkoutViewModelTests {
    
    let container: ModelContainer
    let context: ModelContext
    
    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: Workout.self, Exercise.self, ExerciseSet.self,
            configurations: config
        )
        context = ModelContext(container)
    }
    
    @Test("Creates workout with valid input")
    func createWorkout() throws {
        let vm = AddWorkoutViewModel(modelContext: context)
        vm.workoutName = "Push Day"
        vm.addExercise(name: "Bench Press")
        vm.addSet(to: 0, reps: 8, weight: 135)
        
        let result = vm.saveWorkout()
        #expect(result == true)
        
        let descriptor = FetchDescriptor<Workout>()
        let workouts = try context.fetch(descriptor)
        #expect(workouts.count == 1)
        #expect(workouts[0].name == "Push Day")
        #expect(workouts[0].exercises.count == 1)
    }
    
    @Test("Rejects empty workout name")
    func rejectEmptyName() {
        let vm = AddWorkoutViewModel(modelContext: context)
        vm.workoutName = ""
        
        let result = vm.saveWorkout()
        #expect(result == false)
        #expect(vm.validationError == "Workout name is required")
    }
}
```

**Key pattern:** `ModelConfiguration(isStoredInMemoryOnly: true)` gives you an isolated, ephemeral database per test. No cleanup needed, no test pollution. This is the SwiftData equivalent of an in-memory SQLite database in web testing.

For view regression testing, add `swift-snapshot-testing` via SPM and use `assertSnapshot(of: view, as: .image)` to catch visual regressions.

## TestFlight Distribution

### Build and Upload

1. **Set version:** Target > General > Version: `1.0.0`, Build: `1`
2. **Archive:** Product > Archive (requires a real device or "Any iOS Device" selected)
3. **Distribute:** Window > Organizer > Distribute App > TestFlight & App Store
4. **Wait:** Apple processes the build (5-30 minutes). You get an email when ready.

In App Store Connect, create a test group and add testers by email. **Internal testers** (up to 100, must be on your team) skip Beta App Review. **External testers** (up to 10,000) require review, usually under 24 hours. Use internal testers first to validate before opening up.

**Common rejection causes:** missing `NS*UsageDescription` keys in Info.plist (especially for HealthKit), crashes on launch (test on a real device), and incomplete App Store Connect metadata.

## Lessons Learned: What Web Developers Find Surprising

| Surprise | Detail |
|----------|--------|
| **No hot reload (sort of)** | SwiftUI Previews update live as you type, but render one view at a time — not the full app. Think "preview this component" not "reload the page." |
| **Invisible build system** | No webpack, babel, tsconfig. Xcode handles everything. Clean Build Folder (Cmd+Shift+K) is your `rm -rf node_modules`. |
| **Async/await has actors** | `@MainActor` ensures UI updates on the main thread — no web equivalent. Forgetting it is a common source of warnings. |
| **No CSS** | View modifiers (`.padding()`, `.font()`) replace cascading styles. Verbose but eliminates "where did this style come from?" debugging. |
| **App size matters** | Users notice 200MB apps. Prefer SF Symbols over bundled icons. Think about the entire binary, not lazy-loaded chunks. |
| **Deploy cycle is days** | App Store review takes 24-48 hours. Feature flags and server-driven config are more valuable than on web. |
| **Simulator is not a phone** | HealthKit, camera, and push notifications do not work in the simulator. Always test on a real device before TestFlight. |
| **State management is simpler** | No Redux/Zustand/Jotai debate. `@State` for local, `@Observable` for shared, `@Environment` for system values. One answer, not twelve. |
