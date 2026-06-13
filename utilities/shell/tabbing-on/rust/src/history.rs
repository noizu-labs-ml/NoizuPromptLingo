use std::collections::HashMap;
use std::fs;
use std::path::PathBuf;

use crate::state::state_dir;

/// Return the history directory path.
fn history_dir() -> PathBuf {
    let dir = state_dir().join("history");
    let _ = fs::create_dir_all(&dir);
    dir
}

/// Strip surrounding double quotes from a YAML value.
fn strip_quotes(s: &str) -> String {
    let s = s.trim();
    if s.starts_with('"') && s.ends_with('"') && s.len() >= 2 {
        s[1..s.len() - 1].to_string()
    } else {
        s.to_string()
    }
}

/// List all known tab IDs with started date and latest title.
pub fn history_list_tabs() {
    let dir = history_dir();
    let entries = match fs::read_dir(&dir) {
        Ok(e) => e,
        Err(_) => {
            eprintln!("No history found.");
            return;
        }
    };

    let rec_base = state_dir().join("recordings");
    let mut found = false;

    let mut files: Vec<_> = entries.filter_map(|e| e.ok()).collect();
    files.sort_by_key(|e| e.file_name());

    for entry in files {
        let path = entry.path();
        if path.extension().and_then(|e| e.to_str()) != Some("yaml") {
            continue;
        }
        let content = match fs::read_to_string(&path) {
            Ok(c) => c,
            Err(_) => continue,
        };

        found = true;
        let mut tab_id = String::new();
        let mut started = String::new();
        let mut last_title = String::new();

        for line in content.lines() {
            if let Some(rest) = line.strip_prefix("tab_id: ") {
                tab_id = strip_quotes(rest);
            } else if let Some(rest) = line.strip_prefix("started: ") {
                started = strip_quotes(rest);
            } else if let Some(rest) = line.strip_prefix("    title: ") {
                last_title = strip_quotes(rest);
            }
        }

        // Count recordings
        let rec_dir = rec_base.join(&tab_id);
        let rec_count = if rec_dir.is_dir() {
            fs::read_dir(&rec_dir)
                .map(|rd| {
                    rd.filter_map(|e| e.ok())
                        .filter(|e| {
                            e.path()
                                .extension()
                                .and_then(|x| x.to_str())
                                == Some("cast")
                        })
                        .count()
                })
                .unwrap_or(0)
        } else {
            0
        };

        if rec_count > 0 {
            println!(
                "  {}  {}  {:<20}  [{} recordings]",
                tab_id, started, last_title, rec_count
            );
        } else {
            println!("  {}  {}  {}", tab_id, started, last_title);
        }
    }

    if !found {
        eprintln!("No history found.");
    }
}

/// Search across all history files for a query string (case-insensitive).
pub fn history_search(query: &str) {
    let dir = history_dir();
    let entries = match fs::read_dir(&dir) {
        Ok(e) => e,
        Err(_) => {
            eprintln!("No history found.");
            return;
        }
    };

    println!("Searching for: {}\n", query);
    let query_lower = query.to_lowercase();
    let mut found = false;

    let mut files: Vec<_> = entries.filter_map(|e| e.ok()).collect();
    files.sort_by_key(|e| e.file_name());

    for entry in files {
        let path = entry.path();
        if path.extension().and_then(|e| e.to_str()) != Some("yaml") {
            continue;
        }
        let content = match fs::read_to_string(&path) {
            Ok(c) => c,
            Err(_) => continue,
        };

        if !content.to_lowercase().contains(&query_lower) {
            continue;
        }

        // Extract tab_id
        let tab_id = content
            .lines()
            .find_map(|l| l.strip_prefix("tab_id: ").map(|r| strip_quotes(r)))
            .unwrap_or_default();

        println!("--- Tab {} ---", tab_id);

        // Show matching lines with 2 lines of context
        let lines: Vec<&str> = content.lines().collect();
        let mut printed: Vec<bool> = vec![false; lines.len()];

        for (i, line) in lines.iter().enumerate() {
            if line.to_lowercase().contains(&query_lower) {
                let start = i.saturating_sub(2);
                let end = (i + 3).min(lines.len());
                for j in start..end {
                    printed[j] = true;
                }
            }
        }

        for (i, line) in lines.iter().enumerate() {
            if printed[i] {
                println!("{}", line);
            }
        }
        println!();
        found = true;
    }

    if !found {
        println!("No results found.");
    }
}

