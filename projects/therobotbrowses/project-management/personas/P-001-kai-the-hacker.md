---
id: P-001
name: "Kai Nakamura"
slug: "kai-the-hacker"
archetype: "The Tool-Building Developer"
segment: "primary"
tags: [developer, rust, open-source, browser-internals, contributor]
---

# Kai Nakamura — The Tool-Building Developer

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 27-35 |
| **Role** | Systems programmer / OSS contributor |
| **Technical Level** | Expert |
| **Industry** | Developer tooling / Infrastructure |
| **Location** | Berlin, Germany |

## Bio

Kai has contributed to Servo, wrote a toy CSS parser in grad school, and has strong opinions about why browsers shouldn't be a Google monoculture. They run Arch Linux, use a tiling window manager, and have been waiting for a browser that treats them as a first-class citizen rather than a consumer. Kai is the person who would build therobotbrowses if they had the bandwidth — instead, they want to contribute.

## Goals

1. Hack on browser internals without fighting Chromium's 30M-line codebase
2. Build custom dev tools that integrate with their workflow (MCP servers, terminal tools)
3. Have a browser where the extension model isn't an afterthought bolted onto a locked-down sandbox

## Frustrations

1. Firefox's codebase is massive and the contribution path is opaque
2. Chrome extensions are increasingly neutered (Manifest V3)
3. Every "alternative browser" is just a Chromium skin
4. Browser dev tools can't be scripted or composed with other tools

## Behaviors

- Reads RFCs and W3C specs for fun
- Prefers TUI/CLI tools over GUI when possible
- Builds personal tools in Rust and publishes them on crates.io
- Spends weekends on side projects, often browser/networking related

## Job to Be Done

> "When I want to understand how a website works at every layer — network, parsing, layout, paint — I want a browser that exposes its internals as composable APIs, so I can build tooling that no existing browser supports."

## Relationship to Product

Kai discovers therobotbrowses via Hacker News or r/rust. They clone the repo, build it, and immediately start poking at the MCP tool surface. They'd contribute layout engine fixes and build experimental extensions. They'd churn if the codebase becomes a mess or if architectural decisions prioritize convenience over correctness.

## Scenarios

1. **Layout debugging** — Kai is investigating why a flex container renders differently than Chrome. They use the MCP layout inspector to query box dimensions at each layout pass, diff the results against the spec, and submit a fix.
2. **Custom dev tool** — Kai builds an MCP-powered "network waterfall" tool that runs in their terminal, showing request timing, headers, and body sizes in real-time as they browse.
