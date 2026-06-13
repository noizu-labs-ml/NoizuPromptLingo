# Accessibility for Terminal Interfaces

Practical guide to making TUI applications usable by people with disabilities, including screen reader users, keyboard-only operators, and users with visual impairments.

---

## Screen Reader Compatibility

Terminal screen readers (brltty, speakup, fenrir, NVDA + ConPTY on Windows, VoiceOver on macOS) work by reading the terminal buffer — they do not have access to your application's internal state or widget tree. This imposes specific requirements.

### Principles for screen reader compatibility

**1. Meaningful text for every state**

Screen readers read whatever characters are in the buffer. Every interactive element must have readable text identity:

```
Bad:  [ ● ]   [ ○ ]   [ ○ ]
Good: [●] Step 1: Welcome  [ ] Step 2: Database  [ ] Step 3: Auth
```

**2. Status changes must be reflected in buffer text**

A screen reader can detect when buffer content changes. Announce status by updating visible text — not by relying on color alone:

```
Bad:  (text turns red to indicate error)
Good: ✗ Error: Connection refused (port 5432 unreachable)
```

**3. Focus indicator must be in the text, not just color**

```
Bad:  Project Alpha    ← selected, shown only by highlight color
Good: > Project Alpha  ← selected, shown by ">" prefix
```

**4. Modal context**

When a modal opens, the reader needs to know what has changed. Put the modal title at the start of the modal's text region, not the end.

```
╔════════════════════╗
║ Delete Project     ║    ← title first
║                    ║
║ Are you sure...    ║
╚════════════════════╝
```

### brltty-compatible output

brltty reads the terminal buffer in linear order (left-to-right, top-to-bottom). Multi-column layouts can confuse it. Consider providing a `--plain` or `--accessible` flag that switches to single-column layout:

```rust
if app.config.accessible_mode {
    render_linear(frame, size, app);
} else {
    render_full(frame, size, app);
}
```

### VoiceOver (macOS Terminal)

- Reads terminal buffer as plain text
- No semantic roles (no "button", "list", "heading")
- Reads line-by-line; put important info at line start
- Use text labels, not just symbols: `[x] Enabled` not just a colored dot
- Use consistent prefixes: `ERROR:`, `WARNING:`, `INFO:`
- Avoid clearing the screen unnecessarily (screen readers lose context)

### NVDA / JAWS (Windows)

- Better terminal support than VoiceOver
- Can read line-by-line through terminal buffer
- Provide `--accessible` mode: disables animation, uses ASCII borders, adds more text labels

---

## Keyboard-Only Operation

Every action reachable by mouse must be reachable by keyboard. This is non-negotiable — some users have no pointing device.

### Audit checklist

- [ ] All interactive elements are focusable via Tab/Shift-Tab
- [ ] Focused element is visually distinct (not color-only)
- [ ] All actions have keyboard shortcuts
- [ ] Keyboard shortcuts are documented (accessible via `?`)
- [ ] No action requires mouse drag or click-and-hold
- [ ] Modal dialogs trap focus (Tab cannot escape)
- [ ] Modal dialogs are dismissible via Escape
- [ ] Confirmation dialogs have a keyboard default (usually Cancel)
- [ ] No time-limited actions without keyboard extension option
- [ ] Scrollable regions respond to keyboard (↑↓, PgUp/PgDn, Home/End)

### Focus trap implementation (ratatui)

```rust
enum ModalResult { Confirmed, Cancelled }

fn handle_modal_key(key: KeyEvent) -> Option<ModalResult> {
    match key.code {
        KeyCode::Escape => Some(ModalResult::Cancelled),
        KeyCode::Enter  => Some(ModalResult::Confirmed),
        KeyCode::Tab    => {
            // Cycle within modal only — do not propagate
            None
        }
        // Swallow all other keys — prevent background interaction
        _ => None,
    }
}
```

### Tab order rules

Tab order must follow visual reading order (left-to-right, top-to-bottom). In a sidebar + main layout:

```
1. Sidebar list
2. Sidebar filters
3. Main content area
4. Footer action buttons
(wraps back to 1)
```

