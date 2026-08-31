//! Interactive TUI for skill-manage (`-i` / `tui`).
//!
//! Keyboard-first browser: toggle enable/disable, filter, switch providers,
//! apply work-type profiles. Reuses discover/link/catalog backends.

mod app;
mod ui;

use crate::catalog::Catalog;
use crate::config::AppConfig;
use crate::kinds::Provider;
use anyhow::{bail, Result};
use crossterm::event::{self, Event, KeyEventKind};
use crossterm::terminal::{
    disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen,
};
use crossterm::ExecutableCommand;
use ratatui::backend::CrosstermBackend;
use ratatui::Terminal;
use std::io::{self, stdout, IsTerminal};
use std::path::PathBuf;
use std::time::Duration;

pub use app::Screen;

/// Launch the interactive TUI. Requires a real terminal (not a pipe).
// ⟦𓄅𓐋𓎱𓅩⟧ run :: Launch the interactive TUI.
pub fn run(
    cfg: AppConfig,
    catalog: Catalog,
    catalog_path: Option<PathBuf>,
    screen: Screen,
    provider: Option<Provider>,
) -> Result<()> {
    if !io::stdout().is_terminal() {
        bail!("--interactive requires a TTY; use list/enable/disable instead");
    }

    let mut app = app::App::new(cfg, catalog, catalog_path, screen, provider)?;

    enable_raw_mode()?;
    stdout().execute(EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout());
    let mut terminal = Terminal::new(backend)?;

    let result = run_loop(&mut terminal, &mut app);

    disable_raw_mode()?;
    stdout().execute(LeaveAlternateScreen)?;
    terminal.show_cursor()?;

    result
}

fn run_loop(
    terminal: &mut Terminal<CrosstermBackend<io::Stdout>>,
    app: &mut app::App,
) -> Result<()> {
    loop {
        terminal.draw(|f| ui::draw(f, app))?;

        if !event::poll(Duration::from_millis(100))? {
            continue;
        }
        let Event::Key(key) = event::read()? else {
            continue;
        };
        if key.kind != KeyEventKind::Press {
            continue;
        }

        if app.handle_key(key.code, key.modifiers)? {
            break;
        }
    }
    Ok(())
}

// ⟦𓏭𓀀𓂳𓆣⟧ parse_provider :: auto-generated pointer for public function parse_provider
pub fn parse_provider(s: Option<&str>) -> Option<Provider> {
    s.and_then(|raw| {
        if raw.eq_ignore_ascii_case("all") {
            None
        } else {
            raw.parse().ok()
        }
    })
}
