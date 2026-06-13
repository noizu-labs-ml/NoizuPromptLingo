---
id: US-052
title: "Client Account Management"
slug: "client-account-management"
personas: [P-007]
epic: "Admin Dashboard"
priority: "must-have"
complexity: "L"
tags: [admin, clients, account, create, deactivate]
---

# US-052: Client Account Management

## User Story

**As a** site administrator,
**I want to** create, edit, and deactivate client accounts with associated metadata (company, contact, engagement type),
**So that** I can maintain an accurate client roster and control dashboard access for each engagement.

## Acceptance Criteria

- [ ] Given I am on the admin client list, when I click "New Client", then a form appears with fields: name, company, email, phone, engagement type, start date, and notes.
- [ ] Given I submit a valid new client form, when the record saves, then the client appears in the list and an invitation email is dispatched to the client's address.
- [ ] Given I am viewing an existing client record, when I edit and save changes, then the updated data is reflected immediately and an audit log entry is created.
- [ ] Given I click "Deactivate" on a client, when I confirm the prompt, then the client's dashboard access is revoked, their status becomes "Inactive", and no data is deleted.
- [ ] Given a deactivated client, when I click "Reactivate", then their access is restored and status returns to "Active".
- [ ] Given the client list, when I search by name or company, then results filter in real time.

## Notes

Deactivation must be non-destructive — all project history, deliverables, and messages are retained. Engagement types: Fractional CTO, Principal Engineer, QC, Code Audit, Service Readiness, Development, Technical PM, IoT & Embedded. Related: US-051, US-053.
