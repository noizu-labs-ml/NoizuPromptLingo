use std::env;
use std::fs;
use std::io::{self, BufRead, Write};
use std::path::PathBuf;

// ANSI helpers
fn bold(s: &str) -> String {
    format!("\x1b[1m{}\x1b[0m", s)
}
fn green(s: &str) -> String {
    format!("\x1b[32m{}\x1b[0m", s)
}
fn yellow(s: &str) -> String {
    format!("\x1b[33m{}\x1b[0m", s)
}

fn check(msg: &str) {
    println!("  [{}] {}", green("OK"), msg);
}
fn warn(msg: &str) {
    println!("  [{}] {}", yellow("!!"), msg);
}
fn info(msg: &str) {
    println!("  [{}] {}", bold(".."), msg);
}

fn ask_yn(prompt: &str) -> bool {
    print!("{} [y/N] ", prompt);
    let _ = io::stdout().flush();
    let stdin = io::stdin();
    let mut line = String::new();
    if stdin.lock().read_line(&mut line).is_err() {
        return false;
    }
    matches!(line.trim().chars().next(), Some('y') | Some('Y'))
}

/// Read a config file and return only non-comment lines.
fn active_lines(path: &PathBuf) -> Option<Vec<String>> {
    let content = fs::read_to_string(path).ok()?;
    Some(
        content
            .lines()
            .filter(|l| {
                let trimmed = l.trim_start();
                !trimmed.starts_with('#')
            })
            .map(|l| l.to_string())
            .collect(),
    )
}

fn ghostty_config_has_title_key(lines: &[String]) -> Option<String> {
    // Match lines like "title = ..." but not "title-report" etc.
    for line in lines {
        let trimmed = line.trim();
        if trimmed.starts_with("title") {
            let rest = &trimmed["title".len()..];
            if rest.starts_with(|c: char| c.is_whitespace() || c == '=') {
                // Extract value after '='
                if let Some(pos) = trimmed.find('=') {
                    let val = trimmed[pos + 1..].trim().to_string();
                    return Some(val);
                }
            }
        }
    }
    None
}

fn lines_contain(lines: &[String], needle: &str) -> bool {
    lines.iter().any(|l| l.contains(needle))
}

fn append_to_config(path: &PathBuf, content: &str) {
    if let Ok(mut f) = fs::OpenOptions::new().append(true).create(true).open(path) {
        let _ = f.write_all(content.as_bytes());
    }
}

fn create_config(path: &PathBuf, content: &str) {
    if let Some(parent) = path.parent() {
        let _ = fs::create_dir_all(parent);
    }
    let _ = fs::write(path, content);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ghostty_config_has_title_key_present() {
        let lines = vec![
            "font-family = JetBrains Mono".to_string(),
            "title = My Terminal".to_string(),
            "theme = catppuccin".to_string(),
        ];
        let result = ghostty_config_has_title_key(&lines);
        assert_eq!(result, Some("My Terminal".to_string()));
    }

    #[test]
    fn test_ghostty_config_has_title_key_absent() {
        let lines = vec![
            "font-family = JetBrains Mono".to_string(),
            "theme = catppuccin".to_string(),
        ];
        let result = ghostty_config_has_title_key(&lines);
        assert_eq!(result, None);
    }

    #[test]
    fn test_ghostty_config_title_report_not_matched() {
        let lines = vec![
            "title-report = full".to_string(),
        ];
        let result = ghostty_config_has_title_key(&lines);
        assert_eq!(result, None);
    }

    #[test]
    fn test_lines_contain() {
        let lines = vec![
            "shell-integration-features = cursor,sudo,no-title".to_string(),
            "font-size = 14".to_string(),
        ];
        assert!(lines_contain(&lines, "no-title"));
        assert!(lines_contain(&lines, "font-size"));
        assert!(!lines_contain(&lines, "nonexistent"));
    }
}

