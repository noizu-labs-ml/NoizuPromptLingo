# Developer Persona

## Profile
- **Name**: Keith (Primary User)
- **Role**: Software Developer
- **Primary Environment**: macOS
- **Secondary Environments**: Linux, Windows (偶尔)
- **Tools**: VS Code, Terminal, Git, Cloud Services (Cloudflare, etc.)

## Motivations
- Values efficient workflows and keyboard-first interfaces
- Wants tools that integrate seamlessly into macOS environment
- Interested in cross-device functionality without vendor lock-in
- Prefers local-first, privacy-respecting applications
- Values configurability and extensibility

## Pain Points
- Frequently loses clipboard content during development workflow
- Copy-paste fatigue when working with multiple code snippets, URLs, JSON payloads
- Needs to quickly recall what was copied 5-10 minutes ago
- Wants shared clipboard across development machines
- Frustrated with cloud clipboard managers that require proprietary sync services

## Goals
1. Instant clipboard history access (Cmd+Shift+T)
2. Quick filtering and search of history
3. Visual indicators for content type (text, image, URL, file, JSON)
4. Timestamp awareness (knowing when something was copied)
5. Configurable history retention (default: 100-500 items)
6. Eventually: encrypted sync across personal devices
7. Minimal resource usage in background

## Usage Patterns
- Frequently copies code snippets, API responses, JSON payloads, git hashes
- Uses keyboard shortcuts extensively
- May need to toggle between recent items frequently
- Works with terminal output that needs to be copied and referenced

## Anti-Patterns (What to Avoid)
- Mouse-focused UI that breaks keyboard flow
- Proprietary sync services without self-host option
- Heavy resource usage or slow startup
- Hardcoded limits or behaviors without config options
- Cloud services without explicit encryption control

<!-- nav -->

---

[< Previous: Smart Clipboard for macOS - Planning Document](../00a-roadmap.md) | [Table of Contents](../../product-spec.md) | [Next: Knowledge Worker Persona >](knowledge-worker.md)

<!-- nav -->
