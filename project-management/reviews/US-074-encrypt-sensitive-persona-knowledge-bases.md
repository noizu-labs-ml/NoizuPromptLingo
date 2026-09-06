# Review: Encrypt Sensitive Persona Knowledge Bases

- **Story**: `project-management/user-stories/US-074-encrypt-sensitive-persona-knowledge-bases.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No encryption capability exists anywhere in either codebase. Grep for `encrypt|fernet|cipher|passphrase` across `src/npl_mcp/` returns zero hits, and across the Elixir backend (`backend/lib/noizu_prompt_lingua/`) likewise zero. The persona system (`backend/lib/noizu_prompt_lingua/domains/personas/`, and Python-side persona tooling) stores knowledge bases as plaintext; there is no master-key management, no passphrase prompt in any CLI (`npl-persona` persona agent files carry no encryption hooks), and no audit logging of KB access (no audit infrastructure exists — see US-070/US-071 reviews). Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Persona `.knowledge-base.md` files support encryption at rest | Not Met | no evidence found in either codebase |
| Encryption uses project-level or user-level master key | Not Met | no key-management code exists (`grep encrypt|cipher|fernet`: no hits) |
| `npl-persona` CLI prompts for passphrase when accessing encrypted KB | Not Met | no evidence found |
| Encrypted files transparently decrypted when loaded | Not Met | no evidence found |
| Decryption failures return clear error without corrupting data | Not Met | no evidence found |
| Audit log records KB access attempts | Not Met | no audit-log infrastructure exists (no `audit` hits in `src/npl_mcp/`; backend `asset_history` covers assets only) |

## Gaps / Risks

- Persona knowledge bases (domain expertise, potentially customer data) are stored and served in plaintext.
- Adjacent plaintext exposure compounds this: `src/npl_mcp/browser/secrets.py` stores secret values as plaintext in the `npl_secrets` table (module docstring, line 3).
- Backward-compatibility requirement (unencrypted KBs keep working) is trivially satisfied today, but only because nothing is encrypted.

## BDD Scenario

```gherkin
Feature: Encrypted persona knowledge bases
  Story is NOT implemented — scenario describes intended behavior, currently absent.

  Scenario: Product manager encrypts a proprietary KB
    Given a persona with a knowledge base containing customer-specific methods
    When the KB is written to disk
    Then the file is stored as plaintext markdown (current behavior)
    And any reader with filesystem or tool access can read it without a key
    And no access attempt is logged anywhere
```
