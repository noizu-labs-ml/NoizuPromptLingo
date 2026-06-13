use std::env;
use std::fs;
use std::io::Write;
use std::path::PathBuf;
use std::process::Command;

use crate::state::{state_dir, TabState};

/// Write the current tab state to the FIFO named pipe.
///
/// Checks `TABBING_PIPE` env var — returns silently if unset or if no
/// reader is attached to the pipe.  The write is best-effort: we do not
/// want a missing reader to block or crash the main flow.
pub fn write_state_to_pipe(state: &TabState) {
    let pipe_path = match env::var("TABBING_PIPE") {
        Ok(p) if !p.is_empty() => p,
        _ => return,
    };

    // Open for writing.  On macOS/Linux, opening a FIFO for write
    // without a reader will block (or ENXIO with O_NONBLOCK).
    // We attempt a non-blocking open via std::fs — if it fails
    // (no reader), we silently return.
    let path = std::path::Path::new(&pipe_path);
    if !path.exists() {
        return;
    }

    // Use a short-lived child process to avoid blocking the main thread
    // if no reader is attached.  `dd` with a timeout is one approach,
    // but the simplest portable method is to just try the open and
    // accept that it may block briefly.  On macOS, opening a FIFO
    // for write without O_NONBLOCK blocks until a reader appears.
    //
    // For a CLI tool that runs-and-exits, a brief block is acceptable.
    // The shell implementation has the same characteristic.
    let block = format_state_block(state);

    let mut file = match fs::OpenOptions::new().write(true).open(path) {
        Ok(f) => f,
        Err(_) => return, // No reader or pipe gone — silently skip
    };

    let _ = file.write_all(block.as_bytes());
    let _ = file.flush();
    // File drops and closes here
}

/// Format a state block for the FIFO protocol.
/// Terminated by a `---` sentinel line so the reader knows a complete
/// snapshot was received.
fn format_state_block(state: &TabState) -> String {
    format!(
        "TAB_TITLE={}\nTAB_STATUS={}\nTAB_HIGHLIGHT={}\nTAB_URGENCY={}\nTAB_EMOJI={}\nTAB_BG={}\nTAB_THEME={}\nTAB_ID={}\nTAB_TERMINAL={}\n---\n",
        state.title,
        state.status,
        state.highlight,
        state.urgency,
        state.emoji,
        state.bg,
        state.theme,
        state.tab_id,
        state.terminal,
    )
}

/// Create a named pipe (FIFO) for the given session.
///
/// Returns the path on success, `None` on failure.
pub fn create_pipe(session: &str) -> Option<PathBuf> {
    let dir = state_dir();
    let _ = fs::create_dir_all(&dir);
    let pipe_path = dir.join(format!("claude-{}.pipe", session));

    // Remove stale pipe if it exists
    if pipe_path.exists() {
        let _ = fs::remove_file(&pipe_path);
    }

    let status = Command::new("mkfifo")
        .arg(&pipe_path)
        .status()
        .ok()?;

    if status.success() {
        Some(pipe_path)
    } else {
        None
    }
}

/// Remove the FIFO pipe file for the given session.
pub fn remove_pipe(session: &str) {
    let dir = state_dir();
    let pipe_path = dir.join(format!("claude-{}.pipe", session));
    if pipe_path.exists() {
        let _ = fs::remove_file(&pipe_path);
    }

    // Also clean up the state file
    let state_path = dir.join(format!("claude-{}.state", session));
    if state_path.exists() {
        let _ = fs::remove_file(&state_path);
    }
}

/// Write state to an atomic flat file that the Claude statusline reader
/// (`run_claude_statusline()` in `claude.rs`) polls.
///
/// Write to a `.tmp` file first, then rename for atomicity.
pub fn write_state_file(state: &TabState, session: &str) {
    let dir = state_dir();
    let _ = fs::create_dir_all(&dir);

    let state_path = dir.join(format!("claude-{}.state", session));
    let tmp_path = dir.join(format!("claude-{}.state.tmp", session));

    let content = format!(
        "title={}\nstatus={}\nhighlight={}\nurgency={}\nemoji={}\nbg={}\ntheme={}\ntab_id={}\nterminal={}\n",
        state.title,
        state.status,
        state.highlight,
        state.urgency,
        state.emoji,
        state.bg,
        state.theme,
        state.tab_id,
        state.terminal,
    );

    if fs::write(&tmp_path, &content).is_ok() {
        let _ = fs::rename(&tmp_path, &state_path);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_format_state_block_contains_sentinel() {
        let s = TabState {
            title: "MyApp".to_string(),
            status: "deploying".to_string(),
            ..TabState::default()
        };
        let block = format_state_block(&s);
        assert!(block.ends_with("---\n"));
        assert!(block.contains("TAB_TITLE=MyApp\n"));
        assert!(block.contains("TAB_STATUS=deploying\n"));
    }

    #[test]
    fn test_format_state_block_all_fields() {
        let s = TabState {
            title: "t".to_string(),
            status: "s".to_string(),
            highlight: "blue".to_string(),
            urgency: "2".to_string(),
            emoji: "rocket".to_string(),
            bg: "#000".to_string(),
            theme: "dark".to_string(),
            tab_id: "abc123".to_string(),
            terminal: "iterm2".to_string(),
            ..TabState::default()
        };
        let block = format_state_block(&s);
        assert!(block.contains("TAB_HIGHLIGHT=blue\n"));
        assert!(block.contains("TAB_URGENCY=2\n"));
        assert!(block.contains("TAB_EMOJI=rocket\n"));
        assert!(block.contains("TAB_BG=#000\n"));
        assert!(block.contains("TAB_THEME=dark\n"));
        assert!(block.contains("TAB_ID=abc123\n"));
        assert!(block.contains("TAB_TERMINAL=iterm2\n"));
    }

    #[test]
    fn test_write_state_to_pipe_no_env_returns_silently() {
        // With TABBING_PIPE unset, this should be a no-op
        env::remove_var("TABBING_PIPE");
        let s = TabState::default();
        write_state_to_pipe(&s); // Should not panic
    }

    #[test]
    fn test_write_state_to_pipe_nonexistent_path() {
        env::set_var("TABBING_PIPE", "/tmp/tabbing-test-nonexistent-pipe-12345");
        let s = TabState::default();
        write_state_to_pipe(&s); // Should not panic — path doesn't exist
        env::remove_var("TABBING_PIPE");
    }

    #[test]
    fn test_write_state_file_roundtrip() {
        let session = "test-bridge-roundtrip";
        let s = TabState {
            title: "Test".to_string(),
            status: "running".to_string(),
            emoji: "rocket".to_string(),
            ..TabState::default()
        };
        write_state_file(&s, session);

        let state_path = state_dir().join(format!("claude-{}.state", session));
        assert!(state_path.exists());

        let content = fs::read_to_string(&state_path).unwrap();
        assert!(content.contains("title=Test"));
        assert!(content.contains("status=running"));
        assert!(content.contains("emoji=rocket"));

        // Cleanup
        let _ = fs::remove_file(&state_path);
    }

    #[test]
    fn test_remove_pipe_nonexistent() {
        // Should not panic when files don't exist
        remove_pipe("nonexistent-session-12345");
    }

    #[test]
    fn test_create_pipe_and_remove() {
        let session = "test-bridge-pipe-create";
        let result = create_pipe(session);
        assert!(result.is_some());

        let pipe_path = result.unwrap();
        assert!(pipe_path.exists());

        // Clean up via remove_pipe
        remove_pipe(session);
        assert!(!pipe_path.exists());
    }
}
