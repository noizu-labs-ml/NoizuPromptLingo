# Category: Git and GitHub

## Overview
Use tools in this category when a skill needs to interact with version control, manage issues or pull requests, trigger CI/CD, or integrate with project management platforms. Most dev-facing skills touch at least one tool here — whether scaffolding repos, automating PR reviews, or syncing task state.

## MCP Services

| Name | Deployment | Key Features | Security Notes | Maturity |
|------|-----------|-------------|----------------|----------|
| GitHub MCP | hosted SSE (OAuth) | Repo ops, issue/PR management, search, Actions | PAT or OAuth; broad scope by default | Stable (official) |
| GitLab MCP | hosted SSE (OAuth) | 50+ tools: MR, CI/CD pipelines, wiki, registry | PAT required; self-hosted option available | Stable (official) |
| Git MCP | local stdio | Local repo ops: log, diff, branch, commit, stash | No remote auth; local only | Stable (official) |
| Linear MCP | hosted SSE (OAuth) | Issue tracking, cycle/sprint planning, roadmap | OAuth token; data leaves machine | Stable |
| Atlassian MCP | hosted SSE (OAuth) | Jira + Confluence: 5K+ stars, issues, wiki pages | OAuth per workspace; broad data access | Mature (community) |

### GitLab MCP
- **What it does**: Full GitLab API surface — merge requests, pipelines, issues, snippets, wikis, container registry, environments, and more. 50+ discrete tools.
- **Deployment**: Hosted SSE; configure with a GitLab PAT (personal access token). Self-hosted GitLab instances supported via `GITLAB_URL` env var.
- **Key features**: Pipeline trigger and status monitoring; MR diff review and approval; wiki page CRUD; environment variable management; registry tag listing
- **Security considerations**: PAT scope determines blast radius. Use a scoped token (`read_api` for read-only tasks; add `write_repository` only when commits are needed). Rotate tokens quarterly. Never commit the token.
- **When to use**: Any skill operating in a GitLab-first organization. Preferred over GitHub MCP when CI/CD automation is the primary use case — pipeline tooling is richer.
- **When to avoid**: GitHub-hosted repos; teams where GitHub Actions is the CI standard

### GitHub MCP
- **What it does**: Manages GitHub repos, issues, PRs, branches, file contents, search, and GitHub Actions workflows.
- **Deployment**: Hosted SSE via OAuth or PAT. Official Anthropic-maintained server.
- **Key features**: Create/merge PRs, manage issue labels and milestones, search code/repos, trigger workflow dispatches, read Actions run logs
- **Security considerations**: OAuth app or PAT with `repo` scope grants wide access. Prefer fine-grained PATs scoped to specific repos. Avoid `admin:org` scope unless necessary.
- **When to use**: GitHub-first projects. Ideal for skills that automate PR creation, issue triage, or release management. Default choice for open-source workflows.
- **When to avoid**: GitLab or Bitbucket repos; air-gapped environments; when only local git ops are needed (use Git MCP instead)

### Atlassian MCP
- **What it does**: Unified interface for Jira (issue tracking, sprint boards, roadmaps) and Confluence (wiki pages, spaces, templates). Community server with 5K+ GitHub stars.
- **Deployment**: Hosted SSE via Atlassian OAuth. Supports both Jira Software and Confluence Cloud.
- **Key features**: Create/update Jira issues, transition ticket status, query JQL, read/write Confluence pages, manage sprint boards
- **Security considerations**: OAuth token scoped to Atlassian account — can access all projects the user has permission for. Use a dedicated service account for automation. Treat token as a secret.
- **When to use**: Enterprise environments where Jira is the canonical project tracker. Market-intelligence and trl-conversion-engineer skills benefit from Jira integration for tracking initiative status.
- **When to avoid**: GitHub Issues or Linear shops; lightweight projects where Jira overhead isn't justified

## CLI Tools

| Name | Install | What It Does | Skill Relevance |
|------|---------|-------------|-----------------|
| gh | `brew install gh` | GitHub's official CLI: PR/issue/release/Actions management | Scripting GitHub ops; faster than API calls for common tasks |
| git | system / `brew install git` | Core VCS: commit, branch, merge, rebase, stash | Foundation for all local repo operations |

### gh CLI
- **What it does**: GitHub's official CLI. Create and merge PRs, manage issues, trigger Actions workflows, manage releases, clone repos, and authenticate across accounts.
- **Install**: `brew install gh` then `gh auth login`
- **Key features**: `gh pr create`, `gh issue list`, `gh run watch`, `gh release create`, `gh repo clone`; JSON output (`--json`) for scripting; supports multiple accounts via `gh auth switch`
- **Skill relevance**: Use in skill shell scripts or agent tool calls when GitHub MCP isn't available or when piping output to other CLI tools. Pairs well with `jq` for structured output processing.

## Selection Guide

Choose based on your team's primary platform:

| Platform | Primary Tool | Supplementary |
|----------|-------------|---------------|
| GitHub | GitHub MCP | gh CLI for scripting |
| GitLab | GitLab MCP | Git MCP for local ops |
| Jira + Confluence | Atlassian MCP | GitHub/GitLab MCP for code |
| Linear | Linear MCP | GitHub MCP for code |
| Local only | Git MCP | — |

**Decision rules**:
- If you need CI/CD pipeline control → GitLab MCP (richer pipeline tooling) or GitHub MCP Actions tools
- If you need issue/PR management on GitHub → GitHub MCP first, gh CLI as fallback
- If the environment is enterprise with Jira → Atlassian MCP for task state; GitHub/GitLab MCP for code
- If only local git history/diffs are needed → Git MCP (no token required, no external calls)
