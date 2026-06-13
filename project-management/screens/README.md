# Screen Inventory

## Summary

| Metric | Count |
|--------|-------|
| **Total Screens** | 38 |
| **Categories** | 12 |

## Type Legend

| Type | Description |
|------|-------------|
| **Primary** | Full-page views in main navigation |
| **Dashboard** | Aggregation/metrics views with charts and cards |
| **Settings** | Configuration panels |
| **Modal** | Overlays/dialogs triggered from other screens |
| **Storyboard** | Multi-step flows/wizards |

## Screens by Category

### Auth & Onboarding

| # | Screen | Type | User Stories |
|---|--------|------|-------------|
| 01 | [Sign Up](01-sign-up.md) | Primary | US-001 |
| 02 | [Login](02-login.md) | Primary | US-002 |
| 03 | [Onboarding Wizard](03-onboarding-wizard.md) | Storyboard | US-003, US-012 |

### Core

| # | Screen | Type | User Stories |
|---|--------|------|-------------|
| 04 | [Main Dashboard](04-dashboard.md) | Dashboard | US-012, US-029, US-094, US-096, US-097 |

### Auth & Security

| # | Screen | Type | User Stories |
|---|--------|------|-------------|
| 05 | [API Key Management](05-api-key-management.md) | Primary | US-004, US-006, US-063 |
| 06 | [Connected Services](06-connected-services.md) | Settings | US-005, US-084 |
| 22 | [SSO/SAML Configuration](22-sso-saml-config.md) | Settings | US-011 |
| 23 | [mTLS Configuration](23-mtls-config.md) | Settings | US-010 |

### SafeMCP / Policy

| # | Screen | Type | User Stories |
|---|--------|------|-------------|
| 07 | [Policy Editor](07-policy-editor.md) | Primary | US-008, US-009, US-013, US-014, US-015, US-016, US-017, US-018, US-019, US-030, US-066, US-085 |
| 08 | [Policy Simulation](08-policy-simulation.md) | Primary | US-020, US-080 |
| 28 | [Policy Template Library](28-policy-template-library.md) | Settings | US-085 |
| 32 | [Confirmation Gate Prompt](32-confirmation-gate-prompt.md) | Modal | US-015 |

### SafeMCP / Audit

| # | Screen | Type | User Stories |
|---|--------|------|-------------|
| 09 | [Audit Log Explorer](09-audit-log-explorer.md) | Primary | US-007, US-019, US-021, US-022, US-023, US-024, US-025 |
| 10 | [Anomaly Alerts](10-anomaly-alerts.md) | Primary | US-025 |
| 37 | [Audit Export Dialog](37-audit-export-modal.md) | Modal | US-023 |

### JustMCP Deployment

| # | Screen | Type | User Stories |
|---|--------|------|-------------|
| 11 | [JustMCP Deploy Wizard](11-justmcp-deploy-wizard.md) | Storyboard | US-026, US-027, US-028, US-030, US-037, US-095 |
| 12 | [Server Detail](12-server-detail.md) | Primary | US-029, US-031, US-032, US-033, US-034, US-035, US-036, US-038, US-060, US-076, US-077, US-078, US-079, US-081, US-093 |
| 33 | [Delete Deployment Confirmation](33-delete-deployment-modal.md) | Modal | US-035 |
| 34 | [Rollback Confirmation](34-rollback-confirmation-modal.md) | Modal | US-034 |
| 38 | [Security Scan Report](38-security-scan-report.md) | Modal | US-037 |

### MCP Jumpstart

| # | Screen | Type | User Stories |
|---|--------|------|-------------|
| 13 | [MCP Jumpstart Generator](13-mcp-jumpstart-generator.md) | Storyboard | US-039, US-040, US-041, US-042, US-043, US-044, US-045, US-046, US-047, US-048, US-049, US-050 |

### Registry & Discovery

| # | Screen | Type | User Stories |
|---|--------|------|-------------|
| 14 | [Registry Search & Browse](14-registry.md) | Primary | US-051, US-052, US-053, US-099 |
| 15 | [Registry Server Detail Page](15-registry-server-detail.md) | Primary | US-054, US-055, US-056, US-057, US-058, US-069, US-070, US-071, US-073, US-075 |
| 16 | [Category Notifications](16-category-notifications.md) | Settings | US-059 |

### Organization Management

| # | Screen | Type | User Stories |
|---|--------|------|-------------|
| 17 | [Organization Setup & Management](17-organization-management.md) | Primary | US-061, US-062, US-065, US-067 |
| 18 | [Organization Usage Dashboard](18-org-usage-dashboard.md) | Dashboard | US-064 |
| 19 | [Billing & Subscription](19-billing.md) | Settings | US-068 |

### Social & Publishing

| # | Screen | Type | User Stories |
|---|--------|------|-------------|
| 20 | [Publisher Dashboard](20-publisher-dashboard.md) | Dashboard | US-057, US-072, US-074 |
| 21 | [My Favorites](21-favorites.md) | Primary | US-069 |
| 35 | [Access Request Flow](35-access-request.md) | Modal | US-073 |
| 36 | [Report Server](36-report-server-modal.md) | Modal | US-075 |

### Settings & Preferences

| # | Screen | Type | User Stories |
|---|--------|------|-------------|
| 24 | [Notification Preferences](24-notification-preferences.md) | Settings | US-082 |
| 25 | [Webhook Configuration](25-webhook-config.md) | Settings | US-100 |
| 26 | [Appearance Settings](26-appearance-settings.md) | Settings | US-083 |
| 27 | [Regional Settings](27-regional-settings.md) | Settings | US-086, US-098 |

### Admin & Moderation

| # | Screen | Type | User Stories |
|---|--------|------|-------------|
| 29 | [Admin Moderation Queue](29-admin-moderation-queue.md) | Primary | US-087, US-088, US-091 |
| 30 | [Admin Analytics Dashboard](30-admin-analytics.md) | Dashboard | US-089 |
| 31 | [Admin Rate Limits & Abuse Prevention](31-admin-rate-limits.md) | Settings | US-090, US-092 |

## Coverage

All 100 user stories are mapped to at least one screen.
