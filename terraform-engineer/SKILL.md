---
name: trl-terraform-engineer
description: >
  Design, implement, test, and maintain production-grade Terraform infrastructure
  across AWS, GCP, Azure, Kubernetes, Cloudflare, and 30+ providers. Use this
  skill when the user wants to write Terraform code, design module architectures,
  manage state backends, debug plan/apply failures, refactor HCL, set up CI/CD
  for infrastructure, write custom providers, test infrastructure code, migrate
  between Terraform versions, implement policy-as-code, or optimize cost and
  security posture — even if they don't say "Terraform." Also trigger when users
  mention HCL, OpenTofu, Terragrunt, CDKTF, terraform plan, terraform apply,
  tfstate, remote backend, Atlantis, Spacelift, Terraform Cloud, tflint, tfsec,
  Checkov, Sentinel, Terratest, provider development, infrastructure as code,
  IaC, terraform import, moved blocks, or terraform test.
---

# Terraform Engineer

Production-grade infrastructure as code with Terraform — from first resource to planet-scale multi-cloud.

## Overview

This skill transforms infrastructure requirements into well-structured, tested, secure Terraform configurations. It provides:

- **Module architecture** — Composable, versioned modules with clean interfaces and semantic versioning
- **Multi-cloud fluency** — AWS, GCP, Azure, Kubernetes, Cloudflare, and 30+ providers with idiomatic patterns per cloud
- **State management** — Remote backends, state locking, workspace strategies, safe state operations
- **Testing pyramid** — Built-in `terraform test` (1.6+), Terratest, policy-as-code (OPA, Sentinel, Checkov), cost guardrails
- **CI/CD integration** — Atlantis, Spacelift, Terraform Cloud, GitHub Actions workflows with plan-on-PR, apply-on-merge
- **Security hardening** — No secrets in state, least-privilege IAM, policy enforcement, drift detection
- **Custom providers** — Plugin Framework development, testing, registry publishing
- **Refactoring** — moved blocks, state surgery, monolith decomposition, version migration

## Core Philosophy

**Five Principles:**

1. **Blast radius minimization** — Small, independent state files over monoliths; a failed apply should never take down unrelated infrastructure
2. **Explicit over implicit** — Pin versions, declare dependencies, name resources descriptively; implicit behavior is a time bomb
3. **Immutable patterns** — Prefer replace over in-place mutation; use `create_before_destroy` for zero-downtime changes
4. **Test before deploy** — Every change gets a plan review; critical infrastructure gets automated tests and policy checks
5. **State is sacred** — Never edit state manually; use `terraform state mv`, `moved` blocks, and `import` blocks; always back up before surgery

## When to Use This Skill

- **Writing Terraform from scratch** — New infrastructure, greenfield projects, first-time IaC adoption
- **Designing module architecture** — Module composition, registry publishing, interface design, versioning strategy
- **Managing state** — Backend configuration, workspace strategy, state migration, splitting monoliths
- **Debugging plan/apply failures** — Dependency issues, provider errors, state drift, timeout handling
- **Refactoring existing Terraform** — Module extraction, resource renaming with moved blocks, provider upgrades
- **Setting up CI/CD for IaC** — Atlantis, Spacelift, GitHub Actions, plan-on-PR workflows
- **Testing infrastructure** — terraform test, Terratest, policy-as-code, cost estimation
- **Writing custom providers** — Plugin Framework, acceptance tests, registry publishing
- **Multi-cloud patterns** — AWS + GCP + Azure + Cloudflare in coordinated deployments
- **Security and compliance** — IAM patterns, policy enforcement, secrets management, drift detection
- **Kubernetes via Terraform** — EKS/GKE/AKS provisioning, helm_release, kubernetes_manifest patterns
- **Cost optimization** — Infracost integration, spot instances, reserved capacity, cleanup automation
- **Migration** — Terraform version upgrades, SDK v2 → Plugin Framework, OpenTofu compatibility

> For Kubernetes manifest management post-cluster-creation, the parent repo uses Helm charts directly — see `CLAUDE.md` in the repo root.
> For secrets management in Kubernetes, see the parent repo's Infisical patterns (`docs/secret-management.md`).
> For database schema design within provisioned databases, see **trl-dba-db-designer-and-tuning**.
> For security architecture review of the overall system, see **trl-threat-modeler**.

