# SwiftUI for Web Developers

Mental model translation from React/CSS/HTML to SwiftUI.

---

## Core Mental Model

| Web Concept | SwiftUI Equivalent | Notes |
|-------------|-------------------|-------|
| Component | `View` (struct) | Computed `body` property = render function |
| `useState` | `@State` | Local component state |
| `useContext` | `@Environment` | Injected values, read-only |
| Store (Zustand/Redux) | `@Observable` class | Shared mutable state |
| `useEffect` | `.task`, `.onChange`, `.onAppear` | Side effects |
| CSS class | View modifier (`.font()`, `.padding()`) | Chainable, order matters |
| Flexbox row | `HStack` | Default spacing applies |
| Flexbox column | `VStack` | Default spacing applies |
| `z-index` stack | `ZStack` | Last child = topmost |
| Router outlet | `NavigationSplitView` / `NavigationStack` | |
| Modal / Dialog | `.sheet`, `.popover`, `.alert` | |
| Right-click menu | `.contextMenu` | |
| `<header>` toolbar | `.toolbar { }` | |
| CSS `display: none` | `.hidden()` / `if condition { View() }` | |
| CSS Grid | `Grid` + `GridRow` | SwiftUI 4+ |
| Scroll container | `ScrollView` | |
| `<input>` | `TextField`, `TextEditor`, `Toggle`, `Slider` | |

---

## State — @State vs @Observable

### React
```tsx
// Local state
const [count, setCount] = useState(0)
const [user, setUser] = useState<User | null>(null)

// Derived
const doubled = count * 2
```

### SwiftUI
```swift
// Local state — value types only
@State private var count = 0
@State private var user: User? = nil

// Derived — just a computed property
var doubled: Int { count * 2 }

// Mutate inside view
Button("Increment") { count += 1 }
// Note: @State mutation is always on MainActor
```

---

## Shared State — Store Pattern

### React (Zustand)
```tsx
const useStore = create((set) => ({
  items: [],
  add: (item) => set((s) => ({ items: [...s.items, item] })),
}))

function MyComponent() {
  const { items, add } = useStore()
}
```

### SwiftUI (@Observable)
```swift
@Observable
class AppStore {
    var items: [Item] = []
    func add(_ item: Item) { items.append(item) }
}

// Inject at root
@main struct MyApp: App {
    @State private var store = AppStore()
    var body: some Scene {
        WindowGroup { ContentView().environment(store) }
    }
}

// Consume anywhere in tree
struct MyView: View {
    @Environment(AppStore.self) var store
    var body: some View {
        List(store.items) { item in Text(item.name) }
    }
}
```

---

## Side Effects

### React
```tsx
useEffect(() => {
  fetchData()
}, [id])

useEffect(() => {
  return () => cleanup()
}, [])
```

### SwiftUI
```swift
// Run on appear, cancel on disappear
.task { await fetchData() }

// Re-run when id changes
.task(id: selectedID) {
    guard let id = selectedID else { return }
    await fetchData(id: id)
}

// Synchronous reaction to state change
.onChange(of: searchText) { old, new in
    filterResults(query: new)
}

// Mount/unmount equivalent
.onAppear { startTimer() }
.onDisappear { stopTimer() }
```

---

## Navigation — Router Equivalent

### React Router
```tsx
<Routes>
  <Route path="/" element={<Sidebar />} />
  <Route path="/item/:id" element={<Detail />} />
</Routes>
```

### SwiftUI
```swift
// Three-column split (Mail/Finder style)
NavigationSplitView {
    SidebarView(selection: $selectedCategory)
} content: {
    ItemListView(category: selectedCategory, selection: $selectedItem)
} detail: {
    if let item = selectedItem {
        DetailView(item: item)
    } else {
        Text("Select an item").foregroundStyle(.secondary)
    }
}

// Stack navigation (push/pop)
NavigationStack(path: $path) {
    RootView()
        .navigationDestination(for: Item.self) { item in
            DetailView(item: item)
        }
}
// Navigate: path.append(item)
// Pop: path.removeLast()
// Pop to root: path = []
```

---

## View Modifiers — CSS Equivalent

Modifiers chain like CSS but **order matters** — each modifier wraps the previous view.

### CSS
```css
.card {
  padding: 16px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  font-size: 14px;
}
```

### SwiftUI
```swift
Text("Hello")
    .font(.subheadline)           // font-size + weight
    .foregroundStyle(.secondary)  // color
    .padding(16)                  // padding (inside)
    .background(.background)      // background fills padded area
    .clipShape(.rect(cornerRadius: 8))  // border-radius
    .shadow(radius: 4, y: 2)     // box-shadow
```

Key difference: `.padding()` then `.background()` pads the background. `.background()` then `.padding()` adds space outside the background.

---

## Modals and Overlays

### React
```tsx
{isOpen && <Modal onClose={() => setIsOpen(false)} />}
// Or: <Dialog open={isOpen} />
```

### SwiftUI
```swift
// Sheet (bottom slide-up on iOS, centered modal on macOS)
.sheet(isPresented: $showingSheet) {
    SheetContent()
        .frame(minWidth: 400, minHeight: 300)
}

// Popover (anchored to a view)
.popover(isPresented: $showingPopover) {
    PopoverContent().padding()
}

// Alert
.alert("Delete Item?", isPresented: $showingAlert) {
    Button("Delete", role: .destructive) { deleteItem() }
    Button("Cancel", role: .cancel) {}
} message: {
    Text("This cannot be undone.")
}

// Confirmation dialog (action sheet style)
.confirmationDialog("Choose export format", isPresented: $showingExport) {
    Button("PDF") { exportPDF() }
    Button("CSV") { exportCSV() }
}
```

---

## Toolbar — Header/Nav Bar Equivalent

```swift
// In a NavigationSplitView or NavigationStack
.toolbar {
    // Left side — navigation
    ToolbarItem(placement: .navigation) {
        Button(action: toggleSidebar) {
            Image(systemName: "sidebar.left")
        }
    }

    // Right side — actions
    ToolbarItemGroup(placement: .primaryAction) {
        Button { addItem() } label: {
            Label("Add", systemImage: "plus")
        }
        Menu {
            Button("Sort by Name") { sortByName() }
            Button("Sort by Date") { sortByDate() }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
        }
    }

    // Center — status/title
    ToolbarItem(placement: .status) {
        Text("\(items.count) items")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}
```

---

## Context Menu — Right-Click

```swift
List(items) { item in
    ItemRow(item: item)
        .contextMenu {
            Button("Open") { open(item) }
            Button("Rename...") { rename(item) }
            Divider()
            Button("Delete", role: .destructive) { delete(item) }
        }
}
```

---

## Conditional Rendering

### React
```tsx
{isLoading ? <Spinner /> : <Content />}
{error && <ErrorBanner message={error} />}
```

### SwiftUI
```swift
if isLoading {
    ProgressView()
} else {
    ContentView()
}

// Inline with Group
Group {
    if let error {
        ErrorBanner(message: error)
    }
}

// Switch on enum state (preferred for complex states)
switch viewState {
case .loading: ProgressView()
case .loaded(let data): DataView(data: data)
case .error(let msg): ErrorView(message: msg)
}
```
