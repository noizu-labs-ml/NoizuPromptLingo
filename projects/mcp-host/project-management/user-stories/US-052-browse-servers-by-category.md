---
id: US-052
title: "Browse MCP servers by category"
slug: "browse-servers-by-category"
personas: [P-001, P-004, P-007]
epic: "Registry & Discovery"
priority: "must-have"
complexity: "M"
tags: [registry, browse, categories, discovery]
---

# US-052: Browse MCP Servers by Category

## User Story

**As a** AI/ML Engineer (P-004),
**I want to** browse MCP servers organized by category (Communication, Data & Storage, Developer Tools, AI & ML, Productivity, Infrastructure, Finance, Custom),
**So that** I can discover relevant tools for my use case even when I do not have a specific keyword to search for.

## Acceptance Criteria

- [ ] Given the user navigates to the Registry page, when the page loads, then the system displays the eight categories as clickable cards with icons, names, and the count of listed servers in each.
- [ ] Given the user clicks a category card, when the category page loads, then it displays all listed MCP servers in that category sorted by a combination of trust score (US-056) and popularity.
- [ ] Given a category contains more than 20 servers, when the user scrolls, then paginated results load with consistent sort order preserved across pages.
- [ ] Given the user is viewing a category, when they click a server card, then they are navigated to the detailed tool page (US-054).
- [ ] Given a server belongs to multiple categories (e.g., an MCP server in both "AI & ML" and "Developer Tools"), when browsing either category, then the server appears in both with consistent presentation.
- [ ] Given the user is on a category page, when they apply additional filters (US-053), then the filters narrow results within the selected category.

## Notes

Categories are defined in the architecture as: Communication, Data & Storage, Developer Tools, AI & ML, Productivity, Infrastructure, Finance, Custom. Servers may belong to a primary category with optional secondary tags. Related: US-051 (keyword search), US-053 (filtering).
