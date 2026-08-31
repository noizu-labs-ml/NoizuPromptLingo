use super::app::{App, Mode, Screen};
use crate::context::codex_fallback_skill_budget_chars;
use crate::kinds::InstallStatus;
use ratatui::layout::{Constraint, Direction, Layout, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, Borders, Clear, List, ListItem, Paragraph, Wrap};
use ratatui::Frame;

// ⟦𓆥𓈶𓇔𓅑⟧ draw :: auto-generated pointer for public function draw
pub fn draw(f: &mut Frame, app: &App) {
    let area = f.area();
    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(3),
            Constraint::Min(5),
            Constraint::Length(2),
        ])
        .split(area);

    draw_header(f, chunks[0], app);

    match app.screen {
        Screen::Profiles => draw_profiles(f, chunks[1], app),
        _ => draw_browse(f, chunks[1], app),
    }

    draw_footer(f, chunks[2], app);

    match app.mode {
        Mode::Help => draw_help(f, area),
        Mode::ConfirmReplace => draw_confirm(f, area, app),
        Mode::EditMeta => draw_edit(f, area, app),
        Mode::Filter => {} // filter shown in header
        Mode::Browse => {}
    }
}

fn draw_header(f: &mut Frame, area: Rect, app: &App) {
    let prov = format_providers(app);
    let filter = if app.mode == Mode::Filter {
        format!("/{}", app.filter)
    } else if !app.filter.is_empty() {
        format!("filter:{} ", app.filter)
    } else {
        String::new()
    };
    let status_f = app
        .status_filter
        .map(|s| format!("status:{} ", s.as_str()))
        .unwrap_or_default();
    let title = format!(
        " skill-manage  {}  ·  {}{}{} ",
        app.screen.title(),
        filter,
        status_f,
        prov
    );
    let block = Block::default()
        .borders(Borders::ALL)
        .title(title)
        .border_style(Style::default().fg(Color::Cyan));
    let inner = block.inner(area);
    f.render_widget(block, area);

    let src = match app.screen.kind() {
        Some(k) => app
            .cfg
            .source_roots(k)
            .first()
            .map(|r| r.path.display().to_string())
            .unwrap_or_else(|| "(no source)".into()),
        None => app
            .catalog_path
            .as_ref()
            .map(|p| p.display().to_string())
            .unwrap_or_else(|| "catalog".into()),
    };
    f.render_widget(
        Paragraph::new(Line::from(vec![
            Span::styled("src ", Style::default().fg(Color::DarkGray)),
            Span::raw(truncate(&src, inner.width as usize)),
        ])),
        inner,
    );
}

fn format_providers(app: &App) -> String {
    app.available_providers
        .iter()
        .map(|p| {
            if *p == app.provider {
                format!("[{}]", p.as_str())
            } else {
                p.as_str().to_string()
            }
        })
        .collect::<Vec<_>>()
        .join(" ")
}

