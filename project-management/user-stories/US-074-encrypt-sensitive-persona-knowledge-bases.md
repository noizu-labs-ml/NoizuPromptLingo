# US-074 - Encrypt Sensitive Persona Knowledge Bases

**ID**: US-074
**Persona**: P-002 - Product Manager
**PRD Group**: npl_load
**Priority**: medium
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a product manager, I need persona knowledge bases to be encrypted at rest so that sensitive domain expertise (customer data, proprietary methods) isn't exposed in plaintext files.

## Acceptance Criteria

- [ ] Persona `.knowledge-base.md` files support encryption at rest
- [ ] Encryption uses project-level or user-level master key
- [ ] `npl-persona` CLI prompts for passphrase when accessing encrypted KB
- [ ] Encrypted files are transparently decrypted when loaded
- [ ] Decryption failures return clear error without corrupting data
- [ ] Audit log records KB access attempts

## Technical Notes

This story extends the persona system with encryption capabilities. Implementation considerations:

1. **Encryption format**: Consider using standard formats (e.g., GPG, age) for interoperability
2. **Key management**: Support both project-level (shared) and user-level (individual) master keys
3. **Performance**: Cache decrypted content in memory during sessions
4. **Backward compatibility**: Unencrypted KBs must continue to work
5. **Audit trail**: Log all KB access attempts including decryption failures

Related to personas/security concerns in the npl_load bounded context.

## Dependencies

- Related stories: None
- Related personas: P-002 (Product Manager)
