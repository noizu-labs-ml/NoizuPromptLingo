// TUI application (ratatui) — voice memo to ticket workflow.

use crossterm::event::{self, Event, KeyCode, KeyEvent};
use crossterm::execute;
use crossterm::terminal::{
    disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen,
};
use ratatui::prelude::*;
use ratatui::widgets::*;
use std::io;
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

use super::llm::LlmClient;
use super::types::{AppConfig, AppPhase, AppState, Ticket};

// ---------------------------------------------------------------------------
// Background result channel
// ---------------------------------------------------------------------------

enum BackgroundResult {
    TranscriptionDone(Result<String, String>),
    GenerationDone(Result<Ticket, String>),
    SaveDone(Result<String, String>),
}

enum InputResult {
    Continue,
    Quit,
}

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

pub fn run(config: AppConfig) -> Result<(), Box<dyn std::error::Error>> {
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let mut state = AppState::default();
    let (bg_tx, bg_rx) = mpsc::channel::<BackgroundResult>();

    // 0 = type, 1 = priority
    let mut focus_field: usize = 0;

    // Simulated recording state (will be replaced when audio module is real)
    let mut recording_start: Option<std::time::Instant> = None;

    loop {
        // -- Check for background results (non-blocking) --
        if let Ok(result) = bg_rx.try_recv() {
            match result {
                BackgroundResult::TranscriptionDone(Ok(text)) => {
                    state.transcript = text;
                    state.phase = AppPhase::ReviewingTranscript;
                }
                BackgroundResult::TranscriptionDone(Err(e)) => {
                    state.error = Some(e);
                    state.phase = AppPhase::Error;
                }
                BackgroundResult::GenerationDone(Ok(ticket)) => {
                    state.ticket = Some(ticket);
                    state.phase = AppPhase::PreviewingTicket;
                    focus_field = 0;
                }
                BackgroundResult::GenerationDone(Err(e)) => {
                    state.error = Some(e);
                    state.phase = AppPhase::Error;
                }
                BackgroundResult::SaveDone(Ok(path)) => {
                    state.saved_path = Some(path);
                    state.phase = AppPhase::Done;
                }
                BackgroundResult::SaveDone(Err(e)) => {
                    state.error = Some(e);
                    state.phase = AppPhase::Error;
                }
            }
        }

        // -- Update recording duration --
        if let Some(start) = recording_start {
            state.recording_duration = start.elapsed().as_secs();
        }

        // -- Draw --
        terminal.draw(|f| ui(f, &state, focus_field, &config))?;

        // -- Handle input (poll with 100ms timeout for animation) --
        if event::poll(Duration::from_millis(100))? {
            if let Event::Key(key) = event::read()? {
                let result = handle_input(
                    key,
                    &mut state,
                    &mut recording_start,
                    &config,
                    &bg_tx,
                    &mut focus_field,
                    &mut terminal,
                );
                match result {
                    InputResult::Continue => {}
                    InputResult::Quit => break,
                }
            }
        }
    }

    // -- Restore terminal --
    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;
    terminal.show_cursor()?;

    Ok(())
}

// ---------------------------------------------------------------------------
// UI rendering
// ---------------------------------------------------------------------------

fn ui(f: &mut Frame, state: &AppState, focus_field: usize, config: &AppConfig) {
    let chunks = Layout::vertical([
        Constraint::Length(3),  // header
        Constraint::Min(5),    // content
        Constraint::Length(1), // action bar
        Constraint::Length(1), // status line
    ])
    .split(f.area());

    draw_header(f, chunks[0], state, config);
    draw_content(f, chunks[1], state, focus_field);
    draw_action_bar(f, chunks[2], state);
    draw_status_line(f, chunks[3]);
}

