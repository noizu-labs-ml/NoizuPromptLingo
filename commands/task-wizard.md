# Task CLI Wizard

**LLM instructions for using the `task` CLI tool to manage work, deadlines, and project coordination.**

> The task CLI is the primary interface for creating, filtering, updating, and tracking work items. This guide covers all operations with examples and best practices.

---

## Overview

The task system manages work coordination across the project. Each task represents a discrete unit of work with:

- **Subject** – Brief imperative title ("Add authentication", not "Authentication feature")
- **Description** – Detailed requirements, context, and acceptance criteria
- **Status** – `pending`, `in_progress`, `completed`, or `deleted`
- **Owner** – Agent ID (person or AI agent responsible)
- **Metadata** – Custom fields for tracking project-specific data
- **Dependencies** – Blocks/blockedBy relationships for task ordering
- **Timeline** – Created date, deadline, completed date

---

## Quick Reference

| Goal | Command |
|------|---------|
| List all tasks | `task list` |
| Create a new task | `task create --subject "..." --description "..."` |
| View task details | `task get <task-id>` |
| Update task | `task update <task-id> --status in_progress` |
| Set deadline | `task update <task-id> --deadline 2026-02-15` |
| Assign task | `task update <task-id> --owner agent-name` |
| Mark complete | `task update <task-id> --status completed` |
| Filter by status | `task list --status pending` |
| Search tasks | `task list --search "keyword"` |
| View blocking | `task list --blocked-by <task-id>` |
| Set dependency | `task update <task-id> --blocks task-2,task-3` |

---

## Creating Tasks

### Basic Task Creation

```bash
task create \
  --subject "Add user authentication" \
  --description "Implement JWT-based auth with login/logout endpoints"
```

**Result:** Returns new task ID (e.g., `task-42`)

### Complete Task Creation (Best Practice)

```bash
task create \
  --subject "Implement password reset flow" \
  --description "Allow users to reset forgotten passwords via email link.

Requirements:
- Generate secure reset token (expires 24h)
- Send email with reset link
- Validate token and update password
- Log password change event

Acceptance criteria:
- ✓ Email sent within 60 seconds
- ✓ Reset link works only once
- ✓ Old sessions invalidated after reset
- ✓ User can set new password on form" \
  --owner alice \
  --deadline 2026-02-15 \
  --metadata priority=high,component=auth
```

### Task Subject Best Practices

**Good subject lines (imperative form):**
- ✅ "Add email verification to signup"
- ✅ "Fix authentication timeout on mobile"
- ✅ "Optimize database query for user list"
- ✅ "Write tests for payment processor"

**Avoid:**
- ❌ "Authentication feature" (vague)
- ❌ "Bug in login" (no action verb)
- ❌ "stuff" (meaningless)
- ❌ "research" (not a deliverable)

### Task Description Best Practices

Structure descriptions with:

```markdown
[1-2 sentence summary of what needs doing]

## Context
[Why this matters, background, related tasks]

## Requirements
- Requirement 1
- Requirement 2
- Requirement 3

## Acceptance Criteria
- ✓ Criterion 1
- ✓ Criterion 2
- ✓ Criterion 3 (should include testing)

## Related Tasks
- task-25 (blocks this one)
- task-30 (blocked by this one)
```

---

## Reviewing Tasks

### List All Tasks

```bash
task list
```

**Output:**
```
ID       Subject                          Status       Owner        Deadline
─────────────────────────────────────────────────────────────────────────────
task-1   Add authentication               completed    alice        2026-02-10
task-2   Fix login timeout                in_progress  bob          2026-02-12
task-3   Optimize user query              pending      (unassigned) 2026-02-15
task-4   Write payment tests              pending      (unassigned) 2026-02-20
```

### View Specific Task

```bash
task get task-3
```

