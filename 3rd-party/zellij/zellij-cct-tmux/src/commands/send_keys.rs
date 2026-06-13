use crate::{idmap, keys, logger, ready_wait, tab_resolve, zellij_bridge};

/// tmux send-keys [-t <target>] [-l] <key>...
pub fn run(args: &[&str]) -> i32 {
    let mut target: Option<&str> = None;
    let mut literal = false;
    let mut key_args: Vec<&str> = Vec::new();
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-t" if i + 1 < args.len() => {
                i += 1;
                target = Some(args[i]);
            }
            "-l" => literal = true,
            _ => key_args.push(args[i]),
        }
        i += 1;
    }

    let bytes = if literal {
        key_args.join("").into_bytes()
    } else {
        keys::translate_args(&key_args)
    };

    if bytes.is_empty() {
        return 0;
    }

    let (zellij_pane_id, tmux_id) = if let Some(t) = target {
        let tmux_id = idmap::parse_tmux_pane_id(t);
        match tmux_id {
            Some(id) => {
                let idmap = idmap::IdMap::load();
                match idmap.to_zellij(id) {
                    Some(z) => (z.to_string(), Some(id)),
                    None => {
                        logger::log_msg(&format!("send-keys: unknown pane %{id}"));
                        eprintln!("can't find pane: {t}");
                        return 1;
                    }
                }
            }
            None => {
                // Not a pane ID — try tab name resolution
                if let Some(resolved) = tab_resolve::resolve(t) {
                    let nav = zellij_bridge::action(&["go-to-tab-name", &resolved.name]);
                    if nav.code != 0 {
                        logger::log_msg(&format!(
                            "send-keys: failed to switch to tab {}",
                            resolved.name
                        ));
                        return 1;
                    }
                    (String::new(), None)
                } else {
                    eprintln!("bad pane id: {t}");
                    return 1;
                }
            }
        }
    } else {
        (String::new(), None)
    };

    // Race fix: if this pane was created recently, wait for shell prompt
    if let Some(id) = tmux_id {
        let idmap = idmap::IdMap::load();
        if let Some(created_at) = idmap.created_at(id) {
            if ready_wait::is_recently_created(created_at) {
                logger::log_msg(&format!(
                    "send-keys: pane %{id} created recently, waiting for prompt"
                ));
                let detected = ready_wait::wait_for_prompt(&zellij_pane_id);
                if !detected {
                    logger::log_msg(&format!(
                        "send-keys: prompt not detected for %{id}, sending anyway"
                    ));
                }
            }
        }
    }

    let bytes_str = String::from_utf8_lossy(&bytes).to_string();

    let action_args = if !zellij_pane_id.is_empty() {
        vec!["write-chars", "--pane-id", &zellij_pane_id, &bytes_str]
    } else {
        vec!["write-chars", &bytes_str]
    };

    let result = zellij_bridge::action(&action_args);
    if result.code != 0 {
        logger::log_msg(&format!(
            "send-keys: zellij write-chars failed: {}",
            result.stderr.trim()
        ));
        return 1;
    }

    0
}
