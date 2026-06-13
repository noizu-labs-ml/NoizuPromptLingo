use crate::logger;

/// tmux resize-pane [-t <target>] [-x <width>] [-y <height>] [-LRUD <n>]
/// Zellij's CLI only supports relative resize, not absolute percentages.
/// For `-x 30%` (leader pane sizing), we accept and log.
pub fn run(args: &[&str]) -> i32 {
    let mut target: Option<&str> = None;
    let mut width: Option<&str> = None;
    let mut height: Option<&str> = None;
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-t" if i + 1 < args.len() => {
                i += 1;
                target = Some(args[i]);
            }
            "-x" if i + 1 < args.len() => {
                i += 1;
                width = Some(args[i]);
            }
            "-y" if i + 1 < args.len() => {
                i += 1;
                height = Some(args[i]);
            }
            "-L" | "-R" | "-U" | "-D" if i + 1 < args.len() => {
                // Directional resize — could map to zellij action resize
                i += 1;
            }
            _ => {}
        }
        i += 1;
    }

    logger::log_msg(&format!(
        "resize-pane: target={:?} width={:?} height={:?} (accepted, Zellij auto-sizes)",
        target, width, height
    ));

    0
}
