# Swift Essentials for macOS Development

## Property Wrappers — When to Use What

### @Observable (Swift 5.9+, recommended)
The modern replacement for `ObservableObject`. Less boilerplate, more efficient.

```swift
@Observable
class DocumentStore {
    var documents: [Document] = []
    var isLoading = false

    func load() async {
        isLoading = true
        documents = await fetchDocuments()
        isLoading = false
    }
}

// In view — no @ObservedObject/@StateObject needed
struct ContentView: View {
    @State private var store = DocumentStore()
    var body: some View {
        List(store.documents) { doc in DocumentRow(doc: doc) }
    }
}
```

### @AppStorage — Persistent User Defaults
```swift
@AppStorage("selectedTheme") private var selectedTheme = "system"
@AppStorage("windowWidth") private var windowWidth = 900.0

// Works across app restarts. Backed by UserDefaults.
// Use for: preferences, last-selected items, UI state that persists.
```

### @Environment — System and Injected Values
```swift
@Environment(\.colorScheme) var colorScheme
@Environment(\.openWindow) var openWindow
@Environment(\.dismiss) var dismiss
@Environment(\.openURL) var openURL

// Inject custom values down the tree
struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppRouter? = nil
}
extension EnvironmentValues {
    var router: AppRouter? {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
```

### @SceneStorage — Per-Window State
Persists state per window/scene, restored on relaunch:
```swift
@SceneStorage("selectedTab") private var selectedTab = "inbox"
@SceneStorage("splitPosition") private var splitPosition = 250.0
```

---

## Async/Await Patterns

### Task Lifecycle in Views
```swift
.task {
    // Cancelled automatically when view disappears
    await store.load()
}

.task(id: selectedID) {
    // Re-runs when selectedID changes, cancels previous
    guard let id = selectedID else { return }
    detail = await fetchDetail(id: id)
}
```

### Actor for Thread-Safe State
```swift
actor DataCache {
    private var cache: [String: Data] = [:]

    func get(_ key: String) -> Data? { cache[key] }
    func set(_ key: String, value: Data) { cache[key] = value }
}

// MainActor for UI-bound state
@MainActor
class UIStateManager {
    var items: [Item] = []  // Safe to read from views
}
```

### AsyncStream for Continuous Data
```swift
func watchFile(at url: URL) -> AsyncStream<FileChange> {
    AsyncStream { continuation in
        let watcher = FileSystemWatcher(url: url) { change in
            continuation.yield(change)
        }
        continuation.onTermination = { _ in watcher.stop() }
        watcher.start()
    }
}

// Consume in view
.task {
    for await change in watchFile(at: projectURL) {
        handleChange(change)
    }
}
```

---

## Codable — Practical Patterns

```swift
struct Config: Codable {
    var theme: String = "system"
    var recentFiles: [URL] = []
    var windowSize: CGSize = CGSize(width: 900, height: 600)

    // Custom key mapping
    enum CodingKeys: String, CodingKey {
        case theme, recentFiles
        case windowSize = "window_size"
    }
}

// Save/load from Application Support
extension Config {
    static var fileURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MyApp/config.json")
    }

    func save() throws {
        let data = try JSONEncoder().encode(self)
        try data.write(to: Config.fileURL, options: .atomic)
    }

    static func load() -> Config {
        guard let data = try? Data(contentsOf: fileURL),
              let config = try? JSONDecoder().decode(Config.self, from: data)
        else { return Config() }
        return config
    }
}
```

---

## Transferable — Drag and Drop / Clipboard

```swift
struct ProjectFile: Transferable {
    var name: String
    var content: Data

    static var transferRepresentation: some TransferRepresentation {
        // Export as file to Finder
        FileRepresentation(exportedContentType: .plainText) { file in
            SentTransferredFile(file.exportedURL)
        }
        // Import dropped files
        FileRepresentation(importedContentType: .plainText) { received in
            ProjectFile(name: received.file.lastPathComponent,
                       content: try Data(contentsOf: received.file))
        }
        // Copy/paste as data
        DataRepresentation(contentType: .data) { file in
            file.content
        } importing: { data in
            ProjectFile(name: "Imported", content: data)
        }
    }
}

// Use in view
.draggable(projectFile)
.dropDestination(for: ProjectFile.self) { items, location in
    handleDrop(items)
    return true
}
```

---

## UTType — File Type Declarations

Declare custom file types in Info.plist AND in code:

```swift
import UniformTypeIdentifiers

extension UTType {
    // For a custom file format your app owns
    static let myProjectFile = UTType(exportedAs: "com.myapp.project")
    // For reading a third-party format
    static let someFormat = UTType(importedAs: "com.other.format")
}

// Use in document-based apps
struct MyDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.myProjectFile, .plainText] }
    static var writableContentTypes: [UTType] { [.myProjectFile] }
}
```

---

## NSWorkspace — System Integration

```swift
import AppKit

// Open file in default app
NSWorkspace.shared.open(fileURL)

// Open URL in browser
NSWorkspace.shared.open(URL(string: "https://example.com")!)

// Reveal file in Finder
NSWorkspace.shared.activateFileViewerSelecting([fileURL])

// Get default app for file type
let app = NSWorkspace.shared.urlForApplication(toOpen: fileURL)

// Watch for app launch/quit events
let notif = NSWorkspace.shared.notificationCenter
notif.addObserver(forName: NSWorkspace.didLaunchApplicationNotification,
                  object: nil, queue: .main) { note in
    let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    print("Launched: \(app?.localizedName ?? "unknown")")
}
```

---

## Process — CLI Integration

Run shell commands and capture output:

```swift
func runCommand(_ executable: String, arguments: [String]) async throws -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    try process.run()
    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard process.terminationStatus == 0 else {
        throw CommandError.failed(String(data: data, encoding: .utf8) ?? "")
    }
    return String(data: data, encoding: .utf8) ?? ""
}

// Usage
let output = try await runCommand("/usr/bin/git", arguments: ["status", "--short"])
```

For long-running processes with streaming output:
```swift
process.standardOutput = pipe
pipe.fileHandleForReading.readabilityHandler = { handle in
    let data = handle.availableData
    guard !data.isEmpty else { return }
    DispatchQueue.main.async {
        self.output += String(data: data, encoding: .utf8) ?? ""
    }
}
```
