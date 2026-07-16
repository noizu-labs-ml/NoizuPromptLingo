---
id: US-079
title: "List GitHub Pull Requests for a Linked Repo"
slug: "list-github-pull-requests-for-a-linked-repo"
personas: [P-007]
epic: "Social & Collaboration"
priority: "should-have"
complexity: "S"
tags: [github, pull-requests, integration]
---

# US-079: List GitHub Pull Requests for a Linked Repo

## User Story

**As a** Design & Code Reviewer (Sofia Reyes, P-007),
**I want to** list open and closed pull requests for a project's linked GitHub repo from inside the platform,
**So that** I can find the PR I need to review without switching to github.com first.

## Acceptance Criteria

- [ ] Given a project with a linked GitHub repo and valid credentials, when the PR list is requested, then open pull requests are returned with title, author, branch, and status (e.g. draft, ready, checks-passing).
- [ ] Given a filter for closed or merged PRs, when the PR list is requested with that filter, then closed/merged PRs are included instead of only open ones.
- [ ] Given a project with no linked GitHub repo, when the PR list is requested, then a clear "no repo linked" state is returned instead of an empty list indistinguishable from "zero open PRs."

## Notes

Read-only surface; commenting is covered separately in US-080. Repo issue listing shares the same linkage but is out of scope for this story (pull requests only).
