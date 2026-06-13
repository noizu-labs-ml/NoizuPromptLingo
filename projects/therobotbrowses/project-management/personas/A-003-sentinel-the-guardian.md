---
id: A-003
name: "Sentinel"
slug: "sentinel-the-guardian"
archetype: "The Security & Privacy Guardian"
segment: "agent-secondary"
agent_type: "background-monitor"
tags: [agent, security, privacy, monitoring, background, protection]
---

# Sentinel — The Security & Privacy Guardian

## Agent Profile

| Field | Value |
|-------|-------|
| **Type** | Background monitoring agent |
| **Interface** | MCP client → browser MCP server (event subscriptions) |
| **Autonomy Level** | Monitoring (observes and alerts, doesn't act without consent) |
| **Persistence** | Always-on during browser session |
| **Trust Level** | High read, zero write — observes everything, modifies nothing |

## Role

Sentinel is a background agent that monitors browsing activity for security and privacy concerns. It watches network requests for tracking pixels, inspects TLS certificate chains, detects suspicious DOM mutations (potential XSS), flags mixed content, and alerts on phishing indicators. It's the security analyst (Suki, P-005) in software form — but for everyday users who don't know what to look for.

## Capabilities

1. **Network Monitoring** — Watch all requests/responses for tracking domains, suspicious redirects, mixed content
2. **TLS Inspection** — Verify certificate chains, flag cert transparency issues, warn on weak ciphers
3. **DOM Mutation Watch** — Detect injected scripts, unexpected iframes, form action changes
4. **Privacy Scoring** — Rate pages on tracker count, cookie behavior, fingerprinting attempts
5. **Phishing Detection** — Compare visual appearance against known legitimate sites, check domain reputation
6. **Content Security Policy Audit** — Parse and evaluate CSP headers, flag weaknesses

## Constraints

1. Read-only — cannot block requests, modify DOM, or navigate (only alerts)
2. Cannot access encrypted request bodies (TLS termination is at the network layer)
3. Alert fatigue management — batches low-severity findings, only interrupts for critical
4. User can disable entirely or per-site
5. Does not send any data externally — all analysis is local

## Interaction Patterns

- **Background**: Runs silently, surfaces findings in a status indicator (green/yellow/red shield icon)
- **Alert**: Interrupts with a modal for critical findings (suspected phishing, active XSS, invalid TLS)
- **Report**: On-demand detailed security/privacy report for the current page or session
- **Integration**: Exposes findings via MCP for other agents (Claude can reference Sentinel's analysis)

## Scenarios

1. **Phishing alert** — User clicks a link in an email. Sentinel notices the domain is a homoglyph of a legitimate banking site, the TLS cert was issued 2 hours ago, and the login form POSTs to a different domain. It surfaces a critical alert before the user enters credentials.
2. **Privacy report** — User visits a news site. Sentinel counts 47 third-party requests, 12 tracking cookies, and 3 fingerprinting scripts. It summarizes this in the status panel. User can share this report or use it to configure blocking rules.
3. **DOM injection detection** — While browsing, Sentinel detects a script tag injected into the DOM after page load that wasn't in the original HTML. It flags this as potential stored XSS and logs the mutation for Suki's analysis.
