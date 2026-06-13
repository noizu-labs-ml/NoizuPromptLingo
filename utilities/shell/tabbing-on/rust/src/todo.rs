use std::fs;
use std::io::{self, Write};
use std::path::PathBuf;

use crate::state::state_dir;

/// Return the todo file path for a given tab ID.
pub fn todo_file(tab_id: &str) -> PathBuf {
    let dir = state_dir().join("todos");
    let _ = fs::create_dir_all(&dir);
    dir.join(format!("{}.yaml", tab_id))
}

/// Escape a string for YAML double-quoted values.
fn yaml_escape(s: &str) -> String {
    s.replace('\\', "\\\\").replace('"', "\\\"")
}

/// Read the next_id field from a todo file, defaulting to 1.
fn read_next_id(path: &PathBuf) -> u64 {
    let content = match fs::read_to_string(path) {
        Ok(c) => c,
        Err(_) => return 1,
    };
    for line in content.lines() {
        if let Some(rest) = line.strip_prefix("next_id: ") {
            if let Ok(n) = rest.trim().parse::<u64>() {
                return n;
            }
        }
    }
    1
}

/// Bump the next_id field in a todo file by 1.
fn bump_next_id(path: &PathBuf) {
    let content = match fs::read_to_string(path) {
        Ok(c) => c,
        Err(_) => return,
    };
    let current = read_next_id(path);
    let new_id = current + 1;
    let updated: String = content
        .lines()
        .map(|line| {
            if line.starts_with("next_id: ") {
                format!("next_id: {}", new_id)
            } else {
                line.to_string()
            }
        })
        .collect::<Vec<_>>()
        .join("\n");
    // Preserve trailing newline
    let _ = fs::write(path, format!("{}\n", updated));
}

/// Initialize the todo file if it does not exist.
fn init_file(tab_id: &str, tab_title: &str) {
    let path = todo_file(tab_id);
    if path.exists() {
        return;
    }
    let content = format!(
        "tab_id: \"{}\"\ntask_title: \"{}\"\nnext_id: 1\ntodos:\n",
        yaml_escape(tab_id),
        yaml_escape(tab_title)
    );
    let _ = fs::write(&path, content);
}

/// Add a new todo item to the tab's todo file.
pub fn todo_add(tab_id: &str, tab_title: &str, title: &str, description: &str, emoji: &str, urgency: &str) {
    init_file(tab_id, tab_title);

    let path = todo_file(tab_id);
    let todo_id = read_next_id(&path);
    let ts = chrono::Local::now().format("%Y-%m-%dT%H:%M:%S%z").to_string();

    let mut entry = String::new();
    entry.push_str(&format!("  - id: {}\n", todo_id));
    entry.push_str(&format!("    title: \"{}\"\n", yaml_escape(title)));
    if !description.is_empty() {
        entry.push_str(&format!("    description: \"{}\"\n", yaml_escape(description)));
    }
    if !emoji.is_empty() {
        entry.push_str(&format!("    emoji: \"{}\"\n", yaml_escape(emoji)));
    }
    if !urgency.is_empty() {
        entry.push_str(&format!("    urgency: {}\n", urgency));
    }
    entry.push_str("    status: \"pending\"\n");
    entry.push_str(&format!("    created: \"{}\"\n", ts));

    // Append to file
    let _ = fs::OpenOptions::new()
        .append(true)
        .open(&path)
        .and_then(|mut f| f.write_all(entry.as_bytes()));

    bump_next_id(&path);

    println!("tabbing: added todo #{}: {}", todo_id, title);
}

/// Parsed representation of a single todo item.
struct TodoItem {
    id: String,
    title: String,
    description: String,
    emoji: String,
    urgency: String,
    status: String,
}

/// Parse all todo items from a todo file's content.
fn parse_todos(content: &str) -> Vec<TodoItem> {
    let mut items: Vec<TodoItem> = Vec::new();
    let mut current: Option<TodoItem> = None;

    for line in content.lines() {
        if line.starts_with("  - id: ") {
            if let Some(item) = current.take() {
                items.push(item);
            }
            let id = line.trim_start_matches("  - id: ").trim().to_string();
            current = Some(TodoItem {
                id,
                title: String::new(),
                description: String::new(),
                emoji: String::new(),
                urgency: String::new(),
                status: String::new(),
            });
        } else if let Some(ref mut item) = current {
            if let Some(rest) = line.strip_prefix("    title: ") {
                item.title = strip_yaml_quotes(rest);
            } else if let Some(rest) = line.strip_prefix("    description: ") {
                item.description = strip_yaml_quotes(rest);
            } else if let Some(rest) = line.strip_prefix("    emoji: ") {
                item.emoji = strip_yaml_quotes(rest);
            } else if let Some(rest) = line.strip_prefix("    urgency: ") {
                item.urgency = rest.trim().to_string();
            } else if let Some(rest) = line.strip_prefix("    status: ") {
                item.status = strip_yaml_quotes(rest);
            }
        }
    }
    if let Some(item) = current {
        items.push(item);
    }
    items
}

