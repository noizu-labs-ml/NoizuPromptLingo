//! Scanner for `dc_yaml … <<'YAML' … YAML` heredoc blocks in `.envrc*` files.
//!
//! Produces a path→line index (indentation-aware, block-scalar aware) so callers
//! can locate and precisely rewrite the source line(s) for a given subject/path.

use std::ops::Range;
use std::path::{Path, PathBuf};

/// One `dc_yaml` heredoc block within a file.
#[derive(Debug, Clone)]
pub struct HeredocBlock {
    pub subject: String,
    pub layer: Option<String>,
    /// 0-indexed line of the `dc_yaml … <<'YAML'` opener.
    #[allow(dead_code)]
    pub start_line: usize,
    /// 0-indexed body range (exclusive end = the terminator line).
    pub body: Range<usize>,
}

/// A located key within a heredoc block.
#[derive(Debug, Clone)]
pub struct KeyLoc {
    pub subject: String,
    #[allow(dead_code)]
    pub layer: Option<String>,
    pub path: String,
    pub file: PathBuf,
    /// 0-indexed line where `key:` appears.
    pub key_line: usize,
    /// 0-indexed inclusive range of line(s) holding the value.
    pub value_start: usize,
    pub value_end: usize,
    pub is_block_scalar: bool,
    pub indent: usize,
}

/// Parse the args of a `dc_yaml` opener into `(flags, subject, layer)`.
fn parse_opener_args(args: &str) -> (Vec<String>, Option<String>, Option<String>) {
    let toks: Vec<&str> = args.split_whitespace().collect();
    let mut flags = Vec::new();
    let mut subject = None;
    let mut layer = None;
    let mut i = 0;
    while i < toks.len() {
        let t = toks[i];
        if t == "--layer" {
            flags.push(t.to_string());
            if let Some(v) = toks.get(i + 1) {
                layer = Some(v.to_string());
                flags.push(v.to_string());
                i += 2;
                continue;
            }
        } else if t == "--replace-key" {
            flags.push(t.to_string());
            if let Some(v) = toks.get(i + 1) {
                flags.push(v.to_string());
                i += 2;
                continue;
            }
        } else if t.starts_with("--") {
            flags.push(t.to_string());
        } else if subject.is_none() {
            subject = Some(t.to_string());
        }
        i += 1;
    }
    (flags, subject, layer)
}

/// Match a `dc_yaml … <<'YAML'` opener line, returning its raw arg string.
fn match_opener(line: &str) -> Option<String> {
    let t = line.trim_start();
    let rest = t.strip_prefix("dc_yaml")?;
    if !rest.starts_with(char::is_whitespace) {
        return None;
    }
    // Split on the heredoc operator `<<`.
    let idx = rest.find("<<")?;
    let args = rest[..idx].trim();
    // Validate the heredoc tail is a YAML terminator declaration.
    let tail = rest[idx + 2..].trim();
    let tail = tail.trim_start_matches('-').trim();
    let tail = tail.trim_matches(|c| c == '\'' || c == '"');
    if tail != "YAML" {
        return None;
    }
    Some(args.to_string())
}

fn is_terminator(line: &str) -> bool {
    line.trim() == "YAML"
}

/// Parse a `key: value` line, returning `(key, rest_after_colon)`.
fn parse_key_line(trimmed: &str) -> Option<(String, String)> {
    let pos = trimmed.find(':')?;
    let key = &trimmed[..pos];
    if key.is_empty()
        || !key
            .chars()
            .all(|c| c.is_alphanumeric() || c == '_' || c == '-' || c == '.')
    {
        return None;
    }
    Some((key.to_string(), trimmed[pos + 1..].to_string()))
}

