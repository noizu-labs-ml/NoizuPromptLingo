# Data Persistence Patterns

> Storage strategies for iOS apps: SwiftData for modern apps, Core Data for legacy, UserDefaults for preferences, Keychain for secrets, and file system for documents. Includes a decision matrix for choosing the right approach.

## Table of Contents

- [1. SwiftData (iOS 17+)](#1-swiftdata-ios-17)
- [2. Core Data (Legacy)](#2-core-data-legacy)
- [3. UserDefaults](#3-userdefaults)
- [4. Keychain](#4-keychain)
- [5. File System Storage](#5-file-system-storage)
- [6. Decision Matrix](#6-decision-matrix)

---

## 1. SwiftData (iOS 17+)

### 1.1 Model Definition

```swift
import SwiftData

@Model
final class Task {
    var title: String
    var notes: String
    var isCompleted: Bool
    var createdAt: Date
    var dueDate: Date?

    @Relationship(deleteRule: .cascade)
    var subtasks: [Subtask] = []

    @Relationship(inverse: \Category.tasks)
    var category: Category?

    init(title: String, notes: String = "", dueDate: Date? = nil) {
        self.title = title
        self.notes = notes
        self.isCompleted = false
        self.createdAt = .now
        self.dueDate = dueDate
    }
}

@Model
final class Subtask {
    var title: String
    var isCompleted: Bool

    init(title: String) {
        self.title = title
        self.isCompleted = false
    }
}

@Model
final class Category {
    @Attribute(.unique) var name: String
    var tasks: [Task] = []

    init(name: String) {
        self.name = name
    }
}
```

### 1.2 Container Setup

```swift
import SwiftUI
import SwiftData

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Task.self, Category.self])
    }
}
```

### 1.3 Queries and CRUD

```swift
struct TaskListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Task.createdAt, order: .reverse) private var tasks: [Task]

    // Filtered query
    @Query(
        filter: #Predicate<Task> { $0.isCompleted == false },
        sort: \Task.dueDate
    ) private var pendingTasks: [Task]

    var body: some View {
        List(tasks) { task in
            TaskRow(task: task)
        }
    }

    func addTask(title: String) {
        let task = Task(title: title)
        context.insert(task)
        // SwiftData auto-saves; explicit save if needed:
        // try? context.save()
    }

    func deleteTask(_ task: Task) {
        context.delete(task)
    }
}
```

### 1.4 Relationship Queries

```swift
// Fetch tasks with a specific category
@Query(
    filter: #Predicate<Task> { task in
        task.category?.name == "Work"
    }
) private var workTasks: [Task]
```

---

## 2. Core Data (Legacy)

### 2.1 Stack Setup

```swift
import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error { fatalError("Core Data failed: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func save() {
        let ctx = container.viewContext
        guard ctx.hasChanges else { return }
        try? ctx.save()
    }
}
```

### 2.2 Fetch Request in SwiftUI

```swift
struct CoreDataListView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        predicate: NSPredicate(format: "isCompleted == NO")
    ) private var items: FetchedResults<Item>

    var body: some View {
        List(items) { item in
            Text(item.title ?? "Untitled")
        }
    }
}
```

---

## 3. UserDefaults

### 3.1 Simple Preferences

```swift
// Direct access
UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
let completed = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

// Property wrapper in SwiftUI
struct SettingsView: View {
    @AppStorage("theme") private var theme = "system"
    @AppStorage("notificationsEnabled") private var notifications = true

    var body: some View {
        Form {
            Picker("Theme", selection: $theme) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            Toggle("Notifications", isOn: $notifications)
        }
    }
}
```

### 3.2 Custom Codable Storage

```swift
extension UserDefaults {
    func setCodable<T: Codable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            set(data, forKey: key)
        }
    }

    func codable<T: Codable>(forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
```

**Limits:** Do not store large objects, images, or arrays with more than a few hundred items. UserDefaults is backed by a plist loaded entirely into memory.

---

## 4. Keychain

### 4.1 Keychain Wrapper

```swift
import Security

enum KeychainError: Error {
    case duplicateItem, itemNotFound, unexpectedStatus(OSStatus)
}

struct KeychainService {
    static func save(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let update = [kSecValueData as String: data]
            let s = SecItemUpdate(query as CFDictionary, update as CFDictionary)
            guard s == errSecSuccess else { throw KeychainError.unexpectedStatus(s) }
        } else if status != errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    static func load(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.itemNotFound
        }
        return data
    }

    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
```

**Use for:** API tokens, passwords, OAuth refresh tokens, encryption keys. Never store secrets in UserDefaults.

---

## 5. File System Storage

### 5.1 Document Storage

```swift
struct FileStorage {
    static var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static func save<T: Codable>(_ object: T, filename: String) throws {
        let url = documentsURL.appendingPathComponent(filename)
        let data = try JSONEncoder().encode(object)
        try data.write(to: url, options: .atomic)
    }

    static func load<T: Codable>(filename: String) throws -> T {
        let url = documentsURL.appendingPathComponent(filename)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

### 5.2 Directory Locations

| Directory | Purpose | Backed Up |
|-----------|---------|-----------|
| `.documentDirectory` | User-generated content | Yes |
| `.cachesDirectory` | Re-downloadable data | No |
| `.applicationSupportDirectory` | App-managed data | Yes |
| `.temporaryDirectory` | Scratch files | No |

---

## 6. Decision Matrix

| Criteria | SwiftData | Core Data | UserDefaults | Keychain | File System |
|----------|-----------|-----------|--------------|----------|-------------|
| **Best for** | Structured models | Complex legacy | Simple prefs | Secrets | Documents, media |
| **Min iOS** | 17 | 11 | 2 | 2 | 2 |
| **Relationships** | Yes | Yes | No | No | Manual |
| **Query support** | Predicates | NSPredicate | Key lookup | Key lookup | Manual |
| **Thread safety** | Actor-based | Context-based | Thread-safe | Thread-safe | Manual |
| **Encryption** | No (use Data Protection) | No | No | Yes (hardware) | Manual |
| **iCloud sync** | Built-in | CloudKit | NSUbiquitousKeyValueStore | Shared keychain | iCloud Drive |

**Rules of thumb:**

- **< 1 KB, key-value** -- UserDefaults
- **Credentials/tokens** -- Keychain, always
- **Structured data with queries** -- SwiftData (iOS 17+) or Core Data
- **Large files, images, exports** -- File system
- **Need offline + sync** -- SwiftData with CloudKit or Core Data with NSPersistentCloudKitContainer

---

*Version: 0.1.0*
*Last updated: 2026-05-12*
