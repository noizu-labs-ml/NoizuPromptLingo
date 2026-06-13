# Prototype Variants

Adapting the trl-rapid-prototype process for non-code spikes.

## Design Spike

**When:** You need to validate a UX concept, information architecture, or visual approach before coding.

**Differences from code spike:**
- Phase 2 output is a mockup/wireframe, not running code
- Feasibility matrix replaces "Performance" with "User Comprehension"
- Feasibility matrix replaces "Dependencies" with "Design System Fit"
- Timebox is typically shorter (1-2h total)

**Tools:** SVG mockups, Figma (via MCP), hand-drawn sketches photographed and described

## Data Spike

**When:** You need to validate that data exists, is accessible, and has the right shape for a feature.

**Differences from code spike:**
- Phase 2 is exploratory queries and data profiling, not app code
- Add "Data Quality" dimension (completeness, accuracy, freshness)
- Replace "Maintainability" with "Data Pipeline Complexity"
- Often blocked by access — factor permission lead time into timebox

**Tools:** SQL queries, pandas/jupyter exploration, API exploration scripts

## Architecture Spike

**When:** You need to validate that a system design handles a non-functional requirement (scale, latency, fault tolerance).

**Differences from code spike:**
- Phase 2 may be a simulation, load test, or paper analysis rather than a demo
- Feasibility matrix emphasizes Integration and Complexity
- Add "Operational Complexity" dimension (deployment, monitoring, failure modes)
- Timebox is often longer (3-4h) because the setup cost is higher

**Tools:** Load testing (k6, wrk), architecture diagrams, back-of-envelope calculations

## Integration Spike

**When:** Two systems need to talk to each other and you need to prove it works before designing the full integration.

**Differences from code spike:**
- Phase 2 is a minimal end-to-end flow, not a feature demo
- "Integration" dimension gets double weight in scoring
- Anti-scope explicitly excludes error handling, retries, and auth flows (test with hardcoded tokens)
- Document exact API behavior observed (not just "it works") — response formats, latency, rate limits

## Research Spike

**When:** The question is "is this even possible?" and you need to investigate before building anything.

**Differences from code spike:**
- Phase 2 is literature review, documentation analysis, and small experiments
- Replace "Performance" with "Evidence Quality" (how confident are we in our sources?)
- Report may recommend a follow-up code spike rather than a go/no-go
- Timebox is shorter (1-2h) — if you can't find the answer in 2h of research, that itself is a finding
