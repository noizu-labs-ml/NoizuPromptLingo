---
id: US-090
title: "Share Playground Session via URL"
slug: "playground-sharing"
personas: [P-008, P-004]
epic: "Cloud & Commercial Services"
priority: "could-have"
complexity: "M"
tags: [playground, sharing, collaboration, education, community]
---

# US-090: Share Playground Session via URL

## User Story

**As a** CS educator (P-008) and tabletop GM (P-004),
**I want to** generate a shareable URL for my playground session configuration,
**So that** I can distribute a pre-configured scenario to my students or gaming group without them needing to replicate my setup manually.

## Acceptance Criteria

- [ ] Given a configured playground session, when I click "Share", then a unique URL is generated (e.g., `playground.noizurpg.com/s/abc123`) and copied to my clipboard with a success notification
- [ ] Given a share URL, when a recipient opens it in a browser, then the playground loads with the exact same component configuration as the original session (same character stats, world state, quest definitions, etc.)
- [ ] Given a share URL, when a recipient opens it, then they can interact with the session immediately without signing in, but their interactions do not modify the original sharer's session
- [ ] Given a share URL, when opened by a signed-in user, then they have the option to "Fork to My Account" which creates a personal copy they can modify and re-share
- [ ] Given a shared session that contains no user-specific data (no API keys, no personally identifiable info), when it is stored, then the URL slug is the only identifier and the session data is stored server-side for a minimum of 90 days before expiry

## Notes

Session state must be sanitized before storage to ensure no credentials are embedded in shared URLs. Pairs with US-089 (export to code) — the share URL and the code export cover two different distribution needs: browser-to-browser vs browser-to-local. Particularly valuable for P-008's classroom scenarios.
