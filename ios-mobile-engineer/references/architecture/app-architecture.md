# App Architecture Patterns for iOS

> For web developers: iOS architecture through the lens of React, Redux, and component patterns you already know.

---

## MVVM — The Default Choice

**Mental model:** A ViewModel is a custom React hook fused with a Zustand store. It holds state, exposes actions, and the View (SwiftUI) re-renders when state changes.

### The Pattern

```
View (SwiftUI)  <-->  ViewModel (@Observable class)  <-->  Model / Services
   renders              holds state, logic                 data layer
```

### Code Example

```swift
import SwiftUI
import Observation

// Model — plain data (like a TypeScript interface)
struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var isComplete: Bool
}

// ViewModel — like a custom hook that returns state + actions
@Observable
class TaskListViewModel {
    var tasks: [Task] = []
    var isLoading = false
    var errorMessage: String?

    private let api: TaskAPIProtocol

    init(api: TaskAPIProtocol = TaskAPI()) {
        self.api = api
    }

    func loadTasks() async {
        isLoading = true
        defer { isLoading = false }
        do {
            tasks = try await api.fetchTasks()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleComplete(_ task: Task) async {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isComplete.toggle()
        try? await api.updateTask(tasks[index])
    }
}

// View — purely declarative, like a React component
struct TaskListView: View {
    @State private var viewModel = TaskListViewModel()

    var body: some View {
        List(viewModel.tasks) { task in
            TaskRow(task: task) {
                Task { await viewModel.toggleComplete(task) }
            }
        }
        .overlay {
            if viewModel.isLoading { ProgressView() }
        }
        .task { await viewModel.loadTasks() }
    }
}
```

### Web Analogy

| iOS (MVVM)                | React Equivalent                          |
|---------------------------|-------------------------------------------|
| `@Observable` ViewModel   | Custom hook + Zustand store               |
| `@State private var vm`   | `const store = useMyStore()`              |
| `.task { await ... }`     | `useEffect(() => { fetch... }, [])`       |
| View's `body`             | Component's `return` JSX                  |

---

## TCA — The Composable Architecture

**Mental model:** TCA is Redux + middleware for iOS. Actions go in, state comes out, side effects run through an `Effect` system (like Redux-Saga or Redux-Thunk, but type-safe).

### Core Concepts Mapped to Redux

| TCA Concept   | Redux Equivalent        | Purpose                              |
|---------------|-------------------------|--------------------------------------|
| `State`       | Redux state slice       | All data for this feature            |
| `Action`      | Action type union       | Every event that can happen          |
| `Reducer`     | Reducer function        | Pure state transitions               |
| `Effect`      | Thunk / Saga            | Async side effects                   |
| `Store`       | Redux store             | Holds state, dispatches actions      |
| `Scope`       | `useSelector` + slice   | Child gets a focused view of state   |

### Code Example

```swift
import ComposableArchitecture

@Reducer
struct TaskListFeature {
    @ObservableState
    struct State: Equatable {
        var tasks: [Task] = []
        var isLoading = false
    }

    enum Action {
        case onAppear
        case tasksLoaded([Task])
        case loadFailed(String)
        case toggleTask(Task)
    }

    @Dependency(\.taskAPI) var taskAPI

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let tasks = try await taskAPI.fetchTasks()
                    await send(.tasksLoaded(tasks))
                } catch: { error, send in
                    await send(.loadFailed(error.localizedDescription))
                }

            case .tasksLoaded(let tasks):
                state.isLoading = false
                state.tasks = tasks
                return .none

            case .loadFailed:
                state.isLoading = false
                return .none

            case .toggleTask(let task):
                guard let i = state.tasks.firstIndex(where: { $0.id == task.id }) else {
                    return .none
                }
                state.tasks[i].isComplete.toggle()
                return .run { [updated = state.tasks[i]] _ in
                    try await taskAPI.updateTask(updated)
                }
            }
        }
    }
}

// View — dispatches actions, reads state
struct TaskListView: View {
    let store: StoreOf<TaskListFeature>

    var body: some View {
        List(store.tasks) { task in
            TaskRow(task: task) {
                store.send(.toggleTask(task))
            }
        }
        .overlay {
            if store.isLoading { ProgressView() }
        }
        .onAppear { store.send(.onAppear) }
    }
}
```

