---
id: US-090
title: "Fleet Data Encryption at Rest"
slug: "fleet-data-encryption-at-rest"
personas: [P-005]
epic: "Security & Compliance"
priority: "could-have"
complexity: "L"
tags: [encryption, security, compliance, data-protection]
---

# US-090: Fleet Data Encryption at Rest

## User Story

**As an** IT Security Director (P-005),
**I want to** verify that all fleet telemetry and configuration data is encrypted at rest and optionally supply my own encryption key (BYOK),
**So that** I can satisfy enterprise data security policies and retain control over data decryptability.

## Acceptance Criteria

- [ ] Given the platform is deployed, when I view Security Settings, then I see a data encryption status section confirming encryption algorithm (AES-256) and key management provider (default: platform-managed)
- [ ] Given I want to use BYOK, when I enable the Customer Managed Keys option, then I can provide an AWS KMS, Azure Key Vault, or GCP Cloud KMS key ARN/URL and the platform re-encrypts existing data under my key
- [ ] Given BYOK is active, when my key is rotated in the KMS, then IoTGo detects the rotation via the KMS API and re-wraps data keys automatically without service interruption
- [ ] Given my key is disabled or revoked, when IoTGo attempts to decrypt data, then all queries requiring decryption fail gracefully and an alert is raised to org admins within 5 minutes

## Notes

BYOK is an enterprise-tier feature. Relates to US-086 (fleet isolation) and US-089 (compliance reports). Key rotation and re-encryption are background jobs that must not degrade platform performance.