fn draw_header(f: &mut Frame, area: Rect, state: &AppState, config: &AppConfig) {
    let project = config
        .project
        .as_deref()
        .unwrap_or("no project");
    let phase_label = match &state.phase {
        AppPhase::Idle => "Idle",
        AppPhase::Recording => "Recording",
        AppPhase::Transcribing => "Transcribing",
        AppPhase::ReviewingTranscript => "Review",
        AppPhase::GeneratingTicket => "Generating",
        AppPhase::PreviewingTicket => "Preview",
        AppPhase::Saving => "Saving",
        AppPhase::Done => "Done",
        AppPhase::Error => "Error",
    };
    let block = Block::bordered()
        .title(format!(" tabbing-plan / {} ", project))
        .title_alignment(Alignment::Left)
        .title_bottom(Line::from(format!(" {} ", phase_label)).right_aligned())
        .border_type(BorderType::Rounded);
    f.render_widget(block, area);
}

fn draw_content(f: &mut Frame, area: Rect, state: &AppState, focus_field: usize) {
    match &state.phase {
        AppPhase::Idle => {
            let text = Paragraph::new("Press r to start recording your memo")
                .alignment(Alignment::Center)
                .block(Block::default().padding(Padding::top(area.height / 2)));
            f.render_widget(text, area);
        }

        AppPhase::Recording => {
            let mins = state.recording_duration / 60;
            let secs = state.recording_duration % 60;

            let mut lines = vec![Line::from(vec![
                Span::styled("● ", Style::default().fg(Color::Red).bold()),
                Span::raw(format!("Recording  {:02}:{:02}", mins, secs)),
            ])];

            // Waveform from amplitude_history
            if !state.amplitude_history.is_empty() {
                let bars: Vec<char> = vec!['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'];
                let wave: String = state
                    .amplitude_history
                    .iter()
                    .rev()
                    .take(area.width as usize)
                    .rev()
                    .map(|&a| {
                        let idx = (a.clamp(0.0, 1.0) * 7.0) as usize;
                        bars[idx]
                    })
                    .collect();
                lines.push(Line::from(Span::styled(
                    wave,
                    Style::default().fg(Color::Cyan),
                )));
            }

            let para = Paragraph::new(lines)
                .block(Block::default().padding(Padding::new(2, 2, 1, 0)));
            f.render_widget(para, area);
        }

        AppPhase::Transcribing => {
            let text = Paragraph::new("⏳ Transcribing audio...")
                .alignment(Alignment::Center)
                .block(Block::default().padding(Padding::top(area.height / 2)));
            f.render_widget(text, area);
        }

        AppPhase::ReviewingTranscript => {
            let block = Block::bordered().title(" Transcript ");
            let para = Paragraph::new(state.transcript.as_str())
                .wrap(Wrap { trim: true })
                .block(block);
            f.render_widget(para, area);
        }

        AppPhase::GeneratingTicket => {
            let text = Paragraph::new("⏳ Generating ticket...")
                .alignment(Alignment::Center)
                .block(Block::default().padding(Padding::top(area.height / 2)));
            f.render_widget(text, area);
        }

        AppPhase::PreviewingTicket => {
            draw_ticket_preview(f, area, state, focus_field);
        }

        AppPhase::Saving => {
            let text = Paragraph::new("⏳ Saving ticket...")
                .alignment(Alignment::Center)
                .block(Block::default().padding(Padding::top(area.height / 2)));
            f.render_widget(text, area);
        }

        AppPhase::Done => {
            let path = state.saved_path.as_deref().unwrap_or("(unknown)");
            let text = Paragraph::new(format!("✅ Ticket saved!\n{}", path))
                .style(Style::default().fg(Color::Green))
                .alignment(Alignment::Center)
                .block(Block::default().padding(Padding::top(area.height / 2)));
            f.render_widget(text, area);
        }

        AppPhase::Error => {
            let msg = state.error.as_deref().unwrap_or("Unknown error");
            let text = Paragraph::new(msg)
                .style(Style::default().fg(Color::Red))
                .wrap(Wrap { trim: true })
                .block(
                    Block::bordered()
                        .title(" Error ")
                        .border_style(Style::default().fg(Color::Red)),
                );
            f.render_widget(text, area);
        }
    }
}

