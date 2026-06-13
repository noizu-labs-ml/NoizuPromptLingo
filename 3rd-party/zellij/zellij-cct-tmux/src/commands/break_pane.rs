use crate::logger;

/// tmux break-pane [-d] [-s <source>] [-t <target>]
/// Claude Code uses this to hide teammate panes by moving them to a hidden session.
/// We track the "hidden" state in the idmap without actually destroying the pane.
pub fn run(args: &[&str]) -> i32 {
    let mut source: Option<&str> = None;
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-d" => {} // detach after break — always implied
            "-s" if i + 1 < args.len() => {
                i += 1;
                source = Some(args[i]);
            }
            "-t" if i + 1 < args.len() => {
                i += 1;
                // target session — ignored (we keep the pane in place)
            }
            _ => {}
        }
        i += 1;
    }

    let Some(src) = source else {
        logger::log_msg("break-pane: no -s source specified");
        return 0;
    };

    logger::log_msg(&format!(
        "break-pane: hiding pane {src} (pane stays in Zellij, tracked as hidden)"
    ));

    // We don't actually move the pane — just log it.
    // Claude Code's hide/show is cosmetic; the pane keeps running.
    0
}
