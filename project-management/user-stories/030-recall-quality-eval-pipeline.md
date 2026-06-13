---
id: story-030
title: "Build recall quality evaluation pipeline"
persona: persona-human-developer
priority: should-have
complexity: L
status: draft
---

# Build recall quality evaluation pipeline

**As** a Human Developer,
**I want to** run an automated evaluation pipeline that measures recall quality — precision, recall, emotional relevance, and latency — against a curated test dataset,
**So that** I can objectively assess memory system performance, detect regressions after configuration changes, and benchmark different tuning profiles.

## Acceptance Criteria
- [ ] Eval pipeline accepts a test dataset of (query, expected_memories, emotional_context) tuples
- [ ] Metrics computed: precision@K (default K=5), recall@K, NDCG (normalized discounted cumulative gain), emotional relevance score (average emotional similarity of returned results), and P95 latency
- [ ] Results are output as a structured report (JSON) with per-query breakdown and aggregate scores
- [ ] Pipeline supports A/B comparison: run the same test dataset against two different configurations and produce a diff report
- [ ] Integration with CI/CD: pipeline can be invoked as a CLI command and fails with non-zero exit code if any metric drops below configured thresholds
- [ ] Test datasets can be versioned and stored alongside the codebase

## Scenario: Regression detection after decay parameter change
- **Given** the operator changed the base decay half-life from 30 to 14 days yesterday
- **When** the developer runs the eval pipeline with the standard test dataset
- **Then** the report shows recall@5 dropped from 0.82 to 0.65 (memories decayed below salience threshold), flags the regression with a diff against the previous run, and the CI pipeline fails

## Scenario: A/B comparison of recall scoring weights
- **Given** two configuration profiles: "balanced" (semantic: 0.4, emotional: 0.3) and "emotional-first" (semantic: 0.25, emotional: 0.5)
- **When** the developer runs A/B comparison with a test dataset containing emotionally-charged queries
- **Then** the diff report shows "emotional-first" has 15% higher emotional relevance scores but 8% lower precision@5 on factual queries, enabling an informed trade-off decision

## Technical Notes
- The test dataset should include diverse query types: factual, emotional, temporal, cross-domain, and negative (queries that should return nothing)
- Consider using human-labeled relevance judgments for the ground truth dataset
- NDCG is the standard IR metric for evaluating ranked results with graded relevance
- The eval pipeline should be runnable against a separate "eval" memory web (not production) seeded from the test dataset
- Store eval results as time-series data for trend analysis across releases

## Related Stories
- story-029: The API is the interface through which the eval pipeline submits queries
- story-024: Emotional recall quality is a key metric in the eval pipeline
- story-025: Multi-path search performance is measured by the eval pipeline
- story-026: Winnowing quality directly affects precision@K scores
- story-028: Operator tuning decisions should be validated by running the eval pipeline before and after changes
