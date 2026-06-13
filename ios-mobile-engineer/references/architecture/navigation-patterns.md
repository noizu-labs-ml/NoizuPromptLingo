# Navigation Patterns in SwiftUI

> For web developers: iOS navigation through the lens of React Router, tabs, modals, and responsive layouts.

---

## NavigationStack — The iOS Router

**Mental model:** `NavigationStack` is React Router with a type-safe path stack. Instead of URL strings, you push typed values onto a navigation path. The router renders the destination view for each type.

### Basic Push Navigation

```swift
struct TaskListView: View {
    var body: some View {
        NavigationStack {
            List(tasks) { task in
                // NavigationLink = <Link to="/task/:id">
                NavigationLink(value: task) {
                    TaskRow(task: task)
                }
            }
            .navigationTitle("Tasks")
            .navigationDestination(for: Task.self) { task in
                // This is your route handler — renders when a Task is pushed
                TaskDetailView(task: task)
            }
        }
    }
}
```

### Programmatic Navigation (like `useNavigate`)

```swift
@Observable
class Router {
    var path = NavigationPath()

    func navigate(to task: Task) {
        path.append(task)
    }

    func navigateToSettings() {
        path.append(Route.settings)
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func pop() {
        path.removeLast()
    }
}

enum Route: Hashable {
    case settings
    case profile(userId: String)
    case taskDetail(Task)
}

struct AppView: View {
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            TaskListView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .settings:
                        SettingsView()
                    case .profile(let userId):
                        ProfileView(userId: userId)
                    case .taskDetail(let task):
                        TaskDetailView(task: task)
                    }
                }
        }
        .environment(router)
    }
}
```

### Mapping to React Router

| SwiftUI                          | React Router Equivalent               |
|----------------------------------|---------------------------------------|
| `NavigationStack`                | `<BrowserRouter>` + `<Routes>`        |
| `NavigationLink(value:)`         | `<Link to={...}>`                     |
| `.navigationDestination(for:)`   | `<Route path="..." element={...}>`    |
| `NavigationPath`                 | History stack                         |
| `path.append(value)`            | `navigate("/path")`                   |
| `path.removeLast()`             | `navigate(-1)`                        |
| `path = NavigationPath()`       | `navigate("/", { replace: true })`    |

---

## TabView — Tab-Based Navigation

**Mental model:** A bottom tab bar, like a persistent layout with route-based tabs. Each tab maintains its own navigation stack.

```swift
struct MainTabView: View {
    @State private var selectedTab = Tab.tasks

    enum Tab {
        case tasks, search, profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Each tab wraps its own NavigationStack
            NavigationStack {
                TaskListView()
            }
            .tabItem {
                Label("Tasks", systemImage: "checklist")
            }
            .tag(Tab.tasks)

            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(Tab.search)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(Tab.profile)
        }
    }
}
```

**Key behavior:** Each tab preserves its own navigation state. Switching from Tasks (3 levels deep) to Search and back -- Tasks still shows the same detail view. This is different from web SPAs where route changes typically unmount components.

### Programmatic Tab Switching

```swift
// From a child view deep in the Tasks tab, switch to Profile:
@Environment(\.selectedTab) private var selectedTab

Button("View Profile") {
    selectedTab.wrappedValue = .profile
}
```

---

## Sheets and Full-Screen Covers (Modals)

**Mental model:** `.sheet()` is a modal dialog. `.fullScreenCover()` is a full-screen modal (like React Portal rendering over everything).

### Sheet (Slide-Up Modal)

```swift
struct TaskListView: View {
    @State private var showingNewTask = false
    @State private var selectedTask: Task?

    var body: some View {
        List(tasks) { task in
            Button(task.title) {
                selectedTask = task  // triggers the item-based sheet
            }
        }
        .toolbar {
            Button("Add", systemImage: "plus") {
                showingNewTask = true  // triggers the boolean sheet
            }
        }
        // Boolean-triggered sheet (like showModal())
        .sheet(isPresented: $showingNewTask) {
            NewTaskView()
        }
        // Item-triggered sheet (like showModal(data))
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
        }
    }
}
```

### Full-Screen Cover

```swift
.fullScreenCover(isPresented: $showingOnboarding) {
    OnboardingFlow()
}
```

### Dismissing from Inside a Modal

```swift
struct NewTaskView: View {
    // This is injected automatically inside sheets
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form { /* ... */ }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            saveTask()
                            dismiss()
                        }
                    }
                }
        }
    }
}
```

### Sheet vs Full-Screen Cover

| Feature            | `.sheet()`               | `.fullScreenCover()`      |
|--------------------|--------------------------|---------------------------|
| Appearance         | Slides up, card-style    | Covers entire screen      |
| Swipe to dismiss   | Yes (default)            | No                        |
| Use case           | Quick actions, forms     | Onboarding, login, camera |
| Web analogy        | Modal dialog             | Full-page overlay / Portal|

---

## NavigationSplitView — Responsive Sidebar

