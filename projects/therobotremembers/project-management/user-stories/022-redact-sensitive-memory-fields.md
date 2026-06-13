---
id: story-022
title: "Redact sensitive fields from memory responses"
persona: persona-the-sentinel
priority: should-have
complexity: M
status: draft
---

# Redact sensitive fields from memory responses

**As** The Sentinel,
**I want to** redact specific sensitive fields from memory records when returning them to callers with insufficient clearance, rather than blocking the entire memory,
**So that** callers can still benefit from the non-sensitive portions of a memory without exposing protected details.

## Acceptance Criteria
- [ ] Memories can have individual fields marked as `sensitive` with a minimum classification level required to view them
- [ ] When a caller's clearance is below a field's classification, the field is replaced with `[REDACTED]` and a `redaction_reason` hint (e.g., "contains PII", "contains credentials")
- [ ] Redaction is applied to: raw content, context window entries, association link rationales, and synthesis summaries
- [ ] The response metadata includes `redacted_fields: ["content", "context_window"]` so callers know information was withheld
- [ ] Redaction rules are defined in a configurable policy file, not hardcoded
- [ ] Redaction is applied after access gating — only memories that pass basic access checks are considered for redaction

## Scenario: Partial redaction of memory with PII
- **Given** a memory about "onboarding user john.doe@example.com to the new API" is classified `internal` but the email field is marked `sensitive: confidential`
- **When** a caller with `internal` clearance retrieves the memory
- **Then** the memory is returned with content "onboarding user [REDACTED] to the new API", redaction_reason: "contains PII", and `redacted_fields: ["content"]`

## Scenario: Full clearance sees unredacted memory
- **Given** the same memory about onboarding with PII
- **When** a caller with `confidential` clearance retrieves the memory
- **Then** the memory is returned fully unredacted with the email visible

## Technical Notes
- Redaction must be applied server-side — never send sensitive data to the client and rely on client-side filtering
- Consider using regex patterns for automatic PII detection (emails, API keys, IPs) in addition to manual field-level marking
- Redaction of association link rationales is important — a link rationale like "both mention john.doe@example.com" would leak the PII even if the memory content is redacted
- The redaction policy file should support both field-level rules and content-pattern rules

## Related Stories
- story-021: Access gating is the prerequisite — redaction is a softer alternative to full denial
- story-028: Compartmentalization provides structural boundaries; redaction provides field-level boundaries
- story-023: Recall Agent multi-path search results must have redaction applied before ranking
- story-006: Guardian injection blocking should also check for attempts to inject sensitive data patterns
