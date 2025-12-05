# npl-persona

A comprehensive persona management tool for NPL with multi-tiered hierarchical loading (project -> user -> system).

## Synopsis

```bash
npl-persona <command> [options]
```

## Description

`npl-persona` manages AI persona definitions with persistent state across sessions. It provides lifecycle management, journaling, task tracking, knowledge bases, team collaboration, and analytics capabilities.

## Environment Variables

| Variable | Description | Fallback |
|----------|-------------|----------|
| `NPL_PERSONA_DIR` | Base path for persona definitions | `./.npl/personas`, `~/.npl/personas`, `<system>/personas` |
| `NPL_PERSONA_TEAMS` | Path for team definitions | `./.npl/teams`, `~/.npl/teams`, `<system>/teams` |
| `NPL_PERSONA_SHARED` | Path for shared persona resources | `./.npl/shared`, `~/.npl/shared`, `<system>/shared` |

### Platform-Specific System Paths

| Platform | System Path |
|----------|-------------|
| Linux | `/etc/npl/personas/` |
| macOS | `/Library/Application Support/npl/personas/` |
| Windows | `%PROGRAMDATA%\npl\personas\` |

## Persona File Structure

Each persona consists of four mandatory files:

| File | Purpose |
|------|---------|
| `{id}.persona.md` | Core definition, role, background, traits |
| `{id}.journal.md` | Chronological experiences and learnings |
| `{id}.tasks.md` | Active tasks, goals, and assignments |
| `{id}.knowledge-base.md` | Domain expertise and acquired knowledge |

## Commands

### Lifecycle Commands

#### init - Create new persona

```bash
npl-persona init <persona_id> [options]
```

| Option | Description |
|--------|-------------|
| `--role` | Role/title for the persona |
| `--scope` | Where to create: `project`, `user`, `system` (default: project) |
| `--from-template` | Copy from existing persona in specified scope |

**Examples:**

```bash
# Create new project-level persona
npl-persona init sarah-architect --role "Software Architect"

# Create user-level persona from system template
npl-persona init my-reviewer --scope user --from-template system
```

#### get - Fetch persona files

```bash
npl-persona get <persona_id> [options]
```

| Option | Description |
|--------|-------------|
| `--files` | Files to load: `definition`, `journal`, `tasks`, `knowledge`, or `all` (default: all) |
| `--skip` | Skip if already loaded (supports tracking) |

**Examples:**

```bash
# Load all persona files
npl-persona get sarah-architect

# Load only definition and tasks
npl-persona get sarah-architect --files definition,tasks

# Load with skip tracking
npl-persona get sarah-architect --skip sarah-architect
```

#### list - List available personas

```bash
npl-persona list [options]
```

| Option | Description |
|--------|-------------|
| `--scope` | Filter by scope: `project`, `user`, `system`, `all` (default: all) |
| `--verbose`, `-v` | Show file status details |

**Examples:**

```bash
# List all personas
npl-persona list

# List project personas with details
npl-persona list --scope project --verbose
```

#### which - Locate persona

```bash
npl-persona which <persona_id>
```

Finds and displays the location of a persona in the search paths.

#### remove - Delete persona

```bash
npl-persona remove <persona_id> [options]
```

| Option | Description |
|--------|-------------|
| `--scope` | Only delete from specified scope |
| `--force`, `-f` | Skip confirmation prompt |

### Journal Commands

```bash
npl-persona journal <persona_id> <action> [options]
```

| Action | Description |
|--------|-------------|
| `add` | Add new journal entry |
| `view` | View recent entries |
| `archive` | Archive old entries |

| Option | Description |
|--------|-------------|
| `--message` | Journal entry message (for add) |
| `--interactive`, `-i` | Interactive mode for add |
| `--entries` | Number of entries to view (default: 5) |
| `--since` | View entries since date (YYYY-MM-DD) |
| `--before` | Archive entries before date (YYYY-MM-DD) |

**Examples:**

```bash
# Add journal entry
npl-persona journal sarah-architect add --message "Reviewed API design patterns"

# View last 10 entries
npl-persona journal sarah-architect view --entries 10

# Archive old entries
npl-persona journal sarah-architect archive --before 2024-01-01
```

### Task Commands

```bash
npl-persona task <persona_id> <action> [task_description] [options]
```

| Action | Description |
|--------|-------------|
| `add` | Add new task |
| `update` | Update task status |
| `complete` | Mark task as completed |
| `list` | List tasks |
| `remove` | Remove a task |

| Option | Description |
|--------|-------------|
| `--due` | Due date (YYYY-MM-DD) |
| `--priority` | Priority: `high`, `med`, `low` (default: med) |
| `--status` | New status for update: `pending`, `in-progress`, `blocked`, `completed` |
| `--filter` | Filter tasks by status (for list) |
| `--note` | Completion note (for complete) |

**Examples:**

```bash
# Add a high-priority task
npl-persona task sarah-architect add "Review microservices design" --priority high --due 2024-12-15

