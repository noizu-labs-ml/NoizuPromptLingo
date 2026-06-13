# Category: Code Analysis

## Overview
Use tools in this category when a skill needs to inspect, score, or improve existing code quality — either as a gate before shipping or as a continuous feedback loop during development. Relevant for security auditing skills, refactoring workflows, onboarding automation (understanding an unfamiliar codebase), and CI/CD integration patterns. Most tools here expose results as structured JSON or MCP tool responses, making them composable with AI agents.

## MCP Services

| Name | Deployment | Key Features | Security Notes | Maturity |
|------|-----------|-------------|----------------|----------|
| Semgrep MCP | Local stdio (built into binary) | 30+ languages, custom rules, SAST | Runs locally; no code leaves machine | Stable |
| SonarQube MCP | Self-hosted / cloud | 423 GitHub stars, quality gates, 25+ languages | Code sent to SonarQube instance | Stable |
| Repomix | Local stdio / npx | Repo-to-AI format, Tree-sitter compress, Secretlint | Secretlint scans before output | Stable |
| CodeScene | Cloud SaaS | Behavioral analysis, Code Health metric, hotspots | Repo cloned to CodeScene cloud | Stable |
| Snyk MCP | Cloud / local | 11 tools: SAST/SCA/IaC/containers/SBOM/AI-BOM | Snyk account required | Stable |
| Sourcegraph | Self-hosted / cloud | Code search, code intelligence, batch changes | Self-hostable for air-gap | Stable |
| Codacy | Cloud SaaS | Automated review, quality metrics, PR comments | Code sent to Codacy | Stable |
| DeepSource | Cloud / self-hosted | Auto-fix PRs, 30+ analyzers | Repo access via GitHub/GitLab OAuth | Stable |

---

### Semgrep MCP
- **What it does**: Static analysis engine with an MCP server built directly into the Semgrep binary. Scans code for security vulnerabilities, anti-patterns, and custom rule violations across 30+ languages without sending code to a remote service.
- **Deployment**: Local stdio; `semgrep mcp` command starts the server; no separate install beyond the binary
- **Key features**: 30+ language support (Python, JS/TS, Go, Java, Ruby, C/C++, and more); 3,500+ community rules in the Semgrep Registry; custom YAML rule authoring for project-specific patterns; autofix suggestions; taint analysis for data-flow security; CI/CD integration via `semgrep ci`; MCP exposes scan, rule-list, and finding-detail tools
- **Security considerations**: Entirely local execution — no code transmitted externally unless using Semgrep Cloud for rule syncing. Custom rules can be stored in-repo. Safe for proprietary and regulated codebases. Secretlint is not bundled — pair with Repomix for secret detection.
- **When to use**: Security-focused skills that need SAST without cloud dependencies; skills that enforce custom coding standards via project-specific rules; pre-commit hooks; onboarding workflows that need a quick codebase health snapshot.
- **When to avoid**: When behavioral/hotspot analysis (CodeScene) or dependency vulnerability scanning (Snyk SCA) is the primary need — Semgrep is SAST-first and does not track git history or package manifests well.

---

### Repomix
- **What it does**: Packages an entire repository into a single AI-consumable text file (XML, Markdown, or plain text). Uses Tree-sitter for semantic compression and runs Secretlint before output to catch accidental secret inclusion.
- **Deployment**: Local stdio; `npx repomix` (no install required); also available as a global npm package
- **Key features**: `--compress` flag uses Tree-sitter to extract only function signatures and structure (reduces token count by 60–80%); Secretlint integration blocks output if secrets detected; `.repomixignore` for custom exclusions; output formats: XML (best for Claude), Markdown, plain text; GitHub URL support (`repomix --remote owner/repo`); MCP server mode for tool-call access
- **Security considerations**: Secretlint runs automatically and blocks packing if API keys, tokens, or credentials are detected in any included file. Review the ignore list — misconfigured `.repomixignore` can still include `.env` files if the pattern is wrong. Output files contain your full codebase — treat them as sensitive.
- **When to use**: Feeding an unfamiliar codebase to an AI agent for analysis, refactoring planning, or documentation generation; any skill that needs to give an LLM full codebase awareness without manual file enumeration; remote repo analysis via URL.
- **When to avoid**: Real-time file-watch loops (Repomix is a one-shot packer, not a watcher); when the repo is too large and even `--compress` output exceeds context limits; when line-level precision is needed (use Semgrep or Sourcegraph instead).

