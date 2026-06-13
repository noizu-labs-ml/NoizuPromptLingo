# Review Gate

| Field | Value |
|-------|-------|
| **ID** | `review-gate` |
| **Type** | Primary |
| **Category** | Publish Phase |
| **User Stories** | INK-061, INK-062, INK-063, INK-064 |

## Description

Pre-deployment quality gate combining automated code review, test coverage, and security scan results. Deploy button remains disabled until critical issues are resolved (or explicitly overridden with documented risk acceptance).

## Key Components

- **Code Review Summary** — Issues grouped by severity (critical/warning/info) with file+line links (INK-061)
- **Test Coverage Report** — Overall score + per-module breakdown with visual coverage map (INK-062)
- **Security Scan Results** — CVE findings, hardcoded secrets, OWASP flags with remediation suggestions (INK-063)
- **Deploy Gate Indicator** — Blocked/Ready status with "Accepted Risk" override requiring reason (INK-064)
- **Override Audit Log** — Timestamped record of risk acceptances (INK-064)

## Interactions

- "Re-run" triggers fresh analysis
- File+line links jump to code location
- Critical issues must be resolved or explicitly overridden
- Override requires reason textarea → logs to audit trail
- When all criticals resolved: Deploy button unlocks
- PDF/Markdown export of coverage report

## Navigation

- Accessible from: Agent Development completion, Dashboard "Continue" on Publish phase
- Links to: Deploy screen (when gate passes)
