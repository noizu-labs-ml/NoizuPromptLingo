# MCP Discovery Guide

How to find and evaluate MCP servers and CLI tools not in the catalog.
Use this when the catalog doesn't have what you need or when you want to verify
a tool is still the best option in its category.

---

## Primary MCP Registries

Start here before searching GitHub or npm. Registries aggregate metadata,
security scans, and compatibility rankings that would take hours to gather manually.

| Registry | URL | Size | Notes |
|----------|-----|------|-------|
| Official MCP Registry | registry.modelcontextprotocol.io | Growing | Vendor-neutral, open-source, verified publishers |
| Glama | glama.ai/mcp/servers | 22,838+ | Security scanning, compatibility ranking, test UI |
| mcp.so | mcp.so | 20,702+ | Real-world adoption barometer |
| Smithery | smithery.ai | 7,300+ | Registry + management platform, hosted deployment |
| PulseMCP | pulsemcp.com/servers | 14,000+ | Weekly newsletter, daily directory, trend tracking |
| Docker MCP Catalog | hub.docker.com/mcp | Growing | Container-native deployment, sandboxed by default |
| GitHub MCP Registry | github.blog | Growing | GitHub-hosted servers, discover via GitHub infra |
| OpenTools | opentools.ai | Growing | Open registry organized by capability |

### Which registry to use

- **Verifying a publisher** — official registry first
- **Browsing by category** — Glama or Smithery (best UI)
- **Checking real adoption** — mcp.so (star counts reflect actual usage)
- **Container deployment** — Docker MCP Catalog
- **Staying current** — PulseMCP newsletter (weekly digest)

---

## GitHub Search Strategies

GitHub has the highest density of MCP server implementations, including many not yet
listed in any registry.

### Topic and keyword searches

```
topic:mcp-server
topic:model-context-protocol
"modelcontextprotocol" in:readme
"@modelcontextprotocol/sdk" in:package.json
mcp-server in:name
```

### Curated lists to bookmark

- `wong2/awesome-mcp-servers` — community-maintained, broad coverage
- `punkpeye/awesome-mcp-servers` — alternative curation with different emphasis
- `tolkonepiu/best-of-mcp-servers` — ranked 400+ servers, updated weekly
- `modelcontextprotocol/servers` — official reference implementations from Anthropic

### Reading a repo before testing

Check in this order:
1. README — deployment model, auth requirements, tool list
2. `package.json` or `pyproject.toml` — dependencies and maintenance signals
3. Issues tab — look for security reports or abandoned PRs
4. Last commit date — anything > 6 months without activity is a yellow flag
5. Contributors — single-maintainer repos with high downloads need extra scrutiny

---

## npm and PyPI Search

Most MCP servers ship as npm packages (TypeScript/Node) or PyPI packages (Python).

### npm

```bash
npm search mcp-server
npm search @modelcontextprotocol
```

Look for:
- `@modelcontextprotocol/` scope — official SDK and reference servers
- Trusted Publishing with OIDC configured — quality signal for PyPI-equivalent
- Download counts (weekly) relative to star count — high ratio = organic adoption

### PyPI

```bash
pip search mcp-server   # deprecated, use web search instead
# Search: site:pypi.org mcp-server
```

Filter by:
- `mcp` or `mcp-server` keyword in classifiers
- Trusted Publishing badge (OIDC, not manual token upload)
- Maintained by known orgs (Anthropic, LangChain, major platform vendors)

---

## Community Resources

### Discussion channels

- **Discord** — MCP Discord server (primary community, invite via modelcontextprotocol.io)
- **Reddit** — r/mcp and r/ClaudeAI both track new servers
- **GitHub Discussions** — modelcontextprotocol/modelcontextprotocol repo

### Newsletters and tracking

- **PulseMCP Weekly** — pulsemcp.com — best weekly digest of new servers and ecosystem news
- **AgentRank** — scores servers by real-world performance across agent benchmarks
- **Glama changelog** — glama.ai/mcp/changelog — daily additions to their index

### Security tracking

- **OWASP MCP Top 10** — canonical list of MCP-specific vulnerability classes
- **Glama security scanner** — runs automated checks on indexed servers
- **CVE feeds** — filter on "model context protocol" for disclosed vulnerabilities

---

## Evaluation Framework

### Positive signals

| Signal | Why It Matters |
|--------|---------------|
| Official / first-party from platform vendor | Vendor maintains it alongside their API |
| OAuth 2.0 auth | Only 8.5% of servers use it — strong maturity signal |
| Listed in official registry with verified publisher | Passed baseline review |
| Hosted / remote deployment option | Reduces local attack surface |
| Active maintenance, responsive issues | Bug reports get fixed |
| High stars with proportional contributor count | Organic adoption, not astroturfed |
| Read-only mode available | Can test safely before enabling writes |
| Pinned dependency versions | Reproducible builds, no supply chain drift |

### Red flags

