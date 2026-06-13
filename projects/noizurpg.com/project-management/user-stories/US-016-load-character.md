---
id: US-016
title: "Load character from save file"
slug: "load-character"
personas: [P-001, P-004]
epic: "Character System"
priority: "must-have"
complexity: "S"
tags: [character, save, load, persistence, file-system]
---

# US-016: Load Character from Save File

## User Story

**As an** indie AI game developer or tabletop GM (P-001, P-004),
**I want to** load a character's state from a previously saved file on disk,
**So that** players can resume a game session with their character exactly as they left it.

## Acceptance Criteria

- [ ] Given a character YAML file at `characters/aria.yaml`, when I call `Character.from_file("characters/aria.yaml")`, then the returned `Character` object is fully populated with stats, inventory, relationships, and knowledge as defined in the file.
- [ ] Given a character JSON file at `saves/aria_session_5.json`, when I call `Character.from_file("saves/aria_session_5.json")`, then the format is auto-detected from the file extension and the object is loaded correctly.
- [ ] Given a file path that does not exist, when I call `Character.from_file("missing.yaml")`, then a `FileNotFoundError` is raised with the full path in the error message.
- [ ] Given a save file that references a `noizurpg_schema_version` incompatible with the installed version, when I call `Character.from_file()`, then a `SchemaVersionError` is raised listing the file version, the current version, and a link to the migration guide.
- [ ] Given a character loaded from file, when I modify `character.stats["health"]` and then call `character.save("saves/aria_session_6.json")`, then the new file exists on disk and loading it reflects the updated health value.

## Notes

Sarah (P-004) needs save/load to work reliably for tabletop sessions that may span weeks. The `save()` convenience method should default to writing to the same path the character was loaded from, with an optional path override. See US-015 for the serialization specification and US-009 for bulk project import/export.
