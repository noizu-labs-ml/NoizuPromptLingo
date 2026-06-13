mod bridge;
mod claude;
mod color;
mod daemon;
mod demo;
mod doctor;
mod emoji;
mod history;
mod init;
mod marquee;
mod recording;
mod render;
mod state;
mod terminal;
mod theme;
mod theme_picker;
mod todo;
mod plan;
mod toggl;

use std::env;
use std::process;

const VERSION: &str = "0.2.0";

fn main() {
    let argv0 = env::args()
        .next()
        .unwrap_or_default()
        .rsplit('/')
        .next()
        .unwrap_or("tabbing-on")
        .to_string();

    match argv0.as_str() {
        "tabbing-on" => cmd_tabbing_on(),
        "tabbing-off" => cmd_tabbing_off(),
        "tabbing-status" => cmd_tabbing_status(),
        "tabbing-info" => cmd_tabbing_info(),
        "tabbing-clear" => cmd_tabbing_clear(),
        "tabbing-todo" => cmd_tabbing_todo(),
        "tabbing-report" => cmd_tabbing_report(),
        "tabbing-history" => cmd_tabbing_history(),
        "tabbing-recordings" => cmd_tabbing_recordings(),
        "tabbing-doctor" => { doctor::run_doctor(); }
        "tabbing-marquee" => { marquee::run_marquee(&env::args().skip(1).collect::<Vec<_>>()); }
        "tabbing-init" => { init::run_init(&env::args().skip(1).collect::<Vec<_>>()); }
        "demo-runner" => { demo::run_demo(&env::args().skip(1).collect::<Vec<_>>()); }
        "tabbing-style" => cmd_tabbing_style(),
        "tabbing-theme" => cmd_tabbing_theme(),
        "tabbing-claude-statusline" => { claude::run_claude_statusline(); }
        "tabbing-plan" | "task-memo" => cmd_tabbing_plan(),
        "tabbing-daemon" => { daemon::run_daemon(&env::args().skip(1).collect::<Vec<_>>()); }
        _ => cmd_tabbing_on(),
    }
}

