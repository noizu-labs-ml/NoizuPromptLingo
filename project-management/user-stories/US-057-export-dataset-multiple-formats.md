---
id: US-057
title: "Export Dataset in Multiple Formats"
slug: export-dataset-multiple-formats
personas: [P-003]
epic: "Datasets"
priority: must-have
complexity: medium
tags: [datasets, export]
---

# US-057: Export Dataset in Multiple Formats

## User Story

**As an** ML fine-tuning engineer
**I want to** export a dataset as OpenAI chat-format JSONL, Anthropic-format JSONL, or raw JSONL via a format selector
**So that** I can feed it directly into my training pipeline without a separate conversion step

## Acceptance Criteria

- **Given** a dataset with tagged entries
  **When** I choose "Export" and select "OpenAI chat format"
  **Then** a JSONL file is produced where each line matches the OpenAI chat-completion message-array schema for that entry's message range

- **Given** the same dataset
  **When** I select "Anthropic format" instead
  **Then** the export produces JSONL matching Anthropic's message schema (roles, content blocks) rather than OpenAI's

- **Given** the same dataset
  **When** I select "raw JSONL"
  **Then** the output is the original unmodified JSONL records for the tagged ranges, with no schema transformation applied

- **Given** the export is also available via API
  **When** I call the export route directly (e.g. `GET /api/datasets/:id/export?format=openai`)
  **Then** it returns the same file content as the UI-triggered download

## Notes

Elena consumes both the UI download and the API route depending on whether she's exporting manually or scripting a pipeline pull as part of her training workflow.
