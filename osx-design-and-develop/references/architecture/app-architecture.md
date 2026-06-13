# macOS SwiftUI App Architecture

## Pattern Decision Tree

```
Is your app document-based?
├── Yes → FileDocument or ReferenceFileDocument (see below)
└── No → Is state complex with many side effects?
         ├── Yes → TCA (The Composable Architecture)
         │         When: large team, testability is critical, Redux background
         └── No → @Observable + MVVM
                  When: 1-3 dev team, standard CRUD/nav app (default choice)
```

**Default to @Observable + MVVM.** TCA has real overhead — only adopt it if you need
its testing model or already know it.

---

## MVVM with @Observable (macOS 14+)

```swift
// Model
struct Project: Identifiable, Codable {
    let id: UUID
    var name: String
    var items: [Item]
}

// ViewModel — one per window scene
@Observable
final class ProjectViewModel {
    var project: Project
    var selectedItemID: Item.ID?
    var isLoading = false
    var error: Error?

    private let repository: ProjectRepository

    init(project: Project, repository: ProjectRepository = .shared) {
        self.project = project
        self.repository = repository
    }

    func save() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await repository.save(project)
        } catch {
            self.error = error
        }
    }
}

// View — reads directly from @Observable (no @ObservedObject needed)
struct ProjectView: View {
    var viewModel: ProjectViewModel      // @Observable: no property wrapper needed

    var body: some View {
        List(viewModel.project.items) { item in
            Text(item.name)
        }
        .toolbar {
            ToolbarItem {
                Button("Save") { Task { await viewModel.save() } }
            }
        }
    }
}
```

---

## Multi-Window State Strategy

### Each window owns its ViewModel (recommended for document apps)

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(ProjectViewModel())   // fresh VM per window
        }
    }
}
```

### Shared singleton state (for app-wide data)

```swift
// Global state that survives window open/close
@Observable
final class AppState {
    static let shared = AppState()
    var recentProjects: [ProjectSummary] = []
    var preferences: AppPreferences = .default
}

@main
struct MyApp: App {
    private var appState = AppState.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)        // injected, not owned per-window
        }
        Settings {
            SettingsView()
                .environment(appState)
        }
    }
}
```

**Rule:** Per-window ViewModels for document/editing state. Shared singleton for
preferences, recent files, authentication, and app-wide caches.

---

## FileDocument vs ReferenceFileDocument

| | FileDocument | ReferenceFileDocument |
|---|---|---|
| Mutability | Value type (struct) | Reference type (class) |
| Undo | Auto (SwiftUI manages snapshots) | Manual (UndoManager) |
| File size | Small–medium | Large / streaming |
| Use case | Simple formats, JSON/plain text | Images, video, binary blobs |
| SwiftUI scene | `DocumentGroup` | `DocumentGroup` |

```swift
// FileDocument — value semantics, undo is free
struct NoteDocument: FileDocument {
    static var readableContentTypes = [UTType.plainText]
    var text: String = ""

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}

// Scene
WindowGroup {
    DocumentGroup(newDocument: NoteDocument()) { file in
        NoteEditorView(document: file.$document)
    }
}
```

---

## Service Layer

Keep ViewModels thin. Services own I/O.

```swift
// Filesystem service
actor ProjectRepository {
    static let shared = ProjectRepository()

    private let baseURL: URL = {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!.appendingPathComponent(Bundle.main.bundleIdentifier!)
    }()

    func save(_ project: Project) throws {
        let url = baseURL.appendingPathComponent("\(project.id).json")
        let data = try JSONEncoder().encode(project)
        try data.write(to: url, options: .atomic)
    }

    func load(id: UUID) throws -> Project {
        let url = baseURL.appendingPathComponent("\(id).json")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Project.self, from: data)
    }
}

// Keychain service
struct KeychainService {
    static func store(key: String, value: String) throws {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.saveFailed(status) }
    }

    static func retrieve(key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8)
        else { throw KeychainError.notFound }
        return value
    }
}
```

---

## Dependency Injection

Use environment injection for testability. Avoid singletons in ViewModels.

```swift
// Protocol-based DI
protocol ProjectRepositoryProtocol {
    func save(_ project: Project) async throws
    func load(id: UUID) async throws -> Project
}

// Production
actor LiveProjectRepository: ProjectRepositoryProtocol { ... }

// Test / Preview
actor MockProjectRepository: ProjectRepositoryProtocol {
    var projects: [UUID: Project] = [:]
    func save(_ project: Project) { projects[project.id] = project }
    func load(id: UUID) throws -> Project {
        guard let p = projects[id] else { throw RepositoryError.notFound }
        return p
    }
}

// ViewModel takes protocol
@Observable
final class ProjectViewModel {
    private let repository: any ProjectRepositoryProtocol

    init(repository: any ProjectRepositoryProtocol = LiveProjectRepository.shared) {
        self.repository = repository
    }
}

// Previews use mock
#Preview {
    ProjectView(viewModel: ProjectViewModel(repository: MockProjectRepository()))
}
```
