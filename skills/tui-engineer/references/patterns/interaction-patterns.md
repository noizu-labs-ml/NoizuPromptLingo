# TUI Interaction Patterns

Design reference for keyboard navigation, focus management, and user interaction in terminal interfaces.

---

## Navigation Models

### Vim-style Navigation

Best for power users, text-heavy interfaces, and tools with a developer audience.

| Key | Action |
|-----|--------|
| `h` / `j` / `k` / `l` | left / down / up / right |
| `gg` / `G` | first item / last item |
| `Ctrl+d` / `Ctrl+u` | half-page down / up |
| `Ctrl+f` / `Ctrl+b` | full-page down / up |
| `/` | enter search mode |
| `n` / `N` | next / previous match |
| `q` | quit / close |
| `i` / `a` | enter insert/edit mode |
| `Esc` | return to normal mode |

**When to use:** Log viewers, file browsers, text editors, any app where users spend time navigating large datasets.

### Arrow Key Navigation

Best for general audiences, wizard flows, and form-heavy interfaces.

| Key | Action |
|-----|--------|
| `↑` / `↓` | move selection up / down |
| `←` / `→` | move between panes or within fields |
| `Page Up` / `Page Down` | scroll by page |
| `Home` / `End` | first / last item |
| `Enter` | confirm / activate |
| `Escape` | cancel / back |
| `Tab` / `Shift+Tab` | next / previous focusable element |

**When to use:** Setup wizards, forms, menu-driven apps, anything targeting non-developer users.

### Tab Navigation

Supplement to both models. Tab cycles through focusable regions; within a region, arrow keys navigate items.

```
Focus order: Header tabs → Sidebar → Main content → Footer actions
Within sidebar: ↑↓ move items
Within main: ↑↓ or hjkl move items
Escape: return focus to previous region
```

---

## Focus Management

### Focus Ring Rules

1. **Always visible** — focused element must have a clear visual indicator (highlight, border, cursor)
2. **Single focus** — only one element holds focus at a time
3. **Predictable order** — Tab follows visual reading order (top-left to bottom-right)
4. **Trap modals** — focus must not escape a modal dialog while it is open
5. **Restore on close** — closing a modal restores focus to the element that opened it

### Ratatui focus pattern (Rust)

```rust
#[derive(Clone, Copy, PartialEq)]
enum FocusedPane {
    Sidebar,
    Main,
    Footer,
}

struct App {
    focused: FocusedPane,
}

impl App {
    fn handle_tab(&mut self) {
        self.focused = match self.focused {
            FocusedPane::Sidebar => FocusedPane::Main,
            FocusedPane::Main   => FocusedPane::Footer,
            FocusedPane::Footer => FocusedPane::Sidebar,
        };
    }

    fn render_sidebar(&self, frame: &mut Frame, area: Rect) {
        let border_style = if self.focused == FocusedPane::Sidebar {
            Style::default().fg(Color::Yellow)
        } else {
            Style::default().fg(Color::DarkGray)
        };
        let block = Block::default().borders(Borders::ALL).border_style(border_style);
        frame.render_widget(block, area);
    }
}
```

### Bubbletea focus pattern (Go)

```go
type model struct {
    focusIndex int
    inputs     []textinput.Model
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.KeyMsg:
        switch msg.String() {
        case "tab", "shift+tab":
            if msg.String() == "tab" {
                m.focusIndex = (m.focusIndex + 1) % len(m.inputs)
            } else {
                m.focusIndex = (m.focusIndex - 1 + len(m.inputs)) % len(m.inputs)
            }
            for i := range m.inputs {
                if i == m.focusIndex {
                    m.inputs[i].Focus()
                } else {
                    m.inputs[i].Blur()
                }
            }
        }
    }
    return m, nil
}
```

---

## Keyboard Shortcut Conventions

### Universal conventions (do not override)

| Key | Convention |
|-----|-----------|
| `Ctrl+C` | Quit / interrupt (SIGINT) |
| `Ctrl+Z` | Suspend (SIGTSTP) |
| `Escape` | Cancel / back / dismiss |
| `Enter` | Confirm / activate |
| `Tab` | Next focusable |
| `Shift+Tab` | Previous focusable |
| `?` | Show help |
| `q` | Quit (vim convention; do not use in text input contexts) |

### Layer your shortcuts

```
Global:  q/Ctrl+C (quit), ? (help), : (command palette)
App:     Tab (switch pane), / (search), r (refresh)
Context: specific to active widget (list, form, editor)
```

### Conflict avoidance

- In text input mode, single-key shortcuts are consumed by the input — disable them
- Distinguish "normal mode" vs "insert mode" explicitly in status bar
- Prefer `Ctrl+` prefixes for destructive actions (`Ctrl+D` delete, never plain `d` outside vim-mode)

