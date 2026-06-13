# Project Layout

```
auto-sudo/
├── vim.zsh                 # Zsh function shim — auto-elevates vim with sudo for unwritable files
├── docs/                   # Documentation
│   ├── PROJ-LAYOUT.md      # This file — project structure map
│   └── PROJ-LAYOUT.summary.md  # Quick-reference tree
└── README.md               # Project description and purpose
```

## Key Files

| File | Purpose |
|------|---------|
| `vim.zsh` | Source in `.zshrc` to enable auto-sudo vim behavior |
| `README.md` | Describes the auto-sudo concept |

## Usage

Source `vim.zsh` in your shell profile to override the `vim` command with a wrapper that detects write permission and auto-elevates via `sudo` when needed.
