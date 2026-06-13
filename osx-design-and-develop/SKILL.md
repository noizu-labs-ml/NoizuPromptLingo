---
name: trl-osx-design-and-develop
description: >
  Design and build production-ready macOS desktop applications using SwiftUI and Swift,
  from concept through Mac App Store submission or notarized direct distribution. Use
  this skill when the user wants to build a macOS app, design desktop interfaces, implement
  SwiftUI views for Mac, architect a desktop application, set up Xcode projects for macOS,
  create menu bar apps, build document-based apps, implement multi-window interfaces,
  add toolbar and inspector patterns, handle drag-and-drop, create Settings windows,
  or distribute via the Mac App Store or notarization — even if they don't say "macOS"
  or "desktop." Also trigger when users mention SwiftUI for Mac, AppKit, NSWindow,
  WindowGroup, MenuBarExtra, NavigationSplitView for desktop, macOS sandbox, entitlements,
  notarization, Sparkle updates, Mac Catalyst, or desktop app architecture.
---

# macOS Design and Develop

Design and ship production-ready macOS desktop applications — from concept to distribution — with SwiftUI-first architecture and full platform integration.

## Overview

This skill covers the complete macOS app lifecycle. macOS SwiftUI shares foundations with iOS but has critical platform-specific patterns: multi-window management, menu bars, keyboard-driven interaction, document-based architectures, and dual distribution paths (Mac App Store + notarized direct). The skill teaches these patterns while mapping familiar concepts from web and iOS development.

**Core Purpose:**
- Architect macOS apps using SwiftUI with AppKit interop where needed
- Implement multi-window, document-based, and menu bar application patterns
- Design desktop-native interfaces: sidebars, inspectors, toolbars, split views
- Handle macOS-specific concerns: sandboxing, entitlements, file access, permissions
- Navigate dual distribution: Mac App Store submission and notarized direct distribution
- Integrate system services: Spotlight, Share Extensions, Quick Look, Automator/Shortcuts

## Core Philosophy

1. **SwiftUI-first, AppKit when necessary** — Default to declarative SwiftUI for all new views. Drop to AppKit only for capabilities SwiftUI doesn't cover on Mac (certain NSTextView features, custom window chrome, low-level event handling). Always wrap AppKit in `NSViewRepresentable` to maintain a SwiftUI-native API surface.

2. **Desktop-native, not iOS-enlarged** — macOS users expect keyboard shortcuts, menu bar access, right-click context menus, drag-and-drop, resizable windows, and information-dense layouts. An iOS app stretched to fill a monitor is not a Mac app. Design for mouse+keyboard as the primary input.

3. **Multi-window as a first-class concept** — Unlike iOS where you have one scene, macOS apps routinely manage multiple windows, each potentially showing different content. Architect for `WindowGroup`, `Window`, and `MenuBarExtra` from the start.

4. **Respect the sandbox, escape when justified** — macOS sandboxing is more nuanced than iOS. Start sandboxed (required for Mac App Store), add entitlements only as needed, and use security-scoped bookmarks for persistent file access. For direct distribution, sandboxing is recommended but optional.

5. **Dual distribution awareness** — Mac apps can ship via App Store (sandboxed, StoreKit) or direct (notarized, custom licensing, Sparkle updates). Architecture decisions differ based on distribution path — the skill teaches both and when to choose each.

## When to Use This Skill

- **Building a new macOS app** — Full lifecycle from concept through distribution
- **Designing desktop interfaces** — Sidebars, inspectors, toolbars, split views, popovers
- **Creating a menu bar app** — `MenuBarExtra` with status item and popover/window
- **Building a document-based app** — `DocumentGroup`, file types, undo/redo, autosave
- **Implementing multi-window management** — `WindowGroup`, `Window`, `openWindow` environment action
- **Porting an iOS app to macOS** — Adapting mobile patterns to desktop conventions
- **Adding macOS system integrations** — Spotlight, Quick Look, Share Extensions, Shortcuts
- **Configuring sandboxing and entitlements** — File access, network, camera, microphone permissions
- **Distributing outside the App Store** — Notarization, Sparkle auto-updates, DMG/pkg creation
- **Migrating AppKit to SwiftUI** — Incremental adoption in existing Cocoa apps