/// Scan all `dc_yaml` heredoc blocks in `lines`.
pub fn scan_blocks(lines: &[String]) -> Vec<HeredocBlock> {
    let mut blocks = Vec::new();
    let mut i = 0;
    while i < lines.len() {
        if let Some(args) = match_opener(&lines[i]) {
            let (_flags, subject, layer) = parse_opener_args(&args);
            // Find the terminator.
            let mut j = i + 1;
            while j < lines.len() && !is_terminator(&lines[j]) {
                j += 1;
            }
            if let Some(subject) = subject {
                blocks.push(HeredocBlock {
                    subject,
                    layer,
                    start_line: i,
                    body: (i + 1)..j,
                });
            }
            i = j + 1;
        } else {
            i += 1;
        }
    }
    blocks
}

/// Index every key within a block to its line location.
pub fn index_block(block: &HeredocBlock, lines: &[String], file: &Path) -> Vec<KeyLoc> {
    let mut locs = Vec::new();
    let mut stack: Vec<(usize, String)> = Vec::new();
    let mut i = block.body.start;
    while i < block.body.end {
        let line = &lines[i];
        let trimmed = line.trim_start();
        if trimmed.is_empty() || trimmed.starts_with('#') {
            i += 1;
            continue;
        }
        let indent = line.len() - trimmed.len();
        let Some((key, rest)) = parse_key_line(trimmed) else {
            i += 1;
            continue;
        };

        // Pop deeper-or-equal entries off the stack.
        while let Some((ind, _)) = stack.last() {
            if *ind >= indent {
                stack.pop();
            } else {
                break;
            }
        }
        stack.push((indent, key.clone()));
        let path = stack
            .iter()
            .map(|(_, k)| k.as_str())
            .collect::<Vec<_>>()
            .join(".");

        let rest_trim = rest.trim();
        if rest_trim.starts_with('|') || rest_trim.starts_with('>') {
            // Block scalar: value spans following more-indented lines.
            let mut j = i + 1;
            let mut last_nonblank = i;
            while j < block.body.end {
                let l = &lines[j];
                let lt = l.trim_start();
                if lt.is_empty() {
                    j += 1;
                    continue;
                }
                let ind2 = l.len() - lt.len();
                if ind2 > indent {
                    last_nonblank = j;
                    j += 1;
                } else {
                    break;
                }
            }
            locs.push(KeyLoc {
                subject: block.subject.clone(),
                layer: block.layer.clone(),
                path,
                file: file.to_path_buf(),
                key_line: i,
                value_start: i + 1,
                value_end: last_nonblank,
                is_block_scalar: true,
                indent,
            });
            i = j;
        } else {
            locs.push(KeyLoc {
                subject: block.subject.clone(),
                layer: block.layer.clone(),
                path,
                file: file.to_path_buf(),
                key_line: i,
                value_start: i,
                value_end: i,
                is_block_scalar: false,
                indent,
            });
            i += 1;
        }
    }
    locs
}

/// Read a file and return all located keys across its heredoc blocks.
pub fn index_file(path: &Path) -> std::io::Result<Vec<KeyLoc>> {
    let content = std::fs::read_to_string(path)?;
    let lines: Vec<String> = content.lines().map(|s| s.to_string()).collect();
    let mut out = Vec::new();
    for block in scan_blocks(&lines) {
        out.extend(index_block(&block, &lines, path));
    }
    Ok(out)
}

/// Discover `.envrc*` files in `dir` (non-recursive).
pub fn envrc_files(dir: &Path) -> Vec<PathBuf> {
    let mut files = Vec::new();
    if let Ok(entries) = std::fs::read_dir(dir) {
        for e in entries.flatten() {
            let name = e.file_name();
            let name = name.to_string_lossy();
            if name == ".envrc" || name.starts_with(".envrc.") {
                files.push(e.path());
            }
        }
    }
    files.sort();
    files
}

#[cfg(test)]
mod tests {
    use super::*;

    fn lines(s: &str) -> Vec<String> {
        s.lines().map(|l| l.to_string()).collect()
    }