/// Strip surrounding double quotes and unescape.
fn strip_yaml_quotes(s: &str) -> String {
    let s = s.trim();
    let s = if s.starts_with('"') && s.ends_with('"') && s.len() >= 2 {
        &s[1..s.len() - 1]
    } else {
        s
    };
    s.replace("\\\"", "\"").replace("\\\\", "\\")
}

/// Read the task_title header from a todo file.
fn read_task_title(content: &str) -> String {
    for line in content.lines() {
        if let Some(rest) = line.strip_prefix("task_title: ") {
            return strip_yaml_quotes(rest);
        }
    }
    String::new()
}

/// Print a formatted list of todos with status icons.
pub fn todo_list(tab_id: &str, tab_title: &str) {
    let path = todo_file(tab_id);
    let content = match fs::read_to_string(&path) {
        Ok(c) => c,
        Err(_) => {
            println!("No todos for this tab.");
            return;
        }
    };

    let task_title = read_task_title(&content);
    let display_title = if task_title.is_empty() { tab_title } else { &task_title };
    println!("Todos for: {}\n", display_title);

    let items = parse_todos(&content);
    for item in &items {
        let icon = match item.status.as_str() {
            "done" => "\u{2705}",   // ✅
            "active" => "\u{25b6}", // ▶
            _ => "\u{25cb}",        // ○
        };
        println!("  {} #{:<3} {}", icon, item.id, item.title);
    }
    println!();
}

/// Print pending todos as "id title" lines (for interactive selection).
pub fn todo_pending(tab_id: &str) {
    let path = todo_file(tab_id);
    let content = match fs::read_to_string(&path) {
        Ok(c) => c,
        Err(_) => return,
    };

    let items = parse_todos(&content);
    for item in &items {
        if item.status == "pending" {
            println!("{} {}", item.id, item.title);
        }
    }
}

/// Mark a todo as done. If target_id is empty, find the currently active todo.
pub fn todo_done(tab_id: &str, target_id: &str) {
    let path = todo_file(tab_id);
    let content = match fs::read_to_string(&path) {
        Ok(c) => c,
        Err(_) => {
            eprintln!("tabbing: no todos found");
            return;
        }
    };

    let items = parse_todos(&content);
    let resolved_id = if target_id.is_empty() {
        // Find the active todo
        match items.iter().find(|i| i.status == "active") {
            Some(i) => i.id.clone(),
            None => {
                eprintln!("tabbing: no active todo to mark done (specify an id)");
                return;
            }
        }
    } else {
        target_id.to_string()
    };

    // Rewrite file, changing the target's status to "done"
    let updated = rewrite_status(&content, &resolved_id, "done", None);
    let _ = fs::write(&path, updated);

    println!("tabbing: marked todo #{} as done", resolved_id);
}

/// Switch to a todo: deactivate current active, activate target.
/// Returns (title, emoji, urgency) of the switched-to todo, or None if not found.
pub fn todo_switch(tab_id: &str, target_id: &str) -> Option<(String, String, String)> {
    let path = todo_file(tab_id);
    let content = match fs::read_to_string(&path) {
        Ok(c) => c,
        Err(_) => {
            eprintln!("tabbing: no todos found");
            return None;
        }
    };

    let items = parse_todos(&content);

    // Find the target todo to return its details
    let target_item = items.iter().find(|i| i.id == target_id)?;
    let result = (
        target_item.title.clone(),
        target_item.emoji.clone(),
        target_item.urgency.clone(),
    );

    // Rewrite: deactivate any active todo, activate the target
    let updated = rewrite_status_switch(&content, target_id);
    let _ = fs::write(&path, updated);

    println!("tabbing: switched to todo #{}: {}", target_id, result.0);

    Some(result)
}

