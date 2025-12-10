# PRD-007: MCP Server Bug Fixes

**Version**: 1.0.0
**Status**: Active
**Priority**: P1
**Owner**: Engineering
**Created**: 2025-12-10
**Source**: `mcp-server/docs/ISSUES.md`

---

## Executive Summary

This PRD documents six bugs identified during systematic testing of the NPL MCP Server. The primary focus is on Issue #4 (Artifact-Session Association), which blocks proper session management functionality. The remaining issues are lower severity UI and script integration problems.

---

## Problem Statement

### Current State
The MCP server is functionally complete with 22+ passing tests and working web UI. However, testing revealed several issues that affect usability and data integrity:

1. Session-artifact linkage is broken - artifacts cannot be associated with sessions
2. Two script wrapper tools return empty results
3. Chat UI lacks visual context for replies, assignments, and reactions

### Desired State
- Artifacts created within a session context are properly linked to that session
- All script wrapper tools produce expected output
- Chat UI provides complete visual context for all event types

### Impact Analysis

| Issue | Impact | Affected Users |
|:------|:-------|:---------------|
| Artifact-Session | Data integrity, organization | All MCP users |
| Script wrappers | Reduced functionality | Developers using NPL tools |
| UI indicators | Reduced usability | Web UI users |

---

## Requirements

### FR-001: Artifact Session Association (P0 - Critical)

**Severity**: Medium (functional gap)
**Location**: `mcp-server/src/npl_mcp/unified.py:118-128`, `mcp-server/src/npl_mcp/artifacts/manager.py:23-89`

#### Root Cause Analysis

The `create_artifact` MCP tool does not accept a `session_id` parameter. While the database schema supports `session_id` on the `artifacts` table (added via migration), the tool and manager do not propagate this value.

```python
# Current signature (unified.py:118-128)
async def create_artifact(
    name: str, artifact_type: str, file_content_base64: str, filename: str,
    created_by: Optional[str] = None, purpose: Optional[str] = None
) -> dict:
```

The `ArtifactManager.create_artifact()` method similarly lacks the parameter:

```python
# Current signature (manager.py:23-31)
async def create_artifact(
    self,
    name: str,
    artifact_type: str,
    file_content: bytes,
    filename: str,
    created_by: Optional[str] = None,
    purpose: Optional[str] = None
) -> Dict[str, Any]:
```

#### Fix Specification

1. **Add `session_id` parameter to MCP tool** (`unified.py`):
   ```python
   @mcp.tool()
   async def create_artifact(
       name: str, artifact_type: str, file_content_base64: str, filename: str,
       created_by: Optional[str] = None, purpose: Optional[str] = None,
       session_id: Optional[str] = None  # NEW PARAMETER
   ) -> dict:
   ```

2. **Add `session_id` parameter to ArtifactManager** (`manager.py`):
   ```python
   async def create_artifact(
       self,
       name: str,
       artifact_type: str,
       file_content: bytes,
       filename: str,
       created_by: Optional[str] = None,
       purpose: Optional[str] = None,
       session_id: Optional[str] = None  # NEW PARAMETER
   ) -> Dict[str, Any]:
   ```

3. **Update artifact INSERT query** (`manager.py:57-63`):
   ```python
   cursor = await self.db.execute(
       """
       INSERT INTO artifacts (name, type, session_id)
       VALUES (?, ?, ?)
       """,
       (name, artifact_type, session_id)
   )
   ```

4. **Pass session_id through MCP tool** (`unified.py`):
   ```python
   return await _artifact_manager.create_artifact(
       name=name, artifact_type=artifact_type, file_content=file_content,
       filename=filename, created_by=created_by, purpose=purpose,
       session_id=session_id  # PASS THROUGH
   )
   ```

#### Acceptance Criteria

- [ ] AC-001.1: `create_artifact` tool accepts optional `session_id` parameter
- [ ] AC-001.2: Artifacts created with `session_id` appear in `get_session` response
- [ ] AC-001.3: `artifact_count` in session listing reflects linked artifacts
- [ ] AC-001.4: Artifacts created without `session_id` continue to work (backward compatible)
- [ ] AC-001.5: Session manager's `get_session_contents()` returns linked artifacts

