# SwiftUI for Web Developers

A mental-model translation layer for React/Vue/HTML developers moving to SwiftUI.

---

## The Core Analogy

| Web Concept | SwiftUI Equivalent | Key Difference |
|---|---|---|
| Component | `View` (struct) | Value type, not a class. Recreated on every state change. |
| JSX / template | `body` property | Returns a view tree. No string interpolation — it's real Swift code. |
| Props | Init parameters | Passed at construction. Immutable by default. |
| `useState` | `@State` | Compiler-managed. Triggers view re-render on mutation. |
| `useContext` | `@Environment` / `@EnvironmentObject` | Injected down the view tree, not imported globally. |
| CSS | Modifiers (`.padding()`, `.font()`) | Chained method calls. Order matters — modifiers wrap the view. |
| `className` | No equivalent | There is no stylesheet. Every style is inline via modifiers. |
| DOM | View tree | No mutable DOM. SwiftUI diffs the tree for you. |
| Event handler (`onClick`) | Action closure (`.onTapGesture {}`, `Button(action: {})`) | Closures, not string function names. |
| `children` / slots | `@ViewBuilder` closures | Trailing closure syntax replaces slot/children patterns. |

---

## Side-by-Side: A Simple Card Component

### React

```jsx
function ProfileCard({ name, role, avatarUrl }) {
  const [isFollowing, setIsFollowing] = useState(false);

  return (
    <div className="card">
      <img src={avatarUrl} alt={name} className="avatar" />
      <h2>{name}</h2>
      <p className="role">{role}</p>
      <button onClick={() => setIsFollowing(!isFollowing)}>
        {isFollowing ? "Following" : "Follow"}
      </button>
    </div>
  );
}
```

### SwiftUI

```swift
struct ProfileCard: View {
    let name: String
    let role: String
    let avatarUrl: URL

    @State private var isFollowing = false

    var body: some View {
        VStack(spacing: 12) {
            AsyncImage(url: avatarUrl) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())

            Text(name)
                .font(.headline)

            Text(role)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(isFollowing ? "Following" : "Follow") {
                isFollowing.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
    }
}
```

**Key observations:**

1. **No CSS file.** Every visual property is a modifier chained onto the view.
2. **No `className`.** You style by composing modifiers: `.font()`, `.padding()`, `.background()`.
3. **Layout is structural.** `VStack` (vertical), `HStack` (horizontal), `ZStack` (layered) replace flexbox/grid.
4. **`@State` replaces `useState`.** Same idea, different mechanics — it's a property wrapper, not a hook.
5. **Image loading is built in.** `AsyncImage` replaces `<img>` + lazy loading libraries.

---

## Layout: Flexbox vs Stacks

Web developers think in `display: flex` and `flex-direction`. SwiftUI thinks in stacks.

| CSS | SwiftUI |
|---|---|
| `flex-direction: column` | `VStack` |
| `flex-direction: row` | `HStack` |
| `position: absolute` / `z-index` | `ZStack` |
| `justify-content: center` | Stack with `Spacer()` or alignment parameter |
| `align-items: center` | `VStack(alignment: .center)` |
| `gap: 16px` | `VStack(spacing: 16)` |
| `flex: 1` | `Spacer()` or `.frame(maxWidth: .infinity)` |
| `max-width: 600px` | `.frame(maxWidth: 600)` |
| `padding: 16px` | `.padding(16)` or `.padding()` for system default |
| `margin` | No direct equivalent. Use `padding` on the parent or `Spacer()`. |

### The Spacer Pattern

`Spacer()` is the SwiftUI equivalent of `flex-grow: 1`. It expands to fill available space.

```swift
// Push button to the right (like justify-content: space-between)
HStack {
    Text("Title")
    Spacer()
    Button("Action") { }
}
```

### No Margin

SwiftUI has no margin. This trips up every web developer. Instead:
- Use `padding` on the container
- Use `spacing` on the parent stack
- Use `Spacer()` for explicit gaps
- Use `.padding(.leading, 8)` for directional insets

