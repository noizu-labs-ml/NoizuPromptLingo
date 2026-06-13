use std::env;
use std::thread;
use std::time::{Duration, Instant, SystemTime};

use crate::{logger, zellij_bridge};

const DEFAULT_TIMEOUT_MS: u64 = 3000;
const POLL_INTERVAL_MS: u64 = 100;
const RECENCY_THRESHOLD_SECS: u64 = 5;

const DEFAULT_PROMPT_PATTERN: &str = r"[\$#>❯%]\s*$";

/// Check if a pane was created recently enough to need prompt-readiness waiting.
pub fn is_recently_created(created_at_epoch: u64) -> bool {
    let now = SystemTime::now()
        .duration_since(SystemTime::UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0);
    now.saturating_sub(created_at_epoch) < RECENCY_THRESHOLD_SECS
}

/// Wait until the pane shows a shell prompt (or timeout).
/// Returns true if prompt was detected, false if timed out.
pub fn wait_for_prompt(zellij_pane_id: &str) -> bool {
    let timeout_ms = env::var("ZELLIJ_CCT_READY_TIMEOUT_MS")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(DEFAULT_TIMEOUT_MS);

    let pattern = env::var("ZELLIJ_CCT_READY_PATTERN")
        .unwrap_or_else(|_| DEFAULT_PROMPT_PATTERN.to_string());

    let deadline = Instant::now() + Duration::from_millis(timeout_ms);
    let poll_interval = Duration::from_millis(POLL_INTERVAL_MS);

    logger::log_msg(&format!(
        "ready-wait: polling {zellij_pane_id} for prompt (timeout={timeout_ms}ms pattern={pattern})"
    ));

    let mut attempts = 0;
    loop {
        if Instant::now() >= deadline {
            logger::log_msg(&format!(
                "ready-wait: timeout after {attempts} attempts on {zellij_pane_id}"
            ));
            return false;
        }

        let result = zellij_bridge::action(&[
            "dump-screen", "--pane-id", zellij_pane_id,
        ]);

        if result.code == 0 {
            let screen = result.stdout.trim_end();
            if let Some(last_line) = last_nonempty_line(screen) {
                if matches_prompt(last_line, &pattern) {
                    logger::log_msg(&format!(
                        "ready-wait: prompt detected on {zellij_pane_id} after {attempts} polls"
                    ));
                    return true;
                }
            }
        }

        attempts += 1;
        thread::sleep(poll_interval);
    }
}

fn last_nonempty_line(text: &str) -> Option<&str> {
    text.lines().rev().find(|l| !l.trim().is_empty())
}

fn matches_prompt(line: &str, pattern: &str) -> bool {
    // Simple matching: check if the line ends with any of the prompt characters
    // followed by optional whitespace. We avoid pulling in regex as a dependency
    // and instead do a character-class check that covers the default pattern.
    if pattern == DEFAULT_PROMPT_PATTERN {
        let trimmed = line.trim_end();
        if trimmed.is_empty() {
            return false;
        }
        let last_char = trimmed.chars().last().unwrap();
        matches!(last_char, '$' | '#' | '>' | '❯' | '%')
    } else {
        // For custom patterns, do a simple suffix check.
        // A full regex engine could be added later if needed.
        let trimmed = line.trim_end();
        trimmed.ends_with(pattern.trim())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn detects_bash_prompt() {
        assert!(matches_prompt("user@host:~$ ", DEFAULT_PROMPT_PATTERN));
        assert!(matches_prompt("$ ", DEFAULT_PROMPT_PATTERN));
    }

    #[test]
    fn detects_root_prompt() {
        assert!(matches_prompt("root@host:~# ", DEFAULT_PROMPT_PATTERN));
        assert!(matches_prompt("# ", DEFAULT_PROMPT_PATTERN));
    }

    #[test]
    fn detects_zsh_prompt() {
        assert!(matches_prompt("❯ ", DEFAULT_PROMPT_PATTERN));
        assert!(matches_prompt("~/code ❯", DEFAULT_PROMPT_PATTERN));
    }

    #[test]
    fn detects_fish_prompt() {
        assert!(matches_prompt("user@host ~/code> ", DEFAULT_PROMPT_PATTERN));
    }

    #[test]
    fn rejects_empty_line() {
        assert!(!matches_prompt("", DEFAULT_PROMPT_PATTERN));
        assert!(!matches_prompt("   ", DEFAULT_PROMPT_PATTERN));
    }

    #[test]
    fn rejects_non_prompt() {
        assert!(!matches_prompt("Loading...", DEFAULT_PROMPT_PATTERN));
        assert!(!matches_prompt("Oh My Zsh is being installed", DEFAULT_PROMPT_PATTERN));
    }

    #[test]
    fn last_nonempty_finds_it() {
        assert_eq!(last_nonempty_line("hello\n\n"), Some("hello"));
        assert_eq!(last_nonempty_line("a\nb\n$ "), Some("$ "));
        assert_eq!(last_nonempty_line("\n\n"), None);
    }
}
