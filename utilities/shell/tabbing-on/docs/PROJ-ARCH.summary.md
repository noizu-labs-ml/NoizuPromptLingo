# Project Architecture — Summary

## Overview

Shell utility for terminal tab management. Layered architecture: POSIX shared libraries + shell-specific adapters (Bash/Zsh). Two runtime modes: env mode (shell variables) and dc mode (direnv-config store + background daemon). Integrates with Claude Code IDE and Toggl Track.

## Components

- **lib/render.sh** -- Render pipeline, color/emoji validation, version string
- **lib/core.sh** -- Color/emoji mapping, urgency levels, help, YAML escape
- **lib/terminal.sh** -- Terminal detection (10+ emulators), escape sequence abstraction
- **lib/history.sh** -- Tab ID generation, YAML event logging, search, reporting
- **lib/recording.sh** -- asciinema recording lifecycle
- **lib/session.sh** -- Per-session state persistence via TAB_SESSION-keyed env files
- **lib/todo.sh** -- Per-tab todo CRUD with provider pattern
- **lib/theme.sh** -- Theme loading, listing, custom .theme file support
- **lib/dc.sh** -- direnv-config integration: state read/write, timestamps, daemon lifecycle, SIGUSR1 notification
- **lib/claude.sh** -- Claude Code IDE bridge via FIFO + state file
- **lib/toggl.sh** -- Toggl Track API integration for time entry lifecycle
- **bin/tabbing-daemon** -- Background daemon: polls dc last_update at 200ms, renders title, marquees long status
- **shell/tabbing.zsh** -- Zsh adapter (sources render.sh + dc.sh, 1-based arrays, precmd hook)
- **shell/tabbing.bash** -- Bash adapter (sources render.sh + dc.sh, 0-based arrays, PROMPT_COMMAND hook)
- **bin/tabbing-init** -- Bootstrap: outputs `source` command + TABBING_ROOT export

## Installation

`make install` copies: bin/ → ~/.local/bin/, lib/ → ~/.local/share/tabbing-on/lib/, shell/ → ~/.local/share/tabbing-on/shell/. `tabbing-init` resolves TABBING_ROOT from its own location (source tree or installed).

## State

- **Env mode**: TAB_* environment variables in the current shell session
- **DC mode**: direnv-config key-value store (`dc tab {title,status,highlight,urgency,emoji,theme,last_update}`). `_tabbing_set` writes through to both env var and dc store, bumps last_update, sends SIGUSR1 to daemon
- **Persistent**: YAML files under `$XDG_STATE_HOME/tabbing/` (history, todos, recordings per tab; session env files)
- **Claude bridge**: FIFO pipe + flat state file + PID file per session

## Key Decisions

- POSIX library layer for portability; shell-specific syntax only in adapters
- `_tabbing_set` as single mutation path: env export + dc write-through + timestamp + SIGUSR1
- Render.sh + dc.sh sourced at shell init (lightweight); other libs loaded on demand by bin/ scripts
- DC daemon uses last_update as single change sentinel; SIGUSR1 for instant refresh, 200ms poll for marquee
- Environment variables for env-mode session state; dc store for cross-process/directory-scoped state
- Per-tab isolation via unique TAB_ID; per-session isolation via TAB_SESSION
- No external dependencies (dc and asciinema optional)
- Claude bridge uses FIFO to decouple render pipeline from IDE statusline
