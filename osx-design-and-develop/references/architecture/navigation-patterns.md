# macOS Navigation Patterns

## NavigationSplitView — 2-Column

The standard source-list layout. Sidebar + detail.

```swift
@Observable
final class SidebarViewModel {
    var selectedProjectID: Project.ID?
    var projects: [Project] = []
}

struct ContentView: View {
    @Environment(SidebarViewModel.self) var vm

    var body: some View {
        @Bindable var vm = vm

        NavigationSplitView {
            List(vm.projects, selection: $vm.selectedProjectID) { project in
                Label(project.name, systemImage: "folder")
                    .tag(project.id)
            }
            .listStyle(.sidebar)
            .navigationTitle("Projects")
        } detail: {
            if let id = vm.selectedProjectID,
               let project = vm.projects.first(where: { $0.id == id }) {
                ProjectDetailView(project: project)
            } else {
                ContentUnavailableView("Select a Project", systemImage: "folder")
            }
        }
    }
}
```

---

## NavigationSplitView — 3-Column

Sidebar + content list + detail. Common in mail/notes apps.

```swift
struct ThreeColumnView: View {
    @State private var selectedFolderID: Folder.ID?
    @State private var selectedNoteID: Note.ID?

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            FolderSidebar(selectedID: $selectedFolderID)
                .listStyle(.sidebar)
        } content: {
            if let folderID = selectedFolderID {
                NoteList(folderID: folderID, selectedID: $selectedNoteID)
            } else {
                Text("Choose a folder").foregroundStyle(.secondary)
            }
        } detail: {
            if let noteID = selectedNoteID {
                NoteEditor(noteID: noteID)
            } else {
                ContentUnavailableView("No Note Selected", systemImage: "note.text")
            }
        }
        .navigationSplitViewStyle(.balanced)  // or .prominentDetail
    }
}
```

**Column widths:**
```swift
.navigationSplitView(sidebar: { ... }, detail: { ... })
// Sidebar: set preferred width via .frame(minWidth:idealWidth:maxWidth:)
// on the sidebar content, not the split view itself
```

---

## Sidebar `.listStyle(.sidebar)`

Always use `.listStyle(.sidebar)` in the sidebar column — gives correct macOS
disclosure groups, hover states, and selection color.

```swift
List(selection: $selectedID) {
    Section("Favorites") {
        ForEach(favoriteItems) { item in
            Label(item.name, systemImage: item.icon)
                .tag(item.id)
                .badge(item.unreadCount)    // badge support
        }
    }
    Section("All Items") {
        DisclosureGroup("Archives") {
            ForEach(archivedItems) { item in
                Label(item.name, systemImage: "archivebox")
                    .tag(item.id)
            }
        }
    }
}
.listStyle(.sidebar)
```

---

## Inspector Panel

Slide-in inspector, right side. macOS 14+.

```swift
struct EditorView: View {
    @State private var inspectorIsPresented = true
    @State private var selectedElement: Element?

    var body: some View {
        CanvasView(selectedElement: $selectedElement)
            .inspector(isPresented: $inspectorIsPresented) {
                if let element = selectedElement {
                    ElementInspector(element: element)
                        .inspectorColumnWidth(min: 200, ideal: 270, max: 400)
                } else {
                    Text("Select an element")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        inspectorIsPresented.toggle()
                    } label: {
                        Label("Inspector", systemImage: "sidebar.right")
                    }
                }
            }
    }
}
```

---

## Programmatic Navigation with NavigationPath

For push-style navigation stacks within a detail column.

```swift
@Observable
final class NavigationState {
    var path = NavigationPath()

    func push(_ destination: AppDestination) {
        path.append(destination)
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}

enum AppDestination: Hashable {
    case projectDetail(Project.ID)
    case settings
    case export(Project.ID)
}

struct DetailNavigator: View {
    @Environment(NavigationState.self) var nav

    var body: some View {
        @Bindable var nav = nav

        NavigationStack(path: $nav.path) {
            ProjectListView()
                .navigationDestination(for: AppDestination.self) { dest in
                    switch dest {
                    case .projectDetail(let id): ProjectDetailView(id: id)
                    case .settings: SettingsView()
                    case .export(let id): ExportView(id: id)
                    }
                }
        }
    }
}
```

---

## TabView (Secondary Navigation)

Use TabView for top-level sections when sidebar would be sparse.
More common in iOS ports; on macOS prefer sidebar for most apps.

```swift
struct MainTabView: View {
    @State private var selectedTab: AppTab = .dashboard

    enum AppTab: String, CaseIterable {
        case dashboard = "Dashboard"
        case analytics = "Analytics"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .dashboard: "square.grid.2x2"
            case .analytics: "chart.line.uptrend.xyaxis"
            case .settings: "gear"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem { Label(tab.rawValue, systemImage: tab.icon) }
                    .tag(tab)
            }
        }
    }
}
```

---

## Toolbar View Switching

Segment control in toolbar to switch between views in the detail area.
Common pattern: list vs grid vs chart modes.

```swift
enum ViewMode: String, CaseIterable, Identifiable {
    case list, grid, chart
    var id: Self { self }
    var icon: String {
        switch self {
        case .list: "list.bullet"
        case .grid: "square.grid.2x2"
        case .chart: "chart.bar"
        }
    }
}

struct ProjectDetailView: View {
    @State private var viewMode: ViewMode = .list

    var body: some View {
        Group {
            switch viewMode {
            case .list:  ItemListView()
            case .grid:  ItemGridView()
            case .chart: ItemChartView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("View", selection: $viewMode) {
                    ForEach(ViewMode.allCases) { mode in
                        Image(systemName: mode.icon).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }
        }
    }
}
```

---

## Source List Pattern (Sidebar with Sections + Actions)

Full sidebar with add/remove buttons in the bottom bar — Finder-style.

```swift
struct SourceListView: View {
    @Binding var selectedID: Item.ID?
    var items: [Item]
    var onAdd: () -> Void
    var onDelete: (Item.ID) -> Void

    var body: some View {
        List(items, selection: $selectedID) { item in
            Label(item.name, systemImage: "doc")
                .tag(item.id)
                .contextMenu {
                    Button("Delete", role: .destructive) {
                        onDelete(item.id)
                    }
                }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button(action: onAdd) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(8)
            .background(.bar)
        }
    }
}
```
