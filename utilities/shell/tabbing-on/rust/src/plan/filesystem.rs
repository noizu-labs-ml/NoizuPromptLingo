use std::fs;
use std::path::{Path, PathBuf};

use super::types::{Ticket, TicketMetadata, TicketType};

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Map a ticket type to its subdirectory name.
fn type_dir(ticket_type: &TicketType) -> &'static str {
    match ticket_type {
        TicketType::UserStory => "user-stories",
        TicketType::Bug => "bugs",
        TicketType::Task => "tasks",
    }
}

/// Map a ticket type to its ID prefix.
fn id_prefix(ticket_type: &TicketType) -> &'static str {
    match ticket_type {
        TicketType::UserStory => "US",
        TicketType::Bug => "BUG",
        TicketType::Task => "TASK",
    }
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Scan the type subdirectory under `output_dir` for existing files matching
/// `PREFIX-NNN` and return the next ID (e.g. `US-004`).  If the directory is
/// empty or missing, returns `PREFIX-001`.
pub fn get_next_id(ticket_type: &TicketType, output_dir: &str) -> String {
    let prefix = id_prefix(ticket_type);
    let dir = Path::new(output_dir).join(type_dir(ticket_type));

    let mut max_num: u32 = 0;

    if let Ok(entries) = fs::read_dir(&dir) {
        for entry in entries.flatten() {
            let name = entry.file_name();
            let name = name.to_string_lossy();
            // Match PREFIX-NNN at the start of the filename.
            if let Some(rest) = name.strip_prefix(prefix) {
                if let Some(rest) = rest.strip_prefix('-') {
                    // Take leading digits before any further dash or dot.
                    let digits: String =
                        rest.chars().take_while(|c| c.is_ascii_digit()).collect();
                    if let Ok(n) = digits.parse::<u32>() {
                        if n > max_num {
                            max_num = n;
                        }
                    }
                }
            }
        }
    }

    format!("{}-{:03}", prefix, max_num + 1)
}

/// Format ticket metadata as YAML frontmatter (no serde_yaml dependency).
fn format_frontmatter(m: &TicketMetadata) -> String {
    let labels = if m.labels.is_empty() {
        "  []".to_string()
    } else {
        m.labels
            .iter()
            .map(|l| format!("  - {}", l))
            .collect::<Vec<_>>()
            .join("\n")
    };

    format!(
        "id: \"{}\"\n\
         title: \"{}\"\n\
         issue_type: {}\n\
         slug: \"{}\"\n\
         status: {}\n\
         priority: {}\n\
         category: \"{}\"\n\
         labels:\n{}\n\
         created_at: \"{}\"",
        m.id,
        m.title,
        m.issue_type,
        m.slug,
        m.status,
        m.priority,
        m.category,
        labels,
        m.created_at,
    )
}

/// Save a ticket as a Markdown file with YAML frontmatter.
///
/// Creates the type subdirectory if needed.  Returns the full file path on
/// success.
pub fn save_ticket(ticket: &Ticket, output_dir: &str) -> Result<String, String> {
    let target_dir = Path::new(output_dir).join(type_dir(&ticket.metadata.issue_type));

    fs::create_dir_all(&target_dir)
        .map_err(|e| format!("Failed to create {}: {}", target_dir.display(), e))?;

    let id = if ticket.metadata.id.is_empty() {
        get_next_id(&ticket.metadata.issue_type, output_dir)
    } else {
        ticket.metadata.id.clone()
    };

    // Build a version of metadata with the resolved id for frontmatter.
    let mut meta = ticket.metadata.clone();
    meta.id = id.clone();

    let filename = format!("{}-{}.md", id, meta.slug);
    let filepath = target_dir.join(&filename);

    let frontmatter = format_frontmatter(&meta);
    let content = format!("---\n{}\n---\n\n{}", frontmatter, ticket.body);

    fs::write(&filepath, &content)
        .map_err(|e| format!("Failed to write {}: {}", filepath.display(), e))?;

    Ok(filepath.to_string_lossy().into_owned())
}

