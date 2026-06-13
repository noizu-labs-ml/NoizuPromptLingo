use crate::{idmap, logger, tab_resolve, zellij_bridge};

/// tmux capture-pane [-p] [-t <target>] [-S -<n>] [-e]
pub fn run(args: &[&str]) -> i32 {
    let mut print_to_stdout = false;
    let mut target: Option<&str> = None;
    let mut ansi = false;
    let mut _scroll_start: Option<&str> = None;
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-p" => print_to_stdout = true,
            "-e" => ansi = true,
            "-t" if i + 1 < args.len() => {
                i += 1;
                target = Some(args[i]);
            }
            "-S" if i + 1 < args.len() => {
                i += 1;
                _scroll_start = Some(args[i]);
            }
            _ => {}
        }
        i += 1;
    }

    let mut action_args = vec!["dump-screen"];

    let zellij_id;
    if let Some(t) = target {
        if let Some(tmux_id) = idmap::parse_tmux_pane_id(t) {
            let idmap = idmap::IdMap::load();
            if let Some(z) = idmap.to_zellij(tmux_id) {
                zellij_id = z.to_string();
                action_args.extend_from_slice(&["--pane-id", &zellij_id]);
            }
        } else if let Some(resolved) = tab_resolve::resolve(t) {
            let nav = zellij_bridge::action(&["go-to-tab-name", &resolved.name]);
            if nav.code != 0 {
                logger::log_msg(&format!(
                    "capture-pane: failed to switch to tab {}",
                    resolved.name
                ));
                return 1;
            }
        } else {
            eprintln!("bad target: {t}");
            return 1;
        }
    }

    action_args.push("--full");
    if ansi {
        action_args.push("--ansi");
    }

    let result = zellij_bridge::action(&action_args);
    if result.code != 0 {
        logger::log_msg(&format!(
            "capture-pane: dump-screen failed: {}",
            result.stderr.trim()
        ));
        return 1;
    }

    if print_to_stdout {
        print!("{}", result.stdout);
    }

    0
}
