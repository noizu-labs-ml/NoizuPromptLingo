# Mac-Specific SwiftUI Components

Reference for SwiftUI components with Mac-specific behavior, styling, and patterns.

---

## Table — Multi-Column Sortable

Mac's `Table` is a full AppKit-backed NSTableView. Requires `Identifiable` rows.

```swift
struct FileItem: Identifiable {
    let id = UUID()
    var name: String
    var size: Int
    var modified: Date
}

struct FileListView: View {
    @State private var items: [FileItem] = FileItem.samples
    @State private var sortOrder = [KeyPathComparator(\FileItem.name)]
    @State private var selection = Set<FileItem.ID>()

    var body: some View {
        Table(items, selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.name)
            TableColumn("Size") { item in
                Text(item.size.formatted(.byteCount(style: .file)))
            }
            .width(min: 80, ideal: 100, max: 140)
            TableColumn("Modified", value: \.modified) { item in
                Text(item.modified.formatted(date: .abbreviated, time: .omitted))
            }
        }
        .onChange(of: sortOrder) { _, order in
            items.sort(using: order)
        }
    }
}
```

**Notes:**
- `TableColumn` with `value:` enables sorting; without `value:` it's display-only.
- `selection` can be `Set<ID>` (multi) or `Optional<ID>` (single).
- Combine with `contextMenu` on the Table for right-click menus.

---

## Form — Mac Styling

On macOS, `Form` uses a two-column label/control layout by default.

```swift
Form {
    Section("Network") {
        TextField("Host", text: $host)
        TextField("Port", value: $port, format: .number)
        Toggle("Use TLS", isOn: $useTLS)
    }
    Section("Credentials") {
        TextField("Username", text: $username)
        SecureField("Password", text: $password)
    }
}
.formStyle(.grouped)   // Inset grouped (like System Preferences)
// .formStyle(.columns) // Default two-column alignment
```

Use `.formStyle(.grouped)` for Settings windows. Use default (`.columns`) for inspector panels.

---

## GroupBox

Visual grouping with an optional label. Common in inspectors and Settings.

```swift
GroupBox("Appearance") {
    VStack(alignment: .leading, spacing: 8) {
        Toggle("Show toolbar labels", isOn: $showLabels)
        Toggle("Use compact layout", isOn: $compactLayout)
    }
    .padding(.top, 4)
}

// Nested GroupBox
GroupBox {
    GroupBox("Inner Group") {
        Text("Nested content")
    }
} label: {
    Label("Outer Group", systemImage: "folder")
}
```

---

## DisclosureGroup

Collapsible section — built-in chevron animation.

```swift
@State private var isExpanded = false

DisclosureGroup("Advanced Options", isExpanded: $isExpanded) {
    VStack(alignment: .leading) {
        Toggle("Enable debug logging", isOn: $debugLogging)
        Slider(value: $timeout, in: 1...60, label: { Text("Timeout") })
    }
    .padding(.leading, 4)
}

// Programmatic control
Button("Expand All") { isExpanded = true }
```

---

## HSplitView / VSplitView

Resizable pane splits. The system handles drag handles and cursor changes.

```swift
HSplitView {
    // Sidebar — constrain width
    SidebarView()
        .frame(minWidth: 180, maxWidth: 300)

    // Detail — fills remaining space
    DetailView()
        .frame(minWidth: 400)
}

// Three-pane layout
HSplitView {
    NavigationView()
        .frame(minWidth: 160, maxWidth: 240)
    ContentList()
        .frame(minWidth: 220, maxWidth: 380)
    InspectorView()
        .frame(minWidth: 300)
}
```

**Notes:**
- Wrap in `NavigationSplitView` (iOS/Mac Catalyst); use raw `HSplitView` for pure AppKit-backed Mac apps.
- `NavigationSplitView` respects sidebar show/hide toolbar button automatically.

---

## DatePicker