fn cmd_tabbing_on() {
    let args: Vec<String> = env::args().skip(1).collect();

    if args.is_empty() {
        let mut s = state::TabState::from_env();
        s.load();
        render::display(&s);
        return;
    }

    // Single-arg subcommands
    if args.len() == 1 {
        match args[0].as_str() {
            "--version" | "-V" => {
                println!("tabbing-on {}", VERSION);
                return;
            }
            "--help" => {
                print_help();
                return;
            }
            "help" => {
                print_help();
                return;
            }
            "emojis" | "emoji-list" | "--emoji-list" | "--emojis" | "-emojis" => {
                emoji::emoji_list();
                return;
            }
            "colors" | "color-list" | "--color-list" | "--colors" => {
                color::color_list();
                return;
            }
            "--terminal-info" => {
                let t = terminal::detect();
                terminal::terminal_info(&t);
                return;
            }
            _ => {}
        }
    }

    // Check for emoji search: -emoji:FILTER
    for arg in &args {
        if let Some(filter) = arg.strip_prefix("-emoji:") {
            emoji::emoji_search(filter);
            return;
        }
        if let Some(filter) = arg.strip_prefix("--emoji-search=") {
            emoji::emoji_search(filter);
            return;
        }
    }

    let mut s = state::TabState::from_env();
    s.load();

    let orig_highlight = s.highlight.clone();
    let orig_urgency = s.urgency.clone();
    let orig_emoji = s.emoji.clone();

    let mut positional: Vec<String> = Vec::new();
    let mut has_record = false;
    let mut has_continue = false;
    let mut has_claude = false;
    let mut run_with_cmd: Option<Vec<String>> = None;
    let mut i = 0;

    while i < args.len() {
        let arg = &args[i];
        match arg.as_str() {
            "--record" => {
                has_record = true;
            }
            "--continue" => {
                has_continue = true;
            }
            "--stop-recording" => {
                recording::record_stop();
                return;
            }
            "--highlight" | "--color" | "-h" => {
                i += 1;
                if i < args.len() {
                    let val = &args[i];
                    if color::color_code_or_raw(val).is_none() {
                        eprintln!("tabbing: unknown color '{}'", val);
                        process::exit(1);
                    }
                    s.highlight = val.clone();
                }
            }
            a if a.starts_with("--highlight=") => {
                let val = a.strip_prefix("--highlight=").unwrap();
                s.highlight = val.to_string();
            }
            a if a.starts_with("--color=") => {
                let val = a.strip_prefix("--color=").unwrap();
                s.highlight = val.to_string();
            }

            "--urgency" | "--pri" | "-p" => {
                i += 1;
                if i < args.len() {
                    validate_urgency(&args[i]);
                    s.urgency = args[i].clone();
                }
            }
            a if a.starts_with("--urgency=") => {
                let val = a.strip_prefix("--urgency=").unwrap();
                validate_urgency(val);
                s.urgency = val.to_string();
            }
            a if a.starts_with("--pri=") => {
                let val = a.strip_prefix("--pri=").unwrap();
                validate_urgency(val);
                s.urgency = val.to_string();
            }

            "--emoji" | "-e" => {
                i += 1;
                if i < args.len() {
                    let val = &args[i];
                    if emoji::emoji_lookup(val).is_none() {
                        eprintln!("tabbing: unknown emoji '{}'", val);
                        process::exit(1);
                    }
                    s.emoji = val.clone();
                }
            }
            a if a.starts_with("--emoji=") => {
                let val = a.strip_prefix("--emoji=").unwrap();
                if emoji::emoji_lookup(val).is_none() {
                    eprintln!("tabbing: unknown emoji '{}'", val);
                    process::exit(1);
                }
                s.emoji = val.to_string();
            }
            "--no-emoji" => s.emoji.clear(),

            "--bg" => {
                i += 1;
                if i < args.len() {
                    s.bg = args[i].clone();
                }
            }
            a if a.starts_with("--bg=") => {
                s.bg = a.strip_prefix("--bg=").unwrap().to_string();
            }
            "--no-bg" => {
                terminal::clear_bg_color();
                s.bg.clear();
            }

            "--theme" => {
                i += 1;
                if i < args.len() {
                    s.theme = args[i].clone();
                }
            }
            a if a.starts_with("--theme=") => {
                s.theme = a.strip_prefix("--theme=").unwrap().to_string();
            }
            "--no-theme" => {
                theme::clear_theme();
                s.theme.clear();
            }

            "--claude" => {
                has_claude = true;
            }

            "--run-with" => {
                i += 1;
                if i < args.len() {
                    run_with_cmd = Some(args[i..].to_vec());
                    break; // remaining args are the command
                }
            }

            "-m" | "--marquee" => s.marquee = true,
            "--no-marquee" => s.marquee = false,

            "--export" => {
                let t = terminal::detect();
                s.terminal = t.as_str().to_string();
                s.ensure_tab_id();
                s.print_exports();
                return;
            }

            // -priN shorthand
            a if a.starts_with("-pri") && a.len() == 5 => {
                let ch = &a[4..5];
                validate_urgency(ch);
                s.urgency = ch.to_string();
            }

            // -COLOR or -EMOJI shorthand
            a if a.starts_with('-')
                && a.len() > 1
                && a.chars().nth(1).map(|c| c.is_ascii_lowercase()).unwrap_or(false) =>
            {
                let name = &a[1..];
                if color::is_known_color(name) {
                    s.highlight = name.to_string();
                } else if emoji::is_known_emoji(name) {
                    s.emoji = name.to_string();
                } else {
                    eprintln!("tabbing: unknown option: {}", a);
                    process::exit(1);
                }
            }

            a if a.starts_with('-') => {
                eprintln!("tabbing: unknown option: {}", a);
                process::exit(1);
            }

            _ => positional.push(arg.clone()),
        }
        i += 1;
    }

    // No positional args and no style changes — display only
    if positional.is_empty()
        && s.highlight == orig_highlight
        && s.urgency == orig_urgency
        && s.emoji == orig_emoji
    {
        render::display(&s);
        return;
    }

    // Apply positional args
    if !positional.is_empty() {
        s.title = positional[0].clone();
        if positional.len() >= 2 {
            s.status = positional[1].clone();
        } else {
            s.status.clear();
        }
    }

    let t = terminal::detect();
    s.terminal = t.as_str().to_string();
    s.ensure_tab_id();

    // Render escape sequences to terminal
    if !s.title.is_empty() {
        render::render_title(&s);
        render::apply_urgency_color(&s, &t);
        render::apply_bg_color(&s);
        if !s.theme.is_empty() {
            theme::apply_named_theme(&s.theme);
        }
    }

    // Display colored state to console (stderr so exports go to stdout)
    render::display_stderr(&s);

    // Persist
    state::record_event(&s, "title");
    s.save();

    // Start recording if requested
    if has_record || has_continue {
        recording::record_start(&s.tab_id, &s.status);
    }

    // Claude bridge: create pipe, write state file, export TABBING_PIPE
    if has_claude {
        if let Some(pipe_path) = bridge::create_pipe(&s.session) {
            println!("export TABBING_PIPE='{}'", pipe_path.display());
            bridge::write_state_file(&s, &s.session);
            // Note: write_state_to_pipe will use the env var, but since
            // we just printed the export (for the calling shell to eval),
            // we set it in-process too so the write works immediately.
            env::set_var("TABBING_PIPE", pipe_path.as_os_str());
            bridge::write_state_to_pipe(&s);
        }
    }

    // --run-with: create a uniquely-named pipe and export it
    if let Some(ref _cmd) = run_with_cmd {
        let run_id = state::generate_id();
        let pipe_name = format!("run-with-{}", run_id);
        if let Some(pipe_path) = bridge::create_pipe(&pipe_name) {
            println!("export TABBING_PIPE='{}'", pipe_path.display());
            env::set_var("TABBING_PIPE", pipe_path.as_os_str());
            bridge::write_state_to_pipe(&s);
        }
    }

    // Always write to pipe if TABBING_PIPE is already set (from a prior --claude invocation)
    if !has_claude && run_with_cmd.is_none() {
        bridge::write_state_to_pipe(&s);
    }

    // Output env exports on stdout for shell eval
    s.print_exports();

    // Toggl Track integration — create/update time entry
    toggl::toggl_on_title_change(&s);
}

