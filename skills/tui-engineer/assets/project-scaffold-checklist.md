# TUI Project Scaffold Checklist

## Project Setup

- [ ] Framework selected: _______________
- [ ] Language version specified: _______________
- [ ] Build system configured (Cargo.toml / go.mod / package.json / pom.xml / CMakeLists.txt / Makefile)
- [ ] Dependencies pinned to specific versions
- [ ] Project directory structure created
- [ ] `.gitignore` includes build artifacts

## Terminal Management

- [ ] Terminal setup (raw mode, alternate screen)
- [ ] Terminal restore on clean exit
- [ ] Panic/crash handler restores terminal
- [ ] Signal handling (SIGINT, SIGTERM)
- [ ] Resize handling (SIGWINCH or framework equivalent)

## Rendering

- [ ] Minimum terminal size check (80×24)
- [ ] Graceful degradation at smaller sizes
- [ ] Layout responds to terminal resize
- [ ] No hardcoded terminal dimensions

## Color & Styling

- [ ] Color capability detection (`TERM`, `COLORTERM`)
- [ ] `NO_COLOR` environment variable respected
- [ ] Tier 1 fallback (8 ANSI colors) implemented
- [ ] Tested in both light and dark terminal themes
- [ ] Semantic color mapping (not hardcoded colors for meaning)

## Input & Interaction

- [ ] Arrow key navigation works
- [ ] Quit key (`q` or `Ctrl+C`) works
- [ ] Help overlay (`?` key) shows all keybindings
- [ ] Keyboard-only operation (no mouse required)
- [ ] Mouse support added as progressive enhancement (if applicable)
- [ ] Focus management for multi-widget layouts
- [ ] Quit confirmation for destructive/unsaved state

## Testing

- [ ] Testing strategy selected (snapshot / golden / headless / integration)
- [ ] Test framework configured
- [ ] At least one rendering test exists
- [ ] Tests run in CI without a TTY

## Build & Release

- [ ] Release build compiles without warnings
- [ ] Cross-compilation targets defined
- [ ] CI/CD pipeline configured (GitHub Actions or equivalent)
- [ ] Version embedding via build flags
- [ ] Release packaging set up (cargo-dist / goreleaser / pkg / jpackage / brew tap)
- [ ] Binary size acceptable for distribution

## Documentation

- [ ] README with screenshots/recordings (VHS or asciinema)
- [ ] `--help` flag or help subcommand
- [ ] Keybinding reference accessible from within the app
- [ ] Installation instructions for each platform

## Cross-Platform

- [ ] Tested on macOS
- [ ] Tested on Linux
- [ ] Tested on Windows Terminal (if applicable)
- [ ] Tested in tmux
- [ ] Tested over SSH
- [ ] Unicode rendering verified
