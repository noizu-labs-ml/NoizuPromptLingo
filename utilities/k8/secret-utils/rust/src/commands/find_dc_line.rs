use anyhow::Result;

use crate::cli::FindDcLineArgs;
use crate::dc::{find_dc_directive, find_envrc_dc};

pub fn run(args: FindDcLineArgs) -> Result<()> {
    let path = if let Some(f) = &args.file {
        std::path::PathBuf::from(f)
    } else {
        find_envrc_dc()?
    };

    let directive = find_dc_directive(&path, &args.scope, &args.item_path)?;

    match directive {
        None => {
            eprintln!("Not found: dc get {} {}", args.scope, args.item_path);
            std::process::exit(1);
        }
        Some(d) => {
            if args.inline {
                let file_prefix = if args.env_path {
                    format!("{}:", path.display())
                } else {
                    String::new()
                };
                println!("{}{}:{}", file_prefix, d.line_number, d.raw_line);
            } else {
                if args.env_path {
                    println!("File: {}", path.display());
                }
                println!("Line: {}", d.line_number);
                println!("Scope: {}", d.scope);
                println!("Path: {}", d.item_path);
                println!("Content: {}", d.raw_line);
                println!();
                println!("Jump hints:");
                println!("  sed -n '{}p' {}", d.line_number, path.display());
                println!("  code -g {}:{}", path.display(), d.line_number);
                println!("  vim +{} {}", d.line_number, path.display());
            }
        }
    }

    Ok(())
}
