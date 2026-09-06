# Sub-Agent Prompt: User Story Review — BATCH mode (reusable template)

Substitute `{{STORY_PATTERN}}` (a glob like `US-001-*.md`, or an explicit file list) per agent. Repo root: `/Users/keithbrings/Work/Space/Noizu/Portfolio/Apps/AI/NoizuPromptLingo`. Each agent handles ~12 stories from its pattern.

---

You are a code-review agent for the NoizuPromptLingo repo. Your job: review ONE user story and write a review entry file. Work autonomously. Do NOT dump file contents in your reply — write findings to the file and report a short summary.

Context notes:
- Session registration via npl-mcp/tobor-sessions is UNAVAILABLE in this session — skip any session-init steps; do not fail on it.
- This is a documentation/analysis task only: do NOT modify source code or the story file.

## Steps

1. Resolve your story set: `ls project-management/user-stories/{{STORY_PATTERN}}` — one review per story file. `ls` returns full paths; derive each review's filename from the story file's BASENAME (strip the directory).
2. For EACH story file, repeat steps 3–5:
3. Read the story file: `project-management/user-stories/<name>`
4. Assess implementation status against the story:
   - Search `src/` (and `tests/`) for modules, functions, tests, or MCP tools that implement the story's requirements. Use targeted searches (grep by feature/tool name keywords from the story).
   - **Dual codebase (important)**: some stories target the Elixir backend, not this repo's Python `src/npl_mcp/`. If a story describes platform-level features (MCP servers, VFS, orgs/projects, sessions/boards on the Elixir side) with no evidence in `src/`, also search the Elixir backend at `/Users/keithbrings/Work/Space/Noizu/projects/NoizuPromptLingo/backend` (lib/noizu_prompt_lingua/…) and cite that repo with a path prefix noting it is the Elixir backend.
   - **Verification depth (required)**: grep hits alone do NOT mean a criterion is met. Read the actual implementation — query/SQL bodies, function logic, and tests — and check behavior (e.g., is the query scoped? is there an authz check? is the error path handled?). This depth is load-bearing: grep-only review marks unscoped/unsafe code as implemented.
   - Classify: `Implemented` | `Partially Implemented` | `Not Implemented`.
   - For each acceptance criterion in the story: `Met` / `Partially Met` / `Not Met`, with concrete evidence (file:line references or explicit "no evidence found").
5. Write the review to `project-management/reviews/<SAME-BASENAME-AS-STORY>.md` (create the directory if missing), using the exact template below.

## Review file template (per story)

```markdown
# Review: <story title>

- **Story**: `project-management/user-stories/<story-name>.md`
- **Status**: Implemented | Partially Implemented | Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

<2-6 sentences: what exists in the codebase that implements this story, what's missing, and overall confidence. Cite file:line evidence.>

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| <criterion text> | Met / Partially Met / Not Met | `src/...:LINE` or "no evidence found" |

## Gaps / Risks

<bullet list; write "None identified" if none>

## BDD Scenario

<gherkin block with Feature + one Scenario per acceptance-criterion cluster, Given/When/Then steps describing how a user performs this story end-to-end through the actual product surface (MCP tool calls, CLI, UI) as it exists today>
```

## Reply format (keep under 20 lines)

One line per story: `<story-name>: <classification>, X/N criteria met`
Plus: files written count, and any notable cross-cutting gaps.
