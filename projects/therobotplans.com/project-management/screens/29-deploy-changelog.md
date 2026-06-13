# Deploy Changelog

| Field | Value |
|-------|-------|
| **ID** | `deploy-changelog` |
| **Type** | Primary |
| **Category** | CI/CD & Deployments |
| **User Stories** | US-044, US-061 |

## Description

Auto-generated changelogs from linked work items and commits, grouped by category (features, fixes, chores). AI enriches with human-readable summaries. Supports multiple export formats.

## Key Components

- **Changelog entry list** — Items included in this deploy grouped by type
- **Category grouping** — Features, Bug Fixes, Chores, Breaking Changes
- **Commit list** — Raw commits included in the deploy
- **AI summary draft** — Agent-written human-readable summary
- **Export actions** — Markdown, PDF, Slack message, email
- **Format selector** — Choose output format and level of detail

## Interactions

- Auto-generated on each deploy
- Edit AI summary before publishing
- Choose export format and audience
- Compare changelogs between deploys
- Link to individual items/commits for detail

## Navigation

- Accessible from: Pipeline Status, Environment Dashboard, Deploy Approval
- Links to: Item detail, Commit detail, Client Report Generator
