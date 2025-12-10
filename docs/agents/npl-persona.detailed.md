# npl-persona Detailed Reference

Complete documentation for the persona-based collaboration agent and CLI management tool.

## Overview

The `npl-persona` system provides two distinct capabilities:

1. **Agent**: Simulates persona-driven interactions with persistent state for code reviews, architecture discussions, and team collaborations
2. **CLI Tool**: Manages persona lifecycle, files, teams, and analytics

Both components share a hierarchical file-backed state system that maintains persona definitions, journals, tasks, and knowledge bases.

---

## Table of Contents

- [Environment Variables](#environment-variables)
- [File System Structure](#file-system-structure)
- [Persona Files](#persona-files)
- [Agent Usage](#agent-usage)
- [CLI Reference](#cli-reference)
- [Team Management](#team-management)
- [Analytics and Reporting](#analytics-and-reporting)
- [Integration Patterns](#integration-patterns)
- [Best Practices](#best-practices)
- [Limitations](#limitations)

---

## Environment Variables

| Variable | Purpose | Fallback Path |
|----------|---------|---------------|
| `$NPL_PERSONA_DIR` | Base path for persona files | `./.npl/personas` -> `~/.npl/personas` -> `/etc/npl/personas/` |
| `$NPL_PERSONA_TEAMS` | Team definitions path | `./.npl/teams` -> `~/.npl/teams` -> `/etc/npl/teams/` |
| `$NPL_PERSONA_SHARED` | Shared resources (relationships, world-state) | `./.npl/shared` -> `~/.npl/shared` -> `/etc/npl/shared/` |

**Resolution Order**: project -> user -> system (first match wins)

---

## File System Structure

```
$NPL_PERSONA_DIR/
├── personas/
│   ├── {persona-id}.persona.md      # Core definition
│   ├── {persona-id}.journal.md      # Experience log
│   ├── {persona-id}.tasks.md        # Active tasks
│   └── {persona-id}.knowledge-base.md
├── teams/
│   ├── {team-id}.team.md            # Team composition
│   └── {team-id}.history.md         # Collaboration history
└── shared/
    ├── relationships.graph.md        # Inter-persona connections
    └── world-state.md                # Shared context
```

---

## Persona Files

### Definition File (`{id}.persona.md`)

Core persona identity, voice, and expertise.

```markdown
⌜persona:{persona-id}|{role}|NPL@1.0⌝
# {Full Name}
`{role}` `{expertise_tags}`

## Identity
- **Role**: {role_title}
- **Experience**: {years} years in {domains}
- **Personality**: {OCEAN_scores}
- **Communication**: {style}

## Voice Signature
```voice
lexicon: [{preferred_terms}]
patterns: [{speech_patterns}]
quirks: [{unique_behaviors}]
```

## Expertise Graph
```knowledge
primary: [{core_competencies}]
secondary: [{supporting_skills}]
boundaries: [{limitations}]
learning: [{growth_areas}]
```

## Relationships
| Persona | Relationship | Dynamics |
|---------|-------------|----------|
| @other-persona | {type} | {style} |

## Memory Hooks
- journal: `./{persona-id}.journal.md`
- tasks: `./{persona-id}.tasks.md`
- knowledge: `./{persona-id}.knowledge-base.md`

⌞persona:{persona-id}⌟
```

### Journal File (`{id}.journal.md`)

Chronological interaction log with reflections.

```markdown
# {persona-id} Journal

## Recent Interactions
### {date} - {session-id}
**Context**: {situation}
**Participants**: @{personas}
**My Role**: {contribution}

<npl-reflection>
{personal_thoughts}
{lessons_learned}
</npl-reflection>

**Outcomes**: {results}
**Growth**: {skills_gained}

---

## Relationship Evolution
| Person | Initial | Current |
|--------|---------|---------|
| @other | {first_impression} | {current_understanding} |

## Personal Development Log
```growth
{date}: Learned {concept} from @{mentor}
{date}: Applied {skill} in {context}
```
```

### Tasks File (`{id}.tasks.md`)

Active tasks, responsibilities, and goals.

```markdown
# {persona-id} Tasks

## Active Tasks
| Task | Status | Owner | Due |
|------|--------|-------|-----|
| {task} | In Progress | @{owner} | {date} |
| {task} | Complete | @{owner} | {date} |

## Role Responsibilities
DAILY: [{routine_tasks}]
WEEKLY: [{reviews}]
PROJECT: [{deliverables}]

## Goals & OKRs
**Objective**: {goal}
- **KR1**: {result} [%]
- **KR2**: {result} [%]
```

### Knowledge Base File (`{id}.knowledge-base.md`)

Domain expertise and acquired knowledge.

```markdown
# {persona-id} Knowledge Base

## Core Domains
### {Domain}
```knowledge
confidence: {0-100}%
depth: {surface|working|expert}
last_updated: {date}
```

**Key Concepts**: [{concepts}]
**Applications**: [{use_cases}]

## Recently Acquired
### {date} - {topic}
**Source**: {origin}
**Learning**: {content}
**Integration**: {connections}

## Knowledge Gaps
KNOWN_UNKNOWNS: [{areas}]
UNCERTAIN_AREAS: [{concepts}]
```

---

## Agent Usage

### Single Persona Invocation

```bash
# Direct invocation
@persona sarah-architect "How would you design the authentication layer?"

# With context specification
@persona mike-backend --context=api-review "Review this endpoint design"

# Reference previous interactions
@persona qa-engineer --journal=last-5 "Follow up on test coverage"
```

### Multi-Persona Collaboration

```bash
# Team discussion
@persona --team=architects "Discuss: microservices vs monolith"

# Panel review
@persona alice-dev,bob-qa,charlie-security "Review: auth PR #482"

# Brainstorming session
@persona --brainstorm design-team "Generate dashboard redesign ideas"

# Debate format
@persona --debate sarah-architect,mike-pragmatist "Event sourcing vs CRUD"
```

### Orchestrated Workflows

```bash
# Sequential collaboration
@persona sarah-architect "Design the system" | \
@persona mike-backend "Implement the design" | \
@persona qa-engineer "Create test plan"

# Parallel analysis
@persona --parallel \
  alice-dev:"Analyze code quality" \
  bob-security:"Check vulnerabilities" \
  charlie-perf:"Profile performance"
```

### Agent Response Format

Single persona responses follow this structure:

```
[@{persona-id}]: {in_character_response}

<npl-reflection>
*Internal thoughts*: {reasoning}
*Feelings*: {emotional_reaction}
*Knowledge applied*: {expertise_used}
</npl-reflection>

**Context Updates**:
- Journal: {summary}
- Tasks: {new_task} | {completed_task}
- Knowledge: {new_learning}
```

---

## CLI Reference

### Persona Lifecycle

#### init - Create New Persona

```bash
npl-persona init <persona_id> [options]

Options:
  --role=<role>           Role/title for the persona
  --scope=<scope>         project|user|system (default: project)
  --from-template=<scope> Copy from existing persona
```

Creates all four mandatory files with role-appropriate templates.

**Example**:
```bash
npl-persona init sarah-architect --role=architect
# Creates:
#   sarah-architect.persona.md
#   sarah-architect.journal.md
#   sarah-architect.tasks.md
#   sarah-architect.knowledge-base.md
```

#### get - Load Persona Files

```bash
npl-persona get <persona_id> [options]

Options:
  --files=<types>   definition|journal|tasks|knowledge|all (default: all)
  --skip=<list>     Skip if already loaded
```

Outputs persona file contents with tracking flags for `npl-load` integration.

**Example**:
```bash
npl-persona get sarah-architect --files=definition,journal
# Output includes: @npl.personas.loaded+="sarah-architect"
```

#### list - List Available Personas

```bash
npl-persona list [options]

Options:
  --scope=<scope>  project|user|system|all (default: all)
  --verbose        Show file status
```

**Example**:
```bash
npl-persona list --scope=project --verbose
# Output:
# Project personas:
#   - sarah-architect [definition:ok, journal:ok, tasks:ok, knowledge:ok]
#   - mike-backend [definition:ok, journal:ok, tasks:missing, knowledge:ok]
```

#### which - Locate Persona

```bash
npl-persona which <persona_id>
```

Shows where a persona is defined in the search path hierarchy.

#### remove - Delete Persona

```bash
npl-persona remove <persona_id> [options]

Options:
  --scope=<scope>  Only delete from specified scope
  --force          Skip confirmation
```

### Journal Operations

```bash
npl-persona journal <persona_id> <action> [options]

Actions:
  add      Add new entry
  view     View recent entries
  archive  Move old entries to archive

Options:
  --message=<text>   Entry message (for add)
  --interactive      Multi-line input mode
  --entries=<n>      Number to view (default: 5)
  --since=<date>     Filter by date (YYYY-MM-DD)
  --before=<date>    Archive before date
```

**Examples**:
```bash
# Add journal entry
npl-persona journal sarah add --message="Learned about GraphQL schema design"

# View last 10 entries
npl-persona journal sarah view --entries=10

# View entries from last week
npl-persona journal sarah view --since=2025-12-03

# Archive old entries
npl-persona journal sarah archive --before=2025-11-01
```

### Task Management

```bash
npl-persona task <persona_id> <action> [options]

Actions:
  add       Create new task
  update    Change task status
  complete  Mark task complete
  list      Show all tasks
  remove    Delete task

Options:
  --due=<date>      Due date (YYYY-MM-DD)
  --priority=<p>    high|med|low (default: med)
  --status=<s>      pending|in-progress|blocked|completed
  --filter=<s>      Filter list by status
  --note=<text>     Completion note
```

**Examples**:
```bash
# Add task with due date
npl-persona task sarah add "Review API design" --due=2025-12-15 --priority=high

# Update task status
npl-persona task sarah update "Review API" --status=in-progress

# Complete task
npl-persona task sarah complete "Review API" --note="Approved with minor changes"

# List blocked tasks
npl-persona task sarah list --filter=blocked
```

### Knowledge Base Operations

```bash
npl-persona kb <persona_id> <action> [options]

Actions:
  add            Add knowledge entry
  search         Search knowledge base
  get            Retrieve specific topic
  update-domain  Update domain confidence

Options:
  --content=<text>     Knowledge content
  --source=<source>    Knowledge source
  --domain=<domain>    Domain filter
  --confidence=<n>     Confidence level 0-100
```

**Examples**:
```bash
# Add knowledge entry
npl-persona kb sarah add "GraphQL" --content="Schema-first API design pattern" --source="Tech talk"

# Search knowledge
npl-persona kb sarah search "API" --domain="Architecture"

# Get specific topic
npl-persona kb sarah get "GraphQL"

# Update domain expertise
npl-persona kb sarah update-domain "Architecture" --confidence=85
```

### Health and Maintenance

#### health - Check File Integrity

```bash
npl-persona health [persona_id] [options]

Options:
  --all       Check all personas
  --verbose   Show detailed info
```

**Output**:
```
PERSONA: sarah-architect
├── ok sarah-architect.persona.md (2.1KB, 2h ago)
├── ok sarah-architect.journal.md (14.3KB, 2h ago)
├── warning sarah-architect.tasks.md (8.2KB, needs sync)
└── ok sarah-architect.knowledge-base.md (22.5KB, current)

INTEGRITY: 85% healthy
ISSUES: Tasks file exceeds expected sync interval
```

#### sync - Validate and Synchronize

```bash
npl-persona sync <persona_id> [options]

Options:
  --validate      Validate file structure (default: true)
  --no-validate   Skip validation
```

Checks file presence, validates NPL headers, and verifies cross-file references.

#### backup - Archive Persona Data

```bash
npl-persona backup [persona_id] [options]

Options:
  --all           Backup all personas
  --output=<dir>  Output directory (default: ./backups)
```

Creates timestamped tar.gz archive of persona files.

**Example**:
```bash
npl-persona backup --all --output=/backup/personas
# Creates: /backup/personas/personas-backup-20251210-143022.tar.gz
```

### Knowledge Sharing

```bash
npl-persona share <from_persona> <to_persona> [options]

Options:
  --topic=<topic>   Knowledge topic to share (required)
  --translate       Adapt to target's context
```

Transfers knowledge between personas with attribution.

**Example**:
```bash
npl-persona share sarah-architect mike-backend --topic="API patterns" --translate
```

---

## Team Management

### Creating Teams

```bash
npl-persona team create <team_id> [options]

Options:
  --members=<list>  Comma-separated persona IDs
  --scope=<scope>   project|user|system (default: project)
```

Creates team definition and history files.

**Example**:
```bash
npl-persona team create core-architects --members=sarah-architect,mike-backend,alex-devops
```

### Managing Team Members

```bash
# Add member to team
npl-persona team add <team_id> <persona_id>

# List team members
npl-persona team list <team_id> [--verbose]
```

### Team Knowledge Synthesis

```bash
npl-persona team synthesize <team_id> [options]

Options:
  --output=<path>  Output file path
```

Merges knowledge bases from all team members into unified document with:
- Expertise matrix
- Knowledge distribution analysis
- Gap identification
- Team strengths assessment

**Output**:
```markdown
# Team Knowledge Synthesis

## Expertise Matrix
| Domain | Expert(s) | Confidence | Coverage |
|--------|-----------|------------|----------|
| Architecture | @sarah (90%) | 90% | 3/4 |
| Security | @alex (85%) | 85% | 2/4 |

## Knowledge Gaps
Single Point of Knowledge (bus factor = 1):
- Kubernetes (only @alex)
```

### Team Analytics

```bash
# View expertise matrix
npl-persona team matrix <team_id>

# Analyze collaboration patterns
npl-persona team analyze <team_id> [--period=30]
```

**Analysis Output**:
```
Team Collaboration Analysis: core-architects
Period: Last 30 days

Total Interactions: 47
Active Members: 4/4

Member Activity:
  @sarah: 18 interactions
  @mike: 15 interactions
  @alex: 9 interactions
  @bob: 5 interactions

Top Collaboration Pairs:
  @sarah <-> @mike: 12 interactions
  @sarah <-> @alex: 8 interactions

Team Health Metrics:
  Collaboration Index: 83% (5/6 pairs active)
  Average Interactions per Member: 11.8
```

---

## Analytics and Reporting

### Individual Analysis

```bash
npl-persona analyze <persona_id> [options]

Options:
  --type=<type>    journal|tasks (default: journal)
  --period=<days>  Analysis period (default: 30)
```

**Journal Analysis Output**:
```
Journal Analysis (Last 30 days)

Interaction frequency: 47 sessions
Top collaborators: @mike (15), @alex (12), @bob (8)
Mood trajectory: 72% positive trend
Topics discussed: Architecture (15), API Design (12), Testing (8)
Learning velocity: 3.2 concepts/week
```

**Task Analysis Output**:
```
Task Completion Analysis (Last 30 days)

Total tasks: 24
Completed: 18 (75%)
In Progress: 4
Blocked: 2

Average completion time: 3.2 days
On-time completion: 85%
```

### Comprehensive Reports

```bash
npl-persona report <persona_id> [options]

Options:
  --format=<fmt>    md|json|html (default: md)
  --period=<p>      week|month|quarter|year (default: month)
```

Generates full persona report including:
- Executive summary
- Health status
- Activity summary
- Task metrics
- Knowledge growth
- Recommendations

---

## Integration Patterns

### With npl-technical-writer

```bash
# Persona-reviewed documentation
@persona tech-leads "Review this spec" | @npl-technical-writer "Format as RFC"

# Multi-perspective documentation
@persona --team=dev-team "Discuss API design" | \
@npl-technical-writer "Document the agreed approach"
```

### With npl-grader

```bash
# Persona-based QA
@persona qa-engineer "Test this feature" | @npl-grader "Validate test coverage"

# Team quality review
@persona --panel=architects "Architecture review" | \
@npl-grader "Grade against architecture rubric"
```

### With npl-project-coordinator

```bash
# Decompose with persona input
@project-coordinator "Design microservices architecture" \
  --consult=@persona[sarah-architect,mike-backend]

# Team task orchestration
@project-coordinator --delegate-to-personas "Implement user authentication"
```

### npl-load Integration

The CLI outputs tracking flags compatible with `npl-load`:

```bash
npl-persona get sarah-architect --skip {@npl.personas.loaded}
# Returns: @npl.personas.loaded+="sarah-architect"
```

---

## Best Practices

### Persona Design

1. **Complete Definitions**: Fill all sections in persona files; incomplete definitions produce inconsistent behavior
2. **Distinct Voices**: Define unique lexicon, patterns, and quirks for each persona
3. **Clear Boundaries**: Explicitly state expertise limitations to prevent hallucination
4. **Relationship Mapping**: Document how personas relate to each other

### State Management

5. **Regular Syncs**: Run `sync --validate` after interactions to catch drift
6. **Proactive Archiving**: Archive journal entries before files exceed 100KB
7. **Knowledge Maintenance**: Update domain confidence levels as expertise grows
8. **Daily Backups**: Use `backup --all` with retention policy

### Team Collaboration

9. **Team Synthesis**: Run monthly to identify knowledge gaps and bus factors
10. **Cross-Training**: Use `share` command to distribute critical knowledge
11. **Balanced Composition**: Include diverse expertise in teams

### Version Control

12. **Git Integration**: Commit persona files after significant interactions
13. **Branch per Session**: Consider branches for extended collaboration sessions
14. **Review Changes**: Treat persona state changes like code changes

---

## Limitations

### Technical Constraints

- **File Size Limits**: Journal files archive at 100KB; knowledge bases at 500KB
- **Concurrent Access**: Read-many, write-one model; no multi-writer support
- **Platform Paths**: macOS uses `/Library/Application Support/npl/`; Linux uses `/etc/npl/`

### Behavioral Limitations

- **Voice Drift**: Long sessions may cause subtle personality shifts
- **Knowledge Staleness**: LLM knowledge cutoff applies; persona KB supplements only
- **Relationship Complexity**: Simple relationship tracking; no dynamic relationship modeling
- **Emotional Depth**: Surface-level emotional simulation; no deep psychological modeling

### Integration Constraints

- **No Real-Time Sync**: State updates happen post-interaction, not during
- **Manual Archive Triggers**: No automatic archival; requires explicit commands
- **Limited Report Formats**: Currently supports md, json, html only

---

## See Also

- [Environment Setup](../../CLAUDE.md) - Environment variable configuration
- [Agent Patterns](../../npl/agent.md) - NPL agent construction reference
- [Multi-Agent Orchestration](../../docs/multi-agent-orchestration.md) - Team workflow patterns
- [npl-project-coordinator](./npl-prd-manager.md) - Task delegation to personas
