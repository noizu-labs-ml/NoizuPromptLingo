---
id: US-102
title: "Open a Remote-Access Tunnel to a Local Dev Server"
slug: "remote-access-tunnel-local-dev-server"
personas: [P-001]
epic: "Integration & External APIs"
priority: "should-have"
complexity: "M"
tags: [remote-access, tunneling, frp, integration]
---

# US-102: Open a Remote-Access Tunnel to a Local Dev Server

## User Story

**As** Jordan Vance, the Harness Operator (P-001),
**I want to** expose my locally running dev server at a stable `<name>.remote-access.noizu.com` URL via a reverse tunnel,
**So that** I, an agent, or a reviewer can reach it from outside my machine without manually configuring port-forwarding or a separate tunneling service.

## Acceptance Criteria

- [ ] Given Jordan runs the local tunnel client (frpc) with a valid project-scoped token, when it connects to the platform's tunnel server (frps), then his local port becomes reachable at `<name>.remote-access.noizu.com` within a few seconds.
- [ ] Given the requested tunnel name is already claimed by another active tunnel, when Jordan attempts to start his with the same name, then he receives a clear conflict error rather than silently hijacking or failing opaquely.
- [ ] Given Jordan's local dev server or network connection drops, when the tunnel client disconnects, then the public URL stops routing traffic to the dead backend and reconnects automatically once the client returns.
- [ ] Given a tunnel is active, when Jordan intentionally stops the frpc client, then the `<name>.remote-access.noizu.com` route is released and becomes available for reuse within a bounded time.

## Notes

Should-have — high value for sharing WIP and agent-driven browser testing against a live local server, but not core platform functionality. Naming/claim semantics should be project-scoped to avoid cross-org collisions.
