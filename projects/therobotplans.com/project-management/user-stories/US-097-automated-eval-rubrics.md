---
id: US-097
title: "Define automated evaluation rubrics for agent tasks"
personas: [lin-zhao]
domain: agent-eval
priority: high
mvp_phase: "v0.4"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want to define automated evaluation rubrics for agent tasks — covering completeness, accuracy, format compliance, and timeliness — so that agent quality is measured continuously and consistently without relying solely on human ratings.

## Acceptance Criteria

- [ ] A rubric builder allows defining evaluation criteria per task type with weighted dimensions (e.g., completeness: 30%, accuracy: 40%, format: 15%, timeliness: 15%)
- [ ] Each dimension supports configurable scoring: binary pass/fail, numeric scale (1-5), or threshold-based (e.g., "complete if all checklist items addressed")
- [ ] Automated rubrics run asynchronously after each agent task completion and store scores alongside the task output
- [ ] Rubric definitions are versioned — changing a rubric does not retroactively alter historical scores but is tracked in the eval history
- [ ] A rubric test mode allows running a rubric against historical outputs to preview scores before activating it

## Notes

Automated rubrics are what scale evaluation beyond what human rating alone can achieve. The key design tension is between rubric expressiveness and rubric reliability — overly complex rubrics that themselves use LLM judges introduce their own failure modes. Start with deterministic checks where possible (format compliance via regex, timeliness via timestamp comparison, completeness via checklist coverage) and layer in LLM-as-judge for subjective dimensions like accuracy. The rubric versioning requirement prevents a common pitfall: changing the scoring methodology and then drawing trend conclusions across the boundary. The test mode against historical data lets users calibrate rubrics before they go live.
