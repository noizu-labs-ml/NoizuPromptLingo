# Feature Parity: Shell vs Rust

Generated 2026-05-27 (rev 2). Covers shell-impl/ and rust/src/.

## Legend

| Symbol | Meaning |
|--------|---------|
| Y | Fully implemented |
| Y+ | Exceeds shell — Rust has features shell lacks |
| P | Partial — basic support, missing interactive or advanced features |
| N | Not implemented |
| N/A | Not applicable (handled by shell adapters co-installed with Rust binary) |

---

## Commands & Dispatch

| Feature | Shell | Rust | Notes |
|---------|:-----:|:----:|-------|
| `tabbing-on` (set title/status/color/emoji/urgency/bg) | Y | Y | |
| `tabbing-status` (update status text) | Y | Y | |
| `tabbing-info` (state dump) | Y | Y | |
| `tabbing-clear` (history/todos/recordings/all/everything) | Y | Y | |
| `tabbing-todo` (add/list/done/switch/list-pending) | Y | Y | |
| `tabbing-todo --pick` (interactive selector) | Y | N | Shell uses TTY read loop |
| `tabbing-report` (ASCII bar chart) | Y | Y | |
| `tabbing-report --mermaid` (Mermaid pie chart) | Y | Y | |
| `tabbing-history` (list/search) | Y | Y | |
| `tabbing-recordings` (list/start/stop/status/to-gif) | Y | Y | |
| `tabbing-doctor` (Ghostty/Kitty config patching) | Y | Y | |
| `tabbing-marquee` (scrolling marquee subprocess) | Y | Y | |
| `tabbing-init` (shell bootstrapper) | Y | Y | |
| `tabbing-theme` (interactive picker) | Y | **Y+** | Rust has ratatui TUI with descriptions, code preview, inline editor |
| `tabbing-theme list` | Y | Y | |
| `tabbing-theme apply <name>` | Y | Y | |
| `tabbing-theme clone <src> <dest>` | Y | Y | |
| `tabbing-theme edit <name>` (CLI) | Y | Y | Opens $EDITOR |
| `tabbing-theme delete <name>` | Y | Y | With confirmation |
| `tabbing-theme export <name>` | Y | Y | |
| `tabbing-theme save [name] [dir]` | Y | P | Picker prompts y/N; CLI stub |
| `tabbing-theme preview <name>` | Y | Y | |
| `tabbing-theme reset` | Y | Y | |
| `tabbing-claude-statusline` | Y | Y | |
| `tabbing-plan` / `task-memo` (voice-memo TUI) | Y | Y | Rust uses ratatui |
| `tabbing-style` (appearance-only command) | Y | N | Shell-only convenience wrapper |
| `tabbing-off` (full teardown) | Y | N | Handled by shell adapter function |
| `tabbing-daemon` (background dc-mode poller) | Y | N | Shell background process |
| `demo-runner` (typewriter .demo player) | Y | N | |

## Interactive Theme Picker

| Feature | Shell | Rust | Notes |
|---------|:-----:|:----:|-------|
| Alternate screen buffer | Y | Y | ratatui handles this |
| Category-grouped layout with headers | Y | **Y+** | Colored headers with icons per category |
| Theme descriptions inline | N | **Y+** | 60+ descriptions searchable |
| Theme tags (warm/cool/vibrant/muted/etc) | N | **Y+** | Used in search |
| Arrow key + vim navigation (hjkl) | Y | **Y+** | + Home/End |
| Tab/Shift-Tab category jumping | N | **Y+** | Jump between category groups |
| Live preview (apply theme on cursor move) | Y | Y | |
| `/` search/filter mode | Y | **Y+** | Searches name + description + tags + category |
| Color swatch preview (truecolor blocks) | Y | Y | 7-color inline swatch |
| Code preview (syntax-highlighted Rust snippet) | N | **Y+** | Shows theme colors on real code |
| Enter to apply + save-to-.envrc prompt | Y | Y | |
| `n` create new theme (clone + inline edit) | N | **Y+** | Modal name input → color editor |
| `e` inline color editor | N | **Y+** | 19-slot hex editor with live preview |
| `c` clone theme | Y | Y | |
| `d` delete user theme | Y | Y | |
| `s` save to .envrc | Y | Y | |
| `r` reset to defaults | Y | Y | |
| `?` help overlay | N | **Y+** | Full keybinding reference modal |
| `q`/Esc quit (restore original) | Y | Y | |
| PageUp/PageDown | Y | Y | |
| Home/End | N | **Y+** | |
| Panic handler (terminal restore) | N | **Y+** | Prevents corrupted terminal on crash |
| Tab bar (Browse/Search/Edit modes) | N | **Y+** | Visual mode indicator |
| Flash messages (timed notifications) | N | **Y+** | 4-second auto-dismiss |
| Footer key hints (contextual per mode) | N | **Y+** | Changes per view mode |
| Responsive layout (wide/narrow) | Y | Y | Descriptions hide on narrow terminals |

