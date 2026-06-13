# Compliance Checklist

**System:** {System or project name}
**Target Framework(s):** {SOC2 Type II / ISO 27001 / NIST CSF / GDPR / HIPAA}
**Assessment Date:** {YYYY-MM-DD}
**Assessor:** {Name or team}
**Next Review:** {YYYY-MM-DD}

---

## Status Definitions

| Status | Meaning |
|--------|---------|
| Implemented | Control is fully in place with supporting evidence |
| Partial | Control exists but does not fully meet the requirement |
| Gap | Control is missing or insufficient; remediation required |
| N/A | Control is not applicable to this system (document justification) |

---

## Access Control

| Control ID | Control Description | Framework(s) | Status | Evidence | Notes |
|------------|-------------------|--------------|--------|----------|-------|
| AC-01 | Enforce unique user identification and authentication for all system access | SOC2 CC6.1, ISO A.9.2.1, NIST PR.AC-1 | Implemented | JWT auth required for all API endpoints; user table enforces unique email | |
| AC-02 | Implement role-based access control with least privilege | SOC2 CC6.3, ISO A.9.1.2, NIST PR.AC-4, GDPR Art.25 | Partial | RBAC defined for admin/user roles; tenant scoping incomplete on 2 endpoints | See T-001 in risk register |
| AC-03 | Enforce multi-factor authentication for privileged accounts | SOC2 CC6.1, ISO A.9.4.2, NIST PR.AC-7 | {Status} | {Evidence} | {Notes} |
| AC-04 | Implement session timeout and automatic logout | SOC2 CC6.1, ISO A.9.4.2, HIPAA 164.312(a)(2)(iii) | {Status} | {Evidence} | {Notes} |
| AC-05 | Restrict and monitor privileged access to infrastructure | SOC2 CC6.2, ISO A.9.2.3, NIST PR.AC-4 | {Status} | {Evidence} | {Notes} |
| AC-06 | Enforce password complexity and rotation policies | SOC2 CC6.1, ISO A.9.4.3, HIPAA 164.312(d) | {Status} | {Evidence} | {Notes} |

## Data Protection

| Control ID | Control Description | Framework(s) | Status | Evidence | Notes |
|------------|-------------------|--------------|--------|----------|-------|
| DP-01 | Encrypt data in transit using TLS 1.2 or higher | SOC2 CC6.7, ISO A.10.1.1, NIST PR.DS-2, GDPR Art.32 | Implemented | Cloudflare enforces TLS 1.3; internal cluster traffic unencrypted | Cluster-internal mTLS planned for Q3 |
| DP-02 | Encrypt sensitive data at rest | SOC2 CC6.1, ISO A.10.1.1, NIST PR.DS-1, GDPR Art.32, HIPAA 164.312(a)(2)(iv) | Gap | PostgreSQL PVs not encrypted; PII stored as plain text | Priority remediation — see T-010 |
| DP-03 | Classify data by sensitivity and apply handling procedures | SOC2 CC6.1, ISO A.8.2.1, GDPR Art.5(1)(c) | {Status} | {Evidence} | {Notes} |
| DP-04 | Implement data retention and deletion policies | SOC2 CC6.5, ISO A.8.3.2, GDPR Art.5(1)(e), HIPAA 164.530(j) | {Status} | {Evidence} | {Notes} |
| DP-05 | Maintain inventory of personal data processing activities | GDPR Art.30, ISO A.8.1.1 | {Status} | {Evidence} | {Notes} |
| DP-06 | Implement backup and recovery procedures for critical data | SOC2 A1.2, ISO A.12.3.1, NIST PR.IP-4 | {Status} | {Evidence} | {Notes} |

## Logging and Monitoring

| Control ID | Control Description | Framework(s) | Status | Evidence | Notes |
|------------|-------------------|--------------|--------|----------|-------|
| LM-01 | Log authentication events (success and failure) | SOC2 CC7.2, ISO A.12.4.1, NIST DE.AE-3, HIPAA 164.312(b) | Partial | Access logs capture HTTP requests; no structured auth event logging | See Finding 4 in security review |
| LM-02 | Log privileged operations and data access | SOC2 CC7.2, ISO A.12.4.3, NIST DE.AE-3 | Gap | No audit trail for data mutations or admin actions | Audit logging implementation planned |
| LM-03 | Centralize log aggregation with tamper protection | SOC2 CC7.2, ISO A.12.4.2, NIST PR.PT-1 | {Status} | {Evidence} | {Notes} |
| LM-04 | Implement alerting for security-relevant events | SOC2 CC7.3, ISO A.16.1.2, NIST DE.AE-5 | {Status} | {Evidence} | {Notes} |
| LM-05 | Retain logs for the required compliance period | SOC2 CC7.2, ISO A.12.4.1, HIPAA 164.312(b) | {Status} | {Evidence} | {Notes} |

## Incident Response