---

### SonarQube MCP
- **What it does**: MCP server for SonarQube / SonarCloud that exposes code quality data — issues, hotspots, metrics, quality gates — as structured tool responses. Allows AI agents to query project health and act on findings.
- **Deployment**: Self-hosted (SonarQube Community/Developer/Enterprise) or SonarCloud (hosted SaaS); MCP server is a separate process that connects to either via REST API
- **Key features**: Quality gate status queries (pass/fail + reasons); issue listing by severity, type, and file; security hotspot review; 25+ language support; code coverage and duplication metrics; pull request decoration; branch analysis; 423 GitHub stars (active community)
- **Security considerations**: Code is analyzed by the SonarQube instance — self-hosted keeps code internal, SonarCloud sends code to Sonar's servers. MCP server requires a SonarQube token with appropriate project permissions. Token scope should be read-only for query workflows.
- **When to use**: Teams already using SonarQube as their quality gate; skills that need to surface actionable quality metrics to an AI agent; CI workflows where the agent should block deployment on gate failure; large-scale multi-project portfolios tracked in a single Sonar instance.
- **When to avoid**: Projects with no existing SonarQube setup (setup cost is non-trivial for a one-off analysis — use Semgrep instead); when local-only execution is required (SonarCloud violates this); when behavioral analysis beyond static rules is needed (CodeScene).

---

## CLI Tools

| Name | Install | What It Does | Skill Relevance |
|------|---------|-------------|-----------------|
| `semgrep` | `pip install semgrep` | SAST, custom rules, 30+ languages | Security gates, custom pattern enforcement |
| `repomix` | `npx repomix` | Pack repo to AI-consumable format | Codebase context for LLM analysis |
| `snyk` | `npm i -g snyk` | SCA, SAST, IaC, container scanning | Dependency vulnerability audits |
| `sonar-scanner` | Sonar docs | Push analysis to SonarQube | CI integration for quality gates |
| `codescene-ci` | CodeScene docs | Behavioral analysis in CI | Hotspot and Code Health in pipelines |

---

## Selection Guide

**Choose by analysis type:**

| Need | Best Choice | Fallback |
|------|------------|---------|
| SAST — security vulnerabilities | Semgrep MCP | Snyk MCP (SAST tools) |
| Dependency vulnerabilities (SCA) | Snyk MCP | Dependabot |
| Quality gates + metrics dashboard | SonarQube MCP | Codacy |
| Codebase context for LLM | Repomix | Manual file enumeration |
| Behavioral hotspots + tech debt trends | CodeScene | SonarQube complexity metrics |
| Code search + navigation | Sourcegraph | grep / ripgrep |
| IaC security (Terraform, K8s YAML) | Snyk MCP | Semgrep with IaC rules |
| Container image scanning | Snyk MCP | Trivy |

**Data residency:**
- Code must stay local → Semgrep, Repomix, self-hosted SonarQube
- Cloud SaaS acceptable → SonarCloud, CodeScene, Codacy, Snyk Cloud

**Setup cost:**
- Zero config → Semgrep (`semgrep mcp`), Repomix (`npx repomix`)
- Moderate setup → SonarQube MCP (requires running Sonar instance)
- High setup → CodeScene (repo integration + team training)

**AI agent composability:**
- Native MCP → Semgrep, SonarQube MCP, Snyk MCP
- CLI output parsed by agent → Repomix, Aider-compatible tools
- Webhook / API only → CodeScene, Codacy
