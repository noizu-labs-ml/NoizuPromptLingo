//! `dc config get/set/setall` — locate and edit secrets in source `.envrc*` files.
//!
//! These commands operate on the literal hand-authored heredoc files (not the
//! state store), encrypting secret values at rest inline as `🔒 dcenc:…` and
//! preserving all surrounding formatting/comments via line splicing.

use anyhow::{bail, Result};
use std::io::{Read, Write};
use std::path::{Path, PathBuf};

use crate::envrc::locator::{self, KeyLoc};
use crate::secret::PADLOCK;

fn source_dir() -> Result<PathBuf> {
    let store = crate::store::find_current_store()?;
    let meta = crate::store::meta::read_meta(&store)?;
    Ok(meta.source)
}

fn read_lines(path: &Path) -> Result<Vec<String>> {
    let content = std::fs::read_to_string(path)?;
    Ok(content.lines().map(|s| s.to_string()).collect())
}

fn write_lines(path: &Path, lines: &[String]) -> Result<()> {
    let mut body = lines.join("\n");
    body.push('\n');
    std::fs::write(path, body)?;
    Ok(())
}

fn marker(tier: u8) -> String {
    let bangs: String = std::iter::repeat('❗').take(tier.min(3) as usize).collect();
    format!("{PADLOCK}{bangs}")
}

fn leaf_key(path: &str) -> &str {
    path.rsplit('.').next().unwrap_or(path)
}

/// Find all source locations for a subject/path across `.envrc*` files.
fn find_locs(subject: &str, path: &str) -> Result<Vec<KeyLoc>> {
    let dir = source_dir()?;
    let mut matches = Vec::new();
    for f in locator::envrc_files(&dir) {
        if let Ok(locs) = locator::index_file(&f) {
            for l in locs {
                if l.subject == subject && l.path == path {
                    matches.push(l);
                }
            }
        }
    }
    Ok(matches)
}

/// Current raw value text for a location (block scalars joined).
fn current_value_text(lines: &[String], loc: &KeyLoc) -> String {
    if loc.is_block_scalar {
        lines[loc.value_start..=loc.value_end.min(lines.len() - 1)].join("\n")
    } else {
        lines[loc.key_line]
            .splitn(2, ':')
            .nth(1)
            .unwrap_or("")
            .trim()
            .trim_matches(|c| c == '"' || c == '\'')
            .to_string()
    }
}

fn existing_tier(lines: &[String], loc: &KeyLoc) -> u8 {
    crate::secret::parse_marker(&current_value_text(lines, loc))
        .map(|p| p.tier)
        .unwrap_or(0)
}

/// Compute the replacement line for a located key.
fn compute_set_line(loc: &KeyLoc, tier: u8, token: &str) -> String {
    let indent = " ".repeat(loc.indent);
    format!("{indent}{}: \"{} {}\"", leaf_key(&loc.path), marker(tier), token)
}

/// Splice a single replacement line over a location's key+value range.
fn splice_set(lines: &[String], loc: &KeyLoc, new_line: String) -> Vec<String> {
    let after = if loc.is_block_scalar {
        loc.value_end + 1
    } else {
        loc.key_line + 1
    };
    let mut out = lines[..loc.key_line].to_vec();
    out.push(new_line);
    out.extend_from_slice(&lines[after.min(lines.len())..]);
    out
}

/// Compute an errata insertion `(index, line)` for a missing leaf whose parent
/// (or block top-level) exists.
fn errata_compute(
    lines: &[String],
    subject: &str,
    path: &str,
    tier: u8,
    token: &str,
) -> Option<(usize, String)> {
    let leaf = leaf_key(path);
    let parent = path.rsplit_once('.').map(|(p, _)| p);

    for block in locator::scan_blocks(lines) {
        if block.subject != subject {
            continue;
        }
        let locs = locator::index_block(&block, lines, Path::new(""));
        match parent {
            Some(p) => {
                if let Some(ploc) = locs.iter().find(|l| l.path == p) {
                    let child_indent = ploc.indent + 2;
                    // Find end of the parent's subtree.
                    let mut idx = if ploc.is_block_scalar {
                        ploc.value_end + 1
                    } else {
                        ploc.key_line + 1
                    };
                    while idx < block.body.end {
                        let lt = lines[idx].trim_start();
                        if lt.is_empty() || lt.starts_with('#') {
                            idx += 1;
                            continue;
                        }
                        let ind = lines[idx].len() - lt.len();
                        if ind > ploc.indent {
                            idx += 1;
                        } else {
                            break;
                        }
                    }
                    let line = format!(
                        "{}{}: \"{} {}\"",
                        " ".repeat(child_indent),
                        leaf,
                        marker(tier),
                        token
                    );
                    return Some((idx, line));
                }
            }
            None => {
                // Top-level: insert just before the block terminator.
                let line = format!("{}: \"{} {}\"", leaf, marker(tier), token);
                return Some((block.body.end, line));
            }
        }
    }
    None
}