fn cmd_tabbing_style() {
    let args: Vec<String> = env::args().skip(1).collect();
    let mut s = state::TabState::from_env();
    s.load();

    if s.title.is_empty() {
        eprintln!("tabbing-style: no TAB_TITLE set — call tabbing-on first");
        process::exit(1);
    }

    // No args — show current style settings
    if args.is_empty() {
        println!("highlight: {}", if s.highlight.is_empty() { "(none)" } else { &s.highlight });
        println!("urgency:   {}", if s.urgency.is_empty() { "(none)" } else { &s.urgency });
        println!("emoji:     {}", if s.emoji.is_empty() { "(none)" } else { &s.emoji });
        println!("bg:        {}", if s.bg.is_empty() { "(none)" } else { &s.bg });
        println!("theme:     {}", if s.theme.is_empty() { "(none)" } else { &s.theme });
        println!("marquee:   {}", if s.marquee { "on" } else { "off" });
        return;
    }

    let mut i = 0;
    while i < args.len() {
        let arg = &args[i];
        match arg.as_str() {
            "--highlight" | "--color" | "-h" => {
                i += 1;
                if i < args.len() {
                    let val = &args[i];
                    if color::color_code_or_raw(val).is_none() {
                        eprintln!("tabbing: unknown color '{}'", val);
                        process::exit(1);
                    }
                    s.highlight = val.clone();
                }
            }
            a if a.starts_with("--highlight=") => {
                let val = a.strip_prefix("--highlight=").unwrap();
                s.highlight = val.to_string();
            }
            a if a.starts_with("--color=") => {
                let val = a.strip_prefix("--color=").unwrap();
                s.highlight = val.to_string();
            }

            "--urgency" | "--pri" | "-p" => {
                i += 1;
                if i < args.len() {
                    validate_urgency(&args[i]);
                    s.urgency = args[i].clone();
                }
            }
            a if a.starts_with("--urgency=") => {
                let val = a.strip_prefix("--urgency=").unwrap();
                validate_urgency(val);
                s.urgency = val.to_string();
            }
            a if a.starts_with("--pri=") => {
                let val = a.strip_prefix("--pri=").unwrap();
                validate_urgency(val);
                s.urgency = val.to_string();
            }

            "--emoji" | "-e" => {
                i += 1;
                if i < args.len() {
                    let val = &args[i];
                    if emoji::emoji_lookup(val).is_none() {
                        eprintln!("tabbing: unknown emoji '{}'", val);
                        process::exit(1);
                    }
                    s.emoji = val.clone();
                }
            }
            a if a.starts_with("--emoji=") => {
                let val = a.strip_prefix("--emoji=").unwrap();
                if emoji::emoji_lookup(val).is_none() {
                    eprintln!("tabbing: unknown emoji '{}'", val);
                    process::exit(1);
                }
                s.emoji = val.to_string();
            }
            "--no-emoji" => s.emoji.clear(),

            "--bg" => {
                i += 1;
                if i < args.len() {
                    s.bg = args[i].clone();
                }
            }
            a if a.starts_with("--bg=") => {
                s.bg = a.strip_prefix("--bg=").unwrap().to_string();
            }
            "--no-bg" => {
                terminal::clear_bg_color();
                s.bg.clear();
            }

            "--theme" => {
                i += 1;
                if i < args.len() {
                    s.theme = args[i].clone();
                }
            }
            a if a.starts_with("--theme=") => {
                s.theme = a.strip_prefix("--theme=").unwrap().to_string();
            }
            "--no-theme" => {
                theme::clear_theme();
                s.theme.clear();
            }

            "-m" | "--marquee" => s.marquee = true,
            "--no-marquee" => s.marquee = false,

            // -priN shorthand
            a if a.starts_with("-pri") && a.len() == 5 => {
                let ch = &a[4..5];
                validate_urgency(ch);
                s.urgency = ch.to_string();
            }

            // -COLOR or -EMOJI shorthand
            a if a.starts_with('-')
                && a.len() > 1
                && a.chars().nth(1).map(|c| c.is_ascii_lowercase()).unwrap_or(false) =>
            {
                let name = &a[1..];
                if color::is_known_color(name) {
                    s.highlight = name.to_string();
                } else if emoji::is_known_emoji(name) {
                    s.emoji = name.to_string();
                } else {
                    eprintln!("tabbing-style: unknown option: {}", a);
                    process::exit(1);
                }
            }

            a if a.starts_with('-') => {
                eprintln!("tabbing-style: unknown option: {}", a);
                process::exit(1);
            }

            _ => {
                eprintln!("tabbing-style: unexpected argument '{}' — use tabbing-on to set title/status", arg);
                process::exit(1);
            }
        }
        i += 1;
    }

    let t = terminal::detect();
    s.terminal = t.as_str().to_string();
    s.ensure_tab_id();

    // Render escape sequences to terminal
    render::render_title(&s);
    render::apply_urgency_color(&s, &t);
    render::apply_bg_color(&s);
    if !s.theme.is_empty() {
        theme::apply_named_theme(&s.theme);
    }

    // Display colored state to console (stderr so exports go to stdout)
    render::display_stderr(&s);

    // Persist
    state::record_event(&s, "style");
    s.save();

    // Output env exports on stdout for shell eval
    s.print_exports();
}

