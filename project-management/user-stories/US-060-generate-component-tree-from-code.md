---
id: US-060
title: "Generate component tree diagram from React/code structure"
slug: "generate-component-tree-from-code"
personas: [P-001, P-007]
epic: "Diagram & Rendering Engine"
priority: "could-have"
complexity: "L"
tags: [react, component-tree, code-analysis, diagram, frontend]
---

# US-060: Generate Component Tree Diagram from React/Code Structure

## User Story

**As a** Full-Stack Developer (P-001),
**I want to** submit a React component file or directory and receive a component hierarchy diagram,
**So that** I can document and communicate frontend architecture without manually tracing imports.

## Acceptance Criteria

- [ ] Given a React component file (JSX/TSX), when submitted, then a tree diagram showing the component and its direct child components is returned
- [ ] Given a directory of React components, when submitted with a root component specified, then the full component tree from that root is traced and diagrammed
- [ ] Given the diagram, when returned, then each node shows the component name and optionally its key props (if `show_props: true` is set)
- [ ] Given a component with dynamic imports or lazy loading, when encountered, then it is represented as a dashed/deferred node in the diagram with a visual distinction

## Notes

Static analysis of imports is the primary mechanism — no runtime execution required. Relies on AST parsing in the Phoenix backend (e.g., via a Node.js subprocess or Elixir NimbleParsec). Related to US-057/US-058 as a code-structure-to-diagram pattern.
