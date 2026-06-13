# MCP Catalog

Curated directory of 100+ MCP servers and CLI tools for AI-assisted development.
Point-in-time snapshot: mid-2026. For finding newer tools, see `discovery-guide.md`.

---

## What This Catalog Is

A reference library for skill designers integrating external tools into Claude-based workflows.
Each entry has been evaluated for maturity, security posture, and practical deployment.

Coverage spans MCP servers (tools exposed to LLMs via the Model Context Protocol) and
CLI tools (invoked directly in agentic shell sessions). Entries are grouped by function.

---

## Entry Format

Each category file uses a consistent structure:

- **Overview table** — scannable comparison of all tools in the category
- **Detailed entries** — top tools with full write-ups
- **CLI tools section** — shell-invocable tools relevant to the category
- **Selection guide** — decision tree for choosing between options

### Field definitions

| Field | Meaning |
|-------|---------|
| Name | Tool name and link to source |
| Type | `mcp-server`, `cli`, or `mcp+cli` |
| Deployment | `local`, `remote`, `docker`, `npm`, `pypi` |
| Key Features | Capabilities most relevant to skill design |
| Security Notes | Auth model, permission scope, known risks |
| Maturity | `stable`, `active`, `experimental`, or `archived` |

---

## Category Directory

| Category | File | MCP Servers | CLI Tools |
|----------|------|-------------|-----------|
| AI Coding Assistants | `ai-coding-assistants.md` | 8 | 4 |
| Code Analysis | `code-analysis.md` | 6 | 2 |
| Data & Databases | `data-and-databases.md` | 7 | 2 |
| Design & UI | `design-and-ui.md` | 6 | 0 |
| DevOps & Infrastructure | `devops-and-infra.md` | 7 | 0 |
| File & Knowledge | `file-and-knowledge.md` | 8 | 0 |
| Git & GitHub | `git-and-github.md` | 5 | 1 |
| LLM & Prompt Tools | `llm-and-prompt.md` | 2 | 4 |
| Monitoring & Observability | `monitoring-and-observability.md` | 3 | 0 |
| Search & Web | `search-and-web.md` | 7 | 1 |
| Security & Auth | `security-and-auth.md` | 3 | 3 |
| Testing & QA | `testing-and-qa.md` | 5 | 2 |
| Workflow & Automation | `workflow-and-automation.md` | 8 | 0 |

**Total: ~113 tools cataloged**

---

## When to Suggest Tools During Skill Design

### Always suggest when the skill involves:
- External data sources (databases, APIs, SaaS platforms)
- Web fetching, search, or crawling
- File system operations beyond the working directory
- Auth-gated services (GitHub, Notion, Google Workspace)

### Consider suggesting when the skill involves:
- Code generation that benefits from static analysis feedback
- Test execution and result interpretation
- Deployment pipelines or infrastructure state
- Structured data transformation

### Rarely needed for:
- Pure knowledge/advisory skills (no external I/O)
- Prompt engineering and template design
- Strategy and planning outputs

---

## Versioning

This catalog is a point-in-time snapshot (mid-2026). The MCP ecosystem moves fast —
registries grow by hundreds of servers per week.

For finding tools not listed here:
- See `discovery-guide.md` for registry URLs, search strategies, and evaluation criteria
- Check Glama (22,838+ servers) and mcp.so (20,702+ servers) for current coverage
- The official registry at `registry.modelcontextprotocol.io` is the authoritative source
  for verified publisher status
