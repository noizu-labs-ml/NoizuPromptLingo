# Project Layout — Summary

```
tabbing-on/
├── bin/                            # CLI commands → ~/.local/bin/
│   ├── tabbing-init                #   Shell bootstrapper
│   ├── tabbing-daemon              #   Background daemon (dc mode)
│   ├── demo-runner                 #   Demo runner
│   ├── _tabbing-wrapper            #   Shared setup (sources adapter + all libs)
│   ├── _tabbing-commit             #   Side-effects helper for thin adapter
│   ├── tabbing-on                  #   CLI: set title & status
│   ├── tabbing-status              #   CLI: update status
│   ├── tabbing-style               #   CLI: adjust appearance
│   ├── tabbing-theme               #   CLI: theme browser/selector
│   ├── tabbing-marquee             #   CLI: scrolling marquee text
│   ├── tabbing-todo                #   CLI: manage todos
│   ├── tabbing-report              #   CLI: reports
│   ├── tabbing-history             #   CLI: history
│   ├── tabbing-recordings          #   CLI: recordings
│   ├── tabbing-info                #   CLI: state dump
│   ├── tabbing-clear               #   CLI: clear data
│   ├── tabbing-claude-statusline   #   CLI: Claude Code IDE statusline bridge
│   └── tabbing-doctor              #   CLI: check/fix terminal config
├── lib/                            # POSIX shared libraries → ~/.local/share/tabbing-on/lib/
│   ├── render.sh                   #   Render pipeline + version (sourced at init)
│   ├── core.sh                     #   Emoji/color lists, help, YAML escape
│   ├── terminal.sh                 #   Terminal detection, badge, clear
│   ├── history.sh                  #   Tab history tracking
│   ├── recording.sh                #   asciinema integration
│   ├── session.sh                  #   Session state persistence
│   ├── todo.sh                     #   Todo management
│   ├── theme.sh                    #   Theme loading, listing, custom themes
│   ├── dc.sh                       #   direnv-config: dc state, timestamps, daemon lifecycle
│   ├── claude.sh                   #   Claude Code IDE bridge (FIFO + state)
│   └── toggl.sh                    #   Toggl time tracking integration
├── shell/                          # Shell adapters → ~/.local/share/tabbing-on/shell/
│   ├── tabbing.bash                #   Bash adapter (sources render.sh + dc.sh)
│   └── tabbing.zsh                 #   Zsh adapter (sources render.sh + dc.sh)
├── examples/themes/                # User theme templates (.theme files)
├── demo/                           # Demo scripts & outputs
├── docs/                           # Documentation
├── Makefile                        # make install / make uninstall
├── CLAUDE.md                       # Claude Code instructions
├── LICENSE                         # MIT
├── README.md                       # Project entry point
└── TODO.md                         # Roadmap
```
