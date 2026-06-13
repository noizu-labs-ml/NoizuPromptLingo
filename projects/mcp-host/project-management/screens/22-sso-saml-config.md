# SSO/SAML Configuration

| Field | Value |
|-------|-------|
| **ID** | `sso-saml-config` |
| **Type** | Settings |
| **Category** | Auth & Security |
| **User Stories** | US-011 |

## Description

Enterprise SSO setup: upload IdP metadata XML, configure SAML group-to-role mappings, enforce SSO for org domain.

## Key Components

- **MetadataUploader**
- **GroupRoleMappingTable**
- **SAMLConfigStatus**
- **EnforcementToggle**

## Interactions

- Upload IdP metadata
- Map SAML groups to roles
- Enforce SSO
- Test configuration

## Navigation

- Organization Management -> SSO Configuration
