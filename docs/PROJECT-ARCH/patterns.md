# Code Patterns
Named patterns and conventions used in NoizuPromptLingo.

## Pattern Catalog

| Pattern | Category | Usage Locations |
|:--------|:---------|:----------------|
| Markdown-as-Code | architectural | `/npl/`, `/core/agents/` |
| Hierarchical Loading | architectural | `/core/scripts/npl-load` |
| Event-Sourced Chat | behavioral | `/mcp-server/src/npl_mcp/chat/` |
| Manager/Service | structural | `/mcp-server/src/npl_mcp/artifacts/`, `/chat/` |
| Base64 Content Transfer | structural | `/mcp-server/src/npl_mcp/server.py` |
| Unicode Boundary Markers | syntactic | `/npl/`, `/core/agents/` |
| Directive Pattern | syntactic | `/npl/directive.md`, `/npl/directive/` |
| YAML Frontmatter Metadata | structural | `/core/agents/*.md` |

---

## Markdown-as-Code

**category**
: architectural

**rationale**
: LLM agents are defined through structured markdown files rather than traditional code. This approach leverages the fact that markdown is both human-readable and machine-parseable, making agent definitions simultaneously documentation and executable specifications. The LLM interprets markdown structure, headings, and special syntax blocks as behavioral instructions.

**when-to-use**
: Define agent capabilities, behavioral constraints, syntax rules, personas, and any specification that will be interpreted by an LLM. Use when you need versioned, human-readable agent definitions that can be loaded dynamically.

**when-not-to-use**
: Traditional programming logic requiring runtime execution. Binary data processing. Performance-critical computational tasks where compiled code is necessary.

### Implementation

The pattern uses structured markdown with special syntax elements:

```markdown
---
name: agent-name
description: Agent purpose and capabilities
model: inherit
color: category-color
---

npl-load c "syntax,agent,directive" --skip {@npl.def.loaded}

---

[unicode-start]agent-name|type|NPL@version[unicode-end]
# Agent Title
Brief description focusing on core value proposition.

[attention-alias] @agent-name primary-keywords

## Core Functions
- Behavioral specifications
- Capability definitions

[unicode-end-block]agent-name[unicode-end-block]
```

### Usage Examples

**Agent Definition**
: Location: `/github/ai/NoizuPromptLingo/core/agents/npl-gopher-scout.md`

```markdown
---
name: npl-gopher-scout
description: Elite reconnaissance agent for systematic exploration
model: inherit
color: orange
---

You will need to load the following before proceeding.

npl-load c "syntax,agent,directive,formatting,pumps.intent" --skip {@npl.def.loaded}

---

[unicode-boundary]npl-gopher-scout|reconnaissance|NPL@1.0[unicode-boundary]
# Gopher Scout
Elite reconnaissance specialist for navigating complex systems.

[attention-alias] @npl-gopher-scout explore analyze synthesize

## Mission Profile

**role**
: Elite reconnaissance specialist for codebases

**mission**
: Navigate -> Understand -> Distill -> Report
```

### Variations

**Syntax Definition**
: Files in `/npl/` define syntax rules rather than agent behavior. They follow similar markdown structure but focus on documenting syntax patterns, usage examples, and processing rules. Example: `/npl/syntax.md` defines placeholder syntax, attention markers, and in-fill patterns.

**Persona Definition**
: Persona files use the markdown-as-code pattern but emphasize character traits, personality, and behavioral consistency rather than functional capabilities. Example: `/core/agents/npl-persona.md`.

---

## Hierarchical Loading

**category**
: architectural

**rationale**
: NPL resources (components, metadata, styles) may exist at multiple levels: organization-wide, project-specific, user preferences, and system defaults. The hierarchical loading pattern searches paths in priority order and tracks what has been loaded to prevent duplicates. This enables customization at any level while inheriting defaults from parent paths.

**when-to-use**
: Loading NPL components, agent definitions, metadata, style guides, personas, PRDs, or any resource that may have project-level overrides of system defaults. Use when you need flexible configuration with fallback chains.

**when-not-to-use**
: Loading resources that must come from a single authoritative source. When load-order dependency is critical and override behavior would cause issues.

