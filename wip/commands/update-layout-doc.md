# PROJ-LAYOUT.md — Maintenance Guide

## Purpose

`docs/PROJ-LAYOUT.md` provides a **navigable map of the project structure** with concise descriptions of what each directory and key file contains. It helps developers quickly locate code and understand organization.

## Structure

```
docs/
├── PROJ-LAYOUT.md        # Main project tree (keep small)
└── layout/
    ├── src.md            # Detailed breakdowns by directory
    ├── config.md
    ├── scripts.md
    └── ...
```

## What to Include

### Include
- All directories
- Key files (entry points, configs, READMEs)
- Special dotfiles: `.envrc`, `.env.example`, `.editorconfig`, `.nvmrc`, etc.
- Files that must be manually configured

### Exclude
- Files matched by `.gitignore` (node_modules, build outputs, caches)
- Generated files
- IDE-specific files (unless team-standardized)

### Exception Dotfiles to Always Document
```
.envrc              # direnv configuration
.env.example        # environment template
.editorconfig       # editor settings
.nvmrc / .node-version / .tool-versions
.dockerignore
.prettierrc / .eslintrc.*
flake.nix / shell.nix
```

## Content Guidelines

### Tree Format

```
project-root/
├── src/                    # Application source code
│   ├── api/                # HTTP handlers
│   └── core/               # Business logic
├── config/                 # Configuration files
├── scripts/                # Build and utility scripts
├── .envrc                  # direnv — loads environment
└── README.md               # Project entry point
```

### Description Rules

- One-line descriptions, right-aligned or on same line
- Focus on *what it contains* not *how it works*
- Use consistent terminology
- Mark required-to-configure files clearly

## Size Limits

| Location | Target Size | Action When Exceeded |
|----------|-------------|----------------------|
| PROJ-LAYOUT.md | < 150 lines | Extract sections to `layout/` |
| Directory listing | < 10 items | Collapse with summary + link |
| layout/*.md files | < 100 lines | Consider further decomposition |

## When to Extract

Move content to `layout/{directory}.md` when:

1. A directory has more than ~8-10 immediate children to document
2. Files within need more than one-line descriptions
3. The directory has complex internal organization

## Extraction Process

1. Create `docs/layout/{directory-name}.md` with full tree + descriptions
2. Replace in PROJ-LAYOUT.md with:
   ```
   ├── src/                    # Application source → [layout/src.md](layout/src.md)
   ```
3. Keep 2-3 key subdirectories visible for context

## Example PROJ-LAYOUT.md

```markdown
# Project Layout

\`\`\`
myproject/
├── src/                        # Source code → [layout/src.md](layout/src.md)
│   ├── api/                    #   HTTP/GraphQL handlers
│   ├── core/                   #   Business logic
│   └── main.ts                 #   Entry point
├── config/                     # Configuration
│   ├── default.yaml            #   Base config
│   └── production.yaml         #   Production overrides
├── scripts/                    # Tooling → [layout/scripts.md](layout/scripts.md)
│   ├── build.sh
│   └── deploy.sh
├── docs/                       # Documentation
│   ├── PROJ-ARCH.md
│   ├── PROJ-LAYOUT.md
│   └── arch/
├── tests/                      # Test suites
│   ├── unit/
│   └── integration/
├── .envrc                      # direnv — run `direnv allow`
├── .env.example                # Copy to .env and configure
├── flake.nix                   # Nix development environment
├── docker-compose.yml          # Local dev services
├── package.json                # Dependencies and scripts
└── README.md                   # Start here
\`\`\`

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `.env` | Copy from `.env.example`, fill secrets |
| `.envrc` | Run `direnv allow` |
| `config/local.yaml` | Create for local overrides (gitignored) |
```

## Summary File Sync

`docs/PROJ-LAYOUT.summary.md` is a **companion document** that must be kept in sync with `docs/PROJ-LAYOUT.md`:

- **Purpose**: Provides a quick reference of directory structure for tools and agents
- **Content**: Extracted tree from PROJ-LAYOUT.md without detailed descriptions
- **Format**: Plain tree format (code block) with brief annotations
- **Update Rule**: Whenever PROJ-LAYOUT.md structure changes, regenerate or manually update the summary

### Summary Maintenance

1. **After structural changes to PROJ-LAYOUT.md**: Sync the tree in PROJ-LAYOUT.summary.md
2. **Keep trees aligned**: Both files should show the same directory hierarchy
3. **Remove obsolete entries**: Delete directories from summary when they're deleted from main file
4. **Brief descriptions only**: Summary entries may use shorter descriptions than main file

## Maintenance Checklist

- [ ] Tree reflects current project structure
- [ ] PROJ-LAYOUT.summary.md tree is in sync with main file
- [ ] No gitignored files included (except special dotfiles)
- [ ] All `layout/*.md` links are valid
- [ ] Descriptions are concise (one line each)
- [ ] Required-setup files are clearly marked
- [ ] Updated when directory structure changes

## Generating the Tree

Useful commands to generate base tree:

```bash
# Basic tree excluding gitignored
tree -a -I '.git|node_modules|__pycache__|.venv|dist|build|*.pyc'

# With gitignore awareness (if tree supports it)
tree --gitignore

# Using fd
fd -t d --hidden --exclude .git | sort

# Include specific dotfiles
tree -a -I '.git|node_modules' --matchdirs -P '.envrc|.env.example|flake.nix'
```

Then manually add descriptions and prune to appropriate size.