/// Parsed history entry for time-in-state calculations.
struct HistoryEntry {
    timestamp: String,
    status: String,
}

/// Detect whether a history file uses the shell-compatible format (with
/// `entries:` header and `event:` keys) or the legacy Rust flat format
/// (with `- type:` entries and `type:` keys).
///
/// Returns `true` for shell format, `false` for legacy Rust format.
fn is_shell_format(content: &str) -> bool {
    for line in content.lines() {
        let trimmed = line.trim();
        if trimmed.starts_with("tab_id:") || trimmed == "entries:" {
            return true;
        }
        if trimmed.starts_with("- type:") {
            return false;
        }
    }
    // Default to shell format for empty/ambiguous files
    true
}

/// Parse history entries from file content.
/// Handles both the shell-compatible format (`entries:` header, `event:` keys,
/// 2-space-indented list items) and the legacy Rust flat format (`- type:` at
/// column 0, `  timestamp:` / `  status:` at 2-space indent).
fn parse_entries(content: &str) -> Vec<HistoryEntry> {
    if is_shell_format(content) {
        parse_entries_shell(content)
    } else {
        parse_entries_legacy(content)
    }
}

/// Parse the shell-compatible format:
/// ```yaml
/// tab_id: "abc"
/// terminal: "ghostty"
/// started: "2026-05-27T12:00:00Z"
/// entries:
///   - timestamp: "..."
///     event: "title"
///     title: "My App"
///     status: "deploying"
/// ```
fn parse_entries_shell(content: &str) -> Vec<HistoryEntry> {
    let mut entries: Vec<HistoryEntry> = Vec::new();
    let mut current_ts = String::new();

    for line in content.lines() {
        // Match "  - timestamp: " (shell format entry start)
        if let Some(rest) = line.strip_prefix("  - timestamp: ") {
            // Push previous entry if we have a pending timestamp with no status yet
            // (this handles entries that lack a status field)
            current_ts = strip_quotes(rest);
        } else if let Some(rest) = line.strip_prefix("    status: ") {
            entries.push(HistoryEntry {
                timestamp: current_ts.clone(),
                status: strip_quotes(rest),
            });
        }
    }
    entries
}

/// Parse the legacy Rust flat format:
/// ```yaml
/// - type: title
///   timestamp: "2025-01-15T10:00:00+0000"
///   title: "MyApp"
///   status: "building"
/// ```
fn parse_entries_legacy(content: &str) -> Vec<HistoryEntry> {
    let mut entries: Vec<HistoryEntry> = Vec::new();
    let mut current_ts = String::new();

    for line in content.lines() {
        if let Some(rest) = line.strip_prefix("  timestamp: ") {
            current_ts = strip_quotes(rest);
        } else if let Some(rest) = line.strip_prefix("  status: ") {
            entries.push(HistoryEntry {
                timestamp: current_ts.clone(),
                status: strip_quotes(rest),
            });
        }
    }
    entries
}