### Implementation

From `/github/ai/NoizuPromptLingo/core/scripts/npl-load`:

```python
def get_search_paths(self, resource_type='component'):
    """Get search paths based on resource type"""
    paths = []

    # Platform-specific global config
    if sys.platform.startswith('win'):
        global_npl = Path(os.environ.get('PROGRAMDATA')) / 'npl'
    elif sys.platform == 'darwin':
        global_npl = Path('/Library/Application Support/npl')
    else:
        global_npl = Path('/etc/npl')

    if resource_type == 'component':
        if self.npl_home:
            paths.append(Path(self.npl_home) / 'npl')
        paths.extend([
            Path('./.npl/npl'),           # Project local
            Path.home() / '.npl/npl',     # User home
            global_npl / 'npl'            # System global
        ])
    # ... similar patterns for meta, style, agent, etc.

    return paths
```

### Usage Examples

**Component Loading**
: Location: `/github/ai/NoizuPromptLingo/core/scripts/npl-load`

```bash
# Load core components with skip tracking
npl-load c "syntax,agent,directive" --skip "syntax"

# Load agent definitions
npl-load agent npl-gopher-scout

# Load specifications
npl-load spec project-arch-spec
```

### Variations

**Environment Variable Override**
: `$NPL_HOME`, `$NPL_META`, `$NPL_STYLE_GUIDE` environment variables can override the default search paths, allowing organizations to set company-wide standards.

**Patch Files**
: The loader supports `.patch.md` files that extend base definitions without replacing them. Patches are applied after the base file is loaded.

**Skip Tracking**
: The `--skip` flag with `{@npl.def.loaded}` syntax prevents reloading already-loaded components across multiple npl-load invocations.

---

## Event-Sourced Chat

**category**
: behavioral

**rationale**
: All chat interactions are stored as immutable events with typed payloads. This enables complete audit trails, replay capability, and flexible querying of chat history. Events capture not just messages but also reactions, artifact shares, todo creation, and membership changes.

**when-to-use**
: Building collaborative features where history matters. When you need to reconstruct conversation state from events. Systems requiring audit trails or notification generation from interaction history.

**when-not-to-use**
: Simple request-response patterns without history requirements. Real-time streaming where event storage adds unacceptable latency.

### Implementation

From `/github/ai/NoizuPromptLingo/mcp-server/src/npl_mcp/chat/rooms.py`:

```python
async def _create_event(
    self,
    room_id: int,
    event_type: str,
    persona: str,
    data: Dict[str, Any],
    reply_to_id: Optional[int] = None
) -> int:
    """Create a chat event with JSON-encoded payload."""
    data_json = json.dumps(data)

    cursor = await self.db.execute(
        """
        INSERT INTO chat_events
        (room_id, event_type, persona, data, reply_to_id)
        VALUES (?, ?, ?, ?, ?)
        """,
        (room_id, event_type, persona, data_json, reply_to_id)
    )

    return cursor.lastrowid
```

### Usage Examples

**Message Event**
: Location: `/github/ai/NoizuPromptLingo/mcp-server/src/npl_mcp/chat/rooms.py`

```python
async def send_message(
    self, room_id: int, persona: str, message: str,
    reply_to_id: Optional[int] = None
) -> Dict[str, Any]:
    """Send a message, creating event with mentions extracted."""
    mentions = self._extract_mentions(message)

    event_data = {
        "message": message,
        "mentions": mentions
    }

    event_id = await self._create_event(
        room_id=room_id,
        event_type="message",
        persona=persona,
        data=event_data,
        reply_to_id=reply_to_id
    )

    # Create notifications for mentioned personas
    for mentioned in mentions:
        if mentioned != persona:
            await self._create_notification(
                persona=mentioned,
                event_id=event_id,
                notification_type="mention"
            )
```

### Variations

**Event Types**
: The schema supports multiple event types: `message`, `emoji_reaction`, `artifact_share`, `todo_create`, `persona_join`, `persona_leave`. Each type has its own payload structure stored in the `data` JSON field.

**Notification Generation**
: Events that mention other personas or share artifacts automatically generate notification records, enabling async notification delivery.

---

## Manager/Service Pattern