---

## Mouse Support as Progressive Enhancement

Mouse support should never be required — keyboard must be fully functional first.

```rust
// Ratatui: opt-in mouse capture
terminal.enable_raw_mode()?;
execute!(stdout, EnableMouseCapture)?;

// Handle events
match event::read()? {
    Event::Mouse(MouseEvent { kind: MouseEventKind::Down(MouseButton::Left), column, row, .. }) => {
        // Map pixel position to widget, then delegate to keyboard handler
        if let Some(widget) = self.hit_test(column, row) {
            self.focus(widget);
        }
    }
    Event::Mouse(MouseEvent { kind: MouseEventKind::ScrollDown, .. }) => {
        self.scroll_down(3);
    }
    _ => {}
}
```

**Guidelines:**
- Click to focus (same as Tab navigation result)
- Scroll wheel maps to ↑↓ navigation
- Right-click is optional; if used, show a context menu
- Drag is optional; never required for core workflows
- Always show keyboard alternative in status bar even when mouse is used

---

## Confirmation Patterns

### Destructive action tiers

| Risk level | Pattern | Example |
|-----------|---------|---------|
| Low | Undo available | Archive item |
| Medium | `y/N` prompt in status bar | Delete file |
| High | Modal with typed confirmation | Delete project with data |
| Critical | Multi-step: modal + type name + wait | Drop production database |

### Status bar confirmation (inline)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Delete "report.csv"? [y/N]: _                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

Timeout after 5s with no input defaults to `N`. Show countdown: `[y/N] (4s)`.

### Typed confirmation (modal)

Only for irreversible, high-impact actions. The typed string must match exactly — case-sensitive.

---

## Search and Filter Patterns

### Incremental search (fuzzy)

```
/ opens search mode
Typing filters list in real time
Enter confirms selection
Escape cancels, restores original list
n/N (or Ctrl+N/P) cycles through matches
```

```rust
fn filter_items<'a>(items: &'a [Item], query: &str) -> Vec<&'a Item> {
    if query.is_empty() {
        return items.iter().collect();
    }
    let query_lower = query.to_lowercase();
    items.iter()
        .filter(|item| item.name.to_lowercase().contains(&query_lower))
        .collect()
}
```

### Filter bar (persistent)

Show active filters in status bar or a dedicated filter row. Always show item count after filtering:

```
[x] Active  [ ] Archived  [x] Mine  │  Search: api  │  Showing 3 of 47 items
```

Clear all filters with `Ctrl+F` or `Esc` from the filter bar.

---

## Help Overlay Design

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Keyboard Shortcuts                                              [?] to close │
├─────────────────────────────────┬────────────────────────────────────────────┤
│  Navigation                     │  Actions                                   │
│  ─────────────────────────────  │  ────────────────────────────────────────  │
│  j / ↓      Move down           │  Enter      Open / activate               │
│  k / ↑      Move up             │  d          Delete selected                │
│  Tab        Next pane           │  e          Edit selected                  │
│  Shift+Tab  Previous pane       │  n          New item                       │
│  /          Search              │  r          Refresh                        │
│  Esc        Cancel / back       │  Ctrl+Z     Undo last action               │
│                                 │                                            │
│  Global                         │  View                                      │
│  ─────────────────────────────  │  ────────────────────────────────────────  │
│  q / Ctrl+C  Quit               │  1-4        Switch tab                     │
│  ?           This help          │  [          Toggle sidebar                 │
│  :           Command palette     │  f          Toggle fullscreen              │
└─────────────────────────────────┴────────────────────────────────────────────┘
```

**Guidelines:**
- `?` always opens help; `Escape` or `?` again closes it
- Group by context (navigation, actions, global, view)
- Show only relevant shortcuts — filter by current mode
- Keep it one screen; scroll if needed, but prefer two columns

---

## Status Bar Conventions

The status bar is the app's ambient information layer. Left-to-right priority:

```
[Mode/State] [Entity info] [Counts/stats] ─── [Help hints] [Connection/sync]
```

Example layout:
```
NORMAL │ projects/alpha │ 3 of 47 items │ ────── │ ↑↓:nav Enter:open /:search │ ● Live
```

**Rules:**
- Leftmost: current mode (NORMAL, INSERT, VISUAL, SEARCH, FILTER)
- Center: contextual info (current file, selected item, progress)
- Rightmost: global state (connected/disconnected, sync status, clock)
- Hint bar: show 3-5 most relevant shortcuts for current context; update on focus change
- Never scroll or animate the status bar — it must be stable reference