/// Parse an ISO timestamp into epoch seconds (approximate, for duration diffs).
/// Handles formats like: 2025-01-15T10:30:45Z, 2025-01-15T10:30:45+0000
fn ts_to_seconds(ts: &str) -> i64 {
    // Strip timezone suffix for parsing
    let ts = ts.trim_end_matches('Z');
    // Remove +HHMM or -HHMM timezone offset if present
    let ts = if ts.len() > 5 {
        let tail = &ts[ts.len() - 5..];
        if (tail.starts_with('+') || tail.starts_with('-'))
            && tail[1..].chars().all(|c| c.is_ascii_digit())
        {
            &ts[..ts.len() - 5]
        } else {
            ts
        }
    } else {
        ts
    };

    // Parse: YYYY-MM-DDTHH:MM:SS
    let parts: Vec<&str> = ts.split('T').collect();
    if parts.len() != 2 {
        return 0;
    }
    let date_parts: Vec<&str> = parts[0].split('-').collect();
    let time_parts: Vec<&str> = parts[1].split(':').collect();

    if date_parts.len() != 3 || time_parts.len() < 3 {
        return 0;
    }

    let year: i64 = date_parts[0].parse().unwrap_or(0);
    let month: i64 = date_parts[1].parse().unwrap_or(0);
    let day: i64 = date_parts[2].parse().unwrap_or(0);
    let hour: i64 = time_parts[0].parse().unwrap_or(0);
    let min: i64 = time_parts[1].parse().unwrap_or(0);
    let sec: i64 = time_parts[2].parse().unwrap_or(0);

    // Approximate days from epoch (not perfectly accurate but sufficient for diffs)
    let mut total_days: i64 = 0;
    // Years
    for y in 1970..year {
        total_days += if is_leap(y) { 366 } else { 365 };
    }
    // Months
    let days_in_month = [31, if is_leap(year) { 29 } else { 28 }, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    for m in 0..(month - 1) as usize {
        if m < 12 {
            total_days += days_in_month[m];
        }
    }
    total_days += day - 1;

    total_days * 86400 + hour * 3600 + min * 60 + sec
}

fn is_leap(y: i64) -> bool {
    (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0)
}

/// Compute time-in-state durations from entries.
fn compute_durations(entries: &[HistoryEntry]) -> (HashMap<String, i64>, i64) {
    let mut durations: HashMap<String, i64> = HashMap::new();
    let mut total: i64 = 0;

    for i in 0..entries.len().saturating_sub(1) {
        let status = if entries[i].status.is_empty() {
            "(no status)".to_string()
        } else {
            entries[i].status.clone()
        };

        let sec_a = ts_to_seconds(&entries[i].timestamp);
        let sec_b = ts_to_seconds(&entries[i + 1].timestamp);
        let diff = (sec_b - sec_a).max(0);

        *durations.entry(status).or_insert(0) += diff;
        total += diff;
    }

    // Ensure last status appears even with 0 duration
    if let Some(last) = entries.last() {
        if !last.status.is_empty() {
            durations.entry(last.status.clone()).or_insert(0);
        }
    }

    (durations, total)
}

/// Format duration seconds as "Xh YYm".
fn format_duration(seconds: i64) -> String {
    let hrs = seconds / 3600;
    let mins = (seconds % 3600) / 60;
    format!("{}h {:02}m", hrs, mins)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_strip_quotes_plain() {
        assert_eq!(strip_quotes("hello"), "hello");
    }

    #[test]
    fn test_strip_quotes_quoted() {
        assert_eq!(strip_quotes("\"hello\""), "hello");
    }

    #[test]
    fn test_strip_quotes_whitespace() {
        assert_eq!(strip_quotes("  \"hello\"  "), "hello");
    }

    #[test]
    fn test_is_leap() {
        assert!(is_leap(2000));
        assert!(is_leap(2024));
        assert!(!is_leap(1900));
        assert!(!is_leap(2023));
    }

    #[test]
    fn test_ts_to_seconds_basic() {
        let ts = "2025-01-01T00:00:00+0000";
        let secs = ts_to_seconds(ts);
        assert!(secs > 0);
    }

    #[test]
    fn test_ts_to_seconds_diff() {
        let ts1 = "2025-01-15T10:00:00+0000";
        let ts2 = "2025-01-15T11:00:00+0000";
        let diff = ts_to_seconds(ts2) - ts_to_seconds(ts1);
        assert_eq!(diff, 3600);
    }

    #[test]
    fn test_ts_to_seconds_timezone_stripped() {
        let ts_utc = "2025-01-15T10:00:00Z";
        let ts_offset = "2025-01-15T10:00:00+0000";
        assert_eq!(ts_to_seconds(ts_utc), ts_to_seconds(ts_offset));
    }

    #[test]
    fn test_ts_to_seconds_invalid() {
        assert_eq!(ts_to_seconds("garbage"), 0);
        assert_eq!(ts_to_seconds(""), 0);
    }

    #[test]
    fn test_format_duration() {
        assert_eq!(format_duration(0), "0h 00m");
        assert_eq!(format_duration(60), "0h 01m");
        assert_eq!(format_duration(3600), "1h 00m");
        assert_eq!(format_duration(3661), "1h 01m");
        assert_eq!(format_duration(7200), "2h 00m");
    }

    #[test]
    fn test_parse_entries_legacy_format() {
        let content = r#"- type: title
  timestamp: "2025-01-15T10:00:00+0000"
  title: "MyApp"
  status: "building"
- type: status
  timestamp: "2025-01-15T11:00:00+0000"
  title: "MyApp"
  status: "testing"
"#;
        let entries = parse_entries(content);
        assert_eq!(entries.len(), 2);
        assert_eq!(entries[0].status, "building");
        assert_eq!(entries[0].timestamp, "2025-01-15T10:00:00+0000");
        assert_eq!(entries[1].status, "testing");
        assert_eq!(entries[1].timestamp, "2025-01-15T11:00:00+0000");
    }

    #[test]
    fn test_parse_entries_shell_format() {
        let content = r#"tab_id: "abc12345"
terminal: "ghostty"
started: "2026-05-27T12:00:00Z"
entries:
  - timestamp: "2026-05-27T12:00:00Z"
    event: "title"
    title: "My App"
    status: "deploying"
  - timestamp: "2026-05-27T12:05:00Z"
    event: "status"
    title: "My App"
    status: "testing"
  - timestamp: "2026-05-27T12:30:00Z"
    event: "status"
    title: "My App"
    status: "done"
"#;
        let entries = parse_entries(content);
        assert_eq!(entries.len(), 3);
        assert_eq!(entries[0].status, "deploying");
        assert_eq!(entries[0].timestamp, "2026-05-27T12:00:00Z");
        assert_eq!(entries[1].status, "testing");
        assert_eq!(entries[2].status, "done");
    }

    #[test]
    fn test_is_shell_format_detection() {
        let shell = "tab_id: \"abc\"\nterminal: \"ghostty\"\nstarted: \"2026-05-27\"\nentries:\n";
        assert!(is_shell_format(shell));

        let legacy = "- type: title\n  timestamp: \"2025-01-15\"\n  status: \"building\"\n";
        assert!(!is_shell_format(legacy));

        // Empty content defaults to shell format
        assert!(is_shell_format(""));
    }

    #[test]
    fn test_compute_durations() {
        let entries = vec![
            HistoryEntry {
                timestamp: "2025-01-15T10:00:00+0000".to_string(),
                status: "building".to_string(),
            },
            HistoryEntry {
                timestamp: "2025-01-15T11:00:00+0000".to_string(),
                status: "testing".to_string(),
            },
            HistoryEntry {
                timestamp: "2025-01-15T11:30:00+0000".to_string(),
                status: "done".to_string(),
            },
        ];
        let (durations, total) = compute_durations(&entries);
        assert_eq!(total, 5400); // 1.5 hours
        assert_eq!(*durations.get("building").unwrap(), 3600);
        assert_eq!(*durations.get("testing").unwrap(), 1800);
    }

    #[test]
    fn test_compute_durations_empty() {
        let entries: Vec<HistoryEntry> = vec![];
        let (durations, total) = compute_durations(&entries);
        assert_eq!(total, 0);
        assert!(durations.is_empty());
    }

    #[test]
    fn test_compute_durations_single() {
        let entries = vec![HistoryEntry {
            timestamp: "2025-01-15T10:00:00+0000".to_string(),
            status: "idle".to_string(),
        }];
        let (durations, total) = compute_durations(&entries);
        assert_eq!(total, 0);
        assert_eq!(*durations.get("idle").unwrap(), 0);
    }
}

/// Print an ASCII bar chart of time spent in each status for a tab.
pub fn report(tab_id: &str) {
    let hfile = history_dir().join(format!("{}.yaml", tab_id));
    let content = match fs::read_to_string(&hfile) {
        Ok(c) => c,
        Err(_) => {
            eprintln!("No history for tab {}", tab_id);
            return;
        }
    };

    println!("Status Distribution (tab {}):", tab_id);

    let entries = parse_entries(&content);
    if entries.is_empty() {
        println!("  (no entries)");
        return;
    }

    let (durations, total) = compute_durations(&entries);
    let total = if total == 0 { 1 } else { total };

    // Sort by duration descending
    let mut sorted: Vec<(String, i64)> = durations.into_iter().collect();
    sorted.sort_by(|a, b| b.1.cmp(&a.1));

    let bar_width = 30;
    for (status, dur) in &sorted {
        let pct = (*dur * 100 / total) as usize;
        let filled = (pct * bar_width / 100).min(bar_width);

        let bar: String = "\u{2588}".repeat(filled)
            + &" ".repeat(bar_width - filled);

        println!(
            "  {:<14} [{}] {:>3}%  {}",
            status,
            bar,
            pct,
            format_duration(*dur)
        );
    }

    // Show associated recordings
    let rec_dir = state_dir().join("recordings").join(tab_id);
    if rec_dir.is_dir() {
        let cast_files: Vec<_> = fs::read_dir(&rec_dir)
            .into_iter()
            .flat_map(|rd| rd.filter_map(|e| e.ok()))
            .filter(|e| {
                e.path()
                    .extension()
                    .and_then(|x| x.to_str())
                    == Some("cast")
            })
            .collect();

        if !cast_files.is_empty() {
            println!("\n  Recordings ({}):", cast_files.len());
            for entry in &cast_files {
                let fname = entry.file_name();
                let fname = fname.to_string_lossy();
                let size = entry.metadata().map(|m| m.len()).unwrap_or(0);
                // Extract status from filename: {timestamp}_{status}.cast
                let status_part = fname
                    .strip_suffix(".cast")
                    .unwrap_or(&fname)
                    .splitn(2, '_')
                    .nth(1)
                    .unwrap_or("unknown");
                println!("    {}  ({} bytes)  [{}]", fname, size, status_part);
            }
            println!("  Path: {}/", rec_dir.display());
        }
    }
}

/// Output Mermaid pie chart syntax for a tab's time-in-state.
pub fn report_mermaid(tab_id: &str) {
    let hfile = history_dir().join(format!("{}.yaml", tab_id));
    let content = match fs::read_to_string(&hfile) {
        Ok(c) => c,
        Err(_) => {
            eprintln!("No history for tab {}", tab_id);
            return;
        }
    };

    let entries = parse_entries(&content);
    if entries.is_empty() {
        return;
    }

    let (durations, total) = compute_durations(&entries);
    let total = if total == 0 { 1 } else { total };

    println!("pie title Time by Status (tab {})", tab_id);
    for (status, dur) in &durations {
        let pct = (*dur * 100 / total).max(1);
        println!("  \"{}\" : {}", status, pct);
    }
}

/// Run the report for all tabs that have history files.
pub fn report_all() {
    let dir = history_dir();
    let entries = match fs::read_dir(&dir) {
        Ok(e) => e,
        Err(_) => {
            eprintln!("No history found.");
            return;
        }
    };

    let mut files: Vec<_> = entries.filter_map(|e| e.ok()).collect();
    files.sort_by_key(|e| e.file_name());

    for entry in files {
        let path = entry.path();
        if path.extension().and_then(|e| e.to_str()) != Some("yaml") {
            continue;
        }
        let content = match fs::read_to_string(&path) {
            Ok(c) => c,
            Err(_) => continue,
        };

        let tab_id = content
            .lines()
            .find_map(|l| l.strip_prefix("tab_id: ").map(|r| strip_quotes(r)))
            .unwrap_or_default();

        if !tab_id.is_empty() {
            println!();
            report(&tab_id);
        }
    }
}