fn acquire_value(value: Option<&str>, from: Option<&str>, stdin: bool) -> Result<String> {
    let sources = [value.is_some(), from.is_some(), stdin]
        .iter()
        .filter(|b| **b)
        .count();
    if sources == 0 {
        bail!("provide a value with --value, --from <FILE>, or --stdin");
    }
    if sources > 1 {
        bail!("use only one of --value / --from / --stdin");
    }
    if let Some(v) = value {
        return Ok(v.to_string());
    }
    if let Some(f) = from {
        return Ok(std::fs::read_to_string(f)?.trim_end_matches('\n').to_string());
    }
    let mut buf = String::new();
    std::io::stdin().read_to_string(&mut buf)?;
    Ok(buf.trim_end_matches('\n').to_string())
}

fn confirm(prompt: &str) -> Result<bool> {
    eprint!("{prompt} [y/N] ");
    std::io::stderr().flush().ok();
    let mut buf = String::new();
    std::io::stdin().read_line(&mut buf)?;
    Ok(matches!(buf.trim().to_lowercase().as_str(), "y" | "yes"))
}

/// Print a context preview around a location, redacting secret values, and
/// marking the line(s) being changed.
fn preview(lines: &[String], key_line: usize, last_line: usize, new_display: Option<&str>) {
    let start = key_line.saturating_sub(2);
    let end = (last_line + 3).min(lines.len());
    eprintln!("  ┄┄ {} ┄┄", "context");
    for (i, line) in lines.iter().enumerate().take(end).skip(start) {
        if i >= key_line && i <= last_line {
            eprintln!("  ➡️  {}", redact_for_display(line));
        } else {
            eprintln!("      {line}");
        }
    }
    if let Some(nd) = new_display {
        eprintln!("  ✚  {nd}");
    }
}

fn redact_for_display(line: &str) -> String {
    // Mask any dcenc token in the displayed line.
    if let Some(pos) = line.find("dcenc:v1:") {
        let prefix = &line[..pos];
        return format!("{prefix}**redacted**\"");
    }
    line.to_string()
}

// ---------------------------------------------------------------------------
// Commands
// ---------------------------------------------------------------------------

/// Replace a subject/path's value in its `.envrc*` source with the `⛔`
/// shadowed-secret sentinel. Returns true if a source line was rewritten.
pub(crate) fn write_sentinel(subject: &str, path: &str) -> Result<bool> {
    let locs = find_locs(subject, path)?;
    let Some(loc) = locs.first() else {
        return Ok(false);
    };
    let lines = read_lines(&loc.file)?;
    let new_line = format!("{}{}: \"⛔\"", " ".repeat(loc.indent), leaf_key(&loc.path));
    let out = splice_set(&lines, loc, new_line);
    write_lines(&loc.file, &out)?;
    Ok(true)
}

pub fn get(subject: &str, path: &str) -> Result<()> {
    let locs = find_locs(subject, path)?;
    if locs.is_empty() {
        println!("no source entry found for `{subject} {path}` in .envrc* files");
        return Ok(());
    }
    for l in &locs {
        let lines = read_lines(&l.file)?;
        println!(
            "{}:{}  ({} {})",
            l.file.display(),
            l.key_line + 1,
            subject,
            path
        );
        preview(&lines, l.key_line, if l.is_block_scalar { l.value_end } else { l.key_line }, None);
    }
    Ok(())
}