## tabbing-on Flags

| Flag | Shell | Rust | Notes |
|------|:-----:|:----:|-------|
| `--highlight`/`--color`/`-h`/`-COLOR` | Y | Y | |
| `--urgency`/`--pri`/`-p`/`-priN` | Y | Y | |
| `--emoji`/`-e`/`-EMOJI`/`--no-emoji` | Y | Y | |
| `--bg`/`--no-bg` | Y | Y | |
| `-m`/`--marquee`/`--no-marquee` | Y | Y | |
| `--export` (print shell exports) | Y | Y | |
| `--theme`/`--no-theme` | Y | N | Shell applies theme inline |
| `--claude` (FIFO bridge to Claude Code) | Y | N | Shell named pipe bridge |
| `--run-with` (custom consumer pipe) | Y | N | |
| `--record`/`--continue`/`--stop-recording` | Y | N | Recording flags in main cmd |
| `--terminal-info` | Y | Y | |
| `emojis`/`colors` (list) | Y | Y | |
| `-emoji:FILTER` (search) | Y | Y | |

## Libraries & Integrations

| Feature | Shell | Rust | Notes |
|---------|:-----:|:----:|-------|
| Emoji system (400+ with aliases) | Y | Y | Identical data |
| Color system (named + hex + ANSI) | Y | Y | |
| Terminal detection (10+ emulators) | Y | Y | |
| OSC escape sequences (title/bg/tab-color/badge/theme) | Y | Y | Both write to /dev/tty |
| Session persistence (.env files) | Y | Y | |
| History (YAML event log) | Y | Y | **Incompatible format** between shell & Rust |
| Todo CRUD (YAML) | Y | Y | |
| Asciinema recording lifecycle | Y | Y | |
| direnv-config (dc) integration | Y | P | Rust has save-only via dc SDK |
| Toggl Track API integration | Y | N | |
| Claude Code FIFO bridge | Y | N | |
| `--run-with` custom pipe | Y | N | |
| User theme file loading (.theme) | Y | Y | |
| Precmd hook / prompt integration | Y | N/A | Shell adapter, co-installed |
| Direnv helper (use_tabbing) | Y | N/A | Shell script, co-installed |

## Summary

**Rust now exceeds shell** on the theme picker experience with 15+ Rust-only features. Key Rust advantages:

- Theme descriptions and tag-based search
- Inline color editor (19-slot hex editor with live preview)
- Syntax-highlighted code preview showing theme colors on real Rust code
- Create-new-theme workflow (name → clone base → edit colors)
- Help overlay, contextual footer, flash messages, panic handler
- Category jumping via Tab/Shift-Tab

**Remaining shell-only gaps:**

1. **`--claude` bridge / `--run-with`** — FIFO pipe IPC for Claude Code integration
2. **`--theme`/`--no-theme` flags** on `tabbing-on` and `tabbing-status`
3. **`--record` flags** on `tabbing-on` (convenience wrappers)
4. **`tabbing-todo --pick`** interactive selector
5. **Toggl Track integration** — full API client
6. **`tabbing-daemon`** — background dc-mode poller
7. **`demo-runner`** — typewriter .demo file player
8. **YAML history format** — shell and Rust use incompatible formats
