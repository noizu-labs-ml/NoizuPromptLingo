---
id: US-079
title: "System injects secrets at runtime via sealed secrets"
slug: "sealed-secret-injection"
personas: [P-003, P-001]
epic: "Sandbox & Execution"
priority: "must-have"
complexity: "L"
tags: [secrets, runtime-injection, security, credentials, sealed-secrets]
---

# US-079: System Injects Secrets at Runtime via Sealed Secrets

## User Story

**As a** Security Engineer (P-003),
**I want to** ensure downstream service credentials are injected into tool sandboxes at runtime and never baked into container images or stored in plaintext configuration,
**So that** secret material has a minimal blast radius and cannot be extracted from image layers, build logs, or static configuration files.

## Acceptance Criteria

- [ ] Given a tool requires downstream service credentials (e.g., API key, OAuth token), when the MCP server admin configures the tool, then secrets are stored in the platform's sealed secret store (encrypted at rest) and are never written to the tool's image, source code, or manifest YAML
- [ ] Given a tool invocation is dispatched and the tool's manifest declares required secrets, when the sandbox is provisioned, then the sealed secrets are decrypted and injected as environment variables or mounted files available only within that sandbox instance
- [ ] Given a tool invocation completes, when the sandbox is torn down, then all injected secret material is purged from memory and the ephemeral filesystem
- [ ] Given an audit log entry is written for a secret injection event, when the entry is reviewed, then the log records which secret was accessed and by which invocation but does not include the secret value itself

## Notes

This follows the pattern of Kubernetes SealedSecrets or external secret injection (e.g., Infisical, Vault agent). The platform should support multiple secret backends for self-hosted deployments. Related to US-078 (filesystem isolation ensures injected secrets are ephemeral) and the dual-principal auth model for scoping which credentials a caller can access.
