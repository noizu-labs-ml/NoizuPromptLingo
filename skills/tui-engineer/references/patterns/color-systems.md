# Color Systems for Terminal UIs

Design reference for terminal color capabilities, semantic mapping, accessibility, and palette recipes.

---

## Three-Tier Color System

### Tier 1: 8/16 ANSI Colors

The baseline. Supported by every terminal including ancient ones, SSH sessions, and CI runners.

| Code | Name | Typical rendering |
|------|------|-------------------|
| 0 | Black | Dark background color |
| 1 | Red | Error, danger |
| 2 | Green | Success, ok |
| 3 | Yellow | Warning, caution |
| 4 | Blue | Info, links |
| 5 | Magenta | Special, highlight |
| 6 | Cyan | Secondary info |
| 7 | White | Default text |
| 8-15 | Bright variants | +Bold intensity |

**Caveat:** These 16 colors are remapped by the user's terminal theme. A "green" in your code may be lime or olive depending on the user's colorscheme. Design for meaning, not specific hue.

### Tier 2: 256 Colors

Supported by xterm-256color and virtually all modern terminals. Adds 216 color cube (6×6×6) and 24 grayscale steps.

```
Indices 0–15:   System colors (same as ANSI, theme-dependent)
Indices 16–231: 6×6×6 color cube
Indices 232–255: Grayscale ramp (dark to light, excludes true black/white)
```

Useful grayscale indices for subtle UI chrome:
```
232  233  234  235  236  237  238  239  240  241  242  243
█    █    █    █    █    █    █    █    █    █    █    █
very dark                              mid              light
```

### Tier 3: Truecolor (16M colors)

Full 24-bit RGB. Required for gradients, brand colors, and pixel-accurate design.

```
ESC[38;2;R;G;Bm   foreground
ESC[48;2;R;G;Bm   background
```

---

## Terminal Color Capability Detection

### Shell detection snippet

```bash
detect_color_support() {
    # Respect explicit NO_COLOR
    if [ -n "$NO_COLOR" ]; then
        echo "none"
        return
    fi

    # Check COLORTERM for truecolor
    if [ "$COLORTERM" = "truecolor" ] || [ "$COLORTERM" = "24bit" ]; then
        echo "truecolor"
        return
    fi

    # Check TERM for 256 color
    case "$TERM" in
        *-256color|*-256|xterm-kitty|alacritty)
            echo "256"
            return
            ;;
    esac

    # Check terminfo
    if command -v tput >/dev/null 2>&1; then
        colors=$(tput colors 2>/dev/null)
        if [ "${colors:-0}" -ge 256 ]; then
            echo "256"
            return
        fi
    fi

    echo "ansi"
}
```

### Rust detection (ratatui)

```rust
use std::env;

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum ColorSupport {
    None,
    Ansi,
    Colors256,
    Truecolor,
}

pub fn detect_color_support() -> ColorSupport {
    // NO_COLOR wins unconditionally
    if env::var("NO_COLOR").is_ok() {
        return ColorSupport::None;
    }

    // COLORTERM signals truecolor
    match env::var("COLORTERM").as_deref() {
        Ok("truecolor") | Ok("24bit") => return ColorSupport::Truecolor,
        _ => {}
    }

    // TERM-based detection
    let term = env::var("TERM").unwrap_or_default();
    if term.contains("256color") || term == "xterm-kitty" || term == "alacritty" {
        return ColorSupport::Colors256;
    }

    // Fallback to basic ANSI
    if term.starts_with("xterm") || term.starts_with("vt") || term == "screen" {
        return ColorSupport::Ansi;
    }

    ColorSupport::None
}
```

### Go detection (bubbletea / lipgloss)

```go
import "github.com/muesli/termenv"

func detectColorProfile() termenv.Profile {
    return termenv.ColorProfile()
    // Returns: termenv.TrueColor, termenv.ANSI256, termenv.ANSI, termenv.Ascii
}
```

`termenv.ColorProfile()` handles `NO_COLOR`, `COLORTERM`, `TERM`, and CI detection automatically.

---

## Semantic Color Mapping

Map meaning to colors, then resolve to capabilities. Never hardcode RGB in business logic.

```rust
pub struct Theme {
    pub primary:     Color,
    pub secondary:   Color,
    pub success:     Color,
    pub warning:     Color,
    pub error:       Color,
    pub info:        Color,
    pub text:        Color,
    pub text_muted:  Color,
    pub bg:          Color,
    pub bg_panel:    Color,
    pub bg_selected: Color,
    pub border:      Color,
    pub border_focused: Color,
}

impl Theme {
    pub fn truecolor_dark() -> Self {
        Self {
            primary:        Color::Rgb(99, 179, 237),   // blue-300
            secondary:      Color::Rgb(154, 117, 204),  // purple-400
            success:        Color::Rgb(72, 199, 142),   // green-400
            warning:        Color::Rgb(246, 173, 85),   // orange-300
            error:          Color::Rgb(245, 101, 101),  // red-400
            info:           Color::Rgb(99, 179, 237),   // blue-300
            text:           Color::Rgb(237, 242, 247),  // gray-100
            text_muted:     Color::Rgb(113, 128, 150),  // gray-500
            bg:             Color::Rgb(23, 25, 35),     // near-black
            bg_panel:       Color::Rgb(36, 41, 56),     // dark navy
            bg_selected:    Color::Rgb(49, 58, 82),     // blue-gray
            border:         Color::Rgb(74, 85, 104),    // gray-600
            border_focused: Color::Rgb(99, 179, 237),   // blue-300
        }
    }

    pub fn ansi_dark() -> Self {
        Self {
            primary:        Color::Cyan,
            secondary:      Color::Magenta,
            success:        Color::Green,
            warning:        Color::Yellow,
            error:          Color::Red,
            info:           Color::Cyan,
            text:           Color::White,
            text_muted:     Color::DarkGray,
            bg:             Color::Black,
            bg_panel:       Color::Black,
            bg_selected:    Color::DarkGray,
            border:         Color::DarkGray,
            border_focused: Color::Cyan,
        }
    }
}
```

