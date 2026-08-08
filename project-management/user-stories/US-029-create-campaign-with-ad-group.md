---
id: US-029
title: "Create a Campaign with an Ad Group"
slug: "create-campaign-with-ad-group"
personas: [P-005]
epic: "Creative Assets & Campaigns"
priority: "must-have"
complexity: "S"
tags: [campaigns, ad-groups, creative]
---

# US-029: Create a Campaign with an Ad Group

## User Story

**As the** Growth Operator (P-005),
**I want to** create a new campaign and add at least one ad group to it,
**So that** I have a named container to organize ad copy generation, tracking, and reporting under.

## Acceptance Criteria

- [ ] Given I am viewing the Campaigns dashboard for my org, when I submit the "new campaign" form with a required name and objective, then a new campaign record is created and appears in my campaign list with status "draft".
- [ ] Given I have an existing campaign open, when I create a new ad group with a name and target-audience label, then the ad group is persisted and appears nested under that campaign in the detail view.
- [ ] Given a campaign currently has zero ad groups, when I attempt to navigate to ad-copy generation for that campaign, then the UI blocks the action and prompts me to create an ad group first.

## Notes

Ad groups are the unit ad copy generation attaches to — see US-030. A campaign can hold multiple ad groups, each generated and approved independently.
