/// Uniformly operates ZELLIJ* environment variables
use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::{
    collections::{BTreeMap, HashMap},
    env::{set_var, var},
};

use std::fmt;

pub const ZELLIJ_ENV_KEY: &str = "ZELLIJ";
pub fn get_zellij() -> Result<String> {
    Ok(var(ZELLIJ_ENV_KEY)?)
}
pub fn set_zellij(v: String) {
    set_var(ZELLIJ_ENV_KEY, v);
}

pub const SESSION_NAME_ENV_KEY: &str = "ZELLIJ_SESSION_NAME";

pub fn get_session_name() -> Result<String> {
    Ok(var(SESSION_NAME_ENV_KEY)?)
}

pub fn set_session_name(v: String) {
    set_var(SESSION_NAME_ENV_KEY, v);
}

pub const SOCKET_DIR_ENV_KEY: &str = "ZELLIJ_SOCKET_DIR";
pub fn get_socket_dir() -> Result<String> {
    Ok(var(SOCKET_DIR_ENV_KEY)?)
}

pub const TMUX_COMPAT_ENV_KEY: &str = "ZELLIJ_TMUX_COMPAT";
pub fn tmux_compat_enabled() -> bool {
    var(TMUX_COMPAT_ENV_KEY).map(|v| v == "1").unwrap_or(false)
}

pub fn set_tmux_compat_vars(session_name: &str) {
    if tmux_compat_enabled() {
        set_var("TMUX", format!("zellij-cct:{},{},0", session_name, std::process::id()));
    }
}

pub fn set_tmux_compat_pane(terminal_id: u32) {
    if tmux_compat_enabled() {
        set_var("TMUX_PANE", format!("%{}", terminal_id));
    }
}

/// Manage ENVIRONMENT VARIABLES from the configuration and the layout files
#[derive(Default, Clone, PartialEq, Serialize, Deserialize)]
pub struct EnvironmentVariables {
    env: HashMap<String, String>,
}

impl fmt::Debug for EnvironmentVariables {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut stable_sorted = BTreeMap::new();
        for (env_var_name, env_var_value) in self.env.iter() {
            stable_sorted.insert(env_var_name, env_var_value);
        }
        write!(f, "{:#?}", stable_sorted)
    }
}

impl EnvironmentVariables {
    /// Merges two structs, keys from `other` supersede keys from `self`
    pub fn merge(&self, other: Self) -> Self {
        let mut env = self.clone();
        env.env.extend(other.env);
        env
    }
    pub fn from_data(data: HashMap<String, String>) -> Self {
        EnvironmentVariables { env: data }
    }
    /// Set all the ENVIRONMENT VARIABLES, that are configured
    /// in the configuration and layout files
    pub fn set_vars(&self) {
        for (k, v) in &self.env {
            set_var(k, v);
        }
    }
    pub fn inner(&self) -> &HashMap<String, String> {
        &self.env
    }
}
