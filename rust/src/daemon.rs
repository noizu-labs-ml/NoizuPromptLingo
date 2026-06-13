use std::env;
use std::fs;
use std::path::PathBuf;
use std::process;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::thread;
use std::time::Duration;

use direnv_config::DcClient;

use crate::render;
use crate::state::{self, TabState};
use crate::terminal;

/// Returns the pidfile path for the current session.
fn pidfile(session: &str) -> PathBuf {
    state::state_dir().join(format!("daemon-{}.pid", session))
}

/// Read the PID from the pidfile, if it exists and parses.
fn read_pid(session: &str) -> Option<u32> {
    let path = pidfile(session);
    let content = fs::read_to_string(path).ok()?;
    content.trim().parse::<u32>().ok()
}

/// Check if a PID is alive via `kill -0`.
fn pid_alive(pid: u32) -> bool {
    process::Command::new("kill")
        .args(["-0", &pid.to_string()])
        .stdout(process::Stdio::null())
        .stderr(process::Stdio::null())
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

/// Resolve the dc namespace for this session (matches shell's dc_ns logic).
fn dc_namespace() -> String {
    let uuid = env::var("TABBING_DC_UUID").unwrap_or_default();
    if uuid.is_empty() {
        "tab".to_string()
    } else {
        format!("tab-{}", uuid)
    }
}

/// Build a TabState from dc key/value pairs.
fn state_from_dc(client: &DcClient, ns: &str) -> TabState {
    let get = |key: &str| -> String {
        client
            .get_string(ns, key)
            .unwrap_or_default()
            .unwrap_or_default()
    };

    TabState {
        title: get("title"),
        status: get("status"),
        highlight: get("highlight"),
        urgency: get("urgency"),
        emoji: get("emoji"),
        bg: get("bg"),
        theme: get("theme"),
        marquee: get("marquee") == "1",
        ..TabState::default()
    }
}

// ── The core polling loop ──────────────────────────────────────────

fn daemon_loop(running: Arc<AtomicBool>) {
    let session = env::var("TAB_SESSION").unwrap_or_default();
    if session.is_empty() {
        eprintln!("tabbing-daemon: TAB_SESSION not set");
        process::exit(1);
    }

    let dc_ns = dc_namespace();

    let client = match DcClient::new(None) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("tabbing-daemon: failed to connect to dc: {}", e);
            process::exit(1);
        }
    };

    let t = terminal::detect();
    let tty = env::var("TABBING_TTY").unwrap_or_else(|_| "/dev/tty".to_string());

    let max_status: usize = 20;
    let max_title: usize = 25;

    let mut last_update = String::new();
    let mut marquee_offset: usize = 0;
    let mut cached_state = TabState::default();

    // Write pidfile for this session
    let pf = pidfile(&session);
    let _ = fs::create_dir_all(pf.parent().unwrap_or(&state::state_dir()));
    let _ = fs::write(&pf, format!("{}", process::id()));

    // Install cleanup on exit: clear title, remove pidfile
    let cleanup_pf = pf.clone();
    let cleanup_tty = tty.clone();
    let _cleanup_running = running.clone();

    // Use ctrlc-style handler via atomic flag — no extra crate needed.
    // The process will be killed externally (SIGTERM from `stop`),
    // and we clean up in the loop exit.

    while running.load(Ordering::Relaxed) {
        thread::sleep(Duration::from_millis(200));

        // Fast check: has the dc timestamp changed?
        let cur_update = client
            .get_string(&dc_ns, "last_update")
            .unwrap_or_default()
            .unwrap_or_default();

        if cur_update.is_empty() {
            continue;
        }

        if cur_update == last_update {
            // No data change — but if marquee is active, advance scroll
            let status_len = cached_state.status.chars().count();
            if cached_state.marquee && status_len > max_status && !cached_state.status.is_empty() {
                marquee_offset = (marquee_offset + 1) % (status_len + 4);
                render_marquee(&cached_state, marquee_offset, max_title, max_status, &tty);
            }
            continue;
        }

        // State changed — reload from dc
        last_update = cur_update;
        marquee_offset = 0;
        cached_state = state_from_dc(&client, &dc_ns);

        let status_len = cached_state.status.chars().count();
        if cached_state.marquee && status_len > max_status {
            render_marquee(&cached_state, marquee_offset, max_title, max_status, &tty);
        } else {
            render_static(&cached_state, max_title, &tty);
            render::apply_urgency_color(&cached_state, &t);
        }
    }

    // Cleanup
    clear_title(&cleanup_tty);
    let _ = fs::remove_file(&cleanup_pf);
}