/// Determine the output directory for saved tickets.
///
/// Resolution order:
/// 1. Explicit `config_output_dir` (from CLI flag or config file)
/// 2. Walk up from cwd looking for a `projects/` parent
/// 3. `config_project` flag: look for `projects/<name>/project-management/`
/// 4. Fallback: `<cwd>/project-management/`
pub fn resolve_output_dir(
    config_output_dir: Option<&str>,
    config_project: Option<&str>,
) -> String {
    // 1. Explicit override
    if let Some(dir) = config_output_dir {
        return dir.to_string();
    }

    let cwd = std::env::current_dir().unwrap_or_else(|_| PathBuf::from("."));
    let cwd_str = cwd.to_string_lossy();

    // 2. Walk ancestors looking for a `projects/<name>` parent.
    {
        let parts: Vec<&str> = cwd_str.split('/').collect();
        for i in (1..parts.len()).rev() {
            if parts[i - 1] == "projects" {
                let project_root = parts[..=i].join("/");
                let pm = format!("{}/project-management", project_root);
                return pm;
            }
        }
    }

    // 3. Explicit --project flag
    if let Some(project) = config_project {
        let project_dir = cwd.join("projects").join(project);
        if project_dir.exists() {
            return project_dir
                .join("project-management")
                .to_string_lossy()
                .into_owned();
        }
    }

    // 4. Fallback
    cwd.join("project-management")
        .to_string_lossy()
        .into_owned()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_type_dir() {
        assert_eq!(type_dir(&TicketType::UserStory), "user-stories");
        assert_eq!(type_dir(&TicketType::Bug), "bugs");
        assert_eq!(type_dir(&TicketType::Task), "tasks");
    }

    #[test]
    fn test_id_prefix() {
        assert_eq!(id_prefix(&TicketType::UserStory), "US");
        assert_eq!(id_prefix(&TicketType::Bug), "BUG");
        assert_eq!(id_prefix(&TicketType::Task), "TASK");
    }

    #[test]
    fn test_format_frontmatter() {
        let meta = TicketMetadata {
            id: "US-001".to_string(),
            title: "Test ticket".to_string(),
            issue_type: TicketType::UserStory,
            slug: "test-ticket".to_string(),
            status: "open".to_string(),
            priority: super::super::types::Priority::P1,
            category: "feature".to_string(),
            labels: vec!["ui".to_string(), "backend".to_string()],
            created_at: "2025-01-15".to_string(),
        };
        let fm = format_frontmatter(&meta);
        assert!(fm.contains("id: \"US-001\""));
        assert!(fm.contains("title: \"Test ticket\""));
        assert!(fm.contains("issue_type: user-story"));
        assert!(fm.contains("priority: P1"));
        assert!(fm.contains("  - ui"));
        assert!(fm.contains("  - backend"));
    }

    #[test]
    fn test_format_frontmatter_empty_labels() {
        let meta = TicketMetadata {
            id: "BUG-001".to_string(),
            title: "Bug".to_string(),
            issue_type: TicketType::Bug,
            slug: "bug".to_string(),
            status: "open".to_string(),
            priority: super::super::types::Priority::P0,
            category: "defect".to_string(),
            labels: vec![],
            created_at: "2025-01-15".to_string(),
        };
        let fm = format_frontmatter(&meta);
        assert!(fm.contains("  []"));
    }

    #[test]
    fn test_get_next_id_empty_dir() {
        let id = get_next_id(&TicketType::UserStory, "/nonexistent/path");
        assert_eq!(id, "US-001");
    }

    #[test]
    fn test_resolve_output_dir_explicit() {
        let dir = resolve_output_dir(Some("/my/custom/dir"), None);
        assert_eq!(dir, "/my/custom/dir");
    }

    #[test]
    fn test_resolve_output_dir_fallback() {
        let dir = resolve_output_dir(None, None);
        assert!(dir.contains("project-management"));
    }
}
