---
id: US-095
title: "Third-Party Alert Integrations"
slug: "third-party-alert-integrations"
personas: [P-004, P-001]
epic: "Integration & API"
priority: "should-have"
complexity: "M"
tags: [pagerduty, slack, opsgenie, alerts, integration]
---

# US-095: Third-Party Alert Integrations

## User Story

**As a** DevOps / SRE Lead (P-004),
**I want to** route IoTGo escalations and critical alerts to PagerDuty, Slack, and OpsGenie,
**So that** on-call engineers are notified through the tools they already monitor rather than requiring them to check a separate dashboard.

## Acceptance Criteria

- [ ] Given I navigate to Integrations > Alerts, when I click Add Integration, then I can choose from PagerDuty, Slack, and OpsGenie, and follow a guided setup flow for each
- [ ] Given PagerDuty is configured, when an agent escalates a critical incident, then an alert is triggered in PagerDuty with the incident title, fleet group, severity, and a deep link back to the IoTGo incident detail page
- [ ] Given Slack is configured with a channel and webhook, when an agent completes a playbook execution, then a Slack message is posted with action summary, outcome status, and device count affected
- [ ] Given OpsGenie is configured, when I test the integration, then a test alert appears in OpsGenie within 10 seconds and I can confirm receipt from the IoTGo UI
- [ ] Given an integration is active, when I want to limit noise, then I can set a minimum severity threshold (info/warning/critical) below which alerts are suppressed for that integration

## Notes

Alert routing rules (e.g., send only Fleet B escalations to PagerDuty team X) are a follow-on enhancement. Relates to US-092 (webhooks) and US-091 (REST API). Slack integration uses incoming webhooks, not bot tokens, for simpler setup.
