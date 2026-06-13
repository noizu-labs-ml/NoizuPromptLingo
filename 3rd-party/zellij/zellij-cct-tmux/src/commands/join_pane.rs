use crate::logger;

/// tmux join-pane [-h] [-s <source>] [-t <target>]
/// Complement of break-pane — restores a "hidden" pane.
/// Since we don't actually hide panes (they stay in Zellij), this is a no-op.
pub fn run(args: &[&str]) -> i32 {
    let mut source: Option<&str> = None;
    let mut _target: Option<&str> = None;
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-h" => {} // horizontal — ignored
            "-s" if i + 1 < args.len() => {
                i += 1;
                source = Some(args[i]);
            }
            "-t" if i + 1 < args.len() => {
                i += 1;
                _target = Some(args[i]);
            }
            _ => {}
        }
        i += 1;
    }

    logger::log_msg(&format!(
        "join-pane: showing pane {:?} (no-op, pane was never hidden)",
        source
    ));

    0
}
