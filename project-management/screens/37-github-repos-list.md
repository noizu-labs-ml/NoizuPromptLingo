# GitHub Repos List

| Field | Value |
|-------|-------|
| **ID** | `github-repos-list` |
| **Type** | Primary |
| **Category** | Integrations |
| **User Stories** | US-100 |

## Description

Org-scoped listing of connected GitHub repositories at `/app/[orgId]/github`, covering repository connection and default-ACL configuration.

## Key Components

- **Connected Repo Table** — repo name, default branch, connection status
- **Connect Repository Button** — starts the GitHub connection flow (US-100)
- **Default ACL Selector** — sets the default access level applied when a repo is connected (US-100)

## Interactions

- User clicks Connect Repository Button → GitHub OAuth/App flow, then the repo appears in the Connected Repo Table (US-100)
- User sets the Default ACL Selector on a repo → applies to future access grants for that repo (US-100)

## Navigation

- Accessible from: Org Dashboard (17), Admin: GitHub Integration (13)
- Links to: GitHub Repo Detail / PRs (38)
