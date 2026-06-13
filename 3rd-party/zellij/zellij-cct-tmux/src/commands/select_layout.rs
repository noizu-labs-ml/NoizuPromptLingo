use crate::logger;

/// tmux select-layout [-t <target>] <layout-name>
/// Zellij doesn't expose named layouts via CLI yet.
/// Claude Code uses: main-vertical, tiled
pub fn run(args: &[&str]) -> i32 {
    let mut _target: Option<&str> = None;
    let mut layout: Option<&str> = None;
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-t" if i + 1 < args.len() => {
                i += 1;
                _target = Some(args[i]);
            }
            _ => {
                if layout.is_none() {
                    layout = Some(args[i]);
                }
            }
        }
        i += 1;
    }

    logger::log_msg(&format!(
        "select-layout: {:?} (accepted, Zellij auto-layouts)",
        layout
    ));

    0
}
