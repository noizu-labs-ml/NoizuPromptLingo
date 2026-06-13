---
id: P-005
name: "Priya Nair"
slug: "content-moderator"
archetype: "The Borderline Arbiter"
segment: "edge-case"
tags: [internal, moderation, quality-review, edge-cases, borderline, ops]
---

# Priya Nair — The Borderline Arbiter

## Demographics
| Field | Value |
|-------|-------|
| **Age** | 32 |
| **Role** | Trust & Quality Reviewer (contract) |
| **Technical Level** | Intermediate |
| **Industry** | Platform Operations / Content Moderation |
| **Location** | Bangalore, India |

## Bio
Priya reviews borderline cases flagged by the AI scoring system or community users — sites that score ambiguously, submissions that might be spam, and edge cases the automated pipeline isn't confident about. She has a sharp eye for distinguishing genuine personal sites from SEO-farmed content designed to look hand-crafted. She works a review queue that mixes genuinely hard calls with obvious spam.

## Goals
1. Clear her review queue efficiently without making decisions she'd be embarrassed to defend
2. Develop consistent judgment heuristics for recurring borderline patterns (e.g., AI-written but cited, or low design quality but high depth)
3. Flag systemic scoring issues — patterns where the AI consistently gets it wrong — back to the technical team

## Frustrations
1. Borderline cases require context the review tools don't surface (who is the author, when was this built, what community does it serve)
2. Inconsistent scoring rubric documentation makes it hard to know what "human authorship 3/5" actually means in practice
3. Queue spikes when a category gets brigaded by SEO submitters or a community decides to mass-submit low-quality sites

## Behaviors
- Works the review queue in focused 2-hour blocks
- Opens the flagged site, the AI scoring rationale, and the community flag reason in parallel tabs
- Makes a binary decision (confirm score / override score / remove / escalate) with a written rationale
- Tags decisions by pattern type for monthly calibration reviews with the scoring team
- Occasionally escalates to editorial team for sites that raise policy questions (NSFW, legal, commercial spam)

## Job to Be Done
> "I need to make the right call on 40 borderline sites per shift without second-guessing myself by noon — and I need the tools to make it defensible."

## Relationship to Product
Priya is an internal user, not a public one. Her workflow requirements directly shape the moderation dashboard design — review queue management, scoring rationale display, decision audit trail, and escalation pathways. She is not monetized but her throughput and accuracy are existential to the directory's quality reputation. Her feedback is the most direct signal the team has about AI scoring failure modes.

## Scenarios
1. **The Trojan Personal Site** — A submission looks like a personal blog: hand-written prose, personal photos, thoughtful design. But Priya notices the "About" page was auto-generated and the post dates cluster in an unnatural pattern. She overrides the Human Authorship score from 4 to 2 and adds a pattern tag: "AI-ghost-written-personal-template."
2. **Calibration Escalation** — Priya notices that sites in the "Data Journalism" category are consistently scoring low on Originality because the AI penalizes aggregating data from government sources. She writes up the pattern and escalates to the scoring team for a rubric update.
