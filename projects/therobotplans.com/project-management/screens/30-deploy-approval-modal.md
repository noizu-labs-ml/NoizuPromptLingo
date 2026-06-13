# Deploy Approval Modal

| Field | Value |
|-------|-------|
| **ID** | `deploy-approval-modal` |
| **Type** | Modal |
| **Category** | CI/CD & Deployments |
| **User Stories** | US-047 |

## Description

Approval gate modal showing deploy summary, changelog preview, test results, and approve/reject actions. Maintains an audit trail of all approval decisions.

## Key Components

- **Deploy summary** — What's being deployed, to which environment
- **Changelog preview** — Condensed changelog of included changes
- **Test results** — CI test pass/fail summary
- **Approve/reject buttons** — Decision actions with required comment
- **Comment field** — Mandatory rationale for reject, optional for approve
- **Approval chain display** — Who needs to approve (multi-approver support)

## Interactions

- Review summary and changelog before decision
- Approve or reject with comment
- Multi-approver chains wait for all required approvals
- Audit trail records all decisions with timestamps
- Notification sent to deployer on approval/rejection

## Navigation

- Triggered from: Deploy action, Pipeline completion
- Links to: Deploy Changelog, Pipeline Status
