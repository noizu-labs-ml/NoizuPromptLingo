# Mockup MCP

**Domain:** securamcp.com

**Status:** Concept / Pre-development

**Part of:** [MCP Host](../mcp-host/) platform ecosystem (reference tenant service)

---

## Vision

Product mockup generator exposed as an MCP service. Uses image AI and structured diagramming tools (PlantUML, SVG, Mermaid) to generate product mockups, wireframes, and architectural diagrams. Includes a companion website for collecting stakeholder feedback on generated mockups.

## Relationship to MCP Host

Mockup MCP is a tenant application on the MCP Host platform. It is published to the MCP Host registry, deployed through JustMCP.it, and governed by SafeMCP access policies. It serves as the reference implementation for a well-behaved hosted MCP service: sandboxed execution, scoped auth, audit-logged invocations, and discoverable via the registry.
