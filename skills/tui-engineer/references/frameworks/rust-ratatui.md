# Rust — ratatui + crossterm

## Overview

**ratatui** is an immediate-mode TUI framework for Rust. You own the render loop: each frame, you build a widget tree and ratatui draws it. **crossterm** provides the terminal backend (raw mode, event reading, cursor control) and works on Windows, macOS, and Linux.

Key crates:
- `ratatui` — widgets, layout, styling
- `crossterm` — terminal backend, events
- `color-eyre` — pretty panic/error handling with terminal restore

## Project Setup

```toml
# Cargo.toml
[package]
name = "my-tui"
version = "0.1.0"
edition = "2021"

[dependencies]
ratatui = "0.29"
crossterm = "0.28"
color-eyre = "0.6"
```

```
my-tui/
├── Cargo.toml
├── src/
│   ├── main.rs        # Entry point, terminal setup/restore
│   ├── app.rs         # App state and update logic
│   ├── ui.rs          # Rendering functions
│   └── event.rs       # Event handling (optional separation)
```

## Architecture

### Terminal Setup / Restore

```rust
use crossterm::{
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::prelude::*;

fn setup_terminal() -> color_eyre::Result<Terminal<CrosstermBackend<std::io::Stdout>>> {
    enable_raw_mode()?;
    let mut stdout = std::io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let terminal = Terminal::new(backend)?;
    Ok(terminal)
}

fn restore_terminal(mut terminal: Terminal<CrosstermBackend<std::io::Stdout>>) -> color_eyre::Result<()> {
    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;
    terminal.show_cursor()?;
    Ok(())
}
```

### Panic Handler

Install before `setup_terminal()` so panics restore the terminal:

```rust
fn install_panic_hook() {
    let original_hook = std::panic::take_hook();
    std::panic::set_hook(Box::new(move |panic| {
        let _ = disable_raw_mode();
        let _ = execute!(std::io::stdout(), LeaveAlternateScreen);
        original_hook(panic);
    }));
}
```

### Event Loop

```rust
fn run(terminal: &mut Terminal<impl Backend>, app: &mut App) -> color_eyre::Result<()> {
    loop {
        terminal.draw(|frame| ui::render(frame, app))?;

        if crossterm::event::poll(std::time::Duration::from_millis(50))? {
            if let crossterm::event::Event::Key(key) = crossterm::event::read()? {
                if key.kind == crossterm::event::KeyEventKind::Press {
                    app.handle_key(key);
                }
            }
        }

        if app.should_quit {
            break;
        }
    }
    Ok(())
}
```

## Widget Catalog

| Widget | Purpose | Key Methods |
|--------|---------|-------------|
| `Block` | Bordered container with title | `.title()`, `.borders()`, `.border_type()` |
| `Paragraph` | Text display with wrapping/scrolling | `.wrap(Wrap { trim: true })`, `.scroll((y, x))` |
| `List` | Selectable list of items | `.highlight_style()`, `.highlight_symbol()` |
| `Table` | Tabular data with column headers | `.header()`, `.widths()`, `.highlight_style()` |
| `Tabs` | Tab bar | `.select()`, `.highlight_style()` |
| `Gauge` | Progress bar | `.percent()`, `.ratio()`, `.label()` |
| `LineGauge` | Single-line progress | `.ratio()`, `.line_set()` |
| `Chart` | Line/scatter chart | `.datasets()`, `.x_axis()`, `.y_axis()` |
| `BarChart` | Vertical bar chart | `.data()`, `.bar_width()`, `.bar_gap()` |
| `Sparkline` | Inline mini chart | `.data()`, `.max()` |
| `Canvas` | Freeform drawing (lines, shapes) | `.paint()`, `.x_bounds()`, `.y_bounds()` |
| `Scrollbar` | Scrollbar indicator | `.orientation()`, `.position()` |

## Layout System

```rust
use ratatui::layout::{Layout, Direction, Constraint};

let chunks = Layout::default()
    .direction(Direction::Vertical)
    .constraints([
        Constraint::Length(3),      // fixed 3 rows (header)
        Constraint::Min(0),         // fill remaining (body)
        Constraint::Length(1),      // fixed 1 row (footer)
    ])
    .split(frame.area());
```

**Constraint types:**
- `Length(u16)` — exact cell count
- `Min(u16)` / `Max(u16)` — minimum/maximum
- `Percentage(u16)` — percentage of parent
- `Ratio(u32, u32)` — fraction of parent
- `Fill(u16)` — fill proportionally (like flex-grow)

**Nested layouts:** Split a chunk further for columns within rows.

## Event Handling

