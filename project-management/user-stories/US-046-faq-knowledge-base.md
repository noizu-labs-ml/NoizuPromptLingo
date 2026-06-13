---
id: US-046
title: "FAQ and Knowledge Base for Common Questions"
slug: "faq-knowledge-base"
personas: [P-007, P-001, P-003, P-002]
epic: "Support & Communication"
priority: "should-have"
complexity: "M"
tags: [support, faq, knowledge-base, self-service]
---

# US-046: FAQ and Knowledge Base for Common Questions

## User Story

**As a** client with a question about how engagements work (P-007, P-003),
**I want to** browse a knowledge base of frequently asked questions and common processes,
**So that** I can find answers to standard questions without creating a support ticket and waiting for a response.

## Acceptance Criteria

- [ ] Given I navigate to the Help section, when the page loads, then I see a searchable list of FAQ articles organized by category
- [ ] Given I type a search query, when I type at least 3 characters, then matching articles are displayed in real time
- [ ] Given I click on an article, when it opens, then I see the full answer with any relevant links, formatted with markdown
- [ ] Given an article does not answer my question, when I click "This didn't help", then I am offered a shortcut to create a support ticket (US-039) with the article context pre-filled
- [ ] Given Keith adds or updates an article in the admin, when I next visit the knowledge base, then the updated content is visible

## Notes

Categories: Engagement Process, Billing & Contracts, Technical Standards, Project Management, Communication & Expectations. Start with 10–20 hand-curated articles. Articles are admin-managed (Keith or designated admin). Consider surfacing relevant KB articles in the ticket creation form (US-039) to deflect tickets before submission. The knowledge base is accessible to both authenticated clients and unauthenticated visitors on the public site.