fn draw_ticket_preview(f: &mut Frame, area: Rect, state: &AppState, focus_field: usize) {
    let ticket = match &state.ticket {
        Some(t) => t,
        None => return,
    };

    let chunks = Layout::vertical([
        Constraint::Min(4),    // ticket content
        Constraint::Length(1), // metadata selectors
    ])
    .split(area);

    // Build frontmatter + body preview
    let meta = &ticket.metadata;
    let preview = format!(
        "---\ntitle: {}\ntype: {}\npriority: {}\ncategory: {}\nlabels: [{}]\nstatus: {}\n---\n\n{}",
        meta.title,
        meta.issue_type,
        meta.priority,
        meta.category,
        meta.labels.join(", "),
        meta.status,
        ticket.body
    );

    let block = Block::bordered().title(" Ticket Preview ");
    let para = Paragraph::new(preview)
        .wrap(Wrap { trim: true })
        .block(block);
    f.render_widget(para, chunks[0]);

    // Metadata selector line
    let type_style = if focus_field == 0 {
        Style::default().fg(Color::Yellow).bold()
    } else {
        Style::default()
    };
    let prio_style = if focus_field == 1 {
        Style::default().fg(Color::Yellow).bold()
    } else {
        Style::default()
    };

    let selector = Line::from(vec![
        Span::raw("  Type: "),
        Span::styled(
            format!("◂ {} ▸", meta.issue_type),
            type_style,
        ),
        Span::raw("    Priority: "),
        Span::styled(
            format!("◂ {} ▸", meta.priority),
            prio_style,
        ),
    ]);
    f.render_widget(Paragraph::new(selector), chunks[1]);
}

fn draw_action_bar(f: &mut Frame, area: Rect, state: &AppState) {
    let actions = match &state.phase {
        AppPhase::Idle => "[r] Record  [q] Quit",
        AppPhase::Recording => "[space] Stop  [esc] Cancel",
        AppPhase::Transcribing | AppPhase::GeneratingTicket | AppPhase::Saving => "Working...",
        AppPhase::ReviewingTranscript => "[enter] Generate  [e] Edit  [r] Re-record  [q] Quit",
        AppPhase::PreviewingTicket => {
            "[enter] Save  [tab] Fields  [←/→] Change  [r] Re-record  [q] Quit"
        }
        AppPhase::Done => "[n] New  [q] Quit",
        AppPhase::Error => "[r] Retry  [q] Quit",
    };
    let bar = Paragraph::new(actions)
        .style(Style::default().fg(Color::DarkGray))
        .alignment(Alignment::Center);
    f.render_widget(bar, area);
}

fn draw_status_line(f: &mut Frame, area: Rect) {
    let line = Paragraph::new("tabbing-plan v0.2.0")
        .style(Style::default().fg(Color::DarkGray))
        .alignment(Alignment::Right);
    f.render_widget(line, area);
}

// ---------------------------------------------------------------------------
// Input handling
// ---------------------------------------------------------------------------

