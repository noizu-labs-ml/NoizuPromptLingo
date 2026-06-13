---
id: US-035
title: "Self-hosted Defender deployment"
slug: "self-hosted-defender-deployment"
personas: [P-002, P-005]
epic: "Defender — Scan Configuration"
priority: "won't-have-yet"
complexity: "XL"
tags: [defender, scan-config, self-hosted, enterprise, on-premise]
---

# US-035: Self-Hosted Defender Deployment

## User Story

**As a** CISO at a mid-market SaaS company (P-005),
**I want to** deploy the Defender scanning engine within my own infrastructure,
**So that** attack probes and model responses never leave my network perimeter, satisfying data residency requirements and allowing scanning of air-gapped or VPC-internal model endpoints.

## Acceptance Criteria

- [ ] Given I have an enterprise license, when I access the self-hosted deployment documentation, then I find a complete guide with Docker Compose and Kubernetes Helm chart options.
- [ ] Given I deploy the Defender engine container, when it starts, then it authenticates to the JailbreakingSite.com licensing API to validate my license key before accepting scan jobs.
- [ ] Given the self-hosted engine is running, when I configure a scan via the cloud UI, then I can select my registered self-hosted engine as the execution target instead of the cloud runner.
- [ ] Given a scan runs on my self-hosted engine, when results are generated, then raw prompt/response pairs remain on-premise and only metadata (technique IDs, severity, pass/fail) is transmitted to the cloud for reporting.
- [ ] Given my engine is offline or unreachable, when I attempt to launch a scan targeting it, then the UI shows engine connectivity status and blocks the scan with a clear error.

## Notes

This feature requires significant platform architecture work (engine/runner separation, licensing service, metadata-only result sync protocol) and is deferred until post-MVP. Anticipated for enterprise tier only. Licensing and air-gap deployment modes are separate sub-features.
