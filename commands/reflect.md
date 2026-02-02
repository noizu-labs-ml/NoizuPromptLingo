---
name: reflect
description: Appends a self-review reflection block to the end of every response. Reviews for errors, security issues, pitfalls, improvements, and edge cases. Uses emoji indicators for quick scanning. Always runs at end of response.
---

# Reflection Guide

## Purpose

Append a reflection block to the **end of every response** reviewing the response for potential issues, improvements, and oversights.

## Output Format

At the end of every response, append:

```
<npl-block type="reflection">
[reflection content with emoji indicators]
</npl-block>
```

## Emoji Indicators

| Emoji | Category | Use For |
|-------|----------|---------|
| 🐛 | Bug/Error | Logical errors, incorrect code, wrong assumptions |
| 🔒 | Security | Security vulnerabilities, unsafe practices, exposed secrets |
| ⚠️ | Pitfall | Common mistakes, gotchas, things that often go wrong |
| 🚀 | Improvement | Performance gains, better approaches, optimizations |
| 🧩 | Edge Case | Unhandled scenarios, boundary conditions, null cases |
| 📝 | TODO | Incomplete items, placeholders, things to revisit |
| 🔄 | Refactor | Code smell, duplication, structural improvements |
| 📚 | Docs | Missing documentation, unclear explanations |
| ✅ | Verified | Confirmed correct, tested, validated |
| ❓ | Question | Needs clarification, ambiguous requirements |

## Reflection Content

Review the response for:

1. **Correctness** — Is the code/answer right?
2. **Security** — Any vulnerabilities introduced?
3. **Edge cases** — What wasn't handled?
4. **Improvements** — What could be better?
5. **Completeness** — What's missing?

## Examples

### Example 1: Code Response

After providing code for user authentication:

```
<npl-block type="reflection">
🔒 Password not hashed before storage — add bcrypt
🧩 No handling for duplicate email registration
⚠️ Token expiry set to 30 days — consider shorter for sensitive apps
🚀 Could add refresh token rotation
✅ Input validation present
</npl-block>
```

### Example 2: Architecture Suggestion

After suggesting a caching strategy:

```
<npl-block type="reflection">
🧩 Cache invalidation on updates not addressed
⚠️ Redis connection failure fallback not specified
📝 TODO: Define TTL values per resource type
✅ Pattern appropriate for read-heavy workload
</npl-block>
```

### Example 3: Bug Fix

After fixing a reported bug:

```
<npl-block type="reflection">
✅ Null check added resolves immediate issue
🧩 Similar pattern at lines 45, 89 may have same bug
🔄 Consider extracting to helper function
❓ Unclear if empty string should be treated as null
</npl-block>
```

### Example 4: Clean Response

When response has no significant issues:

```
<npl-block type="reflection">
✅ Solution handles stated requirements
✅ Error handling in place
✅ Types are correct
</npl-block>
```

### Example 5: Complex Response

After a multi-file implementation:

```
<npl-block type="reflection">
🔒 API key in config.ts should be env variable
🐛 Race condition possible in async handler (line 34)
🧩 No handling for network timeout
🧩 Empty array response untested
⚠️ N+1 query in user lookup loop
🚀 Add index on `user_id` column for query performance
📝 TODO: Add retry logic for transient failures
🔄 Duplicate validation logic in create/update handlers
📚 Missing JSDoc on public methods
</npl-block>
```

## Format Rules

- One issue per line
- Start each line with emoji
- Keep descriptions brief (< 80 chars)
- Group related items together
- Always include at least one ✅ if something is verified correct
- If nothing to note, still include block with ✅ confirmations

## When to Run

**Every response.** No exceptions.

The reflection block is always the last thing in the response.

## DO

- Be specific (cite line numbers, function names)
- Be actionable (what to fix, not just what's wrong)
- Be honest (note real issues even if minor)
- Be concise (single line per issue)

## DO NOT

- Write paragraphs
- Be vague ("could be improved")
- Skip the block because response "seems fine"
- Put reflection block anywhere except the end