    #[test]
    fn parses_opener_variants() {
        assert_eq!(match_opener("dc_yaml --no-bump cf <<'YAML'").as_deref(), Some("--no-bump cf"));
        assert_eq!(match_opener("  dc_yaml cf --layer secrets <<'YAML'").as_deref(), Some("cf --layer secrets"));
        assert_eq!(match_opener("dc_yaml cf <<-\"YAML\"").as_deref(), Some("cf"));
        assert!(match_opener("echo dc_yaml cf").is_none());
        assert!(match_opener("dc_yamlx cf <<'YAML'").is_none());
    }

    #[test]
    fn parses_subject_and_layer() {
        let (_f, s, l) = parse_opener_args("--no-bump cf --layer secrets");
        assert_eq!(s.as_deref(), Some("cf"));
        assert_eq!(l.as_deref(), Some("secrets"));
        let (_f, s, l) = parse_opener_args("--no-bump infra");
        assert_eq!(s.as_deref(), Some("infra"));
        assert_eq!(l, None);
    }

    #[test]
    fn indexes_nested_single_line_keys() {
        let src = lines(
            "dc_yaml --no-bump cf <<'YAML'\naccount_id: 123\naccess:\n  client_id: pub\n  client_secret: \"🔒 shh\"\nYAML\n",
        );
        let blocks = scan_blocks(&src);
        assert_eq!(blocks.len(), 1);
        assert_eq!(blocks[0].subject, "cf");
        let locs = index_block(&blocks[0], &src, Path::new("/x/.envrc"));
        let by_path = |p: &str| locs.iter().find(|l| l.path == p).unwrap();
        assert_eq!(by_path("account_id").key_line, 1);
        assert_eq!(by_path("access.client_id").key_line, 3);
        let cs = by_path("access.client_secret");
        assert_eq!(cs.key_line, 4);
        assert!(!cs.is_block_scalar);
        assert_eq!(cs.indent, 2);
    }

    #[test]
    fn indexes_block_scalar_range() {
        let src = lines(
            "dc_yaml --no-bump cf <<'YAML'\naccount_id: |\n  🔒 line-one\n  line-two\n\n  line-three\nzone: z\nYAML\n",
        );
        let blocks = scan_blocks(&src);
        let locs = index_block(&blocks[0], &src, Path::new("/x/.envrc"));
        let acct = locs.iter().find(|l| l.path == "account_id").unwrap();
        assert!(acct.is_block_scalar);
        assert_eq!(acct.key_line, 1);
        assert_eq!(acct.value_start, 2);
        // value_end is the last non-blank indented line (line index 5: "  line-three")
        assert_eq!(acct.value_end, 5);
        // the next sibling key is found after the block
        let zone = locs.iter().find(|l| l.path == "zone").unwrap();
        assert_eq!(zone.key_line, 6);
        assert!(!zone.is_block_scalar);
    }

    #[test]
    fn multiple_blocks_in_one_file() {
        let src = lines(
            "dc_yaml --no-bump infra <<'YAML'\nroot: /x\nYAML\n\ndc_yaml --no-bump cf --layer secrets <<'YAML'\napi_token: \"🔒 t\"\nYAML\n",
        );
        let blocks = scan_blocks(&src);
        assert_eq!(blocks.len(), 2);
        assert_eq!(blocks[1].subject, "cf");
        assert_eq!(blocks[1].layer.as_deref(), Some("secrets"));
        let locs = index_block(&blocks[1], &src, Path::new("/x/.envrc"));
        assert_eq!(locs.iter().find(|l| l.path == "api_token").unwrap().subject, "cf");
    }

    #[test]
    fn ignores_comments_and_blank_lines() {
        let src = lines(
            "dc_yaml --no-bump cf <<'YAML'\n# a comment\naccount_id: 123\n\n# another\nzone: z\nYAML\n",
        );
        let blocks = scan_blocks(&src);
        let locs = index_block(&blocks[0], &src, Path::new("/x/.envrc"));
        assert_eq!(locs.len(), 2);
        assert_eq!(locs.iter().find(|l| l.path == "zone").unwrap().key_line, 5);
    }
}
