# Pane Architecture

## Pane Types

All panes implement the `Pane` trait (defined in `zellij-server/src/panes/mod.rs`).

### TerminalPane (`terminal_pane.rs` — 1342 lines)

Connects to a PTY process. Contains a `Grid` character buffer that stores terminal output with scrollback. The VT parser (via the `vte` crate) interprets escape sequences from the PTY stream and updates the grid.

Key fields:
- `grid: Grid` — character buffer
- `pid: u32` — PTY process ID
- `current_cursor_position: Position` — cursor row/col
- `client_id: Option<ClientId>` — owning client

### PluginPane (`plugin_pane.rs` — 976 lines)

Displays output from a WASM plugin. The plugin's `render()` function produces a string of styled text that the pane converts into its character buffer. Plugin panes have no PTY — they communicate through the plugin event system.

## Grid (`grid.rs` — 5025 lines)

The core terminal emulation buffer:

```rust
struct Grid {
    lines: VecDeque<Line>,      // Each Line is Vec<TerminalCharacter>
    viewport_bottom: usize,     // Scrollback offset
    cursor: Position,           // Current cursor (row, col)
}

struct TerminalCharacter {
    character: char,            // The displayed glyph
    styles: CharacterStyles,    // ANSI styling (fg/bg color, bold, italic, etc.)
}
```

Supports scrollback history, line wrapping, alternate screen buffer, and Sixel image protocol.

## Layout Modes

### Tiled Panes (`panes/tiled_panes/`)

Uses the Cassowary constraint solver for automatic pane sizing. Panes fill the available space according to split directions (horizontal/vertical) and size constraints. Layout definitions come from KDL files.

### Floating Panes (`panes/floating_panes/`)

Absolute-positioned panes that overlay the tiled layout. Support z-ordering, drag-to-move, and resize handles.

## Tab Container

Each `Tab` (`zellij-server/src/tab/mod.rs`) holds:
- `tiled_panes: TiledPanes` — constraint-based layout
- `floating_panes: FloatingPanes` — overlay stack
- `pane_ids: PaneIdsAndNames` — registry mapping IDs to names
- `layout: TiledPaneLayout` — current KDL layout definition

Tabs support swap layouts (`swap_layouts.rs`) for transitioning between different pane arrangements without destroying panes.

## Supporting Modules

| Module | Purpose |
|--------|---------|
| `hyperlink_tracker.rs` | URL detection and OSC 8 hyperlink protocol |
| `search.rs` | Text search within pane scrollback |
| `sixel.rs` | Sixel image protocol rendering |
| `terminal_character.rs` | Character styling and ANSI attribute mapping |