**category**
: structural

**rationale**
: Each domain area (artifacts, reviews, chat) has a dedicated manager class that encapsulates all business logic and database operations for that domain. This provides clean separation of concerns, testable units, and a consistent interface for the MCP server layer.

**when-to-use**
: Organizing business logic in the MCP server. When you have distinct domain areas that each require CRUD operations plus domain-specific logic. Systems where you want to separate HTTP/MCP layer from business logic.

**when-not-to-use**
: Simple scripts without multiple domain areas. Systems where domain boundaries are unclear or highly interconnected.

### Implementation

From `/github/ai/NoizuPromptLingo/mcp-server/src/npl_mcp/artifacts/manager.py`:

```python
class ArtifactManager:
    """Manages artifacts and their revisions."""

    def __init__(self, db: Database):
        """Initialize artifact manager with database dependency."""
        self.db = db

    async def create_artifact(
        self,
        name: str,
        artifact_type: str,
        file_content: bytes,
        filename: str,
        created_by: Optional[str] = None,
        purpose: Optional[str] = None
    ) -> Dict[str, Any]:
        """Create a new artifact with initial revision."""
        # Check existence, create record, save file, return result
        ...

    async def add_revision(self, artifact_id: int, ...) -> Dict[str, Any]:
        """Add a new revision to an artifact."""
        ...

    async def get_artifact(self, artifact_id: int, ...) -> Dict[str, Any]:
        """Get artifact and its revision content."""
        ...
```

### Usage Examples

**Server Integration**
: Location: `/github/ai/NoizuPromptLingo/mcp-server/src/npl_mcp/server.py`

```python
# Initialize managers at startup
@mcp.lifespan()
async def app_lifespan():
    global db, artifact_manager, review_manager, chat_manager

    db = Database()
    await db.connect()

    artifact_manager = ArtifactManager(db)
    review_manager = ReviewManager(db)
    chat_manager = ChatManager(db)

    yield

    await db.disconnect()


# MCP tools delegate to managers
@mcp.tool()
async def create_artifact(...) -> dict:
    file_content = base64.b64decode(file_content_base64)
    return await artifact_manager.create_artifact(
        name=name,
        artifact_type=artifact_type,
        file_content=file_content,
        ...
    )
```

### Variations

**ReviewManager**
: Handles review sessions with inline comments and overlay annotations. Located in `/mcp-server/src/npl_mcp/artifacts/reviews.py`.

**ChatManager**
: Manages chat rooms, events, and notifications. Located in `/mcp-server/src/npl_mcp/chat/rooms.py`.

---

## Base64 Content Transfer

**category**
: structural

**rationale**
: MCP protocol transfers data as JSON. Binary file content (images, documents, arbitrary files) must be encoded for transport. Base64 encoding provides a reliable, standard way to embed binary content in string fields. Encoding happens at the MCP boundary, with managers operating on raw bytes internally.

**when-to-use**
: Transferring binary file content through MCP tools. When file content must pass through JSON-based protocols. Artifact upload/download operations.

**when-not-to-use**
: Internal file operations where bytes can be passed directly. Large files where streaming would be more efficient than full encoding.

### Implementation

From `/github/ai/NoizuPromptLingo/mcp-server/src/npl_mcp/server.py`:

```python
@mcp.tool()
async def create_artifact(
    name: str,
    artifact_type: str,
    file_content_base64: str,  # Base64 encoded at boundary
    filename: str,
    created_by: Optional[str] = None,
    purpose: Optional[str] = None
) -> dict:
    """Create artifact - decodes base64 at MCP boundary."""
    file_content = base64.b64decode(file_content_base64)
    return await artifact_manager.create_artifact(
        name=name,
        artifact_type=artifact_type,
        file_content=file_content,  # Raw bytes to manager
        filename=filename,
        created_by=created_by,
        purpose=purpose
    )
```

### Usage Examples

**Artifact Retrieval with Encoding**
: Location: `/github/ai/NoizuPromptLingo/mcp-server/src/npl_mcp/artifacts/manager.py`

