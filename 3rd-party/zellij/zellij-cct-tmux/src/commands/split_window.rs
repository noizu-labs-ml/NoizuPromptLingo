use crate::{idmap, logger, zellij_bridge};

/// tmux split-window [-h|-v] [-l <size>] [-t <target>] [-P] [-F <format>] [-c <cwd>]
pub fn run(args: &[&str]) -> i32 {
    let mut horizontal = false;
    let mut print_info = false;
    let mut format = String::new();
    let mut _target = String::new();
    let mut _size = String::new();
    let mut _cwd = String::new();
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-h" => horizontal = true,
            "-v" => {} // vertical is the default in tmux; Zellij picks automatically
            "-P" => print_info = true,
            "-F" if i + 1 < args.len() => {
                i += 1;
                format = args[i].to_string();
            }
            "-t" if i + 1 < args.len() => {
                i += 1;
                _target = args[i].to_string();
            }
            "-l" if i + 1 < args.len() => {
                i += 1;
                _size = args[i].to_string();
            }
            "-c" if i + 1 < args.len() => {
                i += 1;
                _cwd = args[i].to_string();
            }
            _ => {}
        }
        i += 1;
    }

    let mut action_args = vec!["new-pane"];
    if horizontal {
        action_args.extend_from_slice(&["--direction", "right"]);
    }

    let result = zellij_bridge::action(&action_args);
    if result.code != 0 {
        eprintln!("split-window failed: {}", result.stderr.trim());
        return 1;
    }

    let zellij_id = result.stdout.trim().to_string();
    if zellij_id.is_empty() {
        logger::log_msg("split-window: no pane ID returned from zellij");
        if print_info {
            println!("%0");
        }
        return 0;
    }

    let mut idmap = idmap::IdMap::load();
    let tmux_id = idmap.allocate(&zellij_id);

    if print_info {
        if format.contains("#{pane_id}") || format.contains("#{") {
            let ctx = crate::format::FormatContext {
                pane_id: Some(format!("%{tmux_id}")),
                ..Default::default()
            };
            println!("{}", crate::format::expand(&format, &ctx));
        } else {
            println!("%{tmux_id}");
        }
    }

    logger::log_msg(&format!(
        "split-window: created pane %{tmux_id} -> {zellij_id}"
    ));
    0
}
