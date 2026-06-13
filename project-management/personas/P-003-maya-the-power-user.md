---
id: P-003
name: "Maya Johansson"
slug: "maya-the-power-user"
archetype: "The Keyboard-Driven Power User"
segment: "secondary"
tags: [power-user, productivity, keyboard-driven, privacy, vim-user]
---

# Maya Johansson — The Keyboard-Driven Power User

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 30-40 |
| **Role** | Staff engineer / Tech lead |
| **Technical Level** | Advanced |
| **Industry** | Fintech |
| **Location** | Stockholm, Sweden |

## Bio

Maya uses qutebrowser because it has vim keybindings, but she's constantly frustrated by its limited rendering (QtWebEngine is still Chromium under the hood). She wants a browser that respects her workflow: keyboard-first, minimal chrome, scriptable, private by default. She doesn't want AI doing things for her — she wants AI available as a tool she can invoke deliberately.

## Goals

1. Browse the web entirely from the keyboard with vim-like bindings
2. Have a browser that doesn't phone home, doesn't track, doesn't show ads in the UI
3. Script repetitive browsing tasks without learning a browser-specific API
4. Invoke AI assistance on-demand (summarize this page, find the login form, extract all links) without it being always-on

## Frustrations

1. qutebrowser is still Chromium underneath — same resource usage, same Google dependencies
2. Firefox's keyboard support requires extensions that break regularly
3. "AI browsers" shove AI into everything whether you want it or not
4. No browser lets her compose browsing actions like shell pipes

## Behaviors

- Uses vim/neovim for everything, tmux for window management
- Has a dotfiles repo with 3 years of careful configuration
- Reads Hacker News, Lobste.rs, and arxiv daily
- Blocks JavaScript by default, allowlists sites

## Job to Be Done

> "When I'm doing focused work across 30+ tabs of documentation, code, and internal tools, I want a browser I can drive entirely from the keyboard with composable commands, so I never leave my flow state to reach for a mouse."

## Relationship to Product

Maya discovers therobotbrowses via Lobste.rs. She'd adopt it the moment TUI mode works well enough for daily browsing. She'd write custom keybinding configs and share them. She'd churn if the browser becomes bloated or if AI features can't be fully disabled.

## Scenarios

1. **Documentation deep dive** — Maya opens 15 tabs of Rust docs, uses keyboard commands to search across all open tabs, jumps between them with fuzzy-find, and bookmarks the relevant subset — all without touching the mouse.
2. **On-demand AI assist** — While reading a dense RFC, Maya invokes Claude via a keybinding: "summarize sections 3-5 and list the breaking changes." She reads the summary in a side panel, then continues.
