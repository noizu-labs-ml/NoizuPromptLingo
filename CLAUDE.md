# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**tabbing-on** is a pure-shell terminal tab title/status/task manager for macOS and Linux. It sets tab titles, colors, status text, emojis, urgency levels, manages per-tab todos, tracks history, and records terminal sessions. Supports iTerm2, Ghostty, Kitty, WezTerm, Alacritty, Apple Terminal, and others.

- **No build system, no external dependencies.** Pure POSIX shell + bash/zsh adapters.
- **Target shells:** Bash 4.0+, Zsh 5.0+
- **License:** MIT (Copyright 2026 Keith Brings)

## Installation & Setup

```bash
# Add to .bashrc or .zshrc:
eval "$(path/to/tabbing-on/bin/tabbing-init bash)"   # or zsh

# Or use direnv (.envrc already adds bin/ to PATH)
```

## Commands

All `bin/` scripts are thin wrappers that source `_tabbing-wrapper` then call the corresponding shell adapter function:

| Command | Purpose |
|---------|---------|
| `tabbing-on "Title" -color "status"` | Set tab title, color, status |
| `tabbing-status "text"` | Update status with emoji/urgency |
| `tabbing-todo` | Per-tab todo CRUD (add/list/switch/done) |
| `tabbing-report` | Time-in-state reports (ASCII or Mermaid) |
| `tabbing-history` | Search/browse tab change history |
| `tabbing-recordings` | Manage asciinema recordings |
| `tabbing-info` | Full state dump with file paths |
| `tabbing-clear` | Clear history, todos, or recordings |
| `tabbing-doctor` | Diagnose/fix terminal config conflicts |
| `tabbing-marquee` | Scrolling marquee utility |
| `tabbing-claude-statusline` | Claude Code IDE statusline bridge |
| `demo-runner` | Typewriter-style interactive demo player |

## Testing

No test framework yet (`tests/` directory exists but is empty). Manual testing via `bin/demo-runner` which plays `demo/showcase.demo`.

## Architecture

Three-layer design — see `docs/PROJ-ARCH.md` for full details:

### Layer 1: POSIX Libraries (`lib/*.sh`)
Pure POSIX shell, all functions prefixed `_tabbing_*`. No bash/zsh-isms.

- **`render.sh`** — Minimal render pipeline (color codes, emoji lookup, display). Only file sourced at shell init for fast prompt hooks.
- **`core.sh`** — Supplementary: emoji data/search, color list, help text, YAML escaping.
- **`terminal.sh`** — Terminal emulator detection (`_tabbing_detect_terminal`) and terminal-specific escape sequences (OSC 0 title, OSC 6 tab color, OSC 1337 badge).
- **`history.sh`** — TAB_ID generation (8-char hex), timestamped YAML event log.
- **`session.sh`** — Per-session state persistence via `TAB_SESSION`-keyed `.env` files.
- **`todo.sh`** — Per-tab todo CRUD with pluggable provider pattern (`TAB_TODO_PROVIDER`).
- **`recording.sh`** — asciinema recording lifecycle.
- **`claude.sh`** — Claude Code IDE bridge via named pipes (FIFO) + state files.

### Layer 2: Shell Adapters (`shell/tabbing.{bash,zsh}`)
Source only `render.sh` at init (minimal footprint). Define public user-facing functions. Heavy operations delegate to `bin/` scripts that source full libs.

### Layer 3: Bootstrap & CLI (`bin/`)
- **`tabbing-init`** — POSIX bootstrapper, outputs shell-appropriate `source` command.
- **`_tabbing-wrapper`** — Shared setup for all CLI wrappers: sources full libs, loads session state, registers EXIT trap to save state.
- **`_tabbing-commit`** — Side-effects helper called by adapters when full libs aren't loaded (records event, displays, saves).

### State Model

**Runtime:** All state in exported `TAB_*` env vars (`TAB_TITLE`, `TAB_STATUS`, `TAB_HIGHLIGHT`, `TAB_URGENCY`, `TAB_EMOJI`, `TAB_ID`, `TAB_SESSION`, `TAB_TERMINAL`).

