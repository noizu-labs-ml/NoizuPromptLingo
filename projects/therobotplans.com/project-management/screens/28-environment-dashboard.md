# Environment Status Dashboard

| Field | Value |
|-------|-------|
| **ID** | `environment-dashboard` |
| **Type** | Dashboard |
| **Category** | CI/CD & Deployments |
| **User Stories** | US-045 |

## Description

All environments (dev, staging, production, etc.) with deployed service versions, drift detection between environments, last deploy info, and service-level filtering.

## Key Components

- **Environment cards** — One card per environment (dev, staging, prod)
- **Version per service** — Current deployed version for each service
- **Drift indicators** — Highlights when environments have different versions
- **Last deploy timestamp** — When the last deploy occurred
- **Deployer identity** — Who/what triggered the last deploy
- **Project filter** — Focus on a specific project's services

## Interactions

- Compare versions across environments at a glance
- Click drift indicator to see version difference details
- Navigate to deploy changelog for any environment
- Trigger deploy from this view (with approval gate)
- Filter by project or service

## Navigation

- Accessible from: DevOps nav, Portfolio Dashboard
- Links to: Deploy Changelog, Pipeline Status, Deploy Approval
