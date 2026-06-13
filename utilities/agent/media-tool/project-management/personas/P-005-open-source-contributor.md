---
id: P-005
name: "Tomás Rivera"
slug: open-source-contributor
archetype: "Plugin Builder"
segment: secondary
tags: [providers, rust, open-source, extensibility]
---

# P-005: Tomás Rivera

## Demographics

| Attribute | Value |
|-----------|-------|
| Age | 31 |
| Occupation | Backend developer, open-source contributor |
| Location | Mexico City, Mexico |
| Tech comfort | high |

## Bio

Tomás discovered `generate-media-prompt` and immediately wanted to add a provider for his favorite image generation service (Fal.ai). He's comfortable with Rust and wants to implement the `MediaProvider` trait, register it in the dispatch table, and submit a PR. He also wants to write local renderers for formats he uses.

## Goals
- Implement new providers by following the existing pattern
- Add renderers for new markup formats
- Understand the provider trait interface and dispatch mechanism
- Write tests for new providers without needing real API keys

## Frustrations
- Undocumented provider interfaces slow down contributions
- No mock server or test fixtures for provider development
- Unclear which providers are highest priority for the maintainers

## Behaviors
- Reads `src/providers/gemini.rs` as reference implementation
- Uses `--dry-run` to test schema parsing without API calls
- Writes `.media.prompt` files to test new providers end-to-end
- Follows the Rust rewrite architecture in docs/providers.md

## Job to Be Done
> "When I want to add support for a new generation API, I want a clear provider trait interface with a reference implementation, so I can contribute a working provider in an afternoon."

## Relationship to Product
Contributor rather than user. Interacts primarily with the codebase and architecture docs. Values clear extension points, trait documentation, and contributor guides. Will add long-tail providers (Fal, Together, Fireworks, local ComfyUI).

## Scenarios
- **Scenario 1: New Provider** — Implements `FalProvider` by following the `GeminiProvider` pattern, adds it to `src/providers/mod.rs`, tests with `--dry-run`
- **Scenario 2: Renderer Contribution** — Implements a `render_pandoc` renderer for converting generated Markdown to PDF, following the Mermaid renderer pattern
- **Scenario 3: Provider Stub Testing** — Creates a `.media.prompt` file targeting a stubbed provider, verifies that the schema parses correctly and the warning message is shown
