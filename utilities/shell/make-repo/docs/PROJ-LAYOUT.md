# Project Layout

```
make-repo/
├── bin/
│   └── make-repo               # CLI entry point — bash script (~614 lines)
├── docs/
│   ├── PROJ-LAYOUT.md          # This file
│   └── PROJ-LAYOUT.summary.md  # Compact tree reference
└── README.md                   # Usage guide, CLI flags, env vars, examples
```

## Key Files

| File | Purpose |
|------|---------|
| `bin/make-repo` | Creates or edits GitHub repos via `gh` CLI with interactive confirmation, parent-repo inheritance, team access grants, and env-var configuration |
| `README.md` | Full documentation: install, quick start, precedence rules, all flags and env vars, edit mode, prerequisites |

## Setup

Add `bin/` to your PATH:

```bash
export PATH="$PATH:/path/to/make-repo/bin"
```

Requires: `gh` CLI authenticated (`gh auth login`).