**Output:**
```
ID:          task-3
Subject:     Optimize user query
Status:      pending
Owner:       (unassigned)
Deadline:    2026-02-15
Created:     2026-01-28
Blocked By:  task-2 (in_progress)
Blocks:      task-4 (pending)

Description:
Database query for user list takes 3 seconds.
Need to optimize with indexing and pagination.

Requirements:
- Add database indexes
- Implement pagination
- Cache results for 5 minutes

Acceptance Criteria:
- ✓ Query completes in <500ms
- ✓ Pagination works for 10k+ users
- ✓ Cache invalidates on update
```

### List with Filters

```bash
# By status
task list --status pending
task list --status in_progress
task list --status completed

# By owner
task list --owner alice
task list --owner bob
task list --owner unassigned

# Overdue tasks
task list --overdue

# Due soon (next 7 days)
task list --due-soon

# By deadline
task list --deadline-before 2026-02-15
task list --deadline-after 2026-02-01
task list --deadline-range 2026-02-01 2026-02-28
```

### Search Tasks

```bash
# Search by keyword
task list --search authentication
task list --search "payment processor"
task list --search bug

# Combine filters
task list --status pending --search auth --owner alice

# Show all pending auth tasks assigned to alice
task list --status pending --owner alice --search auth
```

---

## Task Dependencies

### View Blocking Relationships

```bash
# Tasks that task-2 blocks
task list --blocks task-2

# Tasks that block task-2
task list --blocked-by task-2

# All tasks in a dependency chain
task list --related-to task-2
```

### Set Task Dependencies

```bash
# task-2 must complete before task-3 can start
task update task-3 --blocked-by task-2

# task-5 cannot start until task-2 and task-4 complete
task update task-5 --blocked-by task-2,task-4

# task-6 blocks task-7 and task-8
task update task-6 --blocks task-7,task-8
```

### Dependency Chain Example

```
task-1 (Database schema)
  ↓ blocks
task-2 (Implement auth)
  ↓ blocks
task-3 (Write auth tests)
  ↓ blocks
task-4 (Deploy to staging)
```

Create this chain:
```bash
task update task-2 --blocked-by task-1
task update task-3 --blocked-by task-2
task update task-4 --blocked-by task-3
```

---

## Status Management

### Status Workflow

```
pending → in_progress → completed
   ↓
 (never complete directly from pending; mark in_progress first)
```

### Mark Task In Progress

```bash
task update task-3 --status in_progress
```

Use when:
- Starting active work on the task
- Task is currently being worked on
- Owner is actively implementing/testing

### Complete a Task

```bash
task update task-3 --status completed
```

Use when:
- All acceptance criteria met
- Testing passed (if applicable)
- Owner confirms task is done
- Ready for review/merge

### Delete a Task

```bash
task update task-3 --status deleted
```

Use when:
- Task is no longer relevant
- Duplicate of another task
- Out of scope
- Superseded by newer task

---

## Ownership & Assignment

### Assign Task to Owner

```bash
task update task-3 --owner alice
```

Use real names, email, or agent IDs:
- `alice`, `bob`, `claude-3` ✅
- `Alice Smith <alice@company.com>` ✅
- `npl-tdd-coder` (agent) ✅

### Unassign Task

```bash
task update task-3 --owner unassigned
```

Or leave owner empty:
```bash
task update task-3 --owner ""
```

### View Tasks by Owner

```bash
# My tasks
task list --owner $(whoami)

# Unassigned tasks
task list --owner unassigned

# Alice's tasks
task list --owner alice

# Overdue tasks assigned to Alice
task list --owner alice --overdue
```

---

## Deadlines & Timeline

### Set Deadline

```bash
# Set specific date (ISO format: YYYY-MM-DD)
task update task-3 --deadline 2026-02-15

# Set deadline relative to today
task update task-3 --deadline +7d    # 7 days from now
task update task-3 --deadline +2w    # 2 weeks from now
task update task-3 --deadline +1m    # 1 month from now
```

### View Timeline

