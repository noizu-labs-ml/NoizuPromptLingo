---
id: US-002
title: "First-run indexing wizard"
slug: first-run-indexing-wizard
personas: [P-001, P-007]
epic: "Onboarding & Install"
priority: must-have
complexity: medium
tags: [onboarding, indexing]
---

# US-002: First-Run Indexing Wizard

## User Story

**As a** first-time user (whether power-user or novice)
**I want to** be guided through detecting my `~/.claude/projects` history and starting the initial index with visible progress
**So that** I understand what the tool is about to do and can trust it before it touches my conversation history

## Acceptance Criteria

- **Given** `llm-toolkit` is launched for the first time
  **When** the wizard starts
  **Then** it auto-detects `~/.claude/projects` and displays the number of project directories and JSONL files found before indexing begins

- **Given** the wizard has detected the history location
  **When** it presents the confirmation screen
  **Then** it explains in plain language what will be indexed (FTS5 keyword index + MiniLM semantic embeddings, stored locally) and requires an explicit "Start indexing" confirmation from the user

- **Given** the user confirms and indexing starts
  **When** indexing is in progress
  **Then** a visible progress indicator shows files/messages processed so far and an estimated remaining count, updating at least every few seconds

- **Given** `~/.claude/projects` cannot be found at the default location
  **When** the wizard runs
  **Then** it prompts the user to manually specify the path instead of failing silently or hanging

## Notes
For Jamie (P-007), this is the moment they decide whether to trust the tool — jargon-free explanations matter more than for Marcus (P-001), who mainly wants indexing to start fast and get out of his way.
