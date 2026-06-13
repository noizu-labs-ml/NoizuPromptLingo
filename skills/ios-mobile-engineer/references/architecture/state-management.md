# State Management in SwiftUI

> For web developers: SwiftUI property wrappers mapped to React hooks and state patterns you already know.

---

## The Core Mental Model

In React, you manage state with hooks (`useState`, `useContext`, `useReducer`). In SwiftUI, you use **property wrappers** -- annotations like `@State` that tell the framework "watch this value and re-render when it changes."

The key difference: React re-runs the entire function body on state change. SwiftUI only re-renders the specific views whose observed data changed. This is closer to signals (Solid.js, Preact Signals) than React's reconciliation model.

---

## @State -- Local Component State

**Mental model:** `@State` is `useState()`. It's private to the view, owned by the view, and triggers a re-render when mutated.

```swift
struct CounterView: View {
    @State private var count = 0       // like: const [count, setCount] = useState(0)

    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") {
                count += 1             // like: setCount(prev => prev + 1)
            }
        }
    }
}
```

### Rules

- Always declare `@State` as `private` -- it belongs to this view only
- SwiftUI owns the storage. The view struct is recreated on parent re-renders, but `@State` persists
- Use for: toggles, form field text, local UI state (is expanded, selected index)

---

## @Binding -- Props That Write Back

**Mental model:** `@Binding` is a two-way prop. The parent owns the state; the child can read and write it. Like passing `[value, setValue]` as a prop in React.

```swift
// Parent owns the state
struct ParentView: View {
    @State private var isOn = false

    var body: some View {
        // $isOn creates a Binding<Bool> — the $ prefix is the "binding projector"
        ToggleRow(isOn: $isOn)
    }
}

// Child receives a binding — can read AND write
struct ToggleRow: View {
    @Binding var isOn: Bool            // like: props: { isOn: boolean, setIsOn: (v: boolean) => void }

    var body: some View {
        Toggle("Enable notifications", isOn: $isOn)
    }
}
```

### React Equivalent

```tsx
// This React pattern is what @Binding replaces:
function Parent() {
    const [isOn, setIsOn] = useState(false);
    return <ToggleRow isOn={isOn} setIsOn={setIsOn} />;
}

function ToggleRow({ isOn, setIsOn }) {
    return <input type="checkbox" checked={isOn} onChange={e => setIsOn(e.target.checked)} />;
}
```

In SwiftUI, `@Binding` bundles both the getter and setter into one clean property.

---

## @Observable -- Global Store Pattern

**Mental model:** `@Observable` (from the Observation framework, iOS 17+) turns a class into a reactive store. Any SwiftUI view that reads a property of an `@Observable` object automatically re-renders when that property changes. This is like a Zustand store or MobX observable.

```swift
import Observation

@Observable
class AuthStore {
    var currentUser: User?
    var isAuthenticated: Bool { currentUser != nil }  // computed, also tracked
    var isLoading = false

    func login(email: String, password: String) async {
        isLoading = true
        defer { isLoading = false }
        currentUser = try? await AuthAPI.login(email: email, password: password)
    }

    func logout() {
        currentUser = nil
    }
}
```

### Using in Views

```swift
struct ProfileView: View {
    // The view tracks which properties it reads and only re-renders for those
    var authStore: AuthStore

    var body: some View {
        if let user = authStore.currentUser {
            Text("Hello, \(user.name)")
            Button("Logout") { authStore.logout() }
        } else {
            Text("Not logged in")
        }
    }
}
```

### Fine-Grained Reactivity

Unlike React (which re-runs the entire component), `@Observable` tracks property-level access:

```swift
@Observable
class Store {
    var name = "Alice"     // View A reads this
    var score = 0          // View B reads this
}

// View A only re-renders when `name` changes
// View B only re-renders when `score` changes
// Changing `score` does NOT re-render View A
```

This is closer to Solid.js signals than React state.

---

## @Environment -- Dependency Injection via Context

**Mental model:** `@Environment` is React's `useContext()`. Values are injected by a parent and readable by any descendant.

### Built-In Environment Values

SwiftUI provides dozens of built-in environment values:

```swift
struct MyView: View {
    @Environment(\.colorScheme) private var colorScheme        // light/dark mode
    @Environment(\.dismiss) private var dismiss                // dismiss sheets
    @Environment(\.horizontalSizeClass) private var sizeClass  // compact/regular
    @Environment(\.openURL) private var openURL                // open URLs

    var body: some View {
        Text(colorScheme == .dark ? "Dark mode" : "Light mode")
    }
}
```

### Custom Environment Values (Your Own Context)

```swift
// 1. Define an environment key (like createContext default)
struct AuthStoreKey: EnvironmentKey {
    static let defaultValue = AuthStore()
}

// 2. Extend EnvironmentValues (register the key)
extension EnvironmentValues {
    var authStore: AuthStore {
        get { self[AuthStoreKey.self] }
        set { self[AuthStoreKey.self] = newValue }
    }
}

// 3. Provide at a parent level (like <Context.Provider>)
struct MyApp: App {
    @State private var authStore = AuthStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.authStore, authStore)
        }
    }
}

// 4. Consume anywhere below (like useContext())
struct ProfileView: View {
    @Environment(\.authStore) private var authStore

    var body: some View {
        Text(authStore.currentUser?.name ?? "Guest")
    }
}
```

