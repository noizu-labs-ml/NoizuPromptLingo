# init-project-fast - Persona

**Type**: Command
**Category**: Project Initialization
**Version**: 1.0.0

## Overview

`init-project-fast` is a rapid project documentation bootstrap command that generates foundational documentation through parallel scout deployment without coordinator overhead. It creates minimal viable documentation (CLAUDE.md, PROJECT-ARCH.md, PROJECT-LAYOUT.md) designed to be expanded later with `/update-arch` commands.

## Purpose & Use Cases

- **Quick scaffolding** – Generate initial project documentation in under 90 seconds for new projects
- **Iterative documentation approach** – Bootstrap minimal docs first, expand detail progressively
- **Time-constrained setup** – Rapid initialization when complete analysis can wait
- **Pre-expansion foundation** – Create skeleton structure before running follow-up commands
- **Debugging-friendly execution** – Visible interstitial files in `.npl/project-init/` during run

## Key Features

✅ **No coordinator overhead** – Direct scout deployment eliminates 30+ second pre-scan
✅ **Progressive synthesis** – Begins document generation after 2 scouts complete (not waiting for all 4)
✅ **Consolidated scouts** – 4 merged scouts vs 5-7 specialized scouts in full init-project
✅ **Visible working files** – Interstitial files remain in `.npl/project-init/` during execution for inspection
✅ **Stub generation** – Creates expandable stubs in `docs/PROJECT-ARCH/*.md` for later detail
✅ **Stack detection** – Automatic language/framework identification from project artifacts

## Usage

```bash
/init-project-fast
```

The command executes five phases: (1) initialize environment and CLAUDE.md, (2) deploy 4 parallel scouts (Foundation, Core, Infra, Surface), (3) progressively synthesize findings, (4) generate minimal documentation with stubs, (5) cleanup working files after quality gates pass.

## Integration Points

- **Triggered by**: Manual invocation when quick project documentation is needed
- **Feeds to**: `/update-arch` and `/update-layout` for expanding stub documentation
- **Complements**: `/init-project` (full coordinator-based initialization), `npl-gopher-scout` agent
- **Outputs consumed by**: Developers reviewing PROJECT-ARCH.md and follow-up documentation commands

## Parameters / Configuration

- **No CLI flags** – Command runs with fixed configuration
- **Scout timeout** – Individual scouts timeout at 45 seconds, full scout deployment at 90 seconds
- **Synthesis trigger** – Begins after 2 scouts complete OR 60-second timeout
- **Output depth** – TARGET: 150-250 lines for PROJECT-ARCH.md (minimal viable)
- **Working directory** – `.npl/project-init/` for scout reports and synthesis files

## Success Criteria

- **CLAUDE.md exists** – NPL prompts successfully added/updated
- **PROJECT-ARCH.md created** – Minimal architecture documentation (~150-250 lines)
- **PROJECT-LAYOUT.md created** – Standard structure documentation using git-tree
- **At least 2 scouts complete** – Minimum coverage for synthesis (4 preferred)
- **Stub files created** – `docs/PROJECT-ARCH/{layers,domain,patterns,infrastructure}.md` with expansion hooks
- **Quality gates pass** – All file references resolve correctly

## Limitations & Constraints

- **Minimal detail** – Generates stubs requiring `/update-arch` for complete documentation
- **No pre-scan** – Cannot optimize scout deployment based on project characteristics
- **Fixed scout count** – Always deploys exactly 4 scouts (no dynamic scaling)
- **Partial coverage accepted** – Will generate docs with only 2 scout reports if timeouts occur
- **Stack detection dependency** – Quality depends on recognizable project structure patterns

## Related Utilities

- **`/init-project`** – Full coordinator-based initialization with complete documentation
- **`/update-arch`** – Expands stub files with detailed layer/domain/pattern documentation
- **`/update-layout`** – Refreshes PROJECT-LAYOUT.md
- **`@npl-gopher-scout`** – Scout agent used for reconnaissance
- **`npl-load init-claude`** – CLAUDE.md initialization/versioning command
