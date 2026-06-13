use crate::{logger, tab_resolve, zellij_bridge};

/// tmux select-window [-t <target>]
pub fn run(args: &[&str]) -> i32 {
    let mut target: Option<&str> = None;
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-t" if i + 1 < args.len() => {
                i += 1;
                target = Some(args[i]);
            }
            _ => {}
        }
        i += 1;
    }

    let Some(t) = target else {
        logger::log_msg("select-window: no -t target provided");
        return 1;
    };

    let Some(resolved) = tab_resolve::resolve(t) else {
        eprintln!("can't find window: {t}");
        return 1;
    };

    let result = zellij_bridge::action(&["go-to-tab-name", &resolved.name]);
    if result.code != 0 {
        logger::log_msg(&format!(
            "select-window: go-to-tab-name failed: {}",
            result.stderr.trim()
        ));
        return 1;
    }

    0
}
