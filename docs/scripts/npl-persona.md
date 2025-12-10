# npl-persona

Persona management tool for NPL with multi-tiered hierarchical loading (project -> user -> system).

**Full reference:** [npl-persona.detailed.md](./npl-persona.detailed.md)

## Synopsis

```bash
npl-persona <command> [options]
```

## Quick Reference

| Command | Purpose | Example |
|---------|---------|---------|
| `init` | Create persona | `npl-persona init sarah-architect --role "Architect"` |
| `get` | Load persona files | `npl-persona get sarah-architect --files definition,tasks` |
| `list` | List personas | `npl-persona list --scope project -v` |
| `which` | Locate persona | `npl-persona which sarah-architect` |
| `remove` | Delete persona | `npl-persona remove old-persona --force` |
| `journal` | Journal operations | `npl-persona journal sarah add --message "..."` |
| `task` | Task management | `npl-persona task sarah add "Review API" --due 2024-12-15` |
| `kb` | Knowledge base | `npl-persona kb sarah add "Topic" --content "..."` |
| `health` | Check file health | `npl-persona health --all` |
| `sync` | Validate files | `npl-persona sync sarah-architect` |
| `backup` | Backup data | `npl-persona backup --all --output ./backups` |
| `share` | Share knowledge | `npl-persona share sarah bob --topic "API Design"` |
| `team` | Team management | `npl-persona team create backend --members "a,b,c"` |
| `analyze` | Analyze data | `npl-persona analyze sarah --type journal --period 30` |
| `report` | Generate report | `npl-persona report sarah --format md --period quarter` |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `NPL_PERSONA_DIR` | Override persona path |
| `NPL_PERSONA_TEAMS` | Override teams path |
| `NPL_PERSONA_SHARED` | Override shared path |

See: [Environment Variables](./npl-persona.detailed.md#environment-variables)

## Persona Files

Each persona requires four files:

| File | Purpose |
|------|---------|
| `{id}.persona.md` | Core definition, role, traits |
| `{id}.journal.md` | Experience log, reflections |
| `{id}.tasks.md` | Active tasks, goals |
| `{id}.knowledge-base.md` | Domain expertise |

See: [File Structure](./npl-persona.detailed.md#file-structure)

## Common Workflows

### Create and Configure Persona

```bash
npl-persona init sarah-architect --role "Software Architect"
npl-persona kb sarah-architect update-domain "Architecture" --confidence 85
npl-persona task sarah-architect add "Review API design" --priority high
```

### Daily Operations

```bash
npl-persona journal sarah-architect add --message "Completed API review"
npl-persona task sarah-architect complete "Review API design"
npl-persona kb sarah-architect add "REST Patterns" --content "Use HATEOAS..."
```

### Team Collaboration

```bash
npl-persona team create backend-team --members "sarah,bob,carol"
npl-persona team add backend-team dave-devops
npl-persona team synthesize backend-team
npl-persona share sarah-architect bob-developer --topic "API Design"
```

### Maintenance

```bash
npl-persona health --all -v
npl-persona journal sarah-architect archive --before 2024-01-01
npl-persona backup --all
```

## Dependency Tracking

After `get`, outputs tracking flags:

```markdown
# Flag Update
```🏳️
@npl.personas.loaded+="sarah-architect"
```
```

Use `--skip` to prevent reloading:

```bash
npl-persona get sarah-architect --skip sarah-architect
```

See: [Dependency Tracking](./npl-persona.detailed.md#dependency-tracking)

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error |

## Detailed Documentation

- [Commands Reference](./npl-persona.detailed.md#commands-reference)
- [Search Path Resolution](./npl-persona.detailed.md#search-path-resolution)
- [Implementation Details](./npl-persona.detailed.md#implementation-details)
- [Edge Cases and Limitations](./npl-persona.detailed.md#edge-cases-and-limitations)
- [Integration Patterns](./npl-persona.detailed.md#integration-patterns)

## See Also

- [npl-load](./npl-load.md) - Load NPL components
