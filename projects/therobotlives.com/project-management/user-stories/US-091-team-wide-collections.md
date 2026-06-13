---
id: US-091
title: "Team-Wide Resource Collections"
slug: "team-wide-collections"
personas: [P-003, P-005]
epic: "Team & Org Features"
priority: "could-have"
complexity: "L"
tags: [teams, collections, resources]
---

# US-091: Team-Wide Resource Collections

## User Story

**As an** MCP Server Developer (P-005),
**I want to** create and manage shared resource collections that all team members can contribute to and access,
**So that** my team can build a library of useful prompts, skills, and MCP configs together.

## Acceptance Criteria

- [ ] Given I am an organization member, when I access the organization's collections page, then I see a list of shared resource collections
- [ ] Given I click "Create Collection", when I enter a name and description, then I create a new organization-owned where any team member can add resources
- [ ] Given I'm viewing a collection, when I click "Add Resource", then I can search for and add any public resource or upload a new resource to the collection
- [ ] Given a team member adds a resource to a collection, when the resource is added, then all team members see the new resource in the collection
- [ ] Given I leave an organization, when I check my collections, then organization-wide collections disappear from my personal view

## Notes

Collections are organization-scoped, not user-scoped. Team members can collaboratively curate collections. Collections can be marked as "Organization Official" vs "Community Curated".