```bash
# Tasks due this week
task list --due-soon

# All overdue tasks
task list --overdue

# Tasks due in specific date range
task list --deadline-range 2026-02-01 2026-02-28

# Show with timeline (created, deadline, completed)
task list --with-timeline
```

### Timeline Example

```
task-1  Add auth         pending    created: 2026-01-28  deadline: 2026-02-10
task-2  Fix login        in_progress created: 2026-01-29  deadline: 2026-02-12  completed: (in progress)
task-3  Optimize query   pending    created: 2026-01-30  deadline: 2026-02-15
```

---

## Metadata & Custom Fields

### Add Metadata

```bash
# Single metadata field
task create \
  --subject "Refactor authentication" \
  --metadata priority=high

# Multiple metadata fields
task create \
  --subject "Refactor authentication" \
  --metadata priority=high,component=auth,story=US-001,epic=E-003
```

### Update Metadata

```bash
# Add/update fields
task update task-3 --metadata priority=urgent,component=payment

# Remove a field (set to null)
task update task-3 --metadata priority=null
```

### Filter by Metadata

```bash
# High-priority tasks
task list --metadata priority=high

# Auth component tasks
task list --metadata component=auth

# Multiple metadata filters (AND)
task list --metadata priority=high,component=auth
```

### Common Metadata Fields

| Field | Values | Example |
|-------|--------|---------|
| `priority` | low, medium, high, urgent | `--metadata priority=high` |
| `component` | auth, payment, ui, api, etc | `--metadata component=auth` |
| `story` | US-001, US-002, etc | `--metadata story=US-001` |
| `epic` | E-001, E-002, etc | `--metadata epic=E-003` |
| `effort` | xs, s, m, l, xl | `--metadata effort=m` |
| `type` | bug, feature, refactor, test | `--metadata type=bug` |

---

## Advanced Workflows

### Create a Sprint

```bash
# Create sprint task
task create \
  --subject "Sprint 5 (Feb 10-21)" \
  --description "Sprint planning and delivery for feature X" \
  --deadline 2026-02-21 \
  --metadata sprint=5,type=sprint

# Create sub-tasks
task create \
  --subject "Add user profile page" \
  --description "Profile editing, avatar upload, bio" \
  --metadata sprint=5,story=US-015 \
  --blocked-by sprint-5-task-id

task create \
  --subject "Write profile tests" \
  --description "Unit and integration tests" \
  --metadata sprint=5,story=US-015 \
  --blocked-by profile-feature-task-id
```

### Create Epic with Stories

```bash
# Create epic
task create \
  --subject "Complete payment system" \
  --description "Full payment flow: checkout, processing, webhooks" \
  --metadata epic=E-001,type=epic \
  --deadline 2026-03-15

# Create story 1
task create \
  --subject "Design checkout flow" \
  --metadata epic=E-001,story=US-201

# Create story 2
task create \
  --subject "Implement payment gateway" \
  --metadata epic=E-001,story=US-202 \
  --blocked-by design-task-id

# Create story 3
task create \
  --subject "Set up webhook handlers" \
  --metadata epic=E-001,story=US-203 \
  --blocked-by payment-task-id
```

### View Epic Progress

```bash
# Show all tasks in epic E-001
task list --metadata epic=E-001

# Show status breakdown
task list --metadata epic=E-001 --with-status-summary
```

### Bulk Status Update

```bash
# Mark all pending tasks in a sprint as complete
task update --metadata sprint=5 --status completed

# Start all high-priority unassigned tasks
task update --metadata priority=high --owner unassigned --status in_progress
```

---

## Reporting & Analysis

### Task Status Summary

```bash
task list --summary
```

**Output:**
```
Status Summary:
├── Pending:      15 tasks (avg priority: medium)
├── In Progress:   5 tasks (avg priority: high)
├── Completed:    42 tasks (avg completion: 3.2d)
└── Overdue:       2 tasks
```

### Team Workload

