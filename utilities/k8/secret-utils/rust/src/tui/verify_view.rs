use anyhow::Result;
use crossterm::event::{KeyCode, KeyModifiers};
use ratatui::{
    Frame,
    layout::{Constraint, Direction, Layout, Rect},
    text::{Line, Span},
    widgets::{Block, Borders, Cell, Paragraph, Row, Table, TableState},
};

use crate::engine::{VerifyResult, VerifyStatus, VerifySummary};
use crate::tui::{self, theme::Theme, theme::status_display};

pub struct VerifyView {
    results: Vec<VerifyResult>,
    summary: VerifySummary,
    table_state: TableState,
    show_values: bool,
}

impl VerifyView {
    pub fn new(results: Vec<VerifyResult>, show_values: bool) -> Self {
        let summary = VerifySummary::from_results(&results);
        let mut table_state = TableState::default();
        if !results.is_empty() {
            table_state.select(Some(0));
        }
        Self {
            results,
            summary,
            table_state,
            show_values,
        }
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
                (KeyCode::Char('g'), _) => self.goto_first(),
                (KeyCode::Char('G'), _) => self.goto_last(),
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
                Constraint::Length(3), // summary bar
                Constraint::Min(0),    // table
                Constraint::Length(1), // key hints
            ])
            .split(area);

        self.render_summary(f, chunks[0]);
        self.render_table(f, chunks[1]);
        self.render_hints(f, chunks[2]);
    }

    fn render_summary(&self, f: &mut Frame, area: Rect) {
        let s = &self.summary;
        let items: Vec<Span> = vec![
            Span::styled(format!(" ✓ {} ok", s.ok), Theme::ok()),
            Span::raw("  "),
            Span::styled(format!("≠ {} mismatch", s.mismatch), Theme::error()),
            Span::raw("  "),
            Span::styled(format!("? {} missing_dc", s.missing_dc), Theme::warn()),
            Span::raw("  "),
            Span::styled(format!("✗ {} missing_all", s.missing_all), Theme::error()),
            Span::raw("  "),
            Span::styled(format!("total: {}", s.total), Theme::muted()),
        ];
        let line = Line::from(items);
        let block = Block::default()
            .title(Span::styled("Verify Summary", Theme::title()))
            .borders(Borders::ALL)
            .border_style(Theme::border());
        let para = Paragraph::new(line).block(block);
        f.render_widget(para, area);
    }

    fn render_table(&mut self, f: &mut Frame, area: Rect) {
        let header_cells = if self.show_values {
            vec!["Status", "Name", "Section", "dc Value", "Infisical Value"]
        } else {
            vec!["Status", "Name", "Section", "Path"]
        };

        let header = Row::new(header_cells.iter().map(|h| {
            Cell::from(*h).style(Theme::header())
        }))
        .height(1);

        let rows: Vec<Row> = self
            .results
            .iter()
            .map(|r| {
                let (symbol, style) = status_display(&r.status);
                if self.show_values {
                    Row::new(vec![
                        Cell::from(symbol).style(style),
                        Cell::from(r.name.as_str()),
                        Cell::from(r.section_id.as_str()),
                        Cell::from(r.dc_value.as_deref().unwrap_or("—")),
                        Cell::from(r.infisical_value.as_deref().unwrap_or("—")),
                    ])
                } else {
                    Row::new(vec![
                        Cell::from(symbol).style(style),
                        Cell::from(r.name.as_str()),
                        Cell::from(r.section_id.as_str()),
                        Cell::from(r.path.as_str()),
                    ])
                }
            })
            .collect();

        let widths = if self.show_values {
            vec![
                Constraint::Length(8),
                Constraint::Percentage(20),
                Constraint::Percentage(15),
                Constraint::Percentage(30),
                Constraint::Percentage(30),
            ]
        } else {
            vec![
                Constraint::Length(8),
                Constraint::Percentage(30),
                Constraint::Percentage(25),
                Constraint::Percentage(40),
            ]
        };

        let table = Table::new(rows, widths)
            .header(header)
            .block(
                Block::default()
                    .title(Span::styled("Secrets Verification", Theme::title()))
                    .borders(Borders::ALL)
                    .border_style(Theme::border()),
            )
            .highlight_style(Theme::selected());

        f.render_stateful_widget(table, area, &mut self.table_state);
    }

    fn render_hints(&self, f: &mut Frame, area: Rect) {
        let line = tui::key_hints(&[
            ("j/↓", "down"),
            ("k/↑", "up"),
            ("g", "top"),
            ("G", "bottom"),
            ("q", "quit"),
        ]);
        let para = Paragraph::new(line);
        f.render_widget(para, area);
    }

    fn move_down(&mut self) {
        let next = match self.table_state.selected() {
            Some(i) if i + 1 < self.results.len() => i + 1,
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

    fn goto_first(&mut self) {
        self.table_state.select(Some(0));
    }

    fn goto_last(&mut self) {
        if !self.results.is_empty() {
            self.table_state.select(Some(self.results.len() - 1));
        }
    }
}

/// Plain-text fallback for non-TTY / --no-tui
pub fn print_results_plain(results: &[VerifyResult], show_values: bool) {
    use colored::Colorize;

    let summary = VerifySummary::from_results(results);

    println!(
        "{} ok  {} mismatch  {} missing_dc  {} missing_infisical  {} missing_all  total: {}",
        summary.ok.to_string().green(),
        summary.mismatch.to_string().red(),
        summary.missing_dc.to_string().yellow(),
        summary.missing_infisical.to_string().yellow(),
        summary.missing_all.to_string().red(),
        summary.total
    );
    println!();

    for r in results {
        let (sym, _) = status_display(&r.status);
        let status_str = match r.status {
            VerifyStatus::Ok => sym.green().to_string(),
            VerifyStatus::Mismatch | VerifyStatus::MissingAll => sym.red().to_string(),
            _ => sym.yellow().to_string(),
        };
        print!("{:<6} {:<40} [{}] {}", status_str, r.name, r.section_id, r.path);
        if show_values {
            print!(
                "  dc={} inf={}",
                r.dc_value.as_deref().unwrap_or("—"),
                r.infisical_value.as_deref().unwrap_or("—")
            );
        }
        println!();
    }
}
