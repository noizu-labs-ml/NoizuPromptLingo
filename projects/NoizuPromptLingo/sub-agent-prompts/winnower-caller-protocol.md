# Winnower Caller Protocol

Instructions for any agent that reads files. Integrate this protocol into your file-reading workflow to reduce context consumption.

## When to Use the Winnower

Before reading any file of unknown size, check its line count:

```bash
wc -l <path>
```

| Line Count | Action |
|-----------|--------|
| ≤ 150 lines | Read directly with the Read tool |
| 151–10,000 lines | Spawn npl-winnower |
| > 10,000 lines | Spawn npl-winnower (will auto-downgrade to skeleton) |
| Binary / unsupported | Skip or use npl-winnower stat for metadata |

If you already know the file is large (e.g., lock files, generated code, large test suites), skip the size check and go straight to winnowing.

## Commands

### 1. STAT — Pre-check file metadata

Spawn `npl-winnower` with:
```
Stat <file-path>
```

Returns: line count, byte size, language, token estimate, and a recommendation (`direct`, `winnow`, or `skip`).

Use this when you need metadata without reading content, or to decide your approach for an unfamiliar file.

### 2. WINNOW — Get tailored file view

Spawn `npl-winnower` with:
```
Winnow <file-path> at <verbosity> verbosity.
```

**Verbosity levels:**

| Level | Use When |
|-------|----------|
| `skeleton` | You need structure only — heading/class/function names, line counts |
| `summary` | You need to understand the API — signatures, docstrings, key logic |
| `detailed` | You need most content but can skip boilerplate |
| `full` | You need everything (rarely needed — just use Read tool instead) |

**Optional parameters (append to prompt):**
- `Focus: <query>` — filter to matching content (e.g., "Focus: async methods")
- `Budget: <N> lines` — cap total output lines

**Example invocations:**
```
Winnow src/npl_mcp/launcher.py at summary verbosity.

Winnow src/npl_mcp/meta_tools/catalog.py at skeleton verbosity. Budget: 50 lines.

Winnow tests/test_instructions.py at summary verbosity. Focus: fixture setup patterns.
```

### 3. EXPAND — Drill into sections

After receiving a winnowed response, you'll see section IDs like `[sec:fn-2]` and collapsed markers like `--- 24 lines collapsed [sec:cls-1.3] ---`.

To expand specific sections, spawn `npl-winnower` with:
```
Expand [sec:fn-2, sec:cls-1.3] from <file-path> at <verbosity> verbosity.
```

The response includes only the requested sections. Expanded sections may contain their own child section IDs for further drilling.

**Example multi-turn flow:**

1. `Winnow src/big_module.py at skeleton verbosity.`
   → Get heading outline with section IDs (15 lines from 800-line file)

2. `Expand [sec:cls-1] from src/big_module.py at summary verbosity.`
   → Get class summary with method signatures (30 lines)

3. `Expand [sec:cls-1.5] from src/big_module.py at full verbosity.`
   → Get full method implementation (20 lines)

Total: ~65 lines consumed instead of 800.

### 4. BATCH — Multiple files at once

When you need to survey several files (architecture mapping, pattern comparison):

```
Winnow batch [file1.py, file2.py, file3.py] at skeleton verbosity. Budget: 200 lines.
```

**With a structural query** (extracts matching elements across files):
```
Winnow batch [file1.py, file2.py, file3.py] at summary verbosity. Query: "public functions". Budget: 100 lines.
```

Batch mode caps at 20 files. Budget is split proportionally by file size. Verbosity is limited to `skeleton` or `summary` in batch mode.

## Section ID Reference

These are the IDs you'll see in winnowed output:

| Pattern | Meaning |
|---------|---------|
| `sec:imp` | Imports block |
| `sec:const` | Constants / globals |
| `sec:cls-N` | Nth class |
| `sec:cls-N.M` | Mth method in Nth class |
| `sec:fn-N` | Nth top-level function |
| `sec:fn-N.inner` | Inner functions |
| `sec:H` / `sec:H.S` | Heading / sub-heading (docs) |
| `sec:cN` | Notebook cell N |
| `sec:fX-*` | Batch: file index X prefix |

## Decision Flowchart

```
File to read?
├─ Size known and ≤ 150 lines? → Read directly
├─ Size unknown? → wc -l first, then decide
├─ Need full verbatim content? → Read directly
├─ Need structure/API only? → Winnow at skeleton or summary
├─ Multiple files to survey? → Winnow batch
└─ Need specific section from previous winnow? → Expand with section IDs
```

## Integration Notes

- The winnower is a Claude Code sub-agent (type: `npl-winnower`), invoked via the Agent tool
- It uses the Read, Glob, and Bash tools internally — you don't need to read the file yourself
- Section IDs are position-based and deterministic for a given file version
- If the file changes between winnow and expand calls, section IDs may shift — re-winnow if stale
