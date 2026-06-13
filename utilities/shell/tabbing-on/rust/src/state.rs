use std::collections::HashMap;
use std::env;
use std::fs;
use std::path::PathBuf;

use direnv_config::DcClient;

pub fn state_dir() -> PathBuf {
    let base = env::var("XDG_STATE_HOME")
        .unwrap_or_else(|_| format!("{}/.local/state", env::var("HOME").unwrap_or_default()));
    PathBuf::from(base).join("tabbing")
}

#[derive(Debug, Clone, Default)]
pub struct TabState {
    pub title: String,
    pub status: String,
    pub highlight: String,
    pub urgency: String,
    pub emoji: String,
    pub bg: String,
    pub theme: String,
    pub tab_id: String,
    pub session: String,
    pub terminal: String,
    pub marquee: bool,
}

impl TabState {
    pub fn from_env() -> Self {
        Self {
            title: env::var("TAB_TITLE").unwrap_or_default(),
            status: env::var("TAB_STATUS").unwrap_or_default(),
            highlight: env::var("TAB_HIGHLIGHT").unwrap_or_default(),
            urgency: env::var("TAB_URGENCY").unwrap_or_default(),
            emoji: env::var("TAB_EMOJI").unwrap_or_default(),
            bg: env::var("TAB_BG").unwrap_or_default(),
            theme: env::var("TAB_THEME").unwrap_or_default(),
            tab_id: env::var("TAB_ID").unwrap_or_default(),
            session: env::var("TAB_SESSION").unwrap_or_default(),
            terminal: env::var("TAB_TERMINAL").unwrap_or_default(),
            marquee: env::var("TAB_MARQUEE").as_deref() == Ok("1"),
        }
    }

    fn env_is_set(key: &str) -> bool {
        env::var_os(key).is_some()
    }

    pub fn from_session_file(session_id: &str) -> Option<Self> {
        let path = state_dir().join("sessions").join(format!("{}.env", session_id));
        let content = fs::read_to_string(path).ok()?;
        let vars: HashMap<String, String> = content
            .lines()
            .filter_map(|line| {
                let (k, v) = line.split_once('=')?;
                Some((k.to_string(), v.to_string()))
            })
            .collect();

        Some(Self {
            title: vars.get("TAB_TITLE").cloned().unwrap_or_default(),
            status: vars.get("TAB_STATUS").cloned().unwrap_or_default(),
            highlight: vars.get("TAB_HIGHLIGHT").cloned().unwrap_or_default(),
            urgency: vars.get("TAB_URGENCY").cloned().unwrap_or_default(),
            emoji: vars.get("TAB_EMOJI").cloned().unwrap_or_default(),
            bg: vars.get("TAB_BG").cloned().unwrap_or_default(),
            theme: vars.get("TAB_THEME").cloned().unwrap_or_default(),
            tab_id: vars.get("TAB_ID").cloned().unwrap_or_default(),
            session: session_id.to_string(),
            terminal: vars.get("TAB_TERMINAL").cloned().unwrap_or_default(),
            marquee: vars.get("TAB_MARQUEE").map(|v| v == "1").unwrap_or(false),
        })
    }

    /// Backfill from session file, but only for vars not present in the
    /// environment. An env var set to "" (e.g. by direnv's use_tabbing)
    /// is authoritative — it means "explicitly empty", not "unset".
    pub fn load(&mut self) {
        if self.session.is_empty() {
            return;
        }
        if let Some(saved) = Self::from_session_file(&self.session) {
            if !Self::env_is_set("TAB_TITLE") {
                self.title = saved.title;
            }
            if !Self::env_is_set("TAB_STATUS") {
                self.status = saved.status;
            }
            if !Self::env_is_set("TAB_HIGHLIGHT") {
                self.highlight = saved.highlight;
            }
            if !Self::env_is_set("TAB_URGENCY") {
                self.urgency = saved.urgency;
            }
            if !Self::env_is_set("TAB_EMOJI") {
                self.emoji = saved.emoji;
            }
            if !Self::env_is_set("TAB_BG") {
                self.bg = saved.bg;
            }
            if !Self::env_is_set("TAB_THEME") {
                self.theme = saved.theme;
            }
            if !Self::env_is_set("TAB_ID") {
                self.tab_id = saved.tab_id;
            }
            if !Self::env_is_set("TAB_TERMINAL") {
                self.terminal = saved.terminal;
            }
        }
    }

    pub fn save(&self) {
        if self.session.is_empty() {
            return;
        }
        let dir = state_dir().join("sessions");
        let _ = fs::create_dir_all(&dir);
        let path = dir.join(format!("{}.env", self.session));
        let content = format!(
            "TAB_TITLE={}\nTAB_STATUS={}\nTAB_HIGHLIGHT={}\nTAB_URGENCY={}\nTAB_EMOJI={}\nTAB_BG={}\nTAB_THEME={}\nTAB_ID={}\nTAB_TERMINAL={}\nTAB_MARQUEE={}\n",
            self.title, self.status, self.highlight, self.urgency, self.emoji,
            self.bg, self.theme, self.tab_id, self.terminal,
            if self.marquee { "1" } else { "" }
        );
        let _ = fs::write(path, content);

        self.dc_save();
    }

    fn dc_config_name() -> Option<String> {
        if env::var("TABBING_ON_DC_MODE").as_deref() != Ok("1") {
            return None;
        }
        let uuid = env::var("TABBING_DC_UUID").unwrap_or_default();
        if uuid.is_empty() {
            Some("tab".to_string())
        } else {
            Some(format!("tab-{}", uuid))
        }
    }