---

## NO_COLOR Compliance

The [NO_COLOR standard](https://no-color.org/) specifies: when `NO_COLOR` is set in the environment (any value, including empty string), all color output must be suppressed.

```rust
pub fn should_use_color() -> bool {
    // NO_COLOR: presence of variable, not its value
    if std::env::var_os("NO_COLOR").is_some() {
        return false;
    }
    // Also check TERM=dumb
    if std::env::var("TERM").as_deref() == Ok("dumb") {
        return false;
    }
    // Non-TTY (piped output)
    if !atty::is(atty::Stream::Stdout) {
        return false;
    }
    true
}
```

When colors are disabled, rely on:
- Bold/dim for emphasis hierarchy
- Underline for links and focus
- Symbols and prefixes (`✓`, `✗`, `!`, `>`) for status
- Indentation and spacing for structure

---

## Light vs Dark Theme Considerations

Most terminals default to dark backgrounds, but light themes are common in IDEs and on macOS Terminal.

```rust
pub fn detect_background() -> Background {
    // COLORFGBG="foreground;background" — set by some terminals
    if let Ok(val) = env::var("COLORFGBG") {
        let parts: Vec<&str> = val.split(';').collect();
        if let Some(bg) = parts.last() {
            if let Ok(n) = bg.parse::<u8>() {
                // Values 0-6 are dark, 7-15 are light (rough heuristic)
                return if n < 8 { Background::Dark } else { Background::Light };
            }
        }
    }
    Background::Dark  // Safe default assumption
}
```

**Light theme adjustments:**
- Darken borders (light gray → medium gray)
- Use dark text on light backgrounds (swap text/bg)
- Reduce contrast of muted elements (they appear harsher on light)
- Test that `warning: Yellow` is readable (often is not on white)

---

## Palette Recipes

### Dark terminal (default)

```
Background:    #171923  (near-black blue)
Panel:         #242938  (dark navy)
Selected:      #313A52  (selection highlight)
Border:        #4A5568  (gray-600)
Text:          #EDF2F7  (gray-100)
Muted:         #718096  (gray-500)
Primary:       #63B3ED  (blue-300)
Success:       #48C78E  (green-400)
Warning:       #F6AD55  (orange-300)
Error:         #F56565  (red-400)
```

### Light terminal

```
Background:    #F7FAFC  (gray-50)
Panel:         #FFFFFF  (white)
Selected:      #BEE3F8  (blue-100)
Border:        #CBD5E0  (gray-300)
Text:          #1A202C  (gray-900)
Muted:         #718096  (gray-500)
Primary:       #3182CE  (blue-600)
Success:       #38A169  (green-600)
Warning:       #D69E2E  (yellow-600)
Error:         #E53E3E  (red-600)
```

### High contrast (accessibility)

```
Background:    #000000
Text:          #FFFFFF
Primary:       #00FFFF  (cyan — 21:1 contrast)
Success:       #00FF00  (green — 15.3:1)
Warning:       #FFFF00  (yellow — 19.6:1)
Error:         #FF6666  (bright red — 5.7:1)
Border:        #FFFFFF
Selected:      #0000AA  (bright blue bg)
```

---

## Color Contrast for Accessibility

WCAG 2.1 contrast ratios for terminal text:

| Level | Ratio | Use case |
|-------|-------|---------|
| AA Normal | 4.5:1 | Body text, labels |
| AA Large  | 3.0:1 | Headings (18pt+ or 14pt bold) |
| AAA Normal | 7.0:1 | High-contrast mode |

Terminal text is typically 12-16px, so AA Normal (4.5:1) applies to everything.

**Common failures:**
- Yellow text on white: ~1.07:1 (fails everything)
- Dark gray on black: ~1.9:1 (fails)
- Blue links on dark blue: ~1.5:1 (fails)

Tools: use `wcag-contrast` npm package, or Python `coloraide` library to validate in CI.

```python
from coloraide import Color
def contrast_ratio(fg_hex, bg_hex):
    fg = Color(fg_hex).convert("srgb")
    bg = Color(bg_hex).convert("srgb")
    return fg.contrast(bg)

assert contrast_ratio("#63B3ED", "#171923") >= 4.5  # blue on dark bg
```

---

## TERM Capability Detection Quick Reference

| `$TERM` value | Color support | Notes |
|---------------|--------------|-------|
| `dumb` | None | No color, no cursor movement |
| `vt100`, `vt220` | None | Legacy hardware terminals |
| `ansi` | ANSI 16 | Basic |
| `xterm` | ANSI 16 | Technically 16, often more |
| `xterm-256color` | 256 | Standard modern |
| `xterm-kitty` | Truecolor | Kitty terminal |
| `alacritty` | Truecolor | Alacritty terminal |
| `screen`, `tmux` | 256 or less | Depends on outer TERM |
| `screen-256color` | 256 | tmux/screen explicit |

**tmux note:** tmux intercepts `$TERM` and sets it to `screen` or `screen-256color`. To pass truecolor through, set in `~/.tmux.conf`:
```
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",xterm-256color:Tc"
```
