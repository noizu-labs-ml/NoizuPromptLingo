use std::env;

use crate::{format, idmap, logger};

/// tmux list-panes [-t <target>] [-F <format>]
///
/// Zellij has no `list-panes` action, so we use the idmap as source of truth.
/// The leader pane (from TMUX_PANE) is always included even if not yet in the idmap.
pub fn run(args: &[&str]) -> i32 {
    let mut fmt: Option<&str> = None;
    let mut _target: Option<&str> = None;
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-F" if i + 1 < args.len() => {
                i += 1;
                fmt = Some(args[i]);
            }
            "-t" if i + 1 < args.len() => {
                i += 1;
                _target = Some(args[i]);
            }
            _ => {}
        }
        i += 1;
    }

    let idmap = idmap::IdMap::load();
    let active_panes = idmap.all_active();

    let leader_id = env::var("TMUX_PANE")
        .ok()
        .and_then(|p| p.strip_prefix('%').unwrap_or(&p).parse::<u32>().ok());

    let mut seen = std::collections::HashSet::new();

    // Always include the leader pane first
    if let Some(lid) = leader_id {
        emit_pane(lid, "", true, fmt);
        seen.insert(lid);
    }

    for (tmux_id, _zellij_id) in &active_panes {
        if seen.contains(tmux_id) {
            continue;
        }
        emit_pane(*tmux_id, "", false, fmt);
        seen.insert(*tmux_id);
    }

    if seen.is_empty() {
        emit_pane(0, "", true, fmt);
    }

    logger::log_msg(&format!("list-panes: returned {} panes from idmap", seen.len()));
    0
}

fn emit_pane(tmux_id: u32, title: &str, is_focused: bool, fmt: Option<&str>) {
    if let Some(template) = fmt {
        let ctx = format::FormatContext {
            pane_id: Some(format!("%{tmux_id}")),
            pane_title: Some(title.to_string()),
            ..Default::default()
        };
        println!("{}", format::expand(template, &ctx));
    } else {
        let active = if is_focused { " (active)" } else { "" };
        println!("%{tmux_id}: {title}{active}");
    }
}