    fn dc_save(&self) {
        let config_name = match Self::dc_config_name() {
            Some(n) => n,
            None => return,
        };
        let client = match DcClient::new(None) {
            Ok(c) => c,
            Err(_) => return,
        };

        let ts = dc_timestamp();

        let fields: &[(&str, &str)] = &[
            ("title", &self.title),
            ("status", &self.status),
            ("highlight", &self.highlight),
            ("urgency", &self.urgency),
            ("emoji", &self.emoji),
            ("theme", &self.theme),
            ("last_update", &ts),
        ];

        for (key, value) in fields {
            let _ = client.set(&config_name, key, value, None, true);
        }
        let _ = client.bump();

        // Signal the daemon to refresh immediately (SIGUSR1)
        if let Ok(pid_str) = env::var("TABBING_DC_DAEMON_PID") {
            if let Ok(pid) = pid_str.parse::<u32>() {
                let _ = std::process::Command::new("kill")
                    .args(["-USR1", &pid.to_string()])
                    .output();
            }
        }
    }

    pub fn ensure_tab_id(&mut self) {
        if self.tab_id.is_empty() {
            self.tab_id = generate_id();
        }
    }

    pub fn print_exports(&self) {
        println!("export TAB_TITLE='{}'", shell_escape(&self.title));
        println!("export TAB_STATUS='{}'", shell_escape(&self.status));
        println!("export TAB_HIGHLIGHT='{}'", shell_escape(&self.highlight));
        println!("export TAB_URGENCY='{}'", shell_escape(&self.urgency));
        println!("export TAB_EMOJI='{}'", shell_escape(&self.emoji));
        println!("export TAB_BG='{}'", shell_escape(&self.bg));
        println!("export TAB_THEME='{}'", shell_escape(&self.theme));
        println!("export TAB_ID='{}'", shell_escape(&self.tab_id));
        if self.marquee {
            println!("export TAB_MARQUEE=1");
        } else {
            println!("unset TAB_MARQUEE");
        }
        println!("export CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1");
    }
}

fn shell_escape(s: &str) -> String {
    s.replace('\'', "'\\''")
}

fn dc_timestamp() -> String {
    chrono::Local::now().timestamp_millis().to_string()
}

pub fn generate_id() -> String {
    use rand::Rng;
    let mut rng = rand::thread_rng();
    format!("{:08x}", rng.gen::<u32>())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_generate_id_format() {
        let id = generate_id();
        assert_eq!(id.len(), 8);
        assert!(id.chars().all(|c| c.is_ascii_hexdigit()));
    }

    #[test]
    fn test_generate_id_uniqueness() {
        let id1 = generate_id();
        let id2 = generate_id();
        assert_ne!(id1, id2);
    }

    #[test]
    fn test_shell_escape() {
        assert_eq!(shell_escape("hello"), "hello");
        assert_eq!(shell_escape("it's"), "it'\\''s");
        assert_eq!(shell_escape("no quotes"), "no quotes");
    }

    #[test]
    fn test_tab_state_default() {
        let s = TabState::default();
        assert!(s.title.is_empty());
        assert!(s.status.is_empty());
        assert!(s.highlight.is_empty());
        assert!(s.tab_id.is_empty());
        assert!(!s.marquee);
    }

    #[test]
    fn test_ensure_tab_id() {
        let mut s = TabState::default();
        assert!(s.tab_id.is_empty());
        s.ensure_tab_id();
        assert!(!s.tab_id.is_empty());
        assert_eq!(s.tab_id.len(), 8);
    }

    #[test]
    fn test_ensure_tab_id_preserves_existing() {
        let mut s = TabState::default();
        s.tab_id = "existing1".to_string();
        s.ensure_tab_id();
        assert_eq!(s.tab_id, "existing1");
    }

    #[test]
    fn test_state_dir_returns_path() {
        let dir = state_dir();
        assert!(dir.to_string_lossy().contains("tabbing"));
    }
}

pub fn record_event(state: &TabState, event_type: &str) {
    if state.tab_id.is_empty() {
        return;
    }
    let dir = state_dir().join("history");
    let _ = fs::create_dir_all(&dir);
    let path = dir.join(format!("{}.yaml", state.tab_id));
    let ts = chrono::Local::now().format("%Y-%m-%dT%H:%M:%S%z");

    // Write shell-compatible header if the file is new or empty
    let needs_header = !path.exists() || fs::metadata(&path).map(|m| m.len() == 0).unwrap_or(true);
    if needs_header {
        let header = format!(
            "tab_id: \"{}\"\nterminal: \"{}\"\nstarted: \"{}\"\nentries:\n",
            state.tab_id.replace('"', "\\\""),
            state.terminal.replace('"', "\\\""),
            ts
        );
        let _ = fs::write(&path, header);
    }

    // Append entry in shell-compatible format (indented under entries:, event: instead of type:)
    let entry = format!(
        "  - timestamp: \"{}\"\n    event: \"{}\"\n    title: \"{}\"\n    status: \"{}\"\n    emoji: \"{}\"\n    urgency: \"{}\"\n    highlight: \"{}\"\n",
        ts, event_type,
        state.title.replace('"', "\\\""),
        state.status.replace('"', "\\\""),
        state.emoji, state.urgency, state.highlight
    );
    let _ = fs::OpenOptions::new()
        .append(true)
        .open(&path)
        .and_then(|mut f| {
            use std::io::Write;
            f.write_all(entry.as_bytes())
        });
}
