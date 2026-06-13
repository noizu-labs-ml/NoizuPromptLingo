---
id: P-004
name: "Jordan Rivera"
slug: "jordan-the-a11y-advocate"
archetype: "The Accessibility-First User"
segment: "secondary"
tags: [accessibility, screen-reader, assistive-tech, advocacy, standards]
---

# Jordan Rivera — The Accessibility-First User

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 32-45 |
| **Role** | Accessibility consultant / QA engineer |
| **Technical Level** | Intermediate-Advanced |
| **Industry** | Consulting / Civic tech |
| **Location** | Portland, Oregon |

## Bio

Jordan is legally blind and uses a screen reader (NVDA on Windows, VoiceOver on macOS) as their primary interface. They also consult for organizations on WCAG compliance. They've filed bugs against every major browser's accessibility tree implementation. They believe AI can be transformative for accessibility — but only if the browser's own accessibility tree is correct first.

## Goals

1. A browser with a correct, complete accessibility tree — not the half-implemented versions in current browsers
2. AI-powered page understanding: "describe what's on this page," "find the main content," "skip to the form"
3. Better handling of sites that have poor semantic HTML — AI can infer structure where ARIA is missing

## Frustrations

1. Chrome's accessibility tree has known bugs that have been open for years
2. Sites with bad HTML produce garbage accessibility trees — the browser should compensate
3. "Accessibility overlays" are snake oil — the browser itself needs to be better
4. No browser lets them query the accessibility tree programmatically for testing

## Behaviors

- Tests every browser update against their personal suite of accessibility edge cases
- Maintains a blog documenting browser accessibility bugs
- Contributes to the ARIA spec working group
- Uses both screen reader and magnification depending on context

## Job to Be Done

> "When I encounter a website with poor semantic HTML, I want the browser to use AI to infer the correct accessibility tree, so my screen reader gives me a usable experience instead of garbage."

## Relationship to Product

Jordan discovers therobotbrowses through the accessibility community (A11y Slack, WebAIM). They'd adopt it first as a testing tool (MCP access to the accessibility tree), then as a daily driver if the AI-enhanced accessibility is good enough. They'd become a passionate advocate or vocal critic depending on whether we take accessibility seriously from day one.

## Scenarios

1. **AI-enhanced navigation** — Jordan visits a poorly-structured news site. The browser's AI infers heading hierarchy, landmark regions, and link purposes from visual layout and context. Jordan navigates by landmarks and headings as if the site had perfect ARIA.
2. **Accessibility testing** — Jordan uses MCP tools to query the accessibility tree of a client's site, comparing it against expected roles and properties, generating a compliance report without leaving the browser.
