---
id: P-006
name: "David Tanaka"
slug: "enterprise-it-administrator"
archetype: "The Gatekeeper"
segment: "secondary"
tags: [enterprise, it-admin, sso, saml, compliance, vendor-risk, self-hosted, org-management]
---

# David Tanaka — The Gatekeeper

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 40-49 |
| **Role** | Director of IT / Enterprise Architect |
| **Technical Level** | Advanced |
| **Industry** | Healthcare Technology |
| **Location** | Chicago, Illinois |

## Bio

David oversees IT infrastructure and compliance for a 2,000-person healthcare technology company. His mandate: enable innovation (including AI tooling) while maintaining HIPAA compliance, passing SOC2 audits, and keeping the CISO happy. Every new tool his teams want to adopt goes through a vendor risk assessment. David wants MCP Host to either pass that assessment or be available as a self-hosted deployment that lives entirely within his VPC.

## Goals

1. Deploy or adopt MCP infrastructure that meets enterprise compliance requirements (HIPAA, SOC2, GDPR) without exceptions or carve-outs
2. Enforce organization-wide policies — SSO/SAML authentication, mandatory audit logging, data residency restrictions — across all MCP usage
3. Complete vendor risk assessments for MCP Host with minimal back-and-forth by having security documentation, certifications, and deployment architecture available upfront

## Frustrations

1. AI teams adopt tools and services that have not been through IT review, creating shadow IT with unclear data handling and access controls
2. SaaS vendors claim "enterprise-ready" but cannot provide SOC2 reports, data processing agreements, or self-hosted deployment options
3. Compliance reporting for AI tool usage is non-existent — auditors ask "who accessed what patient data through which AI tool" and there is no structured answer

## Behaviors

- Manages identity through Okta with SAML/OIDC SSO enforced for all engineering tools
- Conducts quarterly vendor risk reviews with a standardized questionnaire covering data handling, encryption, access controls, and incident response
- Prefers self-hosted deployments for tools that process sensitive data, deployed within a private VPC with no egress to external services
- Reviews architecture diagrams and data flow maps before approving any new system

## Job to Be Done

> "When an engineering team requests MCP tooling for their AI workflows, I want to approve it knowing that it integrates with our SSO, enforces our data residency and audit policies, and can be deployed within our VPC if required, so I can say yes to innovation without compromising our compliance posture."

## Relationship to Product

David evaluates MCP Host through the lens of procurement and compliance, not developer experience. He needs SSO/SAML integration, role-based org management, a self-hosted deployment option, and security documentation (SOC2 report, penetration test results, data processing agreement). SafeMCP is the product surface that matters most — audit logs, policy enforcement, and data residency controls. He would approve MCP Host if it checks the compliance boxes and has a credible self-hosted path. He would block it if any data traverses external servers without encryption guarantees or if the vendor cannot produce a SOC2 report.

## Scenarios

1. **SSO Integration and Onboarding** — David configures MCP Host to use the company's Okta SAML integration. All existing engineering team members are automatically provisioned into MCP Host with their Okta group memberships mapped to org roles.
2. **Vendor Risk Assessment** — David downloads the MCP Host security whitepaper, SOC2 Type II report, and architecture diagram from the vendor portal, completes the internal risk questionnaire, and approves the tool for a 90-day pilot.
3. **Self-Hosted Compliance Deployment** — David's team deploys MCP Host within their VPC using the self-hosted Helm chart, configures it to use the internal PostgreSQL cluster and internal identity provider, and verifies that no tool invocation data leaves the private network.