#### Test Cases

```python
# Test 1: Create artifact with session_id
async def test_create_artifact_with_session():
    session = await create_session(title="Test Session")
    artifact = await create_artifact(
        name="test-doc",
        artifact_type="document",
        file_content_base64=base64.b64encode(b"content").decode(),
        filename="test.md",
        session_id=session["session_id"]
    )

    # Verify linkage
    session_contents = await get_session(session["session_id"])
    assert session_contents["artifact_count"] == 1
    assert artifact["artifact_id"] in [a["id"] for a in session_contents["artifacts"]]

# Test 2: Backward compatibility (no session_id)
async def test_create_artifact_without_session():
    artifact = await create_artifact(
        name="standalone-doc",
        artifact_type="document",
        file_content_base64=base64.b64encode(b"content").decode(),
        filename="standalone.md"
    )
    assert artifact["artifact_id"] is not None
```

---

### FR-002: git_tree_depth Empty Result (P2 - Low)

**Severity**: Low
**Location**: `mcp-server/src/npl_mcp/scripts/wrapper.py:90-114`

#### Root Cause Analysis

The `git_tree_depth` wrapper calls the shell script but returns empty string. Potential causes:

1. **Working directory mismatch**: Script uses `git rev-parse --show-toplevel` to find repo root, but wrapper may be calling from different cwd
2. **Path resolution**: The wrapper passes an absolute path, but script expects path relative to repo root
3. **Script execution context**: The script does `cd "$ROOT"` which affects subsequent commands

The shell script (`core/scripts/git-tree-depth`) requires:
- Must be run inside a git repository
- Path argument is relative to repo root after `cd "$ROOT"`

#### Fix Specification

1. **Update wrapper to handle absolute paths** (`wrapper.py:90-114`):
   ```python
   async def git_tree_depth(path: str) -> str:
       script_path = _find_script("git-tree-depth")
       if not script_path:
           raise FileNotFoundError("git-tree-depth script not found")

       # Convert absolute path to relative if needed
       target_path = Path(path)
       if target_path.is_absolute():
           # Try to make it relative to current working directory
           try:
               target_path = target_path.relative_to(Path.cwd())
           except ValueError:
               pass  # Keep absolute if not under cwd

       result = subprocess.run(
           [str(script_path), str(target_path)],
           capture_output=True,
           text=True,
           cwd=str(Path(path).parent) if Path(path).is_absolute() else None,
           check=True
       )
       return result.stdout
   ```

2. **Alternative fix - modify script to handle absolute paths**:
   The script could be modified to detect and handle absolute paths by converting them to relative paths from the git root.

#### Acceptance Criteria

- [ ] AC-002.1: `git_tree_depth("/absolute/path")` returns directory listing with depth
- [ ] AC-002.2: Output format matches expected: `<dir> <depth>` per line
- [ ] AC-002.3: Works for paths inside git repositories
- [ ] AC-002.4: Returns appropriate error for non-git paths

#### Test Cases

```python
async def test_git_tree_depth_absolute_path():
    result = await git_tree_depth("/Volumes/OSX-Extended/workspace/ai/npl/mcp-server")
    assert result.strip() != ""
    lines = result.strip().split("\n")
    assert len(lines) > 0
    # Each line should have format: "path depth"
    for line in lines:
        parts = line.split()
        assert len(parts) == 2
        assert parts[1].isdigit()
```

---

### FR-003: npl_load Wildcard Empty Result (P2 - Low)

**Severity**: Low
**Location**: `mcp-server/src/npl_mcp/scripts/wrapper.py:117-156`

#### Root Cause Analysis

The `npl_load` wrapper returns empty for wildcard patterns like `*`. The underlying `npl-load` script supports wildcards, but:

1. **Path resolution**: The wrapper may not be finding the script correctly
2. **Search paths**: The `npl-load` script searches specific directories that may not exist in the MCP server context
3. **Output filtering**: The script may be finding no matches due to search path configuration

The `npl-load` script searches these paths for metadata:
- `./.npl/meta`
- `~/.npl/meta`
- `/etc/npl/meta`

#### Fix Specification

