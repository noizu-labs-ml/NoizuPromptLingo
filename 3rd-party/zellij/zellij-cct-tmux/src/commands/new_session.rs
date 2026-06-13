use crate::{format, idmap, logger, zellij_bridge};

/// tmux new-session [-d] [-s <name>] [-n <window>] [-P] [-F <format>] [-e KEY=VAL]...
/// Maps to creating a Zellij tab (since Zellij sessions are separate server processes,
/// and Claude Code uses new-session mainly for the external swarm view).
pub fn run(args: &[&str]) -> i32 {
    let mut _detached = false;
    let mut session_name: Option<&str> = None;
    let mut window_name: Option<String> = None;
    let mut print_info = false;
    let mut format_str: Option<&str> = None;
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-d" => _detached = true,
            "-s" if i + 1 < args.len() => {
                i += 1;
                session_name = Some(args[i]);
            }
            "-n" if i + 1 < args.len() => {
                i += 1;
                window_name = Some(args[i].to_string());
            }
            "-P" => print_info = true,
            "-F" if i + 1 < args.len() => {
                i += 1;
                format_str = Some(args[i]);
            }
            "-e" if i + 1 < args.len() => {
                i += 1;
                // Environment variables — stored but not directly actionable in Zellij
                logger::log_msg(&format!("new-session: env var {}", args[i]));
            }
            _ => {}
        }
        i += 1;
    }

    // For detached sessions, create a new tab as the closest Zellij equivalent
    let mut action_args = vec!["new-tab"];
    let name_owned;
    if let Some(ref name) = window_name {
        name_owned = name.clone();
        action_args.extend_from_slice(&["--name", &name_owned]);
    } else if let Some(sname) = session_name {
        name_owned = sname.to_string();
        action_args.extend_from_slice(&["--name", &name_owned]);
    }

    let result = zellij_bridge::action(&action_args);
    if result.code != 0 {
        logger::log_msg(&format!(
            "new-session: zellij new-tab failed: {}",
            result.stderr.trim()
        ));
        // Don't fail — Claude Code may retry
        if print_info {
            println!("%0");
        }
        return 0;
    }

    // new-tab returns a pane ID for the initial pane in the new tab
    let pane_id_str = result.stdout.trim();
    if print_info && !pane_id_str.is_empty() {
        let mut idmap = idmap::IdMap::load();
        let tmux_id = idmap.allocate(pane_id_str);

        if let Some(fmt) = format_str {
            let ctx = format::FormatContext {
                pane_id: Some(format!("%{tmux_id}")),
                session_name: session_name.map(|s| s.to_string()),
                window_name: window_name.clone(),
                ..Default::default()
            };
            println!("{}", format::expand(fmt, &ctx));
        } else {
            println!("%{tmux_id}");
        }
    }

    logger::log_msg(&format!(
        "new-session: created tab for session {:?} window {:?}",
        session_name, window_name
    ));
    0
}
