---
id: US-091
title: "Platform admin manages verified publisher applications"
slug: "admin-verified-publishers"
personas: [P-006, P-001]
epic: "Admin & Moderation"
priority: "should-have"
complexity: "M"
tags: [admin, verified-publisher, trust, applications, review]
---

# US-091: Platform Admin Manages Verified Publisher Applications

## User Story

**As an** Enterprise IT Admin (P-006),
**I want to** review and approve or reject verified publisher applications from MCP server publishers,
**So that** trusted publishers receive a verified badge in the registry, giving users confidence in the authenticity and quality of their tools.

## Acceptance Criteria

- [ ] Given a publisher submits a verified publisher application (organization name, website, domain ownership proof, code signing key), when the submission is received, then it appears in the admin "Publisher Applications" queue with the application details and verification status of each requirement
- [ ] Given a platform admin reviews a publisher application, when they verify the submitted evidence (domain DNS record matches, code signing key is valid, website references the MCP tools), then they can approve the application and the publisher's badge is activated in the registry within 5 minutes
- [ ] Given a platform admin rejects a publisher application, when the rejection is submitted, then the publisher receives a notification with the specific reason(s) for rejection and instructions for reapplying
- [ ] Given a verified publisher violates platform policies, when the platform admin revokes the verified status, then the badge is removed from all of that publisher's registry listings and an audit event is recorded

## Notes

Verified publisher status is a trust signal, not a security guarantee. The verification process should balance thoroughness (domain ownership, identity confirmation) with speed (target: 48-hour turnaround). Verified publishers get priority in registry search results and a faster moderation appeals process (US-088). Related to US-087 (flagging) and the Registry & Discovery component.
