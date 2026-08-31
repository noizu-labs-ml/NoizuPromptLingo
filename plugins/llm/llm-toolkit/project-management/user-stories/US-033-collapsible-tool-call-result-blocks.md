---
id: US-033
title: "Collapsible tool-call/result blocks"
slug: collapsible-tool-call-result-blocks
personas: [P-001, P-002]
epic: "Thread Viewer"
priority: must-have
complexity: medium
tags: [viewer, tool-calls]
---

# US-033: Collapsible Tool-Call/Result Blocks

## User Story

**As a** solo power-user developer
**I want to** have tool-use and tool-result blocks default to collapsed with a one-line summary, expandable on click
**So that** I can scan a long debugging thread's flow without scrolling through pages of raw tool output for every Bash/Read call

## Acceptance Criteria

- **Given** a thread message contains a tool-call and its corresponding tool-result
  **When** the thread viewer renders the message
  **Then** both blocks default to collapsed, each showing a one-line summary (e.g. tool name + truncated key argument, or result size/status)

- **Given** a collapsed tool-call block
  **When** I click it
  **Then** it expands in place to show full call arguments and result content, and can be re-collapsed by clicking again

- **Given** a thread contains many consecutive tool-call/result pairs (e.g. a long agentic loop)
  **When** the thread renders
  **Then** all of them collapse by default so the overall page height stays scannable, with an option to expand all at once

- **Given** Priya is scanning a debugging session to identify which tool calls to preserve when converting to a runbook
  **When** she scans collapsed one-line summaries
  **Then** she can identify the relevant tool calls without expanding each one first

## Notes
Core to keeping long agentic threads readable at all — without this, threads with many tool calls (a common pattern in this product's own conversation history) become unusably long walls of JSON/output. Must-have alongside US-029/US-030 as a Thread Viewer foundation.