Never implement a tab order that jumps visually backward without a clear reason.

### Focus indicators (structure-based, not color-only)

```
Focused:    ┏━━━━━━━━━━━┓     or    ╔═══════════╗
            ┃  Content  ┃           ║  Content  ║
            ┗━━━━━━━━━━━┛           ╚═══════════╝

Unfocused:  ┌───────────┐
            │  Content  │
            └───────────┘
```

Use heavier borders, double borders, or a `>` prefix — never rely on color alone to indicate focus.

---

## High Contrast Mode

High contrast mode uses maximum contrast (black/white) to aid users with low vision.

### Detection and opt-in

```rust
fn detect_high_contrast() -> bool {
    // Explicit user opt-in is most reliable across platforms
    std::env::var("HIGH_CONTRAST").is_ok()
        || std::env::var("FORCE_HIGH_CONTRAST").is_ok()
}
```

Provide `--high-contrast` CLI flag. On Windows, you can also query the system setting.

### High contrast theme (ratatui)

```rust
impl Theme {
    pub fn high_contrast() -> Self {
        Self {
            primary:        Color::Cyan,       // 21:1 on black
            secondary:      Color::Magenta,
            success:        Color::Green,       // 15.3:1 on black
            warning:        Color::Yellow,      // 19.6:1 on black
            error:          Color::Red,
            info:           Color::White,
            text:           Color::White,       // 21:1 on black
            text_muted:     Color::White,       // no muting in high contrast
            bg:             Color::Black,
            bg_panel:       Color::Black,
            bg_selected:    Color::Blue,        // white text on blue = 8.6:1
            border:         Color::White,
            border_focused: Color::Yellow,
        }
    }
}
```

**Rules for high contrast:**
- No muted text — all text at full contrast
- No subtle borders — all borders at full contrast
- Selected item uses color-filled background, not just different text color
- Bold for emphasis instead of color

---

## NO_COLOR Compliance