1. **Verify search paths exist or provide fallback** (`wrapper.py`):
   ```python
   async def npl_load(resource_type: str, items: str, skip: Optional[str] = None) -> str:
       # Set NPL_HOME if not already set to help script find resources
       env = os.environ.copy()
       if 'NPL_HOME' not in env:
           # Try to locate NPL home relative to this package
           possible_homes = [
               Path(__file__).parents[4],  # mcp-server/../..
               Path.cwd(),
           ]
           for home in possible_homes:
               if (home / '.npl').exists() or (home / 'npl.md').exists():
                   env['NPL_HOME'] = str(home)
                   break

       result = subprocess.run(cmd, capture_output=True, text=True, check=True, env=env)
       return result.stdout
   ```

2. **Add diagnostic output for empty results**:
   ```python
   if not result.stdout.strip():
       # Log search paths for debugging
       return f"No results found for pattern '{items}' of type '{resource_type}'"
   ```

#### Acceptance Criteria

- [ ] AC-003.1: `npl_load("m", "*")` returns all metadata files or informative message
- [ ] AC-003.2: Wildcard patterns work for all resource types (c, m, s)
- [ ] AC-003.3: Specific item requests continue to work

#### Test Cases

```python
async def test_npl_load_wildcard():
    result = await npl_load("c", "syntax")  # Known component
    assert "syntax" in result.lower() or "not found" in result.lower()

async def test_npl_load_meta_wildcard():
    result = await npl_load("m", "*")
    # Should return content or informative message
    assert len(result) > 0
```

---

### FR-004: Reply Indicator Missing in Chat UI (P3 - Low)

**Severity**: Low
**Location**: `mcp-server/src/npl_mcp/unified.py:746-751`

#### Root Cause Analysis

The chat UI renders messages but does not check for or display `reply_to_id` field in event data.

Current rendering:
```python
if event_type == 'message':
    content += f'''<div class="message">
        <span class="author">{_escape_html(persona)}</span>
        <span class="time">{timestamp}</span>
        <div class="content">{_escape_html(data.get('message', ''))}</div>
    </div>'''
```

The `reply_to_id` is available in `data` but not used.

#### Fix Specification

1. **Check for reply_to_id and render indicator** (`unified.py:746-751`):
   ```python
   if event_type == 'message':
       reply_indicator = ""
       reply_to_id = data.get('reply_to_id')
       if reply_to_id:
           reply_indicator = f'<div class="reply-indicator">Replying to message #{reply_to_id}</div>'

       content += f'''<div class="message">
           <span class="author">{_escape_html(persona)}</span>
           <span class="time">{timestamp}</span>
           {reply_indicator}
           <div class="content">{_escape_html(data.get('message', ''))}</div>
       </div>'''
   ```

2. **Add CSS for reply indicator** (`unified.py` in `_base_html`):
   ```css
   .reply-indicator {
       font-size: 0.8rem;
       color: var(--text-secondary);
       border-left: 2px solid var(--accent);
       padding-left: 8px;
       margin: 4px 0;
   }
   ```

#### Acceptance Criteria

- [ ] AC-004.1: Reply messages show "Replying to message #N" indicator
- [ ] AC-004.2: Reply indicator is visually distinct from message content
- [ ] AC-004.3: Non-reply messages render normally (no indicator)

---

### FR-005: Assigned-To Not Shown for Todos (P3 - Low)

**Severity**: Low
**Location**: `mcp-server/src/npl_mcp/unified.py:752-757`

#### Root Cause Analysis

Todo events have `assigned_to` field but it's not rendered:

```python
elif event_type in ('todo', 'todo_create'):
    content += f'''<div class="message">
        <span class="author">{_escape_html(persona)}</span>
        <span class="time">{timestamp}</span>
        <div class="content">📋 {_escape_html(data.get('description', ''))}</div>
    </div>'''
```

#### Fix Specification

```python
elif event_type in ('todo', 'todo_create'):
    assigned_to = data.get('assigned_to')
    assigned_text = f" (assigned to @{_escape_html(assigned_to)})" if assigned_to else ""
    content += f'''<div class="message">
        <span class="author">{_escape_html(persona)}</span>
        <span class="time">{timestamp}</span>
        <div class="content">📋 {_escape_html(data.get('description', ''))}{assigned_text}</div>
    </div>'''
```

