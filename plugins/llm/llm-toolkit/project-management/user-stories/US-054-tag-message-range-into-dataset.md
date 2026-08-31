---
id: US-054
title: "Tag Message Range into Dataset"
slug: tag-message-range-into-dataset
personas: [P-003]
epic: "Datasets"
priority: must-have
complexity: medium
tags: [datasets, curation]
---

# US-054: Tag Message Range into Dataset

## User Story

**As an** ML fine-tuning engineer
**I want to** select a message range from the thread viewer and tag it directly into an existing dataset as a new entry
**So that** I can build up training examples without leaving the thread I'm reviewing

## Acceptance Criteria

- **Given** a thread open in the viewer and an existing dataset "error-handling-patterns"
  **When** I select a contiguous message range and choose "Tag into dataset" → select the dataset
  **Then** a new entry referencing that thread and range is added to the dataset

- **Given** I tag the exact same message range into the same dataset a second time
  **When** the second tag attempt happens
  **Then** the system warns of the duplicate rather than silently creating a second identical entry

- **Given** I tag a range into a dataset
  **When** I open the dataset's entry list
  **Then** the new entry shows the source thread, project, and message range, with a link back to view it in context

## Notes

Elena does this while semantically searching the whole corpus for training examples, moving quickly across many threads and datasets in a single session.