## Anti-Scope

This skill does **not**:

- Execute `terraform apply` on production without explicit user confirmation
- Manage Kubernetes workloads post-cluster-creation (that's Helm/ArgoCD territory)
- Design application architectures (only the infrastructure they run on)
- Replace cloud-specific CLIs for one-off operations (aws cli, gcloud, az)
- Handle Pulumi, CloudFormation, or Bicep (mention them for comparison only)
- Provide cost estimates without Infracost (recommend the tool, don't guess prices)

## Terraform Version Landscape

| Version | Key Features | Status |
|---------|-------------|--------|
| 1.0 | Stability guarantee, no breaking changes in 1.x | GA (Jun 2021) |
| 1.1 | `moved` blocks for refactoring | GA (Dec 2021) |
| 1.3 | Optional object attributes | GA (Sep 2022) |
| 1.4 | `terraform_data` replaces `null_resource` | GA (Mar 2023) |
| 1.5 | `import` blocks (config-driven import), `check` blocks | GA (Jun 2023) |
| 1.6 | `terraform test` command, S3 native state locking | GA (Oct 2023) |
| 1.7 | `removed` blocks, config-driven `import` improvements | GA (Jan 2024) |
| 1.8 | Provider-defined functions | GA (Apr 2024) |
| 1.9 | `input` variable validation improvements | GA (2024) |
| 1.10+ | Ongoing improvements | Current |

**OpenTofu fork:** Community-driven fork from 1.5.7, MPL-licensed. Compatible with Terraform 1.5 features; adds its own features (state encryption, early variable evaluation). Use when licensing matters or HashiCorp BSL is a concern.

## File Organization Standard

```
project/
├── main.tf              # Primary resources and module calls
├── variables.tf         # Input variable declarations
├── outputs.tf           # Output value declarations
├── providers.tf         # Provider configurations and required_providers
├── versions.tf          # terraform { required_version } block
├── locals.tf            # Local value computations
├── data.tf              # Data source lookups
├── backend.tf           # Backend configuration (or in versions.tf)
├── terraform.tfvars     # Variable values (NOT committed for secrets)
├── .terraform.lock.hcl  # Dependency lock file (COMMIT this)
└── modules/
    └── <module-name>/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md      # terraform-docs generated
```

### Environment Separation Strategies

| Strategy | When to Use | Trade-offs |
|----------|------------|------------|
| **Directory-based** (`envs/{dev,staging,prod}/`) | Most teams, clear isolation | Some duplication; mitigated by shared modules |
| **Workspace-based** | Simple projects, same shape across envs | Single backend, conditional logic in HCL |
| **Terragrunt** | Large orgs, extreme DRY needs | Additional tool dependency, learning curve |
| **Terraform Cloud workspaces** | Teams using TFC/TFE | Vendor lock-in, but excellent UX |

**Recommendation:** Directory-based with shared modules for most teams. Workspaces for simple projects. Terragrunt for organizations managing 50+ environments.

## Provider Ecosystem

### Tier 1 — Major Cloud (official HashiCorp)

| Provider | Registry Path | Typical Resources |
|----------|--------------|-------------------|
| AWS | `hashicorp/aws` | VPC, EKS, RDS, Lambda, IAM, S3, CloudFront |
| GCP | `hashicorp/google` + `google-beta` | GKE, Cloud Run, IAM, VPC, Cloud SQL |
| Azure | `hashicorp/azurerm` | AKS, VNET, Resource Groups, Key Vault |

### Tier 2 — Infrastructure & Platform

| Provider | Registry Path | Use Case |
|----------|--------------|----------|
| Kubernetes | `hashicorp/kubernetes` | K8s resources when Helm/ArgoCD isn't managing them |
| Helm | `hashicorp/helm` | `helm_release` for chart deployments |
| Docker | `kreuzwerker/docker` | Container and image management |
| Cloudflare | `cloudflare/cloudflare` | DNS, tunnels, WAF, Workers, Zero Trust |
| Vault | `hashicorp/vault` | Secrets engines, auth backends, policies |

### Tier 3 — Supporting

| Provider | Use Case |
|----------|----------|
| `hashicorp/random` | Random IDs, passwords, pet names |
| `hashicorp/null` | `null_resource` triggers (prefer `terraform_data` in 1.4+) |
| `hashicorp/local` | Local file generation |
| `hashicorp/tls` | Self-signed certs, private keys |
| `hashicorp/archive` | ZIP files for Lambda/Cloud Functions |
| `hashicorp/external` | Shell script data sources |

### Tier 4 — Specialized

| Provider | Use Case |
|----------|----------|
| GitHub (`integrations/github`) | Repos, teams, branch protection, Actions secrets |
| Datadog (`DataDog/datadog`) | Monitors, dashboards, SLOs |
| Grafana (`grafana/grafana`) | Dashboards, data sources, alerting |
| PostgreSQL (`cyrilgdn/postgresql`) | Roles, databases, schemas, grants |
| PagerDuty | Escalation policies, services |
| Proxmox (`bpg/proxmox`) | VM/LXC management for homelab |

> For detailed provider patterns and anti-patterns, see [references/providers/](references/providers/).

## Module Design

### Module Interface Contract

```hcl
# Good: Clear, typed, validated inputs
variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,62}$", var.cluster_name))
    error_message = "Cluster name must be lowercase alphanumeric with hyphens, 3-63 chars."
  }
}

variable "node_config" {
  type = object({
    instance_type = string
    min_size      = number
    max_size      = number
    disk_size_gb  = optional(number, 50)
  })
  description = "Node group configuration"
}

# Good: Meaningful outputs
output "cluster_endpoint" {
  value       = aws_eks_cluster.this.endpoint
  description = "EKS cluster API server endpoint"
}

output "cluster_ca_certificate" {
  value       = aws_eks_cluster.this.certificate_authority[0].data
  description = "Base64 encoded cluster CA certificate"
  sensitive   = true
}
```

### Module Composition Pattern

```
root module (environment-specific)
├── calls module "networking" (VPC, subnets)
├── calls module "cluster" (EKS/GKE, depends on networking outputs)
├── calls module "database" (RDS, depends on networking outputs)
└── calls module "monitoring" (Datadog, depends on cluster outputs)
```

**Rules:**
- Modules never declare `provider` blocks — pass via `providers` argument
- Modules never declare `backend` blocks — only root modules do
- Modules expose only what consumers need — don't output internal resource IDs
- Use semantic versioning for registry-published modules

## State Management

### Remote Backend Selection

| Backend | Best For | Locking | Encryption |
|---------|----------|---------|------------|
| S3 + DynamoDB | AWS-centric teams | DynamoDB table | SSE-S3/SSE-KMS |
| S3 (native, 1.6+) | AWS teams on TF 1.6+ | Native (no DynamoDB) | SSE-S3/SSE-KMS |
| GCS | GCP-centric teams | Built-in | Default encrypted |
| Azure Blob | Azure-centric teams | Blob lease | Built-in |
| Terraform Cloud | Teams using TFC | Built-in | Built-in |
| PostgreSQL | Self-hosted, air-gapped | Advisory locks | Depends on setup |

### State Isolation Rules

1. **One state per blast radius** — If a failure in component A shouldn't affect component B, they belong in separate states
2. **Never share state across teams** — Use `terraform_remote_state` data source to read, not write
3. **Separate stateful from stateless** — Databases and persistent volumes in their own state; compute in another
4. **Environment isolation** — Dev, staging, prod are always separate states

## Testing Pyramid

```
┌─────────────────────────┐
│    Manual Review        │  ← Always: terraform plan in PR
├─────────────────────────┤
│  Integration Tests      │  ← Terratest: deploy, validate, destroy
├─────────────────────────┤
│  Policy as Code         │  ← Checkov, tfsec/Trivy, OPA, Sentinel
├─────────────────────────┤
│  Unit Tests             │  ← terraform test (1.6+), plan validation
├─────────────────────────┤
│  Static Analysis        │  ← tflint, terraform validate, terraform fmt
└─────────────────────────┘
```

> For detailed testing strategies, see [references/testing-and-validation.md](references/testing-and-validation.md).

## CI/CD Patterns

### Plan-on-PR, Apply-on-Merge

```
PR opened/updated → terraform fmt -check → terraform validate →
tflint → checkov/tfsec → terraform plan → post plan as PR comment →
require approval → merge → terraform apply → post apply result
```

### Tool Comparison

| Tool | Self-hosted | Managed | PR Comments | Policy | Cost |
|------|------------|---------|-------------|--------|------|
| Atlantis | Yes | No | Yes | Conftest | Free |
| Spacelift | No | Yes | Yes | OPA | Paid |
| Terraform Cloud | No | Yes | VCS integration | Sentinel | Free tier available |
| GitHub Actions | N/A | Yes | Custom | Custom | Free tier |
| env0 | No | Yes | Yes | OPA/Custom | Paid |

> For detailed CI/CD patterns, see [references/ci-cd-patterns.md](references/ci-cd-patterns.md).

## Anti-Pattern Quick Reference

| Anti-Pattern | Why It's Bad | Fix |
|-------------|-------------|-----|
| Monolithic root module | Huge blast radius, slow plans | Split by domain/lifecycle |
| `count` for named resources | Index shift destroys wrong resources | Use `for_each` with stable keys |
| Provider blocks in modules | Implicit provider inheritance breaks | Pass providers from root |
| Secrets in `.tfvars` committed to git | Credential exposure | Use Vault, SSM, or env vars |
| Local state shared via git | State conflicts, corruption | Remote backend with locking |
| `terraform apply -auto-approve` in prod | No review step | Always require plan review |
| Hardcoded IDs | Breaks across environments | Use data sources |
| Over-modularization | Complexity for single resources | Module when 3+ resources form a logical unit |
| Ignoring `.terraform.lock.hcl` | Non-reproducible builds | Commit the lock file |
| `terraform state rm` + `import` to rename | Error-prone, race conditions | Use `moved` blocks (1.1+) |

> For the full anti-pattern catalog with refactoring guides, see [references/anti-patterns-and-pitfalls.md](references/anti-patterns-and-pitfalls.md).

## Quick Start Guides

### Write a New Module
1. Define the interface: `variables.tf` with types, descriptions, and validation
2. Implement resources in `main.tf`, computed values in `locals.tf`
3. Expose outputs in `outputs.tf` — only what consumers need
4. Generate docs: `terraform-docs markdown table . > README.md`
5. Write tests: `.tftest.hcl` for unit, Terratest for integration
6. Pin versions: `versions.tf` with `required_providers` and `required_version`
7. Publish: tag with semver, push to registry

### Set Up CI/CD
1. Choose tool: Atlantis (self-hosted), Spacelift (managed), or GitHub Actions (simple)
2. Configure remote backend with locking
3. Set up plan-on-PR workflow
4. Add policy checks: tflint + Checkov/tfsec minimum
5. Configure apply-on-merge with approval gates
6. Add cost estimation with Infracost

### Refactor Existing Terraform
1. Read [references/refactoring-and-migration.md](references/refactoring-and-migration.md)
2. Start with `terraform plan` to establish baseline (no changes expected)
3. Use `moved` blocks for renames and module extraction
4. Use `import` blocks (1.5+) to bring existing resources under management
5. Use `removed` blocks (1.7+) to drop resources from state without destroying
6. Always `plan` before `apply` — the plan is your safety net

### Debug a Failing Apply
1. Read the error message carefully — Terraform errors are usually precise
2. Check `TF_LOG=DEBUG terraform apply` for API-level errors
3. Use `terraform console` to evaluate expressions
4. Check `terraform state show <resource>` for current state
5. Compare plan output with actual API state
6. Check provider version compatibility

## Reference Guide

| Task | Read These |
|------|-----------|
| **Starting any Terraform project** | `best-practices.md`, `agent-playbook.claude-code.md` |
| **Module design** | `best-practices.md` (Module Design section) |
| **Choosing/configuring providers** | `providers/cloud-providers.md`, `providers/platform-providers.md` |
| **Debugging failures** | `anti-patterns-and-pitfalls.md`, `refactoring-and-migration.md` |
| **Setting up CI/CD** | `ci-cd-patterns.md` |
| **Writing tests** | `testing-and-validation.md` |
| **Building custom providers** | `custom-providers.md` |
| **Infrastructure recipes** | `cookbooks/networking.md`, `cookbooks/kubernetes.md`, `cookbooks/databases.md` |
| **Multi-cloud deployments** | `cookbooks/multi-cloud.md` |
| **Refactoring/migration** | `refactoring-and-migration.md` |
| **Security hardening** | `security-and-compliance.md` |
| **Multi-environment patterns** | `best-practices.md` (Environment Separation section) |
| **Full build walkthrough** | `worked-example-eks-platform.md` |

All reference paths are relative to `references/`.

## Related Skills

- **trl-threat-modeler** — Security review of infrastructure architectures, compliance mapping
- **trl-dba-db-designer-and-tuning** — Database schema design and optimization for provisioned databases
- **trl-mcp-architect** — When Terraform provisions infrastructure that MCP servers run on
- **trl-skill-engineer** — For creating new Terraform-adjacent skills (e.g., cloud-cost-optimizer)
- **trl-user-experience-engineer** — Dashboards and visualizations for infrastructure state

## Bundled Resources

### References

**Foundation** (read first):
- [best-practices.md](references/best-practices.md) — Module design, state management, code organization, naming, DRY patterns, version constraints
- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent role, execution workflows, operational boundaries

**Providers** (`references/providers/`):
- [cloud-providers.md](references/providers/cloud-providers.md) — AWS, GCP, Azure — idiomatic patterns, common resources, gotchas
- [platform-providers.md](references/providers/platform-providers.md) — Kubernetes, Helm, Docker, Cloudflare, Vault, GitHub, and 15+ more

**Engineering** (read as needed):
- [anti-patterns-and-pitfalls.md](references/anti-patterns-and-pitfalls.md) — 20+ anti-patterns with refactoring guides, debugging techniques
- [testing-and-validation.md](references/testing-and-validation.md) — terraform test, Terratest, Checkov, tflint, OPA, Sentinel, Infracost
- [custom-providers.md](references/custom-providers.md) — Plugin Framework, acceptance tests, registry publishing, SDK v2 migration
- [ci-cd-patterns.md](references/ci-cd-patterns.md) — Atlantis, Spacelift, Terraform Cloud, GitHub Actions, plan/apply workflows
- [refactoring-and-migration.md](references/refactoring-and-migration.md) — moved blocks, state surgery, version upgrades, monolith decomposition
- [security-and-compliance.md](references/security-and-compliance.md) — IAM patterns, secrets, policy-as-code, drift detection, encryption

**Cookbooks** (`references/cookbooks/`):
- [networking.md](references/cookbooks/networking.md) — VPC, subnets, security groups, peering, transit gateways, Cloudflare tunnels
- [kubernetes.md](references/cookbooks/kubernetes.md) — EKS, GKE, AKS provisioning, add-ons, workload identity, GitOps handoff
- [databases.md](references/cookbooks/databases.md) — RDS, Cloud SQL, Azure DB, self-managed PostgreSQL, backup patterns
- [serverless.md](references/cookbooks/serverless.md) — Lambda, Cloud Functions, Azure Functions, API Gateway
- [multi-environment.md](references/cookbooks/multi-environment.md) — Directory-based, workspace, Terragrunt, account vending
- [multi-cloud.md](references/cookbooks/multi-cloud.md) — AWS+GCP+Cloudflare coordinated deployments, DR failover, cross-cloud VPN, multi-cloud CI/CD

**Worked Examples**:
- [worked-example-eks-platform.md](references/worked-example-eks-platform.md) — End-to-end: VPC → EKS → RDS → monitoring → CI/CD

### Assets

- [module-template/](assets/module-template/) — Starter template for new Terraform modules
- [audit-checklist.md](assets/audit-checklist.md) — Pre-deploy review checklist for Terraform configurations
- [project-tracker.md](assets/project-tracker.md) — Terraform project progress tracker
