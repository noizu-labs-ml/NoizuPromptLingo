use std::fmt;

// ---------------------------------------------------------------------------
// AppPhase
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, PartialEq)]
pub enum AppPhase {
    Idle,
    Recording,
    Transcribing,
    ReviewingTranscript,
    GeneratingTicket,
    PreviewingTicket,
    Saving,
    Done,
    Error,
}

// ---------------------------------------------------------------------------
// TicketType
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub enum TicketType {
    #[serde(rename = "user-story")]
    UserStory,
    #[serde(rename = "bug")]
    Bug,
    #[serde(rename = "task")]
    Task,
}

impl fmt::Display for TicketType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            TicketType::UserStory => write!(f, "user-story"),
            TicketType::Bug => write!(f, "bug"),
            TicketType::Task => write!(f, "task"),
        }
    }
}

impl TicketType {
    #[allow(dead_code)]
    pub fn all() -> &'static [Self] {
        &[TicketType::UserStory, TicketType::Bug, TicketType::Task]
    }

    pub fn next(&self) -> Self {
        match self {
            TicketType::UserStory => TicketType::Bug,
            TicketType::Bug => TicketType::Task,
            TicketType::Task => TicketType::UserStory,
        }
    }

    pub fn prev(&self) -> Self {
        match self {
            TicketType::UserStory => TicketType::Task,
            TicketType::Bug => TicketType::UserStory,
            TicketType::Task => TicketType::Bug,
        }
    }
}

// ---------------------------------------------------------------------------
// Priority
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub enum Priority {
    P0,
    P1,
    P2,
    P3,
}

impl fmt::Display for Priority {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Priority::P0 => write!(f, "P0"),
            Priority::P1 => write!(f, "P1"),
            Priority::P2 => write!(f, "P2"),
            Priority::P3 => write!(f, "P3"),
        }
    }
}

impl Priority {
    #[allow(dead_code)]
    pub fn all() -> &'static [Self] {
        &[Priority::P0, Priority::P1, Priority::P2, Priority::P3]
    }

    pub fn next(&self) -> Self {
        match self {
            Priority::P0 => Priority::P1,
            Priority::P1 => Priority::P2,
            Priority::P2 => Priority::P3,
            Priority::P3 => Priority::P0,
        }
    }

    pub fn prev(&self) -> Self {
        match self {
            Priority::P0 => Priority::P3,
            Priority::P1 => Priority::P0,
            Priority::P2 => Priority::P1,
            Priority::P3 => Priority::P2,
        }
    }
}

// ---------------------------------------------------------------------------
// TicketMetadata / Ticket
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct TicketMetadata {
    pub id: String,
    pub title: String,
    pub issue_type: TicketType,
    pub slug: String,
    pub status: String,
    pub priority: Priority,
    pub category: String,
    pub labels: Vec<String>,
    pub created_at: String,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct Ticket {
    pub metadata: TicketMetadata,
    pub body: String,
}

// ---------------------------------------------------------------------------
// AppConfig
// ---------------------------------------------------------------------------

pub struct AppConfig {
    pub project: Option<String>,
    pub ticket_type: Option<TicketType>,
    pub api_url: String,
    pub api_key: String,
    pub model: String,
    pub whisper_model: String,
    pub output_dir: Option<String>,
    #[allow(dead_code)]
    pub no_tabbing: bool,
}

// ---------------------------------------------------------------------------
// AppState
// ---------------------------------------------------------------------------

pub struct AppState {
    pub phase: AppPhase,
    pub transcript: String,
    pub ticket: Option<Ticket>,
    pub saved_path: Option<String>,
    pub error: Option<String>,
    pub recording_duration: u64,
    pub amplitude_history: Vec<f32>,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ticket_type_display() {
        assert_eq!(format!("{}", TicketType::UserStory), "user-story");
        assert_eq!(format!("{}", TicketType::Bug), "bug");
        assert_eq!(format!("{}", TicketType::Task), "task");
    }

    #[test]
    fn test_ticket_type_next_cycle() {
        assert_eq!(TicketType::UserStory.next(), TicketType::Bug);
        assert_eq!(TicketType::Bug.next(), TicketType::Task);
        assert_eq!(TicketType::Task.next(), TicketType::UserStory);
    }

    #[test]
    fn test_ticket_type_prev_cycle() {
        assert_eq!(TicketType::UserStory.prev(), TicketType::Task);
        assert_eq!(TicketType::Bug.prev(), TicketType::UserStory);
        assert_eq!(TicketType::Task.prev(), TicketType::Bug);
    }

    #[test]
    fn test_ticket_type_all() {
        let all = TicketType::all();
        assert_eq!(all.len(), 3);
    }

    #[test]
    fn test_priority_display() {
        assert_eq!(format!("{}", Priority::P0), "P0");
        assert_eq!(format!("{}", Priority::P3), "P3");
    }

    #[test]
    fn test_priority_next_cycle() {
        assert_eq!(Priority::P0.next(), Priority::P1);
        assert_eq!(Priority::P3.next(), Priority::P0);
    }

    #[test]
    fn test_priority_prev_cycle() {
        assert_eq!(Priority::P0.prev(), Priority::P3);
        assert_eq!(Priority::P1.prev(), Priority::P0);
    }

    #[test]
    fn test_priority_all() {
        let all = Priority::all();
        assert_eq!(all.len(), 4);
    }
}

impl Default for AppState {
    fn default() -> Self {
        Self {
            phase: AppPhase::Idle,
            transcript: String::new(),
            ticket: None,
            saved_path: None,
            error: None,
            recording_duration: 0,
            amplitude_history: Vec::new(),
        }
    }
}