fn cmd_tabbing_off() {
    // Clear terminal visual state
    terminal::clear_bg_color();
    theme::clear_theme();
    terminal::clear_tab_color();
    terminal::clear_badge();
    terminal::clear_title();

    // Stop Toggl tracking before tearing down session
    toggl::toggl_on_off();

    // Remove session file and clean up bridge pipes/state
    if let Ok(session) = env::var("TAB_SESSION") {
        if !session.is_empty() {
            bridge::remove_pipe(&session);

            let path = state::state_dir()
                .join("sessions")
                .join(format!("{}.env", session));
            let _ = std::fs::remove_file(path);
        }
    }

    // Print unset statements to stdout (for eval $(tabbing-off))
    println!("unset TAB_TITLE TAB_STATUS TAB_HIGHLIGHT TAB_URGENCY TAB_EMOJI TAB_BG TAB_THEME TAB_ID TAB_SESSION TAB_TERMINAL TAB_RECORDING");
    println!("unset TABBING_DC_UUID TABBING_DC_DAEMON_PID _TABBING_WAS_ACTIVE CLAUDE_CODE_DISABLE_TERMINAL_TITLE TABBING_PIPE");
    println!("unset TAB_TOGGL_TOKEN TAB_TOGGL_WORKSPACE TAB_TOGGL_PROJECT TAB_TOGGL_TAGS TAB_TOGGL_BILLABLE TAB_TOGGL_ENTRY_ID");

    eprintln!("tabbing: off");
}

fn cmd_tabbing_status() {
    let args: Vec<String> = env::args().skip(1).collect();
    let mut s = state::TabState::from_env();
    s.load();

    if s.title.is_empty() {
        eprintln!("tabbing-status: no TAB_TITLE set — call tabbing-on first");
        process::exit(1);
    }

    let mut positional: Vec<String> = Vec::new();
    let mut i = 0;

    while i < args.len() {
        let arg = &args[i];
        match arg.as_str() {
            "--urgency" | "--pri" | "-p" => {
                i += 1;
                if i < args.len() {
                    validate_urgency(&args[i]);
                    s.urgency = args[i].clone();
                }
            }
            a if a.starts_with("--urgency=") => {
                let val = a.strip_prefix("--urgency=").unwrap();
                validate_urgency(val);
                s.urgency = val.to_string();
            }

            "--emoji" | "-e" => {
                i += 1;
                if i < args.len() {
                    s.emoji = args[i].clone();
                }
            }
            "--no-emoji" => s.emoji.clear(),

            "--theme" => {
                i += 1;
                if i < args.len() {
                    s.theme = args[i].clone();
                }
            }
            a if a.starts_with("--theme=") => {
                s.theme = a.strip_prefix("--theme=").unwrap().to_string();
            }
            "--no-theme" => {
                theme::clear_theme();
                s.theme.clear();
            }

            "-m" | "--marquee" => s.marquee = true,
            "--no-marquee" => s.marquee = false,

            a if a.starts_with("-pri") && a.len() == 5 => {
                let ch = &a[4..5];
                validate_urgency(ch);
                s.urgency = ch.to_string();
            }

            a if a.starts_with('-')
                && a.len() > 1
                && a.chars().nth(1).map(|c| c.is_ascii_lowercase()).unwrap_or(false) =>
            {
                let name = &a[1..];
                if emoji::is_known_emoji(name) {
                    s.emoji = name.to_string();
                } else {
                    eprintln!("tabbing: unknown option: {}", a);
                    process::exit(1);
                }
            }

            a if a.starts_with('-') => {
                eprintln!("tabbing: unknown option: {}", a);
                process::exit(1);
            }

            _ => positional.push(arg.clone()),
        }
        i += 1;
    }

    if !positional.is_empty() {
        s.status = positional[0].clone();
    }

    let t = terminal::detect();

    render::render_title(&s);
    render::apply_urgency_color(&s, &t);
    render::apply_bg_color(&s);
    if !s.theme.is_empty() {
        theme::apply_named_theme(&s.theme);
    }
    render::display_stderr(&s);

    state::record_event(&s, "status");
    s.save();

    // Write to FIFO pipe if TABBING_PIPE is set (from a prior --claude invocation)
    bridge::write_state_to_pipe(&s);

    s.print_exports();

    // Toggl Track integration — update entry description
    toggl::toggl_on_status_change(&s);
}

