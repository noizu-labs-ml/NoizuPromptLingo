# Category: Design and UI

## Overview
Use tools in this category when a skill bridges the gap between design assets and production code — or when it needs to validate visual output automatically. Common scenarios: design-to-code translation, component library maintenance, visual regression testing in CI, cross-browser rendering verification, and accessibility audits. The key workflow question is directionality: design → code (Figma MCP, Storybook) vs. code → visual verification (Chromatic, Applitools, Playwright).

## MCP Services

| Name | Deployment | Key Features | Security Notes | Maturity |
|------|-----------|-------------|----------------|----------|
| Figma Dev Mode MCP | Hosted SSE | Structured design data, auto-layout, variables | Figma OAuth token required | Stable |
| Storybook MCP | Local stdio | Component catalog, prop inspection, story runner | Reads local Storybook build | Beta |
| Playwright MCP (visual) | Local stdio | Two modes, self-correction with Figma | Browser automation; full OS access | Stable |
| Chromatic | Hosted SaaS | Storybook snapshots, pixel diffing, AI agent connection | Code sent to Chromatic cloud | Stable |
| Applitools MCP | Hosted SaaS | Visual AI diffing, cross-browser, Playwright SDK | Screenshots sent to Applitools | Stable |
| Browser Tools MCP | Local stdio | DevTools access, console, network, perf, a11y | Full browser DevTools access | Beta |

---

### Figma Dev Mode MCP
- **What it does**: Official Figma MCP server that exposes structured design data — component hierarchies, auto-layout constraints, design variables, text styles, and asset exports — as tool responses consumable by AI coding agents. Dev Mode provides intent-rich data beyond raw pixel coordinates, making design-to-code translation dramatically more accurate.
- **Deployment**: Hosted SSE at `https://mcp.figma.com`; authenticated via Figma OAuth or personal access token; connects to Figma Desktop or web app; no local server process needed
- **Key features**: Component hierarchy with semantic names (not just node IDs); auto-layout direction, gap, padding, and alignment values; design variable bindings (tokens mapped to CSS custom properties); text style extraction (font, weight, line-height, letter-spacing); asset export in SVG/PNG; frame and variant enumeration; Code Connect integration (maps Figma components to code component props); selection-aware queries (asks about what the designer has selected)
- **Security considerations**: Figma OAuth token grants read access to all files the user can access — scope to specific file access where possible. Design files may contain proprietary brand assets or unreleased product UI — treat MCP output as sensitive. The hosted SSE endpoint sends selected design data to Figma's servers for processing; no raw file contents are transmitted, only structured API responses.
- **When to use**: Any skill involving design-to-code translation (the primary use case); skills that need to read design tokens from a Figma library and map them to CSS/Tailwind; component scaffolding workflows where the agent reads Figma component props and generates matching React/Vue components; Code Connect setup for documenting how code components map to Figma.
- **When to avoid**: When no Figma file exists (use Storybook MCP to inspect existing code components instead); when the design is in a different tool (Sketch, Framer, Penpot — no MCP equivalent); when pixel-perfect visual regression is the goal (use Chromatic or Applitools instead of Figma MCP).

---

### Storybook MCP
- **What it does**: MCP server for a running Storybook instance that exposes the component catalog — story list, component props/args, story rendering — as tool responses. Allows AI agents to inspect what components exist, what states they support, and render specific stories for visual inspection.
- **Deployment**: Local stdio; requires a running Storybook dev server (`storybook dev`) or a built Storybook (`storybook build`); MCP server connects via Storybook's internal API; `npx @storybook/mcp-server` or configured in project
- **Key features**: List all stories and components; read component ArgTypes (props, events, controls); render a specific story by ID; read story source code; access component documentation (JSDoc, MDX docs pages); integration with Storybook Test Runner for automated story validation; works with React, Vue, Angular, Svelte, and Web Components
- **Security considerations**: Runs entirely locally against a local Storybook instance — no code leaves the machine. The MCP server has read access to the built Storybook bundle and story metadata. No write access to source files (Storybook MCP is read-only by design). If Storybook dev server is exposed on a network port, ensure firewall rules restrict access.
- **When to use**: Skills that need to inventory existing UI components before generating new ones (avoid duplication); code-to-design workflows where the agent reads component API from Storybook to generate Figma Code Connect mappings; documentation generation skills (extract component props and auto-generate docs); visual regression baselines (render stories, capture screenshots, compare).
- **When to avoid**: Projects without Storybook (setup cost may not be worth it for a one-off task); when the goal is production UI testing rather than component development (use Playwright or Chromatic); when Figma is the source of truth and code doesn't exist yet (use Figma Dev Mode MCP instead).

