---
id: P-007
name: "Niko Petrov"
slug: "solo-ai-hobbyist"
archetype: "The Tinkerer"
segment: "tertiary"
tags: [hobbyist, indie-developer, free-tier, simplicity, personal-tools, experimentation]
---

# Niko Petrov — The Tinkerer

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 18-24 |
| **Role** | CS Student / Indie Developer |
| **Technical Level** | Intermediate |
| **Industry** | Education / Personal Projects |
| **Location** | Tallinn, Estonia |

## Bio

Niko is a computer science student who got hooked on AI agents after building a chatbot for a university hackathon. They experiment with MCP tools in their dorm room — connecting Claude to their Notion workspace, building a custom tool that summarizes lecture recordings, and prototyping a party-planning agent for friends. Niko has zero budget for infrastructure and zero patience for enterprise-grade complexity. They want tools that work immediately, for free, with a clear upgrade path if their project gets traction.

## Goals

1. Deploy personal MCP tools to a live endpoint without paying for cloud infrastructure or managing servers
2. Learn MCP development through hands-on experimentation with guided templates and working examples
3. Share their projects with friends and the community through a public link, not a GitHub repo that requires local setup

## Frustrations

1. Every hosting option either costs money or requires deep DevOps knowledge (Kubernetes, DNS, TLS certificates) that they have not learned yet
2. MCP documentation is written for experienced developers — assumes knowledge of transport protocols, OAuth flows, and deployment patterns that Niko is still learning
3. Local-only MCP setups work for personal use but cannot be shared — friends cannot try the tool without installing and configuring it themselves

## Behaviors

- Builds projects using Claude API, Python, and Jupyter notebooks — comfortable with code but not with production infrastructure
- Learns by following tutorials and modifying working examples rather than reading specification documents
- Shares projects through Discord links and Twitter/X posts — a live URL that "just works" is the gold standard
- Tracks expenses carefully — student budget means free tier or nothing

## Job to Be Done

> "When I have an idea for an MCP tool that connects AI to a service I use, I want to build it from a template in an afternoon, deploy it with one click, and share a working URL with my friends, so I can focus on the fun part — making the tool do something cool — instead of fighting with deployment."

## Relationship to Product

Niko discovers MCP Host through a tutorial, a YouTube video, or a friend's link. MCP Jumpstart is the entry point — they pick a template, fill in their API credentials, and get a working project. JustMCP.it's free tier lets them deploy it live. The registry lets them discover other tools to integrate. Niko never uses SafeMCP — policy configuration is not relevant to personal projects. They would stay if the free tier is generous enough for personal use (a few tools, modest invocation volume). They would leave if the free tier is too restrictive, if the onboarding flow asks for a credit card, or if templates are stale and broken.

## Scenarios

1. **First MCP Tool** — Niko opens MCP Jumpstart, selects "Python / Notion integration," follows the step-by-step guide to fill in their Notion API key, and has a working MCP tool that reads their task list — all in under two hours with no prior MCP experience.
2. **One-Click Public Deploy** — Niko clicks "Deploy" on the JustMCP.it dashboard, gets a public URL, and shares it in their Discord server. Friends can call the tool from their own Claude instances without installing anything.
3. **Tool Discovery** — Niko browses the MCP registry for inspiration, finds a tool that generates flashcards from PDF files, and integrates it into their study agent by adding the tool URL and an API key to their agent configuration.
