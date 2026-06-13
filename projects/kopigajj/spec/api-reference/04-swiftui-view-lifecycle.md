# SwiftUI View Lifecycle & State

**Last Updated:** 2026-03-04
**Min Swift Version:** 5.9
**Min macOS Version:** 14.0

## Quick Summary

SwiftUI's view lifecycle and state management system provides a declarative way to build user interfaces. Views are lightweight structs that render based on their state, and the framework manages when views are created, updated, and removed. For the Smart Clipboard project, understanding lifecycle modifiers like `.onAppear`, `.onDisappear`, and state management with `@State`, `@Published`, and `@ObservableObject` is essential for building responsive popup windows with animations and keyboard support.

## Key APIs

| API | Purpose | File Location |
|-----|---------|---------------|
| `.onAppear(perform:)` | Executes code when view appears on screen | `PopupWindowManager.swift` (HelloWorldView) |
| `.onDisappear(perform:)` | Executes code when view leaves screen | -- |
| `@State` | Local state property wrapper | `PopupWindowManager.swift` (HelloWorldView) |
| `@Published` | Publishes changes in ObservableObjects | `PopupWindowManager.swift` (PopupWindowManager) |
| `@ObservableObject` | Protocol for objects that publish changes | `PopupWindowManager.swift` (PopupWindowManager) |
| `.animation(_:)` | Applies animation to view changes | `PopupWindowManager.swift` (HelloWorldView) |
| `.keyboardShortcut(_:)` | Adds keyboard shortcuts to controls | `PopupWindowManager.swift` (HelloWorldView) |
| `.frame()` | Sets fixed frame size for view | `PopupWindowManager.swift` (HelloWorldView) |

## Code Examples

### Basic View with Lifecycle and State (Swift 5.9+, macOS 14.0+)

```swift
import SwiftUI

struct HelloWorldView: View {
    let onClose: () -> Void

    // Local state for animation
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: 20) {
            // Icon
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            // Title
            Text("Hello World")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.primary)

            // Description
            Text("Global hotkey Cmd+Shift+T working!")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)

            Divider()
                .padding(.vertical, 8)

            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "keyboard")
                        .foregroundStyle(.secondary)
                    Text("Press Escape to close this window")
                        .font(.system(size: 13))
                }

                HStack {
                    Image(systemName: "arrow.up.backward")
                        .foregroundStyle(.secondary)
                    Text("Press Cmd+Shift+T to dismiss")
                        .font(.system(size: 13))
                }
            }
            .padding(.horizontal)

            Divider()

            // Close button
            Button(action: onClose) {
                Text("Close")
                    .frame(maxWidth: .infinity)
            }
            .keyboardShortcut(.escape)
            .controlSize(.large)
        }
        .padding(32)
        .frame(width: 400, height: 300)  // Fixed size for popup
        .onAppear {
            // Fade-in animation when view appears
            withAnimation(.easeInOut(duration: 0.2)) {
                opacity = 1
            }
        }
        .keyboardShortcut(.escape)
    }
}
```

### View Lifecycle Modifiers

```swift
struct LifecycleExampleView: View {
    @State private var hasAppeared = false
    @State private var hasLoaded = false

    var body: some View {
        VStack {
            Text("Lifecycle Demo")
                .font(.headline)

            if hasAppeared {
                Text("View has appeared")
                    .foregroundStyle(.green)
            } else {
                Text("View has not appeared yet")
                    .foregroundStyle(.gray)
            }

            if hasLoaded {
                Text("Data has loaded")
                    .foregroundStyle(.blue)
            }
        }
        // onAppear: Called when view becomes visible
        .onAppear {
            print("View appeared on screen")
            hasAppeared = true

            // Load data or start operations
            loadData()
        }
        // onDisappear: Called when view is removed or hidden
        .onDisappear {
            print("View disappeared from screen")
            // Cleanup operations
            cleanupResources()
        }
        // onReceive: Respond to Combine publishers
        .onReceive(notificationPublisher) { notification in
            handleNotification(notification)
        }
        // onChange: Respond to specific state changes
        .onChange(of: hasAppeared) { _, newValue in
            if newValue {
                print("View appearance status changed to true")
            }
        }
    }

    private func loadData() {
        // Simulate async data loading
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            hasLoaded = true
        }
    }

    private func cleanupResources() {
        // Release resources
    }

    private func handleNotification(_ notification: Notification) {
        // Handle incoming notifications
    }
}
```