| Control ID | Control Description | Framework(s) | Status | Evidence | Notes |
|------------|-------------------|--------------|--------|----------|-------|
| IR-01 | Maintain a documented incident response plan | SOC2 CC7.4, ISO A.16.1.1, NIST RS.RP-1, HIPAA 164.308(a)(6) | {Status} | {Evidence} | {Notes} |
| IR-02 | Define roles and responsibilities for incident handling | SOC2 CC7.4, ISO A.16.1.1, NIST RS.CO-1 | {Status} | {Evidence} | {Notes} |
| IR-03 | Establish notification procedures for affected parties | SOC2 CC7.4, ISO A.16.1.2, GDPR Art.33-34, HIPAA 164.408 | {Status} | {Evidence} | {Notes} |
| IR-04 | Conduct periodic incident response testing | SOC2 CC7.4, ISO A.16.1.6, NIST RS.IM-2 | {Status} | {Evidence} | {Notes} |
| IR-05 | Document lessons learned and update procedures | SOC2 CC7.5, ISO A.16.1.6, NIST RS.IM-1 | {Status} | {Evidence} | {Notes} |

## Change Management

| Control ID | Control Description | Framework(s) | Status | Evidence | Notes |
|------------|-------------------|--------------|--------|----------|-------|
| CM-01 | Require documented change requests with approval workflow | SOC2 CC8.1, ISO A.12.1.2, NIST PR.IP-3 | Implemented | All changes require PR with code review approval; CI must pass | GitHub branch protection rules enforced |
| CM-02 | Separate development, staging, and production environments | SOC2 CC8.1, ISO A.12.1.4, NIST PR.IP-2 | Partial | Dev and prod exist; no dedicated staging environment | Staging namespace planned |
| CM-03 | Maintain an inventory of authorized software and dependencies | SOC2 CC6.8, ISO A.12.5.1, NIST ID.AM-2 | {Status} | {Evidence} | {Notes} |
| CM-04 | Scan dependencies for known vulnerabilities | SOC2 CC7.1, ISO A.12.6.1, NIST DE.CM-8 | {Status} | {Evidence} | {Notes} |
| CM-05 | Implement rollback procedures for failed deployments | SOC2 CC8.1, ISO A.12.1.2, NIST PR.IP-3 | {Status} | {Evidence} | {Notes} |

## Risk Management

| Control ID | Control Description | Framework(s) | Status | Evidence | Notes |
|------------|-------------------|--------------|--------|----------|-------|
| RM-01 | Maintain a risk register with periodic review | SOC2 CC3.2, ISO 6.1.2, NIST ID.RA-5 | Implemented | Risk register maintained in risk-register-template.md; quarterly review | Last review 2026-04-01 |
| RM-02 | Conduct periodic threat modeling for system changes | SOC2 CC3.2, ISO A.14.2.1, NIST ID.RA-1 | Partial | Initial threat model complete; no process for triggered re-assessment on architecture changes | Define trigger criteria |
| RM-03 | Define and document risk acceptance criteria and authority | SOC2 CC3.2, ISO 6.1.2, NIST ID.RM-1 | {Status} | {Evidence} | {Notes} |
| RM-04 | Perform vendor and third-party risk assessments | SOC2 CC9.2, ISO A.15.1.1, NIST ID.SC-1 | {Status} | {Evidence} | {Notes} |
| RM-05 | Conduct annual security awareness training | SOC2 CC1.4, ISO A.7.2.2, NIST PR.AT-1, HIPAA 164.308(a)(5) | {Status} | {Evidence} | {Notes} |

---

## Summary

| Section | Implemented | Partial | Gap | N/A | Total |
|---------|------------|---------|-----|-----|-------|
| Access Control | {n} | {n} | {n} | {n} | 6 |
| Data Protection | {n} | {n} | {n} | {n} | 6 |
| Logging and Monitoring | {n} | {n} | {n} | {n} | 5 |
| Incident Response | {n} | {n} | {n} | {n} | 5 |
| Change Management | {n} | {n} | {n} | {n} | 5 |
| Risk Management | {n} | {n} | {n} | {n} | 5 |
| **Total** | **{n}** | **{n}** | **{n}** | **{n}** | **32** |

---

## Usage Instructions

1. **Select applicable frameworks** and remove framework references that do not apply to your system.
2. **Assess each control** by reviewing current implementation against the control description.
3. **Set the status** using the definitions above. Be honest -- Partial is better than a false Implemented.
4. **Document evidence** with specific references: configuration files, policy documents, screenshots, tool output, or ticket numbers.
5. **Add notes** for context, especially for Partial and Gap statuses -- link to risk register entries or remediation tickets.
6. **Update the summary table** after completing the assessment to provide a quick overview of compliance posture.
7. **Review at the defined cadence** or when significant system changes occur.
8. **Add controls** as needed. This template covers common controls; your specific framework scope may require additional items.