# Update task status
npl-persona task sarah-architect update "Review microservices" --status in-progress

# List pending tasks
npl-persona task sarah-architect list --filter pending

# Complete with note
npl-persona task sarah-architect complete "Review microservices" --note "Approved with minor changes"
```

### Knowledge Base Commands

```bash
npl-persona kb <persona_id> <action> [topic] [options]
```

| Action | Description |
|--------|-------------|
| `add` | Add knowledge entry |
| `search` | Search knowledge base |
| `get` | Get specific topic |
| `update-domain` | Update domain confidence |

| Option | Description |
|--------|-------------|
| `--content` | Knowledge content |
| `--source` | Knowledge source reference |
| `--domain` | Knowledge domain filter |
| `--confidence` | Confidence level 0-100 (for update-domain) |

**Examples:**

```bash
# Add knowledge
npl-persona kb sarah-architect add "API Design" \
  --content "REST APIs should use noun-based endpoints" \
  --source "API Design Guidelines v2"

# Search knowledge base
npl-persona kb sarah-architect search "REST" --domain api-design

# Update domain confidence
npl-persona kb sarah-architect update-domain --domain api-design --confidence 90
```

### Health and Maintenance

#### health - Check persona file health

```bash
npl-persona health [persona_id] [options]
```

| Option | Description |
|--------|-------------|
| `--all` | Check all personas |
| `--verbose`, `-v` | Show detailed information |

Reports file presence, size warnings, and overall health score.

#### sync - Validate and synchronize

```bash
npl-persona sync <persona_id> [options]
```

| Option | Description |
|--------|-------------|
| `--validate` | Validate file structure (default: true) |
| `--no-validate` | Skip validation |

#### backup - Backup persona data

```bash
npl-persona backup [persona_id] [options]
```

| Option | Description |
|--------|-------------|
| `--all` | Backup all personas |
| `--output` | Output directory (default: ./backups) |

### Collaboration

#### share - Share knowledge between personas

```bash
npl-persona share <from_persona> <to_persona> [options]
```

| Option | Description |
|--------|-------------|
| `--topic` | Knowledge topic to share (required) |
| `--translate` | Translate knowledge to target context |

**Example:**

```bash
npl-persona share sarah-architect bob-developer \
  --topic "API Design" \
  --translate
```

### Team Management

```bash
npl-persona team <action> <team_id> [persona_id] [options]
```

| Action | Description |
|--------|-------------|
| `create` | Create new team |
| `add` | Add persona to team |
| `list` | List teams or team members |
| `synthesize` | Generate team knowledge synthesis |
| `matrix` | Display team skill matrix |
| `analyze` | Analyze team dynamics |

| Option | Description |
|--------|-------------|
| `--members` | Comma-separated persona IDs (for create) |
| `--scope` | Scope for team creation (default: project) |
| `--output` | Output file path (for synthesize) |
| `--period` | Analysis period in days (default: 30) |
| `--verbose`, `-v` | Show detailed information |

**Examples:**

```bash
# Create a team
npl-persona team create backend-team \
  --members "sarah-architect,bob-developer,carol-tester"

# Add member to existing team
npl-persona team add backend-team dave-devops

# List team members
npl-persona team list backend-team --verbose

# Generate team knowledge synthesis
npl-persona team synthesize backend-team --output team-knowledge.md

# Analyze team dynamics
npl-persona team analyze backend-team --period 90
```

### Analytics

#### analyze - Analyze persona data

```bash
npl-persona analyze <persona_id> [options]
```

| Option | Description |
|--------|-------------|
| `--type` | Analysis type: `journal`, `tasks` (default: journal) |
| `--period` | Analysis period in days (default: 30) |

#### report - Generate persona report

```bash
npl-persona report <persona_id> [options]
```

| Option | Description |
|--------|-------------|
| `--format` | Report format: `md`, `json`, `html` (default: md) |
| `--period` | Report period: `week`, `month`, `quarter`, `year` (default: month) |

**Examples:**

```bash
# Generate monthly markdown report
npl-persona report sarah-architect

# Generate quarterly HTML report
npl-persona report sarah-architect --format html --period quarter
```

## Dependency Tracking

When loading personas with `get`, the tool outputs flag updates for tracking:

```markdown
# Flag Update

```🏳️
@npl.personas.loaded+="sarah-architect"
```
```

Use `--skip` on subsequent calls to prevent reloading:

```bash
npl-persona get sarah-architect --skip sarah-architect
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error (persona not found, invalid arguments, etc.) |

## See Also

- [npl-load](./npl-load.md) - Load NPL components and metadata
- [NPL Persona Agent](../agents/npl-persona.md) - Persona-based collaboration agent
