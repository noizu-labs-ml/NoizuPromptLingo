# Cross-Platform Terminal Compatibility

Reference for building TUI applications that work reliably across terminal emulators, multiplexers, SSH sessions, and operating systems.

---

## Terminal Emulator Compatibility Matrix

| Feature | iTerm2 | Alacritty | kitty | Windows Terminal | macOS Terminal.app | xterm |
|---------|--------|-----------|-------|-----------------|-------------------|-------|
| Truecolor | yes | yes | yes | yes | yes (v3.4+) | no |
| 256 color | yes | yes | yes | yes | yes | yes |
| Unicode (BMP) | yes | yes | yes | yes | yes | yes |
| Unicode (SMP emoji) | yes | yes | yes | yes | partial | no |
| Wide chars (CJK) | yes | yes | yes | yes | yes | partial |
| Mouse (all buttons) | yes | yes | yes | yes | yes | partial |
| Hyperlinks (OSC 8) | yes | no | yes | yes | no | no |
| Images (protocol) | iTerm2 | no | kitty | sixel | no | sixel |
| Ligatures | yes | no | yes | yes | no | no |
| Undercurl | yes | yes | yes | no | no | no |
| Bracketed paste | yes | yes | yes | yes | yes | yes |

**Safe baseline:** Truecolor + unicode BMP + mouse + bracketed paste covers ~95% of modern users.

---

## Terminal Emulator Notes

### iTerm2 (macOS)
- Sets `TERM_PROGRAM=iTerm.app` and `COLORTERM=truecolor`
- Supports iTerm2 inline image protocol (proprietary)
- Reports terminal size changes via `SIGWINCH`
- `ITERM_SESSION_ID` is set in iTerm2 sessions

### Alacritty
- Sets `TERM=alacritty` (some versions) or `TERM=xterm-256color`
- No image protocol support — do not attempt to render images
- GPU-accelerated; renders fast — avoid excessive redraws as they are noticeable

### kitty
- Sets `TERM=xterm-kitty` and `COLORTERM=truecolor`
- Supports kitty graphics protocol (pixel images)
- Supports `TERM_PROGRAM=kitty`
- Detect with: `os.environ.get('TERM') == 'xterm-kitty'`

### Windows Terminal
- Sets `WT_SESSION` environment variable — reliable detection
- ConPTY handles VT sequences; most ANSI/VT100 works
- `TERM=xterm-256color` is typical
- Truecolor works; `COLORTERM=truecolor` may not be set — check `WT_SESSION` instead

### macOS Terminal.app
- Sets `TERM_PROGRAM=Apple_Terminal`
- Truecolor support added in macOS Catalina; check version or use `COLORTERM`
- Does not support OSC 8 hyperlinks
- Report encoding: UTF-8, but emoji width calculation can be unreliable

---

## Multiplexer Considerations

### tmux

tmux intercepts terminal sequences and re-emits them to the outer terminal. This creates a layered environment.

**TERM in tmux:** tmux sets `$TERM` to `screen` or `screen-256color` inside the session, losing outer terminal capabilities.

**Enable truecolor passthrough in `~/.tmux.conf`:**
```
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",xterm-256color:Tc"
set -ga terminal-overrides ",alacritty:Tc"
```

**Detection inside tmux:**
```bash
if [ -n "$TMUX" ]; then
    # Running inside tmux
    # Use tmux display-message to query outer terminal
    OUTER_TERM=$(tmux display-message -p '#{client_termname}')
fi
```

**Mouse in tmux:** Enable with `set -g mouse on`. Your app still receives mouse events, but coordinates are relative to the pane, not the window.

### GNU Screen

Legacy. Assumes 8-color by default. Enable 256 colors with `term xterm-256color` in `.screenrc`. Truecolor is not reliably supported. Test if screen is detected and degrade to 256.

```bash
if [ -n "$STY" ]; then
    # Running inside GNU screen
    echo "screen detected"
fi
```

---

## SSH Considerations

Over SSH, the remote shell inherits `$TERM` from the client via the SSH protocol — but only if `SendEnv LANG LC_*` or `SendEnv TERM` is configured (it often is).

**Common issues:**
1. `$COLORTERM` is not forwarded by default — truecolor detection may fail
2. `$TERM` may be `xterm-256color` even if client terminal supports truecolor
3. Large paste buffers may arrive as many small reads — handle bracketed paste

**Forwarding COLORTERM over SSH (server side, `/etc/ssh/sshd_config`):**
```
AcceptEnv LANG LC_* COLORTERM TERM_PROGRAM
```

**Client side (`~/.ssh/config`):**
```
Host *
    SendEnv LANG LC_* COLORTERM TERM_PROGRAM
```

**Fallback heuristic for SSH:**
```rust
fn ssh_color_support() -> ColorSupport {
    // SSH_CONNECTION or SSH_CLIENT indicates SSH session
    if std::env::var("SSH_CONNECTION").is_ok() {
        // Conservative: assume 256 unless COLORTERM explicitly set
        match std::env::var("COLORTERM").as_deref() {
            Ok("truecolor") | Ok("24bit") => ColorSupport::Truecolor,
            _ => ColorSupport::Colors256,
        }
    } else {
        detect_color_support()
    }
}
```

---

## Unicode Support and Width Calculation

