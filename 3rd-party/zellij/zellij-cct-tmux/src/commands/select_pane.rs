use crate::{idmap, logger, zellij_bridge};

/// tmux select-pane [-t <target>] [-P <style>] [-T <title>]
pub fn run(args: &[&str]) -> i32 {
    let mut target: Option<&str> = None;
    let mut style: Option<&str> = None;
    let mut title: Option<&str> = None;
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-t" if i + 1 < args.len() => {
                i += 1;
                target = Some(args[i]);
            }
            "-P" if i + 1 < args.len() => {
                i += 1;
                style = Some(args[i]);
            }
            "-T" if i + 1 < args.len() => {
                i += 1;
                title = Some(args[i]);
            }
            _ => {}
        }
        i += 1;
    }

    let zellij_id = resolve_pane_id(target);

    // Handle -T (title) -> zellij action rename-pane
    if let Some(name) = title {
        if let Some(ref zid) = zellij_id {
            let result =
                zellij_bridge::action(&["rename-pane", "--pane-id", zid, name]);
            if result.code != 0 {
                logger::log_msg(&format!(
                    "select-pane -T: rename-pane failed: {}",
                    result.stderr.trim()
                ));
            }
        }
    }

    // Handle -P (style) -> zellij action set-pane-color
    if let Some(style_str) = style {
        if let Some(ref zid) = zellij_id {
            let (fg, bg) = parse_tmux_style(style_str);
            let mut action_args = vec!["set-pane-color", "--pane-id", zid];
            let fg_owned;
            let bg_owned;
            if let Some(ref f) = fg {
                fg_owned = tmux_color_to_hex(f);
                action_args.extend_from_slice(&["--fg", &fg_owned]);
            }
            if let Some(ref b) = bg {
                if b != "default" {
                    bg_owned = tmux_color_to_hex(b);
                    action_args.extend_from_slice(&["--bg", &bg_owned]);
                }
            }
            let result = zellij_bridge::action(&action_args);
            if result.code != 0 {
                logger::log_msg(&format!(
                    "select-pane -P: set-pane-color failed: {}",
                    result.stderr.trim()
                ));
            }
        }
    }

    0
}

fn resolve_pane_id(target: Option<&str>) -> Option<String> {
    let t = target?;
    let tmux_id = idmap::parse_tmux_pane_id(t)?;
    let idmap = idmap::IdMap::load();
    idmap.to_zellij(tmux_id).map(|s| s.to_string())
}

fn parse_tmux_style(style: &str) -> (Option<String>, Option<String>) {
    let mut fg = None;
    let mut bg = None;
    for part in style.split(',') {
        let part = part.trim();
        if let Some(val) = part.strip_prefix("fg=") {
            fg = Some(val.to_string());
        } else if let Some(val) = part.strip_prefix("bg=") {
            bg = Some(val.to_string());
        }
    }
    (fg, bg)
}

fn tmux_color_to_hex(color: &str) -> String {
    match color {
        "red" => "#ff0000".into(),
        "green" => "#00ff00".into(),
        "blue" => "#0000ff".into(),
        "yellow" => "#ffff00".into(),
        "magenta" | "purple" => "#ff00ff".into(),
        "cyan" => "#00ffff".into(),
        "white" => "#ffffff".into(),
        "black" => "#000000".into(),
        "orange" => "#ff8c00".into(),
        "default" => "#ffffff".into(),
        // tmux colour0-colour255 or direct hex
        c if c.starts_with('#') => c.to_string(),
        c if c.starts_with("colour") => {
            // Map tmux 256-color codes to hex (simplified — use white as fallback)
            logger::log_msg(&format!("tmux_color_to_hex: unsupported {c}, using white"));
            "#ffffff".into()
        }
        other => {
            logger::log_msg(&format!("tmux_color_to_hex: unknown color {other}"));
            other.to_string()
        }
    }
}
