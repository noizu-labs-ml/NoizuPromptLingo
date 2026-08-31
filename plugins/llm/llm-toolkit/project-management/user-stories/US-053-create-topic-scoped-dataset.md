---
id: US-053
title: "Create a Topic-Scoped Dataset"
slug: create-topic-scoped-dataset
personas: [P-003]
epic: "Datasets"
priority: must-have
complexity: low
tags: [datasets, curation]
---

# US-053: Create a Topic-Scoped Dataset

## User Story

**As an** ML fine-tuning engineer
**I want to** create a new named dataset (e.g. "error-handling-patterns")
**So that** I have a container to tag relevant message ranges into as I mine the corpus for training examples

## Acceptance Criteria

- **Given** I'm on the Datasets page
  **When** I click "New dataset" and enter a name like "error-handling-patterns"
  **Then** the dataset is created and appears in the dataset list with 0 entries

- **Given** a dataset named "error-handling-patterns" already exists
  **When** I try to create another dataset with the same name
  **Then** creation is blocked with a duplicate-name validation error

- **Given** a dataset has just been created
  **When** I open it
  **Then** it shows an empty entry list ready for tagging

## Notes

Elena typically creates one dataset per training-relevant topic before running semantic search across the corpus to find candidate examples for that topic.
