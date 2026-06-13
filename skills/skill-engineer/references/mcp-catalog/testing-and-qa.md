# Category: Testing and QA

## Overview
Use tools in this category when a skill needs to verify behavior, catch regressions, validate LLM tool calls, or measure system performance under load. Common skill design scenarios: trl-skill-engineer (validate MCP tool behavior with Promptfoo), trl-user-experience-engineer (E2E and visual regression for landing pages), AI templates (red-team prompt pipelines), content publishing (verify rendered output across browsers).

## MCP Services

| Name | Deployment | Key Features | Security Notes | Maturity |
|------|-----------|-------------|----------------|----------|
| Playwright MCP | Local stdio | Official Microsoft, two modes, auto-waits, smart locators, Chromium/WebKit/Firefox | Runs locally; browser processes are sandboxed | Stable (official) |
| Selenium MCP | Local stdio | Community, WebDriver protocol, wide browser/OS support | Runs locally; requires WebDriver binary | Beta (community) |
| k6 MCP | Local stdio / Hosted | Load testing via MCP, LLM-driven test creation | Local k6 binary; Grafana Cloud for hosted | Beta |
| Applitools MCP | Hosted SSE | Visual AI, cross-browser screenshot diffing, Playwright SDK | Screenshots sent to Applitools cloud | Stable |
| TestSprite | Hosted | AI-powered web app testing, automated test generation | Cloud-based; sends app state/screenshots | Beta |

### Playwright MCP
- **What it does**: Official Microsoft MCP server for browser automation. Two modes: **snapshot mode** (accessibility tree, fast, no screenshots, best for form interaction/navigation) and **vision mode** (screenshot-based, slower, required for visual checks). Auto-waits for elements, uses smart locators (ARIA roles preferred), supports Chromium, WebKit, and Firefox.
- **Deployment**: Local stdio; requires `npx @playwright/mcp` or `npm install -g @playwright/mcp`; Playwright browsers installed separately via `npx playwright install`
- **Key features**: Navigate, click, fill forms, submit, take screenshots, read accessibility tree, run in headed or headless mode, record traces, intercept network requests
- **Security considerations**: Runs entirely locally. Browser process is sandboxed by OS. Vision mode screenshots stay local unless forwarded to a tool like Applitools. No credentials leave the machine.
- **When to use**: E2E testing of web UIs in skill pipelines. Automating user journeys to verify landing pages or app flows. Generating screenshots for visual comparison. Driving any web UI that doesn't have an API. Preferred over Selenium for modern web apps.
- **When to avoid**: Native desktop or mobile app testing (use Appium). When the target page aggressively blocks automated browsers (some login pages detect Playwright). Load testing (use k6).

### Promptfoo (CLI — with MCP testing mode)
- **What it does**: LLM evaluation and red-teaming framework. Runs test suites against prompts, models, and MCP tool calls. Supports YAML-based test configs with assertions. Can call MCP tools directly and assert on their outputs — making it the primary tool for validating MCP servers built during skill design. Also does adversarial red-teaming (jailbreak, prompt injection, PII leak detection).
- **Deployment**: `npm install -g promptfoo` or `npx promptfoo`; runs locally; no external API calls except to the LLMs/MCPs under test
- **Key features**: Multi-model evaluation, MCP tool call testing, YAML test configs, assertion library (contains, regex, JSON schema, LLM-graded), red-team attack suite, HTML/JSON report output, CI integration
- **Security considerations**: Runs locally. API keys for LLMs under test are required but stay local. Red-team mode sends adversarial prompts to the model — use isolated test environments.
- **When to use**: Validating MCP servers built in AI templates skill. A/B testing prompt variations in trl-content-publishing skill. Red-teaming LLM pipelines before production. Any time you ship a prompt or MCP tool and need regression coverage.
- **When to avoid**: Browser/UI testing (use Playwright). Load/performance testing (use k6). When tests need to run in a browser context.

### k6 MCP
- **What it does**: Load testing via MCP interface. The LLM can author k6 test scripts using natural language, run them, and interpret results. k6 simulates concurrent virtual users, measures response times, error rates, and throughput. LLM-driven test creation removes the need to hand-write k6 scripts.
- **Deployment**: Local stdio (requires k6 binary: `brew install k6`) or Grafana Cloud k6 for hosted runs
- **Key features**: Virtual user simulation, ramp-up/ramp-down stages, threshold assertions (p95 < 500ms), HTTP metrics, WebSocket support, LLM-assisted script generation
- **Security considerations**: Local runs keep all traffic local. Grafana Cloud runs send traffic from Grafana's infrastructure — ensure test targets can accept external load. Do not load-test production without rate limiting.
- **When to use**: API performance validation before launch. Stress testing MCP server endpoints. Verifying a Next.js app handles expected traffic. When a skill pipeline provisions infrastructure and needs a performance gate.
- **When to avoid**: Functional/behavioral testing (use Playwright). LLM evaluation (use Promptfoo). When you just need a single request check (use curl).

## CLI Tools

| Name | Install | What It Does | Skill Relevance |
|------|---------|-------------|-----------------|
| Promptfoo | `npm install -g promptfoo` | LLM/MCP evaluation + red teaming, test MCP tool calls, YAML configs, assertion library, HTML reports | Primary tool for validating MCP servers and prompts; CI gate for LLM-powered skills |
| Chromatic | `npm install --save-dev chromatic` | Storybook snapshot testing, visual regression, pixel diffing, PR review UI | Visual regression for component libraries in UX-engineer skill; pairs with Storybook |

## Selection Guide

**E2E browser testing (user journeys, form flows, navigation):** Use Playwright MCP. Official, fast in snapshot mode, handles modern SPAs. Use vision mode when screenshots are needed.

**Visual regression (pixel-level UI comparison across deploys):** Use Applitools MCP for cross-browser AI-powered diffing. Use Chromatic CLI for Storybook component regression.

**LLM and MCP tool validation:** Use Promptfoo CLI. Only tool with native MCP tool call testing. Required for any skill that ships prompts or MCP servers.

**Load and performance testing:** Use k6 MCP. LLM authors the script, k6 runs it. Grafana Cloud for distributed load.

**Legacy browser coverage (IE, older WebDriver targets):** Use Selenium MCP. More browser/OS matrix coverage than Playwright, but slower and more brittle on modern apps.

**AI-generated test suites for web apps:** Use TestSprite. Fully automated test generation — useful when no existing test coverage exists and manual authoring is too costly.

**Decision by testing type:**
- Functional behavior → Playwright MCP
- LLM output quality → Promptfoo CLI
- Visual appearance → Applitools MCP or Chromatic CLI
- Performance under load → k6 MCP
- Component library regression → Chromatic CLI