```bash
task list --by-owner
```

**Output:**
```
Owner         Pending  In Progress  Completed  Load
────────────────────────────────────────────────────
alice            3          2          18      Medium
bob              5          1          12      Medium
charlie          0          3           8      High
unassigned       7          0           0       (waiting)
```

### Burndown Chart

```bash
task list --burndown
```

**Output:**
```
Sprint 5 Burndown (Feb 10-21):
Days Remaining    Tasks Remaining
    11                 15 ●
    10                 13 ●
     9                 12 ●
     8                 11 ●
     7                 10 ●
     6                  8 ●
     5                  6 ●
     4                  4 ●
     3                  2 ●
     2                  1 ●
     1                  0 ✓
```

### Velocity Report

```bash
task list --velocity
```

**Output:**
```
Velocity (last 4 sprints):
Sprint 5: 15 tasks completed
Sprint 4: 18 tasks completed
Sprint 3: 12 tasks completed
Sprint 2:  9 tasks completed
Average:  13.5 tasks/sprint
Trend:    ↑ Improving
```

---

## Common Patterns

### "I don't know what to work on"

```bash
# Show available (unblocked, unassigned) high-priority tasks
task list --status pending --owner unassigned --metadata priority=high

# Show available auth tasks
task list --status pending --owner unassigned --metadata component=auth

# Show tasks due soon
task list --due-soon --owner unassigned
```

### "What's blocking me?"

```bash
# Show what blocks task-5
task list --blocked-by task-5

# Show all blocking relationships for task-5
task get task-5 | grep -A5 "Blocked By:"
```

### "What am I responsible for?"

```bash
# My in-progress tasks
task list --owner alice --status in_progress

# My pending tasks
task list --owner alice --status pending

# My overdue tasks
task list --owner alice --overdue
```

### "Update multiple tasks at once"

```bash
# Mark all sprint 5 tasks as completed
task update --metadata sprint=5 --status completed

# Reassign all overdue payment tasks to bob
task update --metadata component=payment --overdue --owner bob

# Set deadline for all unassigned high-priority tasks
task update --owner unassigned --metadata priority=high --deadline +3d
```

### "I completed a task that was blocking others"

```bash
# Mark task-2 complete
task update task-2 --status completed

# View newly unblocked tasks
task list --blocked-by task-2
```

---

## Best Practices

### Task Creation

1. **Use imperative subjects** – "Add", "Fix", "Refactor", not "Feature", "Bug"
2. **Include context** – Why does this matter? What does it enable?
3. **Write clear acceptance criteria** – How do you know it's done?
4. **Link related tasks** – Use blockedBy/blocks for dependencies
5. **Set realistic deadlines** – Consider dependencies and owner capacity

### Status Updates

1. **Always move to in_progress before working** – Signals active work
2. **Set owner before marking in_progress** – Clarity on who's doing it
3. **Only mark complete when criteria met** – Don't mark done prematurely
4. **Delete duplicate tasks** – Keep task list clean

### Ownership

1. **Assign before starting work** – Don't hoard unassigned tasks
2. **Reassign if blocked** – Tell the owner if you're stuck
3. **Unassign if stopping work** – Let others pick it up
4. **One owner per task** – Clear accountability

### Dependencies

1. **Keep chains shallow** – Long chains hard to manage (max 4-5 deep)
2. **Only block when truly dependent** – Not every task needs blocking
3. **Verify deadlines respect dependencies** – downstream task deadline > upstream
4. **Document why task is blocked** – In the description

### Metadata

1. **Consistent field names** – "component=auth" not "comp=authentication"
2. **Use predefined values** – Enables filtering and reporting
3. **Link to stories/epics** – `story=US-001`, `epic=E-005`
4. **Tag effort estimates** – `effort=m` helps with planning

---

## Troubleshooting

### "Task deadline passed"

