---
id: US-018
title: "Save a Prompt as Draft"
slug: "save-as-draft"
personas: [P-001, P-003, P-006]
epic: "Prompt Submission"
priority: "should-have"
complexity: "S"
tags: [prompt, draft, save, workflow]
---

# US-018: Save a Prompt as Draft

## User Story

**As a** Content Creator (P-006),
**I want to** save my prompt as a draft before publishing,
**So that** I can work on it across multiple sessions and only share it when it is ready.

## Acceptance Criteria

- [ ] Given I am on the prompt submission form with content entered, when I click "Save as draft", then the prompt is saved with a "draft" status, I am redirected to my drafts page, and a success notification confirms the save.
- [ ] Given I am working on the submission form, when I navigate away without saving (or the browser is closed unexpectedly), then an autosave fires every 60 seconds and a browser beforeunload warning prompts me to confirm leaving with unsaved changes.
- [ ] Given I have saved drafts, when I navigate to My Profile > Drafts, then I see all my drafts listed with titles, last modified timestamps, and a "Continue editing" link for each.
- [ ] Given I am viewing my drafts, when I click "Publish" on a draft, then the draft is validated and published exactly as if I had submitted the form fresh — the status changes to "published" and it appears in the feed.
- [ ] Given a draft has not been modified in 90 days, when the cleanup job runs, then the draft is auto-deleted and I receive an email notification 7 days before deletion warning me to publish or update it.

## Notes

The autosave behavior in AC-2 is particularly important for P-003 who may write extensive documentation alongside prompts. Drafts are private — not visible to other users or search engines. The 90-day cleanup prevents draft accumulation while giving ample time for intermittent contributors.
