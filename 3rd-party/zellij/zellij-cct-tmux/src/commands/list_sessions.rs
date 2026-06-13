use crate::zellij_bridge;

/// tmux list-sessions [-F <format>]
pub fn run(_args: &[&str]) -> i32 {
    let result = zellij_bridge::command(&["list-sessions"]);
    if result.code != 0 {
        return 1;
    }
    print!("{}", result.stdout);
    0
}
