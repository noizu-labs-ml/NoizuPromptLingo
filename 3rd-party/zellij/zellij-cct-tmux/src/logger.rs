use std::env;
use std::fs::{self, OpenOptions};
use std::io::Write;
use std::path::PathBuf;
use std::time::SystemTime;

fn log_dir() -> PathBuf {
    let session = env::var("ZELLIJ_SESSION_NAME").unwrap_or_else(|_| "unknown".into());
    let base = env::var("XDG_RUNTIME_DIR")
        .or_else(|_| env::var("TMPDIR"))
        .unwrap_or_else(|_| "/tmp".into());
    PathBuf::from(base).join("zellij-cct").join(&session)
}

fn log_path() -> PathBuf {
    log_dir().join("tmux-shim.log")
}

fn unknown_log_path() -> PathBuf {
    PathBuf::from("/var/log/zellij/tmux-compat.log")
}

fn timestamp() -> u64 {
    SystemTime::now()
        .duration_since(SystemTime::UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0)
}

pub fn init() {
    let dir = log_dir();
    let _ = fs::create_dir_all(&dir);
}

pub fn log_invocation(args: &[&str]) {
    let path = log_path();
    let Ok(mut f) = OpenOptions::new().create(true).append(true).open(&path) else {
        return;
    };
    let _ = writeln!(f, "[{}] tmux {}", timestamp(), args.join(" "));
}

pub fn log_msg(msg: &str) {
    if env::var("ZELLIJ_CCT_DEBUG").unwrap_or_default() != "1" {
        return;
    }
    let path = log_path();
    let Ok(mut f) = OpenOptions::new().create(true).append(true).open(&path) else {
        return;
    };
    let _ = writeln!(f, "[{}] {msg}", timestamp());
}

pub fn log_unimplemented(subcmd: &str, args: &[&str]) {
    log_msg(&format!("UNIMPLEMENTED: tmux {subcmd} {}", args.join(" ")));
}

pub fn log_unknown(subcmd: &str, args: &[&str]) {
    let session = env::var("ZELLIJ_SESSION_NAME").unwrap_or_else(|_| "unknown".into());
    let line = format!(
        "[{}] session={} UNKNOWN: tmux {} {}",
        timestamp(),
        session,
        subcmd,
        args.join(" ")
    );

    log_msg(&line);

    let path = unknown_log_path();
    if let Some(parent) = path.parent() {
        let _ = fs::create_dir_all(parent);
    }
    if let Ok(mut f) = OpenOptions::new().create(true).append(true).open(&path) {
        let _ = writeln!(f, "{line}");
    }
}
