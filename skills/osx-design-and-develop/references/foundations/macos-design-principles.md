# macOS Design Principles — HIG Distilled

## Core Philosophy

macOS apps are **power tools**. Users sit at desks, use keyboards, manage multiple windows, and run apps for hours. Design for efficiency, not discoverability theater.

iOS designs for touch, infrequent use, and a single focused task. macOS designs for precision input, persistent sessions, and parallel workflows.

---

## macOS vs iOS Design Philosophy

| Dimension | macOS | iOS |
|-----------|-------|-----|
| Input model | Keyboard + precise pointer | Touch, fat fingers |
| Session length | Hours, persistent state | Minutes, stateless |
| Window model | Multiple overlapping windows | One app at a time |
| Navigation | Menu bar, keyboard shortcuts | Back buttons, tabs |
| Information density | High — users can handle it | Low — reduce cognitive load |
| Discoverability | Menus + tooltips + Help | Affordances + onboarding |
| Multitasking | Native — users switch constantly | Limited, system-managed |
| File system | Visible, users manage files | Hidden behind app sandboxes |
| Screen real estate | Large, resizable windows | Fixed viewport |
| Error recovery | Undo everything, Cmd+Z is sacred | Confirm-before-destructive |

---

## Information Density

macOS users expect **compact, information-rich** interfaces. Dense lists, sidebars with many items, and tables with multiple columns are appropriate. Avoid:

- Large touch targets (44pt minimums are iOS — use 22-28pt on macOS)
- Excessive whitespace and padding
- Single-column layouts that waste horizontal space
- Cards when a table row communicates the same thing

Use `List` with `.listStyle(.sidebar)` for navigation. Use `Table` (not `List`) for tabular data with sortable columns.

---

## Keyboard-First Interaction

Every destructive action needs a keyboard shortcut. Every navigation has a keyboard equivalent. Design assumes the user's hands are on the keyboard.

```swift
// Every menu item should have a shortcut
Button("Delete Item") { deleteItem() }
    .keyboardShortcut(.delete, modifiers: [])

// Commands registered in App body
.commands {
    CommandGroup(after: .newItem) {
        Button("Import...") { showImporter() }
            .keyboardShortcut("i", modifiers: [.command, .shift])
    }
}
```

Standard macOS keyboard conventions:
- `Cmd+N` — New document/item
- `Cmd+O` — Open
- `Cmd+S` — Save
- `Cmd+Z` / `Cmd+Shift+Z` — Undo/Redo
- `Cmd+,` — Preferences/Settings
- `Cmd+W` — Close window
- `Cmd+Q` — Quit app
- `Cmd+F` — Find
- `Delete` — Delete selected item (no Cmd modifier)
- `Return` — Confirm/Accept default action
- `Escape` — Cancel/Dismiss

---

## Window Management

Users expect windows to be resizable, movable, and remembered. Apps that open at a fixed size or forget window position are broken.

```swift
WindowGroup {
    ContentView()
}
.defaultSize(width: 900, height: 600)
.windowResizability(.contentMinSize)

// Settings window: fixed size, single instance
Settings {
    SettingsView()
}
```

Window expectations:
- Remember size and position between launches (`@AppStorage` or scene storage)
- Support full screen (`WindowGroup` does this automatically)
- Respect minimum content size — don't let window collapse to unusable state
- Document-based apps: each document gets its own window

---

## Menu Bar Conventions

The menu bar is the canonical home for all app capabilities. If a feature exists, it should be findable in the menu bar.

Standard menu structure:
1. **App menu** (app name) — About, Settings, Services, Quit
2. **File** — New, Open, Close, Save, Export, Print
3. **Edit** — Undo, Redo, Cut, Copy, Paste, Select All, Find
4. **View** — Show/hide panels, zoom, full screen
5. **Window** — Minimize, Zoom, Bring All to Front, open windows list
6. **Help** — Search, documentation link

```swift
// Add to app-level commands
.commands {
    CommandMenu("Tools") {
        Button("Analyze...") { analyze() }
            .keyboardShortcut("a", modifiers: [.command, .option])
    }
}
```

Never remove standard Edit menu items — the system uses them for text fields automatically.

---

## Toolbar Patterns

Toolbars live below the title bar. Use them for frequent, document-scoped actions — not navigation.

```swift
.toolbar {
    ToolbarItem(placement: .navigation) {
        Button(action: toggleSidebar) {
            Image(systemName: "sidebar.left")
        }
    }
    ToolbarItemGroup(placement: .primaryAction) {
        Button("Add") { addItem() }
        Button("Delete") { deleteItem() }
    }
    ToolbarItem(placement: .automatic) {
        Spacer()
    }
}
```

Placement options that matter:
- `.navigation` — leftmost, sidebar toggle lives here
- `.primaryAction` — right side, main actions
- `.status` — center, document title or status
- `.automatic` — system decides

---

## Respecting System Preferences

### Dark Mode
Never hardcode colors. Use semantic colors from the system or define your own asset catalog colors with light/dark variants.

```swift
// Good — adapts automatically
Color(.controlBackground)
Color(.labelColor)
Color(.separatorColor)

// Bad — hardcoded
Color(red: 0.95, green: 0.95, blue: 0.95)
```

### Accent Color
Use `.accentColor` (or omit it) to inherit the user's chosen accent. Don't override it to your brand color — that's an iOS pattern.

### Reduced Motion
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

withAnimation(reduceMotion ? nil : .spring()) {
    expanded.toggle()
}
```

### Text Size / Dynamic Type
macOS supports Dynamic Type. Use `Font` semantic styles (`.body`, `.headline`) over fixed sizes.

---

## Key Differences from iOS to Internalize

- No navigation bar — use `NavigationSplitView` sidebars instead
- No tab bar at the bottom — use sidebar or segmented controls in toolbar
- No large title style — `.navigationTitle` renders inline on macOS
- Right-click (`.contextMenu`) is expected everywhere — add it to list rows, canvas items, toolbar buttons
- Hover states matter — `.onHover` for custom cursors and highlight states
- Drag and drop is a first-class citizen — users expect to drag files onto your app
- Sheets are for short modal tasks — long workflows use new windows or panels
