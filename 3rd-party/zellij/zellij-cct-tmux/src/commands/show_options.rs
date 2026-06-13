use crate::logger;

/// tmux show-options / show [-gv] <option>
/// Claude Code queries `show -gv focus-events` and `show -Av mouse`.
pub fn run(args: &[&str]) -> i32 {
    let mut option_name: Option<&str> = None;
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-g" | "-v" | "-A" | "-gv" | "-Av" => {}
            s if !s.starts_with('-') => {
                option_name = Some(s);
            }
            _ => {}
        }
        i += 1;
    }

    match option_name {
        Some("focus-events") => {
            println!("on");
            0
        }
        Some("mouse") => {
            println!("on");
            0
        }
        Some(opt) => {
            logger::log_msg(&format!("show-options: unknown option {opt}, returning empty"));
            0
        }
        None => {
            logger::log_msg("show-options: no option name provided");
            0
        }
    }
}