fn handle_input(
    key: KeyEvent,
    state: &mut AppState,
    recording_start: &mut Option<std::time::Instant>,
    config: &AppConfig,
    bg_tx: &mpsc::Sender<BackgroundResult>,
    focus_field: &mut usize,
    terminal: &mut Terminal<CrosstermBackend<io::Stdout>>,
) -> InputResult {
    // Global quit on Ctrl-C
    if key.code == KeyCode::Char('c')
        && key.modifiers.contains(crossterm::event::KeyModifiers::CONTROL)
    {
        return InputResult::Quit;
    }

    match &state.phase {
        AppPhase::Idle => match key.code {
            KeyCode::Char('r') => {
                *recording_start = Some(std::time::Instant::now());
                state.amplitude_history.clear();
                state.recording_duration = 0;
                state.phase = AppPhase::Recording;
            }
            KeyCode::Char('q') | KeyCode::Esc => return InputResult::Quit,
            _ => {}
        },

        AppPhase::Recording => match key.code {
            KeyCode::Char(' ') | KeyCode::Enter => {
                *recording_start = None;
                // In the real implementation, audio data would come from the recorder.
                // For now, transition to Transcribing with a stub.
                state.phase = AppPhase::Transcribing;
                spawn_transcription(config, &[], bg_tx);
            }
            KeyCode::Esc => {
                *recording_start = None;
                state.phase = AppPhase::Idle;
            }
            _ => {}
        },

        AppPhase::Transcribing | AppPhase::GeneratingTicket | AppPhase::Saving => {
            // No input during background work (except Ctrl-C handled above)
        }

        AppPhase::ReviewingTranscript => match key.code {
            KeyCode::Enter => {
                state.phase = AppPhase::GeneratingTicket;
                spawn_generation(config, &state.transcript, bg_tx);
            }
            KeyCode::Char('e') => {
                edit_transcript_in_editor(state, terminal);
            }
            KeyCode::Char('r') => {
                reset_for_new_recording(state);
            }
            KeyCode::Char('q') | KeyCode::Esc => return InputResult::Quit,
            _ => {}
        },

        AppPhase::PreviewingTicket => match key.code {
            KeyCode::Enter => {
                state.phase = AppPhase::Saving;
                spawn_save(config, state.ticket.as_ref().unwrap(), bg_tx);
            }
            KeyCode::Tab | KeyCode::BackTab => {
                *focus_field = (*focus_field + 1) % 2;
            }
            KeyCode::Right => {
                cycle_metadata_field(state, *focus_field, true);
            }
            KeyCode::Left => {
                cycle_metadata_field(state, *focus_field, false);
            }
            KeyCode::Char('r') => {
                reset_for_new_recording(state);
            }
            KeyCode::Char('q') | KeyCode::Esc => return InputResult::Quit,
            _ => {}
        },

        AppPhase::Done => match key.code {
            KeyCode::Char('n') => {
                reset_for_new_recording(state);
            }
            KeyCode::Char('q') | KeyCode::Esc => return InputResult::Quit,
            _ => {}
        },

        AppPhase::Error => match key.code {
            KeyCode::Char('r') => {
                state.error = None;
                state.phase = AppPhase::Idle;
            }
            KeyCode::Char('q') | KeyCode::Esc => return InputResult::Quit,
            _ => {}
        },
    }

    InputResult::Continue
}

// ---------------------------------------------------------------------------
// Metadata cycling
// ---------------------------------------------------------------------------

fn cycle_metadata_field(state: &mut AppState, field: usize, forward: bool) {
    if let Some(ref mut ticket) = state.ticket {
        match field {
            0 => {
                ticket.metadata.issue_type = if forward {
                    ticket.metadata.issue_type.next()
                } else {
                    ticket.metadata.issue_type.prev()
                };
            }
            1 => {
                ticket.metadata.priority = if forward {
                    ticket.metadata.priority.next()
                } else {
                    ticket.metadata.priority.prev()
                };
            }
            _ => {}
        }
    }
}

// ---------------------------------------------------------------------------
// State reset
// ---------------------------------------------------------------------------

fn reset_for_new_recording(state: &mut AppState) {
    *state = AppState::default();
}

// ---------------------------------------------------------------------------
// Background task spawners
// ---------------------------------------------------------------------------

fn spawn_transcription(
    config: &AppConfig,
    audio_data: &[u8],
    tx: &mpsc::Sender<BackgroundResult>,
) {
    let api_url = config.api_url.clone();
    let api_key = config.api_key.clone();
    let model = config.whisper_model.clone();
    let data = audio_data.to_vec();
    let tx = tx.clone();

    thread::spawn(move || {
        let client = LlmClient::new(&api_url, &api_key);
        let result = client.transcribe(&data, &model);
        let _ = tx.send(BackgroundResult::TranscriptionDone(result));
    });
}

