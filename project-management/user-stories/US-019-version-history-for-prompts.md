---
id: US-019
title: "Version History for Prompts"
slug: "version-history-for-prompts"
personas: [P-001, P-003]
epic: "Prompt Submission"
priority: "could-have"
complexity: "L"
tags: [prompt, versioning, history, diff, audit]
---

# US-019: Version History for Prompts

## User Story

**As a** ML Researcher (P-003),
**I want to** view the version history of a prompt and compare revisions,
**So that** I can understand how a prompt has evolved and reference earlier versions that may have worked better for specific models.

## Acceptance Criteria

- [ ] Given a prompt has been edited at least once, when I view the prompt detail page, then an "Edit history (N revisions)" link is visible below the prompt metadata.
- [ ] Given I click "Edit history", when the history panel opens, then I see a chronological list of revisions showing version number, editor (author or moderator), timestamp, and a brief change summary.
- [ ] Given I click on a specific revision, when the revision view loads, then I see the full prompt body and metadata as it existed at that point in time, with a clear "Archived version" banner.
- [ ] Given I am viewing the history panel, when I click "Compare revisions" and select two versions, then a side-by-side diff view highlights added text in green and removed text in red at the line level.
- [ ] Given I am the author and I am viewing a past revision, when I click "Restore this version", then a confirmation prompt appears and on confirm, a new snapshot of the current version is created before the restore is applied.

## Notes

Version snapshots are created automatically on each edit (triggered by US-016). Only the prompt body, title, description, tags, and model fields are versioned — vote counts and comments are not. The diff view (AC-4) is the highest-value feature here for P-001 and P-003 but also the most complex to implement.
