//! Small reusable blocking TUI screens: a list picker, a text input, and a
//! yes/no confirm. Each runs its own draw/event loop and returns the user's
//! choice (or `None`/`false` on cancel).

use crate::error::Result;
use ratatui::crossterm::event::{self, Event, KeyCode, KeyEventKind};
use ratatui::layout::{Constraint, Direction, Layout};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, Borders, List, ListItem, ListState, Paragraph, Wrap};
use ratatui::DefaultTerminal;

const ACCENT: Color = Color::Cyan;

fn header(title: &str) -> Block<'static> {
    Block::default()
        .borders(Borders::ALL)
        .title(Span::styled(
            format!(" {title} "),
            Style::default().fg(ACCENT).add_modifier(Modifier::BOLD),
        ))
}

/// A scrollable single-select list. Returns the chosen index, or `None` on Esc/q.
pub fn select_list(
    terminal: &mut DefaultTerminal,
    title: &str,
    help: &str,
    items: &[String],
) -> Result<Option<usize>> {
    let mut state = ListState::default();
    if !items.is_empty() {
        state.select(Some(0));
    }

    loop {
        terminal.draw(|f| {
            let chunks = Layout::default()
                .direction(Direction::Vertical)
                .constraints([Constraint::Min(1), Constraint::Length(1)])
                .split(f.area());

            let list_items: Vec<ListItem> =
                items.iter().map(|i| ListItem::new(i.as_str())).collect();
            let list = List::new(list_items)
                .block(header(title))
                .highlight_style(
                    Style::default()
                        .bg(ACCENT)
                        .fg(Color::Black)
                        .add_modifier(Modifier::BOLD),
                )
                .highlight_symbol("▶ ");
            f.render_stateful_widget(list, chunks[0], &mut state);

            let help = Paragraph::new(Line::from(Span::styled(
                format!(" {help}  ↑/↓ move · Enter select · q cancel"),
                Style::default().fg(Color::DarkGray),
            )));
            f.render_widget(help, chunks[1]);
        })?;

        if let Event::Key(key) = event::read()? {
            if key.kind != KeyEventKind::Press {
                continue;
            }
            match key.code {
                KeyCode::Char('q') | KeyCode::Esc => return Ok(None),
                KeyCode::Enter => return Ok(state.selected()),
                KeyCode::Down | KeyCode::Char('j') => move_sel(&mut state, items.len(), 1),
                KeyCode::Up | KeyCode::Char('k') => move_sel(&mut state, items.len(), -1),
                _ => {}
            }
        }
    }
}

fn move_sel(state: &mut ListState, len: usize, delta: isize) {
    if len == 0 {
        return;
    }
    let cur = state.selected().unwrap_or(0) as isize;
    let next = (cur + delta).rem_euclid(len as isize) as usize;
    state.select(Some(next));
}

/// A single-line text input pre-filled with `initial`. Returns the trimmed value
/// on Enter, or `None` on Esc.
pub fn text_input(
    terminal: &mut DefaultTerminal,
    title: &str,
    prompt: &str,
    initial: &str,
) -> Result<Option<String>> {
    let mut buf = initial.to_string();

    loop {
        terminal.draw(|f| {
            let chunks = Layout::default()
                .direction(Direction::Vertical)
                .constraints([
                    Constraint::Length(3),
                    Constraint::Length(3),
                    Constraint::Min(0),
                ])
                .split(f.area());

            let p = Paragraph::new(prompt)
                .block(header(title))
                .wrap(Wrap { trim: true });
            f.render_widget(p, chunks[0]);

            let input = Paragraph::new(Line::from(vec![
                Span::raw(&buf),
                Span::styled("▏", Style::default().fg(ACCENT)),
            ]))
            .block(Block::default().borders(Borders::ALL));
            f.render_widget(input, chunks[1]);

            let help = Paragraph::new(Span::styled(
                " Enter accept · Esc cancel",
                Style::default().fg(Color::DarkGray),
            ));
            f.render_widget(help, chunks[2]);
        })?;

        if let Event::Key(key) = event::read()? {
            if key.kind != KeyEventKind::Press {
                continue;
            }
            match key.code {
                KeyCode::Esc => return Ok(None),
                KeyCode::Enter => return Ok(Some(buf.trim().to_string())),
                KeyCode::Backspace => {
                    buf.pop();
                }
                KeyCode::Char(c) => buf.push(c),
                _ => {}
            }
        }
    }
}

/// Draw a one-shot informational frame (no event loop). Useful right before a
/// blocking operation so the user sees what's happening.
pub fn note(terminal: &mut DefaultTerminal, title: &str, body: &str) -> Result<()> {
    terminal.draw(|f| {
        let p = Paragraph::new(body.to_string())
            .block(header(title))
            .wrap(Wrap { trim: true });
        f.render_widget(p, f.area());
    })?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn state(selected: Option<usize>) -> ListState {
        let mut s = ListState::default();
        s.select(selected);
        s
    }

    #[test]
    fn move_down() {
        let mut s = state(Some(0));
        move_sel(&mut s, 3, 1);
        assert_eq!(s.selected(), Some(1));
    }

    #[test]
    fn move_wraps_at_end() {
        let mut s = state(Some(2));
        move_sel(&mut s, 3, 1);
        assert_eq!(s.selected(), Some(0));
    }

    #[test]
    fn move_wraps_at_start() {
        let mut s = state(Some(0));
        move_sel(&mut s, 3, -1);
        assert_eq!(s.selected(), Some(2));
    }

    #[test]
    fn empty_list_is_noop() {
        let mut s = state(None);
        move_sel(&mut s, 0, 1);
        assert_eq!(s.selected(), None);
    }
}

/// A yes/no confirmation. Returns true for y/Enter, false for n/Esc.
pub fn confirm(terminal: &mut DefaultTerminal, title: &str, body: &str) -> Result<bool> {
    loop {
        terminal.draw(|f| {
            let p = Paragraph::new(format!("{body}\n\n[y] proceed   [n] cancel"))
                .block(header(title))
                .wrap(Wrap { trim: true });
            f.render_widget(p, f.area());
        })?;

        if let Event::Key(key) = event::read()? {
            if key.kind != KeyEventKind::Press {
                continue;
            }
            match key.code {
                KeyCode::Char('y') | KeyCode::Char('Y') | KeyCode::Enter => return Ok(true),
                KeyCode::Char('n') | KeyCode::Char('N') | KeyCode::Esc => return Ok(false),
                _ => {}
            }
        }
    }
}
