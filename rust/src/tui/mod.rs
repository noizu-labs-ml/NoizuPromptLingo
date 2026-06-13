pub mod theme;
pub mod verify_view;
pub mod fetch_view;
pub mod populate_view;

use anyhow::Result;
use crossterm::{
    event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode, KeyModifiers},
    execute,
    terminal::{EnterAlternateScreen, LeaveAlternateScreen, disable_raw_mode, enable_raw_mode},
};
use ratatui::{Terminal, backend::CrosstermBackend};
use std::io;

pub fn is_tty() -> bool {
    atty::is(atty::Stream::Stdout)
}

/// Set up the terminal for TUI rendering.
/// Returns a cleanup guard — drop it to restore the terminal.
pub fn setup_terminal() -> Result<Terminal<CrosstermBackend<io::Stdout>>> {
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let terminal = Terminal::new(backend)?;
    Ok(terminal)
}

pub fn restore_terminal(terminal: &mut Terminal<CrosstermBackend<io::Stdout>>) -> Result<()> {
    disable_raw_mode()?;
    execute!(
        terminal.backend_mut(),
        LeaveAlternateScreen,
        DisableMouseCapture
    )?;
    terminal.show_cursor()?;
    Ok(())
}

/// Read a key event, return (key_code, modifiers)
pub fn read_key() -> Result<(KeyCode, KeyModifiers)> {
    loop {
        if let Event::Key(key) = event::read()? {
            return Ok((key.code, key.modifiers));
        }
    }
}

/// Render a footer line showing common key hints
pub fn key_hints(pairs: &[(&str, &str)]) -> ratatui::text::Line<'static> {
    use ratatui::text::{Line, Span};
    use theme::Theme;

    let mut spans: Vec<Span> = Vec::new();
    for (i, (key, desc)) in pairs.iter().enumerate() {
        if i > 0 {
            spans.push(Span::raw("  "));
        }
        spans.push(Span::styled(format!("[{key}]"), Theme::key_hint()));
        spans.push(Span::styled(format!(" {desc}"), Theme::key_desc()));
    }
    Line::from(spans)
}