---

## Modifier Order Matters

This is the single biggest gotcha for web developers. In CSS, `padding` and `background-color` are independent properties. In SwiftUI, modifiers wrap the view — order changes the result.

```swift
// Padding INSIDE the background (like CSS box model with padding inside)
Text("Hello")
    .padding()
    .background(.blue)

// Padding OUTSIDE the background (blue box, then space around it)
Text("Hello")
    .background(.blue)
    .padding()
```

Think of each modifier as wrapping the view in a new container. The first modifier is the innermost wrapper.

```
.background(.blue) wraps → .padding() wraps → Text("Hello")
```

This applies to everything: `.clipShape()`, `.shadow()`, `.border()`, `.overlay()`.

---

## State Management Translation

| Web Pattern | SwiftUI Equivalent | Scope |
|---|---|---|
| `useState` | `@State` | Local to one view |
| `useRef` (mutable, no re-render) | Plain `let` / `var` — but careful, views are value types | See note below |
| `useContext` | `@Environment` | System values (color scheme, locale, etc.) |
| `useContext` (custom) | `@EnvironmentObject` | Custom objects injected into the tree |
| Redux / Zustand | `@Observable` class + `@Environment` | Shared mutable state |
| Props drilling | Pass values through init | Same problem, same solutions |
| `useEffect` | `.onAppear {}`, `.onChange(of:) {}`, `.task {}` | Lifecycle modifiers |

### The `@State` Rule

