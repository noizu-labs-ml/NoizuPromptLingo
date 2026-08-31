---
id: US-001
title: "Install via install script"
slug: install-via-script
personas: [P-001, P-007]
epic: "Onboarding & Install"
priority: must-have
complexity: low
tags: [onboarding, cli, install]
---

# US-001: Install Via Install Script

## User Story

**As a** solo power-user developer juggling multiple client repos
**I want to** run a single install script that places the `llm-toolkit` binary/CLI on my PATH
**So that** I can start using `recent`, `search`, and `show` immediately without manually wiring up paths or dependencies

## Acceptance Criteria

- **Given** a fresh machine without `llm-toolkit` installed
  **When** the user runs the published install script
  **Then** the `llm-toolkit` binary is copied to a standard bin location and is invocable as `llm-toolkit` from a new shell session

- **Given** the install script has finished running
  **When** it completes
  **Then** it prints a clear success message including the installed version and binary path, or a clear failure message with the specific error (e.g. permission denied, unsupported OS/arch)

- **Given** the user's shell PATH does not already include the install target directory
  **When** the script detects this
  **Then** it prints the exact line to add to the shell profile (e.g. `.zshrc`/`.bashrc`) rather than silently leaving the binary unreachable

- **Given** an existing `llm-toolkit` install is already present
  **When** the install script is re-run
  **Then** it upgrades in place and reports the previous and new version numbers instead of erroring or duplicating the binary

## Notes
Both personas need this to work with zero friction: Marcus (P-001) wants to get to `recent`/`search` fast across his 4-6 client repos, and Jamie (P-007) is a novice who will abandon the tool if install fails silently or leaves them guessing whether it worked.