fn cmd_tabbing_info() {
    let s = state::TabState::from_env();
    let sd = state::state_dir();

    println!("Tab State:");
    println!("  title:     {}", if s.title.is_empty() { "(not set)" } else { &s.title });
    println!("  status:    {}", if s.status.is_empty() { "(not set)" } else { &s.status });
    println!("  highlight: {}", if s.highlight.is_empty() { "(not set)" } else { &s.highlight });
    println!("  urgency:   {}", if s.urgency.is_empty() { "(not set)" } else { &s.urgency });
    println!("  emoji:     {}", if s.emoji.is_empty() { "(not set)" } else { &s.emoji });
    println!("  bg:        {}", if s.bg.is_empty() { "(not set)" } else { &s.bg });
    println!("  theme:     {}", if s.theme.is_empty() { "(not set)" } else { &s.theme });
    println!("  tab_id:    {}", if s.tab_id.is_empty() { "(not set)" } else { &s.tab_id });
    println!("  session:   {}", if s.session.is_empty() { "(not set)" } else { &s.session });
    println!("  terminal:  {}", if s.terminal.is_empty() { "(not set)" } else { &s.terminal });
    println!("  marquee:   {}", if s.marquee { "on" } else { "off" });
    println!();
    println!("Paths:");
    println!("  state_dir: {}", sd.display());
    if !s.tab_id.is_empty() {
        println!("  history:   {}", sd.join("history").join(format!("{}.yaml", s.tab_id)).display());
        println!("  todos:     {}", sd.join("todos").join(format!("{}.yaml", s.tab_id)).display());
    }
    if !s.session.is_empty() {
        println!("  session:   {}", sd.join("sessions").join(format!("{}.env", s.session)).display());
    }
}

fn cmd_tabbing_clear() {
    let args: Vec<String> = env::args().skip(1).collect();
    if args.is_empty() {
        eprintln!("Usage: tabbing-clear history|todos|recordings|all|everything");
        eprintln!();
        eprintln!("  history                 Clear history (current tab)");
        eprintln!("  history --all           Clear history (all tabs)");
        eprintln!("  history --tab ID        Clear history for specific tab");
        eprintln!("  todos                   Clear todos (current tab)");
        eprintln!("  recordings              Clear recordings (current tab)");
        eprintln!("  all                     Clear everything (current tab)");
        eprintln!("  everything              Clear everything (all tabs)");
        process::exit(1);
    }

    let target = &args[0];
    let s = state::TabState::from_env();
    let sd = state::state_dir();

    let mut tab_id = s.tab_id.clone();
    let mut clear_all_tabs = false;

    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "--tab" => {
                i += 1;
                if i < args.len() { tab_id = args[i].clone(); }
            }
            a if a.starts_with("--tab=") => {
                tab_id = a.strip_prefix("--tab=").unwrap().to_string();
            }
            "--all" => clear_all_tabs = true,
            _ => {}
        }
        i += 1;
    }

    match target.as_str() {
        "history" => {
            if clear_all_tabs {
                let dir = sd.join("history");
                if dir.exists() {
                    let _ = std::fs::remove_dir_all(&dir);
                }
                println!("tabbing: cleared history for all tabs");
            } else if !tab_id.is_empty() {
                let path = sd.join("history").join(format!("{}.yaml", tab_id));
                if path.exists() {
                    let _ = std::fs::remove_file(&path);
                }
                println!("tabbing: cleared history for tab {}", tab_id);
            } else {
                eprintln!("tabbing-clear: no TAB_ID set — call tabbing-on first or use --all");
                process::exit(1);
            }
        }
        "todos" => {
            if clear_all_tabs {
                let dir = sd.join("todos");
                if dir.exists() {
                    let _ = std::fs::remove_dir_all(&dir);
                }
                println!("tabbing: cleared todos for all tabs");
            } else if !tab_id.is_empty() {
                let path = sd.join("todos").join(format!("{}.yaml", tab_id));
                if path.exists() {
                    let _ = std::fs::remove_file(&path);
                }
                println!("tabbing: cleared todos for tab {}", tab_id);
            } else {
                eprintln!("tabbing-clear: no TAB_ID set — call tabbing-on first or use --all");
                process::exit(1);
            }
        }
        "recordings" => {
            if clear_all_tabs {
                let dir = sd.join("recordings");
                if dir.exists() {
                    let _ = std::fs::remove_dir_all(&dir);
                }
                println!("tabbing: cleared recordings for all tabs");
            } else if !tab_id.is_empty() {
                let dir = sd.join("recordings").join(&tab_id);
                if dir.exists() {
                    let _ = std::fs::remove_dir_all(&dir);
                }
                println!("tabbing: cleared recordings for tab {}", tab_id);
            } else {
                eprintln!("tabbing-clear: no TAB_ID set — call tabbing-on first or use --all");
                process::exit(1);
            }
        }
        "all" => {
            if !tab_id.is_empty() {
                for sub in ["history", "todos"] {
                    let path = sd.join(sub).join(format!("{}.yaml", tab_id));
                    if path.exists() {
                        let _ = std::fs::remove_file(&path);
                    }
                }
                let rec_dir = sd.join("recordings").join(&tab_id);
                if rec_dir.exists() {
                    let _ = std::fs::remove_dir_all(&rec_dir);
                }
                println!("tabbing: cleared all data for tab {}", tab_id);
            } else {
                eprintln!("tabbing-clear: no TAB_ID set — call tabbing-on first");
                process::exit(1);
            }
        }
        "everything" => {
            for sub in ["history", "todos", "recordings", "sessions"] {
                let dir = sd.join(sub);
                if dir.exists() {
                    let _ = std::fs::remove_dir_all(&dir);
                }
            }
            println!("tabbing: cleared everything for all tabs");
        }
        other => {
            eprintln!("Unknown target: {}", other);
            process::exit(1);
        }
    }
}

