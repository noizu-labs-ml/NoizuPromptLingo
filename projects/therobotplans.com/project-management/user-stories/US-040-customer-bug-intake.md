---
id: US-040
title: "Customer bug intake via external form"
personas: [james-oduya]
domain: bugs
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **James Oduya (Agency Owner)**, I want to accept customer-reported bugs via an external intake form with automatic deduplication and routing so that clients have a professional way to report issues without needing access to our internal workspace.

## Acceptance Criteria

- [ ] A configurable, embeddable bug intake form can be generated per project or per client, branded with the client's logo and colors, accessible via a public URL without authentication
- [ ] Submitted reports run through the duplicate detection engine (US-037) before creating a new bug; if a likely duplicate is found, the submission is linked to the existing bug and the reporter is notified that a matching issue is already tracked
- [ ] Intake form submissions are auto-routed to the correct project based on the form's configuration and auto-triaged by the triage agent (US-034) with client SLA context applied
- [ ] The reporter receives an email confirmation with a tracking ID and can check status via a minimal public status page (no internal details exposed — just stage and estimated resolution)
- [ ] Internal team sees intake-sourced bugs tagged with "customer-reported" and the client identity, distinct from internally-discovered bugs

## Notes

Client-facing bug intake is an agency differentiator — it signals professionalism and reduces back-and-forth over email/Slack. The form must be dead simple (title, description, screenshot upload, optional severity) with no internal jargon. Rate limiting and spam prevention are necessary for a public form. The status page must be carefully scoped — clients should see progress without seeing internal discussions, assignees, or other client data. Consider Slack/email integration as alternative intake channels that funnel into the same pipeline.
