# GitHub Repo Detail / PRs

| Field | Value |
|-------|-------|
| **ID** | `github-repo-detail-prs` |
| **Type** | Primary |
| **Category** | Integrations |
| **User Stories** | US-079, US-080, US-101 |

## Description

Single-repo view at `/app/[orgId]/github/[repoId]` and its pull-request detail at `/app/[orgId]/github/[repoId]/pulls/[pullNumber]`, listing PRs, supporting PR comments, and creating new PRs from within the platform.

## Key Components

- **Pull Request List** — open/closed PRs for the linked repo (US-079)
- **Create Pull Request Button** — opens the new-PR form (US-101)
- **PR Comment Thread** — comment on a specific pull request (US-080)
- **PR Status Badge** — CI/review/merge status per PR

## Interactions

- User clicks Create Pull Request Button → form collects branch/title/description, then creates the PR on GitHub (US-101)
- User opens a PR from the Pull Request List and adds a comment via the PR Comment Thread (US-079, US-080)

## Navigation

- Accessible from: GitHub Repos List (37)
- Links to: Ticket Detail (26) when a PR is linked to a ticket
