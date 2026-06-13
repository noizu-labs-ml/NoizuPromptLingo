use crate::{logger, zellij_bridge};

/// tmux has-session [-t <session>]
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

    let session_name = match target {
        Some(name) => name.to_string(),
        None => {
            let discovered = zellij_bridge::current_session();
            if discovered.is_empty() {
                return 1;
            }
            discovered
        }
    };

    let result = zellij_bridge::command(&["list-sessions", "--short"]);
    if result.code != 0 {
        logger::log_msg(&format!(
            "has-session: zellij list-sessions failed: {}",
            result.stderr.trim()
        ));
        return 1;
    }

    let found = result
        .stdout
        .lines()
        .any(|line| line.trim() == session_name);

    if found { 0 } else { 1 }
}
