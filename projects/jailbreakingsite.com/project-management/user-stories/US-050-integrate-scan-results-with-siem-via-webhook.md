---
id: US-050
title: "Integrate scan results with SIEM via webhook"
slug: "integrate-scan-results-with-siem-via-webhook"
personas: [P-007, P-005]
epic: "Defender — Results & Reporting"
priority: "won't-have-yet"
complexity: "L"
tags: [defender, results, siem, webhook, integration, enterprise]
---

# US-050: Integrate Scan Results with SIEM via Webhook

## User Story

**As a** DevSecOps engineer in a regulated industry (P-007),
**I want to** configure a webhook that fires when a scan completes and delivers structured findings to my SIEM or security data platform,
**So that** LLM vulnerability data flows automatically into our centralized security event system alongside alerts from other scanners, without manual export steps.

## Acceptance Criteria

- [ ] Given I have an enterprise account, when I navigate to Integrations settings, then I can add one or more webhook endpoints with a URL, optional shared secret, and event trigger configuration.
- [ ] Given a scan completes, when the webhook is triggered, then a POST request is sent to the configured URL with a JSON payload containing the scan summary and all findings in the documented schema.
- [ ] Given I configure a shared secret, when the webhook fires, then the request includes an `X-JBS-Signature` HMAC-SHA256 header so the receiver can verify authenticity.
- [ ] Given the webhook target is unreachable, when the initial delivery fails, then the system retries with exponential backoff for up to 24 hours and logs delivery failures in the integration settings page.
- [ ] Given I want to test a webhook, when I click "Send Test Event", then a sample payload is dispatched immediately and the delivery result (HTTP status, response body) is shown in the UI.

## Notes

Webhook payload schema is an extension of the JSON export format from US-041. Common SIEM targets include Splunk HTTP Event Collector, Elastic Security, and Datadog Logs — documentation examples for each are part of this story's definition of done. Deferred until post-MVP due to support complexity and enterprise-tier audience size.