> For iOS-specific development, see **trl-ios-mobile-engineer** — shares SwiftUI foundations but diverges on navigation, lifecycle, and distribution.
> For GPU-accelerated graphics on macOS, see **trl-metal-graphics-dev** — covers Metal shaders, compute pipelines, and CAMetalLayer.
> For web UI design principles that inform desktop layout, see **trl-user-experience-engineer** (`references/core-philosophy.md`).
> For validating your app idea before building, see **trl-market-intelligence** (`references/niche-discovery.md`).

## Web/iOS-to-macOS Concept Map

| Web / iOS Concept | macOS Equivalent | Key Differences |
|-------------------|-----------------|-----------------|
| React component / SwiftUI `View` | SwiftUI `View` (same) | Identical foundation; macOS adds hover, keyboard focus |
| Single page app | `WindowGroup` | Multiple instances possible; each is an independent window |
| Modal dialog | `.sheet()` or `NSPanel` | Sheets attach to parent window; panels float independently |
| `UITabBarController` | `TabView` (sidebar style) or custom sidebar | Mac tabs are typically top-of-window or sidebar, not bottom |
| `UINavigationController` | `NavigationSplitView` | Two- or three-column layout, not stack-based push/pop |
| iOS Settings bundle | `Settings` scene + `Form` | Dedicated app window via Cmd+, |
| `UIToolbar` | `.toolbar { }` with placement | Integrates with window title bar; supports customization |
| `UIContextMenuConfiguration` | `.contextMenu { }` | Right-click driven; expected on every interactive element |
| iOS share sheet | `NSSharingServicePicker` | Menu-based; integrates with system Share Extensions |
| App Store only | Mac App Store OR direct distribution | Notarization required for direct; Sparkle for auto-updates |
| `UserNotifications` | `UserNotifications` (same) | macOS Notification Center; banner vs alert styles |
| iOS Files app | Direct filesystem access | Open/Save panels, security-scoped bookmarks, sandbox entitlements |
| `UIDocumentBrowserViewController` | `DocumentGroup` | Native document architecture with autosave, undo, versioning |
| Drag from cell | `draggable()` / `dropDestination()` | Richer: file promises, pasteboard types, spring-loaded folders |
| Keyboard shortcuts (limited) | `.keyboardShortcut()` + `commands { }` | Expected everywhere; menu bar is the canonical shortcut surface |

## App Architecture Patterns

### Recommended: MVVM + Observable

The default architecture for new SwiftUI Mac apps. Same pattern as iOS.

```
View (SwiftUI)          <- Declarative UI, no business logic
  | binds to
ViewModel (@Observable) <- Business logic, state management
  | calls
Service layer           <- Networking, persistence, system APIs
  | maps to/from
Model (struct/enum)     <- Plain data types, Codable, Transferable
```

### macOS-Specific Architectural Concerns

| Concern | Pattern | Notes |
|---------|---------|-------|
| Multi-window state | Separate `@Observable` per window | Don't share mutable state across windows without coordination |
| Document architecture | `ReferenceFileDocument` or `FileDocument` | `FileDocument` for value-type docs; `ReferenceFileDocument` for complex mutable state |
| Menu bar app | Dedicated `@Observable` AppState | Lightweight; avoid heavy frameworks for status-item-only apps |
| Background processing | `Task` + `actor` | macOS allows true background work unlike iOS |
| File system access | Service layer with security-scoped bookmarks | Sandbox-aware; persist access across launches |

> For detailed architecture patterns, see [references/architecture/app-architecture.md](references/architecture/app-architecture.md).

## macOS App Scenes

SwiftUI on macOS supports multiple scene types that define your app's window topology:

