---
id: US-070
title: "RFI Response Templates"
slug: "rfi-response-templates"
personas: [P-007]
epic: "RFI Dashboard"
priority: "should-have"
complexity: "S"
tags: [admin, rfi, templates, response, efficiency]
---

# US-070: RFI Response Templates

## User Story

**As a** site administrator,
**I want to** create and manage reusable response templates for common RFI scenarios,
**So that** I can respond to recurring inquiry types quickly without rewriting the same content from scratch.

## Acceptance Criteria

- [ ] Given I navigate to `/admin/rfi/templates`, when the page loads, then I see a list of existing templates with name, associated service type, and last modified date.
- [ ] Given I click "New Template", when I fill in a name, service type association, subject line, and body text (with variable placeholders like {{prospect_name}}, {{service_type}}), then the template is saved.
- [ ] Given I am responding to an RFI, when I click "Use Template", then a dropdown shows applicable templates filtered by the RFI's service type, and selecting one populates the response compose field.
- [ ] Given a template is applied, when the response is populated, then variable placeholders are replaced with the actual RFI values before display.
- [ ] Given I edit an existing template, when I save changes, then all future uses of the template use the updated content (existing sent responses are unaffected).
- [ ] Given I delete a template, when confirmed, then it is removed from the template list but any responses already sent that used it retain their content.

## Notes

Placeholders: {{prospect_name}}, {{company}}, {{service_type}}, {{budget_range}}, {{timeline}}, {{rfi_reference}}. Templates are admin-only; prospects never see the template structure. Related: US-068, US-069.
