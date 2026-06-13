---
id: P-007
name: "Taylor Nguyen"
slug: "taylor-qa"
archetype: "QA Engineer"
segment: "tertiary"
tags: [qa, testing, acceptance-criteria, mockup-review, annotation, requirements-verification]
---

# Taylor Nguyen — QA Engineer

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 25–38 |
| **Role** | Senior QA Engineer / SDET |
| **Technical Level** | Advanced |
| **Industry** | Software Product (Mid-size) |
| **Location** | US / Canada / Eastern Europe |

## Bio
Taylor is the QA lead for a team of 25 engineers shipping a B2B productivity platform. They write automated test suites, manage the regression suite, and own acceptance criteria validation before every release. Taylor got burned once by a sprint where the shipped UI didn't match the approved mockup and the discrepancy wasn't caught until a customer complained. Since then, they've been methodical about tracing every UI element back to an approved visual reference, but that process is slow when mockups are scattered across Figma, Notion, and a shared drive.

## Goals
1. Compare implemented UI against the reference mockup with a structured annotation workflow rather than ad hoc Slack messages
2. Generate test-scenario diagrams (user flows, state machines) from mockups to ensure test coverage maps to designed behavior
3. Participate earlier in the mockup review process — catch edge cases and missing states at the wireframe stage before implementation begins

## Frustrations
1. Mockups often don't include error states, empty states, or loading states — QA discovers these gaps only after implementation
2. There's no structured way to annotate a wireframe with "this violates acceptance criterion X" during review — feedback gets lost
3. Design artifacts and requirements documents live in different tools; tracing a UI element back to a requirement is a manual scavenger hunt

## Behaviors
- Reviews wireframes with a requirements document open in a second window, cross-referencing coverage
- Annotates UI artifacts with test IDs and requirement references when given the ability to do so
- Writes Gherkin scenarios from user flows; wants a mockup that makes the happy path and all edge-case states explicit
- Files bugs at the wireframe stage when given access to a feedback mechanism — "design bugs are cheaper than code bugs"

## Job to Be Done
> "When a new feature wireframe is ready for review, I want to annotate missing states and edge cases directly on the mockup with requirement references, so I can catch gaps before a developer writes a single line of implementation code."

## Relationship to Product
Taylor discovers Mockup MCP because a PM or developer shares a feedback link with them during a review cycle. They are an adoption amplifier: once they find the annotation and feedback features useful, they advocate for the whole team to use Mockup MCP as the standard review artifact. Key features: annotation with labels or comments tied to specific mockup regions, the ability to reference acceptance criteria in feedback, and a view of all open annotations before a design is approved. Churn happens if the feedback features are too simple (just free-text comments with no structure) or if the mockup doesn't include the edge-state coverage they need.

## Scenarios
1. **Pre-implementation QA review** — The team shares a wireframe for a new bulk-upload feature. Taylor opens the feedback link, annotates four missing states (empty upload queue, partial failure, file-type error, file-size error), and tags each annotation with the corresponding acceptance criterion ID. The designer addresses all four before handing off to engineering — zero rework in QA.
2. **Regression baseline** — Taylor uses Mockup MCP to generate a state-machine diagram for a checkout flow from the existing wireframes. Uses the diagram to verify that the automated test suite covers all 11 states. Discovers two missing test cases before the next release cycle.
