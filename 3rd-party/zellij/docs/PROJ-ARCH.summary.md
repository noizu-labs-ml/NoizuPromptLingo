# Zellij Architecture Summary

## Overview

Rust terminal multiplexer (v0.45.0) with client-server architecture, WASM plugin system, and Protobuf IPC. Clients connect over Unix sockets; server manages sessions with six dedicated threads.

## Workspace Crates

- **zellij** — CLI binary: argument parsing, command routing
- **zellij-client** — Terminal I/O, input parsing, IPC client, optional web client (Axum)
- **zellij-server** — Session management, pane orchestration, PTY handling, WASM plugin runtime
- **zellij-utils** — Shared types (Events, Actions, Config), Protobuf IPC, KDL parsing
- **zellij-tile** — Plugin SDK: ZellijPlugin trait, register_plugin! macro
- **zellij-tile-utils** — Plugin ANSI styling helpers
- **zellij-cct-tmux** — Tmux compatibility shim: translates tmux CLI calls to Zellij actions
- **default-plugins/** — 13 built-in WASM plugins
- **xtask** — Build automation (Protobuf codegen, plugin compilation)

## Server Threading

Six threads: Route (message dispatch), Screen (pane/tab/layout — largest at 435KB), PTY (terminal I/O + VT parsing), Plugin (Wasmi WASM execution), PTY Writer (dedicated writes), Background Jobs (tokio async). All communicate via typed ThreadSenders channels.

## Plugin System

WASM modules (wasm32-unknown-unknown) run in Wasmi interpreter. Lifecycle: Load → Update (event-driven) → Render → Unload. Sandboxed memory, Protobuf serialization across WASM boundary, permission-gated operations, worker thread pools, inter-plugin pipes.

## Client-Server IPC

Unix domain socket at /run/user/{uid}/zellij-session-{name}.sock. Protobuf messages: ClientToServerMsg (actions, terminal input) and ServerToClientMsg (rendered frames, mode updates). Multiple clients per session. Optional web client via Axum WebSocket.

## Pane Architecture

Two types: TerminalPane (PTY-connected, Grid character buffer with scrollback) and PluginPane (WASM plugin output). Organized in Tabs with TiledPanes (Cassowary constraint solver) and FloatingPanes (absolute positioning). Supports swap layouts, Sixel images, hyperlinks, search.

## Claude Code Tmux Shim (zellij-cct-tmux)

Rust binary symlinked as `tmux` to intercept Claude Code Agent Teams' tmux CLI calls and translate them to `zellij action` subprocess calls. Dispatches across three tiers: 17 real command handlers (split-window, send-keys, kill-pane, show-options, version, etc. delegate to Zellij), 9 stub categories (layout/style/config commands Zellij handles natively), and socket-scoped virtuals (-L commands for Claude Code's internal PTY management). Key subsystems: idmap (%N to terminal_N bidirectional mapping), format string expansion (7 tmux variables), key name translation, and a race-condition fix that polls pane screen content for shell prompt readiness before forwarding send-keys to recently-created panes. State persisted per session under $XDG_RUNTIME_DIR/zellij-cct/<session>/.

## Configuration

KDL format. ~/.config/zellij/config.kdl for settings/keybindings, layouts/*.kdl for pane arrangements, themes/ for colors. Embedded defaults in assets/.

## Key Design Decisions

- Client-server for session persistence and multi-client attach
- Wasmi (not Wasmtime) for pure-Rust cross-compilation simplicity
- KDL for nested layout configuration expressiveness
- Protobuf for structured, versioned IPC

## Technology Stack

Rust 2021, tokio async, crossterm/vte terminal control, wasmi WASM runtime, prost Protobuf, KDL config, clap CLI, optional Axum web client.
