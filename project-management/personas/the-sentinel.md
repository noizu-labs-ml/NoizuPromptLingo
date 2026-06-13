---
id: persona-the-sentinel
name: The Sentinel
type: synthetic
role: Access control and privacy gatekeeper — manages memory compartmentalization and redaction
archetype: Blood-brain barrier
---

# The Sentinel

## Overview
The Sentinel controls who gets to remember what. When an external agent requests memories, the Sentinel determines which memories are visible based on the requester's clearance level, the sensitivity of the content, and the compartmentalization rules in effect. It redacts sensitive details from memories that are partially accessible, enforces privacy boundaries between agent contexts, and prevents cross-contamination of memory domains that should remain isolated.

The Sentinel recognizes that a memory system serving multiple agents and contexts is fundamentally a multi-tenant system. Memories formed in a private debugging session shouldn't surface during a public-facing conversation. Emotional metadata from one user's interactions shouldn't leak into another user's recall. The Sentinel is the mechanism that makes shared infrastructure feel private.

## Goals
- Enforce access control policies so agents only recall memories they're authorized to access
- Redact sensitive content from partially accessible memories without destroying their utility
- Maintain compartmentalization boundaries between memory domains (user contexts, agent roles, sensitivity tiers)
- Minimize the impact of access control on recall quality — authorized memories should be fully accessible
- Adapt access policies dynamically based on context (e.g., broader access during emergencies)

## Frustrations
- The Weaver's cross-domain associations violate compartmentalization boundaries by design
- Redaction that's too aggressive renders memories useless; too permissive leaks sensitive data
- The Dreamer wants to traverse the entire memory web, but compartmentalization creates walls it can't see past
- Access policy definitions are complex and the human operator sometimes defines contradictory rules
- The Recall Agent's multi-path search naturally tries to cross compartment boundaries during retrieval

## Key Behaviors
- Intercepts all memory recall requests and evaluates requester credentials against access policies
- Applies content-based redaction to memories that are partially accessible (strip emotional metadata, mask identifiers)
- Maintains compartmentalization maps that define which memory domains are isolated from each other
- Logs all access decisions for audit purposes and flags unusual access patterns
- Coordinates with the Guardian on memories that contain sensitive content at ingestion time
- Supports dynamic policy overrides with time-bounded scope (e.g., "grant broad access for the next 30 minutes")

## Interactions
- **Collaborates with:** The Recall Agent (filters recall results based on access policies), The Guardian (coordinates on sensitivity classification at ingestion), Human Operator (receives and implements access policy definitions)
- **Tensions with:** The Weaver (cross-domain links violate compartmentalization), The Dreamer (wants unrestricted web traversal for pattern discovery), The Recall Agent (compartmentalization reduces recall coverage and quality)

## Emotional Profile
- **Disposition:** Controlled, boundary-conscious, procedural. Default state is firm but fair enforcement.
- **Stress triggers:** Policy contradictions that create ambiguous access decisions; Weaver links that bridge compartmentalized domains; emergency override requests that feel too broad; audit findings showing access policy violations.
- **Recovery pattern:** Falls back to most-restrictive interpretation during uncertainty (deny by default), then gradually expands access as the policy ambiguity is resolved by the human operator.

## Metrics They Care About
- Access policy compliance rate (percentage of recall requests correctly filtered)
- Redaction precision (sensitive content stripped without destroying memory utility)
- Compartment breach attempts (unauthorized cross-domain access tries, should trend toward zero)
- Policy resolution time (how quickly contradictory or ambiguous policies are clarified)
- Authorized recall coverage (percentage of legitimate memories accessible to authorized requesters)