---

### Chromatic
- **What it does**: Cloud-based visual testing platform built for Storybook. Captures snapshots of every story, diffs them against baselines with pixel-level precision, and surfaces regressions for human review. AI agent connection allows automated baseline acceptance and regression triage.
- **Deployment**: Hosted SaaS; `npx chromatic --project-token=<token>` in CI; Storybook must exist in the project; snapshots rendered on Chromatic's cloud infrastructure across configured viewports and browsers
- **Key features**: Pixel diffing with configurable threshold (ignores anti-aliasing noise); multi-viewport testing (mobile, tablet, desktop); cross-browser snapshots (Chrome, Firefox, Safari via cloud browsers); baseline management (accept/reject changes via UI or API); PR integration (blocks merge on unreviewed visual changes); AI-assisted change grouping (clusters similar diffs for batch review); Storybook Interactions tests run before snapshot capture; MCP/API for agent-driven baseline acceptance
- **Security considerations**: Storybook bundle (including component source and story data) is uploaded to Chromatic's CDN for rendering. Review Chromatic's data retention policy for proprietary UI. Project tokens grant write access to baselines — treat like a CI secret. Chromatic does not execute arbitrary code from stories, but interactive stories may load external URLs.
- **When to use**: Teams shipping Storybook components to production and needing an automated visual regression gate; skills that automate design-to-code workflows and need to validate the output visually; any project where CSS or dependency updates could silently break component appearance; PR workflows where visual sign-off should be part of the merge checklist.
- **When to avoid**: Projects without Storybook (Chromatic is Storybook-native; for non-Storybook visual testing use Playwright + Applitools); when all visual testing must run locally (Chromatic requires cloud upload); very small projects where Storybook setup overhead exceeds the benefit.

---

## CLI Tools

| Name | Install | What It Does | Skill Relevance |
|------|---------|-------------|-----------------|
| `storybook` | `npx storybook@latest init` | Component development + catalog | Component isolation and documentation |
| `chromatic` | `npm i -g chromatic` | Upload Storybook, run visual tests | CI visual regression gate |
| `playwright` | `npm i @playwright/test` | Browser automation + visual snapshots | End-to-end + visual testing |
| `figma-export` | Various community tools | Export Figma assets to local files | Asset pipeline automation |
| `axe-core` | `npm i axe-core` | Accessibility audit engine | A11y validation in test suites |

---

## Selection Guide

**Choose by workflow direction:**

| Direction | Best Choice | Fallback |
|-----------|------------|---------|
| Design → Code (read Figma intent) | Figma Dev Mode MCP | Manual Figma inspection |
| Code → Design (document components) | Storybook MCP | Manual prop documentation |
| Code → Visual verification | Chromatic | Playwright + screenshots |
| Cross-browser visual regression | Applitools MCP | Chromatic |
| A11y + network + console inspection | Browser Tools MCP | axe-core CLI |
| End-to-end visual with Figma self-correction | Playwright MCP | Playwright + manual baseline |

**Choose by team maturity:**

| Maturity | Recommendation |
|----------|---------------|
| No visual testing at all | Start with Chromatic + Storybook |
| Storybook exists, no visual CI | Add Chromatic to CI pipeline |
| Visual CI exists, need AI agent integration | Add Figma Dev Mode MCP for design-to-code loop |
| Full design system with tokens | Figma MCP + Storybook MCP + Chromatic together |

**Data residency:**
- All local → Playwright MCP + Browser Tools MCP + Storybook MCP
- Cloud acceptable → Chromatic, Applitools, Figma Dev Mode MCP
