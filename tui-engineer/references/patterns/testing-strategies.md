# TUI Testing Strategies

Practical guide to testing terminal user interfaces: snapshot tests, golden files, headless rendering, integration tests, and CI considerations.

---

## Snapshot Testing

### Ratatui: TestBackend + insta (Rust)

`TestBackend` renders to a buffer without needing a real terminal. Combine with `insta` for snapshot assertions.

```rust
// Cargo.toml
// [dev-dependencies]
// ratatui = "0.26"
// insta = { version = "1", features = ["yaml"] }

#[cfg(test)]
mod tests {
    use ratatui::{backend::TestBackend, Terminal};
    use insta::assert_snapshot;

    fn render_to_string(width: u16, height: u16, app: &App) -> String {
        let backend = TestBackend::new(width, height);
        let mut terminal = Terminal::new(backend).unwrap();
        terminal.draw(|frame| app.render(frame, frame.size())).unwrap();
        let buffer = terminal.backend().buffer().clone();
        // Convert buffer cells to string
        buffer_to_string(&buffer, width, height)
    }

    fn buffer_to_string(buffer: &ratatui::buffer::Buffer, width: u16, height: u16) -> String {
        let mut output = String::new();
        for y in 0..height {
            for x in 0..width {
                let cell = buffer.get(x, y);
                output.push_str(cell.symbol());
            }
            output.push('\n');
        }
        output
    }

    #[test]
    fn test_main_layout_80x24() {
        let app = App::default();
        let rendered = render_to_string(80, 24, &app);
        assert_snapshot!("main_layout_80x24", rendered);
    }

    #[test]
    fn test_modal_overlay() {
        let mut app = App::default();
        app.show_delete_modal("Project Alpha");
        let rendered = render_to_string(80, 24, &app);
        assert_snapshot!("modal_delete_confirmation", rendered);
    }
}
```

Run `cargo insta review` to approve new snapshots. Committed `.snap` files serve as golden references.

### Ratatui: inline buffer assertions

For targeted assertions without full snapshot files:

```rust
#[test]
fn test_status_bar_shows_item_count() {
    let app = App::with_items(vec!["a", "b", "c"]);
    let backend = TestBackend::new(80, 3);
    let mut terminal = Terminal::new(backend).unwrap();
    terminal.draw(|f| app.render_status_bar(f, f.size())).unwrap();

    let buffer = terminal.backend().buffer().clone();
    // Check specific cell content
    assert!(buffer_contains(&buffer, "3 items"));
}
```

### Bubbletea: teatest (Go)

```go
// go get github.com/charmbracelet/x/exp/teatest

func TestMainView(t *testing.T) {
    m := initialModel()
    tm := teatest.NewTestModel(t, m,
        teatest.WithInitialTermSize(80, 24),
    )

    // Send keypress
    tm.Send(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune("j")})

    // Wait for stable output
    teatest.WaitFor(t, tm.Output(),
        func(bts []byte) bool {
            return bytes.Contains(bts, []byte("Project Beta"))
        },
        teatest.WithDuration(2*time.Second),
    )

    // Golden file assertion
    tm.WaitFinished(t, teatest.WithFinalTimeout(time.Second))
    out, err := io.ReadAll(tm.FinalOutput(t))
    require.NoError(t, err)
    golden.RequireEqual(t, out)
}
```

### Ink / React: ink-testing-library (TypeScript/Node)

```typescript
import React from 'react';
import { render } from 'ink-testing-library';
import App from '../src/App';

describe('App', () => {
    it('renders main layout', () => {
        const { lastFrame } = render(<App items={['Alpha', 'Beta', 'Gamma']} />);
        expect(lastFrame()).toMatchSnapshot();
    });

    it('shows modal on delete key', () => {
        const { lastFrame, stdin } = render(<App items={['Alpha']} />);
        stdin.write('d');
        expect(lastFrame()).toContain('Delete "Alpha"?');
        expect(lastFrame()).toMatchSnapshot();
    });

    it('filters items on search', () => {
        const { lastFrame, stdin } = render(<App items={['Alpha', 'Beta']} />);
        stdin.write('/');
        stdin.write('al');
        expect(lastFrame()).toContain('Alpha');
        expect(lastFrame()).not.toContain('Beta');
    });
});
```

---

## Golden File Testing

Golden files are expected output stored on disk. Useful when insta/teatest is unavailable, or for cross-language consistency checks.

```rust
// Pattern: write actual output, compare against .golden file
fn assert_golden(test_name: &str, actual: &str) {
    let golden_path = format!("tests/golden/{}.golden", test_name);
    let golden_path = std::path::Path::new(&golden_path);

    if std::env::var("UPDATE_GOLDEN").is_ok() {
        std::fs::create_dir_all(golden_path.parent().unwrap()).unwrap();
        std::fs::write(golden_path, actual).unwrap();
        return;
    }

    let expected = std::fs::read_to_string(golden_path)
        .expect(&format!("Golden file not found: {}", golden_path.display()));

    assert_eq!(
        expected, actual,
        "Output differs from golden file. Run with UPDATE_GOLDEN=1 to update."
    );
}
```

Update all golden files: `UPDATE_GOLDEN=1 cargo test`

---

## Headless Rendering

For property-based and generative tests, render to a string buffer without assertions:

```rust
// Fuzz test: render does not panic at any terminal size
#[test]
fn test_render_any_size() {
    for width in [20u16, 40, 60, 80, 100, 120, 200] {
        for height in [5u16, 10, 24, 40, 60] {
            let app = App::default();
            let backend = TestBackend::new(width, height);
            let mut terminal = Terminal::new(backend).unwrap();
            // Must not panic
            terminal.draw(|f| app.render(f, f.size())).unwrap();
        }
    }
}
```

```rust
// Property test: status bar is always single line
#[test]
fn test_status_bar_height() {
    for item_count in [0, 1, 100, 10000] {
        let app = App::with_item_count(item_count);
        let rendered = render_to_string(80, 3, &app);
        let lines: Vec<&str> = rendered.lines().collect();
        assert_eq!(lines.len(), 3); // header + status + nothing
    }
}
```

---

## Integration Testing with expect / tmux / VHS

### VHS (terminal recording + CI screenshots)

VHS by Charm runs a real terminal, records keystrokes, and produces `.gif` or `.png` output. Useful for visual regression and documentation.

```vhs
# tests/e2e/main_flow.tape

Output tests/golden/main_flow.gif

Set Shell "bash"
Set FontSize 14
Set Width 800
Set Height 480

Type "./myapp"
Enter
Sleep 500ms

Screenshot tests/golden/initial_state.png

Type "j"
Sleep 100ms
Type "j"
Sleep 100ms

Screenshot tests/golden/after_navigation.png

Type "/"
Type "alpha"
Sleep 200ms

Screenshot tests/golden/search_active.png

Escape
Type "q"
```

Run in CI: `vhs tests/e2e/main_flow.tape`

Compare PNGs with ImageMagick: `compare -metric AE golden.png actual.png diff.png`

### tmux-based integration test

```bash
#!/usr/bin/env bash
set -euo pipefail

SESSION="myapp-test"
tmux new-session -d -s "$SESSION" -x 80 -y 24

# Start the app
tmux send-keys -t "$SESSION" "./myapp" Enter
sleep 0.5

# Capture initial state
INITIAL=$(tmux capture-pane -t "$SESSION" -p)
echo "$INITIAL" | grep -q "MyApp v" || { echo "FAIL: header not found"; exit 1; }

# Navigate down twice
tmux send-keys -t "$SESSION" "j" ""
tmux send-keys -t "$SESSION" "j" ""
sleep 0.2

# Check selection moved
AFTER_NAV=$(tmux capture-pane -t "$SESSION" -p)
echo "$AFTER_NAV" | grep -q "> Project Gamma" || { echo "FAIL: navigation"; exit 1; }

# Cleanup
tmux kill-session -t "$SESSION"
echo "PASS"
```

---

## Visual Regression with VHS Screenshots

In CI, use VHS to produce screenshots on every PR and diff against main:

```yaml
# .github/workflows/visual-regression.yml
name: Visual Regression
on: [pull_request]
jobs:
  vhs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: charmbracelet/vhs-action@v2
        with:
          path: tests/e2e/*.tape
      - name: Compare screenshots
        run: |
          for f in tests/golden/*.png; do
            name=$(basename "$f")
            if [ -f "tests/golden/baseline/$name" ]; then
              diff=$(compare -metric AE "tests/golden/baseline/$name" "$f" /dev/null 2>&1)
              if [ "$diff" -gt 100 ]; then
                echo "VISUAL REGRESSION: $name (diff: $diff pixels)"
                exit 1
              fi
            fi
          done
```

---

## CI/CD Considerations

### No TTY in CI

CI environments (GitHub Actions, GitLab CI) do not allocate a TTY. This breaks:
- Raw mode (`terminal.enable_raw_mode()`)
- Direct terminal write (`crossterm::execute!(stdout(), ...)`)
- Color detection that checks `isatty()`

**Solution:** Detect non-TTY and fall back to headless mode:

```rust
fn is_headless() -> bool {
    !atty::is(atty::Stream::Stdout)
        || std::env::var("CI").is_ok()
        || std::env::var("HEADLESS").is_ok()
}

fn main() -> Result<()> {
    if is_headless() {
        run_headless()
    } else {
        run_tui()
    }
}
```

### Environment variables for CI test control

```bash
# In test suite
export CI=true           # Standard CI flag
export NO_COLOR=1        # Disable color in snapshots (diffs are cleaner)
export TERM=xterm-256color  # Consistent TERM for capability detection
```

### Snapshot stability

Strip ANSI escape codes from snapshots to avoid color-code churn:

```rust
fn strip_ansi(s: &str) -> String {
    // Simple ANSI strip — use `strip-ansi-escapes` crate in production
    let re = regex::Regex::new(r"\x1b\[[0-9;]*[a-zA-Z]").unwrap();
    re.replace_all(s, "").to_string()
}
```

For ink/TypeScript: `strip-ansi` npm package.

### Test matrix recommendations

| Dimension | Values to test |
|-----------|---------------|
| Terminal width | 40, 60, 80, 120 |
| Terminal height | 10, 24, 40 |
| Color support | none, ansi, 256, truecolor |
| NO_COLOR | set / unset |
| Items | 0, 1, many (pagination) |
| Unicode | ASCII-only, mixed, emoji |