| Scene Type | Purpose | Example |
|------------|---------|---------|
| `WindowGroup` | Main content window(s), multiple instances | Document editors, browsers |
| `Window` | Single-instance utility window | Activity monitor, preferences |
| `DocumentGroup` | Document-based app | Text editors, image editors |
| `MenuBarExtra` | Menu bar status item + popover/window | System utilities, quick-access tools |
| `Settings` | Preferences window (Cmd+,) | App configuration |

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            AppCommands()
        }

        Settings {
            SettingsView()
        }

        MenuBarExtra("Status", systemImage: "circle.fill") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
    }
}
```

## Desktop Navigation Patterns

| Pattern | Implementation | Use When |
|---------|---------------|----------|
| Sidebar + detail | `NavigationSplitView` (two-column) | File managers, mail clients, settings |
| Three-column | `NavigationSplitView` (three-column) | Mail-style: sidebar, list, detail |
| Sidebar + inspector | `NavigationSplitView` + `.inspector()` | Editors with property panels |
| Tab-based | `TabView` with `.tabViewStyle(.automatic)` | Grouped settings, dashboard sections |
| Toolbar-based | `.toolbar { }` with `ToolbarItem(placement:)` | Action bars, view switching |
| Source list | `List` with `.listStyle(.sidebar)` | Project navigators, library browsers |

> For comprehensive navigation implementation, see [references/architecture/navigation-patterns.md](references/architecture/navigation-patterns.md).

## macOS-Specific UI Patterns

### Toolbar and Title Bar

```swift
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        Button("Add", systemImage: "plus") { }
    }
    ToolbarItem(placement: .automatic) {
        Picker("View", selection: $viewMode) {
            Label("Grid", systemImage: "square.grid.2x2").tag(ViewMode.grid)
            Label("List", systemImage: "list.bullet").tag(ViewMode.list)
        }
        .pickerStyle(.segmented)
    }
}
.toolbarRole(.editor) // Hides title for content-focused apps
```

### Keyboard Shortcuts and Commands

```swift
.commands {
    CommandGroup(after: .newItem) {
        Button("New from Template...") {
            // action
        }
        .keyboardShortcut("n", modifiers: [.command, .shift])
    }
    CommandMenu("Format") {
        Button("Bold") { }.keyboardShortcut("b")
        Button("Italic") { }.keyboardShortcut("i")
    }
}
```

### Inspector Panel

```swift
NavigationSplitView {
    SidebarView()
} detail: {
    DetailView()
        .inspector(isPresented: $showInspector) {
            InspectorView(item: selectedItem)
                .inspectorColumnWidth(min: 200, ideal: 300, max: 400)
        }
}
.toolbar {
    ToolbarItem {
        Button("Inspector", systemImage: "sidebar.right") {
            showInspector.toggle()
        }
    }
}
```

### Drag and Drop

```swift
// Source
Text(item.name)
    .draggable(item) // Item must conform to Transferable

// Destination
DropZone()
    .dropDestination(for: MyItem.self) { items, location in
        handleDrop(items)
        return true
    }