pub fn run_doctor() {
    let home = env::var("HOME").unwrap_or_default();
    let term = env::var("TERM").unwrap_or_default();
    let tab_terminal = env::var("TAB_TERMINAL").unwrap_or_default();
    let term_for_sshd = env::var("TERM_FOR_SSHD").ok();

    println!();
    println!("{}", bold("tabbing-doctor: terminal configuration check"));
    println!();

    // Terminal detection summary
    println!("{}", bold("Detected terminal:"));
    println!(
        "  TAB_TERMINAL = {}",
        if tab_terminal.is_empty() {
            "unknown"
        } else {
            &tab_terminal
        }
    );
    println!(
        "  TERM         = {}",
        if term.is_empty() { "unset" } else { &term }
    );
    println!(
        "  TERM_FOR_SSHD= {}",
        term_for_sshd.as_deref().unwrap_or("unset")
    );
    println!();

    let mut issues: u32 = 0;

    // -----------------------------------------------------------------------
    // Ghostty
    // -----------------------------------------------------------------------
    let xdg_config = env::var("XDG_CONFIG_HOME").unwrap_or_else(|_| format!("{}/.config", home));
    let ghostty_config_macos =
        PathBuf::from(&home).join("Library/Application Support/com.mitchellh.ghostty/config");
    let ghostty_config_xdg = PathBuf::from(&xdg_config).join("ghostty/config");
    let is_ghostty = term == "xterm-ghostty";

    println!("{}", bold("Ghostty"));
    let mut ghostty_found = false;

    for ghostty_config in [&ghostty_config_macos, &ghostty_config_xdg] {
        if ghostty_config.is_file() {
            ghostty_found = true;
            info(&format!("Config found: {}", ghostty_config.display()));

            if let Some(lines) = active_lines(ghostty_config) {
                // Check 1: static "title" key
                if let Some(title_val) = ghostty_config_has_title_key(&lines) {
                    warn(&format!(
                        "\"title = {}\" is set \u{2014} this LOCKS the title and ignores all escape sequences",
                        title_val
                    ));
                    info("Remove or comment out the 'title' line to allow tabbing to set titles");
                    issues += 1;
                }

                // Check 2: shell-integration = none
                let has_si_none = lines.iter().any(|l| {
                    let t = l.trim();
                    t.starts_with("shell-integration")
                        && t.contains('=')
                        && t.contains("none")
                        && !t.contains("shell-integration-features")
                });
                if has_si_none {
                    warn("shell-integration = none \u{2014} shell-integration-features flags are IGNORED (Ghostty bug #5046)");
                    info(
                        "Workaround: export GHOSTTY_SHELL_INTEGRATION_NO_TITLE=1 in your shell rc",
                    );
                    issues += 1;
                }

                // Check 3: shell-integration-features + no-title
                if lines_contain(&lines, "shell-integration-features") {
                    if lines_contain(&lines, "no-title") {
                        check("shell-integration-features includes no-title");
                    } else {
                        warn("shell-integration-features is set but missing no-title");
                        issues += 1;
                        if ask_yn("  Add no-title to shell-integration-features?") {
                            append_to_config(
                                ghostty_config,
                                "\n# Added by tabbing-doctor: prevent shell integration from overriding tab titles\nshell-integration-features = cursor,sudo,path,no-title\n",
                            );
                            check(&format!("Appended to {}", ghostty_config.display()));
                        }
                    }
                } else {
                    warn("shell-integration-features not set (Ghostty will auto-set tab titles)");
                    issues += 1;
                    if ask_yn(
                        "  Add 'shell-integration-features = cursor,sudo,path,no-title' to config?",
                    ) {
                        append_to_config(
                            ghostty_config,
                            "\n# Added by tabbing-doctor: prevent shell integration from overriding tab titles\nshell-integration-features = cursor,sudo,path,no-title\n",
                        );
                        check(&format!("Appended to {}", ghostty_config.display()));
                    }
                }
            }
        }
    }

    if !ghostty_found {
        if is_ghostty {
            // Pick platform-appropriate default path
            let ghostty_config = if cfg!(target_os = "macos") {
                &ghostty_config_macos
            } else {
                &ghostty_config_xdg
            };
            warn("No Ghostty config found (Ghostty will auto-set tab titles)");
            info(&format!("Checked: {}", ghostty_config_macos.display()));
            info(&format!("Checked: {}", ghostty_config_xdg.display()));
            issues += 1;
            if ask_yn(&format!(
                "  Create config with 'shell-integration-features = cursor,sudo,path,no-title' at {}?",
                ghostty_config.display()
            )) {
                create_config(
                    ghostty_config,
                    "# Added by tabbing-doctor: prevent shell integration from overriding tab titles\nshell-integration-features = cursor,sudo,path,no-title\n",
                );
                check(&format!("Created {}", ghostty_config.display()));
            }
        } else {
            info("No Ghostty config found (not running Ghostty, skipped)");
            info(&format!("Checked: {}", ghostty_config_macos.display()));
            info(&format!("Checked: {}", ghostty_config_xdg.display()));
        }
    }

    println!();

    // -----------------------------------------------------------------------
    // Kitty
    // -----------------------------------------------------------------------
    let kitty_config = PathBuf::from(&xdg_config).join("kitty/kitty.conf");
    let is_kitty = term == "xterm-kitty";

    println!("{}", bold("Kitty"));

    if kitty_config.is_file() {
        info(&format!("Config found: {}", kitty_config.display()));

        if let Some(lines) = active_lines(&kitty_config) {
            if lines_contain(&lines, "shell_integration") {
                if lines_contain(&lines, "no-title") {
                    check("shell_integration includes no-title");
                } else {
                    warn("shell_integration is set but missing no-title");
                    issues += 1;
                    if ask_yn("  Add no-title to shell_integration?") {
                        append_to_config(
                            &kitty_config,
                            "\n# Added by tabbing-doctor: prevent shell integration from overriding tab titles\nshell_integration no-title\n",
                        );
                        check(&format!("Appended to {}", kitty_config.display()));
                    }
                }
            } else {
                warn("shell_integration not set (Kitty will auto-set tab titles)");
                issues += 1;
                if ask_yn("  Add 'shell_integration no-title' to config?") {
                    append_to_config(
                        &kitty_config,
                        "\n# Added by tabbing-doctor: prevent shell integration from overriding tab titles\nshell_integration no-title\n",
                    );
                    check(&format!("Appended to {}", kitty_config.display()));
                }
            }
        }
    } else if is_kitty {
        warn(&format!(
            "No config at {} (Kitty will auto-set tab titles)",
            kitty_config.display()
        ));
        issues += 1;
        if ask_yn("  Create config with 'shell_integration no-title'?") {
            create_config(
                &kitty_config,
                "# Added by tabbing-doctor: prevent shell integration from overriding tab titles\nshell_integration no-title\n",
            );
            check(&format!("Created {}", kitty_config.display()));
        }
    } else {
        info(&format!(
            "No config at {} (not running Kitty, skipped)",
            kitty_config.display()
        ));
    }

    println!();

    // -----------------------------------------------------------------------
    // SSH / TERM_FOR_SSHD
    // -----------------------------------------------------------------------
    println!("{}", bold("SSH"));

    if let Some(ref sshd_term) = term_for_sshd {
        check(&format!("TERM_FOR_SSHD is set ({})", sshd_term));

        // Check for ssh wrapper in shell rc files
        let mut ssh_wrapper_found = false;
        let mut found_in = String::new();
        for rc in &[
            format!("{}/.zshrc", home),
            format!("{}/.bashrc", home),
            format!("{}/.profile", home),
        ] {
            if let Ok(content) = fs::read_to_string(rc) {
                let has_wrapper = content.lines().any(|l| {
                    let trimmed = l.trim();
                    if trimmed.starts_with('#') {
                        return false;
                    }
                    trimmed.contains("ssh()") || trimmed.contains("function ssh")
                });
                if has_wrapper {
                    ssh_wrapper_found = true;
                    found_in = rc.clone();
                    break;
                }
            }
        }

        if ssh_wrapper_found {
            check(&format!(
                "ssh wrapper function detected in {} (TERM override active)",
                found_in
            ));
        } else {
            warn("No ssh wrapper \u{2014} remote hosts will get TERM=$TERM");
            info("Add to .zshrc: ssh() { TERM=\"$TERM_FOR_SSHD\" command ssh \"$@\"; }");
            issues += 1;
        }
    } else {
        match term.as_str() {
            "xterm-ghostty" | "xterm-kitty" => {
                warn(&format!(
                    "TERM={} but TERM_FOR_SSHD not set \u{2014} remote hosts may have issues",
                    term
                ));
                info("Add to .zshrc:");
                info("  case \"$TERM\" in xterm-ghostty|xterm-kitty) TERM_FOR_SSHD=xterm-256color ;; *) TERM_FOR_SSHD=$TERM ;; esac");
                info("  ssh() { TERM=\"$TERM_FOR_SSHD\" command ssh \"$@\"; }");
                issues += 1;
            }
            _ => {
                check(&format!("TERM={} (no override needed for SSH)", term));
            }
        }
    }

    println!();

    // -----------------------------------------------------------------------
    // Summary
    // -----------------------------------------------------------------------
    if issues == 0 {
        println!(
            "{}",
            green("All checks passed. Tab titles should work correctly.")
        );
    } else {
        println!(
            "{}",
            yellow(&format!(
                "{} issue(s) found. Restart your terminal after making changes.",
                issues
            ))
        );
    }
    println!();
}
