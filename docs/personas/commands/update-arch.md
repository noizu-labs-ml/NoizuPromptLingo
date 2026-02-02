# Update-Arch - Persona

**Type**: Command
**Category**: Documentation Maintenance
**Version**: 1.0.0

## Overview

The `update-arch` command is a documentation maintenance utility that enforces size constraints on the project architecture documentation (`PROJ-ARCH.md`). It ensures the main architecture file remains concise and scannable by extracting detailed sections into separate files under `docs/arch/` when size thresholds are exceeded.

## Purpose & Use Cases

- Monitor `PROJ-ARCH.md` for size violations (>300 lines total, >15 lines per section)
- Extract bloated sections to dedicated detail files in `docs/arch/`
- Maintain architectural overview as an entry point without overwhelming detail
- Preserve readability by replacing extracted content with summaries and references
- Support iterative documentation growth without degrading discoverability

## Key Features

✅ Enforces strict size limits on main architecture file
✅ Automated extraction of oversized sections
✅ Generates summary replacements with links to detailed docs
✅ Maintains architectural essence in main file
✅ Creates standardized structure in `arch/` subdirectory
✅ Validates link integrity after extraction

## Usage

```bash
update-arch
```

The command analyzes `docs/PROJ-ARCH.md`, identifies sections exceeding size thresholds, and performs extraction when necessary. For each oversized section, it creates a detailed file at `docs/arch/{section-name}.md`, replaces the original content with a 2-4 sentence summary, and adds a reference link. The process ensures the main file remains under 300 lines while preserving key architectural insights.

## Integration Points

- **Triggered by**: Manual invocation when PROJ-ARCH.md grows unwieldy, or automated checks during doc updates
- **Feeds to**: Architecture documentation structure (`docs/arch/`)
- **Complements**: `update-layout-doc` (maintains PROJ-LAYOUT.md structure)

## Parameters / Configuration

- **Size Limits**: PROJ-ARCH.md < 300 lines, individual sections < 15 lines, arch/*.md files < 200 lines
- **Extraction Threshold**: Sections exceeding ~15 lines or containing implementation details
- **Output Directory**: `docs/arch/` for extracted content
- **Summary Format**: 2-4 sentence summary plus reference link
- **Link Pattern**: `→ *See [arch/{section-name}.md](arch/{section-name}.md) for details*`

## Success Criteria

- Main PROJ-ARCH.md remains under 300 lines
- Each section provides clear summary without requiring click-through for basic understanding
- All `arch/*.md` links remain valid after extraction
- Diagrams and core architectural decisions preserved in main file
- No implementation details leak into main overview

## Limitations & Constraints

- Requires manual judgment on what constitutes "essential" vs "detailed" content
- Cannot automatically determine optimal section boundaries
- Depends on consistent markdown structure for section detection
- May require iterative refinement of summaries for clarity
- Does not handle cyclic dependencies between architectural sections

## Related Utilities

- `update-layout-doc` - Maintains PROJ-LAYOUT.md structure using similar principles
- `track-assumptions` - Documents architectural assumptions that may impact PROJ-ARCH.md content
- `reflect` - General-purpose documentation reflection utility for maintaining consistency
