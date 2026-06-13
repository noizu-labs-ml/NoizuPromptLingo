# macOS SwiftUI State Management

## Web-to-SwiftUI Concept Mapping

| Web / React / Vue | SwiftUI macOS | Notes |
|---|---|---|
| `useState` | `@State` | Local component state, value type |
| `useRef` | `@State` (class) or stored property | Mutable ref without re-render |
| `useContext` / Context.Provider | `@Environment` + `.environment()` | Dependency injection down the tree |
| Redux store / Zustand | `@Observable` singleton | App-wide shared state |
| Props | View initializer params | Passed in, owned by parent |
| Two-way binding (`v-model`) | `@Binding` | Child reads/writes parent state |
| `localStorage` | `@AppStorage` | UserDefaults-backed persistence |
| `IndexedDB` / local DB | SwiftData (`@Query`) | Structured persistent storage |
| React Query / SWR | `async/await` + `@Observable` | No built-in; use actor + Task |
| Derived/computed state | `var` computed property on `@Observable` | Automatic re-evaluation |
| `useReducer` | `@Observable` with methods | Methods are the reducers |
| Vuex mutations | Methods on `@Observable` class | Mutations are just functions |

---

## @Observable (macOS 14+, Swift 5.9)

Modern replacement for `ObservableObject`. No `@Published` needed.

```swift
@Observable
final class AppModel {
    // All stored properties are automatically observed
    var documents: [Document] = []
    var currentUser: User?
    var isLoading = false

    // Computed properties work as derived state
    var documentCount: Int { documents.count }
    var hasUser: Bool { currentUser != nil }

    // Opt-out of observation for private internals
    @ObservationIgnored private var cache: [UUID: Document] = [:]
}

// In views — no property wrapper needed when reading from @Observable
struct DocumentListView: View {
    var model: AppModel    // Swift infers observation automatically

    var body: some View {
        // This view re-renders only when model.documents changes
        // NOT when model.isLoading changes (if body doesn't use it)
        List(model.documents) { doc in
            Text(doc.name)
        }
    }
}
```

---

## @State, @Binding, @Environment

```swift
// @State — private, local, value semantics
struct ToggleRow: View {
    @State private var isExpanded = false    // owned here

    var body: some View {
        DisclosureGroup("Details", isExpanded: $isExpanded) {
            Text("Hidden content")
        }
    }
}

// @Binding — two-way link to parent's @State
struct ColorPicker: View {
    @Binding var color: Color    // not owned; comes from parent

    var body: some View {
        // changes here propagate up to parent's @State
        Slider(value: Binding(
            get: { color.components.red },
            set: { color = Color(red: $0, green: 0, blue: 0) }
        ))
    }
}

// @Environment — read values injected from ancestor views
struct ThemedButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(AppModel.self) var appModel    // custom @Observable injection

    var body: some View {
        Button("Close") { dismiss() }
            .tint(colorScheme == .dark ? .white : .black)
    }
}

// Injecting into environment
WindowGroup {
    ContentView()
        .environment(AppModel())       // @Observable type
        .environment(\.locale, .init(identifier: "en_US"))
}
```

---

## @AppStorage

UserDefaults-backed, persists across launches.

```swift
struct PreferencesView: View {
    @AppStorage("editorFontSize") private var fontSize: Double = 14
    @AppStorage("showLineNumbers") private var showLineNumbers = true
    @AppStorage("themeName") private var themeName = "default"

    var body: some View {
        Form {
            Slider(value: $fontSize, in: 10...24, step: 1) {
                Text("Font Size: \(Int(fontSize))pt")
            }
            Toggle("Show Line Numbers", isOn: $showLineNumbers)
        }
    }
}

// AppStorage in @Observable class (for shared access)
@Observable
final class Preferences {
    @ObservationIgnored
    @AppStorage("fontSize") var fontSize: Double = 14

    @ObservationIgnored
    @AppStorage("theme") var theme: String = "default"
}
```

---

## Cross-Window State Coordination

Windows in macOS share the same process. Use a shared singleton for state
that must be consistent across windows.

```swift
@Observable
final class WindowCoordinator {
    static let shared = WindowCoordinator()

    var openDocuments: [Document.ID: Document] = [:]
    var focusedWindowID: UUID?

    func open(_ document: Document) {
        openDocuments[document.id] = document
    }

    func close(id: Document.ID) {
        openDocuments.removeValue(forKey: id)
    }
}

// Each window registers itself
struct DocumentWindowView: View {
    let windowID = UUID()
    let document: Document
    @Environment(WindowCoordinator.self) var coordinator

    var body: some View {
        EditorView(document: document)
            .onAppear { coordinator.open(document) }
            .onDisappear { coordinator.close(id: document.id) }
    }
}
```

---

## Undo / Redo with UndoManager

```swift
@Observable
final class CanvasViewModel {
    var shapes: [Shape] = []
    var undoManager: UndoManager?    // injected from view

    func addShape(_ shape: Shape) {
        shapes.append(shape)
        undoManager?.registerUndo(withTarget: self) { target in
            target.removeShape(id: shape.id)
        }
        undoManager?.setActionName("Add Shape")
    }

    func removeShape(id: Shape.ID) {
        guard let idx = shapes.firstIndex(where: { $0.id == id }) else { return }
        let removed = shapes[idx]
        shapes.remove(at: idx)
        undoManager?.registerUndo(withTarget: self) { target in
            target.addShape(removed)
        }
        undoManager?.setActionName("Remove Shape")
    }
}

// Read UndoManager from environment
struct CanvasView: View {
    @Environment(\.undoManager) var undoManager
    var vm: CanvasViewModel

    var body: some View {
        DrawingCanvas()
            .onAppear { vm.undoManager = undoManager }
    }
}
```

---

## SwiftData Integration (@Query)

SwiftData is the modern Core Data replacement. Available macOS 14+.

```swift
import SwiftData

// Model definition
@Model
final class Note {
    var title: String
    var body: String
    var createdAt: Date
    var tags: [String]

    init(title: String, body: String = "") {
        self.title = title
        self.body = body
        self.createdAt = .now
        self.tags = []
    }
}

// App setup
@main
struct NoteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Note.self)    // creates/migrates store automatically
    }
}

// Querying in views
struct NoteListView: View {
    @Query(sort: \Note.createdAt, order: .reverse) private var notes: [Note]
    @Environment(\.modelContext) private var context

    var body: some View {
        List(notes) { note in
            Text(note.title)
        }
        .toolbar {
            Button("Add") {
                let note = Note(title: "Untitled")
                context.insert(note)    // auto-saves
            }
        }
    }
}

// Filtered query
@Query(
    filter: #Predicate<Note> { note in
        note.tags.contains("important")
    },
    sort: \Note.createdAt
)
private var importantNotes: [Note]
```

---

## State Scope Summary

| Scope | Tool | Lives in |
|---|---|---|
| Single view | `@State` | View struct (stack) |
| Parent ↔ child | `@Binding` | Derived from parent's `@State` |
| Feature/screen | `@Observable` ViewModel | Injected via environment |
| App-wide | `@Observable` singleton | `AppState.shared` |
| User preferences | `@AppStorage` | UserDefaults / plist |
| Persistent data | `@Query` + `@Model` | SwiftData SQLite store |
| System config | `@Environment(\.)` | SwiftUI environment |
| Cross-window | Shared `@Observable` | Process memory (singleton) |
