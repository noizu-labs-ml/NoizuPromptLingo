use std::env;

/// Expand tmux-style format strings like `#{pane_id}` and `#{session_name}`.
/// Only the 7 variables Claude Code actually uses are supported.
/// Unknown variables expand to empty string.
pub fn expand(template: &str, ctx: &FormatContext) -> String {
    let mut result = String::with_capacity(template.len());
    let mut chars = template.chars().peekable();

    while let Some(ch) = chars.next() {
        if ch == '#' {
            if chars.peek() == Some(&'{') {
                chars.next(); // consume '{'
                let mut var_name = String::new();
                for c in chars.by_ref() {
                    if c == '}' {
                        break;
                    }
                    var_name.push(c);
                }
                result.push_str(&resolve_var(&var_name, ctx));
            } else if chars.peek() == Some(&'[') {
                // tmux style sequences like #[fg=red,bold] — pass through verbatim
                result.push('#');
            } else {
                result.push('#');
            }
        } else {
            result.push(ch);
        }
    }
    result
}

pub struct FormatContext {
    pub pane_id: Option<String>,
    pub session_name: Option<String>,
    pub window_index: Option<u32>,
    pub window_id: Option<String>,
    pub window_name: Option<String>,
    pub pane_title: Option<String>,
    pub socket_path: Option<String>,
    pub pid: Option<u32>,
}

impl Default for FormatContext {
    fn default() -> Self {
        FormatContext {
            pane_id: env::var("TMUX_PANE").ok(),
            session_name: env::var("ZELLIJ_SESSION_NAME").ok(),
            window_index: Some(0),
            window_id: Some("@0".into()),
            window_name: None,
            pane_title: None,
            socket_path: Some("/tmp/zellij-cct-socket".into()),
            pid: Some(std::process::id()),
        }
    }
}

fn resolve_var(name: &str, ctx: &FormatContext) -> String {
    match name {
        "pane_id" => ctx.pane_id.clone().unwrap_or_default(),
        "session_name" => ctx.session_name.clone().unwrap_or_default(),
        "window_index" => ctx.window_index.map(|i| i.to_string()).unwrap_or_default(),
        "window_id" => ctx.window_id.clone().unwrap_or_else(|| "@0".into()),
        "window_name" => ctx.window_name.clone().unwrap_or_default(),
        "pane_title" => ctx.pane_title.clone().unwrap_or_default(),
        "socket_path" => ctx.socket_path.clone().unwrap_or_default(),
        "pid" => ctx.pid.map(|p| p.to_string()).unwrap_or_default(),
        _ => {
            crate::logger::log_msg(&format!("unknown format variable: #{{{name}}}"));
            String::new()
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn expands_known_vars() {
        let ctx = FormatContext {
            pane_id: Some("%3".into()),
            session_name: Some("my-session".into()),
            window_index: Some(0),
            ..Default::default()
        };
        assert_eq!(
            expand("#{session_name}:#{window_index}", &ctx),
            "my-session:0"
        );
        assert_eq!(expand("#{pane_id}", &ctx), "%3");
    }

    #[test]
    fn unknown_vars_expand_to_empty() {
        let ctx = FormatContext::default();
        assert_eq!(expand("#{nonexistent}", &ctx), "");
    }

    #[test]
    fn literal_text_passes_through() {
        let ctx = FormatContext::default();
        assert_eq!(expand("hello world", &ctx), "hello world");
    }

    #[test]
    fn style_sequences_pass_through() {
        let ctx = FormatContext {
            pane_title: Some("agent-1".into()),
            ..Default::default()
        };
        let input = "#[fg=red,bold] #{pane_title} #[default]";
        let result = expand(input, &ctx);
        assert_eq!(result, "#[fg=red,bold] agent-1 #[default]");
    }
}