When `NO_COLOR` is set (https://no-color.org/), all ANSI color codes must be suppressed. The interface must remain fully functional using structure, symbols, and emphasis only.

### Symbol substitutes for color-coded states

| State | Color (normal) | Symbol (no-color) |
|-------|--------------|------------------|
| Success | green text | `[OK]` or `✓` |
| Warning | yellow text | `[!!]` or `!` |
| Error | red text | `[ERR]` or `✗` |
| Info | blue text | `[i]` or `*` |
| Selected | highlighted bg | `>` prefix |
| Active/Live | green dot `●` | `[LIVE]` |
| Inactive | gray `○` | `[IDLE]` |
| Focused | colored border | `╔══` (double border) |
| Unfocused | muted border | `┌──` (single border) |

### Bold/dim hierarchy (no color)

```
Normal text       — body content
BOLD TEXT         — headings, labels
dim text          — metadata, timestamps (use sparingly for important info)
bold + underline  — focused element, links
reverse video     — selected item (background/foreground swap)
```

### Implementation

```rust
let use_color = std::env::var("NO_COLOR").is_err()
    && std::env::var("TERM").as_deref() != Ok("dumb");

fn styled_status(label: &str, color: Color, symbol: &str) -> Span {
    if use_color {
        Span::styled(label, Style::default().fg(color))
    } else {
        Span::raw(format!("{} {}", symbol, label))
    }
}
```

**Test no-color mode in CI:**
```bash
NO_COLOR=1 ./myapp --headless --test
```

---

## Font Size Considerations

Terminal font size is set by the user's terminal emulator, not the application. Applications cannot change font size. However, layout choices affect legibility at different sizes.

**Design for readability at default sizes (12-14px):**
- Minimum 1 cell of padding inside boxes
- Use blank lines to separate logical sections
- Avoid decorative Unicode that looks like noise at small sizes

**Characters that degrade at small sizes:**
- Braille patterns (`⣿`) — may look like noise
- Heavy box-drawing (`┫`, `╬`) — may look like blobs

**Safe for all sizes:**
- Standard box-drawing (`─`, `│`, `┌`, `└`, `├`)
- ASCII symbols (`>`, `*`, `-`, `=`)
- Common Unicode symbols (`✓`, `✗`, `●`, `○`, `▶`)

---

## Alternative Text for Visual Elements

### Progress bars

```rust
fn render_progress(value: f64, width: usize, accessible: bool) -> String {
    if accessible {
        // Text alternative: percentage + fraction
        return format!("{:.0}% ({}/{})",
            value * 100.0,
            (value * 100.0) as u32,
            100
        );
    }
    let filled = (value * width as f64) as usize;
    let empty  = width - filled;
    format!("{}{} {:.0}%", "█".repeat(filled), "░".repeat(empty), value * 100.0)
}
```

### Sparklines

```rust
fn render_sparkline_label(values: &[f64]) -> String {
    let last = values.last().copied().unwrap_or(0.0);
    let trend = match values.windows(2).last() {
        Some([a, b]) if b > a => "↑",
        Some([a, b]) if b < a => "↓",
        _                      => "→",
    };
    format!("{:.1} {}", last, trend)
}
```

### Icons and status indicators

Always pair an icon with a text label or tooltip available via `?`:

```
✓ Success     — not just ✓
✗ Failed      — not just ✗
● Live        — not just ●
⚠ Warning     — not just ⚠
```

---

## Cognitive Accessibility

**1. Confirm before irreversible actions**
Show what will be destroyed. Use typed confirmation for high-impact actions.

```
┌─────────────────────────────────────┐
│ Delete all 47 items?                │
│                                     │
│ This action cannot be undone.       │
│                                     │
│ Type "DELETE" to confirm: _______   │
│                                     │
│ [Cancel]              [Delete All]  │
└─────────────────────────────────────┘
```

**2. Provide undo**
Soft-delete patterns ("archived" before permanent removal) give users a recovery window.

**3. Consistent navigation**
`q` always quits, `Escape` always cancels. Never reassign universal keys.

**4. Explicit mode indicators**
Always show current mode in status bar: `NORMAL`, `INSERT`, `SEARCH`.

**5. Error messages that explain what to do**

```
Bad:  Error: 422 Unprocessable Entity
Good: ✗ Username already taken — choose a different username
```

**6. Loading states for all async operations**

```rust
enum LoadState { Idle, Loading, Error(String), Done }

fn render_content(state: &LoadState) -> String {
    match state {
        LoadState::Loading    => "Loading… (Ctrl+C to cancel)".into(),
        LoadState::Error(msg) => format!("✗ {}", msg),
        _                     => String::new(),
    }
}
```

---

## WCAG Principles Adapted for Terminals

WCAG 2.1 is designed for the web, but its four principles apply directly:

| Principle | TUI application |
|-----------|----------------|
| **Perceivable** | All state expressed as text or symbol, not just color. Text alternatives for sparklines, progress, icons. |
| **Operable** | Full keyboard navigation. No mouse-only actions. Focus always visible via text indicator. |
| **Understandable** | Consistent keybindings. Clear error messages. Mode indicators in status bar. Predictable Tab order. |
| **Robust** | Works with screen readers, NO_COLOR, dumb terminal, SSH. Degrades gracefully at small sizes. |

### Contrast requirements

| Level | Ratio | Applies to |
|-------|-------|-----------|
| AA Normal | 4.5:1 | Body text, labels |
| AA Large  | 3.0:1 | Headings, bold 14pt+ |
| AAA       | 7.0:1 | High-contrast mode |

### Pre-ship accessibility checklist

- [ ] All features work keyboard-only
- [ ] Focus is always visible (text indicator, not color-only)
- [ ] Tab order is logical (visual reading order)
- [ ] No keyboard traps (except modals, which are escapable)
- [ ] `NO_COLOR=1` mode is fully functional
- [ ] Color is never the sole means of conveying information
- [ ] Destructive actions require confirmation
- [ ] Error messages are clear and actionable
- [ ] `?` opens help with all keybindings
- [ ] Works at 80×24 minimum terminal size
- [ ] No blinking or flashing content
- [ ] Loading/progress states are always shown
- [ ] Mode changes are shown in status bar
