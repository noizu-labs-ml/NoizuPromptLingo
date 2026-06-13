# Root Cause Analysis

Diagnostic methodology for finding why something is broken or underperforming.

## When to Use

- Something broke and you need to find out why
- Performance degraded and the cause isn't obvious
- A metric moved unexpectedly (up or down)
- You need to distinguish symptoms from causes

## Methods

### 5 Whys

The simplest diagnostic technique. Keep asking "why" until you reach a root cause.

```
Problem: Conversion rate dropped 20% last week
Why? → Signup form completion rate fell
Why? → Users are abandoning on the email field
Why? → Email validation is rejecting valid addresses
Why? → Validation regex was updated in last deploy
Why? → The new regex doesn't support "+" in email addresses
Root cause: Overly strict email validation regex
```

**When it works:** Single causal chain, relatively simple systems.
**When it fails:** Multiple causes, complex systems, when you stop too early.

### Fishbone (Ishikawa) Diagram

Categorize potential causes into standard buckets.

**For software/product issues:**
- **Code** — Bugs, regressions, logic errors
- **Infrastructure** — Servers, databases, network, DNS
- **Data** — Corrupt data, migration issues, missing records
- **Configuration** — Settings, feature flags, environment
- **External** — Third-party APIs, DNS, CDN, upstream dependencies
- **Process** — Deploy procedures, testing gaps, monitoring gaps

### Elimination Method

Systematically rule out causes.

```markdown
| Suspect | Test | Result | Eliminated? |
|---------|------|--------|-------------|
| [cause 1] | [how to check] | [what you found] | [yes/no] |
| [cause 2] | [how to check] | [what you found] | [yes/no] |
| [cause 3] | [how to check] | [what you found] | [yes/no] |
```

### Fault Tree Analysis

Top-down: start with the failure, decompose into possible causes using AND/OR logic.

```
Signup failure
├── OR: Form doesn't load
│   ├── AND: JS error + no fallback
│   └── OR: CDN down
└── OR: Form submits but fails
    ├── OR: Validation rejects valid input
    └── OR: Backend error
        ├── OR: Database connection failure
        └── OR: Rate limit exceeded
```

## RCA Report Template

```markdown
# Root Cause Analysis: [Incident/Issue Title]

**Date:** [date of analysis]
**Incident date:** [when it happened]
**Severity:** [High/Medium/Low]
**Duration:** [how long before resolution]

## Summary
[1-2 sentences: what happened and what caused it]

## Timeline
| Time | Event |
|------|-------|
| [time] | [what happened] |

## Root Cause
[Specific technical cause, not a vague category]

## Contributing Factors
- [Factor 1 — why this root cause was possible]
- [Factor 2 — why it wasn't caught sooner]

## Resolution
[What was done to fix it]

## Prevention
- [ ] [Action to prevent recurrence — with owner and date]
- [ ] [Monitoring/alerting improvement]
- [ ] [Process change]
```

## Common RCA Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Stopping at symptoms | "The server crashed" isn't a root cause | Keep asking why |
| Blaming people | "Bob pushed bad code" prevents systemic fixes | Ask why the system allowed it |
| Single cause bias | Complex failures have multiple causes | Look for contributing factors |
| No follow-up | Root cause identified but not fixed | Track action items to completion |
