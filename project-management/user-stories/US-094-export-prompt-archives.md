---
id: US-094
title: "Export prompt archives as structured files"
personas: [diana-kovacs]
domain: prompt-archival
priority: low
mvp_phase: "v1.0"
---

## User Story

As a **Diana Kovacs (Freelance Multi-Client)**, I want to export prompt archives as structured files (YAML/JSON) for backup, migration, or external use so that I own my prompt configurations and can move them between platforms or share them with clients as deliverables.

## Acceptance Criteria

- [ ] An export action is available at the agent level (all versions), version level (single snapshot), and library level (all prompts matching a filter)
- [ ] Export formats include YAML and JSON with a documented schema that preserves: prompt text, version metadata, tags, annotations, and eval score summaries
- [ ] Exported files can be re-imported into the same or a different tobornalp workspace with conflict resolution (skip, overwrite, or merge)
- [ ] Bulk export supports filtering by agent, project, date range, or tag before exporting
- [ ] Exports exclude sensitive data (API keys, client secrets) by default with an explicit opt-in for including credentials

## Notes

Data portability is a trust signal — users invest more in a platform they know they can leave. For Diana's freelance workflow, export also serves a business purpose: delivering a configured agent setup to a client as a project deliverable. The YAML format should be human-readable and editable — power users will want to version-control their prompts in git alongside their code. The import/merge workflow is the harder problem: when importing prompts that reference tools or agents that don't exist in the target workspace, the platform should surface clear warnings rather than silently breaking references.
