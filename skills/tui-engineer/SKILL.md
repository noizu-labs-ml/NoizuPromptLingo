---
name: trl-tui-engineer
description: >
  Design, build, and ship terminal user interfaces across Rust (ratatui),
  Go (bubbletea/lipgloss), C/C++ (ncurses/FTXUI), TypeScript (Ink), Java
  (Lanterna/JLine), and shell (gum/dialog/ANSI). Use this skill when the
  user wants to build a TUI app, design a terminal layout, create a CLI
  dashboard, implement a terminal form or wizard, prototype a curses-based
  interface, add keybindings or mouse support, style terminal output, build
  a REPL, create an interactive log viewer, or set up build tooling for a
  TUI project — even if they don't say "TUI." Also trigger when users
  mention ratatui, bubbletea, lipgloss, charm, ncurses, FTXUI, Ink, Lanterna,
  JLine, blessed, terminal widgets, box-drawing characters, ANSI escape codes,
  crossterm, termion, tcell, or terminal color schemes.
---

# TUI Engineer

Design and build production-quality terminal user interfaces across six language ecosystems with idiomatic build tooling, accessible interaction patterns, and cross-platform support.

## Overview

This skill bridges terminal UI design thinking with multi-language implementation:

- **Design methodology** — Layout grids, color systems, interaction patterns, and accessibility for constrained terminal environments
- **Six language stacks** — Rust, Go, C/C++, TypeScript, Java, and Shell with framework-specific guides
- **Build system coverage** — Cargo, Go modules, Make/CMake, npm/pnpm, Maven/Gradle, and shell packaging
- **Pattern library** — Reusable patterns for dashboards, forms, tables, trees, logs, and wizards
- **Cross-platform concerns** — Windows Terminal, iTerm2, Alacritty, tmux, SSH, and Unicode/emoji handling
- **Testing strategies** — Snapshot testing, headless rendering, golden-file comparison

## Core Philosophy

**Five Principles:**

1. **Terminal is a design medium** — Constraints (cell grid, 256 colors, keyboard-first) are features, not limitations; the best TUIs embrace them
2. **Keyboard-first, mouse-optional** — Every interaction must work without a mouse; mouse support is progressive enhancement
3. **Responsive to terminal size** — Layouts must degrade gracefully from 200×60 to 80×24 to 40×12
4. **Color is information, not decoration** — Use color to encode state, severity, and hierarchy; respect `NO_COLOR` and `TERM` capabilities
5. **Framework-idiomatic code** — Don't fight the framework; Elm Architecture for bubbletea, React model for Ink, immediate-mode for ratatui

## When to Use

- **Building a TUI application** from scratch in any supported language
- **Designing terminal layouts** — deciding on panel arrangements, widget placement, navigation flow
- **Adding interactivity** to a CLI tool — forms, selection lists, progress indicators, confirmations
- **Porting a TUI** between frameworks (e.g., Python curses → Rust ratatui)
- **Debugging rendering issues** — Unicode alignment, color fallback, resize handling, SSH compatibility
- **Setting up build tooling** — CI/CD for TUI projects, cross-compilation, release packaging

> For web-based UIs and design systems, see **trl-user-experience-engineer**.
> For MCP server scaffolding that might need a TUI admin panel, see **trl-mcp-builder**.
> For CLI argument parsing (not TUI), prefer the framework's native CLI library (clap, cobra, commander).

## Supported Stacks

| Language | Primary Framework | Alt Framework | Build System | Reference |
|----------|------------------|---------------|-------------|-----------|
| **Rust** | ratatui + crossterm | cursive | Cargo | [frameworks/rust-ratatui.md](references/frameworks/rust-ratatui.md) |
| **Go** | bubbletea + lipgloss | tview | Go modules | [frameworks/go-bubbletea.md](references/frameworks/go-bubbletea.md) |
| **C/C++** | ncurses / FTXUI | CDK | Make / CMake | [frameworks/cpp-ftxui-ncurses.md](references/frameworks/cpp-ftxui-ncurses.md) |
| **TypeScript** | Ink (React for CLI) | blessed-contrib | npm / pnpm | [frameworks/ts-ink.md](references/frameworks/ts-ink.md) |
| **Java** | Lanterna | JLine 3 | Maven / Gradle | [frameworks/java-lanterna.md](references/frameworks/java-lanterna.md) |
| **Shell** | gum + ANSI | dialog / whiptail | Makefile / script | [frameworks/shell-gum.md](references/frameworks/shell-gum.md) |

### Framework Selection Guide

