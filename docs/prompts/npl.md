# npl.md

NPL conventions reference for agent delegation, work logging, and session tracking.

**Source**: `/core/prompts/npl.md`
**Version**: 1.3.0

## Quick Reference

| Section | Description |
|:--------|:------------|
| [Purpose](npl.detailed.md#purpose) | File role and loading context |
| [File Structure](npl.detailed.md#file-structure) | Document organization |
| [Runtime Flags](npl.detailed.md#runtime-flags) | `@command-and-control`, `@work-log`, `@track-work` |
| [Command-and-Control Modes](npl.detailed.md#command-and-control-modes) | `lone-wolf`, `team-member`, `task-master` |
| [Work-Log Flag](npl.detailed.md#work-log-flag) | Interstitial file generation |
| [Available Agents](npl.detailed.md#available-agents) | `Explore`, `Plan`, `npl-technical-writer`, etc. |
| [Session Directory Layout](npl.detailed.md#session-directory-layout) | `.npl/sessions/` structure |
| [Interstitial Files](npl.detailed.md#interstitial-files) | `.summary.md`, `.detailed.md`, `.yaml` |
| [Worklog Communication](npl.detailed.md#worklog-communication) | `npl-session` CLI usage |
| [Visualization Preferences](npl.detailed.md#visualization-preferences) | Mermaid over ASCII |
| [Codebase Tools](npl.detailed.md#codebase-tools) | `Glob`, `Grep`, `Read`, `Task` |
| [NPL Framework Quick Reference](npl.detailed.md#npl-framework-quick-reference) | Core syntax and markers |
| [Usage Examples](npl.detailed.md#usage-examples) | Loading, overriding, session workflow |
| [Integration](npl.detailed.md#integration) | Related components and loading order |
| [Best Practices](npl.detailed.md#best-practices) | Delegation, logging, sessions |

## Default Configuration

```
@command-and-control="task-master"
@work-log="standard"
@track-work=true
```

## Load Command

```bash
npl-load c "npl" --skip {@npl.def.loaded}
```

See [npl.detailed.md](npl.detailed.md) for complete documentation.
