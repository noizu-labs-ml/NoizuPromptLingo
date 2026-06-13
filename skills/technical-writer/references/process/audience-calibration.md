# Audience Calibration

Framework for adjusting documentation depth, vocabulary, and assumptions to match the target reader.

## Why This Matters

The same feature needs radically different documentation depending on who reads it. A Kubernetes deployment guide for an SRE looks nothing like one for a developer who's never touched kubectl. Writing for the wrong audience wastes the reader's time — either by over-explaining what they already know or under-explaining what they don't.

## Audience Profiles

### Profile 1: New External User

**Who:** Someone who just discovered the tool. No prior context.

| Dimension | Calibration |
|-----------|-------------|
| Vocabulary | Plain language. Define every technical term on first use. |
| Assumed knowledge | General programming concepts only. No tool-specific knowledge. |
| Example depth | Full working examples with expected output. Explain every flag. |
| Tone | Welcoming, patient. "Let's get you started." |
| Entry point | README → Getting Started → First Tutorial |
| Anti-patterns | Unexplained acronyms, "obviously," "simply," assumed environment |

### Profile 2: Developer (Integration)

**Who:** A developer integrating with your API/library. Knows programming, HTTP, CLI basics.

| Dimension | Calibration |
|-----------|-------------|
| Vocabulary | Technical vocabulary OK. Domain-specific jargon needs definition. |
| Assumed knowledge | HTTP methods, JSON, environment variables, package managers. |
| Example depth | Code snippets with context. Show request AND response. |
| Tone | Peer-to-peer. Direct and efficient. |
| Entry point | API Reference → Authentication → Quick Start |
| Anti-patterns | Over-explaining HTTP basics, "click the button" for CLI users |

### Profile 3: Internal Team Member

**Who:** Someone on the team or in the org. Has codebase access and institutional context.

| Dimension | Calibration |
|-----------|-------------|
| Vocabulary | Internal terminology, project names, team abbreviations OK. |
| Assumed knowledge | Repo structure, dev environment, internal tools, team processes. |
| Example depth | Terse — reference to files/modules, not full walkthroughs. |
| Tone | Casual professional. Internal shorthand OK. |
| Entry point | Architecture doc → Module docs → CLAUDE.md |
| Anti-patterns | Explaining git, explaining the build system, "for new hires" tone |

### Profile 4: Operator (DevOps/SRE)

**Who:** Someone running the system in production. Focused on availability, not features.

| Dimension | Calibration |
|-----------|-------------|
| Vocabulary | Ops vocabulary (pods, nodes, ingress, PV). Terse is fine. |
| Assumed knowledge | Infrastructure concepts, CLI fluency, monitoring basics. |
| Example depth | Commands with expected output. Decision trees for diagnosis. |
| Tone | Calm, procedural. "If X, do Y." |
| Entry point | Runbook → Deployment guide → Troubleshooting |
| Anti-patterns | Feature explanations, architectural rationale, marketing language |

## Calibration Checklist

When starting any doc, answer these:

1. **Who is the primary reader?** (Pick one profile — don't write for everyone)
2. **What do they know coming in?** (List 3-5 things you can safely assume)
3. **What's their goal?** (What are they trying to accomplish when they find this doc?)
4. **What's their emotional state?** (Excited to explore? Frustrated by a bug? Under pressure in an incident?)
5. **How did they get here?** (Google search? Link from README? Paged at 3am?)

## Adjusting Existing Docs

When proof-editing, check the doc's calibration:

| Signal | Problem | Fix |
|--------|---------|-----|
| Defining terms the audience already knows | Over-calibrated for beginners | Remove definitions, link to glossary |
| Using jargon without definition | Under-calibrated for beginners | Define on first use |
| Long prose explanations for simple actions | Wrong format for the audience | Replace with commands + expected output |
| "Click the Settings button" for a CLI tool | Wrong interface assumptions | Match the reader's actual interface |
| Cheerful tutorial tone in a runbook | Wrong emotional register | Switch to procedural, calm tone |

## Multi-Audience Documents

Sometimes you can't avoid multiple audiences. Strategies:

1. **Separate documents** (best) — Write distinct docs for each audience, linked from a landing page
2. **Tabbed sections** — "For developers" / "For operators" tabs (if rendering supports it)
3. **Progressive sections** — Start simple (everyone), get detailed (specialists) — clearly mark where "basic" ends and "advanced" begins
4. **Callout boxes** — `> **For operators:** ...` inline callouts for audience-specific notes

**Never:** Write a single doc that tries to serve all audiences equally. It will serve none of them well.