// ── Rendering helpers ──────────────────────────────────────────────

fn truncate_title(title: &str, max: usize) -> String {
    if title.chars().count() > max {
        let mut t: String = title.chars().take(max - 1).collect();
        t.push('\u{2026}');
        t
    } else {
        title.to_string()
    }
}

fn render_static(state: &TabState, max_title: usize, tty: &str) {
    let t_title = truncate_title(&state.title, max_title);
    let dot = render::get_indicator(state);
    let prefix = if dot.is_empty() {
        String::new()
    } else {
        format!("{} ", dot)
    };

    let output = if state.status.is_empty() {
        format!("{}{}", prefix, t_title)
    } else {
        format!("{}{}: {}", prefix, t_title, state.status)
    };

    write_title_to_tty(&output, tty);
}

fn render_marquee(
    state: &TabState,
    offset: usize,
    max_title: usize,
    width: usize,
    tty: &str,
) {
    let t_title = truncate_title(&state.title, max_title);
    let dot = render::get_indicator(state);
    let prefix = if dot.is_empty() {
        format!("{}: ", t_title)
    } else {
        format!("{} {}: ", dot, t_title)
    };

    // Pad status with spaces for wraparound scrolling
    let padded = format!("{}    ", state.status);
    let padded_chars: Vec<char> = padded.chars().collect();
    let padded_len = padded_chars.len();

    let mut visible = String::with_capacity(width);
    for i in 0..width {
        let pos = (offset + i) % padded_len;
        visible.push(padded_chars[pos]);
    }

    let output = format!("{}{}", prefix, visible);
    write_title_to_tty(&output, tty);
}

fn write_title_to_tty(title: &str, tty: &str) {
    // Write OSC 0 title sequence directly to the tty
    if let Ok(mut f) = fs::OpenOptions::new().write(true).open(tty) {
        use std::io::Write;
        let _ = write!(f, "\x1b]0;{}\x07", title);
        let _ = f.flush();
    }
}

fn clear_title(tty: &str) {
    write_title_to_tty("", tty);
}

// ── Subcommands ────────────────────────────────────────────────────

fn cmd_start(session: &str) {
    // Check if already running
    if let Some(pid) = read_pid(session) {
        if pid_alive(pid) {
            eprintln!("tabbing-daemon: already running (pid {})", pid);
            return;
        }
        // Stale pidfile — remove it
        let _ = fs::remove_file(pidfile(session));
    }

    // Spawn self as background process with "run" subcommand
    let exe = match env::current_exe() {
        Ok(e) => e,
        Err(e) => {
            eprintln!("tabbing-daemon: cannot resolve own path: {}", e);
            process::exit(1);
        }
    };

    // Build the argv0-style invocation. Since we dispatch on argv0,
    // we need the symlink name "tabbing-daemon" to be used.
    // But current_exe() resolves to the real binary. We need to find
    // the symlink in the same directory, or just pass "run" and let
    // the dispatch handle it via the actual binary name.
    //
    // Simpler approach: use the real binary path and pass a hidden
    // flag so main.rs can route it. But the task spec says to use
    // argv0 dispatch. Let's find the tabbing-daemon symlink.
    let daemon_link = exe.parent().unwrap_or(std::path::Path::new(".")).join("tabbing-daemon");
    let spawn_exe = if daemon_link.exists() {
        daemon_link
    } else {
        // Fallback: use self with env hint
        exe.clone()
    };

    match process::Command::new(&spawn_exe)
        .arg("run")
        .stdin(process::Stdio::null())
        .stdout(process::Stdio::null())
        .stderr(process::Stdio::null())
        .spawn()
    {
        Ok(child) => {
            let pid = child.id();
            // Write pidfile immediately so `status` works right away
            let pf = pidfile(session);
            let _ = fs::create_dir_all(pf.parent().unwrap_or(&state::state_dir()));
            let _ = fs::write(&pf, format!("{}", pid));

            let tty = env::var("TABBING_TTY").unwrap_or_else(|_| "(unknown)".to_string());
            eprintln!("tabbing-daemon: started (pid {}, tty {})", pid, tty);

            // Export the daemon PID so dc_save() can signal it with USR1
            println!("export TABBING_DC_DAEMON_PID='{}'", pid);
        }
        Err(e) => {
            eprintln!("tabbing-daemon: failed to spawn: {}", e);
            process::exit(1);
        }
    }
}

