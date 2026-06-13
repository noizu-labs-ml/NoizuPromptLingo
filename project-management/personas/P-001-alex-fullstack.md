---
id: P-001
name: "Alex Chen"
slug: "alex-fullstack"
archetype: "Full-Stack Developer"
segment: "primary"
tags: [developer, claude-code, cursor, wireframes, ide-native, productivity]
---

# Alex Chen — Full-Stack Developer

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 28–35 |
| **Role** | Senior Full-Stack Engineer |
| **Technical Level** | Expert |
| **Industry** | SaaS / Tech Startup |
| **Location** | US West Coast / Remote |

## Bio
Alex builds product features end-to-end at a 40-person SaaS startup and has integrated AI coding assistants into every layer of their workflow. They spend 8+ hours a day inside VS Code with Claude Code or Cursor, rarely opening a browser unless debugging. Switching tools breaks their flow state, so anything that can't be invoked from the terminal or a chat prompt gets skipped.

## Goals
1. Generate rough wireframes or component sketches without leaving the IDE or switching context
2. Communicate UI intent quickly to design and product teammates during planning
3. Document technical decisions (data flow, API contracts) with generated diagrams embedded directly in PRs or READMEs

## Frustrations
1. Figma requires a full context switch and async back-and-forth with a designer for even trivial layout questions
2. Existing diagram tools (draw.io, Lucidchart) are too heavyweight for the quick throwaway sketches needed during development
3. AI-generated design suggestions from general-purpose LLMs produce verbose code but no visual output — still has to mentally model the layout

## Behaviors
- Invokes MCP tools via Claude Code prompts like "generate a wireframe for this checkout flow"
- Iterates on diagrams inline in the same conversation as code generation
- Commits PlantUML or Mermaid source files alongside code so diagrams version-control naturally
- Shares mockup links in Slack or Linear comments for quick stakeholder sign-off before implementing

## Job to Be Done
> "When I'm spec'ing out a new feature in the IDE, I want to generate a visual mockup from a prompt, so I can align with design and PM before writing a single line of implementation code."

## Relationship to Product
Alex discovers Mockup MCP through the Claude Code plugin directory or a coworker's dotfiles repo. Adoption is immediate if the MCP server can be added in a single config line. The key feature is zero-context-switch generation — prompt in, image/SVG out, inline. Churn happens if the output quality is too low-fidelity to be useful in async communication or if setup requires more than 10 minutes.

## Scenarios
1. **Pre-implementation alignment** — Alex is assigned a ticket to build a new notification settings page. Before writing any React, they prompt the MCP to generate a wireframe from the ticket description, attach it to the Linear ticket, and get PM approval in 20 minutes instead of scheduling a meeting.
2. **PR documentation** — Alex generates a C4 component diagram showing how a new microservice fits into the existing architecture, embeds it in the PR description as an SVG, and reviewers understand the change without reading all the code.
