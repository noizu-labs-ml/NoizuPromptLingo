use crate::{idmap, logger, zellij_bridge};

/// tmux kill-pane [-t <target>]
pub fn run(args: &[&str]) -> i32 {
    let mut target: Option<&str> = None;
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-t" if i + 1 < args.len() => {
                i += 1;
                target = Some(args[i]);
            }
            _ => {}
        }
        i += 1;
    }

    let Some(t) = target else {
        eprintln!("kill-pane: -t <target> required");
        return 1;
    };

    let Some(tmux_id) = idmap::parse_tmux_pane_id(t) else {
        eprintln!("bad pane id: {t}");
        return 1;
    };

    let mut idmap = idmap::IdMap::load();
    let Some(zellij_id) = idmap.to_zellij(tmux_id).map(|s| s.to_string()) else {
        logger::log_msg(&format!("kill-pane: unknown pane %{tmux_id}"));
        return 0; // tmux returns 0 even for nonexistent panes in some cases
    };

    let result = zellij_bridge::action(&["close-pane", "--pane-id", &zellij_id]);
    idmap.tombstone(tmux_id);

    if result.code != 0 {
        logger::log_msg(&format!(
            "kill-pane: zellij close-pane failed: {}",
            result.stderr.trim()
        ));
    }

    0
}