### Shorthand for @Observable Types (iOS 17+)

For `@Observable` classes, there's an even simpler pattern:

```swift
// Provide
ContentView()
    .environment(authStore)    // no keypath needed

// Consume
@Environment(AuthStore.self) private var authStore
```

---

## Data Flow Patterns and Ownership Rules

### The Golden Rule

**Data flows down. Actions flow up.** Same as React's unidirectional data flow.

```
Parent (owns @State)
   |
   |-- passes $binding or value down
   v
Child (reads, optionally writes via @Binding)
```

### Ownership Hierarchy

```
@State          → "I own this data" (source of truth)
@Binding        → "I borrow this data from my parent"
@Environment    → "I read this from an ancestor's context"
@Observable     → "I reference a shared object" (external source of truth)
```

### Decision Flowchart

```
Is the data local to this one view?
├── YES → @State
└── NO
    ├── Does a parent own it and pass it down?
    │   ├── Read-only → pass as regular property
    │   └── Read-write → @Binding
    ├── Is it shared across many views (global)?
    │   └── @Observable class + @Environment
    └── Is it from the system (dark mode, locale)?
        └── @Environment(\.keyPath)
```

---

## Common Pitfalls

### 1. Reference Type vs Value Type Confusion

Structs are value types (copied). Classes are reference types (shared). This matters enormously.

```swift
// WRONG: @State with a class — mutations won't trigger re-renders
@State private var store = MyClass()  // @State is designed for value types

// RIGHT: Use @State with @Observable classes (iOS 17+)
@State private var store = MyObservableClass()  // @Observable + @State works

// RIGHT: Use @State with structs
@State private var formData = FormData()  // struct, value type, works perfectly
```

### 2. Mutating State During Render

```swift
// WRONG: This crashes or causes infinite loops
var body: some View {
    count += 1  // Never mutate state in body!
    Text("\(count)")
}

// RIGHT: Mutate in event handlers or .task/.onAppear
var body: some View {
    Text("\(count)")
        .onAppear { count = loadInitialCount() }
}
```

### 3. Over-Observing with @Observable

```swift
// PROBLEM: This view re-renders when ANY property changes
struct BadView: View {
    var store: BigStore  // reads store in body, tracks everything accessed

    var body: some View {
        let _ = store  // even touching the store variable triggers tracking
        Text("Static text")
    }
}

// FIX: Only read the specific properties you need
struct GoodView: View {
    var store: BigStore

    var body: some View {
        Text(store.userName)  // only re-renders when userName changes
    }
}
```

### 4. Forgetting @State is View-Scoped

```swift
// PITFALL: @State resets when the view is destroyed and recreated
struct TimerView: View {
    @State private var elapsed = 0  // resets if parent conditionally removes this view

    var body: some View {
        Text("\(elapsed)s")
    }
}

// If you need persistence across view lifecycle, use @Observable at a higher scope
```

---

## Comparison Table: React Hooks vs SwiftUI Property Wrappers

| React                              | SwiftUI                        | Purpose                          |
|------------------------------------|--------------------------------|----------------------------------|
| `useState(0)`                      | `@State private var x = 0`    | Local mutable state              |
| `const [v, setV]` passed as props  | `@Binding var v: Type`        | Parent-owned, child-writable     |
| `useContext(MyContext)`             | `@Environment(\.key)`         | Read value from ancestor         |
| `<Context.Provider value={x}>`     | `.environment(\.key, x)`      | Inject value for descendants     |
| Zustand store / `useStore()`       | `@Observable class` + inject  | Shared global state              |
| `useMemo(() => ..., [deps])`       | Computed property on @Observable | Derived/cached value           |
| `useEffect(() => {}, [])`          | `.task { }` / `.onAppear { }` | Side effects on mount            |
| `useReducer(reducer, init)`        | TCA `Reducer` (third-party)   | Action-based state transitions   |
| `useRef(initialValue)`             | Regular `let`/`var` (non-@State) | Non-reactive mutable storage  |
| `React.memo(Component)`            | Automatic (fine-grained tracking) | Skip unnecessary re-renders   |

### Key Differences Worth Internalizing

1. **No dependency arrays.** SwiftUI tracks what you read automatically. No `useEffect` dep bugs.
2. **No stale closures.** Property wrappers always reflect current state. No `count` captured at render time.
3. **Value types are the default.** Structs (Views, models) are copied, not shared. This prevents accidental shared mutation.
4. **Re-render granularity.** SwiftUI re-renders individual views, not subtrees. Closer to signals than VDOM diffing.
5. **No `key` prop.** SwiftUI identifies views by position in the view hierarchy. Use `.id()` modifier when you need explicit identity.

---

## Quick Reference

| Wrapper        | Owns Data? | Triggers Re-render? | Use For                          |
|----------------|------------|----------------------|----------------------------------|
| `@State`       | Yes        | Yes                  | Local view state                 |
| `@Binding`     | No (borrows) | Yes                | Child writing to parent's state  |
| `@Observable`  | N/A (class)  | Yes (per-property) | Shared stores, view models       |
| `@Environment` | No (reads)   | Yes                | System values, injected deps     |
| `let` / `var`  | N/A          | No                 | Static config, non-reactive data |
