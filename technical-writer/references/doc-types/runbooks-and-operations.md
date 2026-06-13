# Runbooks and Operations Documentation

Patterns for operational runbooks, troubleshooting guides, incident response procedures, and changelogs/release notes.

## Runbook Structure

A runbook is a decision tree with commands. The reader is in an incident or performing a procedure — they need answers fast.

### Core Pattern

```markdown
# Runbook: {Procedure Name}

**When to use:** {One sentence: the situation that triggers this runbook}
**Expected duration:** {time estimate}
**Required access:** {permissions, credentials, tools needed}

## Prerequisites
- [ ] Access to {system}
- [ ] {Tool} installed (`{verify-command}`)

## Procedure

### Step 1: {Action}

```bash
{command}
```

**Expected output:**
```
{what you should see}
```

**If you see {error} instead:** Go to [Troubleshooting: {error}](#troubleshooting)

### Step 2: {Action}
...

## Verification

Confirm the procedure succeeded:
```bash
{verification command}
```

Expected: {what success looks like}

## Rollback

If something went wrong:
```bash
{rollback commands}
```

## Troubleshooting

### {Error 1}
**Symptom:** {what you see}
**Cause:** {why it happens}
**Fix:** {what to do}
```

### Key Principles

1. **Every step is one action** — don't combine "stop the service and clear the cache" into one step
2. **Show expected output** — the reader needs to know "did it work?"
3. **Escape hatches at every step** — what if this step fails?
4. **Rollback is mandatory** — every procedure must be reversible (or state explicitly that it isn't)
5. **No prose** — runbooks are for executing, not reading

## Troubleshooting Guide Structure

Different from a runbook: the reader has a *symptom* and needs to find the *cause*.

```markdown
# Troubleshooting: {System/Feature}

## {Symptom 1: Error message or observable behavior}

**Likely cause:** {most common cause}

**Diagnostic steps:**
1. Check {thing}: `{command}`
2. Look for {pattern} in output
3. If {condition}, the cause is {X}

**Fix:**
```bash
{fix command}
```

**Verify:** `{verification command}` should show {expected output}

---

## {Symptom 2}
...
```

### Organizing Troubleshooting Guides

| Approach | When to Use |
|----------|-------------|
| By symptom | Reader knows what they see, not what's wrong |
| By component | Reader knows which part is broken |
| By error code | System has well-defined error codes |

**Default to symptom-based** — it matches how the reader arrives at the doc.

## Incident Response Procedure

```markdown
# Incident Response: {Incident Type}

**Severity:** {P1/P2/P3}
**On-call team:** {team}
**Escalation:** {who to contact if this procedure doesn't resolve}

## Detection
How this incident is typically discovered:
- Alert: {alert name and source}
- User report: {typical report pattern}

## Immediate Actions (first 5 minutes)
1. {Triage step}
2. {Communication step — who to notify}
3. {Mitigation step}

## Investigation
1. {Diagnostic step with command}
2. {What to look for}

## Resolution
{Fix steps, by root cause variant}

## Post-Incident
- [ ] Write incident report
- [ ] Update this runbook if procedure changed
- [ ] File follow-up tickets for prevention
```

## Changelog / Release Notes

### Changelog Format (keepachangelog.com)

```markdown
# Changelog

## [Unreleased]

## [1.2.0] — 2026-05-12

### Added
- User export API endpoint (`GET /api/v1/users/export`)
- Dark mode support for dashboard

### Changed
- Default pagination limit increased from 20 to 50

### Fixed
- Session timeout now correctly resets on activity

### Deprecated
- `GET /api/v1/users?format=csv` — use export endpoint instead

### Removed
- Legacy v0 API endpoints (deprecated since 1.0)

### Security
- Updated `jsonwebtoken` to 9.0.3 (CVE-2024-XXXXX)
```

### Release Notes (User-Facing)

More narrative than a changelog. Written for users who need to know "what changed and do I need to do anything?"

```markdown
# Release Notes: v1.2.0

## Highlights

**User Export API** — You can now export your user list via the API.
See the [export guide](./docs/export.md) for details.

**Dark Mode** — The dashboard now supports dark mode. Toggle it in
Settings → Appearance.

## Breaking Changes

None in this release.

## Migration Guide

No action required — this is a backward-compatible update.

## Full Changelog

See [CHANGELOG.md](./CHANGELOG.md#120---2026-05-12) for the complete list.
```

### Writing Good Changelog Entries

| Bad | Good | Why |
|-----|------|-----|
| "Fixed bug" | "Fixed session timeout not resetting on activity" | Specific symptom |
| "Updated dependencies" | "Updated jsonwebtoken to 9.0.3 (security fix)" | Reason matters |
| "Refactored user service" | *(Don't include internal refactors)* | Users don't care |
| "Added new feature" | "Added user export API (`GET /api/v1/users/export`)" | What and where |
