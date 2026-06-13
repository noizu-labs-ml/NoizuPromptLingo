# Data Flow

## Current Implementation (Stage 0.5)

The current build focuses on the canvas render engine tuning UI. The clipboard monitoring and persistence layers are not yet implemented.

```mermaid
graph LR
    LAUNCH[App Launch] --> PRE[Pre-warm textures + Metal pipeline]
    PRE --> HOTKEY[HotkeyManager registers Cmd+Shift+T]
    HOTKEY --> |keypress| POPUP[PopupWindowManager toggles window]
    POPUP --> CANVAS[CanvasTuningView renders]
    CANVAS --> BG[CanvasBackground procedural texture]
    CANVAS --> CARDS[StrokeCards with bristle edges]
    CANVAS --> METAL[CanvasMetalRenderer applies shaders]
    CANVAS --> SLIDERS[Live parameter sliders]
    SLIDERS --> |update| CONFIG[CanvasConfig JSON]
    CONFIG --> |reload| CANVAS
```

## Planned Full Pipeline (Stage 2+)

```mermaid
graph TB
    PB[NSPasteboard 250ms poll] --> CM[Clipboard Monitor]
    CM --> IE[Ingest Engine]
    IE --> SQL[(SQLite)]
    IE --> VEC[(Vector Index)]
    IE --> FS[File Store]
    SQL --> SE[Search Engine]
    VEC --> SE
    SE --> HP[History Panel UI]
    HP --> PE[Paste Engine]
    PE --> PB
```

## Hotkey → Popup Flow

1. `main.swift` — bootstraps `NSApplication` with `.accessory` policy
2. `AppDelegate` — creates `HotkeyManager` and `PopupWindowManager`
3. `HotkeyManager` — installs `CGEventTap` for Cmd+Shift+T, blocks event, fires callback
4. `PopupWindowManager` — creates/toggles a floating `NSWindow` with `CanvasTuningView`
5. Window appears centered, at `.floating` level, on all spaces
