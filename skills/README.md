# Skills

A collection of 40 Claude Code skills — executable knowledge modules for monetization, engineering, design, security, knowledge management, and AI agent development.

Skills are **self-contained**: each can be invoked independently via `/skill-name` in Claude Code. They reference each other but don't require each other.

## Quick Start

```
/trl-monetization-strategy    # Start here — choose your income stream
/trl-market-intelligence      # Validate your niche before building
/trl-skill-engineer           # Build new skills or improve existing ones
```

## Skills by Category

### Passive Income & Strategy

| Skill | Description |
|-------|-------------|
| [trl-monetization-strategy](monetization-strategy/) | Decision framework for choosing and sequencing passive income streams based on skills, constraints, and risk tolerance |
| [trl-market-intelligence](market-intelligence/) | Identify, validate, and score underserved niches and audiences across any monetization stream |
| [trl-conversion-engineer](conversion-engineer/) | Coordinate a multi-stream portfolio across AI Templates, Content Publishing, and Print on Demand |
| [trl-ai-templates](ai-templates/) | Build, launch, and scale AI-powered digital products — prompt libraries, automation workflows, GPT configs, MCP packages |
| [trl-content-publishing](content-publishing/) | Build authority and recurring revenue through newsletters, technical articles, tutorials, and courses |
| [trl-print-on-demand](print-on-demand/) | Design and sell niche merchandise through fulfillment partners with zero inventory risk |

**Flow:** `trl-monetization-strategy` (pick a path) → `trl-market-intelligence` (validate the niche) → execute with `trl-ai-templates`, `trl-content-publishing`, or `trl-print-on-demand` → `trl-conversion-engineer` (orchestrate the portfolio)

### Knowledge Management & Learning

| Skill | Description |
|-------|-------------|
| [trl-kb](kb/) | Gather, organize, and structure knowledge into learning paths, bibliographies, and research digests |
| [trl-kb-research](kb-research/) | Find and evaluate books, articles, papers, and open-access materials using parallel searches |
| [trl-kb-curriculum](kb-curriculum/) | Design structured learning paths with prerequisite mapping, difficulty calibration, and milestones |
| [trl-kb-digest](kb-digest/) | Synthesize research into knowledge digests calibrated from ELI5 through doctoral depth |

**Flow:** `trl-kb-research` (find resources) → `trl-kb-curriculum` (sequence them) → `trl-kb-digest` (synthesize at target level)

### MCP Server Development

| Skill | Description |
|-------|-------------|
| [trl-mcp-builder](mcp-builder/) | Parent coordinator for the full MCP lifecycle — routes between architect and forge phases |
| [trl-mcp-architect](mcp-architect/) | Checklist-driven specification and design: tool surface, transport, auth, security |
| [trl-mcp-forge](mcp-forge/) | Implementation engineer: scaffold, build, test, containerize, and deploy MCP servers |

**Flow:** `trl-mcp-builder` (coordinate) → `trl-mcp-architect` (design) → `trl-mcp-forge` (build)

### AI & Agent Engineering

| Skill | Description |
|-------|-------------|
| [trl-agent-architect](agent-architect/) | Design, build, and validate AI agents with research-backed patterns — subagents, multi-agent systems, persona definitions, prompt/context engineering, tool design, memory, guardrails |
| [trl-agentic-harness-engineer](agentic-harness-engineer/) | Design, implement, evaluate, and security-harden LLM agentic systems — from architecture through production deployment |
| [trl-rapid-prototype](rapid-prototype/) | Rapid prototyping and feasibility validation — from idea to working demo to go/no-go recommendation in a single session |
| [trl-research-and-development](research-and-development/) | Design and execute structured R&D workflows: hypothesis formation, experiment design, data collection, analysis, and publication |

### Mobile & Desktop Engineering

