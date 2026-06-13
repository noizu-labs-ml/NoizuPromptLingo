---
id: story-021
title: "Enforce access gating on memory retrieval"
persona: persona-the-sentinel
priority: must-have
complexity: L
status: draft
---

# Enforce access gating on memory retrieval

**As** The Sentinel,
**I want to** enforce access control policies on every memory retrieval request, ensuring that callers can only access memories they are authorized to see based on their identity, role, and the memory's classification level,
**So that** sensitive memories are protected from unauthorized access even within the same agent system.

## Acceptance Criteria
- [ ] Every recall request includes a caller identity (agent ID, user ID, or service account) and is validated against an access control list (ACL) before memories are returned
- [ ] Memories have a `classification` field: `public`, `internal`, `confidential`, `restricted`
- [ ] Access policies map caller roles to maximum classification levels (e.g., `recall-agent: confidential`, `external-api: public`)
- [ ] Denied access attempts are logged with caller identity, requested memory ID, classification level, and denial reason
- [ ] Access checks add <10ms overhead to recall latency
- [ ] Bulk recall requests are filtered — authorized memories are returned, unauthorized ones are silently omitted (not error-raised) with a `filtered_count` in the response metadata

## Scenario: Recall agent accessing confidential memory
- **Given** The Recall Agent (role: `recall-agent`, max classification: `confidential`) requests a memory classified as `confidential`
- **When** The Sentinel evaluates the access request
- **Then** access is granted, the memory is returned, and the access is logged as `permitted`

## Scenario: External API accessing restricted memory
- **Given** an external API integration (role: `external-api`, max classification: `public`) requests a memory classified as `restricted`
- **When** The Sentinel evaluates the access request
- **Then** access is denied, the memory is not returned, the attempt is logged as `denied: classification_exceeded`, and the response includes `filtered_count: 1`

## Technical Notes
- Access control must be enforced at the retrieval layer, not the UI layer — defense in depth
- Consider implementing attribute-based access control (ABAC) for more flexible policies than simple role-based ACL
- The ACL should be cacheable with short TTL (60s) to minimize lookup overhead
- Access logging feeds into The Monitor's anomaly detection (story-009) — unusual access patterns may indicate compromise

## Related Stories
- story-022: Recall Agent emotional recall must pass through access gating
- story-023: Multi-path search must respect access restrictions on all traversed paths
- story-027: Sentinel redaction provides a softer alternative to full access denial
- story-028: Compartmentalization provides a structural grouping that informs access policies
