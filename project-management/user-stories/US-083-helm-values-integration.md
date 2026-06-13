---
id: US-083
title: "Integrate with docker-build and deploy-service pipeline"
slug: helm-values-integration
personas: [P-003]
epic: "Integration"
priority: could-have
complexity: medium
tags: [integration, docker-build, deploy-service, helm]
---

# US-083: Integrate with docker-build and deploy-service pipeline

## User Story

**As a** DevOps engineer deploying containerized apps
**I want to** generate media assets as a build step before Docker image creation
**So that** assets are baked into the Docker image at build time

## Acceptance Criteria

- **Given** a Makefile with media generation as a prerequisite
  **When** `docker-build` runs
  **Then** assets are generated before the Docker build context is assembled

- **Given** a CI pipeline with media generation
  **When** the pipeline runs
  **Then** generated assets are available for the deploy step

## Notes
Integration point: Makefile target that runs generate-media-prompt before docker build.
