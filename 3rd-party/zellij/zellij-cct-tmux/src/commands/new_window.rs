use crate::{format, idmap, logger, zellij_bridge};

/// tmux new-window [-t <session>] [-n <name>] [-P] [-F <format>]
pub fn run(args: &[&str]) -> i32 {
    let mut _target: Option<&str> = None;
    let mut window_name: Option<String> = None;
    let mut print_info = false;
    let mut format_str: Option<&str> = None;
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-t" if i + 1 < args.len() => {
                i += 1;
                _target = Some(args[i]);
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
            _ => {}
        }
        i += 1;
    }

    let mut action_args = vec!["new-tab"];
    let name_owned;
    if let Some(ref name) = window_name {
        name_owned = name.clone();
        action_args.extend_from_slice(&["--name", &name_owned]);
    }

    let result = zellij_bridge::action(&action_args);
    if result.code != 0 {
        logger::log_msg(&format!(
            "new-window: zellij new-tab failed: {}",
            result.stderr.trim()
        ));
        return 1;
    }

    let pane_id_str = result.stdout.trim();
    if print_info && !pane_id_str.is_empty() {
        let mut idmap = idmap::IdMap::load();
        let tmux_id = idmap.allocate(pane_id_str);

        if let Some(fmt) = format_str {
            let ctx = format::FormatContext {
                pane_id: Some(format!("%{tmux_id}")),
                window_name: window_name.clone(),
                ..Default::default()
            };
            println!("{}", format::expand(fmt, &ctx));
        } else {
            println!("%{tmux_id}");
        }
    }

    0
}