| Skill | Description |
|-------|-------------|
| [trl-ios-mobile-engineer](ios-mobile-engineer/) | Production-ready iOS apps from concept through App Store submission using SwiftUI and Swift |
| [trl-android-mobile](android-mobile/) | Production-ready Android apps using Kotlin, Jetpack Compose, and Material Design 3 |
| [trl-osx-design-and-develop](osx-design-and-develop/) | Production-ready macOS desktop apps using SwiftUI — menu bar apps, document-based apps, multi-window, Mac App Store and notarized distribution |

### Design & Frontend

| Skill | Description |
|-------|-------------|
| [trl-user-experience-engineer](user-experience-engineer/) | Design and implement UIs from brief through production — web, terminal, SVG mockups, logos |
| [trl-react-engineer](react-engineer/) | Production-grade React engineering with Next.js 15-16, Redux Toolkit, React Server Components, View Transitions, and TypeScript |
| [trl-lit-dev](lit-dev/) | Design and implement production-ready Lit v3 web components — from single elements through full design systems |
| [trl-seo-guru](seo-guru/) | Audit and optimize for search engines and AI answer engines (GEO, AEO, schema markup, llms.txt) |
| [trl-tui-engineer](tui-engineer/) | Design and build terminal UIs across Rust, Go, C/C++, TypeScript, Java, and shell — dashboards, forms, wizards, and interactive CLI tools |

### Backend & Infrastructure

| Skill | Description |
|-------|-------------|
| [trl-kubernetes-engineer](kubernetes-engineer/) | Production K8s and Helm engineering — chart authoring, CRD design, security hardening, autoscaling (Karpenter, KEDA), GitOps, and operational cookbook |
| [trl-terraform-engineer](terraform-engineer/) | Production-grade Terraform infrastructure across AWS, GCP, Azure, Kubernetes, and Cloudflare — modules, state, CI/CD, testing, policy-as-code |
| [trl-dba-db-designer-and-tuning](dba-db-designer-and-tuning/) | Database schema design, query optimization, migration planning, and PostgreSQL tuning |
| [trl-threat-modeler](threat-modeler/) | Defensive security analysis using STRIDE, PASTA, and OWASP — threat modeling, compliance, hardening |
| [trl-metal-graphics-dev](metal-graphics-dev/) | GPU-accelerated macOS/iOS apps with Apple Metal — shaders, render/compute pipelines, profiling |
| [trl-media-solution-architect](media-solution-architect/) | Design, build, and optimize self-hosted CDN and media streaming systems from ingest to playback |
| [trl-plugin-architect](plugin-architect/) | Design plugin architectures for extensible software — extension points, registries, lifecycle management, SDK generation |

### Elixir Framework Reference

| Skill | Description |
|-------|-------------|
| [trl-noizu-frameworks](noizu-frameworks/) | Comprehensive reference for the Noizu Elixir ecosystem — 13 libraries covering GenAI/LLM providers, entity persistence, distributed worker pools, cache invalidation, vector databases, and utilities |

### Documentation, Professional Services & Meta

| Skill | Description |
|-------|-------------|
| [trl-technical-writer](technical-writer/) | Author, proof-edit, and review technical docs — READMEs, API references, onboarding guides, runbooks |
| [trl-proposal-writer](proposal-writer/) | Draft, structure, and refine professional proposals and statements of work for consulting and freelance engagements |
| [trl-content-generator](content-generator/) | Research-driven content ideation, trend validation, and platform-optimized abstract creation for technical publishing pipelines |
| [trl-skill-engineer](skill-engineer/) | Design, build, and validate new skills from requirements through production-ready scaffolds |
| [trl-game-design](game-design/) | End-to-end game design, production, and monetization across mobile, PC, console, and cross-platform — from concept through live ops |

## Skill Structure

Each skill follows a consistent layout:

```
skill-name/
├── SKILL.md              # Entry point — persona, instructions, workflows
├── references/           # Detailed playbooks, guides, and frameworks
└── assets/               # Templates, trackers, and reusable artifacts
```

## Adding a New Skill

Use the `trl-skill-engineer` skill to scaffold and validate new skills:

```
/trl-skill-engineer
```

It walks through interactive discovery, generates the file tree, and evaluates against quality rubrics.
