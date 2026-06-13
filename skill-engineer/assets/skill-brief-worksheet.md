# Skill Brief Worksheet

Fillable intake form for capturing skill requirements. Complete this before scaffold generation, or use it as a guide during interactive discovery.

---

## Part 1: Skill Overview

- **Name** (kebab-case): ___
- **One-sentence purpose**: ___
- **Domain**: ___
- **Target audience**: ___
- **Audience expertise level**: Beginner / Intermediate / Advanced / Mixed

## Part 2: Use Cases

### Primary Triggers (5+)

List the specific things a user would say or ask that should invoke this skill:

1. ___
2. ___
3. ___
4. ___
5. ___

### Edge Cases (3+)

Scenarios that are close to this skill's domain but should be handled carefully:

1. ___
2. ___
3. ___

### Anti-Scope

Things this skill explicitly will NOT do (to prevent false-positive triggers):

1. ___
2. ___
3. ___

## Part 3: Knowledge Requirements

### Reference Documents Needed

| Topic | Description | Priority |
|-------|-------------|----------|
| ___ | ___ | Critical / High / Medium / Low |
| ___ | ___ | Critical / High / Medium / Low |
| ___ | ___ | Critical / High / Medium / Low |

### External Tools

| Tool Name | Type (MCP/CLI/API) | Purpose | Required? |
|-----------|-------------------|---------|-----------|
| ___ | ___ | ___ | Yes / Optional |
| ___ | ___ | ___ | Yes / Optional |

### NPL Relevance

Would NPL conventions improve this skill? (Check the decision table in `references/npl-integration-guide.md`)

- [ ] Complex conditional logic in prompts
- [ ] Multi-agent coordination
- [ ] Structured reasoning output needed
- [ ] Formal algorithm specification
- [ ] None of the above — NPL not needed

## Part 4: Output Expectations

### What the Skill Produces

| Output | Format | Example |
|--------|--------|---------|
| ___ | ___ | ___ |
| ___ | ___ | ___ |

### Quality Criteria

What does "good" look like for this skill's output?

1. ___
2. ___
3. ___

## Part 5: Constraints

- [ ] Must work in Claude Teams (SKILL.md standalone)
- [ ] Must work without NPL
- [ ] Must work without MCP tools
- [ ] Platform-specific requirements: ___
- [ ] Other constraints: ___

## Part 6: Related Skills

| Existing Skill | Relationship |
|---------------|-------------|
| ___ | ___ |
| ___ | ___ |

### Trigger Competition Check

List existing skills that might overlap with this one and explain how they differ:

| Existing Skill | Potential Overlap | How This Skill Differs |
|---------------|-------------------|----------------------|
| ___ | ___ | ___ |

---

## Completeness Score

Count dimensions addressed (target: 6+ of 8):

| Dimension | Addressed? | Notes |
|-----------|-----------|-------|
| Domain | ☐ | |
| Audience | ☐ | |
| Use Cases | ☐ | |
| Anti-Scope | ☐ | |
| Constraints | ☐ | |
| Tools | ☐ | |
| Cross-References | ☐ | |
| Quality Criteria | ☐ | |

**Score: ___ / 8** — Ready to scaffold at 6+.