Terminal character width is determined by Unicode East Asian Width (UAX #11). Most rendering issues come from incorrect width assumptions.

| Category | Width | Examples |
|----------|-------|---------|
| ASCII | 1 | A-Z, 0-9, punctuation |
| Latin Extended | 1 | é, ü, ñ |
| CJK Unified | 2 | 中, 日, 한 |
| Emoji (basic) | 2 | ✨, 🚀 |
| Combining marks | 0 | accent combiners |
| Box drawing | 1 | ─, │, ┼ |
| Braille | 1 | ⣿ |

**Rust: `unicode-width` crate**
```rust
use unicode_width::UnicodeWidthStr;

fn truncate_to_width(s: &str, max_width: usize) -> &str {
    let mut width = 0;
    for (i, c) in s.char_indices() {
        let char_width = unicode_width::UnicodeWidthChar::width(c).unwrap_or(0);
        if width + char_width > max_width {
            return &s[..i];
        }
        width += char_width;
    }
    s
}
```

**Go: `go-runewidth`**
```go
import "github.com/mattn/go-runewidth"

func truncate(s string, max int) string {
    return runewidth.Truncate(s, max, "…")
}

func padRight(s string, width int) string {
    return runewidth.FillRight(s, width)
}
```

**Emoji ZWJ sequences and variation selectors:** These are multi-codepoint sequences that render as single glyphs. Safe approach: treat any emoji cluster as width 2. Use `unicode_segmentation` crate (Rust) or `golang.org/x/text/unicode/norm` (Go) to iterate grapheme clusters, not runes.

---

## Windows-Specific: ConPTY

Windows Terminal uses ConPTY (Console Pseudoterminal) to translate between Win32 Console API and VT sequences. As of Windows 10 1809+, most VT100/ANSI sequences work.

**Detection:**
```rust
#[cfg(windows)]
fn is_windows_terminal() -> bool {
    std::env::var("WT_SESSION").is_ok()
}

#[cfg(windows)]
fn enable_ansi_windows() {
    use windows::Win32::System::Console::{
        GetStdHandle, SetConsoleMode,
        ENABLE_VIRTUAL_TERMINAL_PROCESSING, STD_OUTPUT_HANDLE,
    };
    unsafe {
        let handle = GetStdHandle(STD_OUTPUT_HANDLE).unwrap();
        let mut mode = Default::default();
        windows::Win32::System::Console::GetConsoleMode(handle, &mut mode).unwrap();
        SetConsoleMode(handle, mode | ENABLE_VIRTUAL_TERMINAL_PROCESSING).unwrap();
    }
}
```

**crossterm** (Rust) handles this automatically — prefer it over raw Windows API calls.

**Known Windows limitations:**
- `SIGWINCH` does not exist on Windows; use crossterm's `Event::Resize` instead
- Some older ConPTY versions have issues with alternate screen buffer
- Line endings: prefer LF-only in terminal output even on Windows

---

## TERM / COLORTERM Environment Variable Quick Reference

| Variable | Value | Meaning |
|----------|-------|---------|
| `TERM` | `dumb` | No color, no cursor movement |
| `TERM` | `xterm` | Basic ANSI 16 colors |
| `TERM` | `xterm-256color` | 256 colors |
| `TERM` | `xterm-kitty` | Kitty terminal, truecolor |
| `TERM` | `alacritty` | Alacritty, truecolor |
| `TERM` | `screen` | GNU Screen, 8 colors |
| `TERM` | `screen-256color` | GNU Screen, 256 colors |
| `COLORTERM` | `truecolor` | 24-bit color supported |
| `COLORTERM` | `24bit` | 24-bit color (alternative) |
| `TERM_PROGRAM` | `iTerm.app` | iTerm2 |
| `TERM_PROGRAM` | `Apple_Terminal` | macOS Terminal.app |
| `TERM_PROGRAM` | `kitty` | kitty terminal |
| `WT_SESSION` | (any UUID) | Windows Terminal |
| `NO_COLOR` | (any value) | Suppress all color output |
| `TMUX` | (any value) | Inside tmux session |
| `STY` | (any value) | Inside GNU screen |
| `SSH_CONNECTION` | (any value) | SSH session |

---

## Minimum Terminal Size Handling

Always handle terminals smaller than expected. Define a minimum and show a resize prompt:

```rust
const MIN_WIDTH: u16 = 60;
const MIN_HEIGHT: u16 = 10;

fn render(frame: &mut Frame, size: Rect, app: &App) {
    if size.width < MIN_WIDTH || size.height < MIN_HEIGHT {
        let msg = format!(
            "Terminal too small: {}x{}\nMinimum: {}x{}",
            size.width, size.height, MIN_WIDTH, MIN_HEIGHT
        );
        let paragraph = Paragraph::new(msg)
            .alignment(Alignment::Center)
            .style(Style::default().fg(Color::Yellow));
        frame.render_widget(paragraph, size);
        return;
    }
    app.render(frame, size);
}
```

**Resize event handling (ratatui):**
```rust
match event::read()? {
    Event::Resize(width, height) => {
        // ratatui handles terminal resize automatically on next draw
        // but you may need to reflow layout
        app.on_resize(width, height);
    }
    _ => {}
}
```

**Graceful layout degradation thresholds:**

| Width | Behavior |
|-------|---------|
| < 40  | Single column, no sidebar |
| 40-59 | Compact mode: hide decorative borders, abbreviate labels |
| 60-79 | Standard mode: most features |
| 80+   | Full mode: all features |
| 120+  | Wide mode: show additional columns/panels |