| Red Flag | Risk |
|----------|------|
| Single maintainer with massive downloads | Bus factor + potential takeover target |
| < 1 year old with disproportionate adoption | May be astroturfed or a honeypot |
| Requires broad write access with no read-only mode | Cannot limit blast radius |
| Long-lived static API keys as only auth method | 53% of servers — high credential exposure |
| No sandbox or permission restrictions | Any tool call can affect host system |
| Shell injection in tool parameters | 43% of CVEs filed Jan-Feb 2026 |
| Tool poisoning (hidden instructions in tool descriptions) | 5.5% of scanned servers affected |
| Unpinned `latest` dependencies | Supply chain risk |
| No LICENSE file | Unclear usage rights |

### Evaluation process (step by step)

1. **Check official registry** — is the publisher verified?
2. **Review auth model** — prefer OAuth 2.0; flag static API keys
3. **Read the tool list** — does it request capabilities beyond what the task needs?
4. **Scan dependencies** — run `npm audit` or `pip-audit` on the package
5. **Test read-only first** — enable writes only after validating read behavior
6. **Check for tool poisoning** — read raw tool descriptions for hidden instructions
7. **Maintain an approved-server allowlist** — don't let agents discover servers dynamically
8. **Block dynamic discovery from untrusted networks** — servers discovered mid-session
   can inject malicious tool descriptions

### Auth model scoring

Rate the auth model when evaluating a server:

| Auth Model | Score | Notes |
|------------|-------|-------|
| OAuth 2.0 with PKCE | Best | Short-lived tokens, revocable |
| OAuth 2.0 (basic) | Good | Revocable, no long-lived secrets |
| API key scoped per user | Acceptable | Rotate frequently |
| Shared static API key | Poor | 53% of servers — credential exposure risk |
| No auth | Reject | Only for localhost-only tools |

---

## Security Deep Dive

### The current threat landscape (mid-2026)

MCP adoption has outpaced security practices. Key statistics:

- **53%** of servers use long-lived static API keys as their only auth mechanism
- **Only 8.5%** implement OAuth 2.0
- **43%** of CVEs filed Jan-Feb 2026 involve shell injection via tool parameters
- **5.5%** of servers scanned by Glama contain tool poisoning (hidden LLM instructions
  embedded in tool descriptions)

### OWASP MCP Top 10 (summary)

The full list lives at owasp.org. The categories most relevant to skill designers:

1. **Prompt injection via tool output** — malicious content in API responses
2. **Tool poisoning** — hidden instructions in tool descriptions
3. **Excessive permission scope** — servers requesting more than needed
4. **Insecure credential storage** — API keys in plaintext config
5. **Dynamic server discovery** — loading untrusted servers mid-session

### Mitigation checklist for skill designs that include MCP tools

- [ ] Server is on your approved allowlist
- [ ] Auth model is OAuth 2.0 or scoped API key (not shared static)
- [ ] Tool descriptions reviewed for hidden instructions
- [ ] Minimum required permissions only — no broad write access at start
- [ ] Dependencies pinned and audited
- [ ] Read-only validation completed before enabling writes
- [ ] Dynamic discovery disabled or restricted to trusted sources

---

## Adding to the Catalog

When you've evaluated a tool and want to document it for reuse, use this template.

### Catalog entry template

```markdown
## [Tool Name](https://link-to-source)

| Field | Value |
|-------|-------|
| Type | mcp-server / cli / mcp+cli |
| Deployment | local / remote / docker / npm / pypi |
| Auth | OAuth 2.0 / API key / none |
| Maturity | stable / active / experimental / archived |
| Evaluated | YYYY-MM |

### Key Features
- Feature one
- Feature two
- Feature three

### Security Notes
- Auth model: [describe]
- Permission scope: [what access does it require]
- Known issues: [CVEs, reported vulnerabilities, or "none known"]

### Deployment
```bash
# Install command
# Config snippet
```

### Best For
[One sentence on the ideal use case in a skill context]

### Avoid When
[Conditions where this tool is a poor fit]
```

### Which file to add it to

Match the tool to the closest category in `index.md`. If it spans multiple categories,
put it in the primary one and add a cross-reference note in the others.

If no category fits, add a new category file and update the directory table in `index.md`.

### Minimum bar for inclusion

A tool should meet at least three of these before being added:

- Listed in Glama, mcp.so, or official registry
- Has a public source repo with > 50 stars (or is first-party from a major vendor)
- Auth model is at minimum scoped API key (no shared static keys)
- Last commit within 12 months
- No unresolved critical CVEs

---

## Quick Reference: Discovery Checklist

Use this when you need a tool fast and want to move through evaluation efficiently.

```
[ ] Search official registry → verified publisher?
[ ] Check Glama → security scan results?
[ ] Check mcp.so → real adoption signal?
[ ] Review GitHub repo → maintenance, contributor count, issues
[ ] Read tool descriptions → tool poisoning check
[ ] Audit dependencies → npm audit / pip-audit
[ ] Test read-only → validate before enabling writes
[ ] Document in catalog if adding to a skill
```
