---
id: US-064
title: "Follow a Collection for Updates"
slug: "follow-collection-for-updates"
personas: [P-001, P-003, P-004]
epic: "Collections & Lists"
priority: "should-have"
complexity: "S"
tags: [collections, follow, notifications, subscriptions, updates]
---

# US-064: Follow a Collection for Updates

## User Story

**As a** web nostalgia explorer (P-001),
**I want to** follow a curated collection to get notified when new sites are added,
**So that** I can track curators I trust without having to manually revisit their lists.

## Acceptance Criteria

- [ ] Given I am logged in and viewing a public collection or editorial list, when I click "Follow", then I am subscribed to updates for that collection
- [ ] Given I follow a collection, when new sites are added to it, then I receive an in-app notification and (optionally) an email digest
- [ ] Given I follow multiple collections, when I visit my dashboard or feed, then a recent activity section shows new additions across all followed collections
- [ ] Given I am following a collection, when I click "Unfollow", then I no longer receive notifications for it
- [ ] Given I view a collection I follow, when the page loads, then a "Following" indicator is shown and the follow count for the collection is visible

## Notes

Follow counts on public collections serve as social proof — they signal which curators are trusted by the community. Email notification preference for follows should respect the account-level notification settings (see US-071 profile setup). Related: US-059 (editorial lists), US-062 (share collection), US-056 (saved searches).
