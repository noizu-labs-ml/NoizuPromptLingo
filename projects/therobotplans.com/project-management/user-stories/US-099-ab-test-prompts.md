---
id: US-099
title: "A/B test agent prompt variants"
personas: [lin-zhao]
domain: agent-eval
priority: medium
mvp_phase: "v1.0"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want to A/B test agent prompt variants by splitting traffic and comparing eval scores across versions so that I can make statistically grounded decisions about prompt changes instead of relying on gut feel.

## Acceptance Criteria

- [ ] An A/B test can be created by selecting two prompt versions for the same agent role and specifying a traffic split ratio (e.g., 50/50, 80/20)
- [ ] Task assignment to variant A or B is randomized with deterministic seeding for reproducibility
- [ ] The test dashboard shows real-time score comparison with confidence intervals and statistical significance indicators (p-value or equivalent)
- [ ] A test can be stopped early with auto-winner selection when statistical significance is reached, or manually stopped with inconclusive results recorded
- [ ] Test results are permanently linked to both prompt versions in the prompt-archival timeline for future reference

## Notes

A/B testing is the gold standard for prompt evaluation but it requires sufficient task volume to reach significance — this is why it's a v1.0 feature rather than earlier. The platform should clearly communicate when sample sizes are too small to draw conclusions, preventing users from making confident claims on noisy data. The deterministic seeding for reproducibility is important for debugging: if variant B produces a bad output, you need to know which variant handled which task. Consider supporting multivariate tests (more than two variants) in future iterations, but start with simple A/B. The traffic split should respect ongoing work — don't switch an agent's prompt mid-task, only between tasks.
