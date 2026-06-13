---
id: US-045
title: "Generated project includes CI/CD pipeline"
slug: "cicd-pipeline"
personas: [P-002, P-001]
epic: "MCP Jumpstart"
priority: "could-have"
complexity: "M"
tags: [mcp-jumpstart, scaffolding, cicd, github-actions]
---

# US-045: Generated Project Includes CI/CD Pipeline

## User Story

**As a** Platform Engineer (P-002),
**I want to** the generated MCP project to include a pre-configured CI/CD pipeline (GitHub Actions),
**So that** I get automated testing, building, and deployment from the first commit without manually writing pipeline definitions.

## Acceptance Criteria

- [ ] Given a project is generated (US-041), when the user examines the CI/CD files, then it includes `.github/workflows/ci.yml` with lint, test, and build stages triggered on push and pull request.
- [ ] Given the CI workflow runs, when the lint stage executes, then it runs the language-appropriate linter (ESLint for TypeScript, Ruff for Python, etc.) and fails on errors.
- [ ] Given the CI workflow runs, when the test stage executes, then it discovers and runs all tests in the generated test harness (US-046) and reports results.
- [ ] Given the CI workflow runs, when the build stage executes, then it builds the Docker image and validates it against a vulnerability scanner.
- [ ] Given a project is generated, when the user examines the CD workflow, then it includes `.github/workflows/deploy.yml` with a manual deployment trigger (workflow_dispatch) that builds, tags, and pushes the image to a container registry.
- [ ] Given the generated workflows, when the user reads the CI/CD section of the README, then it explains how to configure the container registry credentials, deployment target, and how to customize the pipeline stages.

## Notes

The CI pipeline should run on the generated test harness (US-046). The CD pipeline is intentionally manual-trigger by default to prevent accidental deployments. Users can customize to auto-deploy on tag or merge to main. Related: US-044 (Docker), US-046 (test harness).
