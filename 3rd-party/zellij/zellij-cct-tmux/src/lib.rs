pub mod commands;
pub mod dispatch;
pub mod format;
pub mod idmap;
pub mod keys;
pub mod logger;
pub mod ready_wait;
pub mod tab_resolve;
pub mod zellij_bridge;

use std::env;
use std::process;

pub fn run() {
    let args: Vec<String> = env::args().collect();
    let argv0 = args
        .first()
        .and_then(|a| std::path::Path::new(a).file_name())
        .and_then(|n| n.to_str())
        .unwrap_or("zellij-tmux-shim");

    let is_shim_mode = matches!(argv0, "tmux" | "zellij-tmux-shim" | "zellij-cct-tmux");

    if !is_shim_mode {
        eprintln!("zellij-tmux-shim: tmux compatibility shim for Zellij");
        eprintln!("Usage: symlink this binary as 'tmux' and invoke from within a Zellij session");
        eprintln!("       or set ZELLIJ_TMUX_COMPAT=1 in your environment");
        process::exit(1);
    }

    let compat = env::var("ZELLIJ_TMUX_COMPAT").as_deref() == Ok("1");
    let in_zellij = env::var("ZELLIJ").is_ok();
    if !(compat && in_zellij) {
        exec_real_tmux(&args[1..]);
    }

    let raw_args: Vec<&str> = args.iter().skip(1).map(|s| s.as_str()).collect();
    logger::init();
    logger::log_invocation(&raw_args);

    let (global_flags, subcmd_args) = dispatch::strip_global_flags(&raw_args);
    let exit_code = dispatch::run(&global_flags, &subcmd_args);
    process::exit(exit_code);
}

fn exec_real_tmux(args: &[String]) -> ! {
    let paths = env::var("PATH").unwrap_or_default();
    let self_exe = env::current_exe().ok();
    let self_canonical = self_exe.as_ref().and_then(|p| p.canonicalize().ok());

    for dir in env::split_paths(&paths) {
        let candidate = dir.join("tmux");
        if !candidate.exists() {
            continue;
        }
        let candidate_canonical = candidate.canonicalize().ok();
        if let (Some(ref sc), Some(ref cc)) = (&self_canonical, &candidate_canonical) {
            if sc == cc {
                continue;
            }
        }
        let status = process::Command::new(&candidate)
            .args(args)
            .status()
            .unwrap_or_else(|e| {
                eprintln!("zellij-tmux-shim: failed to exec {}: {}", candidate.display(), e);
                process::exit(127);
            });
        process::exit(status.code().unwrap_or(1));
    }

    eprintln!("zellij-tmux-shim: no real tmux found in PATH");
    process::exit(127);
}