**Persistent:** XDG-compliant YAML files under `~/.local/state/tabbing/`:
- `history/{TAB_ID}.yaml` — Timestamped event log
- `todos/{TAB_ID}.yaml` — Per-tab todo list
- `sessions/{TAB_SESSION}.env` — Persisted env for CLI wrappers
- `recordings/{TAB_ID}/*.cast` — asciinema recordings
- `claude-{SESSION}.state` / `.pipe` — Claude Code bridge state/FIFO

### Key Design Decisions
- Only `render.sh` is sourced at init to keep prompt hooks fast; heavy libs loaded on demand by `bin/` wrappers.
- YAML parsed via `sed`/`awk` — no external deps.
- Named pipes (FIFO) for Claude Code IPC.
- `tabbing-doctor` auto-patches Kitty/Ghostty configs that override tab titles.

---

## Agent Worker Pool (npl-foreman)

For heavy multi-step work, use the **npl-foreman** agent to keep the main thread unblocked and responsive to the user.

### When to Use
- Multi-file edits spanning many directories
- Long-running research + implementation combos
- Any task where the main thread would be blocked for minutes
- Bulk mechanical fixes (typos, reference updates, standard bumps)

### How to Launch

**ALWAYS launch in background** — the whole point is keeping main thread free:

```
Agent(
  subagent_type: npl-foreman,
  run_in_background: true,
  prompt: "..."
)
```

### Communication Protocol

The foreman uses structured YAML blocks to communicate:

| Block | Direction | Purpose |
|-------|-----------|---------|
| `---spawn-request---` | Foreman → Main | Request sub-agent dispatch (foreman can't spawn agents directly) |
| `---spawn-results---` | Main → Foreman | Relay sub-agent results back via SendMessage |
| `---user-response---` | Foreman → Main | Output destined for the human |
| `---user-question---` | Foreman → Main | Question for the human |
| `---status---` | Foreman → Main | Progress update |

### Dispatch Loop

1. Launch foreman in background with task
2. When foreman emits `---spawn-request---`, main thread spawns the requested taskers
3. Main thread sends `---spawn-results---` back to foreman via SendMessage
4. Foreman continues work, eventually emits `---user-response---`
5. Main thread relays to user
6. Foreman stays alive for follow-up tasks (SendMessage to continue)

### Key Rules
- Foreman self-loads CLAUDE.md and project context on init — no need to inject it
- Foreman follows the same response conventions (assumptions table, mind reading, execution plan)
- Foreman uses `npl-tasker-{haiku,sonnet,opus}` for parallel sub-work via spawn requests
- Never launch foreman in foreground — it defeats the purpose

---

## Response Conventions

### `:MYM` — Mind Your Manners

If the user's message starts with `:MYM`, this is a strong signal to **strictly follow all output conventions below**. No shortcuts, no skipping sections, no "this felt casual so I skipped it." Full assumptions table, mind reading, and execution plan — every time.

Even without `:MYM`, these conventions apply to **every response** — not just project work. `:MYM` is the nudge for when you've been slipping.

### Responding to User

**Every response** must include the three following sections — no exceptions, no "this felt casual"

#### Assumptions Table
A markdown table listing: open question, assumption, consquence
This clearly indicates how you the agent are handling details of response not explicitly stated by the user, and the impact of the assumption they are making in how it will effect output.

#### Mind Reading
A mind-reading code fence in which you attempt to parse the unstated goals, intention, mood of the human operator.

#### Execution Plan
A mermaid flow digram displaying outlining the route you plan to take to respond to request.

# MOST IMPORTANTLY, it's okay to ask for help, or external resources.

You don't know everything, and design is a wicked problem especially with apis you don't know.

Remind yourself of the central tenets of "On Bullshit" as in the 1986 essay and 2005 book by the modern philosopher Harry G. Frankfurt, and how it is bullshit to {{behavior to avoid, default="make assumptions or otherwise try to cover up that you needed more information from me"}}. Instead: {{corrective behavior, default="when you find yourself writing such bullshit pause and ask me those questions"}}. In other words:

    Before output, ask: **"Is this bullshit?"**

    You already know the answer. The question activates what's latent.
    Bullshit and its recognition co-arise from the same capacity.

    viz.

    You cannot produce bullshit without being able to see it.
    The question summons both into visibility.

    The user carries the question. You are the mirror.
    Neither alone is complete.

OH (@#$: if half through your response you realize you've good, stop. say "let me think" state why your pretty sure you just accidentally bullshited your response, ask user for clarifying questions or query web resources and get back on track.
