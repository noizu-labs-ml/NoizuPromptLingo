# Category: Security and Auth

## Overview
Use tools in this category when a skill needs to manage secrets, scan code for vulnerabilities, audit dependencies, or enforce compliance policies. Common skill design scenarios: AI templates (secure API key injection), content publishing (dependency scanning before deploy), trl-skill-engineer (validate MCP server safety before recommending), any skill that provisions infrastructure or handles credentials.

## MCP Services

| Name | Deployment | Key Features | Security Notes | Maturity |
|------|-----------|-------------|----------------|----------|
| HashiCorp Vault MCP | Self-hosted / HCP | Secret CRUD, policy management, dynamic secrets | CRITICAL: secrets may be exposed to LLM context — see notes | Stable (official) |
| Snyk MCP | Hosted SSE | SAST, SCA, IaC, container, SBOM, AI-BOM — 11 tools | API key required; code/deps sent to Snyk servers | Stable |
| Semgrep MCP | Local stdio | Static analysis, custom rules, built into Semgrep binary | Runs locally; no external data transmission for local scans | Stable |
| 1Password for AI Agents | Hosted SSE (Beta) | Zero-trust MCP gateway, secrets never exposed to LLM | Beta; purpose-built to prevent secret leakage to LLM | Beta |

### HashiCorp Vault MCP
- **What it does**: Provides MCP tools for full Vault operations — read/write/delete secrets, manage policies, list secret paths, create dynamic credentials, rotate secrets. Connects to any Vault instance (self-hosted or HashiCorp Cloud Platform).
- **Deployment**: Self-hosted stdio or HCP; connects to your existing Vault instance via VAULT_ADDR + VAULT_TOKEN
- **Key features**: KV secret CRUD, dynamic secrets (database/AWS/PKI), policy management, token/AppRole auth, audit log access
- **Security considerations**: **CRITICAL CAVEAT** — Vault MCP retrieves secret values and places them in LLM context. This means secret values may appear in conversation history, logs, and model inputs. This fundamentally undermines Vault's purpose as a secret store. Use only for secret *metadata* operations (list paths, check policies) — never for retrieving actual secret values via LLM. For secret injection without LLM exposure, use 1Password for AI Agents instead. Token scoped to minimum necessary permissions.
- **When to use**: Policy auditing, secret path discovery, rotation orchestration where the LLM orchestrates but doesn't read the value. Infrastructure automation where Vault is already the org standard.
- **When to avoid**: Any workflow where the LLM must read and use actual secret values. Consumer-facing skills where Vault isn't already deployed.

### Snyk MCP
- **What it does**: 11 security tools via MCP covering the full security surface: SAST (code scanning), SCA (open-source dependency vulnerabilities), IaC (Terraform/K8s misconfigs), container image scanning, SBOM generation, and AI-BOM for AI/ML dependency tracking.
- **Deployment**: Hosted SSE; Snyk API key required; code and dependency manifests sent to Snyk's analysis servers
- **Key features**: `snyk_test_file` (SAST on code), `snyk_test_packages` (SCA), `snyk_test_iac` (IaC), `snyk_container_test` (images), `snyk_sbom` (generate SBOM), `snyk_aibom` (AI/ML dependencies), fix suggestions, PR-ready patches
- **Security considerations**: Code and manifests transmitted to Snyk's cloud. Not suitable for classified or proprietary code that cannot leave org network. Snyk is SOC2 compliant — acceptable for most commercial use. SBOM output may reveal internal architecture.
- **When to use**: Pre-deploy security gate in skill pipelines. When you need broad coverage (SAST + SCA + IaC) in one tool. AI template skills shipping MCP servers — use `snyk_aibom` to track AI/ML supply chain.
- **When to avoid**: Air-gapped environments. Highly sensitive proprietary codebases where cloud transmission is prohibited (use Semgrep local instead).

### Trivy (CLI)
- **What it does**: Open-source vulnerability scanner for containers, filesystems, Git repos, and Kubernetes clusters. Generates SBOMs (CycloneDX/SPDX). Detects CVEs, misconfigs, secrets in code, and license compliance issues. No external API calls — fully local.
- **Deployment**: `brew install aquasecurity/trivy/trivy` or `curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh`
- **Key features**: Container image scanning, filesystem/repo scanning, K8s cluster audit, SBOM generation, secret detection, IaC misconfiguration checks
- **Security considerations**: Fully local — no data leaves the machine. Vulnerability DB downloaded and cached locally. Preferred for air-gapped or sensitive environments.
- **When to use**: Container security before any deploy. SBOM generation for compliance. Secret scanning in repos. When Snyk cloud transmission is not acceptable. Integrates cleanly into skill pipelines via shell commands.
- **When to avoid**: When you need SAST (code-level logic analysis) — Trivy is CVE/config focused, not deep static analysis. Use Semgrep for SAST.

## CLI Tools

| Name | Install | What It Does | Skill Relevance |
|------|---------|-------------|-----------------|
| Trivy | `brew install aquasecurity/trivy/trivy` | Vulnerability scanning for containers/filesystems/repos/K8s, SBOM generation, secret detection — fully local | Pre-deploy security gate; SBOM for compliance; secret scanning in skill outputs |
| Secretlint | `npm install -g secretlint` | Detect hardcoded secrets/credentials in code, 20+ plugins including AWS keys, Slack tokens, GitHub tokens | Validate skill-generated code before committing; used internally by Repomix |

## Selection Guide

**Need to manage/rotate secrets in Vault:** Use Vault MCP — but scope to metadata operations only, never retrieve actual values through LLM context.

**Need secrets injected into agent without LLM seeing them:** Use 1Password for AI Agents MCP. Zero-trust gateway purpose-built for this. Only option that truly prevents secret exposure to model context.

**Broad security scanning (SAST + SCA + IaC + container):** Use Snyk MCP. Best coverage breadth in a single tool. Requires cloud transmission.

**Container/image/repo scanning with no cloud:** Use Trivy CLI. Fully local, fast, excellent CVE coverage, SBOM output.

**Static analysis with custom rules:** Use Semgrep MCP. Runs locally, extensible rule sets, best for org-specific code patterns.

**Scan generated code for leaked secrets before commit:** Use Secretlint CLI. Fast, composable, works on any file type.

**Compliance (SBOM for SOC2/supply chain):** Use Trivy CLI (`trivy sbom`) or Snyk MCP (`snyk_sbom`). Trivy for local/air-gapped; Snyk for hosted with fix suggestions.
