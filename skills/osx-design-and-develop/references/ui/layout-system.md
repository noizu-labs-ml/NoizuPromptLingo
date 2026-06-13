# Desktop Layout System

SwiftUI layout patterns for macOS: splits, sizing, alignment, custom layouts, and Mac spacing conventions.

---

## Window Sizing

Set min/max window dimensions in the scene, not the view.

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 900, height: 600)
        .windowResizability(.contentMinSize)  // Prevents window below content minimum

        // Settings window — fixed or constrained
        Settings {
            SettingsView()
                .frame(minWidth: 400, maxWidth: 600,
                       minHeight: 300, maxHeight: 500)
        }
    }
}

// In the view, constrain content to drive window minimums
struct ContentView: View {
    var body: some View {
        HSplitView {
            SidebarView().frame(minWidth: 180)
            DetailView().frame(minWidth: 400)
        }
        .frame(minHeight: 400)
    }
}
```

---

## NavigationSplitView — Three-Column Layout

The standard Mac app layout (Finder, Mail, Notes pattern).

```swift
@State private var columnVisibility = NavigationSplitViewVisibility.all
@State private var selectedCategory: Category?
@State private var selectedItem: Item?

NavigationSplitView(columnVisibility: $columnVisibility) {
    // Sidebar
    List(Category.all, selection: $selectedCategory) { cat in
        Label(cat.name, systemImage: cat.icon)
    }
    .navigationTitle("Categories")
    .frame(minWidth: 160, idealWidth: 200)
} content: {
    // Content list
    if let category = selectedCategory {
        ItemList(category: category, selection: $selectedItem)
            .frame(minWidth: 220, idealWidth: 280)
    } else {
        ContentUnavailableView("Select a Category", systemImage: "sidebar.left")
    }
} detail: {
    // Detail
    if let item = selectedItem {
        ItemDetailView(item: item)
            .frame(minWidth: 380)
    } else {
        ContentUnavailableView("No Selection", systemImage: "doc")
    }
}
.navigationSplitViewStyle(.balanced)  // or .prominentDetail
```

**Sidebar toggle** — handled automatically by the toolbar button.
Force programmatic toggle: `columnVisibility = .detailOnly` / `.all`.

---

## HSplitView / VSplitView — Manual Splits

For custom split ratios without NavigationSplitView chrome.

```swift
struct EditorLayout: View {
    var body: some View {
        HSplitView {
            SourceEditorView()
                .frame(minWidth: 300)
            VSplitView {
                PreviewView()
                    .frame(minHeight: 200)
                ConsoleView()
                    .frame(minHeight: 80, maxHeight: 200)
            }
            .frame(minWidth: 280)
        }
    }
}
```

**Persisting split position** — wrap pane width in `@AppStorage`:

```swift
@AppStorage("inspectorWidth") private var inspectorWidth: Double = 260

// In HSplitView child:
InspectorView()
    .frame(width: inspectorWidth, minWidth: 200, maxWidth: 400)
    // NB: HSplitView manages the divider; this seeds the initial width
```

---

## GeometryReader

Use sparingly — prefer native layout first. Good for progress bars, canvas sizing, proportional splits.

```swift
struct ProportionalSplit: View {
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                PrimaryPane()
                    .frame(width: geo.size.width * 0.6)
                Divider()
                SecondaryPane()
                    .frame(width: geo.size.width * 0.4)
            }
        }
    }
}

// Safer pattern: read size, pass down
struct SizingContainer: View {
    @State private var containerSize: CGSize = .zero

    var body: some View {
        Color.clear
            .onGeometryChange(for: CGSize.self) { geo in
                geo.size
            } action: { size in
                containerSize = size
            }
            .overlay {
                ContentView(availableSize: containerSize)
            }
    }
}
```

---

## Alignment Guides

Align elements across sibling views — useful for label columns.

```swift
extension HorizontalAlignment {
    struct TrailingLabel: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.trailing]
        }
    }
    static let trailingLabel = HorizontalAlignment(TrailingLabel.self)
}

