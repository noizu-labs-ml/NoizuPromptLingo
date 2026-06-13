# Dependency Injection in SwiftUI

> For web developers: DI patterns in iOS mapped to React Context, service containers, and testing patterns you already use.

---

## Why DI Matters on iOS

Same reasons as the web: you want to swap real API clients for mocks in tests, configure different backends for staging vs production, and avoid hardcoding dependencies deep in your view tree.

SwiftUI gives you a built-in DI system via `@Environment`. No third-party container needed for most apps.

---

## Pattern 1: Environment Values (SwiftUI's Built-In DI)

**Mental model:** This is React Context, but type-safe and built into the framework. You provide values at a parent level, and any descendant can consume them.

### Step-by-Step Setup

```swift
// STEP 1: Define a protocol for your service (the interface)
protocol TaskServiceProtocol: Sendable {
    func fetchTasks() async throws -> [Task]
    func createTask(_ task: Task) async throws
    func deleteTask(id: UUID) async throws
}

// STEP 2: Create the real implementation
final class TaskService: TaskServiceProtocol {
    private let baseURL: URL

    init(baseURL: URL = URL(string: "https://api.myapp.com")!) {
        self.baseURL = baseURL
    }

    func fetchTasks() async throws -> [Task] {
        let (data, _) = try await URLSession.shared.data(from: baseURL.appending(path: "tasks"))
        return try JSONDecoder().decode([Task].self, from: data)
    }

    func createTask(_ task: Task) async throws { /* ... */ }
    func deleteTask(id: UUID) async throws { /* ... */ }
}

// STEP 3: Register as an Environment value
extension EnvironmentValues {
    @Entry var taskService: any TaskServiceProtocol = TaskService()
}

// STEP 4: Provide at the app root (or any parent)
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.taskService, TaskService())
        }
    }
}

// STEP 5: Consume anywhere in the tree
struct TaskListView: View {
    @Environment(\.taskService) private var taskService
    @State private var tasks: [Task] = []

    var body: some View {
        List(tasks) { task in
            Text(task.title)
        }
        .task {
            tasks = (try? await taskService.fetchTasks()) ?? []
        }
    }
}
```

### React Context Comparison

```tsx
// React equivalent of the above:
const TaskServiceContext = createContext<TaskService>(new TaskService());

function App() {
    return (
        <TaskServiceContext.Provider value={new TaskService()}>
            <ContentView />
        </TaskServiceContext.Provider>
    );
}

function TaskListView() {
    const taskService = useContext(TaskServiceContext);
    const [tasks, setTasks] = useState([]);
    useEffect(() => { taskService.fetchTasks().then(setTasks); }, []);
    // ...
}
```

The SwiftUI version is more concise because `@Environment` handles the boilerplate that React Context requires (createContext, Provider wrapper, useContext hook).

---

## Pattern 2: @Observable Objects via Environment

For `@Observable` classes (iOS 17+), you can inject them directly without defining an `EnvironmentKey`:

```swift
@Observable
class AuthStore {
    var currentUser: User?
    var isAuthenticated: Bool { currentUser != nil }

    private let authAPI: AuthAPIProtocol

    init(authAPI: AuthAPIProtocol = AuthAPI()) {
        self.authAPI = authAPI
    }

    func login(email: String, password: String) async throws {
        currentUser = try await authAPI.login(email: email, password: password)
    }
}

// Provide — no key needed for @Observable
@main
struct MyApp: App {
    @State private var authStore = AuthStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authStore)
        }
    }
}

// Consume — reference the type directly
struct ProfileView: View {
    @Environment(AuthStore.self) private var authStore

    var body: some View {
        if let user = authStore.currentUser {
            Text("Welcome, \(user.name)")
        }
    }
}
```

This is the most common pattern for app-wide stores. Use it for auth, settings, feature flags, and other shared state.

---

## Pattern 3: Protocol-Based DI for Services