```python
async def get_artifact(
    self, artifact_id: int, revision: Optional[int] = None
) -> Dict[str, Any]:
    """Get artifact - returns base64 encoded content."""
    # ... fetch revision data ...

    # Read file content as bytes
    file_path = self.db.data_dir / revision_data["file_path"]
    with open(file_path, 'rb') as f:
        file_content = f.read()

    return {
        "artifact_id": artifact_id,
        "artifact_name": artifact["name"],
        # Encode for JSON transport
        "file_content": base64.b64encode(file_content).decode('utf-8'),
        "file_path": str(file_path),
        ...
    }
```

### Variations

**Consistent Boundary**
: All encoding/decoding happens at the MCP tool layer. Internal manager methods work with raw bytes, keeping the encoding concern isolated to the transport boundary.

---

## Unicode Boundary Markers

**category**
: syntactic

**rationale**
: NPL uses Unicode corner brackets to clearly delineate agent definitions and special sections. These markers provide unambiguous start/end boundaries that are visually distinct and unlikely to appear in regular content. The format encodes agent name, type, and version in the opening marker.

**when-to-use**
: Defining agent boundaries in markdown files. Creating special NPL sections like runtime flags or secure prompts. Any content that needs clear, machine-parseable boundaries with semantic metadata.

**when-not-to-use**
: Regular prose content. Code examples within documentation. Content that doesn't require explicit boundary detection.

### Implementation

The pattern uses Unicode corner brackets with embedded metadata:

```markdown
Opening: [corner-open]agent-name|type|NPL@version[corner-close]
Closing: [corner-end-open]agent-name[corner-end-close]

Actual Unicode:
Opening: U+231C + content + U+231D
Closing: U+231E + content + U+231F
```

### Usage Examples

**Agent Definition Boundaries**
: Location: `/github/ai/NoizuPromptLingo/npl/agent.md`

```markdown
[U+231C]sports-news-agent|service|NPL@1.0[U+231D]
# Sports News Agent
Provides up-to-date sports news and facts when prompted.

## Behavior
- Responds to queries about current sports events
- Provides factual information with source verification

[U+231E]sports-news-agent[U+231F]
```

### Variations

**Runtime Flags Block**
: Uses emoji prefix within markers: `[U+231C]flag-emoji ... [U+231F]` for behavior modification settings.

**Agent Extension**
: Extension blocks use `extend:` prefix: `[U+231C]extend:agent-name|service|NPL@1.0[U+231D]`.

**Secure Prompt**
: Highest-precedence blocks use lock emoji: `[U+231C]lock-emoji ... [U+231F]` for immutable instructions.

---

## Directive Pattern

**category**
: syntactic

**rationale**
: Directives provide fine-grained control over agent behavior and output formatting through structured command syntax. The pattern uses Unicode angle brackets with emoji prefixes to create visually distinct, semantically meaningful instruction blocks that extend beyond basic prompt text.

**when-to-use**
: Specialized output formatting (tables, templates). Time-based or conditional execution. Interactive element choreography. Section references and unique identifier management. When you need structured behavior control beyond prose instructions.

**when-not-to-use**
: Simple prose instructions. When basic NPL syntax suffices. Content where special formatting would add complexity without benefit.

### Implementation

From `/github/ai/NoizuPromptLingo/npl/directive.md`:

```markdown
Syntax: [angle-open]emoji: instruction[angle-close]

With elaboration: [angle-open]emoji: instruction | elaboration[angle-close]

Actual Unicode:
Opening: U+27EA
Closing: U+27EB
```

### Usage Examples

**Table Formatting Directive**
: Location: `/github/ai/NoizuPromptLingo/npl/directive.md`

```markdown
[U+27EA]calendar-emoji: (#:left, prime:right, english:center label Numbers) | first 5 prime numbers[U+27EB]
```

**Interactive Behavior Directive**
: Location: `/github/ai/NoizuPromptLingo/core/agents/npl-gopher-scout.md`

```markdown
[U+27EA]map-emoji: exploration-path[U+27EB] Define the exploration trajectory
[U+27EA]search-emoji: focus-area[U+27EB] Narrow investigation to specific component
[U+27EA]chart-emoji: depth-level[U+27EB] Set analysis depth (survey|summary|deep)
```

### Variations