**Mental model:** Like a responsive layout that shows a sidebar on iPad/Mac and collapses to a navigation stack on iPhone. Think of it as a media-query-driven layout that iOS handles automatically.

```swift
struct AppView: View {
    @State private var selectedCategory: Category?
    @State private var selectedTask: Task?

    var body: some View {
        NavigationSplitView {
            // Sidebar (always visible on iPad, hidden on iPhone)
            List(categories, selection: $selectedCategory) { category in
                Label(category.name, systemImage: category.icon)
            }
            .navigationTitle("Categories")
        } content: {
            // Middle column (optional — use two-column variant without this)
            if let category = selectedCategory {
                TaskListView(category: category, selection: $selectedTask)
            } else {
                ContentUnavailableView("Select a Category",
                    systemImage: "sidebar.left")
            }
        } detail: {
            // Detail pane
            if let task = selectedTask {
                TaskDetailView(task: task)
            } else {
                ContentUnavailableView("Select a Task",
                    systemImage: "doc.text")
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}
```

### Adaptive Behavior

| Device      | Layout                                    |
|-------------|-------------------------------------------|
| iPhone      | Single column, push navigation            |
| iPad portrait | Sidebar overlay + detail                |
| iPad landscape | Sidebar + content + detail (3-column)  |
| Mac         | Sidebar + content + detail (3-column)     |

No media queries needed. SwiftUI handles the adaptation.

---

## Deep Linking

**Mental model:** Universal Links (iOS) work like web URLs. When a user taps `https://yourapp.com/task/123`, iOS opens your app and passes the URL. You parse it and set navigation state.

```swift
@main
struct MyApp: App {
    @State private var router = Router()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(router)
                .onOpenURL { url in
                    // Handle: myapp://task/abc-123
                    router.handleDeepLink(url)
                }
        }
    }
}

extension Router {
    func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }

        let segments = components.path.split(separator: "/").map(String.init)

        switch segments.first {
        case "task":
            if let id = segments.dropFirst().first {
                path.append(Route.taskDetail(id: id))
            }
        case "profile":
            if let userId = segments.dropFirst().first {
                path.append(Route.profile(userId: userId))
            }
        default:
            break
        }
    }
}
```

### Deep Link Setup Checklist

1. Register URL scheme in `Info.plist` (`myapp://`)
2. For Universal Links: configure `apple-app-site-association` on your web server
3. Handle URLs via `.onOpenURL` modifier
4. Parse URL into navigation state
5. Test with `xcrun simctl openurl booted "myapp://task/123"`

---

## Coordinator Pattern for Complex Flows

**Mental model:** A coordinator owns a multi-step flow (onboarding, checkout, authentication). It decides what screen comes next based on business logic, keeping individual views dumb.

```swift
@Observable
class OnboardingCoordinator {
    enum Step: Hashable {
        case welcome
        case permissions
        case profileSetup
        case complete
    }

    var path = NavigationPath()
    var currentStep: Step = .welcome

    func advance() {
        switch currentStep {
        case .welcome:
            currentStep = .permissions
            path.append(Step.permissions)
        case .permissions:
            currentStep = .profileSetup
            path.append(Step.profileSetup)
        case .profileSetup:
            currentStep = .complete
            // Don't push — dismiss the whole flow
        case .complete:
            break
        }
    }

    func skip() {
        // Business logic: skip permissions, go straight to profile
        currentStep = .profileSetup
        path.append(Step.profileSetup)
    }
}

struct OnboardingFlow: View {
    @State private var coordinator = OnboardingCoordinator()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            WelcomeView(onContinue: coordinator.advance)
                .navigationDestination(for: OnboardingCoordinator.Step.self) { step in
                    switch step {
                    case .permissions:
                        PermissionsView(
                            onAllow: coordinator.advance,
                            onSkip: coordinator.skip
                        )
                    case .profileSetup:
                        ProfileSetupView(onComplete: {
                            coordinator.advance()
                            dismiss()
                        })
                    default:
                        EmptyView()
                    }
                }
        }
    }
}
```

### When to Use Coordinators

- Multi-step flows with branching logic (onboarding, checkout)
- Flows that can be entered from multiple points
- Navigation decisions depend on business rules (A/B tests, feature flags, user state)
- You want to test navigation logic without rendering views

---

## Quick Reference

| Pattern               | Use When                                    | Web Equivalent                |
|-----------------------|---------------------------------------------|-------------------------------|
| `NavigationStack`     | Linear drill-down (list -> detail)          | React Router                  |
| `TabView`             | Top-level app sections                      | Bottom nav / tab layout       |
| `.sheet()`            | Quick modal interactions                    | Modal dialog                  |
| `.fullScreenCover()`  | Immersive flows (onboarding, camera)        | Full-page overlay             |
| `NavigationSplitView` | Master-detail on iPad                       | Responsive sidebar layout     |
| Deep linking          | External URLs open specific screens         | URL routing                   |
| Coordinator           | Complex multi-step flows                    | Multi-step form wizard        |