**Mental model:** This is constructor injection with interfaces, the same pattern used in backend DI containers (NestJS, Spring, .NET). Define a protocol, inject the concrete implementation.

### The Pattern

```swift
// Protocol (interface)
protocol AnalyticsProtocol {
    func track(event: String, properties: [String: Any])
}

// Production implementation
final class MixpanelAnalytics: AnalyticsProtocol {
    func track(event: String, properties: [String: Any]) {
        Mixpanel.mainInstance().track(event: event, properties: properties)
    }
}

// ViewModel accepts the protocol, not the concrete type
@Observable
class TaskListViewModel {
    var tasks: [Task] = []

    private let taskService: any TaskServiceProtocol
    private let analytics: any AnalyticsProtocol

    // Constructor injection — dependencies are explicit
    init(
        taskService: any TaskServiceProtocol = TaskService(),
        analytics: any AnalyticsProtocol = MixpanelAnalytics()
    ) {
        self.taskService = taskService
        self.analytics = analytics
    }

    func loadTasks() async {
        tasks = (try? await taskService.fetchTasks()) ?? []
        analytics.track(event: "tasks_loaded", properties: ["count": tasks.count])
    }
}
```

### When to Use Constructor Injection vs Environment

| Approach              | Use When                                    |
|-----------------------|---------------------------------------------|
| `@Environment`        | View-layer DI, system values, stores        |
| Constructor injection | ViewModel dependencies, service composition |
| Both combined         | Inject services via Environment into views that create ViewModels |

### Combined Pattern

```swift
struct TaskListView: View {
    @Environment(\.taskService) private var taskService
    @State private var viewModel: TaskListViewModel?

    var body: some View {
        Group {
            if let viewModel {
                TaskListContent(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            viewModel = TaskListViewModel(taskService: taskService)
        }
    }
}
```

---

## Pattern 4: Creating Testing Seams

The whole point of DI is testability. Here's how each pattern enables testing.

### Mock via Protocol

```swift
// Mock implementation for tests
final class MockTaskService: TaskServiceProtocol {
    var tasksToReturn: [Task] = []
    var shouldThrow = false
    var createCallCount = 0

    func fetchTasks() async throws -> [Task] {
        if shouldThrow { throw URLError(.badServerResponse) }
        return tasksToReturn
    }

    func createTask(_ task: Task) async throws {
        createCallCount += 1
    }

    func deleteTask(id: UUID) async throws { }
}
```

### Testing a ViewModel

```swift
import Testing

@Suite("TaskListViewModel")
struct TaskListViewModelTests {

    @Test("loads tasks on appear")
    func loadTasks() async {
        // Arrange — inject mock
        let mock = MockTaskService()
        mock.tasksToReturn = [
            Task(id: UUID(), title: "Test Task", isComplete: false)
        ]
        let vm = TaskListViewModel(taskService: mock)

        // Act
        await vm.loadTasks()

        // Assert
        #expect(vm.tasks.count == 1)
        #expect(vm.tasks.first?.title == "Test Task")
    }

    @Test("handles fetch failure gracefully")
    func loadTasksFailure() async {
        let mock = MockTaskService()
        mock.shouldThrow = true
        let vm = TaskListViewModel(taskService: mock)

        await vm.loadTasks()

        #expect(vm.tasks.isEmpty)
    }
}
```

### Testing Views with Environment Overrides

```swift
@Test("profile shows user name")
func profileShowsName() {
    let mockAuth = AuthStore(authAPI: MockAuthAPI())
    mockAuth.currentUser = User(name: "Test User")

    let view = ProfileView()
        .environment(mockAuth)

    // Use ViewInspector or snapshot testing to verify
}
```

### Preview with Mock Data

