# Project Layout

Shell utility for managing terminal tab titles, status, todos, and recordings.
Supports Bash 4.0+ and Zsh 5.0+ with a shared POSIX library foundation.

## Installation Paths

| Source | Installed |
|--------|-----------|
| `bin/*` | `~/.local/bin/` |
| `lib/*.sh` | `~/.local/share/tabbing-on/lib/` |
| `shell/tabbing.{bash,zsh}` | `~/.local/share/tabbing-on/shell/` |

```
tabbing-on/
├── bin/                            # Entry points & CLI wrappers → ~/.local/bin/
│   ├── tabbing-init                #   Shell bootstrapper — eval "$(tabbing-init bash|zsh)"
│   ├── tabbing-daemon              #   Background daemon: polls dc, renders title, marquees long status
│   ├── demo-runner                 #   Typewriter-style interactive demo runner
│   ├── _tabbing-wrapper            #   Shared setup: sources adapter + all libs, loads session
│   ├── _tabbing-commit             #   Side-effects helper: history, display, session save
│   ├── tabbing-on                  #   CLI: set/display tab title & status
│   ├── tabbing-status              #   CLI: update status
│   ├── tabbing-style               #   CLI: adjust appearance without changing title/status
│   ├── tabbing-theme               #   CLI: theme browser and selector
│   ├── tabbing-marquee             #   CLI: scrolling marquee text in tab title
│   ├── tabbing-todo                #   CLI: manage todos (supports --list-pending, --export-switch)
│   ├── tabbing-report              #   CLI: time-in-state reports
│   ├── tabbing-history             #   CLI: search/browse history
│   ├── tabbing-recordings          #   CLI: manage recordings
│   ├── tabbing-info                #   CLI: full state dump
│   ├── tabbing-clear               #   CLI: clear history/todos/recordings
│   ├── tabbing-claude-statusline   #   CLI: Claude Code IDE statusline bridge
│   └── tabbing-doctor              #   CLI: check/fix terminal config (Ghostty/Kitty title conflicts)
├── lib/                            # POSIX-compatible shared libraries → ~/.local/share/tabbing-on/lib/
│   ├── render.sh                   #   Render pipeline: emoji, color, display, title escape sequences, version
│   ├── core.sh                     #   Supplementary: emoji list, color list, help, YAML escape
│   ├── terminal.sh                 #   Terminal detection, badge, clear (non-render functions)
│   ├── history.sh                  #   Tab ID generation, YAML history tracking
│   ├── recording.sh                #   asciinema recording lifecycle
│   ├── session.sh                  #   Per-session state persistence (TAB_SESSION-keyed files)
│   ├── todo.sh                     #   Per-tab todo management (provider pattern)
│   ├── theme.sh                    #   Theme loading, listing, custom theme file support
│   ├── dc.sh                       #   direnv-config integration: read/write dc tab state, daemon lifecycle
│   ├── claude.sh                   #   Claude Code IDE bridge via named pipes + state files
│   └── toggl.sh                    #   Toggl time tracking integration
├── shell/                          # Shell-specific thin adapters → ~/.local/share/tabbing-on/shell/
│   ├── tabbing.bash                #   Bash: sources render.sh + dc.sh, defines public functions
│   └── tabbing.zsh                 #   Zsh: sources render.sh + dc.sh, defines public functions
├── examples/                       # Example config files
│   └── themes/                     #   User theme templates
│       ├── my-dark.theme           #     Full 19-key theme example
│       └── minimal.theme           #     Minimal 2-key theme (bg + fg only)
├── demo/                           # Demo scripts
│   ├── showcase.demo               #   Interactive feature walkthrough
│   ├── showcase.cast               #   asciinema recording of demo
│   └── showcase.gif                #   GIF render of demo
├── docs/                           # Documentation
│   ├── PROJ-ARCH.md                #   Architecture: components, diagrams, design decisions
│   ├── PROJ-ARCH.summary.md       #   Architecture quick-reference
│   ├── PROJ-LAYOUT.md              #   This file
│   ├── PROJ-LAYOUT.summary.md     #   Quick-reference tree
│   └── assets/                     #   Documentation images
│       └── title-bar.png           #     Screenshot of tab title bar
├── Makefile                        # make install / make uninstall
├── .gitignore                      # Git ignore rules
├── CLAUDE.md                       # Claude Code project instructions
├── LICENSE                         # MIT (Copyright 2026 Keith Brings)
├── README.md                       # Project entry point
└── TODO.md                         # Roadmap & known limitations
```

## Commands

After `make install` and `eval "$(tabbing-init bash|zsh)"`:

| Command | Purpose |
|---------|---------|
| `tabbing-on [args]` | Set/display tab title, status, color, urgency, emoji |
| `tabbing-status` | Update status with emoji/urgency |
| `tabbing-style` | Adjust appearance without changing title/status |
| `tabbing-theme` | Browse and select themes interactively |
| `tabbing-marquee` | Scrolling marquee text in tab title |
| `tabbing-todo` | Add/list/pick/done todo items |
| `tabbing-report` | ASCII/Mermaid reports of time-in-state |
| `tabbing-history` | Search/browse tab history |
| `tabbing-recordings` | Manage asciinema recordings |
| `tabbing-info` | Full state dump + file paths |
| `tabbing-clear` | Clear history, todos, or recordings |
| `tabbing-daemon` | Background daemon (dc mode): start/stop/status |
| `tabbing-claude-statusline` | Claude Code IDE statusline bridge |
| `tabbing-doctor` | Check/fix terminal config for title conflicts |
| `tabbing-on --version` | Print version (works on all commands) |

## Data Storage

XDG-compliant (`~/.local/state/tabbing/`):

```
~/.local/state/tabbing/
├── history/{TAB_ID}.yaml           # Title/status change log
├── todos/{TAB_ID}.yaml             # Todo items per tab
├── recordings/{TAB_ID}/*.cast      # asciinema recordings
└── sessions/{TAB_SESSION}.env      # Persisted env state for CLI wrappers
```

User config (`~/.config/tabbing-on/` or `$XDG_CONFIG_HOME/tabbing-on/`):

```
~/.config/tabbing-on/
└── themes/*.theme                  # User-defined color themes
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `TAB_TITLE` | Tab title text |
| `TAB_STATUS` | Tab status text |
| `TAB_HIGHLIGHT` | Color name for title highlight |
| `TAB_URGENCY` | 0-5 (0=critical/red, 5=nominal/green) |
| `TAB_EMOJI` | Named emoji (overrides urgency dot) |
| `TAB_BG` | Terminal background color (name or `#RRGGBB`) |
| `TAB_THEME` | Active terminal color theme name |
| `TAB_MARQUEE` | Set to `1` to enable scrolling marquee |
| `TAB_TERMINAL` | Detected terminal emulator |
| `TAB_ID` | Unique tab fingerprint (hex) |
| `TAB_SESSION` | Session fingerprint for state file scoping (hex) |
| `TABBING_ROOT` | Library root directory (set by tabbing-init) |
| `TABBING_ON_DC_MODE` | Set to `1` to enable direnv-config mode |
| `TABBING_DC_DAEMON_PID` | PID of running daemon (set automatically) |
| `TABBING_VERSION` | Version string (defined in lib/render.sh) |