fn validate_urgency(val: &str) {
    match val {
        "0" | "1" | "2" | "3" | "4" | "5" => {}
        _ => {
            eprintln!("tabbing: urgency must be 0-5 (0=critical, 5=nominal)");
            process::exit(1);
        }
    }
}

fn cmd_tabbing_todo() {
    let args: Vec<String> = env::args().skip(1).collect();
    let s = state::TabState::from_env();

    if s.title.is_empty() && s.tab_id.is_empty() {
        eprintln!("tabbing-todo: no TAB_TITLE set — call tabbing-on first");
        process::exit(1);
    }

    let tab_id = if s.tab_id.is_empty() { "unknown" } else { &s.tab_id };

    if args.is_empty() {
        todo::todo_list(tab_id, &s.title);
        return;
    }

    match args[0].as_str() {
        "--done" => {
            let id = args.get(1).map(|s| s.as_str()).unwrap_or("");
            todo::todo_done(tab_id, id);
        }
        "--switch" => {
            let id = args.get(1).map(|s| s.as_str()).unwrap_or("");
            if id.is_empty() {
                eprintln!("tabbing-todo: --switch requires a todo ID");
                process::exit(1);
            }
            todo::todo_switch(tab_id, id);
        }
        "--list-pending" => {
            todo::todo_pending(tab_id);
        }
        "--pick" => {
            todo::todo_pick(tab_id);
        }
        _ => {
            let mut title = String::new();
            let mut desc = String::new();
            let mut em = String::new();
            let mut urg = String::new();
            let mut i = 0;
            while i < args.len() {
                match args[i].as_str() {
                    "-m" | "--message" => {
                        i += 1;
                        if i < args.len() { desc = args[i].clone(); }
                    }
                    "-e" | "--emoji" => {
                        i += 1;
                        if i < args.len() { em = args[i].clone(); }
                    }
                    "-p" | "--urgency" | "--pri" => {
                        i += 1;
                        if i < args.len() { urg = args[i].clone(); }
                    }
                    a if a.starts_with('-') && a.len() > 1 => {
                        let name = &a[1..];
                        if emoji::is_known_emoji(name) {
                            em = name.to_string();
                        }
                    }
                    _ => {
                        if title.is_empty() {
                            title = args[i].clone();
                        }
                    }
                }
                i += 1;
            }
            if !title.is_empty() {
                todo::todo_add(tab_id, &s.title, &title, &desc, &em, &urg);
            } else {
                todo::todo_list(tab_id, &s.title);
            }
        }
    }
}

fn cmd_tabbing_report() {
    let args: Vec<String> = env::args().skip(1).collect();
    let s = state::TabState::from_env();

    let mut target_tab = s.tab_id.clone();
    let mut do_mermaid = false;
    let mut do_all = false;
    let mut do_list = false;
    let mut search_query = String::new();

    let mut i = 0;
    while i < args.len() {
        match args[i].as_str() {
            "--mermaid" => do_mermaid = true,
            "--all" => do_all = true,
            "--list" => do_list = true,
            "--tab" => {
                i += 1;
                if i < args.len() { target_tab = args[i].clone(); }
            }
            "--search" => {
                i += 1;
                if i < args.len() { search_query = args[i].clone(); }
            }
            a if a.starts_with("--tab=") => {
                target_tab = a.strip_prefix("--tab=").unwrap().to_string();
            }
            a if a.starts_with("--search=") => {
                search_query = a.strip_prefix("--search=").unwrap().to_string();
            }
            _ => {}
        }
        i += 1;
    }

    if do_list {
        history::history_list_tabs();
    } else if !search_query.is_empty() {
        history::history_search(&search_query);
    } else if do_all {
        // --all --mermaid: iterate tabs and call report_mermaid individually
        if do_mermaid {
            let sd = state::state_dir().join("history");
            if let Ok(entries) = std::fs::read_dir(&sd) {
                for entry in entries.flatten() {
                    let path = entry.path();
                    if path.extension().map(|e| e == "yaml").unwrap_or(false) {
                        if let Some(stem) = path.file_stem() {
                            history::report_mermaid(&stem.to_string_lossy());
                            println!();
                        }
                    }
                }
            }
        } else {
            history::report_all();
        }
    } else if target_tab.is_empty() {
        eprintln!("tabbing-report: no TAB_ID set — call tabbing-on first");
        process::exit(1);
    } else if do_mermaid {
        history::report_mermaid(&target_tab);
    } else {
        history::report(&target_tab);
    }
}

fn cmd_tabbing_history() {
    let args: Vec<String> = env::args().skip(1).collect();
    if args.is_empty() {
        history::history_list_tabs();
    } else {
        history::history_search(&args.join(" "));
    }
}

