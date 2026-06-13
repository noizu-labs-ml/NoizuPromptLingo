use crate::{format, logger, tab_resolve};

/// tmux list-windows [-t <session>] [-F <format>]
pub fn run(args: &[&str]) -> i32 {
    let mut _target: Option<&str> = None;
    let mut fmt: Option<&str> = None;
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-t" if i + 1 < args.len() => {
                i += 1;
                _target = Some(args[i]);
            }
            "-F" if i + 1 < args.len() => {
                i += 1;
                fmt = Some(args[i]);
            }
            _ => {}
        }
        i += 1;
    }

    let tabs = match tab_resolve::query_tabs() {
        Some(t) => t,
        None => {
            logger::log_msg("list-windows: failed to query tabs");
            return 1;
        }
    };

    for tab in &tabs {
        if let Some(template) = fmt {
            let ctx = format::FormatContext {
                window_name: Some(tab.name.clone()),
                window_index: Some(tab.position),
                ..Default::default()
            };
            println!("{}", format::expand(template, &ctx));
        } else {
            println!("{}: {}", tab.position, tab.name);
        }
    }

    0
}
