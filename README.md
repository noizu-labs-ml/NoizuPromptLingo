# NOIZUAI-2: TheRobotMakes — Idea to Running Product

**Domain:** [therobotmakes.com](https://therobotmakes.com)
**Style:** Editorial + Minimal Tech (80/20)
**Stack:** FastAPI + Next.js + TimescaleDB (extends PRIOR.md template)

---

## Elevator Pitch

**Put your pen down.** noizu.ink is a guided pipeline that takes an informal project description and walks it through planning, design, prototyping, and agent-driven development — producing not just specs but working code, live mockups, and deployable projects. First stroke to finished masterpiece.

## The Problem

The gap between "I have an idea" and "I have a running thing" is enormous:
- Planning tools stop at documents nobody reads
- Design tools stop at mockups nobody builds
- AI coding tools start from scratch with no spec, no structure, no plan
- The handoff between planning → design → development is where projects die

Everyone has the first five minutes of enthusiasm. Nobody has the 50 hours of follow-through. The blank page never fills itself.

## The Solution

A **step-by-step pipeline** that goes from rough sketch to deployed product. Each phase is a focused, bounded interaction — a deliberate stroke. AI agents handle the heavy lifting; the user steers.

### The Pipeline

```
Phase 1: SKETCH  (Plan)
  Step 1: Pitch        →  "Describe your idea in 2-3 sentences"
  Step 2: Personas     →  "Who are the 2-3 people who'd use this?"
  Step 3: User Stories →  "What does each persona need to do?"
  Step 4: PRD          →  "Let's structure this into a spec"

Phase 2: DRAFT  (Design)
  Step 5: Style Guide  →  "What should this look and feel like?"
  Step 6: Wireframes   →  "What do the key screens look like?"
  Step 7: Mockups      →  "Here's the visual design — approve or revise"

Phase 3: INK  (Build)
  Step 8: Scaffold     →  "Generating project structure, dependencies, config"
  Step 9: Develop      →  "Agents building against your stories — watch or steer"
  Step 10: Demo        →  "Here's your running prototype — try it"

Phase 4: PUBLISH  (Ship)
  Step 11: Review      →  "Code review, test coverage, security scan"
  Step 12: Deploy      →  "Push to Vercel/Railway/Fly — your app is live"
```

Each step:
- Has a **dedicated system prompt** (cacheable, reusable across all users)
- Takes **structured input** from previous steps (not raw conversation history)
- Produces **structured output** (JSON/markdown/code with known schema)
- Uses **minimal tokens** — small context window per step, no carrying full chat history
- Is **independently resumable** — user can leave after Step 4 and return next week
- Can be **re-entered** — go back to Step 6 wireframes after seeing the demo, regenerate

### Why Not Free-Form Chat?

| | Free-form chat | Guided pipeline |
|---|---|---|
| Token cost per project | ~$0.50-2.00 (unpredictable) | ~$0.05-0.15 per planning step (bounded) |
| Output consistency | Varies wildly | Schema-enforced |
| Prompt caching | Impossible (unique conversations) | High hit rate (shared system prompts) |
| Resume experience | "Where were we?" | Step 6 of 12, click continue |
| User cognitive load | "What do I say next?" | "Review this, approve or adjust" |

### Phase Boundaries

Users can stop and export at any phase boundary:
- **After Sketch (Plan):** Get a complete PRD, personas, and stories → markdown/GitHub/Linear
- **After Draft (Design):** Get a style guide + mockups → Figma spec, HTML style guide, SVG assets
- **After Ink (Build):** Get a working demo project → GitHub repo, local dev environment
- **After Publish (Ship):** Get a deployed, live application → production URL

This means the free tier can offer Sketch only, with upsells to Draft, Ink, Publish.

## Target Personas

### 1. Marcus Chen — Solo Developer ("Weekend Builder")
- **Who:** Developer with a day job and side project ideas
- **Pain:** Has 30 ideas in Apple Notes, none structured enough to start
- **Use case:** Paste in a rough idea, get back a running prototype by end of weekend
- **Success metric:** Has a deployed demo to show people on Monday

### 2. Jules Okafor — Indie Hacker ("Ship Fast")
- **Who:** Building products for revenue, time-constrained
- **Pain:** Can spec it, can design it, but the 40 hours of scaffolding/boilerplate kills momentum
- **Use case:** Go from validated idea to launched MVP in a day, not a month
- **Success metric:** First paying customer within the week

### 3. Rina Patel — Small Team Lead ("Alignment Tool")
- **Who:** 2-5 person team, no dedicated PM or designer
- **Pain:** Everyone has a different mental model of what they're building
- **Use case:** Generate shared spec + mockups + working scaffold that the team can fork and develop
- **Success metric:** Team has a running codebase to iterate on, not a Google Doc to argue about

## Core Features

### MVP (v0.1) — Sketch: Plan
- [ ] Step-by-step wizard (Pitch → Personas → Stories → PRD)
- [ ] AI-guided refinement per step (bounded, cacheable prompts)
- [ ] Structured output per step (JSON schema)
- [ ] Project persistence and resume
- [ ] Markdown export
- [ ] Auth via template (email/password + Google OAuth)

### v0.2 — Draft: Design
- [ ] Style guide generation (color, typography, spacing from product type)
- [ ] ASCII wireframe generation from stories
- [ ] SVG mockup generation from wireframes + style guide
- [ ] Interactive mockup preview (click-through prototype)
- [ ] Export: HTML style guide, Figma spec, SVG assets

### v0.3 — Ink: Build
- [ ] Project scaffold generation (Next.js/FastAPI/etc. from tech spec)
- [ ] Agent-driven development: stories become implementation tasks
- [ ] Agent dashboard: watch agents work, approve/reject changes per story
- [ ] Live demo preview (sandboxed running instance)
- [ ] Code review agent (linting, security, test coverage)
- [ ] Export: GitHub repo, downloadable zip

### v1.0 — Publish: Ship
- [ ] One-click deploy (Vercel, Railway, Fly.io)
- [ ] CI/CD pipeline generation
- [ ] Domain connection
- [ ] Post-launch monitoring setup
- [ ] Iteration loop: user feedback → new stories → agents implement

## Agent Architecture (Ink Phase)

The Ink phase is where noizu.ink becomes more than a planning tool. It orchestrates **specialized AI agents** that work against the user's approved spec:

```
┌─────────────────────────────────────────────────┐
│  AGENT ORCHESTRATOR                              │
│  Input: PRD + Stories + Mockups + Tech Spec      │
├─────────────────────────────────────────────────┤
│                                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ Scaffold │  │  Coder   │  │  Tester  │       │
│  │  Agent   │→ │  Agent   │→ │  Agent   │       │
│  └──────────┘  └──────────┘  └──────────┘       │
│       ↓              ↓              ↓             │
│  Project        Story-by-      Test suite        │
│  structure      story impl     + coverage        │
│                                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ Reviewer │  │  Design  │  │  Deploy  │       │
│  │  Agent   │  │  Agent   │  │  Agent   │       │
│  └──────────┘  └──────────┘  └──────────┘       │
│       ↓              ↓              ↓             │
│  Code review   CSS/components  Infrastructure    │
│  + security    from mockups    + CI/CD           │
│                                                   │
└─────────────────────────────────────────────────┘
```

### Agent Workflow per Story

```
Story (approved) → Coder Agent writes implementation
                 → Tester Agent writes + runs tests
                 → Reviewer Agent checks quality
                 → User approves or requests changes
                 → Next story
```

### User Control Model

Users don't just watch agents work — they **steer**:
- **Approve/reject** each story's implementation before it merges
- **Pause** agent work to manually edit code
- **Reprioritize** which stories agents tackle next
- **Fork** — take the generated codebase and develop locally at any time
- **Rollback** — revert any agent's changes per story

## User Flow

```
Landing Page → Sign Up / Log In
       ↓
  Dashboard (your projects)
       ↓
  "+ New Project"
       ↓
  Phase 1: SKETCH
  ├── Step 1: Pitch (freeform text + AI refinement)
  ├── Step 2: Personas (AI suggests, user curates)
  ├── Step 3: User Stories (AI generates, user curates)
  └── Step 4: PRD (AI assembles, user reviews)
       ↓  [can export here]
  Phase 2: DRAFT
  ├── Step 5: Style Guide (AI generates from product type)
  ├── Step 6: Wireframes (AI generates from stories)
  └── Step 7: Mockups (AI renders, user approves)
       ↓  [can export here]
  Phase 3: INK
  ├── Step 8: Scaffold (agents generate project structure)
  ├── Step 9: Develop (agents implement story by story)
  └── Step 10: Demo (live preview of running app)
       ↓  [can export here]
  Phase 4: PUBLISH
  ├── Step 11: Review (automated code review + security scan)
  └── Step 12: Deploy (one-click to production)
       ↓
  Dashboard (project saved at whatever step)
```

## Story IDs

Stories use the prefix `INK-xxx` (e.g., INK-001, INK-042).

## Key Screens

### 1. Landing Page
- Headline: "Put your pen down."
- Subhead: "First stroke to finished product."
- Demo: animated pipeline showing all 4 phases (Sketch → Draft → Ink → Publish)
- CTA: "Start your first project — free"
- Social proof: example projects built with noizu.ink

### 2. Wizard Step View (Sketch + Draft Phases)
- **Top:** Phase tabs (Sketch · Draft · Ink · Publish) + step progress within phase
- **Main area:** Step-specific UI (form fields, editable cards, mockup canvas)
- **Right sidebar:** AI suggestions panel with Accept/Edit/Reject per suggestion
- **Bottom:** "Back" / "Next Step" / "Save & Exit"

### 3. Agent Dashboard (Ink Phase)
- **Left:** Story backlog — ordered list, current story highlighted, status per story (queued → in progress → review → done)
- **Center:** Live agent output — code diff, file tree changes, terminal output
- **Right:** Story detail — acceptance criteria checklist, auto-checked as agents implement
- **Bottom:** Agent controls — Approve, Request Changes, Pause, Skip

### 4. Demo Preview (Ink Phase)
- **Full-width:** Embedded iframe of running application
- **Floating toolbar:** Device switcher (desktop/tablet/mobile), refresh, open in new tab
- **Side panel (toggle):** List of implemented stories with pass/fail status

### 5. Deploy View (Publish Phase)
- Target selector: Vercel / Railway / Fly.io / Docker
- Environment config: env vars, domain, database
- Deploy log: real-time streaming output
- Post-deploy: live URL, monitoring dashboard link

### 6. Dashboard
- Project cards: title, current phase/step, agent status (if building), last edited
- Phase indicators: Sketch ✓ · Draft ✓ · Ink (3/7 stories) · Publish —
- Quick actions: continue, duplicate, export, archive, view demo

## UX Direction

**Style: Editorial + Minimal Tech (80/20)** — the editorial layer carries brand identity; the minimal tech layer carries functional clarity. Ink-inspired, typographic, deliberate.

- **Typography:** Serif headings (editorial weight, generous leading) for content areas and marketing surfaces. Mono for AI output, code, specs, and agent views. The contrast between the two registers is intentional — craft vs. machine.
- **Color:** Paper-white backgrounds for content areas (Sketch, Draft phases). Ink-dark backgrounds for code and agent views (Ink phase) — the moment the pen meets the page. Single warm accent for CTAs and active states.
- **Layout:** Wizard for Sketch/Draft, agent dashboard for Ink, full-screen for demo preview
- **Motion:** Agent activity indicators, smooth step transitions, code diff animations — purposeful, not decorative
- **Tone:** Direct, deliberate, slightly opinionated ("You should define your MVP before wireframing")

**Anti-patterns to avoid:**
- No gamification (this isn't a productivity app)
- No complex onboarding (the wizard IS the onboarding)
- No feature tours (progressive disclosure through the pipeline itself)
- No "AI is thinking" spinners for long tasks — show real-time agent activity instead

## Differentiators

| vs. | noizu.ink |
|-----|-----------|
| ChatGPT/Claude | Purpose-built pipeline, not open-ended chat. Structured output, project persistence, agent orchestration |
| Notion AI | Doesn't stop at docs — goes through design, build, deploy |
| Linear/Jira | Creates the specs AND implements them. Upstream + downstream |
| Cursor/Copilot | Starts from spec, not from blank file. Agents work against approved stories, not vibes |
| Bolt/v0/Lovable | Has Sketch/Draft phases first. You understand what you're building before agents touch code |
| Devin/Factory | User stays in control per story. Not a black box — approve each change |

## Monetization

| Tier | Price | Includes |
|------|-------|----------|
| Free | $0 | Sketch only (Plan). 3 projects, markdown export |
| Pro | $19/mo | Sketch + Draft (Plan + Design). Unlimited projects, style guides, mockups, Figma export |
| Builder | $49/mo | Sketch + Draft + Ink (Plan + Design + Build). Agent development, demo preview, GitHub export |
| Launch | $99/mo | All phases. One-click deploy, CI/CD, monitoring, custom domain |

Note: Ink and Publish phases have per-project compute costs (agent runtime, sandboxed preview, deployment). Included minutes per tier, overage billed.

## Technical Notes

Built on the PRIOR.md template (FastAPI + Next.js + TimescaleDB):

### Token Economics (Sketch + Draft Phases)

| Step | Input tokens (est.) | Output tokens (est.) | Cacheable system prompt |
|------|--------------------:|---------------------:|:-:|
| Pitch refinement | ~200 | ~300 | Yes |
| Persona generation | ~400 | ~500 | Yes |
| Story generation | ~600 | ~800 | Yes |
| PRD assembly | ~800 | ~1200 | Yes |
| Style guide | ~400 | ~800 | Yes |
| Wireframes | ~500 | ~600 | Yes |
| Mockups | ~600 | ~1000 | Yes |
| **Planning total** | **~3,500** | **~5,200** | — |

**Planning cost per project: ~$0.10-0.15** (Haiku) or ~$0.40-0.60 (Sonnet).

### Ink Phase Costs

Agent-driven development is the expensive phase. Token usage scales with project complexity:

| Project complexity | Est. agent tokens | Est. cost (Sonnet) |
|---|---|---|
| Simple (5 stories, 1 page) | ~50K | ~$0.50 |
| Medium (15 stories, 5 pages) | ~200K | ~$2.00 |
| Complex (40 stories, 15 pages) | ~800K | ~$8.00 |

Mitigation: agents use structured tool calls, not free-form generation. Each story is an isolated task with bounded context.

### Architecture

- **Step engine:** Each planning step is a backend endpoint — request/response, stateless
- **Agent orchestrator:** Manages agent lifecycle for Ink phase. Assigns stories, collects output, handles approval flow
- **Sandbox runtime:** Each project gets an isolated container for live preview (Firecracker/Docker)
- **LLM calls:** One structured call per planning step. Multiple tool-use calls per agent task during Ink.
- **Prompt caching:** System prompts per step identical across all users → high cache hit rate
- **Storage:** Project state as versioned JSON document. Generated code stored in git (one branch per project).
- **Deploy pipeline:** Buildpack detection → container build → push to user's chosen platform

### Agent Tech Stack

- **Orchestrator:** Elixir/OTP (natural fit for supervising concurrent agent processes)
- **Agent runtime:** Claude API with tool use (file write, shell exec, test run)
- **Sandbox:** Per-project Docker container with code mount, exposed on unique subdomain for preview
- **Code storage:** Git repo per project (bare repo on server, pushed to GitHub on export)

## Open Questions

- Should the free tier allow one project through Ink phase as a trial?
- How to handle projects that need a database — provision per-project Postgres/SQLite?
- Agent trust model: what tools can agents invoke without user approval? (File write yes, npm install maybe, deploy no)
- Can users bring their own API key to reduce Ink phase costs?
- Marketplace: can users share/sell project templates that include Sketch + Draft + scaffold?

## Status

Concept / Pre-development

## See Also

- `@see PRIOR.md` — Template app this would be built on
