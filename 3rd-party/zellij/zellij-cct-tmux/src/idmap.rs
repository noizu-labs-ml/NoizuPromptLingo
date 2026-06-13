use serde::{Deserialize, Serialize};
use std::env;
use std::fs;
use std::path::PathBuf;
use std::time::SystemTime;

#[derive(Debug, Clone, Serialize, Deserialize)]
struct Entry {
    tmux_id: u32,
    zellij_id: String,
    #[serde(default)]
    tombstoned: bool,
    #[serde(default)]
    created_at: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
struct IdMapData {
    next_id: u32,
    entries: Vec<Entry>,
}

pub struct IdMap {
    data: IdMapData,
    path: PathBuf,
}

impl IdMap {
    pub fn load() -> Self {
        let path = state_path();
        let data = fs::read_to_string(&path)
            .ok()
            .and_then(|s| serde_json::from_str(&s).ok())
            .unwrap_or_default();
        let mut idmap = IdMap { data, path };

        // Seed the leader pane from TMUX_PANE if the idmap is fresh.
        // This reserves ID 0 for the leader so new panes get IDs >= 1.
        if idmap.data.entries.is_empty() {
            let leader_id = env::var("ZELLIJ_PANE_ID")
                .unwrap_or_else(|_| "0".into());
            let zellij_id = format!("terminal_{leader_id}");
            idmap.allocate(&zellij_id);
        }

        idmap
    }

    fn save(&self) {
        if let Some(parent) = self.path.parent() {
            let _ = fs::create_dir_all(parent);
        }
        let _ = fs::write(&self.path, serde_json::to_string_pretty(&self.data).unwrap());
    }

    pub fn allocate(&mut self, zellij_id: &str) -> u32 {
        let tmux_id = self.data.next_id;
        self.data.next_id += 1;
        let now = SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)
            .map(|d| d.as_secs())
            .unwrap_or(0);
        self.data.entries.push(Entry {
            tmux_id,
            zellij_id: zellij_id.to_string(),
            tombstoned: false,
            created_at: now,
        });
        self.save();
        tmux_id
    }

    pub fn tombstone(&mut self, tmux_id: u32) {
        if let Some(entry) = self.data.entries.iter_mut().find(|e| e.tmux_id == tmux_id) {
            entry.tombstoned = true;
            self.save();
        }
    }

    pub fn to_zellij(&self, tmux_id: u32) -> Option<&str> {
        self.data
            .entries
            .iter()
            .find(|e| e.tmux_id == tmux_id && !e.tombstoned)
            .map(|e| e.zellij_id.as_str())
    }

    pub fn to_tmux(&self, zellij_id: &str) -> Option<u32> {
        self.data
            .entries
            .iter()
            .find(|e| e.zellij_id == zellij_id && !e.tombstoned)
            .map(|e| e.tmux_id)
    }

    pub fn created_at(&self, tmux_id: u32) -> Option<u64> {
        self.data
            .entries
            .iter()
            .find(|e| e.tmux_id == tmux_id)
            .map(|e| e.created_at)
    }

    #[allow(dead_code)]
    pub fn all_active(&self) -> Vec<(u32, &str)> {
        self.data
            .entries
            .iter()
            .filter(|e| !e.tombstoned)
            .map(|e| (e.tmux_id, e.zellij_id.as_str()))
            .collect()
    }
}

/// Parse a tmux-style pane target ("%N" or just "N") to the numeric ID.
pub fn parse_tmux_pane_id(target: &str) -> Option<u32> {
    let s = target.strip_prefix('%').unwrap_or(target);
    s.parse().ok()
}

fn state_path() -> PathBuf {
    let session = env::var("ZELLIJ_SESSION_NAME").unwrap_or_else(|_| "unknown".into());
    let base = env::var("XDG_RUNTIME_DIR")
        .or_else(|_| env::var("TMPDIR"))
        .unwrap_or_else(|_| "/tmp".into());
    PathBuf::from(base)
        .join("zellij-cct")
        .join(&session)
        .join("idmap.json")
}
