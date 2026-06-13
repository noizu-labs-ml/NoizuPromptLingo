# Widgets and Extensions

> WidgetKit fundamentals, App Intents for configuration, interactive widgets (iOS 17+), Live Activities, Dynamic Island, and common app extensions.

## Table of Contents

- [1. WidgetKit Fundamentals](#1-widgetkit-fundamentals)
- [2. App Intents for Configuration](#2-app-intents-for-configuration)
- [3. Interactive Widgets (iOS 17+)](#3-interactive-widgets-ios-17)
- [4. Live Activities and Dynamic Island](#4-live-activities-and-dynamic-island)
- [5. Share and Action Extensions](#5-share-and-action-extensions)

---

## 1. WidgetKit Fundamentals

### 1.1 Timeline Provider

Widgets are not live views. They are timeline-based snapshots that the system renders at scheduled points.

```swift
import WidgetKit
import SwiftUI

struct TaskEntry: TimelineEntry {
    let date: Date
    let taskTitle: String
    let taskCount: Int
    let isPlaceholder: Bool
}

struct TaskWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(date: .now, taskTitle: "Buy groceries", taskCount: 5, isPlaceholder: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> Void) {
        let entry = TaskEntry(date: .now, taskTitle: "Buy groceries", taskCount: 5, isPlaceholder: false)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> Void) {
        // Fetch current data from shared storage (App Group)
        let tasks = SharedDataStore.loadTasks()
        let entry = TaskEntry(
            date: .now,
            taskTitle: tasks.first?.title ?? "No tasks",
            taskCount: tasks.count,
            isPlaceholder: false
        )

        // Refresh in 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}
```

### 1.2 Widget View

```swift
struct TaskWidgetView: View {
    let entry: TaskEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    var smallView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle")
                Text("\(entry.taskCount)")
                    .font(.title.bold())
            }
            Text(entry.taskTitle)
                .font(.caption)
                .lineLimit(2)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }

    var mediumView: some View {
        HStack {
            smallView
            Spacer()
            // Additional content for medium size
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}
```

### 1.3 Widget Declaration

```swift
@main
struct TaskWidget: Widget {
    let kind: String = "TaskWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TaskWidgetProvider()) { entry in
            TaskWidgetView(entry: entry)
        }
        .configurationDisplayName("Tasks")
        .description("See your upcoming tasks at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
```

### 1.4 Shared Data via App Groups

```swift
// In both app target and widget extension target
struct SharedDataStore {
    static let suiteName = "group.com.example.myapp"

    static func saveTasks(_ tasks: [TaskItem]) {
        let defaults = UserDefaults(suiteName: suiteName)
        if let data = try? JSONEncoder().encode(tasks) {
            defaults?.set(data, forKey: "tasks")
        }
    }

    static func loadTasks() -> [TaskItem] {
        let defaults = UserDefaults(suiteName: suiteName)
        guard let data = defaults?.data(forKey: "tasks") else { return [] }
        return (try? JSONDecoder().decode([TaskItem].self, from: data)) ?? []
    }
}

// Trigger widget refresh from the main app
WidgetCenter.shared.reloadTimelines(ofKind: "TaskWidget")
```

---

## 2. App Intents for Configuration

### 2.1 Configurable Widget (iOS 17+)

```swift
import AppIntents
import WidgetKit

struct SelectCategoryIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Category"
    static var description: IntentDescription = "Choose which task category to display."

    @Parameter(title: "Category")
    var category: CategoryEntity?
}

struct CategoryEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Category")
    static var defaultQuery = CategoryQuery()

    var id: String
    var name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct CategoryQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [CategoryEntity] {
        SharedDataStore.loadCategories()
            .filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [CategoryEntity] {
        SharedDataStore.loadCategories()
    }
}
```

### 2.2 Using Intent in Widget

```swift
struct ConfigurableTaskWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "ConfigurableTaskWidget",
            intent: SelectCategoryIntent.self,
            provider: ConfigurableTaskProvider()
        ) { entry in
            TaskWidgetView(entry: entry)
        }
        .configurationDisplayName("Tasks by Category")
        .description("Show tasks from a specific category.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
```

---

## 3. Interactive Widgets (iOS 17+)

Widgets can now contain `Button` and `Toggle` that trigger App Intents without opening the app.

```swift
struct ToggleTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Task"

    @Parameter(title: "Task ID")
    var taskId: String

    init() {}
    init(taskId: String) { self.taskId = taskId }

    func perform() async throws -> some IntentResult {
        var tasks = SharedDataStore.loadTasks()
        if let idx = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[idx].isCompleted.toggle()
            SharedDataStore.saveTasks(tasks)
        }
        return .result()
    }
}

// In widget view
struct InteractiveTaskRow: View {
    let task: TaskItem

    var body: some View {
        Button(intent: ToggleTaskIntent(taskId: task.id)) {
            HStack {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                Text(task.title)
                    .strikethrough(task.isCompleted)
            }
        }
        .buttonStyle(.plain)
    }
}
```

---

## 4. Live Activities and Dynamic Island

See the dedicated [live-activities.md](./live-activities.md) pattern file for full implementation details including ActivityKit setup, push-to-update, and Dynamic Island compact/expanded views.

**Quick summary:**

```swift
// Start a Live Activity
let attributes = OrderAttributes(orderNumber: "1234")
let state = OrderAttributes.ContentState(status: .preparing, eta: 15)
let content = ActivityContent(state: state, staleDate: nil)
let activity = try Activity.request(
    attributes: attributes,
    content: content,
    pushType: .token
)
```

---

## 5. Share and Action Extensions

### 5.1 Share Extension

File > New > Target > Share Extension.

```swift
import SwiftUI

struct ShareView: View {
    let extensionContext: NSExtensionContext?

    @State private var sharedText = ""
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Shared Content") {
                    Text(sharedText)
                }
                Section("Add Note") {
                    TextField("Note", text: $note)
                }
            }
            .navigationTitle("Save to My App")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        extensionContext?.completeRequest(returningItems: nil)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                        extensionContext?.completeRequest(returningItems: nil)
                    }
                }
            }
            .task { await loadSharedContent() }
        }
    }

    func loadSharedContent() async {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else { return }
        for item in items {
            for provider in item.attachments ?? [] {
                if provider.hasItemConformingToTypeIdentifier("public.plain-text") {
                    if let text = try? await provider.loadItem(
                        forTypeIdentifier: "public.plain-text"
                    ) as? String {
                        sharedText = text
                    }
                }
            }
        }
    }

    func saveItem() {
        // Save via App Group shared storage
        SharedDataStore.saveSharedItem(text: sharedText, note: note)
    }
}
```

### 5.2 Extension Memory Limits

| Extension Type | Memory Limit |
|----------------|-------------|
| Widget | ~30 MB |
| Share Extension | ~120 MB |
| Action Extension | ~120 MB |
| Notification Service | ~24 MB |
| Notification Content | ~48 MB |

Extensions are killed if they exceed limits. Keep data processing minimal; delegate heavy work to the main app.

---

*Version: 0.1.0*
*Last updated: 2026-05-12*
