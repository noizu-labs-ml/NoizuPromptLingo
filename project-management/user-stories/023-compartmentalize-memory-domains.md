---
id: story-023
title: "Compartmentalize memories into isolated domains"
persona: persona-the-sentinel
priority: should-have
complexity: L
status: draft
---

# Compartmentalize memories into isolated domains

**As** The Sentinel,
**I want to** organize memories into isolated compartments where association links cannot cross compartment boundaries without explicit authorization,
**So that** sensitive memory domains (e.g., security incidents, HR matters, financial data) are structurally isolated from general recall, preventing information leakage through associative traversal.

## Acceptance Criteria
- [ ] Memories are assigned to compartments at creation time (default: "general")
- [ ] Association links cannot be created between memories in different compartments unless a `bridge_authorization` exists
- [ ] The Weaver, Dreamer, and Recall Agent all enforce compartment boundaries during their operations
- [ ] Compartments are defined in a configuration file with: name, description, authorized roles, and allowed bridge targets
- [ ] Cross-compartment bridge authorizations require Human Operator approval and are logged
- [ ] A memory can belong to at most one compartment (no dual-homing)

## Scenario: Preventing cross-compartment association
- **Given** memory A (compartment: "security-incidents") discusses "credential rotation after breach" and memory B (compartment: "general") discusses "updating API keys for the new service"
- **When** The Weaver attempts to create an association link based on semantic similarity (both mention API keys)
- **Then** the link creation is blocked because "security-incidents" and "general" compartments have no bridge authorization, and the blocked attempt is logged

## Scenario: Authorized cross-compartment bridge
- **Given** compartment "security-incidents" has a bridge authorization to "infrastructure" for memories tagged "remediation"
- **When** The Weaver finds a legitimate association between a remediation memory in "security-incidents" and an infrastructure memory
- **Then** the bridge link is created with `bridge_authorization: security-to-infra-remediation` and logged for audit

## Technical Notes
- Compartmentalization is inspired by intelligence community information security practices (SCI compartments)
- Enforcement must happen at the graph traversal level, not just the query level — The Recall Agent must not traverse into unauthorized compartments during path search
- The Dreamer's consolidation (story-018) must respect compartment boundaries strictly
- Consider implementing compartment hierarchies in future iterations (e.g., "security-incidents/credential-breaches" sub-compartment)

## Related Stories
- story-021: Access gating works alongside compartmentalization — access controls who, compartments control what
- story-022: Redaction provides field-level protection within a compartment
- story-018: Dreamer consolidation must respect compartment boundaries
- story-014: Weaver cross-domain bridging is constrained by compartmentalization
- story-011: Weaver link creation must check compartment compatibility before creating links
