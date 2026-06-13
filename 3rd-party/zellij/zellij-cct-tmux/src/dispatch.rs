use crate::commands;
use crate::logger;

#[derive(Debug, Default)]
pub struct GlobalFlags {
    pub socket_name: Option<String>,
    pub socket_path: Option<String>,
    pub config_file: Option<String>,
}

/// Strip tmux global flags that appear before the subcommand.
/// Returns (global_flags, remaining_args_after_globals).
pub fn strip_global_flags<'a>(args: &'a [&'a str]) -> (GlobalFlags, Vec<&'a str>) {
    let mut flags = GlobalFlags::default();
    let mut rest = Vec::new();
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-L" if i + 1 < args.len() => {
                flags.socket_name = Some(args[i + 1].to_string());
                i += 2;
            }
            "-S" if i + 1 < args.len() => {
                flags.socket_path = Some(args[i + 1].to_string());
                i += 2;
            }
            "-f" if i + 1 < args.len() => {
                flags.config_file = Some(args[i + 1].to_string());
                i += 2;
            }
            _ => {
                rest = args[i..].to_vec();
                break;
            }
        }
    }

    (flags, rest)
}

pub fn run(global_flags: &GlobalFlags, args: &[&str]) -> i32 {
    if args.is_empty() {
        logger::log_msg("no subcommand provided, exiting 0");
        return 0;
    }

    let subcmd = args[0];
    let subcmd_args = &args[1..];
    let is_socket_scoped = global_flags.socket_name.is_some();

    // Handle flags that look like subcommands
    if subcmd == "-V" || subcmd == "--version" {
        return commands::version::run();
    }

    // Socket-scoped commands (-L <socket>) are virtual state — don't touch real Zellij
    if is_socket_scoped {
        return handle_socket_scoped(subcmd, subcmd_args, global_flags);
    }

    match subcmd {
        // --- Milestone 1: real implementations ---
        "split-window" => commands::split_window::run(subcmd_args),
        "send-keys" => commands::send_keys::run(subcmd_args),
        "kill-pane" => commands::kill_pane::run(subcmd_args),
        "list-panes" => commands::list_panes::run(subcmd_args),
        "display-message" => commands::display_message::run(subcmd_args),
        "has-session" => commands::has_session::run(subcmd_args),

        // --- Milestone 2: session/window/styling ---
        "new-session" => commands::new_session::run(subcmd_args),
        "new-window" => commands::new_window::run(subcmd_args),
        "kill-window" => commands::kill_window::run(subcmd_args),
        "select-window" | "selectw" => commands::select_window::run(subcmd_args),
        "rename-window" => commands::rename_window::run(subcmd_args),
        "list-windows" => commands::list_windows::run(subcmd_args),
        "select-pane" => commands::select_pane::run(subcmd_args),
        "set-option" | "set" => commands::set_option::run(subcmd_args),
        "select-layout" => commands::select_layout::run(subcmd_args),
        "resize-pane" => commands::resize_pane::run(subcmd_args),
        "break-pane" => commands::break_pane::run(subcmd_args),
        "join-pane" => commands::join_pane::run(subcmd_args),

        // --- Milestone 3: additional real handlers ---
        "list-sessions" => commands::list_sessions::run(subcmd_args),
        "capture-pane" => commands::capture_pane::run(subcmd_args),

        // --- Stubs (remaining) ---
        "kill-server" => commands::stub::run(subcmd, subcmd_args),
        "set-environment" | "setenv" => commands::stub::run(subcmd, subcmd_args),
        "display-menu" => commands::stub::run(subcmd, subcmd_args),
        "bind-key" | "bind" => commands::stub::run(subcmd, subcmd_args),
        "unbind-key" | "unbind" => commands::stub::run(subcmd, subcmd_args),
        "set-window-option" | "setw" => commands::stub::run(subcmd, subcmd_args),
        "refresh-client" => commands::stub::run(subcmd, subcmd_args),
        "source-file" | "source" => commands::stub::run(subcmd, subcmd_args),
        "show-options" | "show" => commands::show_options::run(subcmd_args),
        _ => {
            logger::log_unknown(subcmd, subcmd_args);
            commands::stub::run(subcmd, subcmd_args)
        }
    }
}

/// Handle commands issued with `-L <socket>` — these target Claude Code's isolated
/// tmux server for Bash tool PTYs. We maintain virtual state instead of touching Zellij.
fn handle_socket_scoped(subcmd: &str, args: &[&str], _flags: &GlobalFlags) -> i32 {
    logger::log_msg(&format!("socket-scoped: {subcmd} {}", args.join(" ")));
    match subcmd {
        "new-session" => 0,
        "has-session" => {
            // Always claim the session exists for socket-scoped commands
            0
        }
        "kill-server" => 0,
        "set-environment" | "setenv" => 0,
        "display-message" => {
            // Claude Code requests: display-message -p '#{socket_path},#{pid}'
            // Return fabricated values
            let format_str = args.iter().find(|a| a.contains('#'));
            if let Some(fmt) = format_str {
                let ctx = crate::format::FormatContext {
                    socket_path: Some("/tmp/zellij-cct-socket".into()),
                    pid: Some(std::process::id()),
                    ..Default::default()
                };
                println!("{}", crate::format::expand(fmt, &ctx));
            }
            0
        }
        _ => {
            logger::log_msg(&format!(
                "socket-scoped UNIMPLEMENTED: {subcmd} {}",
                args.join(" ")
            ));
            0
        }
    }
}
