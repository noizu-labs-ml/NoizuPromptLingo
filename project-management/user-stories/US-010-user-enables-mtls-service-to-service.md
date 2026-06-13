---
id: US-010
title: "User enables mTLS for service-to-service MCP calls"
slug: "user-enables-mtls-service-to-service"
personas: [P-002, P-003]
epic: "Auth & Onboarding"
priority: "should-have"
complexity: "L"
tags: [auth, mtls, service-mesh, security]
---

# US-010: User Enables mTLS for Service-to-Service MCP Calls

## User Story

**As a** Platform Engineer (P-002) or Security Engineer (P-003),
**I want to** enable mutual TLS (mTLS) for MCP calls between services within my cluster,
**So that** service-to-service communication is authenticated via certificates rather than shared tokens, reducing the attack surface from credential theft.

## Acceptance Criteria

- [ ] Given the organization security settings, when the user enables mTLS for a cluster, then the system generates a certificate authority (CA), issues client certificates for each registered MCP caller, and configures the Auth Gateway to require client certificate validation on the mTLS-enabled endpoints.
- [ ] Given mTLS is enabled, when an MCP caller presents a valid client certificate with a SAN matching a registered caller policy, then the Auth Gateway extracts the caller identity from the certificate SAN and proceeds with dual-principal resolution.
- [ ] Given mTLS is enabled, when an MCP caller presents an invalid, expired, or untrusted certificate, then the TLS handshake is terminated before reaching the Auth Gateway and no audit record is created.
- [ ] Given a service with both API key and mTLS authentication configured, when a request arrives with both a valid certificate and a valid API key, then the system uses the certificate-derived caller identity and logs both authentication methods in the audit record.
- [ ] Given the mTLS configuration page, when the user rotates certificates, then the system supports a grace period where both old and new certificates are accepted, and the user can monitor adoption before revoking the old certificate.

## Notes

mTLS is intended for service-to-service calls within a Kubernetes cluster or private network. Certificate SANs map to caller policies, replacing API keys for internal traffic. This is a Phase 1 feature. Certificate rotation must be graceful to avoid service disruption. Related to US-004 (API keys), US-006 (caller auth).