fn draw_browse(f: &mut Frame, area: Rect, app: &App) {
    let cols = Layout::default()
        .direction(Direction::Vertical)
        .constraints([Constraint::Percentage(62), Constraint::Percentage(38)])
        .split(area);

    let visible = cols[0].height.saturating_sub(2) as usize;
    let start = app.list_offset.min(app.filtered.len());
    let end = (start + visible.max(1)).min(app.filtered.len());

    let items: Vec<ListItem> = app.filtered[start..end]
        .iter()
        .enumerate()
        .map(|(i, row_i)| {
            let abs = start + i;
            let row = &app.rows[*row_i];
            let selected = abs == app.selected;
            let glyph = status_glyph(row.status);
            let color = status_color(row.status);
            let tags = if row.tags.is_empty() {
                String::new()
            } else {
                format!(" [{}]", row.tags.join(","))
            };
            let yaml = row
                .frontmatter_name
                .as_ref()
                .map(|n| format!("  ({n})"))
                .unwrap_or_default();
            let line = format!("{glyph} {:<28}{yaml}{tags}", row.name);
            let style = if selected {
                Style::default()
                    .bg(Color::DarkGray)
                    .fg(color)
                    .add_modifier(Modifier::BOLD)
            } else {
                Style::default().fg(color)
            };
            ListItem::new(Line::from(Span::styled(line, style)))
        })
        .collect();

    let list = List::new(items).block(
        Block::default()
            .borders(Borders::ALL)
            .title(format!(
                " {}/{} ",
                if app.filtered.is_empty() {
                    0
                } else {
                    app.selected + 1
                },
                app.filtered.len()
            ))
            .border_style(Style::default().fg(Color::Gray)),
    );
    f.render_widget(list, cols[0]);

    // Detail
    let detail = match app.current_row() {
        Some(row) => {
            let dest = app
                .cfg
                .kind_dir(app.provider, row.source.kind)
                .map(|d| row.source.dest_path(&d).display().to_string())
                .unwrap_or_else(|| "(no dest dir)".into());
            let notes = app
                .catalog
                .meta(row.source.kind, &row.name)
                .and_then(|m| m.notes.clone())
                .unwrap_or_default();
            let wts = app.catalog.work_types_for(row.source.kind, &row.name);
            format!(
                "{}\npath:  {}\ndest:  {}\nstatus: {}  provider: {}\nfrontmatter: {} bytes · {} chars · {} fields\nname: {} chars · title: {} chars · description: {} chars\nwork_types: {}\nnotes: {}",
                row.name,
                row.path.display(),
                dest,
                row.status.as_str(),
                app.provider,
                row.source.frontmatter_bytes,
                row.source.frontmatter_chars,
                row.source.frontmatter_fields,
                row.source
                    .frontmatter_name
                    .as_deref()
                    .map_or(0, |value| value.chars().count()),
                row.source
                    .title
                    .as_deref()
                    .map_or(0, |value| value.chars().count()),
                row.source
                    .description
                    .as_deref()
                    .map_or(0, |value| value.chars().count()),
                if wts.is_empty() {
                    "—".into()
                } else {
                    wts.join(", ")
                },
                if notes.is_empty() { "—" } else { &notes }
            )
        }
        None => "no items".into(),
    };
    f.render_widget(
        Paragraph::new(detail).wrap(Wrap { trim: true }).block(
            Block::default()
                .borders(Borders::ALL)
                .title(" Detail ")
                .border_style(Style::default().fg(Color::Gray)),
        ),
        cols[1],
    );
}