#### Acceptance Criteria

- [ ] AC-005.1: Todos with `assigned_to` show "(assigned to @persona)"
- [ ] AC-005.2: Todos without `assigned_to` render normally
- [ ] AC-005.3: Assigned persona name is properly escaped

---

### FR-006: Emoji Reactions Not Grouped (P3 - Low)

**Severity**: Low
**Location**: `mcp-server/src/npl_mcp/unified.py:758-764`

#### Root Cause Analysis

Each emoji reaction is rendered as a separate message entry rather than being grouped with its target message. This requires either:

1. Frontend aggregation (group reactions by `target_event_id` during render)
2. Backend aggregation (return reactions as sub-objects of their target messages)

#### Fix Specification

Option 1 - Frontend grouping (simpler, recommended):

```python
def _render_chat_room(room: dict, events: list, session_id: str = None) -> str:
    # Pre-process: group reactions by target
    reactions_by_target = {}
    message_events = []

    for e in events:
        if e.get('event_type') == 'emoji_reaction':
            target_id = e.get('data', {}).get('target_event_id')
            if target_id:
                if target_id not in reactions_by_target:
                    reactions_by_target[target_id] = []
                reactions_by_target[target_id].append(e)
        else:
            message_events.append(e)

    # Render messages with their reactions
    for e in message_events:
        # ... render message ...
        event_id = e.get('id')
        if event_id in reactions_by_target:
            reaction_emojis = [r.get('data', {}).get('emoji', '') for r in reactions_by_target[event_id]]
            content += f'<div class="reactions">{" ".join(reaction_emojis)}</div>'
```

#### Acceptance Criteria

- [ ] AC-006.1: Reactions appear grouped with their target message
- [ ] AC-006.2: Multiple reactions to same message show as emoji row
- [ ] AC-006.3: Reaction attribution (who reacted) is visible on hover or click

---

## Priority Matrix

| ID | Issue | Priority | Effort | Dependencies |
|:---|:------|:---------|:-------|:-------------|
| FR-001 | Artifact-Session Association | P0 | Medium | None |
| FR-002 | git_tree_depth Empty Result | P2 | Low | None |
| FR-003 | npl_load Wildcard Empty | P2 | Low | None |
| FR-004 | Reply Indicator Missing | P3 | Low | None |
| FR-005 | Assigned-To Not Shown | P3 | Low | None |
| FR-006 | Reactions Not Grouped | P3 | Medium | None |

---

## Implementation Order

1. **Phase 1 (P0)**: FR-001 - Critical for session management functionality
2. **Phase 2 (P2)**: FR-002, FR-003 - Script wrapper fixes
3. **Phase 3 (P3)**: FR-004, FR-005, FR-006 - UI enhancements

---

## Regression Prevention

### Testing Strategy

1. **Unit Tests**: Add test cases for each fix
2. **Integration Tests**: Verify end-to-end flows
3. **Manual Verification**: Test via MCP client and web UI

### Code Review Checklist

- [ ] Parameter changes are backward compatible
- [ ] Database queries handle NULL session_id
- [ ] HTML output is properly escaped
- [ ] Error messages are informative

---

## Files to Modify

| File | Changes |
|:-----|:--------|
| `mcp-server/src/npl_mcp/artifacts/manager.py` | Add `session_id` parameter to `create_artifact` |
| `mcp-server/src/npl_mcp/unified.py` | Update MCP tool, fix UI rendering |
| `mcp-server/src/npl_mcp/scripts/wrapper.py` | Fix path handling for scripts |
| `mcp-server/tests/test_basic.py` | Add test cases |

---

## Success Metrics

| Metric | Target | Measurement |
|:-------|:-------|:------------|
| All acceptance criteria pass | 100% | Test suite |
| No regression in existing tests | 22+ tests pass | pytest |
| Session artifact_count accurate | 100% | Manual verification |

---

## Open Questions

| # | Question | Owner | Due | Status |
|:--|:---------|:------|:----|:-------|
| 1 | Should reactions show reactor persona name? | UX | - | Open |
| 2 | Should reply indicator show quoted text? | UX | - | Open |
| 3 | Performance impact of frontend reaction grouping? | Eng | - | Open |
