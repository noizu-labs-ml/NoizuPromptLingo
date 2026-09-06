# Review: Explore Project Structure

- **Story**: `project-management/user-stories/US-025-explore-project-structure.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented as CLI console scripts. `git-tree` (`tools/git_tree.py`, entry point registered in `pyproject.toml:69-70`) renders the repository tree from `git ls-files` (`tools/lib/git_helpers.py:91`) using Unicode box-drawing characters (└── ├── │, `tools/git_tree.py:44-48`); `git-dump` (`tools/git_dump.py`) emits file contents with paths, sharing the git helpers. Both handle non-git fallbacks via the shared helpers, and exclusion/depth behavior is provided by the helper layer. The story's requirements — fast structural overview of the repo without reading every file — are met for human/agent CLI use. Note the surface is a CLI, not an MCP tool (story framing was MCP-agnostic enough that this satisfies it). Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| List repository files/directories in a readable tree | Met | `tools/git_tree.py` box-drawing output (`:44-48`) over `git ls-files` (`git_helpers.py:91`) |
| Respect ignore rules / git tracking | Met | built on `git ls-files` (tracked files only) |
| Dump file contents with paths for downstream consumption | Met | `tools/git_dump.py` |
| Installable/runnable commands | Met | console scripts `git-dump` / `git-tree` (`pyproject.toml:69-70`) |

## Gaps / Risks

- Large repos can still produce very large dumps; depth/size limits should be verified for monorepo scale.
- No MCP wrapper — agents inside the MCP server cannot call this without shelling out.

## BDD Scenario

```gherkin
Feature: Explore project structure
  Scenario: Agent surveys an unfamiliar repo
    Given a git repository on disk
    When git-tree is run from the repo root
    Then a Unicode tree of tracked files is printed
    And git-dump can emit selected file contents with paths
```