fn draw_profiles(f: &mut Frame, area: Rect, app: &App) {
    let cols = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([Constraint::Percentage(35), Constraint::Percentage(65)])
        .split(area);

    let left_items: Vec<ListItem> = app
        .profile_rows
        .iter()
        .enumerate()
        .map(|(i, pr)| {
            let selected = i == app.profile_selected && !app.focus_right;
            let style = if selected {
                Style::default()
                    .bg(Color::DarkGray)
                    .add_modifier(Modifier::BOLD)
            } else {
                Style::default()
            };
            ListItem::new(Line::from(Span::styled(
                format!(" {:<16} {}", pr.name, truncate(&pr.description, 24)),
                style,
            )))
        })
        .collect();

    f.render_widget(
        List::new(left_items).block(
            Block::default()
                .borders(Borders::ALL)
                .title(" Work types ")
                .border_style(if !app.focus_right {
                    Style::default().fg(Color::Cyan)
                } else {
                    Style::default().fg(Color::Gray)
                }),
        ),
        cols[0],
    );

    let mut lines: Vec<Line> = Vec::new();
    if let Some(pr) = app.current_profile() {
        if let Some(wt) = app.catalog.work_types.get(&pr.name) {
            lines.push(Line::from(Span::styled(
                pr.name.clone(),
                Style::default()
                    .fg(Color::Cyan)
                    .add_modifier(Modifier::BOLD),
            )));
            lines.push(Line::from(wt.description.clone()));
            lines.push(Line::from(""));
            lines.push(Line::from(Span::styled(
                "Bundle",
                Style::default().add_modifier(Modifier::UNDERLINED),
            )));
            let bundle = app.profile_bundle_lines();
            for (i, (kind, name, st)) in bundle.iter().enumerate() {
                let sel = app.focus_right && i == app.bundle_cursor;
                let g = status_glyph(*st);
                let text = format!(" {g} {:<10} {}", kind.as_str(), name);
                let style = if sel {
                    Style::default().bg(Color::DarkGray).fg(status_color(*st))
                } else {
                    Style::default().fg(status_color(*st))
                };
                lines.push(Line::from(Span::styled(text, style)));
            }
            if !wt.editor_profiles.is_empty() {
                lines.push(Line::from(""));
                lines.push(Line::from(Span::styled(
                    "Editor profiles",
                    Style::default().add_modifier(Modifier::UNDERLINED),
                )));
                for ep in &wt.editor_profiles {
                    if let Some(prof) = app.catalog.editor_profiles.get(ep) {
                        lines.push(Line::from(format!(" {ep}: {}", prof.description)));
                        for file in &prof.files {
                            let mark = if file.path.exists() { "ok" } else { "MISSING" };
                            lines.push(Line::from(format!("   [{mark}] {}", file.path.display())));
                        }
                    } else {
                        lines.push(Line::from(format!(" {ep} (unknown)")));
                    }
                }
            }
        }
    } else {
        lines.push(Line::from("No work types in catalog."));
        lines.push(Line::from("Run: skill-manage catalog init"));
    }

    f.render_widget(
        Paragraph::new(lines).wrap(Wrap { trim: false }).block(
            Block::default()
                .borders(Borders::ALL)
                .title(" Bundle · A apply · Space toggle line ")
                .border_style(if app.focus_right {
                    Style::default().fg(Color::Cyan)
                } else {
                    Style::default().fg(Color::Gray)
                }),
        ),
        cols[1],
    );
}

fn draw_footer(f: &mut Frame, area: Rect, app: &App) {
    let (en, dis, real, broken) = app.counts();
    let (frontmatter_bytes, _, codex_chars) = app.context_totals();
    let context = codex_chars.map_or_else(
        || format!("fm {}B", frontmatter_bytes),
        |chars| {
            let limit = codex_fallback_skill_budget_chars();
            let mark = if chars > limit {
                "EXCEEDED"
            } else if chars.saturating_mul(100) >= limit.saturating_mul(80) {
                "NEAR"
            } else {
                "ok"
            };
            format!(
                "fm {}B · codex {}/{}c {}",
                frontmatter_bytes, chars, limit, mark
            )
        },
    );
    let stats = if app.screen == Screen::Profiles {
        format!(
            "{} work types · provider {} · {}",
            app.profile_rows.len(),
            app.provider,
            app.message
        )
    } else {
        format!(
            "{} shown · {} on · {} off · {} real · {} broken · {} · {}",
            app.filtered.len(),
            en,
            dis,
            real,
            broken,
            context,
            app.message
        )
    };
    f.render_widget(
        Paragraph::new(stats).style(Style::default().fg(Color::DarkGray)),
        area,
    );
}

fn draw_help(f: &mut Frame, area: Rect) {
    let help = "\
Keys\n\
  ↑↓/jk     move              space     toggle enable/disable\n\
  r         replace+enable    e         edit catalog meta\n\
  /         filter            f         cycle status filter\n\
  1/2/3     claude/codex/grok p         cycle provider\n\
  Tab       next screen       g         profiles\n\
  A         apply work-type   R         reload\n\
  ?         help              q         quit\n\
\n\
Edit meta: Tab fields · F2 or Ctrl+S save · Esc cancel\n\
Replace:   y confirm · n cancel\n\
\n\
Agents are definition files under $provider/agents — not the providers themselves.\n\
Press Esc or ? to close.";
    let block = centered_rect(70, 70, area);
    f.render_widget(Clear, block);
    f.render_widget(
        Paragraph::new(help).block(
            Block::default()
                .borders(Borders::ALL)
                .title(" Help ")
                .border_style(Style::default().fg(Color::Yellow)),
        ),
        block,
    );
}

