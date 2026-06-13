# Shortcuts and Siri Integration

> App Intents framework (iOS 16+), custom intent definitions, Siri voice integration, Shortcuts app exposure, and Spotlight indexing.

## Table of Contents

- [1. App Intents Framework](#1-app-intents-framework)
- [2. Defining Custom Intents](#2-defining-custom-intents)
- [3. Siri Integration](#3-siri-integration)
- [4. Shortcuts App Integration](#4-shortcuts-app-integration)
- [5. Spotlight Indexing](#5-spotlight-indexing)

---

## 1. App Intents Framework

App Intents (iOS 16+) replaces the legacy SiriKit Intents framework. Intents are defined entirely in Swift code -- no `.intentdefinition` files needed.

### 1.1 Basic Intent

```swift
import AppIntents

struct AddTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Task"
    static var description: IntentDescription = "Creates a new task in the app."

    @Parameter(title: "Title")
    var taskTitle: String

    @Parameter(title: "Due Date", default: nil)
    var dueDate: Date?

    @Parameter(title: "Category")
    var category: CategoryEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$taskTitle)") {
            \.$dueDate
            \.$category
        }
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let task = TaskItem(title: taskTitle, dueDate: dueDate)
        try await TaskStore.shared.save(task)

        return .result(
            value: task.id,
            dialog: "Added \"\(taskTitle)\" to your tasks."
        )
    }
}
```

### 1.2 Entity Definition

Entities let Shortcuts and Siri understand your app's domain objects.

```swift
struct TaskEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Task")

    static var defaultQuery = TaskEntityQuery()

    var id: String
    var title: String
    var isCompleted: Bool
    var dueDate: Date?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: isCompleted ? "Completed" : "Pending",
            image: .init(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
        )
    }
}

struct TaskEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [TaskEntity] {
        let tasks = try await TaskStore.shared.loadAll()
        return tasks
            .filter { identifiers.contains($0.id) }
            .map { TaskEntity(id: $0.id, title: $0.title, isCompleted: $0.isCompleted, dueDate: $0.dueDate) }
    }

    func suggestedEntities() async throws -> [TaskEntity] {
        let tasks = try await TaskStore.shared.loadAll()
        return tasks.prefix(10).map {
            TaskEntity(id: $0.id, title: $0.title, isCompleted: $0.isCompleted, dueDate: $0.dueDate)
        }
    }
}
```

---

## 2. Defining Custom Intents

### 2.1 Intent with Confirmation

```swift
struct DeleteTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Delete Task"
    static var isDiscoverable = false  // Hide from Shortcuts library

    @Parameter(title: "Task")
    var task: TaskEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Delete \(\.$task)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await requestConfirmation(
            result: .result(dialog: "Are you sure you want to delete \"\(task.title)\"?")
        )

        try await TaskStore.shared.delete(id: task.id)
        return .result(dialog: "Deleted \"\(task.title)\".")
    }
}
```

### 2.2 Intent Returning a Snippet View

```swift
struct ShowTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Task"

    @Parameter(title: "Task")
    var task: TaskEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Show \(\.$task)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        return .result(
            dialog: "\(task.title)",
            view: TaskSnippetView(task: task)
        )
    }
}

struct TaskSnippetView: View {
    let task: TaskEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                Text(task.title)
                    .font(.headline)
            }
            if let due = task.dueDate {
                Text("Due: \(due, style: .date)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
```

### 2.3 Enum Parameters

```swift
enum TaskPriority: String, AppEnum {
    case low, medium, high

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Priority")

    static var caseDisplayRepresentations: [TaskPriority: DisplayRepresentation] = [
        .low: "Low",
        .medium: "Medium",
        .high: "High"
    ]
}

// Use in an intent
struct SetPriorityIntent: AppIntent {
    static var title: LocalizedStringResource = "Set Task Priority"

    @Parameter(title: "Task")
    var task: TaskEntity

    @Parameter(title: "Priority")
    var priority: TaskPriority

    static var parameterSummary: some ParameterSummary {
        Summary("Set \(\.$task) priority to \(\.$priority)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await TaskStore.shared.setPriority(taskId: task.id, priority: priority.rawValue)
        return .result(dialog: "Set \"\(task.title)\" to \(priority.rawValue) priority.")
    }
}
```

---

## 3. Siri Integration

### 3.1 App Shortcuts (iOS 16+)

App Shortcuts make your intents available to Siri without any user setup. Define them in an `AppShortcutsProvider`:

```swift
struct MyAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTaskIntent(),
            phrases: [
                "Add a task in \(.applicationName)",
                "Create a new \(.applicationName) task",
                "Add \(\.$taskTitle) to \(.applicationName)"
            ],
            shortTitle: "Add Task",
            systemImageName: "plus.circle"
        )

        AppShortcut(
            intent: ShowTaskIntent(),
            phrases: [
                "Show my tasks in \(.applicationName)",
                "What's on my \(.applicationName) list"
            ],
            shortTitle: "Show Tasks",
            systemImageName: "list.bullet"
        )
    }
}
```

### 3.2 Siri Tip View

Educate users that Siri works with your app:

```swift
struct HomeView: View {
    var body: some View {
        VStack {
            // ... your content

            SiriTipView(intent: AddTaskIntent())
                .siriTipViewStyle(.automatic)
        }
    }
}
```

### 3.3 Siri Requirements

- Phrases must include `\(.applicationName)` so Siri knows which app
- Keep phrases natural and conversational
- Test on-device -- Siri recognition varies by accent and phrasing
- Maximum 10 App Shortcuts per app

---

## 4. Shortcuts App Integration

All `AppIntent` types with `isDiscoverable = true` (default) automatically appear in the Shortcuts app.

### 4.1 Organizing with AppShortcutsProvider

```swift
// Intents appear in Shortcuts under your app name.
// The AppShortcutsProvider also creates pre-built shortcuts
// users can add with one tap from the Shortcuts gallery.
```

### 4.2 Opening the App

If your intent needs the app UI:

```swift
struct ComposeTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Compose Task"
    static var openAppWhenRun = true  // Opens the app

    func perform() async throws -> some IntentResult {
        // The app will open; handle navigation via a deep link or state change
        await MainActor.run {
            AppState.shared.showComposer = true
        }
        return .result()
    }
}
```

### 4.3 Returning Results to Shortcuts

Intents can return values that chain into subsequent Shortcuts actions:

```swift
struct CountTasksIntent: AppIntent {
    static var title: LocalizedStringResource = "Count Tasks"

    func perform() async throws -> some IntentResult & ReturnsValue<Int> {
        let count = try await TaskStore.shared.loadAll().count
        return .result(value: count)
    }
}
```

---

## 5. Spotlight Indexing

### 5.1 NSUserActivity (On-Screen Content)

```swift
struct TaskDetailView: View {
    let task: TaskItem

    var body: some View {
        VStack { /* ... */ }
            .userActivity("com.example.myapp.viewTask") { activity in
                activity.title = task.title
                activity.isEligibleForSearch = true
                activity.isEligibleForPrediction = true

                let attributes = CSSearchableItemAttributeSet(contentType: .content)
                attributes.contentDescription = task.notes
                activity.contentAttributeSet = attributes
            }
    }
}
```

### 5.2 CSSearchableIndex (Background Indexing)

```swift
import CoreSpotlight

struct SpotlightIndexer {
    static func indexTasks(_ tasks: [TaskItem]) {
        let items = tasks.map { task -> CSSearchableItem in
            let attributes = CSSearchableItemAttributeSet(contentType: .content)
            attributes.title = task.title
            attributes.contentDescription = task.notes
            attributes.keywords = [task.category, "task"]

            return CSSearchableItem(
                uniqueIdentifier: task.id,
                domainIdentifier: "com.example.myapp.tasks",
                attributeSet: attributes
            )
        }

        CSSearchableIndex.default().indexSearchableItems(items) { error in
            if let error { print("Spotlight indexing failed: \(error)") }
        }
    }

    static func deindex(taskId: String) {
        CSSearchableIndex.default().deleteSearchableItems(
            withIdentifiers: [taskId]
        ) { error in
            if let error { print("Spotlight deindex failed: \(error)") }
        }
    }
}
```

### 5.3 Handling Spotlight Taps

```swift
// In your App or AppDelegate
.onContinueUserActivity(CSSearchableItemActionType) { activity in
    guard let id = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return }
    DeepLinkRouter.shared.pending = .task(id: id)
}
```

---

*Version: 0.1.0*
*Last updated: 2026-05-12*