struct AlignedForm: View {
    var body: some View {
        VStack(alignment: .trailingLabel, spacing: 8) {
            HStack {
                Text("Name")
                    .alignmentGuide(.trailingLabel) { d in d[.trailing] }
                TextField("", text: $name)
            }
            HStack {
                Text("Email Address")
                    .alignmentGuide(.trailingLabel) { d in d[.trailing] }
                TextField("", text: $email)
            }
        }
    }
}
```

---

## Custom Layout Protocol

For truly custom arrangement (grid-like, radial, masonry).

```swift
struct EqualWidthHStack: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = subviews.map { $0.sizeThatFits(proposal).width }.max() ?? 0
        let totalWidth = maxWidth * CGFloat(subviews.count) + spacing * CGFloat(subviews.count - 1)
        let maxHeight = subviews.map { $0.sizeThatFits(proposal).height }.max() ?? 0
        return CGSize(width: totalWidth, height: maxHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let maxWidth = subviews.map { $0.sizeThatFits(proposal).width }.max() ?? 0
        var x = bounds.minX
        for subview in subviews {
            subview.place(at: CGPoint(x: x, y: bounds.midY),
                          anchor: .leading,
                          proposal: ProposedViewSize(width: maxWidth, height: bounds.height))
            x += maxWidth + spacing
        }
    }
}

// Usage
EqualWidthHStack(spacing: 12) {
    Button("Cancel") { }
    Button("Save") { }
        .buttonStyle(.borderedProminent)
}
```

---

## Adaptive Layout — Toolbar vs. Inspector

Toggle inspector panel with a toolbar button (Xcode / Preview pattern).

```swift
struct MainView: View {
    @State private var showInspector = true

    var body: some View {
        HStack(spacing: 0) {
            ContentArea()
                .frame(maxWidth: .infinity)

            if showInspector {
                Divider()
                InspectorPanel()
                    .frame(width: 260)
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showInspector)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showInspector.toggle()
                } label: {
                    Label("Inspector", systemImage: "sidebar.right")
                }
                .help("Show/hide inspector")
            }
        }
    }
}
```

---

## Mac Spacing Conventions

| Context | Value | Usage |
|---------|-------|-------|
| Between sections | `20` | VStack section gaps |
| Between related controls | `8` | Inside a group |
| Between unrelated controls | `12–16` | Across groups |
| Form row height | `22` | Standard control row |
| Sidebar row padding | `4` vertical | List row padding |
| Content area inset | `20` | `.padding(20)` for main panels |
| Inspector inset | `12–16` | Narrower panels |
| Toolbar height | Automatic | Never set manually |

```swift
// Standard content area
ScrollView {
    VStack(alignment: .leading, spacing: 20) {
        SectionOne()
        SectionTwo()
    }
    .padding(20)
}

// Inspector panel
VStack(alignment: .leading, spacing: 12) {
    InspectorSection("Transform") { TransformControls() }
    InspectorSection("Appearance") { AppearanceControls() }
}
.padding(14)
.frame(width: 260)
```

---

## Common Layout Recipes

### Full-Width Background Behind Sidebar List

```swift
List(items, selection: $selection) { item in
    ItemRow(item: item)
}
.listStyle(.sidebar)
.background(.regularMaterial)  // vibrancy sidebar effect
```

### Toolbar-Anchored Status Bar

```swift
VStack(spacing: 0) {
    MainContent()
    Divider()
    HStack {
        Text(statusMessage).font(.caption).foregroundStyle(.secondary)
        Spacer()
        ProgressView().controlSize(.small).opacity(isLoading ? 1 : 0)
    }
    .padding(.horizontal, 12)
    .frame(height: 22)
    .background(.bar)
}
```

### Centered Empty State

```swift
ContentUnavailableView {
    Label("No Results", systemImage: "magnifyingglass")
} description: {
    Text("Try adjusting your search or filter.")
} actions: {
    Button("Clear Filter") { filter = "" }
}
```
