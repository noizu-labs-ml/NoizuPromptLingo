---
id: US-100
title: "TypeScript SDK for Web Frontends"
slug: "typescript-sdk"
personas: [P-001, P-006]
epic: "Accessibility & Integration"
priority: "won't-have-yet"
complexity: "XL"
tags: [typescript, sdk, web, frontend, integration, browser]
---

# US-100: TypeScript SDK for Web Frontends

## User Story

**As an** indie game developer (P-001) and game studio lead (P-006),
**I want to** interact with a NoizuRPG game backend from a TypeScript/JavaScript web frontend using an official SDK,
**So that** I can build rich browser-based game UIs that communicate with my Python NoizuRPG backend without writing raw HTTP client code or maintaining my own API type definitions.

## Acceptance Criteria

- [ ] Given `npm install @noizurpg/client`, when I import `NoizuRPGClient`, then it is fully typed with TypeScript definitions matching the Python framework's data models (Character, WorldState, QuestStatus, DialogueTurn, MemoryEntry)
- [ ] Given a `NoizuRPGClient(baseUrl, sessionToken)`, when I call `await client.submitAction("explore the ruins")`, then it POSTs to the backend, awaits the response, and returns a typed `ActionResult` object with narrative text, state diffs, and any triggered events
- [ ] Given the SDK, when I subscribe to `client.events.on("quest.completed", handler)`, then the handler fires whenever the backend emits a `QuestCompleted` event, delivered via Server-Sent Events or WebSocket (configurable at client init)
- [ ] Given a Next.js 14+ project with `@noizurpg/client` installed, when I follow the "React Quickstart" in the SDK docs, then I have a functional game UI rendering narrative output and accepting player input within 30 minutes
- [ ] Given the TypeScript SDK and the ARIA event format from US-098, when I configure `client.events.ariaMode = true`, then all events received include `aria_live` and `aria_atomic` fields, enabling accessible React components without additional transformation

## Notes

Deferred due to the scope of maintaining a parallel TypeScript type system synchronized with the Python data models — this requires a code-generation pipeline (likely from Python Pydantic models to TypeScript interfaces). The Python backend must expose a stable REST/WebSocket API first. This story is the browser-facing complement to the Managed Memory service (US-084) and enables the full "cloud-native game" architecture.
