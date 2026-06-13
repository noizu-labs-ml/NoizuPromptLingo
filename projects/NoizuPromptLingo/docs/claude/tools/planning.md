# Planning & Workflow

## EnterPlanMode

**Purpose**: Transition into planning mode for implementation tasks.

**When to use**:
- Non-trivial feature implementation:
  - Modifies 3+ files, OR
  - Requires architectural decisions, OR
  - Affects multiple modules or systems, OR
  - User might reasonably question the approach
- Multiple valid implementation approaches exist
- User preferences or design choices matter
- Requirements need exploration before implementation

**When NOT to use**:
- Simple one-line fixes
- Pure research tasks (use direct investigation instead)
- Very specific detailed instructions (just implement)
- User already provided full plan
- Requirements are unclear (use AskUserQuestion first)

**Usage**:
```json
{}
```

**What happens**:
1. User must approve entering plan mode
2. You explore codebase thoroughly
3. Design implementation approach
4. Present plan for approval
5. Use AskUserQuestion for clarifications
6. Exit with ExitPlanMode when ready

**Example flow**:
```
User: "Add user authentication"
→ EnterPlanMode (requires architectural decisions)
→ Explore codebase (Read config, Grep for existing auth patterns)
→ Design approach (JWT vs session, middleware placement, etc.)
→ Write plan to file (e.g., .claude/auth-plan.md)
→ Create implementation tasks (TaskCreate for schema, endpoints, tests)
→ ExitPlanMode with approval request
→ User approves
→ Implement (follow TDD: tests first, then code)
```

---

## ExitPlanMode

**Purpose**: Signal plan completion and request user approval.

**When to use**:
- After writing plan to plan file (in `.claude/` or `.tmp/` directory)
- Plan is complete and unambiguous
- Ready for user review and approval
- **ONLY for code implementation tasks** (not research or exploration)

**When NOT to use**:
- Research tasks
- Gathering information
- Understanding codebase
- Don't ask "Is this plan okay?" - that's what this tool does

**Parameters**:
- `allowedPrompts` (optional): Semantic permissions needed

**Usage**:
```json
{
  "allowedPrompts": [
    {"tool": "Bash", "prompt": "run tests"},
    {"tool": "Bash", "prompt": "install dependencies"}
  ]
}
```

**Critical rules**:
- Plan must already be written to plan file
- Tool reads plan from file (doesn't take content as parameter)
- Use AskUserQuestion BEFORE this for clarifications
- Never ask "Should I proceed?" - this tool does that

---

## Integration with TDD Workflow

**Plan mode in the agent orchestration system**:

When working within the [TDD agent workflow](../../arch/agent-orchestration.summary.md):
- **prd-editor** uses plan mode to design PRD structure
- **tdd-tester** uses plan mode for complex test suite design
- **tdd-coder** uses plan mode when implementation approach needs discussion

**Best practices for plan mode + TDD**:
1. Enter plan mode to design approach
2. Create tasks with TaskCreate for tracking implementation steps
3. Write plan to file with clear test strategy
4. Exit plan mode for approval
5. Implement following TDD cycle (tests first, then code)
6. Use `mise run test-status` and `mise run test-errors` to validate

**Example: Adding feature via plan mode**:
```
1. User requests new feature
2. EnterPlanMode → explore codebase
3. Design approach:
   - Decide on architecture
   - Plan test coverage strategy
   - Identify files to modify
4. Write plan to .claude/feature-plan.md
5. TaskCreate for each implementation step
6. ExitPlanMode → user approves
7. Implement with TDD:
   - Write tests first (guided by plan)
   - Run `mise run test-status` to confirm failures
   - Implement code to make tests pass
   - Refactor while keeping tests green
```

**When to skip plan mode in TDD workflow**:
- PRD already provides clear implementation path
- Tests clearly define expected behavior
- Changes are localized to single module
- Following existing patterns in codebase