#[allow(clippy::too_many_arguments)]
pub fn set(
    subject: &str,
    path: &str,
    value: Option<&str>,
    from: Option<&str>,
    stdin_flag: bool,
    encrypted: bool,
    yes: bool,
) -> Result<()> {
    let plaintext = acquire_value(value, from, stdin_flag)?;
    // Using stdin for the value means we cannot also prompt on stdin.
    let yes = yes || stdin_flag;

    let locs = find_locs(subject, path)?;
    if locs.len() > 1 {
        eprintln!("ambiguous — `{subject} {path}` matches multiple locations:");
        for l in &locs {
            eprintln!("  {}:{}", l.file.display(), l.key_line + 1);
        }
        bail!("narrow the path or edit the file directly");
    }

    if locs.is_empty() {
        return set_errata(subject, path, &plaintext, encrypted, yes);
    }

    let loc = &locs[0];
    let mut lines = read_lines(&loc.file)?;
    let tier = existing_tier(&lines, loc);
    let token = if encrypted {
        plaintext.clone()
    } else {
        crate::crypto::encode_token(&plaintext, tier, &crate::settings::key()?)?
    };
    let new_line = compute_set_line(loc, tier, &token);
    let new_display = format!("{}: \"{} **redacted**\"", " ".repeat(loc.indent) + leaf_key(&loc.path), marker(tier));

    eprintln!("Update {} {} in {}:{}", subject, path, loc.file.display(), loc.key_line + 1);
    preview(&lines, loc.key_line, if loc.is_block_scalar { loc.value_end } else { loc.key_line }, Some(&new_display));
    if !yes && !confirm("Apply this change?")? {
        eprintln!("aborted");
        return Ok(());
    }
    lines = splice_set(&lines, loc, new_line);
    write_lines(&loc.file, &lines)?;
    println!("updated {}:{}", loc.file.display(), loc.key_line + 1);
    Ok(())
}

fn set_errata(subject: &str, path: &str, plaintext: &str, encrypted: bool, yes: bool) -> Result<()> {
    let dir = source_dir()?;
    for f in locator::envrc_files(&dir) {
        let mut lines = read_lines(&f)?;
        if !locator::scan_blocks(&lines).iter().any(|b| b.subject == subject) {
            continue;
        }
        let token = if encrypted {
            plaintext.to_string()
        } else {
            crate::crypto::encode_token(plaintext, 0, &crate::settings::key()?)?
        };
        let Some((idx, new_line)) = errata_compute(&lines, subject, path, 0, &token) else {
            bail!(
                "subject `{subject}` exists but parent of `{path}` was not found — use `dc config setall`"
            );
        };
        let display = redact_for_display(&new_line);
        eprintln!("Insert {subject} {path} into {}:{}", f.display(), idx + 1);
        preview(&lines, idx.saturating_sub(1), idx.saturating_sub(1), Some(&display));
        if !yes && !confirm("Insert this entry?")? {
            eprintln!("aborted");
            return Ok(());
        }
        lines.insert(idx, new_line);
        write_lines(&f, &lines)?;
        println!("inserted {subject} {path} at {}:{}", f.display(), idx + 1);
        return Ok(());
    }
    bail!("no `dc_yaml … {subject}` block found in any .envrc* file — use `dc config setall`")
}

