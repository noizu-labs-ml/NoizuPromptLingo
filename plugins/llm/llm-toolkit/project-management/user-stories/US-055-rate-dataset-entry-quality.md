---
id: US-055
title: "Rate Dataset Entry Quality"
slug: rate-dataset-entry-quality
personas: [P-003]
epic: "Datasets"
priority: must-have
complexity: low
tags: [datasets, quality]
---

# US-055: Rate Dataset Entry Quality

## User Story

**As an** ML fine-tuning engineer
**I want** each dataset entry to be labeled gold, silver, or bronze quality, editable at any time from the entry list
**So that** I can triage examples by training value without removing lower-quality ones from the dataset

## Acceptance Criteria

- **Given** a dataset entry with no quality label
  **When** I open the entry list
  **Then** each entry shows a quality selector (gold/silver/bronze) defaulting to unrated

- **Given** I select "gold" for an entry
  **When** the change is made
  **Then** it's saved immediately and reflected in the entry list without a page reload

- **Given** an entry is already rated "silver"
  **When** I change its rating to "gold"
  **Then** the update overwrites the prior rating and no duplicate ratings are retained

## Notes

Elena re-triages ratings iteratively as her sense of what counts as a strong training example evolves over the course of curating a dataset.
