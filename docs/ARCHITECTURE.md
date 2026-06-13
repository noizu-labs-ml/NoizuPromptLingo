# therobotbrowses — Architecture Overview

## System Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        therobotbrowses                           │
│                                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐ │
│  │ TUI/GUI  │  │ MCP      │  │ CLI      │  │ Headless         │ │
│  │ Frontend │  │ Server   │  │ Interface │  │ Mode             │ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────────────┘ │
│       │              │             │              │               │
│       └──────────────┴──────┬──────┴──────────────┘               │
│                             │                                     │
│                    ┌────────┴────────┐                            │
│                    │  Browser Core   │                            │
│                    │  (Orchestrator) │                            │
│                    └────────┬────────┘                            │
│                             │                                     │
│       ┌─────────┬───────────┼───────────┬──────────┐             │
│       │         │           │           │          │             │
│  ┌────┴───┐ ┌───┴────┐ ┌───┴────┐ ┌────┴───┐ ┌───┴─────┐      │
│  │Network │ │ HTML   │ │  CSS   │ │ Layout │ │  Paint  │      │
│  │Stack   │ │ Parser │ │ Engine │ │ Engine │ │ Engine  │      │
│  │        │ │        │ │        │ │        │ │         │      │
│  │ hyper  │ │html5-  │ │light-  │ │ block  │ │  wgpu   │      │
│  │ rustls │ │ever    │ │ningcss │ │ inline │ │  skia   │      │
│  └────────┘ └────────┘ └────────┘ │ flex   │ └─────────┘      │
│                                    │ grid   │                   │
│                                    └────────┘                   │
│                                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐ │
│  │    JS    │  │   DOM    │  │  A11y    │  │    Extension     │ │
│  │  Engine  │  │   Tree   │  │  Tree    │  │    Host          │ │
│  │  (boa)   │  │          │  │          │  │    (WASM)        │ │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────────┘ │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## Crate Structure (Planned)

```
therobotbrowses/
├── Cargo.toml                    # Workspace root
├── crates/
│   ├── trb-core/                 # Browser orchestrator, tab management, session
│   ├── trb-net/                  # HTTP client, TLS, cookie jar, caching
│   ├── trb-html/                 # HTML parser (html5ever wrapper), DOM tree
│   ├── trb-css/                  # CSS parser, cascade, computed styles
│   ├── trb-layout/               # Box model, block/inline/flex/grid layout
│   ├── trb-paint/                # Rendering pipeline, GPU compositing
│   ├── trb-js/                   # JavaScript engine integration (boa)
│   ├── trb-a11y/                 # Accessibility tree, ARIA, platform a11y APIs
│   ├── trb-mcp/                  # MCP server — exposes browser as tools
│   ├── trb-ext/                  # Extension host, plugin API, WASM sandbox
│   ├── trb-tui/                  # ratatui-based TUI frontend
│   ├── trb-gui/                  # winit+wgpu GUI frontend
│   └── trb-cli/                  # CLI interface (headless, one-shot commands)
├── tests/
│   ├── acid1/                    # ACID1 test suite
│   ├── acid2/                    # ACID2 test suite
│   ├── acid3/                    # ACID3 test suite
│   └── wpt/                     # Web Platform Tests integration
└── tools/
    └── trb-devtools/             # Built-in developer tools
```

## MCP Tool Surface (Phase 4)

The browser exposes itself as an MCP server with these tool namespaces:

| Namespace | Tools | Description |
|-----------|-------|-------------|
| `dom` | query, get_element, get_text, get_attributes, get_children | DOM tree inspection |
| `nav` | goto, back, forward, reload, click, fill, submit | Navigation and interaction |
| `net` | get_requests, get_response, get_headers, get_cookies | Network inspection |
| `layout` | get_box, get_computed_style, get_viewport | Layout and style inspection |
| `a11y` | get_tree, get_role, get_name, get_state | Accessibility tree |
| `tab` | list, open, close, switch, get_active | Tab management |
| `console` | get_logs, get_errors | Console output |
| `page` | screenshot, get_title, get_url, get_html | Page-level operations |

## Agent Integration Model

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Claude     │     │   Crawler   │     │   Weaver    │
│  (Copilot)   │     │ (Harvester) │     │ (Automator) │
│   A-001      │     │   A-002     │     │   A-004     │
└──────┬───────┘     └──────┬──────┘     └──────┬──────┘
       │                    │                    │
       │     MCP Protocol (stdio/SSE)            │
       │                    │                    │
┌──────┴────────────────────┴────────────────────┴──────┐
│                    MCP Server (trb-mcp)                │
│                                                        │
│  ┌─────────────────────────────────────────────────┐  │
│  │              Permission Layer                    │  │
│  │  Claude: read + nav + fill (no JS exec)         │  │
│  │  Crawler: read + nav (no credentials)           │  │
│  │  Sentinel: read-only (event subscriptions)      │  │
│  │  Weaver: read + nav + fill (with user gates)    │  │
│  └─────────────────────────────────────────────────┘  │
│                                                        │
│                   Browser Core                         │
└────────────────────────────────────────────────────────┘
```

## Key Design Decisions

### Why Rust?
- Memory safety without GC (critical for a browser)
- Zero-cost abstractions for performance-critical rendering
- Strong ecosystem: html5ever, wgpu, hyper, tokio
- WebAssembly target for plugin sandboxing

### Why Bottom-Up?
- Agent-native architecture requires subsystem access that Chromium/WebKit don't expose
- Educational and community-building value
- Full control over the rendering pipeline for research/experimentation
- No Google dependency

### Why MCP?
- Standard protocol — agents built for any MCP server work here
- Composable with the broader MCP ecosystem (Claude Desktop, other tools)
- Permission model built into the protocol
- Supports multiple concurrent clients (multiple agents browsing simultaneously)

### Why TUI First?
- Ship something useful in Phase 0 without solving GPU rendering
- Keyboard-driven users (Maya, P-003) get value immediately
- Headless/TUI mode is the primary interface for agent personas
- Validates architecture before investing in GPU pipeline
