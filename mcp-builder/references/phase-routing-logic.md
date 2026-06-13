# Phase Routing Logic

Detailed decision tree for routing MCP server build requests to the correct phase and sub-skill.

---

## Intent Classification Heuristics

Before routing to a phase, classify the user's primary intent. Multiple intents may coexist -- route by the highest-priority unresolved intent.

### Primary Intent Categories

| Category | Detection Signals | Priority |
|---|---|---|
| **Learn** | "what is MCP", "how does", "explain", "overview", "compare" | Lowest (resolve first, then re-classify) |
| **Design** | "design the interface", "what tools should", "API surface", "spec" | High |
| **Prototype** | "build", "create", "make", "quick", "try out", "proof of concept" | High |
| **Production** | "deploy", "Docker", "production", "harden", "CI/CD", "scale" | High |
| **Virtual** | "combine", "compose", "unified", "aggregate", "wrap multiple" | High |
| **Debug** | "broken", "error", "not working", "timeout", "connection refused" | Highest (handle immediately) |
| **Distribute** | "publish", "registry", "npm package", "share", "open source" | Medium |

### Multi-Intent Resolution

When a user expresses multiple intents (e.g., "build and deploy an MCP server"):

1. Handle **Debug** immediately if present -- nothing else matters if the server is broken.
2. Resolve **Learn** first if the user lacks MCP familiarity.
3. For build intents, sequence as: Design --> Prototype --> Production --> Distribute.
4. **Virtual** is a parallel track -- do not mix with Phases 1-2 unless the user explicitly wants to prototype a virtual MCP.

---

## Phase Detection Rules

### Phase 1: Prototype

**Enter Phase 1 when:**
- User has an idea but no working code
- User has a rough list of tools but no formal specification
- User wants to "try MCP" or "see if this works"
- User has never built an MCP server before
- User cannot articulate exact input/output schemas for their tools

**Phase 1 constraints:**
- stdio transport only
- No authentication
- No Docker or deployment infrastructure
- No automated tests (manual testing via client)
- Maximum 5 tools
- Target: working server in 1-2 hours

**Exit Phase 1 when:**
- Server starts and all tools respond correctly
- User has tested with a real client (Claude Desktop, etc.)
- User confirms the tool interface "feels right"
- Tool inputs and outputs are stable (no more "actually, let me change that parameter")

### Phase 2: Production

**Enter Phase 2 when:**
- User has a validated prototype (Phase 1 exit criteria met)
- User has an existing specification document (skip Phase 1)
- User's existing server works but needs hardening
- User mentions deployment, Docker, CI/CD, auth, or monitoring

**Phase 2 sub-phases:**

1. **Specification review** (trl-mcp-architect)
   - Formalize tool schemas from prototype
   - Define error taxonomy
   - Specify auth model
   - Run security threat model
   - Output: complete specification document

2. **Implementation** (trl-mcp-forge)
   - Generate production scaffold from specification
   - Implement tool handlers with full error handling
   - Add automated tests
   - Configure transport (usually Streamable HTTP)
   - Package in Docker
   - Set up CI/CD

3. **Security audit** (trl-mcp-builder coordinator)
   - Run `references/security-checklist.md` against implementation
   - Verify all checklist items pass or are explicitly deferred with rationale

**Exit Phase 2 when:**
- All specification checklist items are addressed
- Test suite passes
- Security checklist passes
- Server deploys successfully to target environment
- At least one client connects and executes all tools successfully

### Phase 3: Virtual MCP

**Enter Phase 3 when:**
- User wants to compose multiple existing MCP servers
- User wants an agent to present a unified tool interface without building a real server
- User's requirements span multiple existing servers or APIs
- User mentions "virtual", "composed", "aggregated", or "unified interface"

**Phase 3 does not require Phases 1-2 as prerequisites.** It is a separate track.

**Phase 3 sub-phases:**

1. **Interface design** (trl-mcp-architect)
   - Define the Published tool catalog
   - Map Published tools to Backing tools (real MCP servers) and Stub tools (future)
   - Define version contracts

2. **Composition** (trl-mcp-builder coordinator)
   - Set up the tool routing layer
   - Implement the self-governance protocol
   - Configure self-audit methodology

3. **Validation** (trl-mcp-builder coordinator)
   - Run contract check against all Published tools
   - Verify Backing tools are accessible
   - Execute self-audit report

---

## Re-Entry Patterns

Users frequently move between phases non-linearly. Handle these transitions explicitly.

### Forge-to-Architect Feedback Loop

**Trigger:** During Phase 2 implementation (trl-mcp-forge), a gap is discovered in the specification.

**Examples:**
- Tool handler reveals an edge case the spec did not address
- External API returns data shapes not anticipated in the schema
- Auth model is insufficient for the deployment target
- A tool needs to be split into two or merged with another

**Action:**
1. Pause implementation at the current tool
2. Route back to trl-mcp-architect with the specific gap description
3. trl-mcp-architect updates the specification
4. Resume implementation from the modified spec
5. Do NOT restart implementation from scratch -- only re-implement affected tools

### Production-to-Prototype Regression

**Trigger:** During Phase 2, the fundamental tool interface proves wrong.

**Examples:**
- User feedback shows the tool decomposition does not match user mental models
- Performance testing reveals a tool is too coarse-grained (single call too slow)
- Security review shows a tool exposes too much surface area

**Action:**
1. Acknowledge this is a Phase 1 regression, not a Phase 2 failure
2. Return to Phase 1 with the new understanding
3. Build a revised prototype with the corrected interface
4. Re-validate with the user
5. Re-enter Phase 2 with the revised spec

### Virtual-to-Real Promotion

**Trigger:** A Virtual MCP tool proves so useful that it should become a real MCP server.

**Action:**
1. Extract the Published tool interface from the Virtual MCP contract
2. Use it as the specification input for Phase 2 (skip Phase 1 -- the interface is already validated)
3. Build the real server via trl-mcp-forge
4. Update the Virtual MCP to use the new real server as a Backing tool

---

## Fallback Rules

### When Classification is Ambiguous

If the user's intent does not clearly map to a phase:

1. Default to **Phase 1** (prototype). It is always safe to start with a quick prototype.
2. Ask one clarifying question: "Do you have a working MCP server already, or are we starting from scratch?"
3. If the user says "I have code but it's not MCP," treat as Phase 1 (the MCP interface is new even if the logic exists).

### When the User Resists Structure

If the user wants to "just build it" without phases:

1. Do not enforce phases as gatekeeping. The phases are a mental model, not bureaucracy.
2. Compress Phase 1 + Phase 2 into a single flow: scaffold directly with production patterns, but start with stdio for fast iteration.
3. Still run the security checklist before any deployment.

### When Requirements Exceed MCP Capabilities

If the user wants something MCP cannot do (e.g., bidirectional streaming, server-initiated tool calls to the client, binary protocol):

1. State clearly what MCP does and does not support, referencing the protocol spec.
2. Suggest alternatives (direct API, WebSocket server, gRPC service).
3. If the core use case fits MCP with minor workarounds, propose the workaround.
4. If it fundamentally does not fit, say so -- do not force MCP where it does not belong.