fn cmd_stop(session: &str) {
    let pf = pidfile(session);
    if !pf.exists() {
        eprintln!("tabbing-daemon: not running");
        return;
    }

    match read_pid(session) {
        Some(pid) => {
            if pid_alive(pid) {
                let _ = process::Command::new("kill")
                    .arg(pid.to_string())
                    .stdout(process::Stdio::null())
                    .stderr(process::Stdio::null())
                    .status();
                eprintln!("tabbing-daemon: stopped (pid {})", pid);
            } else {
                eprintln!("tabbing-daemon: stale pidfile (pid {} not running)", pid);
            }
            let _ = fs::remove_file(&pf);
        }
        None => {
            eprintln!("tabbing-daemon: corrupt pidfile");
            let _ = fs::remove_file(&pf);
        }
    }

    println!("unset TABBING_DC_DAEMON_PID");
}

fn cmd_status(session: &str) {
    match read_pid(session) {
        Some(pid) if pid_alive(pid) => {
            let tty = env::var("TABBING_TTY").unwrap_or_else(|_| "(unknown)".to_string());
            eprintln!("tabbing-daemon: running (pid {})", pid);
            eprintln!("  TABBING_TTY={}", tty);
            eprintln!("  poll_interval=0.2s");
        }
        _ => {
            eprintln!("tabbing-daemon: not running");
        }
    }
}

fn cmd_run() {
    let running = Arc::new(AtomicBool::new(true));
    // No signal handler crate — process will be killed via SIGTERM from `stop`.
    // The AtomicBool is here so we can add a handler later if needed,
    // and so the loop has a clean shutdown path.
    daemon_loop(running);
}

// ── Public entry point ─────────────────────────────────────────────

pub fn run_daemon(args: &[String]) {
    let session = env::var("TAB_SESSION").unwrap_or_default();
    if session.is_empty() {
        eprintln!("tabbing-daemon: TAB_SESSION not set — call tabbing-on first");
        process::exit(1);
    }

    let subcmd = args.first().map(|s| s.as_str()).unwrap_or("status");

    match subcmd {
        "start" => cmd_start(&session),
        "stop" => cmd_stop(&session),
        "status" => cmd_status(&session),
        "run" => cmd_run(),
        "--version" | "-V" => {
            println!("tabbing-daemon {}", crate::VERSION);
        }
        _ => {
            eprintln!("Usage: tabbing-daemon {{start|stop|status|run}}");
            process::exit(1);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_pidfile_path_contains_session() {
        let path = pidfile("test-session-123");
        let s = path.to_string_lossy();
        assert!(s.contains("daemon-test-session-123.pid"), "path was: {}", s);
    }

    #[test]
    fn test_dc_namespace() {
        env::remove_var("TABBING_DC_UUID");
        assert_eq!(dc_namespace(), "tab");
        env::set_var("TABBING_DC_UUID", "abc123");
        assert_eq!(dc_namespace(), "tab-abc123");
        env::remove_var("TABBING_DC_UUID");
    }

    #[test]
    fn test_truncate_title_short() {
        assert_eq!(truncate_title("hello", 25), "hello");
    }

    #[test]
    fn test_truncate_title_exact() {
        let t = "a".repeat(25);
        assert_eq!(truncate_title(&t, 25), t);
    }

    #[test]
    fn test_truncate_title_long() {
        let t = "a".repeat(30);
        let result = truncate_title(&t, 25);
        assert_eq!(result.chars().count(), 25);
        assert!(result.ends_with('\u{2026}'));
    }

    #[test]
    fn test_pid_alive_nonexistent() {
        // PID 999999 should not exist
        assert!(!pid_alive(999999));
    }

    #[test]
    fn test_read_pid_missing_file() {
        assert!(read_pid("nonexistent-session-xyz").is_none());
    }
}