fn spawn_generation(
    config: &AppConfig,
    transcript: &str,
    tx: &mpsc::Sender<BackgroundResult>,
) {
    let api_url = config.api_url.clone();
    let api_key = config.api_key.clone();
    let model = config.model.clone();
    let type_override = config.ticket_type.clone();
    let text = transcript.to_string();
    let tx = tx.clone();

    thread::spawn(move || {
        let client = LlmClient::new(&api_url, &api_key);
        let result = client.generate_ticket(&text, &model, type_override.as_ref());
        let _ = tx.send(BackgroundResult::GenerationDone(result));
    });
}

fn spawn_save(
    config: &AppConfig,
    ticket: &Ticket,
    tx: &mpsc::Sender<BackgroundResult>,
) {
    let ticket = ticket.clone();
    let output_dir = config.output_dir.clone();
    let tx = tx.clone();

    thread::spawn(move || {
        let result = save_ticket(&ticket, output_dir.as_deref());
        let _ = tx.send(BackgroundResult::SaveDone(result));
    });
}

/// Write ticket to disk as YAML-frontmatter markdown.
fn save_ticket(ticket: &Ticket, output_dir: Option<&str>) -> Result<String, String> {
    let dir = output_dir.unwrap_or("tickets");
    std::fs::create_dir_all(dir).map_err(|e| format!("Cannot create directory: {e}"))?;

    let filename = format!("{}/{}.md", dir, ticket.metadata.slug);
    let meta = &ticket.metadata;

    let content = format!(
        "---\nid: {}\ntitle: \"{}\"\ntype: {}\nslug: {}\nstatus: {}\npriority: {}\ncategory: {}\nlabels: [{}]\ncreated_at: {}\n---\n\n{}",
        meta.id,
        meta.title,
        meta.issue_type,
        meta.slug,
        meta.status,
        meta.priority,
        meta.category,
        meta.labels.iter().map(|l| format!("\"{}\"", l)).collect::<Vec<_>>().join(", "),
        meta.created_at,
        ticket.body
    );

    std::fs::write(&filename, &content).map_err(|e| format!("Failed to write ticket: {e}"))?;
    Ok(filename)
}

// ---------------------------------------------------------------------------
// External editor for transcript
// ---------------------------------------------------------------------------

fn edit_transcript_in_editor(
    state: &mut AppState,
    terminal: &mut Terminal<CrosstermBackend<io::Stdout>>,
) {
    // Restore terminal for the editor
    let _ = disable_raw_mode();
    let _ = execute!(terminal.backend_mut(), LeaveAlternateScreen);
    let _ = terminal.show_cursor();

    let result = (|| -> Result<String, String> {
        let tmp_dir = std::env::temp_dir();
        let tmp_path = tmp_dir.join("tabbing-plan-transcript.md");

        std::fs::write(&tmp_path, &state.transcript)
            .map_err(|e| format!("Failed to write temp file: {e}"))?;

        let editor = std::env::var("EDITOR").unwrap_or_else(|_| "vi".to_string());

        let status = std::process::Command::new(&editor)
            .arg(&tmp_path)
            .stdin(std::process::Stdio::inherit())
            .stdout(std::process::Stdio::inherit())
            .stderr(std::process::Stdio::inherit())
            .status()
            .map_err(|e| format!("Failed to launch {editor}: {e}"))?;

        if !status.success() {
            return Err(format!("{editor} exited with {status}"));
        }

        let edited = std::fs::read_to_string(&tmp_path)
            .map_err(|e| format!("Failed to read edited file: {e}"))?;

        let _ = std::fs::remove_file(&tmp_path);
        Ok(edited)
    })();

    // Re-enter alternate screen + raw mode
    let _ = execute!(terminal.backend_mut(), EnterAlternateScreen);
    let _ = enable_raw_mode();
    let _ = terminal.clear();

    match result {
        Ok(edited) => state.transcript = edited,
        Err(e) => {
            state.error = Some(e);
            state.phase = AppPhase::Error;
        }
    }
}
