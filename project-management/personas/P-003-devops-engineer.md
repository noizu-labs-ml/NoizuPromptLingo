---
id: P-003
name: "Sven Eriksson"
slug: devops-engineer
archetype: "Pipeline Automator"
segment: primary
tags: [ci-cd, automation, devops-toolchain, infrastructure]
---

# P-003: Sven Eriksson

## Demographics

| Attribute | Value |
|-----------|-------|
| Age | 38 |
| Occupation | Platform / DevOps engineer |
| Location | Stockholm, Sweden |
| Tech comfort | high |

## Bio

Sven manages the infrastructure toolchain for his team. He installed the devops toolchain and now wants to integrate `generate-media-prompt` into the CI/CD pipeline so that media assets are generated and validated as part of the build process. He cares about reproducibility, API cost tracking, and parallel execution.

## Goals
- Integrate media generation into CI/CD pipelines
- Ensure deterministic, reproducible asset generation
- Track API costs and generation times across pipelines
- Run generation in parallel for independent assets

## Frustrations
- Non-deterministic AI outputs break build reproducibility
- No visibility into how much API generation costs per sprint
- Sequential generation is slow for large asset directories

## Behaviors
- Uses `--dry-run` in CI to validate prompt files without spending API credits
- Stores `.media.prompt` files in the repo alongside Helm charts and Dockerfiles
- Wants seed values and model pinning for reproducibility
- Monitors generation via structured logging

## Job to Be Done
> "When I set up a CI pipeline, I want media generation to be a deterministic, parallelizable build step with cost visibility, so assets are produced reliably alongside code artifacts."

## Relationship to Product
Infrastructure-focused user. Configures the tool for team use rather than personal use. Cares about config resolution, API key management, error handling, and integration with the broader devops toolchain. Likely to contribute provider implementations.

## Scenarios
- **Scenario 1: CI Integration** — Adds `generate-media-prompt --force assets/` to the CI pipeline after code checkout, generating all assets before the Docker build step
- **Scenario 2: Cost Estimation** — Runs `--dry-run --verbose` to preview the generation plan and estimate costs before committing to API calls
- **Scenario 3: Parallel Generation** — Runs generation on a directory with 20 independent prompts, expecting within-tier parallelism to complete in seconds rather than minutes
