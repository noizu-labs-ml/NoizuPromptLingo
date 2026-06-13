# therobotbrowses

An AI/LLM-native web browser built from scratch in Rust.

## Vision

A browser designed from the ground up around AI agent collaboration — not a browser with AI bolted on, but a browser where the rendering engine, DOM, networking stack, and extension model are all first-class MCP-accessible surfaces. Claude and other agents can see, navigate, manipulate, and reason about web content as peers to the human operator.

## Core Principles

1. **Bottom-up, not top-down** — We build the rendering engine, CSS parser, layout engine, and JS runtime ourselves. No wrapping Chromium.
2. **Agent-native architecture** — Every browser subsystem exposes MCP tool surfaces. Agents don't scrape screenshots; they query the DOM, inspect layout boxes, read network traces.
3. **Phased construction** — Ship usable artifacts at every phase, not vaporware.
4. **Standards-driven** — Target ISO/W3C specs (HTML5, CSS3, ECMAScript). ACID test compliance as progress milestones.
5. **Composable** — Plugin architecture from day one. The browser is a platform, not a monolith.

## Phased Roadmap

| Phase | Codename | Deliverable | Key Milestone |
|-------|----------|-------------|---------------|
| 0 | `shell` | TUI browser shell — URL bar, tab management, request/response viewer, raw HTML display | Navigate and display raw HTML |
| 1 | `render` | CSS parser + box model + layout engine + text rendering | ACID1 pass |
| 2 | `paint` | GPU-accelerated painting, image decoding, font rendering | Visual web pages |
| 3 | `interact` | DOM event model, forms, basic JS (embedded engine or wasm) | Interactive pages |
| 4 | `connect` | MCP server exposing DOM, network, layout, console as tools | Agent-driven browsing |
| 5 | `extend` | Plugin/extension architecture, content scripts, theming | User-installable extensions |
| 6 | `comply` | Full ACID2/ACID3 compliance push, accessibility tree, screen reader support | Standards compliance |
| 7 | `ship` | Packaging, installers, auto-update, crash reporting | Public alpha |

## Tech Stack

- **Language**: Rust
- **Rendering**: wgpu (GPU abstraction) / skia-safe (2D graphics)
- **Networking**: hyper + rustls
- **CSS Parsing**: lightningcss or custom parser
- **HTML Parsing**: html5ever
- **JS Engine**: boa (Rust-native) or embedded V8/SpiderMonkey via FFI
- **TUI (Phase 0)**: ratatui
- **GUI (Phase 2+)**: winit + wgpu
- **MCP**: mcp-rust-sdk
- **Serialization**: serde

## Domain

`therobotbrowses.com` (portfolio project under the-robot-lives)

## Status

Phase 0 — Planning