```
Need maximum performance / systems-level?     → Rust (ratatui)
Need rapid prototyping / Go ecosystem?        → Go (bubbletea)
Need C interop / embedded / legacy?           → C/C++ (ncurses/FTXUI)
Need React devs to build CLI tools?           → TypeScript (Ink)
Need JVM / enterprise / existing Java stack?  → Java (Lanterna)
Need quick script-level interactivity?        → Shell (gum)
```

## Design Patterns

### Layout Primitives

| Pattern | Description | Use When |
|---------|-------------|----------|
| **Full-screen app** | Header + body + footer; body splits into panels | Dashboards, monitors, editors |
| **Wizard / stepper** | Sequential screens with back/next | Onboarding, configuration, setup |
| **Split pane** | Vertical or horizontal division, resizable | File managers, diff viewers |
| **Tabbed interface** | Tab bar + content area | Multi-view applications |
| **Modal overlay** | Centered box over dimmed background | Confirmations, detail views |
| **Streaming log** | Auto-scrolling text with filtering | Log viewers, build output |
| **Form** | Label-input pairs with validation | Data entry, settings |

### Interaction Patterns

| Pattern | Keys | Description |
|---------|------|-------------|
| **Vim navigation** | `hjkl`, `gg`, `G` | List/table movement (opt-in, never default) |
| **Arrow navigation** | `↑↓←→` | Always supported as primary |
| **Tab cycling** | `Tab` / `Shift+Tab` | Focus between widgets/panes |
| **Action keys** | `Enter`, `Space`, `Esc` | Confirm, toggle, cancel |
| **Quick filter** | `/` or `Ctrl+F` | Filter/search within a view |
| **Help overlay** | `?` | Show available keybindings |
| **Quit** | `q` or `Ctrl+C` | Exit (with confirmation for destructive state) |

> For the full pattern library with ASCII mockups, see [references/patterns/layout-patterns.md](references/patterns/layout-patterns.md).
> For interaction design deep-dive, see [references/patterns/interaction-patterns.md](references/patterns/interaction-patterns.md).

### Color System

**Tier 1: Safe everywhere** (8 ANSI colors — works on every terminal):
```
black, red, green, yellow, blue, magenta, cyan, white
```

**Tier 2: Extended palette** (256 colors — most modern terminals):
```
Use for subtle gradients, syntax highlighting, status indicators
```

**Tier 3: True color** (16M colors — iTerm2, Alacritty, Windows Terminal, kitty):
```
Use for branding, rich dashboards, image rendering
```

