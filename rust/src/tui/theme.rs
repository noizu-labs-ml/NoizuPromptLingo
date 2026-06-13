use ratatui::style::{Color, Modifier, Style};

pub struct Theme;

impl Theme {
    pub fn ok() -> Style {
        Style::default().fg(Color::Green)
    }
    pub fn error() -> Style {
        Style::default().fg(Color::Red)
    }
    pub fn warn() -> Style {
        Style::default().fg(Color::Yellow)
    }
    pub fn info() -> Style {
        Style::default().fg(Color::Cyan)
    }
    pub fn muted() -> Style {
        Style::default().fg(Color::DarkGray)
    }
    pub fn header() -> Style {
        Style::default()
            .fg(Color::White)
            .add_modifier(Modifier::BOLD)
    }
    pub fn selected() -> Style {
        Style::default()
            .fg(Color::Black)
            .bg(Color::Cyan)
            .add_modifier(Modifier::BOLD)
    }
    pub fn title() -> Style {
        Style::default()
            .fg(Color::Cyan)
            .add_modifier(Modifier::BOLD)
    }
    pub fn border() -> Style {
        Style::default().fg(Color::DarkGray)
    }
    pub fn key_hint() -> Style {
        Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD)
    }
    pub fn key_desc() -> Style {
        Style::default().fg(Color::DarkGray)
    }
}

/// Map VerifyStatus to a colored symbol + style
pub fn status_display(status: &crate::engine::VerifyStatus) -> (&'static str, Style) {
    use crate::engine::VerifyStatus::*;
    match status {
        Ok => ("✓", Theme::ok()),
        Mismatch => ("≠", Theme::error()),
        MissingYaml => ("?", Theme::warn()),
        MissingDc => ("dc?", Theme::warn()),
        MissingInfisical => ("inf?", Theme::warn()),
        MissingAll => ("✗", Theme::error()),
    }
}
