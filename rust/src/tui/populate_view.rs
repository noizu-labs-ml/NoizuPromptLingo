
#[derive(Clone, Debug)]
pub struct PopulateEvent {
    pub name: String,
    pub path: String,
    pub outcome: PopulateOutcome,
}

#[allow(dead_code)]
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum PopulateOutcome {
    Created,
    Updated,
    Unchanged,
    Skipped,
    Error(String),
    Pending,
}

impl PopulateOutcome {
    pub fn symbol(&self) -> &'static str {
        match self {
            Self::Created => "+",
            Self::Updated => "~",
            Self::Unchanged => "=",
            Self::Skipped => "-",
            Self::Error(_) => "✗",
            Self::Pending => "…",
        }
    }
}

/// Simple in-place progress list printed to stdout (no alternate screen)
pub fn print_event(event: &PopulateEvent) {
    use colored::Colorize;

    let sym = event.outcome.symbol();
    let colored_sym = match &event.outcome {
        PopulateOutcome::Created => sym.green().to_string(),
        PopulateOutcome::Updated => sym.cyan().to_string(),
        PopulateOutcome::Unchanged => sym.dimmed().to_string(),
        PopulateOutcome::Skipped => sym.dimmed().to_string(),
        PopulateOutcome::Error(_) => sym.red().to_string(),
        PopulateOutcome::Pending => sym.yellow().to_string(),
    };

    let detail = match &event.outcome {
        PopulateOutcome::Error(msg) => format!("  ERROR: {msg}"),
        _ => String::new(),
    };

    println!(
        "{} {:<45} {}{}",
        colored_sym,
        event.name,
        event.path,
        detail
    );
}
