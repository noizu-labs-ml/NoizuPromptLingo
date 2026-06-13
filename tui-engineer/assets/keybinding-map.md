# TUI Keybinding Map

## Universal Keys (Do Not Override)

| Key | Action | Notes |
|-----|--------|-------|
| `Ctrl+C` | Force quit | Always exits, no confirmation |
| `q` | Quit | May show confirmation if unsaved state |
| `?` | Help overlay | Show all available keybindings |

## Navigation

| Key | Action | Context |
|-----|--------|---------|
| `↑` / `↓` | Move up/down | Lists, tables, menus |
| `←` / `→` | Move left/right | Tabs, horizontal nav, text |
| `k` / `j` | Move up/down (vim) | Opt-in, never sole navigation |
| `h` / `l` | Move left/right (vim) | Opt-in, never sole navigation |
| `Tab` | Next focus area | Cycle between panes/widgets |
| `Shift+Tab` | Previous focus area | Reverse cycle (may not work in all terminals) |
| `g` `g` | Jump to top | Vim-style, lists/tables |
| `G` | Jump to bottom | Vim-style, lists/tables |
| `Page Up` | Page up | Long lists, viewports |
| `Page Down` | Page down | Long lists, viewports |
| `Home` | Jump to first item | Lists, text |
| `End` | Jump to last item | Lists, text |

## Actions

| Key | Action | Context |
|-----|--------|---------|
| `Enter` | Confirm / select | Focused item |
| `Space` | Toggle / check | Checkboxes, multi-select |
| `Esc` | Cancel / back | Modals, submenus, search |
| `Backspace` | Delete character | Text inputs |
| `Delete` | Delete forward | Text inputs |

## Search & Filter

| Key | Action | Context |
|-----|--------|---------|
| `/` | Start search/filter | Lists, tables |
| `Ctrl+F` | Find (alternative) | When `/` conflicts |
| `n` | Next match | After search |
| `N` | Previous match | After search |
| `Esc` | Clear search | During search |

## Application-Specific

| Key | Action | Context |
|-----|--------|---------|
| | | |
| | | |
| | | |
| | | |
| | | |

## Modifier Key Conventions

| Modifier | Convention | Example |
|----------|-----------|---------|
| None | Navigation and selection | `j`, `k`, `Enter` |
| `Shift` | Reverse/extend | `Shift+Tab` = prev focus |
| `Ctrl` | System/global actions | `Ctrl+C` = quit, `Ctrl+S` = save |
| `Alt/Meta` | Application-specific | Less portable, avoid if possible |

## Conflict Checklist

- [ ] No two actions share the same key in the same context
- [ ] Universal keys (`Ctrl+C`, `q`, `?`) are not overridden
- [ ] Arrow keys always work for navigation (vim keys are supplemental)
- [ ] `Esc` never quits — it cancels/goes back
- [ ] Single-letter keys don't conflict with text input modes
- [ ] `Tab` cycles focus, not confused with `\t` in text inputs
- [ ] Terminal multiplexer prefixes (`Ctrl+B` for tmux, `Ctrl+A` for screen) are avoided
