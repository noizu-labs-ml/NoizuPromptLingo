---
id: P-008
name: "Agent: CI Pipeline"
slug: "agent-ci"
archetype: "Automated CI/CD Actor"
segment: "edge-case"
tags: [automation, ci-cd, github-actions, headless, programmatic, diagram-as-code, non-human]
---

# Agent: CI Pipeline — Automated CI/CD Actor

## Demographics

| Field | Value |
|-------|-------|
| **Age** | N/A |
| **Role** | Automated Pipeline Process |
| **Technical Level** | N/A (programmatic API consumer) |
| **Industry** | Any (software engineering) |
| **Location** | Cloud / On-premises CI infrastructure |

## Bio
This persona represents an automated actor — a GitHub Actions workflow, a GitLab CI job, or a custom pipeline script — that invokes the Mockup MCP server programmatically without human interaction. It is triggered by repository events (pull requests, merges, spec file changes) and uses the MCP API to generate or update architectural diagrams, component mockups, or data-flow charts as build artifacts. The diagrams are committed back to the repository, published to a documentation site, or attached to a pull request as review artifacts. No human sits behind the keyboard; correctness, idempotency, and failure resilience are the only behavioral properties that matter.

## Goals
1. Generate or regenerate architectural and component diagrams automatically when source specs, OpenAPI definitions, or ADR files change in a pull request
2. Attach generated mockups as PR review artifacts so human reviewers see an up-to-date diagram alongside the diff without manual effort
3. Fail fast and loudly on generation errors so pipeline failures are clearly attributable to diagram generation rather than silent corruption

## Frustrations
1. N/A — this is a non-human actor. Failure modes instead: rate limits without retry guidance, non-deterministic output that breaks snapshot tests, no structured error responses, API surface that requires interactive authentication
2. Lack of idempotent generation — same input should produce deterministically identical output (or a documented hash) so diff-based checks work correctly
3. No batch endpoint — generating 20 diagrams per PR triggers 20 sequential API calls and blows the per-job time budget

## Behaviors
- Authenticates via API key (service account token) with no OAuth redirect or interactive step
- Parses structured MCP tool responses; expects JSON or structured text, not prose explanations
- Retries on 429 / 503 with exponential backoff; treats 4xx as fatal (bad input) and surfaces the error message in the CI log
- Writes generated SVG/PNG output to a deterministic file path for artifact upload or git commit
- Runs in a sandboxed container with no browser, no GUI, and no human in the loop

## Job to Be Done
> "When a spec file or architecture document changes in a pull request, I want to invoke the Mockup MCP API headlessly and attach updated diagrams to the PR, so reviewers always see current visuals without any manual diagram update step."

## Relationship to Product
This persona represents the API integration tier of the product. Developers who own CI pipelines configure the Mockup MCP server as a step in their workflow — either via the hosted API or a self-hosted MCP server container. The key product requirements this persona surfaces: a stable, versioned REST or MCP-protocol API, service-account authentication (no user OAuth), idempotent generation, structured error responses, and a batch endpoint for multi-diagram jobs. This persona does not churn — it either works reliably or is replaced by a different tool at the next quarterly toolchain review.

## Scenarios
1. **PR diagram generation** — A developer merges a branch that modifies `architecture/services.yaml`. A GitHub Actions workflow detects the change, invokes Mockup MCP's API with the updated spec, receives a C4 container diagram SVG, commits it to `docs/diagrams/services.svg`, and posts a "Diagrams updated" comment on the PR with an inline preview. Reviewers see the current diagram without opening a separate tool.
2. **Documentation site publish** — On every merge to main, a pipeline job calls Mockup MCP for all 14 spec files in `docs/specs/`, generates a full diagram set, and deploys them to the internal documentation site via a static site build step. Architecture documentation is always current with the main branch, with zero manual maintenance.