**Rules:**
- Always implement Tier 1 fallback
- Detect capability via `COLORTERM=truecolor` or `TERM` inspection
- Respect `NO_COLOR` env var (see https://no-color.org/)
- Test in both light and dark terminal themes
- Semantic colors: `error=red`, `warn=yellow`, `success=green`, `info=blue`, `muted=gray`

> For color system details and palette recipes, see [references/patterns/color-systems.md](references/patterns/color-systems.md).

## Build Systems

Each framework reference includes its idiomatic build setup. Cross-cutting concerns:

| Concern | Approach |
|---------|----------|
| **Cross-compilation** | Rust: `cross`; Go: `GOOS/GOARCH`; C: toolchain files; Java: JRE bundling (jlink) |
| **Release packaging** | Rust: `cargo-dist`; Go: `goreleaser`; npm: `pkg`; Java: `jpackage`; Shell: `brew tap` |
| **CI/CD** | GitHub Actions with matrix builds per OS; headless terminal testing |
| **Static linking** | Rust: `musl` target; Go: `CGO_ENABLED=0`; C: `-static` |
| **Version management** | Semantic versioning; embed via build-time injection |

> For build system details per language, see the framework-specific references in `references/frameworks/`.
> For CI/CD templates, see [references/build-systems/ci-templates.md](references/build-systems/ci-templates.md).

## Testing TUIs

| Strategy | Tools | Best For |
|----------|-------|----------|
| **Snapshot testing** | `insta` (Rust), `teatest` (Go), Jest snapshots (TS) | Layout regression |
| **Golden files** | Custom diff against `.golden` files | Pixel-perfect rendering |
| **Headless rendering** | `ratatui::TestBackend`, `teatest`, FTXUI test backend | Unit testing widgets |
| **Integration testing** | `expect`, `tmux send-keys`, VHS | End-to-end flow verification |
| **Visual regression** | VHS + screenshot comparison | Cross-terminal consistency |
| **Accessibility audit** | Screen reader testing, `NO_COLOR` mode | Accessibility compliance |

> For testing strategies per framework, see [references/patterns/testing-strategies.md](references/patterns/testing-strategies.md).

## Quick Start Guides

### Design a TUI Layout
1. Define the information hierarchy — what's primary, secondary, contextual
2. Choose a layout primitive from the table above
3. Sketch in ASCII (or use the [layout worksheet](assets/layout-worksheet.md))
4. Define keybindings using the interaction pattern table
5. Choose a color tier based on target terminal environments
6. Select a framework from the selection guide

### Build a TUI in [Framework]
1. Read the framework-specific reference in `references/frameworks/`
2. Scaffold the project using the provided template
3. Implement layout → widgets → interaction → styling (in that order)
4. Add Tier 1 color fallback
5. Test at 80×24 minimum terminal size
6. Set up build/release tooling per the framework guide

### Port a TUI Between Frameworks
1. Document the source TUI's layout, widgets, and interaction model
2. Map source concepts to target framework equivalents (see framework references)
3. Implement layout shell first, then populate widgets
4. Port keybindings — adjust for framework idioms
5. Verify visual parity with screenshot comparison

### Add Interactivity to an Existing CLI
1. Identify which interactions need TUI vs. simple prompts
2. For simple prompts: use `gum` (shell) or `inquire` (Rust) / `survey` (Go) / `inquirer` (TS)
3. For rich TUI: choose a framework and embed as a subcommand or mode
4. Keep non-interactive mode available (`--no-tui` or pipe detection)

## Reference Guide

| Task | Read These |
|------|-----------|
| **Starting a TUI project** | Framework-specific ref + `patterns/layout-patterns.md` |
| **Designing layouts** | `patterns/layout-patterns.md` + `assets/layout-worksheet.md` |
| **Choosing colors** | `patterns/color-systems.md` |
| **Keybinding design** | `patterns/interaction-patterns.md` |
| **Framework deep-dive** | `frameworks/{rust,go,cpp,ts,java,shell}-*.md` |
| **Build/release setup** | Framework ref + `build-systems/ci-templates.md` |
| **Testing** | `patterns/testing-strategies.md` |
| **Cross-platform issues** | `patterns/cross-platform.md` |
| **Accessibility** | `patterns/accessibility.md` |

All paths relative to `references/`.

## Related Skills

- **trl-user-experience-engineer** — Web UI design, landing pages, brand identity; complementary to TUI for non-terminal interfaces
- **trl-skill-engineer** — Meta-skill for designing and validating new skills; used to build this skill
- **trl-mcp-builder** — MCP server scaffolding; TUI can serve as admin/debug interface for MCP servers
- **trl-content-publishing** — Write tutorials about TUI development for audience building

## Bundled Resources

### References

**Frameworks** (`references/frameworks/`):
- [rust-ratatui.md](references/frameworks/rust-ratatui.md) — ratatui + crossterm: setup, Cargo config, widget catalog, event loop, async, testing with TestBackend
- [go-bubbletea.md](references/frameworks/go-bubbletea.md) — bubbletea + lipgloss + bubbles: Elm Architecture, model/update/view, styling, go mod setup
- [cpp-ftxui-ncurses.md](references/frameworks/cpp-ftxui-ncurses.md) — FTXUI (modern C++) and ncurses (C): CMake/Make setup, component trees, input handling
- [ts-ink.md](references/frameworks/ts-ink.md) — Ink (React for CLI): JSX components, hooks, state management, npm/pnpm build, tsx setup
- [java-lanterna.md](references/frameworks/java-lanterna.md) — Lanterna + JLine: screen management, GUI layer, Maven/Gradle setup, GraalVM native-image
- [shell-gum.md](references/frameworks/shell-gum.md) — gum, dialog, whiptail, pure ANSI: script-level TUI, packaging, portability

**Patterns** (`references/patterns/`):
- [layout-patterns.md](references/patterns/layout-patterns.md) — Layout primitives with ASCII mockups, responsive degradation rules
- [interaction-patterns.md](references/patterns/interaction-patterns.md) — Keybinding conventions, focus management, modal behavior, mouse support
- [color-systems.md](references/patterns/color-systems.md) — Tiered color support, palette recipes, NO_COLOR compliance, light/dark themes
- [testing-strategies.md](references/patterns/testing-strategies.md) — Snapshot, golden file, headless, integration, and visual regression testing
- [cross-platform.md](references/patterns/cross-platform.md) — Windows Terminal, macOS Terminal, Linux, SSH, tmux, screen, Unicode handling
- [accessibility.md](references/patterns/accessibility.md) — Screen reader support, high contrast, keyboard-only operation, WCAG for terminals

**Build Systems** (`references/build-systems/`):
- [ci-templates.md](references/build-systems/ci-templates.md) — GitHub Actions matrix builds, cross-compilation, release automation per language

### Assets

- [layout-worksheet.md](assets/layout-worksheet.md) — Fillable ASCII layout planning template with grid system
- [keybinding-map.md](assets/keybinding-map.md) — Standard keybinding assignment template
- [project-scaffold-checklist.md](assets/project-scaffold-checklist.md) — Pre-build checklist for new TUI projects