// Transferable conformance
struct MyItem: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .myItemType)
        FileRepresentation(contentType: .png) { item in
            SentTransferredFile(item.pngURL)
        } importing: { received in
            // import from file
        }
    }
}
```

## Sandboxing and Entitlements

### Sandbox Decision Matrix

| Distribution | Sandbox Required? | Recommendation |
|-------------|-------------------|----------------|
| Mac App Store | Yes (mandatory) | Design for sandbox from day one |
| Direct (notarized) | No (but recommended) | Sandbox unless you need unrestricted file/network access |
| Enterprise / internal | No | Sandbox if feasible for security posture |

### Common Entitlements

| Entitlement | Purpose | When Needed |
|-------------|---------|-------------|
| `com.apple.security.files.user-selected.read-write` | Open/Save panel access | Almost all document apps |
| `com.apple.security.files.bookmarks.app-scope` | Persist file access across launches | Apps that remember recent files |
| `com.apple.security.network.client` | Outbound network requests | Any app that calls APIs |
| `com.apple.security.network.server` | Accept inbound connections | Local servers, peer-to-peer |
| `com.apple.security.device.camera` | Camera access | Video/photo apps |
| `com.apple.security.device.microphone` | Microphone access | Audio/video apps |
| `com.apple.security.personal-information.location` | Location services | Location-aware apps |
| `com.apple.security.files.downloads.read-write` | Downloads folder access | Download managers |
| `com.apple.security.temporary-exception.*` | Escape hatch (App Store may reject) | Legacy compatibility only |

> For detailed sandboxing guidance, see [references/lifecycle/sandboxing-entitlements.md](references/lifecycle/sandboxing-entitlements.md).

## Distribution Paths

### Path A: Mac App Store

| Step | Tool/Action | Notes |
|------|------------|-------|
| Archive | Xcode > Product > Archive | Release build with signing |
| Upload | Xcode Organizer or `xcrun altool` | Uploads to App Store Connect |
| TestFlight | App Store Connect | Beta testing (up to 10,000 testers) |
| Review | Apple Review | 1-3 day review cycle |
| Release | App Store Connect | Manual or auto-release after approval |

**Constraints:** Sandboxed, StoreKit for payments, Apple's 30% cut, review guidelines.

### Path B: Direct Distribution (Notarized)

| Step | Tool/Action | Notes |
|------|------------|-------|
| Archive | Xcode > Product > Archive | Developer ID signed |
| Notarize | `xcrun notarytool submit` | Apple scans for malware; ~5 min |
| Staple | `xcrun stapler staple` | Attaches notarization ticket to app |
| Package | Create DMG or pkg installer | `create-dmg` tool or `pkgbuild` |
| Distribute | Website, GitHub Releases, CDN | Your hosting, your rules |
| Auto-update | Sparkle framework | Industry standard for Mac auto-updates |

**Advantages:** No sandbox requirement, custom licensing, 0% revenue share, instant releases.

> For complete distribution guides, see [references/lifecycle/app-store-submission.md](references/lifecycle/app-store-submission.md) and [references/lifecycle/direct-distribution.md](references/lifecycle/direct-distribution.md).

## Quick Start Guides

### Build a Windowed Mac App
1. Define scene topology: how many window types, sidebar vs tabs, inspector panels
2. Scaffold with [references/architecture/app-architecture.md](references/architecture/app-architecture.md)
3. Implement navigation per [references/architecture/navigation-patterns.md](references/architecture/navigation-patterns.md)
4. Add keyboard shortcuts and menu commands
5. Configure sandboxing per [references/lifecycle/sandboxing-entitlements.md](references/lifecycle/sandboxing-entitlements.md)
6. Test on multiple screen sizes and with keyboard navigation

### Build a Menu Bar App
1. Create `MenuBarExtra` scene (popover or window style)
2. Implement lightweight `@Observable` state
3. Add system event listeners if needed (network, power, etc.)
4. Configure as LSUIElement (no Dock icon) if appropriate
5. Distribute via notarized DMG

### Build a Document-Based App
1. Define `FileDocument` or `ReferenceFileDocument` with UTType
2. Set up `DocumentGroup` scene
3. Implement undo/redo via `UndoManager`
4. Add autosave support
5. Register UTTypes in Info.plist
6. Test with Versions (File > Revert To)

### Port an iOS App to macOS
1. Audit iOS app for platform assumptions (see concept map above)
2. Replace `UINavigationController` patterns with `NavigationSplitView`
3. Add keyboard shortcuts, context menus, and toolbar
4. Handle window resizing and multi-window
5. Replace iOS-only APIs with macOS equivalents (see [references/foundations/appkit-interop.md](references/foundations/appkit-interop.md))
6. Decide distribution path (Mac App Store vs direct)

## Reference Guide

| Task | Read These |
|------|-----------|
| **Starting any macOS project** | `foundations/macos-design-principles.md`, `architecture/app-architecture.md` |
| **Choosing app architecture** | `architecture/app-architecture.md`, `architecture/state-management.md` |
| **Designing navigation** | `architecture/navigation-patterns.md` |
| **Building UI components** | `ui/swiftui-mac-components.md`, `ui/layout-system.md` |
| **AppKit interop** | `foundations/appkit-interop.md` |
| **Window management** | `patterns/multi-window.md` |
| **Document-based apps** | `patterns/document-architecture.md` |
| **Menu bar apps** | `patterns/menu-bar-apps.md` |
| **Keyboard and menus** | `patterns/keyboard-shortcuts-menus.md` |
| **Drag and drop** | `patterns/drag-and-drop.md` |
| **Sandbox and entitlements** | `lifecycle/sandboxing-entitlements.md` |
| **Mac App Store submission** | `lifecycle/app-store-submission.md` |
| **Direct distribution** | `lifecycle/direct-distribution.md` |
| **Performance profiling** | `lifecycle/performance-profiling.md` |
| **Testing strategy** | `lifecycle/testing-strategy.md` |
| **Full build walkthrough** | `worked-example-notes-app.md` |
| **Menu bar app walkthrough** | `worked-example-menubar-utility.md` |

All reference paths are relative to `references/`.

## Related Skills

- **trl-ios-mobile-engineer** — Shared SwiftUI foundations; use for iOS-specific patterns (push notifications, App Clips, HealthKit)
- **trl-metal-graphics-dev** — GPU-accelerated rendering on macOS; use when your Mac app needs custom graphics pipelines
- **trl-user-experience-engineer** — Desktop UI design principles, wireframing, accessibility audits
- **trl-plugin-architect** — If your Mac app needs an extension/plugin system
- **trl-tui-engineer** — If building a CLI companion alongside the Mac app
- **trl-market-intelligence** — Validate your Mac app idea and identify the target audience
- **trl-seo-guru** — Optimize Mac App Store listing (ASO)

## Bundled Resources

### References

**Foundations** (read first for any macOS project):
- [macos-design-principles.md](references/foundations/macos-design-principles.md) — macOS Human Interface Guidelines distilled: information density, keyboard-first, window management
- [swift-essentials.md](references/foundations/swift-essentials.md) — Swift patterns critical for macOS: actors, async/await, Transferable, UTType
- [swiftui-for-web-devs.md](references/foundations/swiftui-for-web-devs.md) — SwiftUI concepts mapped from web development (shared with iOS skill)
- [appkit-interop.md](references/foundations/appkit-interop.md) — When and how to use AppKit: NSViewRepresentable, NSWindowDelegate, NSEvent

**Architecture:**
- [app-architecture.md](references/architecture/app-architecture.md) — MVVM + Observable, multi-window state, document architecture decisions
- [navigation-patterns.md](references/architecture/navigation-patterns.md) — NavigationSplitView, sidebar, three-column, inspector patterns
- [state-management.md](references/architecture/state-management.md) — @Observable, @Environment, cross-window state, undo/redo integration

**UI:**
- [swiftui-mac-components.md](references/ui/swiftui-mac-components.md) — Mac-specific SwiftUI components: Table, Form, GroupBox, DisclosureGroup, HSplitView
- [layout-system.md](references/ui/layout-system.md) — Desktop layout: resizable splits, minimum window sizes, adaptive density
- [accessibility-macos.md](references/ui/accessibility-macos.md) — VoiceOver, keyboard navigation, accessibility inspector, reduced motion

**Patterns:**
- [multi-window.md](references/patterns/multi-window.md) — WindowGroup, Window, openWindow, window restoration, auxiliary panels
- [document-architecture.md](references/patterns/document-architecture.md) — FileDocument, ReferenceFileDocument, UTType registration, undo/redo, autosave
- [menu-bar-apps.md](references/patterns/menu-bar-apps.md) — MenuBarExtra, status items, popover vs window, LSUIElement, login items
- [keyboard-shortcuts-menus.md](references/patterns/keyboard-shortcuts-menus.md) — Commands, CommandGroup, keyboardShortcut, main menu customization
- [drag-and-drop.md](references/patterns/drag-and-drop.md) — Transferable, draggable, dropDestination, file promises, pasteboard
- [system-integrations.md](references/patterns/system-integrations.md) — Spotlight, Quick Look, Share Extensions, Shortcuts, Services menu

**Lifecycle:**
- [sandboxing-entitlements.md](references/lifecycle/sandboxing-entitlements.md) — App Sandbox, entitlements, security-scoped bookmarks, temporary exceptions
- [app-store-submission.md](references/lifecycle/app-store-submission.md) — Mac App Store: review guidelines, screenshots, metadata, TestFlight
- [direct-distribution.md](references/lifecycle/direct-distribution.md) — Notarization, Sparkle, DMG/pkg creation, custom licensing
- [performance-profiling.md](references/lifecycle/performance-profiling.md) — Instruments, memory graph debugger, Energy Impact, hang detection
- [testing-strategy.md](references/lifecycle/testing-strategy.md) — XCTest, Swift Testing, UI testing on Mac, snapshot testing

**Worked Examples:**
- [worked-example-notes-app.md](references/worked-example-notes-app.md) — Full walkthrough: document-based notes app with sidebar, markdown preview, iCloud sync
- [worked-example-menubar-utility.md](references/worked-example-menubar-utility.md) — Menu bar clipboard manager with global hotkey and popover UI

### Assets

- [app-brief-worksheet.md](assets/app-brief-worksheet.md) — Intake form for capturing macOS app requirements, window topology, distribution path
- [app-scoring-rubric.md](assets/app-scoring-rubric.md) — Quality scoring template for macOS app architecture and implementation
- [project-tracker.md](assets/project-tracker.md) — macOS app project tracker for milestones and deliverables