fn cmd_tabbing_recordings() {
    let args: Vec<String> = env::args().skip(1).collect();
    let s = state::TabState::from_env();
    let mut target_tab = s.tab_id.clone();

    let mut i = 0;
    while i < args.len() {
        match args[i].as_str() {
            "--tab" => {
                i += 1;
                if i < args.len() { target_tab = args[i].clone(); }
            }
            a if a.starts_with("--tab=") => {
                target_tab = a.strip_prefix("--tab=").unwrap().to_string();
            }
            "--start" => {
                if target_tab.is_empty() {
                    eprintln!("tabbing-recordings: no TAB_ID set — call tabbing-on first");
                    process::exit(1);
                }
                recording::record_start(&target_tab, &s.status);
                return;
            }
            "--stop" => {
                recording::record_stop();
                return;
            }
            "--status" => {
                if recording::is_recording() {
                    println!("Recording in progress");
                } else {
                    println!("Not recording");
                }
                return;
            }
            "--to-gif" => {
                if i + 1 < args.len() {
                    let cast = &args[i + 1];
                    let gif = args.get(i + 2).map(|s| s.as_str()).unwrap_or("");
                    recording::recording_to_gif(cast, gif);
                    return;
                } else {
                    eprintln!("tabbing-recordings: --to-gif requires a .cast file path");
                    process::exit(1);
                }
            }
            _ => {}
        }
        i += 1;
    }

    recording::recordings_list(&target_tab);
}

fn cmd_tabbing_theme() {
    let args: Vec<String> = env::args().skip(1).collect();

    if args.is_empty() {
        theme_picker::run_picker();
        return;
    }

    match args[0].as_str() {
        "pick" | "select" => {
            theme_picker::run_picker();
        }
        "list" | "ls" => theme::theme_list(),
        "apply" | "set" => {
            if args.len() < 2 {
                eprintln!("Usage: tabbing-theme apply <name>");
                process::exit(1);
            }
            if theme::apply_named_theme(&args[1]) {
                println!("Theme '{}' applied.", args[1]);
            } else {
                eprintln!("Unknown theme: {}", args[1]);
                process::exit(1);
            }
        }
        "clone" | "copy" => {
            if args.len() < 3 {
                eprintln!("Usage: tabbing-theme clone <source> <new-name>");
                process::exit(1);
            }
            theme_picker::clone_theme(&args[1], &args[2]);
        }
        "edit" => {
            if args.len() < 2 {
                eprintln!("Usage: tabbing-theme edit <name>");
                process::exit(1);
            }
            theme_picker::edit_theme(&args[1]);
        }
        "delete" | "rm" => {
            if args.len() < 2 {
                eprintln!("Usage: tabbing-theme delete <name>");
                process::exit(1);
            }
            theme_picker::delete_theme(&args[1]);
        }
        "export" => {
            if args.len() < 2 {
                eprintln!("Usage: tabbing-theme export <name>");
                process::exit(1);
            }
            theme_picker::export_theme(&args[1]);
        }
        "save" | "envrc" => {
            let theme_name = args.get(1)
                .map(|s| s.as_str())
                .or_else(|| env::var("TAB_THEME").ok().as_deref().map(|_| ""))
                .unwrap_or("");
            let theme_name = if theme_name.is_empty() {
                match env::var("TAB_THEME") {
                    Ok(t) if !t.is_empty() => t,
                    _ => {
                        eprintln!("Usage: tabbing-theme save [theme] [directory]");
                        process::exit(1);
                    }
                }
            } else {
                theme_name.to_string()
            };
            let _dir = args.get(2).map(|s| s.as_str()).unwrap_or(".");
            println!("Theme '{}' — save to .envrc not yet wired from CLI.", theme_name);
        }
        "preview" => {
            if args.len() < 2 {
                eprintln!("Usage: tabbing-theme preview <name>");
                process::exit(1);
            }
            theme_picker::preview_theme(&args[1]);
        }
        "reset" | "clear" => {
            theme::clear_theme();
            println!("Theme cleared. Terminal reset to defaults.");
        }
        "help" | "--help" | "-h" => {
            println!("tabbing-theme — browse, apply, and manage terminal themes");
            println!();
            println!("Usage:");
            println!("  tabbing-theme               Interactive theme picker");
            println!("  tabbing-theme <name>         Apply a theme by name");
            println!("  tabbing-theme list           List all available themes");
            println!("  tabbing-theme apply <name>   Apply a theme");
            println!("  tabbing-theme preview <name> Preview a theme");
            println!("  tabbing-theme clone <src> <name>  Clone to user themes");
            println!("  tabbing-theme edit <name>    Edit a user theme in $EDITOR");
            println!("  tabbing-theme delete <name>  Delete a user theme");
            println!("  tabbing-theme export <name>  Print theme as .theme format");
            println!("  tabbing-theme save [name] [dir]  Write TAB_THEME to .envrc");
            println!("  tabbing-theme reset          Clear theme, restore defaults");
            println!();
            println!("Interactive picker keys:");
            println!("  ↑↓←→/hjkl   Navigate (columns + categories)");
            println!("  /            Search/filter themes by name");
            println!("  Enter        Apply selected theme");
            println!("  c            Clone selected theme");
            println!("  e            Edit selected theme (user themes only)");
            println!("  d            Delete selected theme (user themes only)");
            println!("  r            Reset to terminal defaults");
            println!("  q/Esc        Quit (restore original theme)");
        }
        name => {
            if theme::apply_named_theme(name) {
                println!("Theme '{}' applied.", name);
            } else {
                eprintln!("Unknown theme or subcommand: {}", name);
                process::exit(1);
            }
        }
    }
}

