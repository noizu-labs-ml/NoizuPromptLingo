use crate::{logger, tab_resolve, zellij_bridge};

/// tmux rename-window [-t <target>] <new-name>
pub fn run(args: &[&str]) -> i32 {
    let mut target: Option<&str> = None;
    let mut new_name: Option<&str> = None;
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-t" if i + 1 < args.len() => {
                i += 1;
                target = Some(args[i]);
            }
            _ => {
                if new_name.is_none() {
                    new_name = Some(args[i]);
                }
            }
        }
        i += 1;
    }

    let Some(name) = new_name else {
        logger::log_msg("rename-window: no new name provided");
        return 1;
    };

    // Navigate to target tab if specified
    if let Some(t) = target {
        let Some(resolved) = tab_resolve::resolve(t) else {
            eprintln!("can't find window: {t}");
            return 1;
        };
        let nav = zellij_bridge::action(&["go-to-tab-name", &resolved.name]);
        if nav.code != 0 {
            logger::log_msg(&format!(
                "rename-window: go-to-tab-name failed: {}",
                nav.stderr.trim()
            ));
            return 1;
        }
    }

    let result = zellij_bridge::action(&["rename-tab", name]);
    if result.code != 0 {
        logger::log_msg(&format!(
            "rename-window: rename-tab failed: {}",
            result.stderr.trim()
        ));
        return 1;
    }

    0
}
