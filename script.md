# tabbing-on Demo Script

Screen record your terminal while running these commands.
Pause between commands so viewers can see the tab title change.

---

## Act 1: Setup & Help

```bash
# Initialize tabbing-on
eval "$(bin/tabbing-init zsh)"

# Show what we're working with
tabbing-on help

# What emojis are available?
tabbing-on emojis

# What colors?
tabbing-on colors
```

## Act 2: Basic Title & Status

```bash
# Set a tab title with emoji and color highlight
tabbing-on "The Great American Novel" -blue "Pick Genre" -rocket

# Show current state in the terminal
tabbing-on

# Progress through statuses — watch the tab title change
tabbing-status -brain "Research Train Schedules"
tabbing-status -search "Locomotive Black Market"
tabbing-status -coffee "Watch the Station Agent"
tabbing-status -fire "Write hype blog for novel"

# Change urgency on the fly
tabbing-status -pri0 "DEADLINE TOMORROW"
tabbing-on

# Dramatic pivot — new title, red highlight, critical urgency
tabbing-on "Expunge All Traces of Novel" -red "Holding back tears" -pri0
```

## Act 3: Real Work with Todos

```bash
# Start fresh with a real project
tabbing-on "Acme Dashboard" -green "Planning" -gear -pri4

# Add subtasks
tabbing-todo "K8 infra setup" -e gear -m "Deploy to staging cluster"
tabbing-todo "UX Design" -e art -m "Figma mockups for dashboard"
tabbing-todo "Style Guide" -e sparkle
tabbing-todo "Choose Framework" -e search -p 2

# List all todos
tabbing-todo

# Pick one to work on (interactive prompt — type a number)
tabbing-todo --pick

# Show state after switching
tabbing-on

# Mark it done
tabbing-todo --done

# Pick the next one
tabbing-todo --pick
```

## Act 4: Terminal Detection

```bash
# What terminal are we in?
tabbing-on --terminal-info
```

## Act 5: History & Reporting

```bash
# See the time-in-state report (ASCII bar chart)
tabbing-report

# Same data as Mermaid (paste into GitHub markdown, docs, etc.)
tabbing-report --mermaid

# List all known tabs
tabbing-history

# Search history
tabbing-history "Novel"
```

## Act 6: Full Info Dump

```bash
# Everything about this tab: state, file paths, recordings, todos
tabbing-info
```

---

## Features Covered

- [x] `tabbing-on` — title, status, highlight color, urgency, emoji
- [x] `tabbing-on emojis` / `colors` / `help` — discovery
- [x] `tabbing-status` — update status with emoji/urgency
- [x] `tabbing-todo` — add, list, pick, done
- [x] `tabbing-report` — ASCII bar chart, `--mermaid`
- [x] `tabbing-history` — list tabs, search
- [x] `tabbing-info` — full state + file paths
- [x] `--terminal-info` — terminal detection
- [x] Multi-shell: `tabbing-init bash` / `tabbing-init zsh`
