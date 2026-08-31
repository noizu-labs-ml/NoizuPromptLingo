---
id: US-056
title: "View Dataset Quality Breakdown"
slug: view-dataset-quality-breakdown
personas: [P-003]
epic: "Datasets"
priority: should-have
complexity: low
tags: [datasets, stats]
---

# US-056: View Dataset Quality Breakdown

## User Story

**As an** ML fine-tuning engineer
**I want** a dataset's page to show a stacked-bar (or equivalent) breakdown of gold/silver/bronze entry counts, updating live as entries are tagged
**So that** I can see at a glance whether the dataset has enough high-quality examples before exporting for training

## Acceptance Criteria

- **Given** a dataset with 10 gold, 5 silver, 3 bronze, and 2 unrated entries
  **When** I open the dataset page
  **Then** a stacked-bar visualization shows proportional segments for each quality tier plus unrated, with counts labeled

- **Given** I rate a previously-unrated entry as "bronze" while the dataset page is open
  **When** the rating is saved
  **Then** the breakdown updates to reflect the new count without a manual page refresh

- **Given** a dataset has zero entries
  **When** I view its page
  **Then** the breakdown shows an empty/zero state rather than a broken chart

## Notes

Elena checks this before deciding whether a dataset is ready to export or still needs more mining from the corpus.