/// Insert a YAML section relative to an anchor entry.
pub fn setall(
    layer_subject: &str,
    yaml_input: &str,
    anchor_subject: &str,
    anchor_path: &str,
    below: bool,
    yes: bool,
) -> Result<()> {
    let dir = source_dir()?;
    for f in locator::envrc_files(&dir) {
        let mut lines = read_lines(&f)?;
        let blocks = locator::scan_blocks(&lines);
        let Some(block) = blocks.iter().find(|b| b.subject == layer_subject) else {
            continue;
        };
        let locs = locator::index_block(block, &lines, &f);
        // The anchor must belong to the requested subject too (we edit one block).
        let _ = anchor_subject;
        let Some(anchor) = locs.iter().find(|l| l.path == anchor_path) else {
            continue;
        };
        let indent = anchor.indent;
        let insert_at = if below {
            if anchor.is_block_scalar { anchor.value_end + 1 } else { anchor.key_line + 1 }
        } else {
            anchor.key_line
        };
        // Re-indent the provided YAML to the anchor's indent level.
        let new_lines: Vec<String> = yaml_input
            .lines()
            .map(|l| format!("{}{}", " ".repeat(indent), l))
            .collect();

        eprintln!(
            "Insert {} line(s) {} {} {} in {}:{}",
            new_lines.len(),
            if below { "below" } else { "above" },
            layer_subject,
            anchor_path,
            f.display(),
            insert_at + 1
        );
        for l in &new_lines {
            eprintln!("  ✚  {l}");
        }
        if !yes && !confirm("Insert this section?")? {
            eprintln!("aborted");
            return Ok(());
        }
        let mut out = lines[..insert_at].to_vec();
        out.extend(new_lines);
        out.extend_from_slice(&lines[insert_at..]);
        lines = out;
        write_lines(&f, &lines)?;
        println!("inserted section at {}:{}", f.display(), insert_at + 1);
        return Ok(());
    }
    bail!("anchor `{anchor_subject} {anchor_path}` not found in any .envrc* file")
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::envrc::locator::{index_block, scan_blocks};

    const KEY: [u8; 32] = [5u8; 32];

    fn lines(s: &str) -> Vec<String> {
        s.lines().map(|l| l.to_string()).collect()
    }

    fn locate(src: &[String], subject: &str, path: &str) -> KeyLoc {
        for b in scan_blocks(src) {
            for l in index_block(&b, src, Path::new("/x/.envrc")) {
                if l.subject == subject && l.path == path {
                    return l;
                }
            }
        }
        panic!("not found");
    }

    #[test]
    fn set_single_line_preserves_siblings_and_comments() {
        let src = lines(
            "dc_yaml --no-bump cf <<'YAML'\n# keep me\naccount_id: 123\naccess:\n  client_secret: \"🔒❗ old\"\nzone: z\nYAML",
        );
        let loc = locate(&src, "cf", "access.client_secret");
        let tier = existing_tier(&src, &loc);
        assert_eq!(tier, 1);
        let token = crate::crypto::encode_token("newsecret", tier, &KEY).unwrap();
        let new_line = compute_set_line(&loc, tier, &token);
        let out = splice_set(&src, &loc, new_line);

        // comment + siblings intact
        assert!(out.iter().any(|l| l == "# keep me"));
        assert!(out.iter().any(|l| l == "account_id: 123"));
        assert!(out.iter().any(|l| l == "zone: z"));
        // the secret line now holds an encrypted token, still 🔒❗ tier-1, indented 2
        let line = out.iter().find(|l| l.contains("client_secret")).unwrap();
        assert!(line.starts_with("  client_secret: \"🔒❗ dcenc:v1:t1:"));
    }

    #[test]
    fn set_block_scalar_collapses_to_single_line() {
        let src = lines(
            "dc_yaml --no-bump cf <<'YAML'\naccount_id: |\n  🔒 line-one\n  line-two\nzone: z\nYAML",
        );
        let loc = locate(&src, "cf", "account_id");
        assert!(loc.is_block_scalar);
        let token = crate::crypto::encode_token("v", 0, &KEY).unwrap();
        let new_line = compute_set_line(&loc, 0, &token);
        let out = splice_set(&src, &loc, new_line);
        // The 4-line block is gone; zone survives directly after.
        assert!(out.iter().any(|l| l.starts_with("account_id: \"🔒 dcenc:")));
        assert!(out.iter().any(|l| l == "zone: z"));
        assert!(!out.iter().any(|l| l.contains("line-two")));
    }

    #[test]
    fn errata_inserts_under_existing_parent() {
        let src = lines(
            "dc_yaml --no-bump cf <<'YAML'\naccess:\n  client_id: pub\nzone: z\nYAML",
        );
        let token = crate::crypto::encode_token("BANANA", 0, &KEY).unwrap();
        let (idx, line) = errata_compute(&src, "cf", "access.foobar", 0, &token).unwrap();
        // Inserted after access.client_id (index 3), indented 2.
        assert_eq!(idx, 3);
        assert!(line.starts_with("  foobar: \"🔒 dcenc:"));
        let mut out = src.clone();
        out.insert(idx, line);
        assert_eq!(out[2], "  client_id: pub");
        assert!(out[3].starts_with("  foobar:"));
        assert_eq!(out[4], "zone: z");
    }

    #[test]
    fn errata_inserts_top_level_before_terminator() {
        let src = lines("dc_yaml --no-bump cf <<'YAML'\naccount_id: 1\nYAML");
        let token = crate::crypto::encode_token("t", 0, &KEY).unwrap();
        let (idx, line) = errata_compute(&src, "cf", "api_token", 0, &token).unwrap();
        assert_eq!(idx, 2); // the YAML terminator line index
        assert!(line.starts_with("api_token: \"🔒 dcenc:"));
    }
}
