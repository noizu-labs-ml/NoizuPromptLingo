use std::env;
use std::fs;
use std::io::Write;
use std::path::PathBuf;
use std::process;
use std::thread;
use std::time::Duration;

fn state_dir() -> PathBuf {
    let base = env::var("XDG_STATE_HOME")
        .unwrap_or_else(|_| format!("{}/.local/state", env::var("HOME").unwrap_or_default()));
    PathBuf::from(base).join("tabbing")
}

fn pid_file() -> PathBuf {
    state_dir().join("marquee.pid")
}

fn kill_existing() {
    let pidfile = pid_file();
    if let Ok(content) = fs::read_to_string(&pidfile) {
        if let Ok(pid) = content.trim().parse::<u32>() {
            // Try to kill the old process
            libc_kill(pid as i32);
        }
        let _ = fs::remove_file(&pidfile);
    }
}

/// Send SIGTERM to a process. Uses raw syscall to avoid libc dependency.
fn libc_kill(pid: i32) {
    // Use process::Command to send signal portably
    let _ = process::Command::new("kill")
        .arg(pid.to_string())
        .stdout(process::Stdio::null())
        .stderr(process::Stdio::null())
        .status();
}

fn stop_marquee() {
    let pidfile = pid_file();
    if pidfile.is_file() {
        if let Ok(content) = fs::read_to_string(&pidfile) {
            if let Ok(pid) = content.trim().parse::<u32>() {
                // Check if process is alive, then kill
                let alive = process::Command::new("kill")
                    .args(["-0", &pid.to_string()])
                    .stdout(process::Stdio::null())
                    .stderr(process::Stdio::null())
                    .status()
                    .map(|s| s.success())
                    .unwrap_or(false);

                if alive {
                    libc_kill(pid as i32);
                    println!("tabbing-marquee: stopped (pid {})", pid);
                } else {
                    println!("tabbing-marquee: no running marquee found");
                }
            }
            let _ = fs::remove_file(&pidfile);
        }
    } else {
        println!("tabbing-marquee: no running marquee found");
    }
}

fn print_usage() {
    println!("Usage: tabbing-marquee [options] \"text\"");
    println!();
    println!("Options:");
    println!("  -w, --width N    Visible width (default: 20)");
    println!("  -d, --delay S    Frame delay in seconds (default: 0.2)");
    println!("  --stop           Stop running marquee");
}

/// The actual scrolling loop. Called either directly or via --marquee-loop hidden arg.
fn marquee_loop(text: &str, width: usize, delay_secs: f64) {
    let padded = format!("{}    ", text);
    let chars: Vec<char> = padded.chars().collect();
    let len = chars.len();
    let mut offset: usize = 0;

    // Write PID file
    let pidfile = pid_file();
    let _ = fs::create_dir_all(pidfile.parent().unwrap());
    if let Ok(mut f) = fs::File::create(&pidfile) {
        let _ = write!(f, "{}", process::id());
    }

    // Install a cleanup on exit — best effort via ctrlc-like approach.
    // Since we can't depend on external crates, we just loop and clean up
    // if the write to tty fails (terminal closed).

    let delay = Duration::from_secs_f64(delay_secs);

    loop {
        // Build visible window by wrapping
        let visible: String = (0..width).map(|i| chars[(offset + i) % len]).collect();

        // OSC 0 — set window/tab title
        // Write to /dev/tty if available, else stdout
        let output = format!("\x1b]0;{}\x07", visible);
        let write_ok = if let Ok(mut tty) = fs::OpenOptions::new().write(true).open("/dev/tty") {
            tty.write_all(output.as_bytes()).is_ok()
        } else {
            let mut stdout = std::io::stdout();
            stdout.write_all(output.as_bytes()).is_ok() && stdout.flush().is_ok()
        };

        if !write_ok {
            // Terminal gone, clean up
            let _ = fs::remove_file(&pidfile);
            break;
        }

        offset = (offset + 1) % len;
        thread::sleep(delay);
    }
}

pub fn run_marquee(args: &[String]) {
    let mut width: usize = 20;
    let mut delay: f64 = 0.2;
    let mut text = String::new();
    let mut do_stop = false;
    let mut is_loop_mode = false;

    let mut i = 0;
    while i < args.len() {
        match args[i].as_str() {
            "--stop" => {
                do_stop = true;
            }
            "--marquee-loop" => {
                // Hidden internal arg: run the loop directly (we are the background child)
                is_loop_mode = true;
            }
            "-w" | "--width" => {
                i += 1;
                if i < args.len() {
                    width = args[i].parse().unwrap_or(20);
                }
            }
            a if a.starts_with("-w=") || a.starts_with("--width=") => {
                let val = a.split_once('=').map(|(_, v)| v).unwrap_or("20");
                width = val.parse().unwrap_or(20);
            }
            "-d" | "--delay" => {
                i += 1;
                if i < args.len() {
                    delay = args[i].parse().unwrap_or(0.2);
                }
            }
            a if a.starts_with("-d=") || a.starts_with("--delay=") => {
                let val = a.split_once('=').map(|(_, v)| v).unwrap_or("0.2");
                delay = val.parse().unwrap_or(0.2);
            }
            "-h" | "--help" => {
                print_usage();
                return;
            }
            a if a.starts_with('-') && a != "-" => {
                eprintln!("tabbing-marquee: unknown option: {}", a);
                process::exit(1);
            }
            _ => {
                text = args[i].clone();
            }
        }
        i += 1;
    }

    // Handle --stop
    if do_stop {
        stop_marquee();
        return;
    }

    // Hidden loop mode — we ARE the background child
    if is_loop_mode {
        if text.is_empty() {
            process::exit(1);
        }
        marquee_loop(&text, width, delay);
        return;
    }

    // Normal invocation: validate text, kill old, spawn background child
    if text.is_empty() {
        eprintln!("tabbing-marquee: no text provided");
        print_usage();
        process::exit(1);
    }

    // Kill any existing marquee
    kill_existing();

    // Spawn self as a detached background process with --marquee-loop
    let exe = env::current_exe().unwrap_or_else(|_| PathBuf::from("tabbing-marquee"));
    let mut cmd = process::Command::new(&exe);
    cmd.arg("--marquee-loop")
        .arg("-w")
        .arg(width.to_string())
        .arg("-d")
        .arg(format!("{}", delay))
        .arg(&text)
        .stdin(process::Stdio::null())
        .stdout(process::Stdio::null())
        .stderr(process::Stdio::null());

    // If the binary is multi-call (argv0-based dispatch), we need to ensure
    // the subprocess also routes to marquee. Pass argv[0] hint via env.
    cmd.env("TABBING_MARQUEE_MODE", "1");

    match cmd.spawn() {
        Ok(child) => {
            let pid = child.id();
            // Write pid file (the child also writes it, but write here for immediate feedback)
            let pidfile = pid_file();
            let _ = fs::create_dir_all(pidfile.parent().unwrap());
            if let Ok(mut f) = fs::File::create(&pidfile) {
                let _ = write!(f, "{}", pid);
            }
            println!(
                "tabbing-marquee: running (pid {}, width {}, delay {})",
                pid, width, delay
            );
            println!("tabbing-marquee: stop with: tabbing-marquee --stop");
        }
        Err(e) => {
            eprintln!("tabbing-marquee: failed to spawn background process: {}", e);
            process::exit(1);
        }
    }
}
