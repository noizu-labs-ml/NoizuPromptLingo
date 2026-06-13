# mTLS Configuration

| Field | Value |
|-------|-------|
| **ID** | `mtls-config` |
| **Type** | Settings |
| **Category** | Auth & Security |
| **User Stories** | US-010 |

## Description

Configure mutual TLS for service-to-service MCP calls. Generate CA, issue client certificates, manage rotation.

## Key Components

- **CertificateAuthorityPanel**
- **ClientCertList**
- **CertRotationControls**
- **AdoptionMonitor**

## Interactions

- Enable mTLS
- Generate CA
- Issue client certificates
- Rotate certificates with grace period
- Monitor adoption

## Navigation

- Organization Management -> Security -> mTLS
