# npl-persona - Detailed Reference

Comprehensive persona management tool for NPL with multi-tiered hierarchical loading.

## Table of Contents

- [Architecture](#architecture)
- [Environment Variables](#environment-variables)
- [Search Path Resolution](#search-path-resolution)
- [File Structure](#file-structure)
- [Commands Reference](#commands-reference)
  - [Lifecycle Commands](#lifecycle-commands)
  - [Journal Commands](#journal-commands)
  - [Task Commands](#task-commands)
  - [Knowledge Base Commands](#knowledge-base-commands)
  - [Health and Maintenance](#health-and-maintenance)
  - [Collaboration](#collaboration)
  - [Team Management](#team-management)
  - [Analytics](#analytics)
- [Dependency Tracking](#dependency-tracking)
- [Exit Codes](#exit-codes)
- [Implementation Details](#implementation-details)
- [Edge Cases and Limitations](#edge-cases-and-limitations)
- [Integration Patterns](#integration-patterns)

---

## Architecture

The tool is implemented as a Python 3 script using the `NPLPersona` class. Key components:

```
NPLPersona
├── Search path resolution (project -> user -> system)
├── Persona lifecycle management
├── Journal operations
├── Task tracking
├── Knowledge base management
├── Team collaboration
└── Analytics and reporting
```

Dependencies: `os`, `sys`, `argparse`, `json`, `yaml`, `shutil`, `re`, `pathlib`, `datetime`, `collections`, `tarfile`

---

## Environment Variables

| Variable | Description | Default Behavior |
|----------|-------------|------------------|
| `NPL_PERSONA_DIR` | Override base path for persona definitions | Falls back to hierarchical search |
| `NPL_PERSONA_TEAMS` | Override path for team definitions | Falls back to hierarchical search |
| `NPL_PERSONA_SHARED` | Override path for shared resources | Falls back to hierarchical search |
| `DEBUG` | Enable debug output with stack traces | Disabled |

When environment variables are set, they take **highest priority** in the search order.

---

## Search Path Resolution

The tool searches paths in priority order. First match wins.

### Persona Search Paths

1. `$NPL_PERSONA_DIR` (if set)
2. `./.npl/personas` (project)
3. `~/.npl/personas` (user)
4. System path (platform-specific)

### Team Search Paths

1. `$NPL_PERSONA_TEAMS` (if set)
2. `./.npl/teams` (project)
3. `~/.npl/teams` (user)
4. System path (platform-specific)

### Shared Resource Paths

1. `$NPL_PERSONA_SHARED` (if set)
2. `./.npl/shared` (project)
3. `~/.npl/shared` (user)
4. System path (platform-specific)

### Platform-Specific System Paths

| Platform | Personas | Teams | Shared |
|----------|----------|-------|--------|
| Linux | `/etc/npl/personas/` | `/etc/npl/teams/` | `/etc/npl/shared/` |
| macOS | `/Library/Application Support/npl/personas/` | `/Library/Application Support/npl/teams/` | `/Library/Application Support/npl/shared/` |
| Windows | `%PROGRAMDATA%\npl\personas\` | `%PROGRAMDATA%\npl\teams\` | `%PROGRAMDATA%\npl\shared\` |

---

## File Structure

### Mandatory Persona Files

Each persona requires four files in the same directory:

| File | Template | Purpose |
|------|----------|---------|
| Definition | `{id}.persona.md` | Core identity, role, background, traits, voice signature |
| Journal | `{id}.journal.md` | Chronological experiences, reflections, relationship evolution |
| Tasks | `{id}.tasks.md` | Active tasks, responsibilities, goals, OKRs |
| Knowledge Base | `{id}.knowledge-base.md` | Domain expertise, learning paths, knowledge gaps |

### Team Files

| File | Template | Purpose |
|------|----------|---------|
| Definition | `{team_id}.team.md` | Team composition, purpose, collaboration patterns |
| History | `{team_id}.history.md` | Interaction log, milestones, evolution |

### Generated Files

| File | When Created | Purpose |
|------|--------------|---------|
| `{id}.journal.{YYYYMMDD}.md` | `journal archive` | Archived journal entries |
| `{id}-{period}-{date}.{format}` | `report` | Generated reports |
| `team-knowledge-{team_id}.md` | `team synthesize` | Team knowledge synthesis |
| `personas-backup-{timestamp}.tar.gz` | `backup` | Compressed backup archive |

---

## Commands Reference

### Lifecycle Commands

#### init - Create New Persona

```bash
npl-persona init <persona_id> [options]
```

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `--role` | string | "specialist" | Role/title for the persona |
| `--scope` | choice | project | Where to create: `project`, `user`, `system` |
| `--from-template` | choice | - | Copy from existing persona in `system` or `user` scope |

**Behavior:**

1. Validates persona doesn't already exist at target path
2. If `--from-template` specified, copies all four files from source
3. Otherwise, generates all four mandatory files from templates
4. Templates include NPL markup, placeholder sections, and role-specific content

**Generated Definition Template Structure:**

```markdown
⌜persona:{id}|{role}|NPL@1.0⌝
# {Name}
`{role}` `expertise`

## Identity
## Voice Signature
## Expertise Graph
## Relationships
## Memory Hooks
⌞persona:{id}⌟
```

**Examples:**

```bash
# Create project-level architect persona
npl-persona init sarah-architect --role "Software Architect"

# Create user-level persona from system template
npl-persona init my-reviewer --scope user --from-template system

# Create system-level shared persona (requires permissions)
npl-persona init qa-engineer --role "QA Engineer" --scope system
```

#### get - Fetch Persona Files

```bash
npl-persona get <persona_id> [options]
```

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `--files` | string | all | Comma-separated: `definition`, `journal`, `tasks`, `knowledge`, or `all` |
| `--skip` | list | [] | Persona IDs to skip if already loaded |

**Output Format:**

Files are output with header and separator:
```
# {file_type}:{persona_id}:
{file_content}␜
```

After successful load, outputs tracking flags:
```markdown
# Flag Update

```🏳️
@npl.personas.loaded+="{persona_id}"
```
```

**Examples:**

```bash
# Load all persona files
npl-persona get sarah-architect

# Load only definition and tasks
npl-persona get sarah-architect --files definition,tasks

# Load with skip tracking (prevents reloading)
npl-persona get sarah-architect --skip sarah-architect

# Load multiple specific files
npl-persona get sarah-architect --files definition,journal,knowledge
```

#### list - List Available Personas

```bash
npl-persona list [options]
```

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `--scope` | choice | all | Filter: `project`, `user`, `system`, `all` |
| `--verbose`, `-v` | flag | false | Show file status details |

**Output Formats:**

Standard:
```
Project personas:
  - sarah-architect
  - bob-developer

User personas:
  - personal-assistant
```

Verbose:
```
Project personas:
  - sarah-architect [definition:✓, journal:✓, tasks:✓, knowledge:✓]
  - bob-developer [definition:✓, journal:✗, tasks:✓, knowledge:✓]
```

**Examples:**

```bash
# List all personas across scopes
npl-persona list

# List only project personas with file status
npl-persona list --scope project --verbose

# List system personas
npl-persona list --scope system
```

#### which - Locate Persona

```bash
npl-persona which <persona_id>
```

Displays the resolved location and scope of a persona.

**Output:**
```
Found: /path/to/{persona_id}.persona.md (project scope)
```

Or if not found:
```
Persona '{persona_id}' not found in search paths
```

#### remove - Delete Persona

```bash
npl-persona remove <persona_id> [options]
```

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `--scope` | choice | - | Only delete from specified scope |
| `--force`, `-f` | flag | false | Skip confirmation prompt |

**Behavior:**

1. Locates persona using search path resolution
2. If `--scope` specified, verifies persona is in that scope
3. Prompts for confirmation (unless `--force`)
4. Deletes all four mandatory files

**Examples:**

```bash
# Remove with confirmation
npl-persona remove old-persona

# Force remove from project scope only
npl-persona remove old-persona --scope project --force
```

---

### Journal Commands

```bash
npl-persona journal <persona_id> <action> [options]
```

#### journal add

Add a new journal entry.

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `--message` | string | - | Journal entry message |
| `--interactive`, `-i` | flag | false | Read message from stdin until EOF |

**Entry Format:**

```markdown
### {YYYY-MM-DD} - {YYYYMMDD-HHMMSS}
**Context**: {message}
**Participants**: TBD
**My Role**: TBD

<npl-reflection>
{message}
</npl-reflection>

**Outcomes**: TBD
**Growth**: TBD

---
```

Entries are inserted after `## Recent Interactions` in reverse chronological order.

**Examples:**

```bash
# Add with inline message
npl-persona journal sarah-architect add --message "Reviewed API design patterns"

# Add interactively (multiline)
npl-persona journal sarah-architect add -i
# Type entry, then Ctrl+D (Unix) or Ctrl+Z (Windows)
```

#### journal view

View recent journal entries.

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `--entries` | int | 5 | Number of entries to display |
| `--since` | date | - | Filter entries from date (YYYY-MM-DD) |

**Examples:**

```bash
# View last 5 entries
npl-persona journal sarah-architect view

# View last 10 entries
npl-persona journal sarah-architect view --entries 10

# View entries since specific date
npl-persona journal sarah-architect view --since 2024-06-01
```

#### journal archive

Archive journal entries before a specified date.

**Options:**

| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `--before` | date | Yes | Archive entries before date (YYYY-MM-DD) |

**Behavior:**

1. Parses all journal entries by date
2. Moves entries before cutoff to `{id}.journal.{YYYYMMDD}.md`
3. Updates main journal file to keep only recent entries

**Examples:**

```bash
# Archive entries older than Jan 1, 2024
npl-persona journal sarah-architect archive --before 2024-01-01
```

---

### Task Commands

```bash
npl-persona task <persona_id> <action> [task_description] [options]
```

#### task add

Add a new task.

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `--due` | date | +7 days | Due date (YYYY-MM-DD) |
| `--priority` | choice | med | Priority: `high`, `med`, `low` |

**Task Row Format:**

```markdown
| {description} | 🔄 In Progress | @{persona_id} | {due_date} |
```

**Examples:**

```bash
# Add task with defaults
npl-persona task sarah-architect add "Review microservices design"

# Add high-priority task with due date
npl-persona task sarah-architect add "Security audit" --priority high --due 2024-12-15
```

#### task update

Update task status.

**Options:**

| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `--status` | choice | Yes | New status: `pending`, `in-progress`, `blocked`, `completed` |

**Status Icons:**

| Status | Icon |
|--------|------|
| pending | ⏸️ Pending |
| in-progress | 🔄 In Progress |
| blocked | 🚫 Blocked |
| completed | ✅ Complete |

**Examples:**

```bash
# Update status (partial match on description)
npl-persona task sarah-architect update "Review microservices" --status in-progress

# Mark as blocked
npl-persona task sarah-architect update "Security audit" --status blocked
```

#### task complete

Mark task as completed (shorthand for `update --status completed`).

**Options:**

| Option | Type | Description |
|--------|------|-------------|
| `--note` | string | Completion note (currently unused in implementation) |

**Examples:**

```bash
npl-persona task sarah-architect complete "Review microservices"
```

#### task list

List tasks for persona.

**Options:**

| Option | Type | Description |
|--------|------|-------------|
| `--filter` | string | Filter by status keyword |

**Output Format:**

```
# Tasks for {persona_id} ({count} tasks)

Task                                     Status               Due
------------------------------------------------------------------------
Review microservices design              🔄 In Progress       2024-12-15
Security audit                           🚫 Blocked           2024-12-20
```

**Examples:**

```bash
# List all tasks
npl-persona task sarah-architect list

# List only pending tasks
npl-persona task sarah-architect list --filter pending
```

#### task remove

Remove a task by pattern match.

**Examples:**

```bash
npl-persona task sarah-architect remove "Security audit"
```

---

### Knowledge Base Commands

```bash
npl-persona kb <persona_id> <action> [topic] [options]
```

#### kb add

Add knowledge entry.

**Options:**

| Option | Type | Description |
|--------|------|-------------|
| `--content` | string | Knowledge content |
| `--source` | string | Source reference |

**Entry Format:**

```markdown
### {YYYY-MM-DD} - {topic}
**Source**: {source or "Direct experience"}
**Learning**: {content or "TBD"}
**Integration**: TBD - How this connects to existing knowledge
**Application**: TBD - Can be used for specific use cases
```

**Examples:**

```bash
# Add with source
npl-persona kb sarah-architect add "API Design" \
  --content "REST APIs should use noun-based endpoints" \
  --source "API Design Guidelines v2"

# Add minimal entry
npl-persona kb sarah-architect add "GraphQL"
```

#### kb search

Search knowledge base.

**Options:**

| Option | Type | Description |
|--------|------|-------------|
| `--domain` | string | Restrict search to specific domain section |

**Examples:**

```bash
# Search all knowledge
npl-persona kb sarah-architect search "REST"

# Search within domain
npl-persona kb sarah-architect search "REST" --domain api-design
```

#### kb get

Retrieve specific knowledge topic.

**Examples:**

```bash
npl-persona kb sarah-architect get "API Design"
```

#### kb update-domain

Update domain expertise confidence level.

**Options:**

| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `--confidence` | int | Yes | Confidence level 0-100 |

**Behavior:**

1. Finds domain section by name
2. Updates `confidence` value in ````knowledge` block
3. Updates `last_updated` timestamp
4. If domain not found, creates new domain section

**Depth Mapping:**

| Confidence | Depth |
|------------|-------|
| 80-100% | expert |
| 50-79% | working |
| 0-49% | surface |

**Examples:**

```bash
# Update existing domain
npl-persona kb sarah-architect update-domain "Architecture" --confidence 85

# Create new domain with confidence
npl-persona kb sarah-architect update-domain "Machine Learning" --confidence 40
```

---

### Health and Maintenance

#### health - Check File Health

```bash
npl-persona health [persona_id] [options]
```

**Options:**

| Option | Type | Description |
|--------|------|-------------|
| `--all` | flag | Check all personas |
| `--verbose`, `-v` | flag | Show detailed information |

**Output Format:**

```
PERSONA: sarah-architect
├── ✅ sarah-architect.persona.md (12.5KB, 3d ago)
├── ✅ sarah-architect.journal.md (45.2KB, 1d ago)
├── ⚠️ sarah-architect.tasks.md (2.1KB, 5d ago)
├── ✅ sarah-architect.knowledge-base.md (28.7KB, 2d ago)
└── INTEGRITY: 95% healthy
    ISSUES: None
```

**Health Score Calculation:**

- Base: (files present / 4) * 100
- Penalty: -5 per issue
- Warnings: Journal > 100KB, Knowledge > 500KB

**Examples:**

```bash
# Check single persona
npl-persona health sarah-architect

# Check all with details
npl-persona health --all --verbose
```

#### sync - Validate and Synchronize

```bash
npl-persona sync <persona_id> [options]
```

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `--validate` | flag | true | Validate file structure |
| `--no-validate` | flag | - | Skip validation |

**Validation Checks:**

1. All four mandatory files exist
2. Definition file contains proper NPL header (`⌜persona:{id}`)
3. Definition file references journal, tasks, and knowledge-base files

**Examples:**

```bash
# Sync with validation
npl-persona sync sarah-architect

# Sync without validation
npl-persona sync sarah-architect --no-validate
```

#### backup - Backup Persona Data

```bash
npl-persona backup [persona_id] [options]
```

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `--all` | flag | - | Backup all personas |
| `--output` | path | ./backups | Output directory |

**Output:**

Creates `personas-backup-{YYYYMMDD-HHMMSS}.tar.gz` containing:
```
{persona_id}/
├── {persona_id}.persona.md
├── {persona_id}.journal.md
├── {persona_id}.tasks.md
└── {persona_id}.knowledge-base.md
```

**Examples:**

```bash
# Backup single persona
npl-persona backup sarah-architect

# Backup all personas to custom location
npl-persona backup --all --output /backups/npl
```

---

### Collaboration

#### share - Share Knowledge Between Personas

```bash
npl-persona share <from_persona> <to_persona> [options]
```

**Options:**

| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `--topic` | string | Yes | Knowledge topic to share |
| `--translate` | flag | - | Add attribution prefix |

**Behavior:**

1. Extracts topic section from source knowledge base
2. If `--translate`, prepends "(Shared from @{source})"
3. Adds entry to target's "Recently Acquired Knowledge" section

**Examples:**

```bash
# Share knowledge with translation
npl-persona share sarah-architect bob-developer \
  --topic "API Design" \
  --translate

# Direct share
npl-persona share sarah-architect carol-tester --topic "Testing Patterns"
```

---

### Team Management

```bash
npl-persona team <action> <team_id> [persona_id] [options]
```

#### team create

Create a new team.

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `--members` | string | - | Comma-separated persona IDs |
| `--scope` | choice | project | Scope: `project`, `user`, `system` |

**Files Created:**

1. `{team_id}.team.md` - Team definition
2. `{team_id}.history.md` - Collaboration history

**Examples:**

```bash
# Create team with members
npl-persona team create backend-team \
  --members "sarah-architect,bob-developer,carol-tester"

# Create empty team
npl-persona team create frontend-team --scope user
```

#### team add

Add persona to existing team.

**Examples:**

```bash
npl-persona team add backend-team dave-devops
```

#### team list

List team members.

**Options:**

| Option | Type | Description |
|--------|------|-------------|
| `--verbose`, `-v` | flag | Show detailed member info |

**Output Formats:**

Standard:
```
# Team: Backend Team
**Scope**: project
**Members**: 3

  - @sarah-architect (Software Architect)
  - @bob-developer (Developer)
  - @carol-tester (QA Engineer)
```

Verbose:
```
Persona                   Role                 Joined       Status
-------------------------------------------------------------------
@sarah-architect          Software Architect   2024-06-01   Active
@bob-developer            Developer            2024-06-01   Active
```

#### team synthesize

Generate unified knowledge synthesis from all team members.

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `--output` | path | ./.npl/shared/team-knowledge-{team_id}.md | Output file |

**Output Sections:**

1. Team Expertise Matrix
2. Knowledge Distribution (per domain)
3. Knowledge Gaps (single points of knowledge)
4. Team Strengths
5. Recommendations

**Examples:**

```bash
# Synthesize to default location
npl-persona team synthesize backend-team

# Synthesize to custom file
npl-persona team synthesize backend-team --output ./docs/team-knowledge.md
```

#### team matrix

Display team expertise matrix.

**Output Format:**

```
# Team Expertise Matrix: Backend Team

Domain                         Expert               Proficient           Learning
------------------------------------------------------------------------------------------
API Design                     @sarah-architect     @bob-developer       -
Testing                        @carol-tester        -                    @bob-developer
```

**Expertise Levels:**

| Level | Confidence |
|-------|------------|
| Expert | >= 80% |
| Proficient | 50-79% |
| Learning | < 50% |

#### team analyze

Analyze team collaboration patterns.

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `--period` | int | 30 | Analysis period in days |

**Analysis Outputs:**

- Total interactions
- Active members count
- Member activity (bar chart)
- Top collaboration pairs
- Frequently discussed topics
- Team health metrics (collaboration index)

**Examples:**

```bash
# 30-day analysis
npl-persona team analyze backend-team

# 90-day analysis with verbose
npl-persona team analyze backend-team --period 90 --verbose
```

---

### Analytics

#### analyze - Analyze Persona Data

```bash
npl-persona analyze <persona_id> [options]
```

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `--type` | choice | journal | Analysis type: `journal`, `tasks` |
| `--period` | int | 30 | Period in days |

**Journal Analysis Outputs:**

- Interaction frequency
- Top collaborators (by @mention count)
- Mood trajectory (keyword-based sentiment)
- Topics discussed (capitalized term frequency)
- Learning velocity (concepts/week)

**Task Analysis Outputs:**

- Total tasks
- Status breakdown (completed, in-progress, blocked)
- Completion rate percentage
- Average completion time (estimate)

**Examples:**

```bash
# Analyze journal over 30 days
npl-persona analyze sarah-architect --type journal

# Analyze tasks over 90 days
npl-persona analyze sarah-architect --type tasks --period 90
```

#### report - Generate Comprehensive Report

```bash
npl-persona report <persona_id> [options]
```

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `--format` | choice | md | Output format: `md`, `json`, `html` |
| `--period` | choice | month | Period: `week`, `month`, `quarter`, `year` |

**Period Days:**

| Period | Days |
|--------|------|
| week | 7 |
| month | 30 |
| quarter | 90 |
| year | 365 |

**Report Sections:**

1. Executive Summary
2. Health Status
3. Activity Summary
4. Recommendations

**Output File:** `{persona_id}-{period}-{YYYY-MM-DD}.{format}`

**Examples:**

```bash
# Monthly markdown report
npl-persona report sarah-architect

# Quarterly HTML report
npl-persona report sarah-architect --format html --period quarter
```

---

## Dependency Tracking

When loading personas with `get`, the tool outputs flag updates:

```markdown
# Flag Update

```🏳️
@npl.personas.loaded+="sarah-architect"
```
```

Use `--skip` on subsequent calls to prevent reloading:

```bash
# First load
npl-persona get sarah-architect
# Output includes: @npl.personas.loaded+="sarah-architect"

# Subsequent loads
npl-persona get sarah-architect --skip sarah-architect
# Skips loading if in skip list
```

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error (persona not found, invalid arguments, file error) |
| 130 | Cancelled by user (Ctrl+C) |

---

## Implementation Details

### Pattern Matching

- Task operations use substring matching on task descriptions
- Knowledge topic lookups use case-insensitive regex
- Journal entry parsing uses regex: `###\s+(\d{4}-\d{2}-\d{2})\s+-\s+([^\n]+)(.*?)(?=###|\Z)`

### File Modification Strategy

1. Read entire file content
2. Parse/split by section markers
3. Modify relevant section
4. Write entire file back

### Sentiment Analysis

Simple keyword-based approach:

**Positive keywords:** success, learned, achieved, completed, great, excellent
**Negative keywords:** failed, blocked, difficult, problem, issue, error

Formula: `(positive_count / (positive + negative)) * 100`

### Collaboration Index

```
actual_pairs = unique collaborating pairs
possible_pairs = n * (n-1) / 2
index = (actual / possible) * 100
```

---

## Edge Cases and Limitations

### Known Limitations

1. **Interactive mode** (`-i`) requires terminal stdin; not suitable for piped input
2. **Task matching** uses simple substring; may match unintended tasks
3. **Knowledge search** is line-based; won't find multi-line content
4. **Sentiment analysis** is keyword-based; not context-aware
5. **Report format** only `md` is fully implemented; `json` and `html` generate markdown
6. **Backup** creates flat archive; doesn't preserve scope hierarchy

### Edge Cases

| Scenario | Behavior |
|----------|----------|
| Missing mandatory file | Commands fail gracefully with specific error |
| Empty journal | `view` and `archive` succeed with "no entries" message |
| Task table not found | `task add` falls back to appending |
| Domain not in KB | `kb update-domain` creates new domain section |
| Team member not found | Warning printed, member added anyway |
| Circular share | No prevention; may cause duplicate entries |

### File Size Considerations

| File | Warning Threshold | Recommendation |
|------|-------------------|----------------|
| Journal | > 100KB | Archive old entries |
| Knowledge Base | > 500KB | Split into domains |

---

## Integration Patterns

### With npl-load

```bash
# Load persona after loading NPL components
npl-load c "syntax,agent" --skip "" && \
  npl-persona get sarah-architect --files definition
```

### In Agent Prompts

```markdown
⌜agent|NPL@1.0⌝
# Task execution with persona context

## Setup
npl-persona get sarah-architect --files definition,tasks

## During execution
npl-persona journal sarah-architect add --message "Completed task X"
npl-persona task sarah-architect complete "Task X"
⌞agent⌟
```

### CI/CD Integration

```bash
# Health check in CI pipeline
npl-persona health --all || exit 1

# Generate reports for documentation
npl-persona report sarah-architect --format md --period month
```

### Backup Automation

```bash
# Daily backup cron job
0 0 * * * npl-persona backup --all --output /backups/npl/$(date +\%Y-\%m)
```

---

## See Also

- [npl-persona Quick Reference](./npl-persona.md) - Concise command summary
- [npl-load](./npl-load.md) - Load NPL components and metadata
- [NPL Agent Specification](../npl/agent.md) - Agent definition format
