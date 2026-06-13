---
id: US-069
title: "Star or favorite an MCP server for quick access"
slug: "star-favorite-server"
personas: [P-001, P-007]
epic: "Social & Collaboration"
priority: "could-have"
complexity: "S"
tags: [social, favorites, bookmarks, registry]
---

# US-069: Star or Favorite an MCP Server for Quick Access

## User Story

**As a** Solo AI Hobbyist (P-007),
**I want to** star or favorite an MCP server I find useful,
**So that** I can quickly find it again later without searching or browsing the full registry.

## Acceptance Criteria

- [ ] Given the user is viewing an MCP server detail page (US-054) or a server card in search/browse results, when they click the star/favorite icon, then the server is added to their favorites list and the icon changes to a filled state.
- [ ] Given the user has starred a server, when they click the star icon again, then the server is removed from their favorites list and the icon reverts to the unfilled state.
- [ ] Given the user navigates to their profile or dashboard, when they open the "My Favorites" section, then all starred servers are listed with name, health status (US-056), and last updated date.
- [ ] Given the user has starred servers, when they visit the registry homepage, then a "Your Favorites" quick-access panel is displayed showing up to 6 recently starred servers.
- [ ] Given a starred server is deprecated (US-058) or its health status changes to unhealthy (US-056), when the change occurs, then a notification is displayed in the "My Favorites" section alerting the user.
- [ ] Given the star count for a server, when it is displayed on the server detail page (US-054), then it shows the total number of users who have starred the server as a popularity signal.

## Notes

Star counts contribute to the server's popularity ranking in search results (US-051) and trust score (US-056). This is a lightweight social signal that requires minimal user effort. Related: US-051, US-054, US-056, US-058.
