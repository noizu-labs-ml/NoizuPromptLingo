use std::env;
use std::fs;
use std::path::PathBuf;
use std::process::Command;

use crate::state::state_dir;

/// Return the recordings directory for a tab, creating it if needed.
fn recordings_dir(tab_id: &str) -> PathBuf {
    let dir = state_dir().join("recordings").join(tab_id);
    let _ = fs::create_dir_all(&dir);
    dir
}

/// Generate a recording filename path based on current status.
fn recording_path(tab_id: &str, status: &str) -> PathBuf {
    let dir = recordings_dir(tab_id);
    let timestamp = chrono::Local::now().format("%Y%m%dT%H%M%S").to_string();
    let status_slug: String = status
        .replace(' ', "-")
        .replace('/', "_")
        .chars()
        .filter(|c| c.is_ascii_alphanumeric() || *c == '-' || *c == '_')
        .collect();
    let slug = if status_slug.is_empty() {
        "unknown".to_string()
    } else {
        status_slug
    };
    dir.join(format!("{}_{}.cast", timestamp, slug))
}

/// List .cast files for a tab with their sizes.
pub fn recordings_list(tab_id: &str) {
    let rec_dir = state_dir().join("recordings").join(tab_id);

    if !rec_dir.is_dir() {
        println!("No recordings for tab {}", tab_id);
        return;
    }

    let mut cast_files: Vec<_> = fs::read_dir(&rec_dir)
        .into_iter()
        .flat_map(|rd| rd.filter_map(|e| e.ok()))
        .filter(|e| {
            e.path()
                .extension()
                .and_then(|x| x.to_str())
                == Some("cast")
        })
        .collect();

    if cast_files.is_empty() {
        println!("No recordings for tab {}", tab_id);
        return;
    }

    cast_files.sort_by_key(|e| e.file_name());

    println!("Recordings for tab {}:", tab_id);
    for entry in &cast_files {
        let fname = entry.file_name();
        let fname = fname.to_string_lossy();
        let size = entry.metadata().map(|m| m.len()).unwrap_or(0);
        println!("  {}  ({} bytes)", fname, size);
    }
}

/// Convert a .cast recording to GIF using `agg`.
pub fn recording_to_gif(cast_file: &str, gif_file: &str) {
    // Check agg is available
    if Command::new("agg").arg("--version").output().is_err() {
        eprintln!("tabbing: agg not found");
        eprintln!(
            "tabbing: install it: cargo install --git https://github.com/asciinema/agg"
        );
        return;
    }

    let cast_path = std::path::Path::new(cast_file);
    if !cast_path.is_file() {
        eprintln!("tabbing: recording not found: {}", cast_file);
        return;
    }

    let gif_output = if gif_file.is_empty() {
        // Default: replace .cast with .gif
        cast_file
            .strip_suffix(".cast")
            .map(|s| format!("{}.gif", s))
            .unwrap_or_else(|| format!("{}.gif", cast_file))
    } else {
        gif_file.to_string()
    };

    println!("tabbing: converting {} \u{2192} {}", cast_file, gif_output);

    let status = Command::new("agg")
        .arg(cast_file)
        .arg(&gif_output)
        .status();

    match status {
        Ok(s) if s.success() => {
            println!("tabbing: GIF saved to {}", gif_output);
        }
        Ok(s) => {
            eprintln!(
                "tabbing: agg exited with status {}",
                s.code().unwrap_or(-1)
            );
        }
        Err(e) => {
            eprintln!("tabbing: failed to run agg: {}", e);
        }
    }
}

/// Check if we are currently inside an asciinema recording session.
pub fn is_recording() -> bool {
    env::var("ASCIINEMA_REC").is_ok() || env::var("TAB_RECORDING").is_ok()
}

/// Start an asciinema recording for the given tab.
/// This shells out to `asciinema rec` which spawns a sub-shell.
pub fn record_start(tab_id: &str, status: &str) {
    // Check asciinema is available
    if Command::new("asciinema")
        .arg("--version")
        .output()
        .is_err()
    {
        eprintln!("tabbing: asciinema not found");
        eprintln!(
            "tabbing: install it: https://docs.asciinema.org/manual/cli/installation/"
        );
        return;
    }

    let cast_file = recording_path(tab_id, status);
    let cast_str = cast_file.to_string_lossy().to_string();

    println!("tabbing: recording to {}", cast_str);
    println!("tabbing: type \"exit\" or Ctrl-D to stop recording");

    let result = Command::new("asciinema")
        .arg("rec")
        .arg("--overwrite")
        .arg(&cast_str)
        .status();

    match result {
        Ok(s) if s.success() => {
            println!("tabbing: recording saved to {}", cast_str);
        }
        Ok(s) => {
            eprintln!(
                "tabbing: asciinema exited with status {}",
                s.code().unwrap_or(-1)
            );
        }
        Err(e) => {
            eprintln!("tabbing: failed to run asciinema: {}", e);
        }
    }
}

/// Print a message about stopping the recording.
/// Actual stop requires exiting the asciinema sub-shell.
pub fn record_stop() {
    if !is_recording() {
        eprintln!("tabbing: not currently recording");
        return;
    }

    println!("tabbing: stopping recording");
    if env::var("ASCIINEMA_REC").is_ok() {
        println!("tabbing: exit the asciinema session to finalize the recording");
    }
}
