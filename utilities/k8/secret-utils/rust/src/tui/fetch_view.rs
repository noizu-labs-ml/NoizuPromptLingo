use anyhow::Result;
use crossterm::event::{KeyCode, KeyModifiers};
use ratatui::{
    Frame,
    layout::{Constraint, Direction, Layout},
    text::{Line, Span},
    widgets::{Block, Borders, Cell, Paragraph, Row, Table, TableState},
};

use crate::api::types::SecretItem;
use crate::tui::{self, theme::Theme};

pub struct FetchView {
    secrets: Vec<SecretItem>,
    table_state: TableState,
    path: String,
    env: String,
    redact: bool,
}

impl FetchView {
    pub fn new(secrets: Vec<SecretItem>, path: String, env: String, redact: bool) -> Self {
        let mut table_state = TableState::default();
        if !secrets.is_empty() {
            table_state.select(Some(0));
        }
        Self { secrets, table_state, path, env, redact }
    }

    pub fn run(mut self) -> Result<()> {
        let mut terminal = tui::setup_terminal()?;

        loop {
            terminal.draw(|f| self.render(f))?;

            let (key, mods) = tui::read_key()?;
            match (key, mods) {
                (KeyCode::Char('q'), _)
                | (KeyCode::Char('c'), KeyModifiers::CONTROL)
                | (KeyCode::Esc, _) => break,
                (KeyCode::Down, _) | (KeyCode::Char('j'), _) => self.move_down(),
                (KeyCode::Up, _) | (KeyCode::Char('k'), _) => self.move_up(),
                (KeyCode::Char('g'), _) => self.table_state.select(Some(0)),
                (KeyCode::Char('G'), _) => {
                    if !self.secrets.is_empty() {
                        self.table_state.select(Some(self.secrets.len() - 1));
                    }
                }
                (KeyCode::Char('r'), _) => self.redact = !self.redact,
                _ => {}
            }
        }

        tui::restore_terminal(&mut terminal)?;
        Ok(())
    }

    fn render(&mut self, f: &mut Frame) {
        let area = f.area();
        let chunks = Layout::default()
            .direction(Direction::Vertical)
            .constraints([
                Constraint::Length(3),
                Constraint::Min(0),
                Constraint::Length(1),
            ])
            .split(area);

        // Header
        let header_line = Line::from(vec![
            Span::styled(" Path: ", Theme::muted()),
            Span::styled(self.path.clone(), Theme::info()),
            Span::raw("  "),
            Span::styled("Env: ", Theme::muted()),
            Span::styled(self.env.clone(), Theme::info()),
            Span::raw("  "),
            Span::styled(format!("{} secrets", self.secrets.len()), Theme::muted()),
        ]);
        let header_block = Block::default()
            .title(Span::styled("Infisical Secrets", Theme::title()))
            .borders(Borders::ALL)
            .border_style(Theme::border());
        let header_para = Paragraph::new(header_line).block(header_block);
        f.render_widget(header_para, chunks[0]);

        // Table
        let col_header = Row::new(vec![
            Cell::from("Key").style(Theme::header()),
            Cell::from("Value").style(Theme::header()),
        ])
        .height(1);

        let rows: Vec<Row> = self
            .secrets
            .iter()
            .map(|s| {
                let val = if self.redact {
                    redact_value(&s.value)
                } else {
                    s.value.clone()
                };
                Row::new(vec![Cell::from(s.key.clone()), Cell::from(val)])
            })
            .collect();

        let widths = [Constraint::Percentage(35), Constraint::Percentage(65)];
        let table = Table::new(rows, widths)
            .header(col_header)
            .block(
                Block::default()
                    .borders(Borders::ALL)
                    .border_style(Theme::border()),
            )
            .highlight_style(Theme::selected());

        f.render_stateful_widget(table, chunks[1], &mut self.table_state);

        // Hints
        let hints = tui::key_hints(&[
            ("j/↓", "down"),
            ("k/↑", "up"),
            ("r", "toggle redact"),
            ("q", "quit"),
        ]);
        f.render_widget(Paragraph::new(hints), chunks[2]);
    }

    fn move_down(&mut self) {
        let next = match self.table_state.selected() {
            Some(i) if i + 1 < self.secrets.len() => i + 1,
            Some(i) => i,
            None => 0,
        };
        self.table_state.select(Some(next));
    }

    fn move_up(&mut self) {
        let next = match self.table_state.selected() {
            Some(0) | None => 0,
            Some(i) => i - 1,
        };
        self.table_state.select(Some(next));
    }
}

fn redact_value(v: &str) -> String {
    if v.len() <= 6 {
        return "****".to_owned();
    }
    let prefix = &v[..4];
    let suffix = &v[v.len() - 2..];
    format!("{}…{}", prefix, suffix)
}

/// Plain-text fallback
pub fn print_secrets_plain(
    secrets: &[SecretItem],
    format: &crate::cli::FetchFormat,
    redact: bool,
) {
    use crate::cli::FetchFormat;

    match format {
        FetchFormat::Table => {
            for s in secrets {
                let val = if redact { redact_value(&s.value) } else { s.value.clone() };
                println!("{:<40} = {}", s.key, val);
            }
        }
        FetchFormat::Env => {
            for s in secrets {
                let val = if redact { redact_value(&s.value) } else { s.value.clone() };
                // Shell-safe quoting: replace ' with '\''
                let quoted = val.replace('\'', "'\\''");
                println!("export {}='{}'", s.key, quoted);
            }
        }
        FetchFormat::Json => {
            let items: Vec<serde_json::Value> = secrets
                .iter()
                .map(|s| {
                    serde_json::json!({
                        "key": s.key,
                        "value": if redact { redact_value(&s.value) } else { s.value.clone() }
                    })
                })
                .collect();
            println!("{}", serde_json::to_string_pretty(&items).unwrap());
        }
    }
}