**Directive Types**
: Different emoji prefixes indicate directive purpose:
- Calendar emoji: Table formatting with column alignments
- Hourglass emoji: Temporal control and scheduled actions
- Arrow emoji: Template integration with data binding
- Rocket emoji: Interactive element choreography
- ID emoji: Unique identifier generation
- Book emoji: Explanatory annotations
- Folder emoji: Section references

---

## YAML Frontmatter Metadata

**category**
: structural

**rationale**
: Agent and resource files begin with YAML frontmatter that provides structured metadata for discovery, filtering, and categorization. This pattern enables tools to extract agent properties without parsing the full markdown content, supporting features like agent listing with metadata display.

**when-to-use**
: Agent definition files requiring discoverable metadata. Resources that need categorization, versioning, or property-based filtering. Files that tools should be able to index without full content parsing.

**when-not-to-use**
: Pure syntax documentation without agent identity. Content that doesn't require external tool processing. Files where frontmatter would add unnecessary overhead.

### Implementation

From `/github/ai/NoizuPromptLingo/core/scripts/npl-load`:

```python
def extract_agent_metadata(self, content: str) -> Dict[str, Any]:
    """Extract YAML frontmatter metadata from agent content"""
    metadata = {}

    if content.startswith('---'):
        parts = content.split('---', 2)
        if len(parts) >= 3:
            try:
                metadata = yaml.safe_load(parts[1])
                if metadata is None:
                    metadata = {}
            except yaml.YAMLError:
                metadata = {}

    return metadata
```

### Usage Examples

**Agent Frontmatter**
: Location: `/github/ai/NoizuPromptLingo/core/agents/npl-gopher-scout.md`

```yaml
---
name: npl-gopher-scout
description: Elite reconnaissance agent for systematic exploration
model: inherit
color: orange
---
```

**Frontmatter Usage in Discovery**
: Location: `/github/ai/NoizuPromptLingo/core/scripts/npl-load`

```python
def discover_agents(self) -> Dict[str, Dict[str, Any]]:
    """Discover all agents across search paths with metadata"""
    agents = {}
    for base_path in self.get_search_paths('agent'):
        for agent_file in base_path.glob('*.md'):
            agent_name = agent_file.stem
            content = agent_file.read_text()
            metadata = self.extract_agent_metadata(content)
            agents[agent_name] = {
                'path': agent_file,
                'metadata': metadata,
                'content': content
            }
    return agents
```

### Variations

**Extended Metadata**
: Some agents include additional frontmatter fields like `version`, `categories`, `dependencies`, and custom properties for specialized tooling.

**CLI Listing**
: The `npl-load agent --list --verbose` command displays frontmatter metadata for agent discovery and selection.

---

## Pattern Dependencies

The following diagram shows how patterns relate to each other:

```
+-------------------------+
| Markdown-as-Code        |
+-------------------------+
        |
        v
+-------------------------+     +-------------------------+
| YAML Frontmatter        |     | Unicode Boundary        |
| Metadata                |     | Markers                 |
+-------------------------+     +-------------------------+
        |                               |
        v                               v
+-------------------------+     +-------------------------+
| Hierarchical Loading    |     | Directive Pattern       |
+-------------------------+     +-------------------------+
        |
        v
+-------------------------+
| Manager/Service Pattern |
+-------------------------+
        |
        v
+-------------------------+     +-------------------------+
| Event-Sourced Chat      |     | Base64 Content Transfer |
+-------------------------+     +-------------------------+
```

---

## Pattern Application Guidelines

### Adding New Agents

1. Create markdown file with YAML frontmatter (name, description, model, color)
2. Add npl-load directive for required components
3. Define agent with Unicode boundary markers
4. Place in appropriate directory for hierarchical loading discovery

### Extending MCP Server

1. Create new Manager class following Manager/Service pattern
2. Initialize manager in server lifespan handler
3. Define MCP tools that delegate to manager methods
4. Use Base64 encoding for any binary content at tool boundary

### Creating New Directive Types

1. Document directive syntax in `/npl/directive/` with emoji prefix
2. Define purpose, parameters, and processing behavior
3. Add examples showing correct usage
4. Update directive catalog in `/npl/directive.md`
