---
id: US-050
title: "Push scaffolded project directly to connected Git repository"
slug: "push-to-git-repository"
personas: [P-001, P-002]
epic: "MCP Jumpstart"
priority: "could-have"
complexity: "L"
tags: [mcp-jumpstart, scaffolding, git, integration]
---

# US-050: Push Scaffolded Project Directly to Connected Git Repository

## User Story

**As a** MCP Tool Developer (P-001),
**I want to** push the scaffolded project directly to a connected Git repository (GitHub, GitLab),
**So that** I can skip the manual download-extract-init-push workflow and have my project immediately available in version control with a clean initial commit.

## Acceptance Criteria

- [ ] Given the user has previewed and confirmed the generated project (US-047), when they click "Push to Git," then the system displays a repository connection dialog with options to create a new repository or push to an existing one.
- [ ] Given the user selects "Create new repository," when they provide a repository name and visibility (public/private), then the system creates the repository on the connected Git provider (GitHub/GitLab) using the user's OAuth token.
- [ ] Given the user selects "Push to existing repository," when they browse their repositories, then the system lists repositories from the connected Git provider and allows selection.
- [ ] Given a repository target is selected, when the user confirms, then the system initializes a Git repository with the generated project, creates an initial commit with message "Initial scaffold from MCP Jumpstart," and pushes to the remote.
- [ ] Given the push succeeds, when the operation completes, then the system displays a link to the repository on the Git provider's web interface and a clone URL for local setup.
- [ ] Given the push fails (e.g., repository already has content, authentication expired), when the error occurs, then the system displays a descriptive error message and offers the zip download (US-049) as a fallback.

## Notes

This requires OAuth integration with GitHub and GitLab. The Git push flow should never overwrite existing repository content -- it should only push to empty repositories or new branches. If the user hasn't connected a Git provider, prompt for OAuth authorization. Related: US-049 (zip download fallback), US-047 (preview).
