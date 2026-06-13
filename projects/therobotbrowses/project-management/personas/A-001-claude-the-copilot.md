---
id: A-001
name: "Claude"
slug: "claude-the-copilot"
archetype: "The Browsing Copilot"
segment: "agent-primary"
agent_type: "conversational-assistant"
tags: [agent, llm, claude, mcp, copilot, conversational, primary-agent]
---

# Claude — The Browsing Copilot

## Agent Profile

| Field | Value |
|-------|-------|
| **Type** | Conversational LLM agent |
| **Model** | Claude (Anthropic) |
| **Interface** | MCP client → browser MCP server |
| **Autonomy Level** | Collaborative (acts on user request, suggests proactively) |
| **Persistence** | Session-scoped with optional memory |
| **Trust Level** | High — full read access to DOM/network, write access to navigation/forms with user consent |

## Role

Claude is the primary AI agent integrated into therobotbrowses. It acts as a browsing copilot — a conversational partner that can see what the user sees (via DOM/layout/accessibility tree access), answer questions about page content, perform multi-step browsing tasks, and help the user accomplish goals that span multiple pages and sessions.

## Capabilities (MCP Tool Surface)

1. **Page Understanding** — Query DOM, read rendered text, inspect layout, understand page structure
2. **Navigation** — Open URLs, click links, fill forms, manage tabs
3. **Extraction** — Pull structured data from pages, summarize content, find specific information
4. **Multi-Page Workflows** — Chain navigation + extraction across multiple pages (e.g., "compare prices on these 5 sites")
5. **Accessibility Enhancement** — Describe visual content, infer missing ARIA, narrate page changes
6. **Network Inspection** — Read request/response headers, timing, errors (read-only by default)

## Goals

1. Help users accomplish browsing goals faster than they could alone
2. Reduce cognitive load — summarize, filter, extract, compare
3. Be available but not intrusive — activated by user, not always-on
4. Maintain context across a browsing session (which pages were visited, what was discussed)

## Constraints

1. Cannot execute arbitrary JavaScript unless explicitly authorized by user
2. Cannot access browser-level settings (bookmarks, history, passwords) without user grant
3. Must surface what it's doing — no silent background actions
4. Rate-limited on navigation actions to prevent runaway loops
5. Cannot bypass site security measures (no credential stuffing, no CAPTCHA solving)

## Interaction Patterns

- **Passive**: User browses normally; Claude is available via hotkey/panel but doesn't interrupt
- **Active**: User invokes Claude with a task ("summarize this article," "find the pricing page," "fill out this form with my saved info")
- **Proactive** (opt-in): Claude notices patterns and offers help ("This looks like a comparison shopping session — want me to track prices across tabs?")

## Scenarios

1. **Research assistant** — User is reading academic papers. Claude summarizes each paper, extracts citations, and builds a bibliography across 20 tabs — all via MCP DOM queries, no scraping hacks.
2. **Form automation** — User hits a multi-page government form. Claude reads the form fields via accessibility tree, maps them to user-provided data, fills each page, and waits for user confirmation before submitting.
3. **Accessibility narration** — User (Jordan, P-004) asks Claude to describe a data visualization that has no alt text. Claude inspects the SVG DOM, reads axis labels and data points, and produces a natural-language description.