/// Rewrite the YAML content, changing the status of a specific todo.
/// Optionally also deactivates any currently active todo.
fn rewrite_status(content: &str, target_id: &str, new_status: &str, _deactivate_active: Option<bool>) -> String {
    let mut result = String::new();
    let mut current_id = String::new();

    for line in content.lines() {
        if line.starts_with("  - id: ") {
            current_id = line.trim_start_matches("  - id: ").trim().to_string();
            result.push_str(line);
            result.push('\n');
        } else if line.starts_with("    status: ") && current_id == target_id {
            result.push_str(&format!("    status: \"{}\"\n", new_status));
        } else {
            result.push_str(line);
            result.push('\n');
        }
    }
    result
}

/// Rewrite the YAML content for a switch operation:
/// - Any "active" status becomes "pending"
/// - The target's "pending" status becomes "active"
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_yaml_escape() {
        assert_eq!(yaml_escape("hello"), "hello");
        assert_eq!(yaml_escape(r#"say "hi""#), r#"say \"hi\""#);
        assert_eq!(yaml_escape(r"back\slash"), r"back\\slash");
    }

    #[test]
    fn test_strip_yaml_quotes() {
        assert_eq!(strip_yaml_quotes(r#""hello""#), "hello");
        assert_eq!(strip_yaml_quotes("hello"), "hello");
        assert_eq!(strip_yaml_quotes(r#""say \"hi\"""#), r#"say "hi""#);
        assert_eq!(strip_yaml_quotes(r#"  "trimmed"  "#), "trimmed");
    }

    #[test]
    fn test_parse_todos_empty() {
        let items = parse_todos("tab_id: \"abc\"\nnext_id: 1\ntodos:\n");
        assert!(items.is_empty());
    }

    #[test]
    fn test_parse_todos_single() {
        let content = r#"tab_id: "abc"
next_id: 2
todos:
  - id: 1
    title: "Fix the bug"
    description: "It crashes on startup"
    emoji: "bug"
    urgency: 2
    status: "pending"
    created: "2025-01-15T10:30:00"
"#;
        let items = parse_todos(content);
        assert_eq!(items.len(), 1);
        assert_eq!(items[0].id, "1");
        assert_eq!(items[0].title, "Fix the bug");
        assert_eq!(items[0].description, "It crashes on startup");
        assert_eq!(items[0].emoji, "bug");
        assert_eq!(items[0].urgency, "2");
        assert_eq!(items[0].status, "pending");
    }

    #[test]
    fn test_parse_todos_multiple() {
        let content = r#"todos:
  - id: 1
    title: "First"
    status: "done"
  - id: 2
    title: "Second"
    status: "active"
  - id: 3
    title: "Third"
    status: "pending"
"#;
        let items = parse_todos(content);
        assert_eq!(items.len(), 3);
        assert_eq!(items[0].title, "First");
        assert_eq!(items[0].status, "done");
        assert_eq!(items[1].title, "Second");
        assert_eq!(items[1].status, "active");
        assert_eq!(items[2].title, "Third");
        assert_eq!(items[2].status, "pending");
    }

    #[test]
    fn test_read_task_title() {
        let content = "tab_id: \"abc\"\ntask_title: \"My Project\"\nnext_id: 1\n";
        assert_eq!(read_task_title(content), "My Project");
    }

    #[test]
    fn test_read_task_title_missing() {
        let content = "tab_id: \"abc\"\nnext_id: 1\n";
        assert_eq!(read_task_title(content), "");
    }

    #[test]
    fn test_read_next_id_default() {
        let path = std::path::PathBuf::from("/nonexistent/path.yaml");
        assert_eq!(read_next_id(&path), 1);
    }

    #[test]
    fn test_rewrite_status() {
        let content = r#"todos:
  - id: 1
    title: "First"
    status: "pending"
  - id: 2
    title: "Second"
    status: "pending"
"#;
        let result = rewrite_status(content, "1", "done", None);
        assert!(result.contains("    status: \"done\""));
        // Second todo should remain pending
        let lines: Vec<&str> = result.lines().collect();
        let second_status = lines.iter().rev().find(|l| l.contains("status:")).unwrap();
        assert!(second_status.contains("pending"));
    }

    #[test]
    fn test_rewrite_status_switch_deactivates_and_activates() {
        let content = r#"todos:
  - id: 1
    title: "First"
    status: "active"
  - id: 2
    title: "Second"
    status: "pending"
"#;
        let result = rewrite_status_switch(content, "2");
        // First should be deactivated to pending
        assert!(result.contains("    status: \"pending\""));
        // Second should be activated
        assert!(result.contains("    status: \"active\""));
    }
}

/// Interactive picker for pending todos.
/// Displays a navigable list; Enter switches to the selected todo.
pub fn todo_pick(tab_id: &str) {
    use crossterm::event::{self, Event, KeyCode};
    use crossterm::terminal::{enable_raw_mode, disable_raw_mode};

    let path = todo_file(tab_id);
    let content = match fs::read_to_string(&path) {
        Ok(c) => c,
        Err(_) => {
            println!("No todos for this tab.");
            return;
        }
    };

    let items = parse_todos(&content);
    let pending: Vec<&TodoItem> = items.iter().filter(|i| i.status == "pending").collect();

    if pending.is_empty() {
        println!("No pending todos.");
        return;
    }

    let mut cursor: usize = 0;
    let mut stdout = io::stdout();

    if enable_raw_mode().is_err() {
        eprintln!("tabbing: failed to enter raw mode");
        return;
    }

    // Hide cursor and draw initial list
    let _ = write!(stdout, "\x1b[?25l");
    draw_pick_list(&mut stdout, &pending, cursor);

    loop {
        if let Ok(Event::Key(key)) = event::read() {
            match key.code {
                KeyCode::Up | KeyCode::Char('k') => {
                    if cursor > 0 {
                        cursor -= 1;
                    }
                }
                KeyCode::Down | KeyCode::Char('j') => {
                    if cursor + 1 < pending.len() {
                        cursor += 1;
                    }
                }
                KeyCode::Enter => {
                    let _ = disable_raw_mode();
                    // Show cursor, clear the picker lines
                    let _ = write!(stdout, "\x1b[?25h");
                    clear_pick_list(&mut stdout, pending.len());
                    let _ = stdout.flush();
                    todo_switch(tab_id, &pending[cursor].id);
                    return;
                }
                KeyCode::Char('q') | KeyCode::Esc => {
                    let _ = disable_raw_mode();
                    let _ = write!(stdout, "\x1b[?25h");
                    clear_pick_list(&mut stdout, pending.len());
                    let _ = stdout.flush();
                    eprintln!("tabbing: cancelled");
                    return;
                }
                _ => {}
            }
            draw_pick_list(&mut stdout, &pending, cursor);
        }
    }
}

/// Render the pick list to stdout, moving the cursor back to overwrite.
fn draw_pick_list(stdout: &mut (impl io::Write + ?Sized), items: &[&TodoItem], cursor: usize) {
    for i in 0..items.len() {
        let marker = if i == cursor { "\u{25b8}" } else { " " };
        let emoji_part = if items[i].emoji.is_empty() {
            String::new()
        } else {
            format!(" [{}]", items[i].emoji)
        };
        let _ = write!(
            stdout,
            "\r\x1b[K  {} #{:<3} {}{}\n",
            marker, items[i].id, items[i].title, emoji_part
        );
    }
    // Move cursor back up to top of list
    if items.len() > 1 {
        let _ = write!(stdout, "\x1b[{}A", items.len());
    } else if !items.is_empty() {
        let _ = write!(stdout, "\x1b[1A");
    }
    let _ = stdout.flush();
}

/// Clear the picker lines from the terminal.
fn clear_pick_list(stdout: &mut impl io::Write, count: usize) {
    for _ in 0..count {
        let _ = write!(stdout, "\r\x1b[K\n");
    }
    if count > 0 {
        let _ = write!(stdout, "\x1b[{}A", count);
    }
}

fn rewrite_status_switch(content: &str, target_id: &str) -> String {
    let mut result = String::new();
    let mut current_id = String::new();

    for line in content.lines() {
        if line.starts_with("  - id: ") {
            current_id = line.trim_start_matches("  - id: ").trim().to_string();
            result.push_str(line);
            result.push('\n');
        } else if line.starts_with("    status: ") {
            let status = strip_yaml_quotes(line.trim_start_matches("    status: "));
            if status == "active" {
                // Deactivate
                result.push_str("    status: \"pending\"\n");
            } else if current_id == target_id && status == "pending" {
                // Activate target
                result.push_str("    status: \"active\"\n");
            } else {
                result.push_str(line);
                result.push('\n');
            }
        } else {
            result.push_str(line);
            result.push('\n');
        }
    }
    result
}