```bash
# Find all overdue tasks
task list --overdue

# Update deadline
task update task-3 --deadline 2026-02-20

# Or if task is complete
task update task-3 --status completed
```

### "Task is blocked but blocker is completed"

```bash
# Remove the blocked-by relationship
task update task-5 --blocked-by ""

# Or re-check the blocker
task get task-2  # Verify it's actually completed
```

### "Lost track of what I'm doing"

```bash
# See your current tasks
task list --owner $(whoami) --status in_progress

# See what you should do next
task list --owner $(whoami) --status pending --deadline-before +7d
```

### "Task has wrong owner"

```bash
# Reassign to correct person
task update task-3 --owner alice
```

### "Can't complete task due to dependency"

```bash
# Check what's blocking
task get task-5 | grep "Blocked By"

# If blocked task is stale, mark it complete
task update task-2 --status completed

# Or update the blocking task with new deadline
task update task-2 --deadline 2026-02-10
```

---

## CLI Syntax Reference

```bash
# Create
task create \
  --subject "Task title" \
  --description "Detailed description..." \
  --owner alice \
  --deadline 2026-02-15 \
  --metadata key1=value1,key2=value2 \
  --blocked-by task-1,task-2 \
  --blocks task-5,task-6

# Read
task get task-3
task list [filters]
task list --status pending
task list --owner alice
task list --search keyword
task list --metadata priority=high
task list --overdue
task list --deadline-before 2026-02-15

# Update
task update task-3 \
  --subject "New title" \
  --description "New description" \
  --status in_progress \
  --owner bob \
  --deadline 2026-02-20 \
  --metadata priority=urgent \
  --blocked-by task-1 \
  --blocks task-5

# Bulk update
task update --metadata sprint=5 --status completed
task update --owner unassigned --metadata priority=high --owner bob

# Delete
task update task-3 --status deleted
```

---

## Integration with Project Workflow

Tasks connect to other project components:

- **Linked to User Stories** – `--metadata story=US-001`
- **Grouped into Epics** – `--metadata epic=E-005`
- **Grouped into Sprints** – `--metadata sprint=5`
- **Assigned to Agents** – `--owner npl-tdd-coder`
- **Tracked in PRDs** – Reference in `docs/PRDs/`
- **Status in docs** – See `docs/implementation-tracker.yaml`

---

## Examples

### Full Task Lifecycle

```bash
# 1. Create task
task create \
  --subject "Implement two-factor authentication" \
  --description "Add TOTP-based 2FA to user account settings.

Requirements:
- Generate QR code for authenticator apps
- Validate TOTP codes on login
- Recovery codes for account recovery

Acceptance Criteria:
- ✓ TOTP codes validated in <100ms
- ✓ Recovery codes work after password reset
- ✓ Tests cover success and failure paths" \
  --metadata priority=high,component=auth,story=US-089

# Result: task-127

# 2. Assign and set deadline
task update task-127 \
  --owner alice \
  --deadline +10d

# 3. Mark in progress when starting
task update task-127 --status in_progress

# 4. Complete when done
task update task-127 --status completed

# 5. View completion
task get task-127
```

### Sprint Planning

```bash
# Create sprint epic
task create \
  --subject "Sprint 6 Execution" \
  --description "Feature complete and tested for release" \
  --metadata sprint=6,type=sprint \
  --deadline 2026-02-28

# Create dependent features
task create \
  --subject "Payment webhook validation" \
  --metadata sprint=6,priority=high \
  --blocked-by sprint-6-epic-id

task create \
  --subject "Payment webhook tests" \
  --metadata sprint=6,priority=high \
  --blocked-by webhook-validation-task-id

# View sprint progress
task list --metadata sprint=6
task list --metadata sprint=6 --with-status-summary
```

---

## Version & Updates

- **Last Updated:** 2026-02-02
- **Supported Task CLI:** v1.0+
- **Status:** Production ready

---

*Start with `task list` to see current state. Use `--help` flag on any command for syntax details.*