```swift
// Compact (date only — shows popover calendar on click)
DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
    .datePickerStyle(.compact)

// Graphical (inline calendar)
DatePicker("Select Date", selection: $date)
    .datePickerStyle(.graphical)
    .frame(maxWidth: 320)

// With range constraint
DatePicker("Appointment", selection: $appt,
           in: Date.now...,
           displayedComponents: [.date, .hourAndMinute])
```

---

## ColorPicker

```swift
ColorPicker("Accent Color", selection: $accentColor)
ColorPicker("Background", selection: $bgColor, supportsOpacity: false)
```

Opens the macOS system color panel. `supportsOpacity: false` hides the alpha slider.

---

## Stepper

```swift
// With formatted display
Stepper(value: $count, in: 0...100, step: 5) {
    Text("Items: \(count)")
}

// With explicit increment/decrement
Stepper("Font Size: \(fontSize)pt") {
    fontSize = min(fontSize + 1, 72)
} onDecrement: {
    fontSize = max(fontSize - 1, 8)
}
```

---

## Toggle — Renders as Checkbox on macOS

```swift
// Default: checkbox on Mac
Toggle("Enable notifications", isOn: $notificationsOn)

// Force switch style (e.g., in a Settings window header)
Toggle("Active", isOn: $isActive)
    .toggleStyle(.switch)

// Button toggle (toolbar-style)
Toggle("Bold", isOn: $isBold)
    .toggleStyle(.button)
    .buttonStyle(.bordered)
```

---

## Picker Styles

```swift
// Popup menu (default on Mac for most contexts)
Picker("Sort By", selection: $sortField) {
    Text("Name").tag(SortField.name)
    Text("Date").tag(SortField.date)
    Text("Size").tag(SortField.size)
}
.pickerStyle(.menu)

// Radio buttons (use in Forms / Settings)
Picker("View As", selection: $viewMode) {
    Text("List").tag(ViewMode.list)
    Text("Grid").tag(ViewMode.grid)
}
.pickerStyle(.radioGroup)
.horizontalRadioGroupLayout()  // Side-by-side instead of vertical

// Segmented control (toolbar / content area)
Picker("Mode", selection: $editMode) {
    Label("Select", systemImage: "arrow.up.left").tag(Mode.select)
    Label("Draw", systemImage: "pencil").tag(Mode.draw)
}
.pickerStyle(.segmented)
.frame(width: 160)
```

---

## TextEditor

Multi-line text field. No built-in placeholder — add one manually.

```swift
ZStack(alignment: .topLeading) {
    if text.isEmpty {
        Text("Enter notes...")
            .foregroundStyle(.tertiary)
            .padding(.horizontal, 5)
            .padding(.vertical, 8)
            .allowsHitTesting(false)
    }
    TextEditor(text: $text)
        .font(.body)
        .scrollContentBackground(.hidden)
        .background(Color(nsColor: .textBackgroundColor))
}
.frame(minHeight: 80)

// Disable rich text (plain text only)
TextEditor(text: $text)
    .environment(\.isScrollEnabled, false)  // Expand to fit (wrap in ScrollView)
```

---

## LabeledContent

Displays a label-value pair in Form/inspector style. Respects Form's column alignment.

```swift
Form {
    LabeledContent("Version", value: "1.4.2")
    LabeledContent("Build") {
        Text("2024.03.14")
            .foregroundStyle(.secondary)
    }
    LabeledContent("Memory Usage") {
        HStack {
            Text("128 MB")
            ProgressView(value: 0.25)
                .frame(width: 80)
        }
    }
}

// Outside Form — manual layout
LabeledContent("Status:") {
    StatusBadge(status: .active)
}
.labeledContentStyle(.automatic)
```

---

## Quick Reference: Control → Style Mapping

| Control | Mac Default | Override |
|---------|-------------|----------|
| `Toggle` | Checkbox | `.switch`, `.button` |
| `Picker` | Popup menu | `.radioGroup`, `.segmented`, `.inline` |
| `DatePicker` | Compact | `.graphical`, `.stepperField` |
| `Button` | Borderless | `.bordered`, `.borderedProminent` |
| `List` | Inset | `.plain`, `.sidebar` |
| `Form` | Columns | `.grouped` |
