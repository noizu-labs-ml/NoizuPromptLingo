use crate::format::{self, FormatContext};
use crate::tab_resolve;

/// tmux display-message [-t <target>] [-p] [<format>]
pub fn run(args: &[&str]) -> i32 {
    let mut print_to_stdout = false;
    let mut target: Option<&str> = None;
    let mut template: Option<&str> = None;
    let mut i = 0;

    while i < args.len() {
        match args[i] {
            "-p" => print_to_stdout = true,
            "-t" if i + 1 < args.len() => {
                i += 1;
                target = Some(args[i]);
            }
            _ => {
                if template.is_none() {
                    template = Some(args[i]);
                }
            }
        }
        i += 1;
    }

    let template = template.unwrap_or("");

    let window_name = tab_resolve::query_tabs()
        .and_then(|tabs| tabs.into_iter().next())
        .map(|t| t.name);

    let ctx = if let Some(t) = target {
        let pane_id = if t.starts_with('%') {
            t.to_string()
        } else {
            format!("%{t}")
        };
        FormatContext {
            pane_id: Some(pane_id),
            window_name,
            ..Default::default()
        }
    } else {
        FormatContext {
            window_name,
            ..Default::default()
        }
    };

    let expanded = format::expand(template, &ctx);

    if print_to_stdout {
        println!("{expanded}");
    }

    0
}
