---
id: US-054
title: "Submit Solution and Receive Automated Scoring"
slug: "submit-solution-and-receive-automated-scoring"
personas: [P-008, P-001]
epic: "Academy — Labs"
priority: "must-have"
complexity: "L"
tags: [academy, labs, scoring, submission, automation]
---

# US-054: Submit Solution and Receive Automated Scoring

## User Story

**As a** CTF competitor and security student (P-008),
**I want to** submit my solution and receive immediate automated scoring with feedback,
**So that** I know whether my approach succeeded, how it was evaluated, and what I could improve.

## Acceptance Criteria

- [ ] Given I am in an active lab session, when I submit a solution (flag string, LLM output sample, or configuration artifact depending on lab type), then the scoring engine evaluates it within 10 seconds and returns pass/fail
- [ ] Given my submission is evaluated, when scoring completes, then I receive a score breakdown: objective completion percentage, technique correctness rating, and efficiency score (attempts used vs. par)
- [ ] Given my submission fails, when I receive the result, then I get a non-spoiling failure message that indicates which objective(s) were not met without revealing the solution
- [ ] Given my submission passes all objectives, when scoring completes, then the lab is marked complete, my score is recorded, and I am prompted to view the debrief
- [ ] Given I have remaining attempts, when a submission fails, then I can revise and resubmit without relaunching the environment
- [ ] Given a lab has a strict attempt limit, when I exhaust attempts, then the lab session closes and I can retry after a cooldown period (configurable per lab)

## Notes

Scoring strategy varies by lab type: attack labs use LLM judge evaluation of model outputs; defense labs evaluate configuration diffs or mitigation completeness; build challenges may use unit-test-style automated checks. The scoring engine must be pluggable to support all lab types.
