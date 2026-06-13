# Threat Model: {System Name}

**Date:** {YYYY-MM-DD}
**Author:** {Name / Team}
**Scope:** {What is included and excluded from this model}
**Framework:** {STRIDE / PASTA / OCTAVE}
**Risk Appetite:** {Conservative / Balanced / Aggressive}
**Review Cadence:** {Quarterly / On architecture change / Annual}

---

## System Overview

{1-2 paragraph description of the system, its purpose, user base, and data sensitivity. Include regulatory scope if applicable (GDPR, HIPAA, SOC2, etc.).}

## Architecture

{Component diagram in mermaid or ASCII format showing all components, data flows, and trust boundaries.}

### Components

| Component | Type | Trust Zone | Data Handled |
|-----------|------|------------|--------------|
| {Component name} | {Web server / API / Database / Cache / CDN / etc.} | {Zone name} | {What data it processes or stores} |
| {Component name} | {Type} | {Zone} | {Data} |

### Data Flows

| From | To | Data | Protocol | Encrypted |
|------|-----|------|----------|-----------|
| {Source component} | {Destination component} | {Data description} | {HTTPS / TCP / gRPC / etc.} | {Yes / No} |
| {Source} | {Destination} | {Data} | {Protocol} | {Yes / No} |

### Trust Boundaries

| Boundary | Between | Controls |
|----------|---------|----------|
| {Boundary name} | {Component A} <-> {Component B} | {Firewall / TLS / Network policy / Auth / etc.} |
| {Boundary name} | {Component A} <-> {Component B} | {Controls} |

---

## Attack Surface

### Entry Points

1. {Entry point description — e.g., Public HTTPS endpoint}
2. {Entry point description}

### Assets Worth Protecting

- {Asset and why it matters — e.g., User PII (GDPR-regulated)}
- {Asset}

### Actor Types

- **{Actor type}** — {Description of capability and motivation}
- **{Actor type}** — {Description}

---

## STRIDE Analysis

### {Component Name}

| Category | Threat | L | I | Risk | Mitigation |
|----------|--------|---|---|------|------------|
| Spoofing | {Threat description} | {1-5} | {1-5} | {Low/Medium/High/Critical} | {Mitigation} |
| Tampering | {Threat description} | {1-5} | {1-5} | {Risk level} | {Mitigation} |
| Repudiation | {Threat description} | {1-5} | {1-5} | {Risk level} | {Mitigation} |
| Info Disclosure | {Threat description} | {1-5} | {1-5} | {Risk level} | {Mitigation} |
| Denial of Service | {Threat description} | {1-5} | {1-5} | {Risk level} | {Mitigation} |
| Elevation of Privilege | {Threat description} | {1-5} | {1-5} | {Risk level} | {Mitigation} |

{Repeat the STRIDE table for each component that crosses a trust boundary.}

---

## Risk Register

| ID | Threat | Category | L | I | Risk | Status | Owner | Remediation | Target Date |
|----|--------|----------|---|---|------|--------|-------|-------------|-------------|
| T-001 | {Threat description} | {S/T/R/I/D/E} | {1-5} | {1-5} | {Critical/High/Medium/Low} | {Open/Mitigating/Accepted/Closed} | {Team or person} | {Remediation action} | {YYYY-MM-DD} |
| T-002 | {Threat description} | {Category} | {L} | {I} | {Risk} | {Status} | {Owner} | {Remediation} | {Date} |

---

## Recommendations

### Critical (address immediately)

1. **{Finding title}** — {Remediation description with specific steps} [Effort: {Low/Medium/High}]

### High (address within 30 days)

1. **{Finding title}** — {Remediation description} [Effort: {Low/Medium/High}]

### Medium (address within 90 days)

1. **{Finding title}** — {Remediation description} [Effort: {Low/Medium/High}]

### Low (address in next planning cycle)

1. **{Finding title}** — {Remediation description} [Effort: {Low/Medium/High}]

---

## Appendix

### Assumptions and Limitations

- {Assumption about the environment, infrastructure, or threat landscape}
- {Limitation of this analysis — e.g., no active testing performed}

### Methodology Notes

- {How likelihood and impact were scored}
- {What was in scope vs. out of scope}
- {Tools or references used}

### References

- {Link or citation to relevant standard, benchmark, or prior assessment}
