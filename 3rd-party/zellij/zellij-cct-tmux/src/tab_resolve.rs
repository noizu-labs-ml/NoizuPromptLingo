use crate::{logger, zellij_bridge};

pub struct ResolvedTab {
    pub position: u32,
    pub name: String,
}

/// Resolve a tmux window target (numeric index or tab name) to a zellij tab.
pub fn resolve(target: &str) -> Option<ResolvedTab> {
    let tabs = query_tabs()?;

    if let Ok(index) = target.parse::<u32>() {
        return tabs.into_iter().find(|t| t.position == index);
    }

    tabs.into_iter().find(|t| t.name == target)
}

pub fn query_tabs() -> Option<Vec<ResolvedTab>> {
    let result = zellij_bridge::action(&["list-tabs", "--json"]);
    if result.code == 0 {
        if let Ok(json) = serde_json::from_str::<Vec<serde_json::Value>>(&result.stdout) {
            return Some(
                json.iter()
                    .filter_map(|tab| {
                        let name = tab.get("name")?.as_str()?.to_string();
                        let position = tab.get("position")?.as_u64()? as u32;
                        Some(ResolvedTab { position, name })
                    })
                    .collect(),
            );
        }
    }

    let result = zellij_bridge::action(&["query-tab-names"]);
    if result.code != 0 || result.stderr.contains("not found") {
        logger::log_msg("tab_resolve: both list-tabs and query-tab-names failed");
        return None;
    }

    Some(
        result
            .stdout
            .lines()
            .enumerate()
            .map(|(i, name)| ResolvedTab {
                position: i as u32,
                name: name.trim().to_string(),
            })
            .filter(|t| !t.name.is_empty())
            .collect(),
    )
}