fn cmd_tabbing_plan() {
    let args: Vec<String> = env::args().skip(1).collect();

    let mut project = None;
    let mut ticket_type = None;
    let mut api_url = None;
    let mut api_key = None;
    let mut model = None;
    let mut whisper_model = None;
    let mut output_dir = None;
    let mut no_tabbing = false;

    let mut i = 0;
    while i < args.len() {
        match args[i].as_str() {
            "-p" | "--project" => { i += 1; if i < args.len() { project = Some(args[i].clone()); } }
            "-t" | "--type" => { i += 1; if i < args.len() { ticket_type = Some(args[i].clone()); } }
            "--api-url" => { i += 1; if i < args.len() { api_url = Some(args[i].clone()); } }
            "--api-key" => { i += 1; if i < args.len() { api_key = Some(args[i].clone()); } }
            "--model" => { i += 1; if i < args.len() { model = Some(args[i].clone()); } }
            "--whisper-model" => { i += 1; if i < args.len() { whisper_model = Some(args[i].clone()); } }
            "--output-dir" => { i += 1; if i < args.len() { output_dir = Some(args[i].clone()); } }
            "--no-tabbing" => { no_tabbing = true; }
            "--version" | "-V" => { println!("tabbing-plan {}", VERSION); return; }
            "--help" | "-h" => {
                println!("tabbing-plan {} — Voice memo to structured project ticket", VERSION);
                println!();
                println!("Usage: tabbing-plan [options]");
                println!();
                println!("Options:");
                println!("  -p, --project <name>      Target project");
                println!("  -t, --type <type>         Pre-set ticket type (story|bug|task)");
                println!("  --api-url <url>           LiteLLM endpoint (env: LITELLM_API_URL)");
                println!("  --api-key <key>           API key (env: LITELLM_API_KEY)");
                println!("  --model <model>           Chat model (env: M2T_MODEL)");
                println!("  --whisper-model <model>   STT model (default: whisper-1)");
                println!("  --output-dir <dir>        Override output directory");
                println!("  --no-tabbing              Skip tabbing-on integration");
                return;
            }
            _ => {}
        }
        i += 1;
    }

    if !plan::audio::check_sox_installed() {
        eprintln!("Error: SoX is required for audio recording.");
        eprintln!("Install with:");
        eprintln!("  macOS:  brew install sox");
        eprintln!("  Ubuntu: sudo apt install sox");
        process::exit(1);
    }

    let config = plan::config::resolve_config(
        project, ticket_type, api_url, api_key,
        model, whisper_model, output_dir, no_tabbing,
    );

    if config.api_key.is_empty() {
        eprintln!("Warning: No API key set. Set LITELLM_API_KEY or use --api-key.");
    }

    if let Err(e) = plan::app::run(config) {
        eprintln!("tabbing-plan: {}", e);
        process::exit(1);
    }
}

fn print_help() {
    println!("tabbing-on {} — Terminal tab title, status & task manager", VERSION);
    println!();
    println!("Usage:");
    println!("  tabbing-on [flags] \"title\" \"status\"    Set tab title and status");
    println!("  tabbing-on                             Show current state");
    println!("  tabbing-on emojis                      List available emojis");
    println!("  tabbing-on -emoji:FILTER               Search emojis by name");
    println!("  tabbing-on colors                      List available colors");
    println!("  tabbing-on help                        Show this help");
    println!();
    println!("Flags:");
    println!("  --highlight COLOR, -h COLOR, -COLOR    Set title highlight color");
    println!("  --urgency N, --pri N, -p N, -priN      Set urgency 0-5 (0=critical)");
    println!("  --emoji NAME, -e NAME, -NAME           Set emoji indicator");
    println!("  --no-emoji                             Clear emoji");
    println!("  -emoji:FILTER                          Search emojis by name/alias");
    println!("  -m, --marquee                          Enable scrolling marquee");
    println!("  --no-marquee                           Disable marquee");
    println!("  --bg COLOR                             Set terminal background");
    println!("  --no-bg                                Clear terminal background");
    println!("  --terminal-info                        Show detected terminal");
    println!("  --export                               Output shell export statements");
    println!();
    println!("Related commands:");
    println!("  tabbing-status [flags] \"text\"           Update status only");
    println!("  tabbing-info                             Full tab info");
    println!("  tabbing-clear history|todos|recordings   Clear data");
    println!();
    println!("Examples:");
    println!("  tabbing-on -rocket -blue \"MyApp\" \"deploying\" -p 2");
    println!("  tabbing-status -fire \"hotfix\"");
    println!("  tabbing-on -emoji:fire     # search emojis matching \"fire\"");
    println!();
}
