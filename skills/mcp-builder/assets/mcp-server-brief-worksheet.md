# MCP Server Brief Worksheet

Intake form for scoping a new MCP server project. Fill this out before entering the build workflow.

> After completing this worksheet, proceed to the phase routing logic in `mcp-builder/SKILL.md` to determine your starting phase.

---

## 1. Problem Statement

_What problem does this MCP server solve? What can an LLM agent do with these tools that it cannot do today?_

**Problem:**


**Who has this problem:**


**Current workaround (if any):**


---

## 2. Target Consumers

_Which LLM clients will use this server?_

- [ ] Claude Desktop
- [ ] Claude Code
- [ ] VS Code (GitHub Copilot)
- [ ] Cursor
- [ ] Continue
- [ ] Cline
- [ ] Windsurf
- [ ] Custom client (describe: _______________)

**Primary client for initial testing:**


---

## 3. Proposed Tools

_List the tools this server will expose. For each, provide a name, one-sentence description, and rough parameter sketch._

### Tool 1

| Field | Value |
|---|---|
| **Name** | |
| **Description** | |
| **Parameters** | |
| **Returns** | |
| **Error cases** | |

### Tool 2

| Field | Value |
|---|---|
| **Name** | |
| **Description** | |
| **Parameters** | |
| **Returns** | |
| **Error cases** | |

### Tool 3

| Field | Value |
|---|---|
| **Name** | |
| **Description** | |
| **Parameters** | |
| **Returns** | |
| **Error cases** | |

_(Add more tools as needed)_

---

## 4. Resources (Optional)

_Will this server expose readable data resources? List URI patterns._

| URI Pattern | Description | MIME Type |
|---|---|---|
| | | |

---

## 5. Prompt Templates (Optional)

_Will this server provide reusable prompt templates?_

| Name | Description | Parameters |
|---|---|---|
| | | |

---

## 6. Data Sources

_What external APIs, databases, or services does this server access?_

| Source | Type | Auth Required? | Rate Limits? | Documentation URL |
|---|---|---|---|---|
| | | | | |

---

## 7. Deployment Target

_Where will this server run?_

- [ ] Local only (stdio, developer machine)
- [ ] Docker container (self-hosted)
- [ ] Kubernetes cluster
- [ ] Cloud function (AWS Lambda, GCP Cloud Run, etc.)
- [ ] Platform-hosted (mcp.run, Smithery)
- [ ] Other: _______________

**Target transport:**
- [ ] stdio (local only)
- [ ] Streamable HTTP (remote / multi-client)
- [ ] Both (stdio for dev, HTTP for production)

---

## 8. Auth Requirements

_How will this server authenticate with its data sources?_

| Data Source | Auth Method | Secret Name(s) |
|---|---|---|
| | | |

_How will clients authenticate with this server?_

- [ ] No auth (public/local)
- [ ] Bearer token (static)
- [ ] OAuth2 / JWT
- [ ] API key in header
- [ ] Other: _______________

---

## 9. Language and SDK

_Preferred implementation language and SDK:_

- [ ] TypeScript (`@modelcontextprotocol/sdk` v1.29.0)
- [ ] Python (`fastmcp` v3.2.4)
- [ ] Other: _______________

**Rationale (if any):**


---

## 10. Timeline and Constraints

| Aspect | Value |
|---|---|
| **Target completion** | |
| **Available time per week** | |
| **Phase 1 (prototype) deadline** | |
| **Phase 2 (production) deadline** | |
| **Hard constraints** | |
| **Nice-to-haves** | |

---

## 11. Success Criteria

_How will you know this server is working well?_

- [ ] All tools respond correctly to manual testing
- [ ] Automated test suite passes
- [ ] Deployed and accessible from target client(s)
- [ ] Handles error cases gracefully
- [ ] Published to a registry (npm, PyPI, Smithery)
- [ ] Custom criteria: _______________

---

## Summary

_One-paragraph summary of the server you are building:_


---

## Next Steps

After completing this worksheet:

1. Review with the phase routing logic (`mcp-builder/references/phase-routing-logic.md`)
2. If starting from scratch, begin with Phase 1 (prototype)
3. If you have a clear spec, run it through **trl-mcp-architect** first
4. Add this project to the project tracker (`mcp-builder/assets/project-tracker.md`)