### State Management with Observables

```swift
// ObservableObject for view model
class ClipboardManager: ObservableObject {
    @Published var clipboardHistory: [ClipboardItem] = []
    @Published var isLoading: Bool = false
    @Published var error: String?

    func addToClipboard(_ item: ClipboardItem) {
        clipboardHistory.insert(item, at: 0)
    }

    func clearHistory() {
        clipboardHistory.removeAll()
    }
}

// View that observes the clipboard manager
struct ClipboardHistoryView: View {
    @ObservedObject var clipboardManager: ClipboardManager

    var body: some View {
        VStack {
            if clipboardManager.isLoading {
                ProgressView("Loading...")
            } else {
                List {
                    ForEach(clipboardManager.clipboardHistory) { item in
                        ClipboardItemView(item: item)
                    }
                }
            }

            if let error = clipboardManager.error {
                Text(error)
                    .foregroundStyle(.red)
            }
        }
        .onAppear {
            loadClipboardData()
        }
    }

    private func loadClipboardData() {
        clipboardManager.isLoading = true

        Task {
            do {
                // Simulate data loading
                try await Task.sleep(nanoseconds: 1_000_000_000)
                clipboardManager.clipboardHistory = ClipboardItem.sampleData
                clipboardManager.isLoading = false
            } catch {
                clipboardManager.error = "Failed to load data"
                clipboardManager.isLoading = false
            }
        }
    }
}
```

### Animations and Transitions

```swift
struct AnimatedPopupView: View {
    let onClose: () -> Void
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.8

    var body: some View {
        VStack {
            // Content
            Text("Animated Popup")
                .font(.largeTitle)

            Button("Close") {
                withAnimation {
                    scale = 0.8
                }
                Task {
                    try? await Task.sleep(nanoseconds: 200_000_000)
                    onClose()
                }
            }
            .controlSize(.large)
        }
        .frame(width: 400, height: 300)
        .scaleEffect(isAnimating ? 1.0 : scale)
        .opacity(isAnimating ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isAnimating)
    }
}

// Transition effects
struct TransitionDemoView: View {
    @State private var showDetails = false

    var body: some View {
        VStack {
            Button("Toggle Detail") {
                withAnimation(.easeInOut) {
                    showDetails.toggle()
                }
            }

            if showDetails {
                Text("Detailed content here")
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    .transition(
                        .asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        )
                    )
            }
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}
```

### Keyboard Shortcuts

```swift
struct KeyboardShortcutsView: View {
    let onClose: () -> Void
    @State private var selectedIndex = 0

    var body: some View {
        VStack {
            List {
                ForEach(0..<5) { index in
                    Text("Item \(index)")
                        .foregroundStyle(selectedIndex == index ? .primary : .secondary)
                        .onTapGesture {
                            selectedIndex = index
                        }
                }
            }

            HStack {
                Button("Previous") {
                    if selectedIndex > 0 {
                        selectedIndex -= 1
                    }
                }
                .keyboardShortcut(.upArrow)

                Button("Next") {
                    if selectedIndex < 4 {
                        selectedIndex += 1
                    }
                }
                .keyboardShortcut(.downArrow)

                Button("Close") {
                    onClose()
                }
                .keyboardShortcut(.escape)
            }
        }
        .frame(width: 400, height: 300)
        // Global keyboard shortcut for the entire view
        .keyboardShortcut(.escape, modifiers: [])
    }
}

// Custom keyboard shortcuts
struct CustomShortcutsView: View {
    @FocusState private var focusField: Field?
    @State private var searchText = ""

    enum Field {
        case search
    }

    var body: some View {
        VStack {
            TextField("Search...", text: $searchText)
                .focused($focusField, equals: .search)
                .textFieldStyle(.roundedBorder)

            if focusField == .search {
                Button("Clear") {
                    searchText = ""
                }
                .keyboardShortcut("\\", modifiers: [.command])
            }
        }
        .padding()
        .onAppear {
            focusField = .search  // Auto-focus search field
        }
        .onExitCommand {
            // Handle Escape key specifically
            print("Exit command triggered")
        }
    }
}
```

