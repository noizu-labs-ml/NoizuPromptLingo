# Keyboard Shortcuts & Menus — SwiftUI macOS

## .commands Modifier

Attach custom menu commands to a scene:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
            .commands {
                AppCommands()
            }
    }
}
```

---

## CommandGroup — Modify Existing Menus

```swift
struct AppCommands: Commands {
    CommandGroup(replacing: .newItem) {
        Button("New Document") { createDocument() }
            .keyboardShortcut("n", modifiers: .command)
    }

    CommandGroup(after: .saveItem) {
        Button("Export PDF...") { exportPDF() }
    }

    CommandGroup(replacing: .appInfo) {
        Button("About My App") { showAbout() }
    }
}
```

Placement options: `.newItem`, `.saveItem`, `.printItem`, `.undoRedo`, `.pasteboard`,
`.appInfo`, `.appSettings`, `.systemServices`, `.appVisibility`, `.appTermination`,
`.help`, `.singleWindowList`, `.windowArrangement`.

---

## CommandMenu — New Top-Level Menu

```swift
CommandMenu("Format") {
    Button("Bold") { toggleBold() }
        .keyboardShortcut("b", modifiers: .command)
    Button("Italic") { toggleItalic() }
        .keyboardShortcut("i", modifiers: .command)
    Divider()
    Menu("Font Size") {
        Button("Increase") { increaseFontSize() }
            .keyboardShortcut("+", modifiers: .command)
        Button("Decrease") { decreaseFontSize() }
            .keyboardShortcut("-", modifiers: .command)
    }
}
```

---

## .keyboardShortcut

```swift
Button("Save") { save() }
    .keyboardShortcut("s", modifiers: .command)         // Cmd+S

Button("Save All") { saveAll() }
    .keyboardShortcut("s", modifiers: [.command, .shift]) // Cmd+Shift+S

Button("Delete") { delete() }
    .keyboardShortcut(.deleteForward, modifiers: [])    // Delete key, no modifiers

Button("Refresh") { refresh() }
    .keyboardShortcut("r", modifiers: .command)

// Disable a default shortcut (e.g. Cmd+W close)
Button("") {}
    .keyboardShortcut("w", modifiers: .command)
    .hidden()
```

Common `KeyEquivalent` constants: `.return`, `.escape`, `.tab`, `.deleteBackward`,
`.deleteForward`, `.space`, `.upArrow`, `.downArrow`, `.leftArrow`, `.rightArrow`,
`.home`, `.end`, `.pageUp`, `.pageDown`, `.f1`–`.f12`.

---

## Standard System Shortcuts (Never Override)

| Shortcut | Action |
|----------|--------|
| Cmd+C/V/X | Copy/Paste/Cut |
| Cmd+Z / Cmd+Shift+Z | Undo/Redo |
| Cmd+Q | Quit |
| Cmd+H / Cmd+M | Hide / Minimize |
| Cmd+, | Preferences/Settings |
| Cmd+? | Help search |

---

## Focus-Based Shortcuts

Shortcuts in `Commands` are always active. For focus-scoped shortcuts, use `.onKeyPress`:

```swift
TextField("Search", text: $query)
    .onKeyPress(.escape) {
        query = ""
        return .handled
    }
    .onKeyPress(characters: .alphanumerics, phases: .down) { press in
        // handle
        return .ignored  // let TextField process it too
    }
```

Or `.focusedValue` + `@FocusedValue` for cross-view command binding:

```swift
// In view:
.focusedValue(\.selectedItem, item)

// In Commands:
@FocusedValue(\.selectedItem) var selectedItem: Item?

Button("Edit Item") { edit(selectedItem) }
    .disabled(selectedItem == nil)
```

Define the key:

```swift
extension FocusedValues {
    @Entry var selectedItem: Item? = nil
}
```

---

## Menu Item Validation / State

```swift
// Disable when no selection
Button("Delete Selection") { deleteSelection() }
    .disabled(selection.isEmpty)

// Checkmark state via Toggle
Toggle("Show Ruler", isOn: $showRuler)
    .keyboardShortcut("r", modifiers: [.command, .shift])

// Radio group via Picker in commands
Picker("View Mode", selection: $viewMode) {
    Text("List").tag(ViewMode.list)
    Text("Grid").tag(ViewMode.grid)
}
// Renders as checkmarked menu items in .menu style
```

---

## Submenus

```swift
CommandMenu("Insert") {
    Menu("Shape") {
        Button("Rectangle") { insertRect() }
        Button("Circle") { insertCircle() }
        Button("Triangle") { insertTriangle() }
    }
    Menu("Text") {
        Button("Heading") { insertHeading() }
        Button("Body") { insertBody() }
    }
}
```

Nesting beyond two levels degrades usability — prefer flat structure with contextual grouping.

---

## Settings / Preferences

Use the dedicated `Settings` scene (renders as Cmd+, target automatically):

```swift
Settings {
    SettingsView()
}
```

Do not add a "Preferences" menu item manually — `Settings` scene registers it.

---

## Common Pitfalls

- `Commands` structs must be value types (struct, not class).
- `@FocusedValue` returns `nil` when no view with that key is in focus — always `guard` or `.disabled`.
- `.keyboardShortcut` on a `Button` inside `Commands` works globally; inside a `View` it's focus-scoped.
- `CommandGroup(replacing:)` removes the entire default group including all Apple-provided items — add back what you need.
- Modifier-free shortcuts (`.keyboardShortcut("a", modifiers: [])`) intercept the key everywhere, including text fields.