```swift
#Preview("Task List - Loaded") {
    let mockService = MockTaskService()
    mockService.tasksToReturn = Task.sampleData

    return NavigationStack {
        TaskListView()
    }
    .environment(\.taskService, mockService)
}

#Preview("Task List - Empty") {
    return NavigationStack {
        TaskListView()
    }
    .environment(\.taskService, MockTaskService())
}

#Preview("Task List - Error") {
    let mock = MockTaskService()
    mock.shouldThrow = true

    return NavigationStack {
        TaskListView()
    }
    .environment(\.taskService, mock)
}
```

---

## Comparison with Web DI Patterns

| Web Pattern                        | iOS Equivalent                         | Notes                                 |
|------------------------------------|----------------------------------------|---------------------------------------|
| React Context + Provider           | `@Environment` + `.environment()`      | Closest 1:1 mapping                  |
| Zustand / Jotai store              | `@Observable` class via Environment    | Fine-grained reactivity built in     |
| NestJS `@Injectable()` + module    | Protocol + constructor injection       | Same pattern, no framework needed     |
| Angular DI container               | No equivalent (not needed)             | SwiftUI's Environment is sufficient   |
| Jest `jest.mock('./service')`      | Protocol + mock class                  | More explicit, but more type-safe     |
| MSW (Mock Service Worker)          | `URLProtocol` subclass                 | Intercepts at the network layer       |
| Storybook args/decorators          | `#Preview` with Environment overrides  | Same concept, different syntax        |

### What's Different from Web

1. **No runtime container.** iOS DI is compile-time. If a dependency is missing, you get a compiler error (protocol) or a crash at launch (environment), not a runtime injection failure.

2. **Protocol witness > interface.** Swift protocols can have associated types and are checked at compile time. More powerful than TypeScript interfaces for DI contracts.

3. **No barrel imports.** Each file imports only what it needs. No `import { TaskService } from '@/services'` barrel re-exports.

4. **Environment propagates automatically.** Once you set `.environment(\.taskService, mock)` on a parent, every descendant gets it. No prop drilling, no explicit provider nesting for each service.

---

## Recommended Architecture

For most apps (< 20 screens), this layered approach works well:

```
App Root
├── .environment(authStore)              ← @Observable stores
├── .environment(\.taskService, ...)     ← Service protocols
├── .environment(\.analyticsService, ...)
│
└── Views
    ├── Read from @Environment
    ├── Create @State ViewModels with injected services
    └── Pass @Binding to children
```

### Rules of Thumb

1. **Stores** (`@Observable` classes holding shared state): inject via `.environment(store)`
2. **Stateless services** (API clients, analytics, logging): inject via `.environment(\.keyPath, service)`
3. **ViewModels**: create with `@State`, pass services via constructor
4. **Test seam**: every external dependency gets a protocol; every protocol gets a mock
5. **Previews**: always provide mock environment values so previews work without network

---

## Anti-Patterns to Avoid

### Singleton Services

```swift
// AVOID: Untestable, hidden dependency
class TaskService {
    static let shared = TaskService()
    // ...
}

// PREFER: Protocol + injection
// The default parameter gives you singleton convenience without the coupling
init(taskService: any TaskServiceProtocol = TaskService()) { }
```

### God Environment

```swift
// AVOID: One massive environment object that everything depends on
@Observable class AppEnvironment {
    var auth: AuthStore
    var tasks: TaskService
    var analytics: AnalyticsService
    var settings: SettingsStore
    // 20 more properties...
}

// PREFER: Separate environment entries for each concern
.environment(authStore)
.environment(\.taskService, taskService)
.environment(\.analytics, analytics)
```

### Passing Dependencies Through Views That Don't Use Them

```swift
// AVOID: Prop drilling
struct ParentView: View {
    let taskService: TaskServiceProtocol  // doesn't use it, just passes through

    var body: some View {
        MiddleView(taskService: taskService)  // still just passing through
    }
}

// PREFER: Environment injection — skip the middlemen
.environment(\.taskService, taskService)
// Any descendant reads it directly via @Environment
```