`@State` is for **private, local** state owned by that view. Never pass `@State` between views — pass `@Binding` instead (a two-way reference to someone else's `@State`).

```swift
// Parent owns the state
struct Parent: View {
    @State private var isOn = false

    var body: some View {
        // Child gets a binding — can read AND write
        Toggle("Enable", isOn: $isOn)
    }
}
```

The `$` prefix creates a `Binding` — the SwiftUI equivalent of passing a setter function alongside the value.

---

## View Lifecycle: There Is No `componentDidMount`

SwiftUI views are **value types** (structs). They are created, diffed, and destroyed constantly. There is no persistent instance with a lifecycle.

| React Lifecycle | SwiftUI Equivalent | Notes |
|---|---|---|
| `componentDidMount` / `useEffect([], ...)` | `.onAppear {}` | Fires when view appears on screen |
| `componentWillUnmount` | `.onDisappear {}` | Fires when view leaves screen |
| `useEffect([dep], ...)` | `.onChange(of: dep) {}` | Fires when a value changes |
| `useEffect` (async) | `.task {}` | Async work tied to view lifetime. Auto-cancelled on disappear. |
| `shouldComponentUpdate` | Not needed | SwiftUI diffs automatically. Trust the framework. |

### `.task {}` is Your Best Friend

`.task {}` replaces the pattern of `useEffect` + async fetch + cleanup:

```swift
struct UserProfile: View {
    let userId: String
    @State private var user: User?

    var body: some View {
        Group {
            if let user {
                Text(user.name)
            } else {
                ProgressView()
            }
        }
        .task {
            user = try? await API.fetchUser(userId)
        }
    }
}
```

The task is automatically cancelled if the view disappears. No cleanup needed.

---

## Navigation: No React Router

SwiftUI has built-in navigation. No routing library required.

```swift
// Tab bar (like bottom nav on web)
TabView {
    Tab("Home", systemImage: "house") {
        HomeView()
    }
    Tab("Search", systemImage: "magnifyingglass") {
        SearchView()
    }
    Tab("Profile", systemImage: "person") {
        ProfileView()
    }
}

// Drill-down navigation (like clicking into a detail page)
NavigationStack {
    List(items) { item in
        NavigationLink(item.title) {
            DetailView(item: item)
        }
    }
    .navigationTitle("Items")
}

// Modal / sheet (like a dialog/drawer)
.sheet(isPresented: $showSettings) {
    SettingsView()
}
```

| Web Pattern | iOS Pattern |
|---|---|
| Tab bar / bottom nav | `TabView` |
| Route push (`/items/123`) | `NavigationLink` inside `NavigationStack` |
| Modal / dialog | `.sheet()` or `.fullScreenCover()` |
| Drawer / sidebar | `NavigationSplitView` |
| Back button | Automatic in `NavigationStack` |

---

## Lists: No `map()` Rendering

In React you `{items.map(item => <Card key={item.id} ... />)}`. In SwiftUI, `List` and `ForEach` handle this — and they handle recycling (virtualization) automatically.

```swift
List(items) { item in
    HStack {
        Text(item.title)
        Spacer()
        Text(item.date, style: .date)
    }
}
```

`List` is the iOS equivalent of a virtualized scrollable list. It recycles cells like `react-window` or `react-virtualized` — but it's the default, not an optimization.

For non-list layouts, use `ForEach` inside a `VStack` or `LazyVStack`:

```swift
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            CardView(item: item)
        }
    }
}
```

---

## "Think Different" — Concepts With No Web Equivalent

### 1. Value Types Everywhere

SwiftUI views are structs (value types), not classes (reference types). When you assign a struct to a new variable, it copies. This means views have no identity — they're blueprints, not instances.

**Web brain:** "My component is an object that lives in memory and updates."
**iOS brain:** "My view is a recipe. SwiftUI reads the recipe, builds the UI, and throws the recipe away."

### 2. Property Wrappers

`@State`, `@Binding`, `@Environment`, `@Observable` — these aren't decorators. They're **property wrappers** that add storage and change-tracking behavior to a property. The `@` syntax is compile-time transformation, not runtime metadata.

### 3. Opaque Return Types (`some View`)

`var body: some View` means "this returns a specific concrete type, but I'm not telling you which one." The compiler knows the exact type; you don't have to spell it out. There's no web equivalent — TypeScript would require you to name the return type.

### 4. SF Symbols

Apple provides 5,000+ vector icons built into the OS. No icon library to install. `Image(systemName: "star.fill")` just works. Browse at [developer.apple.com/sf-symbols](https://developer.apple.com/sf-symbols/).

### 5. No Global Styles

There is no `:root` or CSS custom properties that cascade. Theming is done via:
- `@Environment(\.colorScheme)` for dark/light mode
- System semantic colors (`.primary`, `.secondary`, `.accentColor`)
- Custom `EnvironmentKey` values for app-wide tokens

### 6. Safe Area

iOS has the notch, Dynamic Island, home indicator, and status bar. Content must respect the **safe area** — a concept web developers encounter only with `env(safe-area-inset-*)`. In SwiftUI, safe area is respected by default. You explicitly opt out with `.ignoresSafeArea()`.

---

## Quick Reference: Common Translations

| I want to... | Web | SwiftUI |
|---|---|---|
| Show/hide element | Conditional rendering / `display: none` | `if condition { View() }` |
| Conditional class | `className={active ? "on" : "off"}` | Ternary in modifier: `.foregroundStyle(active ? .blue : .gray)` |
| Text input | `<input type="text">` | `TextField("Placeholder", text: $value)` |
| Secure input | `<input type="password">` | `SecureField("Password", text: $password)` |
| Link | `<a href="...">` | `Link("Title", destination: URL(...))` |
| Image | `<img src="...">` | `AsyncImage(url: ...)` or `Image("assetName")` |
| Loading spinner | Custom or library | `ProgressView()` |
| Alert/confirm | `window.alert()` / `window.confirm()` | `.alert("Title", isPresented: $show) { ... }` |
| Scroll container | `overflow: scroll` | `ScrollView { ... }` |
| Grid | CSS Grid | `LazyVGrid(columns: [...]) { ... }` |
| Animation | CSS transitions / Framer Motion | `.animation(.spring, value: x)` / `withAnimation { }` |
