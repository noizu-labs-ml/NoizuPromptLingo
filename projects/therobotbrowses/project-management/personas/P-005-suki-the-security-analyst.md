---
id: P-005
name: "Suki Tanaka"
slug: "suki-the-security-analyst"
archetype: "The Security-Minded Analyst"
segment: "secondary"
tags: [security, pentesting, network-analysis, privacy, forensics]
---

# Suki Tanaka — The Security-Minded Analyst

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 29-38 |
| **Role** | Application security engineer |
| **Technical Level** | Expert |
| **Industry** | Cybersecurity |
| **Location** | Tokyo, Japan |

## Bio

Suki's job is finding vulnerabilities in web applications. She currently juggles Burp Suite, browser dev tools, and a headless browser harness she wrote herself. She wants a browser where the network stack, cookie jar, TLS handshake, and DOM are all inspectable and scriptable — a browser built like a security tool, not a consumer product that happens to have dev tools.

## Goals

1. Full programmatic access to every network request/response, including TLS details
2. Scriptable cookie jar, storage, and credential management for testing auth flows
3. DOM mutation observation for detecting client-side injection
4. Ability to replay, modify, and re-send requests without leaving the browser

## Frustrations

1. Browser dev tools can't be scripted or automated
2. Burp Suite requires a separate proxy setup — context-switching kills flow
3. Headless browsers don't let her interact with the page when something unexpected happens
4. No browser exposes TLS certificate chain details programmatically

## Behaviors

- Runs authorized penetration tests and bug bounty programs
- Writes custom tooling in Rust and Python
- Maintains a library of request/response patterns for common vulnerability classes
- Documents findings in detailed reports with exact request reproduction steps

## Job to Be Done

> "When I'm testing a web application's authentication flow, I want to inspect and modify every request, cookie, and DOM mutation through scriptable APIs, so I can find vulnerabilities without context-switching between five different tools."

## Relationship to Product

Suki finds therobotbrowses through the security community (BlackHat/DEF CON talks, security Twitter). She'd use it as a specialized security testing browser first. If the MCP surface is comprehensive enough, it replaces her custom headless harness. She'd churn if the network stack hides details or if MCP access is read-only.

## Scenarios

1. **Auth flow analysis** — Suki uses MCP tools to step through an OAuth flow: inspect each redirect, examine cookies set at each step, modify a token parameter, replay the request, and verify the server's response.
2. **XSS detection** — Suki sets up a DOM mutation observer via MCP, injects test payloads through the UI, and watches for unexpected script execution or DOM changes — all scriptable and reproducible.
