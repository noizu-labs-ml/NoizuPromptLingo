use anyhow::Result;
use colored::Colorize;

use crate::cli::{ViewDcArgs, ViewDcFormat};
use crate::dc::{find_envrc_dc, parse_envrc_dc, DcDirective, dc_get_optional};

pub fn run(args: ViewDcArgs) -> Result<()> {
    let path = if let Some(f) = &args.file {
        std::path::PathBuf::from(f)
    } else {
        find_envrc_dc()?
    };

    eprintln!("Reading: {}", path.display());

    let mut directives = parse_envrc_dc(&path)?;

    // Apply filters
    if let Some(scope_filter) = &args.scope {
        directives.retain(|d| &d.scope == scope_filter);
    }
    if let Some(path_filter) = &args.path {
        directives.retain(|d| d.item_path.contains(path_filter.as_str()));
    }

    if directives.is_empty() {
        eprintln!("No matching dc get directives found");
        return Ok(());
    }

    // Optionally resolve values
    let values: Vec<Option<String>> = if args.show_values {
        directives
            .iter()
            .map(|d| dc_get_optional(&d.scope, &d.item_path))
            .collect()
    } else {
        vec![None; directives.len()]
    };

    match args.format {
        ViewDcFormat::Json => {
            let items: Vec<serde_json::Value> = directives
                .iter()
                .zip(values.iter())
                .map(|(d, v)| {
                    serde_json::json!({
                        "line_number": d.line_number,
                        "scope": d.scope,
                        "item_path": d.item_path,
                        "value": v
                    })
                })
                .collect();
            println!("{}", serde_json::to_string_pretty(&items)?);
        }
        ViewDcFormat::Table => {
            print_table(&directives, &values, args.show_values);
        }
    }

    eprintln!("Total: {} directive(s)", directives.len());
    Ok(())
}

fn print_table(directives: &[DcDirective], values: &[Option<String>], show_values: bool) {
    let line_w = 6usize;
    let scope_w = 12usize;
    let path_w = 40usize;
    let val_w = 30usize;

    // Header
    print!("{:<line_w$} {:<scope_w$} {:<path_w$}", "Line", "Scope", "Item Path");
    if show_values {
        print!(" {:<val_w$}", "Value");
    }
    println!();

    // Separator
    print!(
        "{:<line_w$} {:<scope_w$} {:<path_w$}",
        "-".repeat(line_w),
        "-".repeat(scope_w),
        "-".repeat(path_w)
    );
    if show_values {
        print!(" {:<val_w$}", "-".repeat(val_w));
    }
    println!();

    for (d, v) in directives.iter().zip(values.iter()) {
        let item_path = if d.item_path.len() > path_w {
            format!("{}…", &d.item_path[..path_w - 1])
        } else {
            d.item_path.clone()
        };

        print!(
            "{:<line_w$} {:<scope_w$} {:<path_w$}",
            d.line_number.to_string().dimmed(),
            d.scope.cyan().to_string(),
            item_path
        );

        if show_values {
            let display = match v {
                None => "—".dimmed().to_string(),
                Some(val) => {
                    if val.len() > val_w {
                        format!("{}…", &val[..val_w - 1])
                    } else {
                        val.clone()
                    }
                }
            };
            print!(" {:<val_w$}", display);
        }
        println!();
    }
}
