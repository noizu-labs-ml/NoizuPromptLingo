---
id: US-099
title: "Virtualized rendering for long threads"
slug: virtualized-rendering-long-threads
personas: [P-002, P-005]
epic: "Performance & Scale"
priority: should-have
complexity: medium
tags: [performance, viewer, scale]
---

# US-099: Virtualized Rendering For Long Threads

## User Story

**As a** staff engineer curating team knowledge
**I want to** scroll through very long threads smoothly in the web thread viewer
**So that** merged incident docs with hundreds of messages don't become sluggish or unusable

## Acceptance Criteria

- **Given** Priya opens a merged incident thread with several hundred messages
  **When** she scrolls through the thread viewer
  **Then** only visible messages, plus a small buffer, are rendered to the DOM at a time

- **Given** Daniel opens a long thread while spot-checking for leaked secrets
  **When** he scrolls rapidly
  **Then** the UI remains smooth with no jank or frame drops, even with syntax-highlighted code and Mermaid blocks present

- **Given** a collapsed tool-call/tool-result block is expanded mid-thread
  **When** virtualization is active
  **Then** the expansion doesn't misalign scroll position or cause other messages to jump

## Notes
Priya's Merge feature (combining two engineers' threads into one incident doc) and Daniel's long-thread spot-checks are the two scenarios most likely to produce threads long enough to need this.