### When TCA Shines

- Teams of 3+ developers (action log = built-in debugging)
- Complex state dependencies between features
- You want exhaustive testing of every state transition
- You already think in Redux patterns

---

## Clean Architecture — For Larger Apps

**Mental model:** Layered like a backend — controllers, use cases, repositories. Each layer only knows about the layer below it. Dependency inversion everywhere.

### Layer Map

```
┌─────────────────────────────┐
│  Presentation (Views + VM)  │  ← SwiftUI views, ViewModels
├─────────────────────────────┤
│  Domain (Use Cases)         │  ← Business logic, pure Swift
├─────────────────────────────┤
│  Data (Repositories)        │  ← API clients, persistence, caching
└─────────────────────────────┘
```

### Project Structure

```
Sources/
├── App/
│   └── MyApp.swift
├── Presentation/
│   ├── TaskList/
│   │   ├── TaskListView.swift
│   │   └── TaskListViewModel.swift
│   └── TaskDetail/
│       ├── TaskDetailView.swift
│       └── TaskDetailViewModel.swift
├── Domain/
│   ├── Models/
│   │   └── Task.swift
│   ├── UseCases/
│   │   ├── FetchTasksUseCase.swift
│   │   └── ToggleTaskUseCase.swift
│   └── Repositories/
│       └── TaskRepositoryProtocol.swift    ← protocol only
└── Data/
    ├── Repositories/
    │   └── TaskRepository.swift            ← concrete implementation
    ├── Network/
    │   └── TaskAPI.swift
    └── Persistence/
        └── TaskStorage.swift
```

### When Clean Architecture Shines

- App has 15+ screens
- Multiple data sources (API + local DB + cache)
- Team needs strict boundary enforcement
- Domain logic must be testable without UI or network

---

## Decision Matrix

| Factor                    | MVVM          | TCA              | Clean Arch      |
|---------------------------|---------------|------------------|-----------------|
| Team size                 | 1-3           | 2-6              | 4+              |
| App complexity            | Small-medium  | Medium-large     | Large           |
| Learning curve            | Low           | Medium-high      | Medium          |
| Testing story             | Good          | Excellent        | Excellent       |
| Boilerplate               | Minimal       | Moderate         | Heavy           |
| State predictability      | Good          | Excellent        | Good            |
| Web developer familiarity | Hook-like     | Redux-like       | Backend-like    |
| Dependency                | None (native) | pointfreeco/tca  | None (patterns) |

### Quick Decision Guide

1. **Solo dev, < 10 screens** — MVVM. Ship fast, refactor later.
2. **Team project, complex state** — TCA. Action logs and testability pay for the boilerplate.
3. **Enterprise, multi-module** — Clean Architecture with MVVM at the presentation layer.
4. **Prototype / hackathon** — Inline `@State` in views. Refactor to MVVM when it gets messy.

---

## Project Structure Templates

### MVVM (Feature-Based)

```
Sources/
├── App/
│   ├── MyApp.swift
│   └── AppRouter.swift
├── Features/
│   ├── TaskList/
│   │   ├── TaskListView.swift
│   │   ├── TaskListViewModel.swift
│   │   └── TaskRow.swift
│   └── Settings/
│       ├── SettingsView.swift
│       └── SettingsViewModel.swift
├── Models/
│   └── Task.swift
├── Services/
│   ├── TaskAPI.swift
│   └── AuthService.swift
└── Shared/
    ├── Components/
    └── Extensions/
```

### TCA (Feature-Based)

```
Sources/
├── App/
│   ├── MyApp.swift
│   └── AppFeature.swift           ← root reducer, composes child features
├── Features/
│   ├── TaskList/
│   │   ├── TaskListFeature.swift  ← State + Action + Reducer
│   │   └── TaskListView.swift
│   └── Settings/
│       ├── SettingsFeature.swift
│       └── SettingsView.swift
├── Models/
│   └── Task.swift
└── Dependencies/
    ├── TaskAPIClient.swift         ← @DependencyClient
    └── LiveDependencies.swift
```

### Key Takeaway

Start with MVVM. It maps cleanly to React mental models, has zero dependencies, and Apple's own tutorials teach it. Graduate to TCA or Clean Architecture when complexity demands it — not before.
