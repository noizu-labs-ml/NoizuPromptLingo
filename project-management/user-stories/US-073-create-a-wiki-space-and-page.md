---
id: US-073
title: "Create a Wiki Space and Page"
slug: "create-a-wiki-space-and-page"
personas: [P-003]
epic: "Social & Collaboration"
priority: "must-have"
complexity: "S"
tags: [wiki, spaces, pages, documentation]
---

# US-073: Create a Wiki Space and Page

## User Story

**As a** Delivery Lead (Priya Anand, P-003),
**I want to** create a new wiki Space and add a first Page to it,
**So that** I can stand up a home for a project's living documentation (runbooks, decisions, onboarding notes) without leaving the platform.

## Acceptance Criteria

- [ ] Given a project with no existing wiki Space of a given name, when a new Space is created with a name and description, then it appears in the project's wiki Space list immediately.
- [ ] Given an existing Space, when a new Page is created within it with a title and body content, then the Page is listed under that Space and is retrievable by its title.
- [ ] Given a Space name that already exists in the project, when creation of a duplicate-named Space is attempted, then the request is rejected with a clear naming-conflict error.

## Notes

Foundational story for the rest of the wiki cluster: comments (US-074), attachments (US-075), reactions (US-076), and keyword search (US-071) all assume a Space/Page already exists.