fn draw_confirm(f: &mut Frame, area: Rect, app: &App) {
    let name = app
        .pending_replace
        .and_then(|i| app.rows.get(i))
        .map(|r| r.name.as_str())
        .unwrap_or("?");
    let text = format!(
        "\n  '{name}' is a REAL path (unmanaged copy).\n\n  \
         Replace will rename it to *.bak.<timestamp>\n  \
         then create a managed symlink.\n\n  \
         [y] replace    [n] cancel\n"
    );
    let block = centered_rect(60, 40, area);
    f.render_widget(Clear, block);
    f.render_widget(
        Paragraph::new(text).block(
            Block::default()
                .borders(Borders::ALL)
                .title(" Confirm replace ")
                .border_style(Style::default().fg(Color::Yellow)),
        ),
        block,
    );
}

fn draw_edit(f: &mut Frame, area: Rect, app: &App) {
    let name = app.current_row().map(|r| r.name.as_str()).unwrap_or("?");
    let field_style = |i: usize| {
        if app.edit_field == i {
            Style::default()
                .fg(Color::Black)
                .bg(Color::Cyan)
                .add_modifier(Modifier::BOLD)
        } else {
            Style::default()
        }
    };
    let text = vec![
        Line::from(format!(" Edit catalog · {name} ")),
        Line::from(""),
        Line::from(vec![
            Span::raw(" tags:       "),
            Span::styled(format!("{}▋", app.edit_tags), field_style(0)),
        ]),
        Line::from(vec![
            Span::raw(" work_types: "),
            Span::styled(format!("{}▋", app.edit_work_types), field_style(1)),
        ]),
        Line::from(vec![
            Span::raw(" notes:      "),
            Span::styled(format!("{}▋", app.edit_notes), field_style(2)),
        ]),
        Line::from(""),
        Line::from(" Tab next field · F2 / Ctrl+S save · Esc cancel "),
    ];
    let block = centered_rect(72, 50, area);
    f.render_widget(Clear, block);
    f.render_widget(
        Paragraph::new(text).block(
            Block::default()
                .borders(Borders::ALL)
                .title(" Catalog meta ")
                .border_style(Style::default().fg(Color::Magenta)),
        ),
        block,
    );
}

fn status_glyph(s: InstallStatus) -> char {
    match s {
        InstallStatus::Enabled => '●',
        InstallStatus::Disabled => '○',
        InstallStatus::Real => '■',
        InstallStatus::Foreign => '↗',
        InstallStatus::Broken | InstallStatus::MissingSource => '✖',
    }
}

fn status_color(s: InstallStatus) -> Color {
    match s {
        InstallStatus::Enabled => Color::Green,
        InstallStatus::Disabled => Color::DarkGray,
        InstallStatus::Real => Color::Yellow,
        InstallStatus::Foreign => Color::Magenta,
        InstallStatus::Broken | InstallStatus::MissingSource => Color::Red,
    }
}

fn centered_rect(percent_x: u16, percent_y: u16, r: Rect) -> Rect {
    let popup_layout = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Percentage((100 - percent_y) / 2),
            Constraint::Percentage(percent_y),
            Constraint::Percentage((100 - percent_y) / 2),
        ])
        .split(r);
    Layout::default()
        .direction(Direction::Horizontal)
        .constraints([
            Constraint::Percentage((100 - percent_x) / 2),
            Constraint::Percentage(percent_x),
            Constraint::Percentage((100 - percent_x) / 2),
        ])
        .split(popup_layout[1])[1]
}

fn truncate(s: &str, max: usize) -> String {
    if max == 0 {
        return String::new();
    }
    if s.chars().count() <= max {
        return s.to_string();
    }
    let t: String = s.chars().take(max.saturating_sub(1)).collect();
    format!("{t}…")
}
