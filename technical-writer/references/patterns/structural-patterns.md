# Structural Patterns

Reusable document structures for common documentation needs. Each pattern defines a section order and purpose — adapt the details to your content.

## Pattern 1: Problem → Solution → Verification

**Use for:** Troubleshooting entries, how-to fixes, FAQ answers.

```markdown
### {Problem Title (as symptom)}

**Problem:** {What the reader is experiencing — error message, unexpected behavior}

**Solution:**
{Steps to fix, with commands}

**Verification:**
{How to confirm the fix worked}
```

**Why this order:** The reader has a problem. They need to confirm you're describing their problem, get the fix, and verify it worked. Don't explain why it happens unless the reader needs that to choose between fixes.

## Pattern 2: Context → Steps → Result

**Use for:** Tutorials, guided walkthroughs, onboarding sections.

```markdown
## {Task Title}

{1-2 sentences: why you're doing this and what you'll have at the end}

### Steps

1. {Step}
2. {Step}
3. {Step}

### Result

{What you should now have. Screenshot or expected output.}
```

**Why this order:** The reader needs motivation ("why am I doing this?"), then instructions, then confirmation. The context sentence prevents the "why am I running these commands?" feeling.

## Pattern 3: Overview → Details → Reference

**Use for:** Feature documentation, concept pages, API sections.

```markdown
## {Feature Name}

{2-3 sentence overview: what it is and the primary use case}

### How It Works

{Explanation with examples. Start with the common case.}

### Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| ... | ... | ... | ... |

### Examples

{Working examples for common scenarios}
```

**Why this order:** Progressive disclosure. The reader who just needs to know "what is this?" stops at the overview. The reader who needs to use it reads the details. The reader who needs exhaustive options reads the reference.

## Pattern 4: Before → During → After

**Use for:** Migration guides, upgrade procedures, breaking change docs.

```markdown
## Migrating from v1 to v2

### Before You Start

- {Prerequisite / backup step}
- {What to verify before beginning}

### Migration Steps

1. {Step with command}
2. {Step with command}

### After Migration

- {Verification steps}
- {Cleanup steps}
- {What's different now}
```

**Why this order:** Migrations are high-stakes. The reader needs to prepare, execute, and verify. Skipping "before" risks data loss. Skipping "after" risks incomplete migration.

## Pattern 5: Concept → Example → Gotchas

**Use for:** Explanatory documentation, "how X works" pages.

```markdown
## {Concept Name}

{Explanation of what the concept is and why it matters}

### Example

```{language}
{Working code example showing the concept}
```

{Brief explanation of the example if non-obvious}

### Gotchas

- **{Gotcha 1}** — {What surprises people and how to handle it}
- **{Gotcha 2}** — {Edge case or common mistake}
```

**Why this order:** Understanding comes from seeing something concrete. The concept gives framing, the example makes it real, the gotchas prevent the pain that comes from assuming it's simpler than it is.

## Pattern Selection Guide

| Reader's question | Pattern | Section emphasis |
|-------------------|---------|-----------------|
| "How do I fix X?" | Problem → Solution → Verification | Solution (commands) |
| "Walk me through X" | Context → Steps → Result | Steps (numbered) |
| "What is X?" | Overview → Details → Reference | Overview + details |
| "How do I upgrade to X?" | Before → During → After | During (steps) |
| "How does X work?" | Concept → Example → Gotchas | Example (code) |

## Combining Patterns

Large documents use multiple patterns in sequence:

```
README:
  Overview → Details → Reference (for "What is this?")
    + Context → Steps → Result (for "Quick Start")
    + Problem → Solution → Verification (for "Troubleshooting")

Onboarding Guide:
  Context → Steps → Result (for each setup section)
    + Problem → Solution → Verification (for troubleshooting)

API Reference:
  Overview → Details → Reference (for each endpoint group)
    + Concept → Example → Gotchas (for authentication, pagination)
```

## Structural Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Wall of prose | Reader can't scan | Break into headed sections |
| Steps without context | Reader doesn't know why | Add a one-sentence "why" before steps |
| Reference without overview | Reader can't find what they need | Add a summary table or overview paragraph |
| Nested 4+ levels deep | Reader loses position | Flatten — use separate pages instead |
| Chronological order | Not how readers search | Order by frequency of need or reader journey |
