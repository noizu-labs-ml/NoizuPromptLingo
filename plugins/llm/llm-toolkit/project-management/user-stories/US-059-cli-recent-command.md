---
id: US-059
title: "CLI Recent Command"
slug: cli-recent-command
personas: [P-001]
epic: "CLI (Ink)"
priority: must-have
complexity: low
tags: [cli, recall]
---

# US-059: CLI Recent Command

## User Story

**As a** solo power-user developer
**I want** `llm-toolkit recent <window>` (e.g. `2h`, `1d`) to list conversations touched within that window, most recent first, with project and last-message preview
**So that** I can quickly recall what I was just working on across my 4-6 client repos without opening the web UI

## Acceptance Criteria

- **Given** conversations were touched in the last 2 hours across 3 different projects
  **When** I run `llm-toolkit recent 2h`
  **Then** the CLI lists those conversations most-recent-first, each showing project name, timestamp, and a truncated last-message preview

- **Given** no conversations were touched within the requested window
  **When** I run `llm-toolkit recent 1d`
  **Then** the command prints a clear "no recent conversations" message rather than blank or empty output

- **Given** I pass an invalid window format
  **When** I run `llm-toolkit recent xyz`
  **Then** the command exits with a non-zero status and a usage error explaining valid window formats (e.g. `2h`, `1d`)

## Notes

This is Marcus's primary daily-driver command — fast recall without leaving the terminal is central to how he juggles context across multiple client repos.
