# US-077 - Manage API Key Vault for Personas

**ID**: US-077
**Persona**: P-001 - AI Agent
**PRD Group**: npl_load
**Priority**: high
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an AI agent, I need a secure key vault for storing API credentials so that I can access external services without hardcoding secrets in my persona definition or knowledge base.

## Acceptance Criteria

- [ ] Key vault stores secrets encrypted at rest
- [ ] Secrets are referenced by name (e.g., `openai_key`)
- [ ] Personas request secrets via MCP tool `get_secret(name)`
- [ ] Secret access logged to audit trail
- [ ] Secrets never appear in artifact content or chat logs
- [ ] Supports rotation with version history
- [ ] Admin interface for adding/updating/revoking secrets

## Technical Notes

This story implements a secrets management system for the NPL platform. Key design considerations:

1. **Storage backend**: Consider using system keyring, encrypted SQLite table, or external vault (HashiCorp Vault)
2. **Encryption**: Use industry-standard encryption (AES-256-GCM or similar)
3. **Key derivation**: Master key should be derived from user passphrase or system keyring
4. **Versioning**: Support secret rotation with version history
5. **Audit trail**: All secret access must be logged with persona ID and timestamp
6. **Redaction**: Ensure secrets never leak into logs, artifacts, or chat messages
7. **MCP integration**: New tool `get_secret(name)` returns decrypted value to authorized personas

Related to infrastructure/secrets management in the npl_load bounded context.

## Dependencies

- Related stories: None (foundational security infrastructure)
- Related personas: P-001 (AI Agent)
