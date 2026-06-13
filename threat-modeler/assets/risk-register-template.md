# Risk Register

**System:** {System or project name}
**Owner:** {Risk register owner — typically security lead or engineering manager}
**Created:** {YYYY-MM-DD}
**Last Reviewed:** {YYYY-MM-DD}
**Review Cadence:** {Monthly / Quarterly / On change}

---

## Scoring Reference

### Likelihood

| Score | Label | Description |
|-------|-------|-------------|
| 1 | Rare | Requires nation-state capability or extraordinary circumstances |
| 2 | Unlikely | Requires significant expertise and motivation |
| 3 | Possible | Within capability of skilled attacker with moderate motivation |
| 4 | Likely | Common attack pattern, known tooling exists |
| 5 | Almost Certain | Trivially exploitable, actively targeted in the wild |

### Impact

| Score | Label | Description |
|-------|-------|-------------|
| 1 | Negligible | No data loss, no service disruption, no compliance impact |
| 2 | Minor | Limited data exposure, brief disruption, minor compliance note |
| 3 | Moderate | Significant data exposure, extended disruption, compliance finding |
| 4 | Major | Large-scale data breach, prolonged outage, regulatory notification required |
| 5 | Critical | Existential threat -- complete compromise, massive breach, legal liability |

### Risk Rating

Risk Score = Likelihood x Impact. Rating thresholds:

| Score Range | Rating | Response Expectation |
|-------------|--------|---------------------|
| 15-25 | Critical | Address immediately; escalate to leadership |
| 8-14 | High | Address within 30 days |
| 4-7 | Medium | Address within 90 days |
| 1-3 | Low | Address in next planning cycle or accept |

### Status Values

| Status | Meaning |
|--------|---------|
| Open | Identified, not yet addressed |
| Mitigating | Remediation in progress |
| Accepted | Risk acknowledged and accepted by owner with documented justification |
| Closed | Remediation complete and verified |

---

## Register

| ID | Threat | Category | L | I | Score | Rating | Status | Owner | Remediation | Target Date | Notes |
|----|--------|----------|---|---|-------|--------|--------|-------|-------------|-------------|-------|
| T-001 | Unauthenticated access to admin endpoints | EoP | 4 | 5 | 20 | Critical | Open | API Team | Add authentication middleware to admin route scope | 2026-05-19 | Discovered during architecture review |
| T-002 | SQL injection via search parameter | Tampering | 2 | 5 | 10 | High | Mitigating | API Team | Migrate raw query to parameterized Ecto query | 2026-05-26 | PR #142 in review |
| T-003 | Verbose error messages in production | Info Disc | 4 | 2 | 8 | High | Closed | API Team | Custom error handler deployed | 2026-04-15 | Verified in production 2026-04-16 |

---

## Change Log

| Date | ID(s) | Change | By |
|------|-------|--------|----|
| {YYYY-MM-DD} | {T-XXX} | {What changed -- e.g., Status changed from Open to Mitigating} | {Name} |
| {YYYY-MM-DD} | {T-XXX} | {Change description} | {Name} |

---

## Usage Instructions

1. **Add new threats** by appending rows to the Register table. Assign a sequential ID (T-001, T-002, etc.).
2. **Score each threat** using the Likelihood and Impact scales above. Calculate Score as L x I and assign a Rating.
3. **Assign an owner** responsible for driving remediation. This should be a team or named individual, not "TBD."
4. **Set a target date** consistent with the Rating response expectations.
5. **Update status** as remediation progresses. When closing a threat, note the date and verification method.
6. **Log all changes** in the Change Log section for audit trail purposes.
7. **Review the register** at the defined cadence. Re-score threats if the environment or threat landscape has changed.
8. **Accepted risks** require documented justification and sign-off from a stakeholder with appropriate authority.
