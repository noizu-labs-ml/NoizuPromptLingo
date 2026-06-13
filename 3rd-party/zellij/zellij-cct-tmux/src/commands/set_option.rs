use crate::logger;

/// tmux set-option [-p|-w|-g] [-t <target>] <key> <value>
/// Most tmux options don't map to Zellij concepts.
/// Pane-scoped border styling is handled by Zellij's built-in borders.
pub fn run(args: &[&str]) -> i32 {
    let mut scope = "global";
    let mut _target: Option<&str> = None;
    let mut key: Option<&str> = None;
    let mut value: Option<&str> = None;
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-p" => scope = "pane",
            "-w" => scope = "window",
            "-g" => scope = "global",
            "-t" if i + 1 < args.len() => {
                i += 1;
                _target = Some(args[i]);
            }
            _ => {
                if key.is_none() {
                    key = Some(args[i]);
                } else if value.is_none() {
                    value = Some(args[i]);
                }
            }
        }
        i += 1;
    }

    let key_str = key.unwrap_or("");
    let val_str = value.unwrap_or("");

    logger::log_msg(&format!(
        "set-option: scope={scope} key={key_str} value={val_str} (accepted as no-op)"
    ));

    // All set-option calls succeed silently.
    // Zellij handles pane borders, colors, and layout natively.
    0
}
