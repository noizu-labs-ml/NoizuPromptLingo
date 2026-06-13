use crate::color;
use crate::emoji;
use crate::state::TabState;
use crate::terminal;

pub fn get_indicator(state: &TabState) -> String {
    if !state.emoji.is_empty() {
        if let Some(ch) = emoji::emoji_lookup(&state.emoji) {
            return ch.to_string();
        }
    }
    if let Ok(level) = state.urgency.parse::<u8>() {
        return color::urgency_dot(level).to_string();
    }
    String::new()
}

pub fn render_title(state: &TabState) {
    let max_title = 25;
    let max_status = 20;

    let mut t_title = state.title.clone();
    if t_title.chars().count() > max_title {
        t_title = t_title.chars().take(max_title - 1).collect::<String>() + "\u{2026}";
    }

    let dot = get_indicator(state);
    let prefix = if dot.is_empty() {
        String::new()
    } else {
        format!("{} ", dot)
    };

    let output = if state.status.is_empty() {
        format!("{}{}", prefix, t_title)
    } else {
        let mut t_status = state.status.clone();
        if t_status.chars().count() > max_status {
            t_status = t_status.chars().take(max_status - 1).collect::<String>() + "\u{2026}";
        }
        format!("{}{}: {}", prefix, t_title, t_status)
    };

    if state.marquee && !state.status.is_empty() {
        return;
    }

    terminal::send_title(&output);
}

pub fn display(state: &TabState) {
    let reset = "\x1b[0m";

    let tc = if !state.highlight.is_empty() {
        if let Some(code) = color::color_code_or_raw(&state.highlight) {
            format!("\x1b[{}m", code)
        } else {
            reset.to_string()
        }
    } else {
        reset.to_string()
    };

    let sc = if let Ok(level) = state.urgency.parse::<u8>() {
        format!("\x1b[{}m", color::urgency_ansi(level))
    } else {
        reset.to_string()
    };

    let dot = get_indicator(state);
    let dot_prefix = if dot.is_empty() {
        String::new()
    } else {
        format!("{} ", dot)
    };

    let title_text = if state.title.is_empty() {
        "(not set)".to_string()
    } else {
        state.title.clone()
    };

    if state.status.is_empty() {
        println!("{}{}{}", tc, title_text, reset);
    } else {
        println!(
            "{}{}{}: {}{}{}{}",
            tc, title_text, reset, dot_prefix, sc, state.status, reset
        );
    }
}

pub fn display_stderr(state: &TabState) {
    let reset = "\x1b[0m";

    let tc = if !state.highlight.is_empty() {
        if let Some(code) = color::color_code_or_raw(&state.highlight) {
            format!("\x1b[{}m", code)
        } else {
            reset.to_string()
        }
    } else {
        reset.to_string()
    };

    let sc = if let Ok(level) = state.urgency.parse::<u8>() {
        format!("\x1b[{}m", color::urgency_ansi(level))
    } else {
        reset.to_string()
    };

    let dot = get_indicator(state);
    let dot_prefix = if dot.is_empty() {
        String::new()
    } else {
        format!("{} ", dot)
    };

    let title_text = if state.title.is_empty() {
        "(not set)".to_string()
    } else {
        state.title.clone()
    };

    if state.status.is_empty() {
        eprintln!("{}{}{}", tc, title_text, reset);
    } else {
        eprintln!(
            "{}{}{}: {}{}{}{}",
            tc, title_text, reset, dot_prefix, sc, state.status, reset
        );
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_indicator_emoji() {
        let s = TabState {
            emoji: "rocket".to_string(),
            ..TabState::default()
        };
        let ind = get_indicator(&s);
        assert_eq!(ind, "\u{1F680}");
    }

    #[test]
    fn test_get_indicator_urgency() {
        let s = TabState {
            urgency: "0".to_string(),
            ..TabState::default()
        };
        let ind = get_indicator(&s);
        assert!(!ind.is_empty());
    }

    #[test]
    fn test_get_indicator_emoji_takes_precedence() {
        let s = TabState {
            emoji: "fire".to_string(),
            urgency: "0".to_string(),
            ..TabState::default()
        };
        let ind = get_indicator(&s);
        assert_eq!(ind, "\u{1F525}");
    }

    #[test]
    fn test_get_indicator_empty() {
        let s = TabState::default();
        let ind = get_indicator(&s);
        assert!(ind.is_empty());
    }

    #[test]
    fn test_get_indicator_unknown_emoji_falls_to_urgency() {
        let s = TabState {
            emoji: "nonexistent_emoji".to_string(),
            urgency: "3".to_string(),
            ..TabState::default()
        };
        let ind = get_indicator(&s);
        assert!(!ind.is_empty());
    }
}

pub fn apply_urgency_color(state: &TabState, terminal: &terminal::Terminal) {
    if let Ok(level) = state.urgency.parse::<u8>() {
        if let Some((r, g, b)) = color::urgency_tab_color(level) {
            terminal::send_tab_color(terminal, r, g, b);
        }
    }
}

pub fn apply_bg_color(state: &TabState) {
    if !state.bg.is_empty() {
        if let Some(hex) = color::resolve_hex(&state.bg) {
            terminal::send_bg_color(&hex);
        }
    }
}