### Focus Management

```swift
struct FocusManagementView: View {
    @FocusState private var focusedField: Field?
    @State private var input1 = ""
    @State private var input2 = ""

    enum Field {
        case first
        case second
    }

    var body: some View {
        VStack(spacing: 20) {
            TextField("First Input", text: $input1)
                .focused($focusedField, equals: .first)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    focusField = .second  // Move to next field
                }

            TextField("Second Input", text: $input2)
                .focused($focusedField, equals: .second)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    // Handle final submission
                    handleSubmit()
                }

            Button("Focus First") {
                focusedField = .first
            }
            .keyboardShortcut("1", modifiers: [.command])

            Button("Focus Second") {
                focusedField = .second
            }
            .keyboardShortcut("2", modifiers: [.command])
        }
        .frame(width: 400, height: 300)
        .onAppear {
            focusedField = .first  // Initial focus
        }
    }

    private func handleSubmit() {
        print("Form submitted: \(input1), \(input2)")
    }
}
```

## Implementation Notes

### Gotchas

- **View Identity and Lifecycle**: SwiftUI views are value types and are recreated frequently. However, SwiftUI tries to preserve state based on view identity. Always ensure views have stable identity for state to persist correctly.

- **@State Initialization**: `@State` properties are initialized once when the view is first created, not on every recomputation. Use `onAppear` for actions that should run every time the view becomes visible.

- **Animation Timing**: Animations only work with animatable properties (opacity, frame, scale, etc.). Non-animatable property changes won't animate even if wrapped in `withAnimation`.

- **Keyboard Shortcut Scopes**: Keyboard shortcuts defined on individual views only work when that view (or its descendants) has focus. For global shortcuts within the view, apply `.keyboardShortcut()` to a parent container or the entire view.

- **Cleanup Timing**: `onDisappear` is the right place to cancel ongoing tasks, close streams, or release resources. However, the view might be recreated quickly, so be careful with expensive cleanup operations.

- **State Updates from Background**: Always dispatch state updates to the main thread when they come from background tasks:

```swift
Task.detached(priority: .userInitiated) {
    let data = await fetchData()
    await MainActor.run {
        viewState.data = data  // State update on main thread
    }
}
```

### Performance Considerations

- **View Complexity**: SwiftUI views are structs, not classes, so creating them is cheap. However, expensive computations in the `body` property run on every state change. Use computed properties or view models to optimize.

- **Animation Performance**: Use `withAnimation` judiciously. Animating large numbers of views or complex hierarchies can cause performance issues.

- **State Subscriptions**: `@ObservedObject` and `@Published` create subscriptions. Remove observers in `onDisappear` to prevent memory leaks.

- **Task Management**: Always create tasks with a storage reference when they need to be cancelled:

```swift
struct ContentView: View {
    @State private var dataTask: Task<Void, Never>?

    var body: some View {
        // ...
            .onDisappear {
                dataTask?.cancel()  // Cancel background task
            }
    }

    func loadData() {
        dataTask = Task {
            // Load data
        }
    }
}
```

- **Lazy Loading**: Use `LazyVStack`, `LazyGrid`, or `List` for large collections. Only visible views are computed, significantly improving performance.

### Threading

- **UI Thread Required**: All SwiftUI view updates must occur on the main thread. The framework's property wrappers (`@State`, `@Published`) handle this automatically for you.

- **MainActor Annotations**: For view models or managers that update SwiftUI state, consider using `@MainActor` to ensure thread safety:

```swift
@MainActor
class ClipboardManager: ObservableObject {
    @Published var items: [ClipboardItem] = []

    func addItem(_ item: ClipboardItem) {
        // Automatically runs on main thread
        items.append(item)
    }
}
```

- **Async Operations**: Use Swift's async/await for background work, ensuring state updates happen on the main actor:

```swift
func loadAsync() async {
    do {
        let data = try await fetchDataInBackground()
        // Update @Published property - automatically on main thread
        self.items = data
    } catch {
        self.error = error.localizedDescription
    }
}
```

## References

- [SwiftUI View Lifecycle - Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/view-lifecycle)
- [State Management in SwiftUI - Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/state-and-data-flow)
- [SwiftUI View Protocol - Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/view)
- [Animation in SwiftUI - Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/animation)
- [Focus Management - Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/focus)
- [View Modifiers - Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/viewmodifier)

## Version Notes

- **macOS 14.0 (Sonoma)**:
  - Introduced `@Observable` macro for simpler observation (replaces `ObservableObject` and `@Published` in many cases)
  - Improved animation system with `.bouncy` and `.smooth` animation curves
  - Enhanced focus management APIs

- **macOS 13.0 (Ventura)**:
  - Introduced `.onChange(of:perform:)` modifier replacing older onChange API
  - Improved `.grid` and LazyGrid performance
  - Native `.searchable` modifier enhanced

- **macOS 12.0 (Monterey)**:
  - Introduced FocusState for advanced focus management
  - Added `.toolbar`, `.toolbarContent`, and related toolbar APIs
  - Improved keyboard shortcut handling

- **macOS 11.0 (Big Sur)**:
  - Major SwiftUI enhancements for macOS
  - `.windowStyle` modifier for custom window appearances
  - First-class support for macOS-specific controls

### Swift 5.9+ Features

```swift
// @Observable macro (SwiftUI 6.0 / macOS 14.0+)
@Observable
class ClipboardModel {
    var items: [ClipboardItem] = []
    var isLoading: Bool = false

    // Automatically publishes changes without @Published
    func addItem(_ item: ClipboardItem) {
        items.append(item)
    }
}

// Using @Observable in view
struct ObservableModelView: View {
    @State private var model = ClipboardModel()

    var body: some View {
        List(model.items) { item in
            Text(item.text)
        }
        .onAppear {
            model.addItem(ClipboardItem(text: "New item"))
        }
    }
}
```

### Common View Modifier Combinations

```swift
// Scrollable view with lifecycle
struct ScrollableView: View {
    var body: some View {
        ScrollView {
            // Content
        }
        .frame(width: 400, height: 300)  // Fixed size
        .onAppear {
            // Initialize or start tasks
        }
        .onDisappear {
            // Cleanup
        }
    }
}

// Button with animation and keyboard shortcut
struct AnimatedButton: View {
    @State private var isPressed = false

    var body: some View {
        Button(action: {}) {
            Text("Action")
        }
        .buttonStyle(.borderedProminent)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .keyboardShortcut(" ", modifiers: [])
        .onLongPressGesture(minimumDuration: 0) { pressing in
            isPressed = pressing
        } perform: {
            // Button action
        }
    }
}

// View with conditional rendering
struct ConditionalView: View {
    @State private var isLoading = true
    @State private var content: String = ""

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if content.isEmpty {
                EmptyStateView {
                    print("Empty state action")
                }
            } else {
                ContentView(data: content)
            }
        }
        .frame(width: 400, height: 300)
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                content = "Loaded data"
                isLoading = false
            }
        }
    }
}

struct EmptyStateView: View {
    let onAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No Data")
                .font(.headline)

            Button("Action") {
                onAction()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct ContentView: View {
    let data: String

    var body: some View {
        Text(data)
    }
}
```

<!-- nav -->

---

[< Previous: NSApplication & Activation Policy](03-nsapplication-activation-policy.md) | [Table of Contents](../../product-spec.md)

<!-- nav -->