```rust
use crossterm::event::{self, Event, KeyCode, KeyModifiers};

match event::read()? {
    Event::Key(key) if key.kind == KeyEventKind::Press => match key.code {
        KeyCode::Char('q') => app.quit(),
        KeyCode::Char('c') if key.modifiers.contains(KeyModifiers::CONTROL) => app.quit(),
        KeyCode::Up | KeyCode::Char('k') => app.previous(),
        KeyCode::Down | KeyCode::Char('j') => app.next(),
        KeyCode::Enter => app.select(),
        KeyCode::Esc => app.back(),
        _ => {}
    },
    Event::Resize(w, h) => { /* layout recalculates automatically */ },
    _ => {}
}
```

## Styling

```rust
use ratatui::style::{Style, Color, Modifier};

let style = Style::default()
    .fg(Color::Cyan)
    .bg(Color::Black)
    .add_modifier(Modifier::BOLD | Modifier::ITALIC);

// Color options
Color::Red                    // basic ANSI
Color::Indexed(208)           // 256-color
Color::Rgb(255, 165, 0)       // truecolor
Color::Reset                  // terminal default
```

## Async Integration

```rust
// With tokio
use futures::StreamExt;
use crossterm::event::EventStream;

async fn run(terminal: &mut Terminal<impl Backend>, app: &mut App) -> color_eyre::Result<()> {
    let mut event_stream = EventStream::new();
    let tick_rate = tokio::time::interval(Duration::from_millis(250));
    tokio::pin!(tick_rate);

    loop {
        terminal.draw(|frame| ui::render(frame, app))?;

        tokio::select! {
            _ = tick_rate.tick() => { app.on_tick(); }
            Some(Ok(event)) = event_stream.next() => {
                if let Event::Key(key) = event {
                    app.handle_key(key);
                }
            }
        }

        if app.should_quit { break; }
    }
    Ok(())
}
```

Requires: `tokio = { version = "1", features = ["full"] }` and `futures = "0.3"` and `crossterm = { version = "0.28", features = ["event-stream"] }`.

## Testing

```rust
#[cfg(test)]
mod tests {
    use ratatui::backend::TestBackend;

    #[test]
    fn renders_correctly() {
        let backend = TestBackend::new(80, 24);
        let mut terminal = Terminal::new(backend).unwrap();
        let mut app = App::default();

        terminal.draw(|frame| ui::render(frame, &app)).unwrap();

        // With insta for snapshot testing
        let buffer = terminal.backend().buffer().clone();
        insta::assert_snapshot!(buffer_to_string(&buffer));
    }
}
```

Add `insta = "1"` to `[dev-dependencies]` for snapshot testing.

## Build & Release

```bash
# Dev
cargo run

# Release
cargo build --release

# Cross-compilation (install cross: cargo install cross)
cross build --release --target x86_64-unknown-linux-musl
cross build --release --target x86_64-pc-windows-gnu
cross build --release --target aarch64-unknown-linux-musl

# cargo-dist for GitHub Releases (install: cargo install cargo-dist)
cargo dist init    # one-time setup
cargo dist build   # local test
# CI: push a tag → GitHub Action builds + publishes

# cargo-release for version management
cargo install cargo-release
cargo release patch --execute
```

## Starter Template

```rust
use std::io;
use crossterm::{
    event::{self, Event, KeyCode, KeyEventKind},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::prelude::*;
use ratatui::widgets::{Block, Borders, List, ListItem, ListState};

struct App {
    items: Vec<String>,
    state: ListState,
    should_quit: bool,
}

impl App {
    fn new() -> Self {
        let mut state = ListState::default();
        state.select(Some(0));
        Self {
            items: vec!["Item 1".into(), "Item 2".into(), "Item 3".into()],
            state,
            should_quit: false,
        }
    }

    fn next(&mut self) {
        let i = self.state.selected().map_or(0, |i| (i + 1) % self.items.len());
        self.state.select(Some(i));
    }

    fn previous(&mut self) {
        let i = self.state.selected().map_or(0, |i| {
            if i == 0 { self.items.len() - 1 } else { i - 1 }
        });
        self.state.select(Some(i));
    }
}

fn main() -> color_eyre::Result<()> {
    color_eyre::install()?;
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let mut terminal = Terminal::new(CrosstermBackend::new(stdout))?;

    let mut app = App::new();
    loop {
        terminal.draw(|frame| {
            let items: Vec<ListItem> = app.items.iter().map(|i| ListItem::new(i.as_str())).collect();
            let list = List::new(items)
                .block(Block::default().title(" My TUI ").borders(Borders::ALL))
                .highlight_style(Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD))
                .highlight_symbol("▶ ");
            frame.render_stateful_widget(list, frame.area(), &mut app.state);
        })?;

        if event::poll(std::time::Duration::from_millis(50))? {
            if let Event::Key(key) = event::read()? {
                if key.kind == KeyEventKind::Press {
                    match key.code {
                        KeyCode::Char('q') => app.should_quit = true,
                        KeyCode::Up | KeyCode::Char('k') => app.previous(),
                        KeyCode::Down | KeyCode::Char('j') => app.next(),
                        _ => {}
                    }
                }
            }
        }
        if app.should_quit { break; }
    }

    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;
    Ok(())
}
```
