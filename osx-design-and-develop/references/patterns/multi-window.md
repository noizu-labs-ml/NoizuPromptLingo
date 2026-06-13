# Multi-Window Patterns — SwiftUI macOS

## WindowGroup vs Window

```swift
// Multiple instances (documents, inspector panels)
WindowGroup("Editor", id: "editor") {
    EditorView()
}

// Single instance (preferences, about)
Window("Preferences", id: "preferences") {
    PreferencesView()
}
```

`WindowGroup` creates independent instances. `Window` enforces a single instance — re-opening focuses the existing window.

---

## openWindow Environment Action

```swift
struct ContentView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Open Inspector") {
            openWindow(id: "inspector")
        }
        Button("Open Document") {
            openWindow(value: documentID)  // WindowGroup must accept the value type
        }
    }
}
```

Pass typed values to `WindowGroup` by declaring a matching value parameter:

```swift
WindowGroup(for: UUID.self) { $id in
    if let id { DocumentView(id: id) }
}
```

---

## HandlesExternalEvents

Route URLs or drag-opens to a specific window scene:

```swift
WindowGroup {
    ContentView()
}
.handlesExternalEvents(matching: ["editor"])  // matches URL scheme path component
```

On the view level, prefer `.onOpenURL` or `.onContinueUserActivity`.

---

## Auxiliary Panels (Utility Windows)

```swift
Window("Inspector", id: "inspector") {
    InspectorPanel()
}
.windowStyle(.hiddenTitleBar)
.windowResizability(.contentSize)
.defaultSize(width: 260, height: 500)
.keyboardShortcut("i", modifiers: [.command, .option])
```

For floating panels that stay above document windows, drop to AppKit:

```swift
.background(WindowAccessor { nsWindow in
    nsWindow.level = .floating
    nsWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
})
```

---

## Window Positioning

```swift
// Hint — system may override
.defaultPosition(.topTrailing)
.defaultSize(width: 800, height: 600)

// Restore last position (automatic with WindowGroup)
// Disable restoration:
.restorationBehavior(.disabled)
```

Programmatic centering requires AppKit:

```swift
nsWindow.center()
nsWindow.setFrameAutosaveName("MainWindow")
```

---

## NSWindow Access via WindowAccessor

SwiftUI provides no direct NSWindow handle. Bridge with a representable:

```swift
struct WindowAccessor: NSViewRepresentable {
    let callback: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window { callback(window) }
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
```

Use sparingly — prefer SwiftUI APIs when available.

---

## Window Styles

```swift
.windowStyle(.hiddenTitleBar)      // content fills title bar area
.windowStyle(.titleBar)            // default
.windowStyle(.plain)               // borderless (use for custom chrome)
```

Toolbar integration:

```swift
.toolbar {
    ToolbarItem(placement: .navigation) { ... }
    ToolbarItem(placement: .principal) { ... }
    ToolbarItem(placement: .primaryAction) { ... }
}
.toolbarBackground(.hidden, for: .windowToolbar)
```

---

## Multiple Windows Coordination

Share state across windows via `@Observable` / `ObservableObject` injected at the App level:

```swift
@main
struct MyApp: App {
    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup { MainView() }
            .environment(store)
        Window("Inspector", id: "inspector") { InspectorView() }
            .environment(store)
    }
}
```

---

## Common Pitfalls

- `Window` scenes do not restore after quit unless you opt into `StateRestorationBehavior`.
- `openWindow` has no completion — use `@Environment(\.dismiss)` inside the window to close.
- `.windowResizability(.contentSize)` locks window to intrinsic content size; add `.frame(minWidth:)` to allow flex.
- Title bar transparency requires `.toolbarBackground(.hidden)` **and** `.background(.ultraThinMaterial)` in the content.
