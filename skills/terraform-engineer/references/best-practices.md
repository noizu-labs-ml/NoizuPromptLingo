# Terraform Best Practices

> Production-ready reference for designing, organizing, securing, and deploying Terraform infrastructure at scale.
>
> **Terraform versions referenced:** 1.10+ (native S3 locking, ephemeral variables), 1.11+ (write-only arguments)
> **Provider versions referenced:** AWS Provider ~> 5.40+, Google Provider ~> 5.0+, AzureRM ~> 3.80+

---

## 1. Module Design Patterns

### Composition Strategy

Build small, single-purpose modules organized in layers:

```
modules/
  networking/       # VPC, subnets, route tables, NAT gateways
  compute/          # EC2, ASG, launch templates
  database/         # RDS, ElastiCache, DynamoDB
  iam/              # Roles, policies, instance profiles
  monitoring/       # CloudWatch, alarms, dashboards
  dns/              # Route53 zones and records
```

Root modules compose these layers together:

```hcl
module "networking" {
  source = "../../modules/networking"
  # ...
}

module "cluster" {
  source     = "../../modules/compute"
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids
}

module "database" {
  source     = "../../modules/database"
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.database_subnet_ids
}

module "monitoring" {
  source       = "../../modules/monitoring"
  cluster_name = module.cluster.name
  db_instance  = module.database.instance_id
}
```

### When to Use Modules vs Inline

**Use a module when:**
- A pattern repeats 2+ times across configurations
- You need to enforce organizational standards (tagging, naming, security)
- The abstraction has a clear interface contract
- The module stays under ~200 lines of HCL

**Keep inline when:**
- Single-use, environment-specific configuration
- Simple one-off resources with no reuse potential
- Wrapping a single resource with no added logic (anti-pattern)

Single-resource wrappers are an anti-pattern. A module that contains only an `aws_s3_bucket` with passthrough variables adds indirection without value. Modules earn their complexity cost by encapsulating multiple related resources with opinionated defaults.

### Standard Module Structure

```
modules/networking/
  main.tf           # Resource definitions
  variables.tf      # Input variables with types, defaults, validation
  outputs.tf        # Exported attributes
  versions.tf       # Required terraform and provider versions
  locals.tf         # Computed values and transformations
  data.tf           # Data sources (optional, only if needed)
  README.md         # Usage docs, examples, requirements
  examples/
    basic/          # Minimal working example
    complete/       # Full-featured example
  tests/
    basic.tftest.hcl
```

### Module Interface Contract

```hcl
# variables.tf — typed, validated, documented
variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 16
    error_message = "Password must be at least 16 characters."
  }
}

# outputs.tf — meaningful, sensitive-marked, grouped
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "db_connection_string" {
  description = "Database connection string"
  value       = "postgresql://${aws_db_instance.this.endpoint}/${aws_db_instance.this.db_name}"
  sensitive   = true
}
```

### Module Rules

1. **No `provider` blocks in child modules.** Providers are configured in the root module and passed implicitly or via `configuration_aliases`.
2. **No `backend` blocks in child modules.** Backend configuration belongs exclusively in root modules.
3. **Expose only what consumers need.** Don't output every attribute; curate the interface.
4. **Semantic versioning.** Tag module releases (`v1.2.3`). Breaking changes = major bump.
5. **Pin module sources.** Always reference a specific version or ref.

```hcl
# Good: pinned version
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"
}

# Good: pinned git ref
module "custom" {
  source = "git::https://github.com/org/modules.git//networking?ref=v2.1.0"
}

# Bad: unpinned
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
}
```

---

## 2. State Management

### Remote Backends (Ranked by Ecosystem)

| Backend | Best For | Locking | Encryption | Notes |
|---------|----------|---------|------------|-------|
| **S3** | AWS-native teams | Native (TF 1.10+) | SSE-S3/KMS | DynamoDB locking deprecated; use `use_lockfile = true` |
| **GCS** | GCP-native teams | Native | Default encrypted | Built-in versioning |
| **Azure Blob** | Azure-native teams | Native (lease) | Default encrypted | Use container-level access |
| **HCP Terraform** | Multi-cloud / managed | Built-in | Built-in | State versioning, run history, cost |
| **PostgreSQL** | Self-hosted / air-gapped | Advisory locks | TLS in transit | Requires maintenance |

### S3 Backend Best Practice (Terraform 1.10+)

```hcl
terraform {
  backend "s3" {
    bucket       = "myorg-terraform-state"
    key          = "networking/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true  # Native S3 locking — no DynamoDB needed
    encrypt      = true
  }
}
```

As of Terraform 1.10, S3 supports native state locking via conditional writes. DynamoDB-based locking is deprecated. New projects should use `use_lockfile = true`. Existing projects should migrate: remove the `dynamodb_table` argument, add `use_lockfile = true`, then decommission the DynamoDB table after confirming lock files appear in S3.

### State Splitting Strategy

Split state by **blast radius** — a bad apply in one state file should not affect unrelated infrastructure:

```
states/
  networking/       # VPC, subnets, NAT, VPN — changes rarely, high blast radius
  security/         # IAM roles, KMS keys, SCPs — changes rarely, extremely sensitive
  compute/          # EKS, ASG, instances — changes frequently, moderate blast radius
  data/             # RDS, ElastiCache, S3 — changes moderately, high blast radius (stateful)
  monitoring/       # CloudWatch, alerts — changes frequently, low blast radius
```

### State Isolation Rules

1. **One state per blast radius.** Never manage networking and compute in the same state.
2. **Never share state across teams.** Each team owns their state files and the infrastructure within.
3. **Separate stateful from stateless.** Databases and storage that hold data live in different state files from ephemeral compute. Destroying compute should never risk data resources.
4. **Isolate by environment.** Dev, staging, and prod each get their own state files — always.

Cross-state references use `terraform_remote_state` or (preferred) data sources:

```hcl
# Preferred: data source lookup
data "aws_vpc" "main" {
  tags = { Name = "main-${var.environment}" }
}

# Alternative: remote state (tighter coupling)
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "myorg-terraform-state"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### Workspace Strategies

| Strategy | Use When | Avoid When |
|----------|----------|------------|
| **Workspaces** | Ephemeral environments (feature branches, PR previews), structurally identical environments | Permanent environments with diverging configs |
| **Directory-based** | Permanent environments (dev/staging/prod), environments that diverge over time | You have 50+ near-identical environments |
| **Terragrunt** | 10+ environments with DRY config needs, complex dependency orchestration | Small teams, simple setups (<5 environments) |

**Hybrid approach:** Use workspaces for feature branch / PR preview environments. Use directories for permanent dev/staging/prod environments.

---

## 3. Code Organization

### Monorepo vs Polyrepo Decision Matrix

| Factor | Monorepo | Polyrepo |
|--------|----------|----------|
| **Team size** | <15 engineers on infra | 15+ or multiple autonomous teams |
| **Coupling** | Shared modules, coordinated deploys | Independent services, decoupled lifecycle |
| **CI/CD blast radius** | Acceptable if CI can target changed paths | Need strict isolation |
| **Code review** | Centralized standards enforcement | Team-level autonomy |
| **Module sharing** | Direct path references (`../../modules/`) | Registry or git refs |
| **Refactoring** | Easier (atomic cross-cutting changes) | Harder (multi-repo PRs) |

### Recommended Monorepo Structure

```
infrastructure/
  modules/                          # Reusable modules
    networking/
    compute/
    database/
    iam/
    monitoring/
  environments/                     # Root modules per env + layer
    dev/
      networking/
        main.tf
        backend.tf
        variables.tf
        terraform.tfvars
      compute/
      data/
    staging/
      networking/
      compute/
      data/
    prod/
      networking/
      compute/
      data/
  policies/                         # OPA/Sentinel policies
    naming.rego
    tagging.rego
    security.rego
  .github/
    workflows/
      terraform-plan.yml
      terraform-apply.yml
  .tflint.hcl                      # Linter config
  .pre-commit-config.yaml           # Pre-commit hooks
```

### Environment Separation (Ranked)

1. **Directory-based (recommended).** Each environment is a separate root module directory. Explicit, auditable, no hidden state. Divergence is visible in code.

2. **Terragrunt.** When managing 10+ environments with DRY configuration. Adds tooling dependency but reduces boilerplate significantly.

3. **Workspaces (ephemeral only).** Good for PR preview environments, sandbox clusters, short-lived test environments. Not recommended for permanent environments — workspace state differences are invisible in code.

---

## 4. Variable and Output Patterns

### Validation Rules

```hcl
# contains — enumerated values
variable "instance_type" {
  type = string
  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium", "m5.large"], var.instance_type)
    error_message = "Instance type must be one of: t3.micro, t3.small, t3.medium, m5.large."
  }
}

# regex — pattern matching
variable "project_name" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,28}[a-z0-9]$", var.project_name))
    error_message = "Project name must be 4-30 chars, lowercase alphanumeric and hyphens, start with letter."
  }
}

# can — structural validation
variable "cidr_blocks" {
  type = list(string)
  validation {
    condition     = alltrue([for cidr in var.cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "All entries must be valid CIDR blocks."
  }
}

# cross-variable validation (TF 1.9+)
variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3

  validation {
    condition     = var.max_size >= var.min_size
    error_message = "max_size must be >= min_size."
  }
}
```

### Type Constraints

Always declare explicit types. Use `object()` for complex structures and `optional()` (Terraform 1.3+) for fields with defaults:

```hcl
variable "database_config" {
  description = "Database configuration"
  type = object({
    engine         = string
    engine_version = string
    instance_class = string
    storage_gb     = number
    multi_az       = optional(bool, false)
    backup = optional(object({
      retention_days = optional(number, 7)
      window         = optional(string, "03:00-04:00")
    }), {})
  })
}
```

### Sensitive Variables

```hcl
variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}
```

Rules:
- Mark `sensitive = true` on any variable containing secrets
- Inject from secrets managers (Vault, AWS Secrets Manager, Infisical) via data sources or environment variables
- Never commit secrets in `.tfvars` files to version control
- Use `.gitignore` for `*.auto.tfvars` files containing secrets

### Ephemeral Variables (Terraform 1.10+)

Ephemeral variables are never written to state, plan files, or CLI output. Use them for values that must not persist:

```hcl
ephemeral "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/database/password"
}

resource "aws_db_instance" "this" {
  # ...
  password = ephemeral.aws_secretsmanager_secret_version.db_password.secret_string
}
```

### Output Naming

Follow the pattern `{resource}_{attribute}`:

```hcl
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "db_endpoint" {
  description = "The connection endpoint for the database"
  value       = aws_db_instance.this.endpoint
  sensitive   = true
}
```

Group outputs logically in `outputs.tf`: networking outputs together, compute outputs together, etc.

---

## 5. Naming Conventions

### Resource Naming

```hcl
# Use underscores, not dashes, in Terraform identifiers
resource "aws_instance" "web_server" {}    # Good
resource "aws_instance" "web-server" {}    # Bad

# Use "this" for the single resource in a module
resource "aws_vpc" "this" {}               # Good (in a VPC module)
resource "aws_vpc" "main_vpc" {}           # Bad (redundant — it's a VPC module)

# Don't repeat the resource type in the name
resource "aws_s3_bucket" "logs" {}         # Good
resource "aws_s3_bucket" "s3_bucket" {}    # Bad
resource "aws_s3_bucket" "log_bucket" {}   # Bad

# Be descriptive when a module has multiple of the same resource
resource "aws_subnet" "public" {}
resource "aws_subnet" "private" {}
resource "aws_subnet" "database" {}
```

### Variable Naming

```hcl
# snake_case always
variable "instance_type" {}       # Good
variable "instanceType" {}        # Bad

# Plural for lists and maps
variable "subnet_ids" {           # Good — list
  type = list(string)
}
variable "tags" {                 # Good — map
  type = map(string)
}

# Boolean prefixes: enable_, is_, has_
variable "enable_monitoring" {    # Good
  type    = bool
  default = true
}
variable "is_public" {            # Good
  type    = bool
  default = false
}
```

### Canonical File Names

| File | Purpose |
|------|---------|
| `main.tf` | Primary resource definitions |
| `variables.tf` | All input variable declarations |
| `outputs.tf` | All output declarations |
| `providers.tf` | Provider configuration (root modules only) |
| `versions.tf` | `required_version` and `required_providers` |
| `locals.tf` | Local value computations and transformations |
| `data.tf` | Data source declarations |
| `backend.tf` | Backend configuration (root modules only) |

For larger modules, split `main.tf` by resource type: `vpc.tf`, `subnets.tf`, `security_groups.tf`. Keep the canonical files for variables, outputs, and versions.

---

## 6. DRY Patterns

### for_each vs count

**Prefer `for_each`** — it's keyed by map or set, so adding/removing items doesn't shift indices and destroy unrelated resources.

```hcl
# Good: for_each with a map
variable "subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    public_a  = { cidr = "10.0.1.0/24", az = "us-east-1a" }
    public_b  = { cidr = "10.0.2.0/24", az = "us-east-1b" }
    private_a = { cidr = "10.0.3.0/24", az = "us-east-1a" }
  }
}

resource "aws_subnet" "this" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = { Name = each.key }
}
```

**Use `count` only for on/off toggles:**

```hcl
resource "aws_cloudwatch_metric_alarm" "cpu" {
  count = var.enable_monitoring ? 1 : 0
  # ...
}
```

### Dynamic Blocks

Use dynamic blocks to conditionally generate repeated nested blocks. Always name the iterator explicitly and limit nesting to 2 levels maximum:

```hcl
resource "aws_security_group" "this" {
  name   = var.name
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    iterator = rule

    content {
      description = rule.value.description
      from_port   = rule.value.from_port
      to_port     = rule.value.to_port
      protocol    = rule.value.protocol
      cidr_blocks = rule.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    iterator = rule

    content {
      from_port   = rule.value.from_port
      to_port     = rule.value.to_port
      protocol    = rule.value.protocol
      cidr_blocks = rule.value.cidr_blocks
    }
  }
}
```

### Locals for Data Transformation

```hcl
locals {
  # Merge default tags with user-provided tags
  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
      Owner       = var.team
    },
    var.extra_tags,
  )

  # Transform a flat list into a map keyed by name
  subnet_map = {
    for subnet in var.subnets :
    subnet.name => subnet
  }

  # Flatten nested structures
  role_policy_attachments = flatten([
    for role_name, policies in var.role_policies : [
      for policy_arn in policies : {
        role   = role_name
        policy = policy_arn
      }
    ]
  ])
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = {
    for rpa in local.role_policy_attachments :
    "${rpa.role}-${rpa.policy}" => rpa
  }

  role       = each.value.role
  policy_arn = each.value.policy
}
```

### templatefile for Config Generation

```hcl
resource "aws_instance" "this" {
  # ...
  user_data = templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
    hostname    = var.hostname
    ssh_keys    = var.ssh_public_keys
    environment = var.environment
    packages    = ["nginx", "certbot", "fail2ban"]
  })
}
```

---

## 7. Version Constraints

### Terraform Version

Use pessimistic constraints in every module:

```hcl
# versions.tf
terraform {
  required_version = "~> 1.10"
}
```

`~> 1.10` allows `1.10.x` and `1.11.x` etc. up to (but not including) `2.0`. For tighter control in production, pin to minor: `~> 1.10.0` (allows only `1.10.x` patches).

### Provider Versions

**Root modules:** Pessimistic constraint pinned to current minor:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }
}
```

**Reusable modules:** Floor constraint to maximize compatibility:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
```

### Lock File

**Always commit `.terraform.lock.hcl`** to version control. It pins exact provider versions and hashes across all platforms your team uses.

```bash
# Update lock file for all platforms your team uses
terraform providers lock \
  -platform=darwin_amd64 \
  -platform=darwin_arm64 \
  -platform=linux_amd64
```

**Important:** The lock file pins *providers* only. It does NOT lock module versions. Module versions must be pinned explicitly in `source` references.

### Module Version Pinning

```hcl
# Registry module: always pin version
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"
}

# Git module: always pin ref
module "custom" {
  source = "git::https://github.com/org/tf-modules.git//networking?ref=v2.1.0"
}

# Never use unversioned module references in production
```

---

## 8. Security Best Practices

### State File Security

State files contain sensitive data in plaintext (passwords, keys, certificates). Treat them as secrets:

1. **Encrypt at rest.** Enable SSE-S3 or SSE-KMS on the state bucket. GCS and Azure Blob encrypt by default.
2. **Version the bucket.** Enable object versioning to recover from corruption or accidental deletion.
3. **Restrict access.** Bucket policy should allow only CI/CD service accounts and break-glass admin roles.
4. **Enable access logging.** Audit who reads/writes state files.
5. **Never commit to VCS.** `.gitignore` must include `*.tfstate` and `*.tfstate.backup`.
6. **Classify as sensitive.** State files are as sensitive as the secrets they contain.

```hcl
# S3 bucket policy for state
resource "aws_s3_bucket_policy" "state" {
  bucket = aws_s3_bucket.state.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyUnencryptedUploads"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.state.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      },
      {
        Sid       = "DenyNonSSL"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.state.arn,
          "${aws_s3_bucket.state.arn}/*",
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      },
    ]
  })
}
```

### Secrets Management Hierarchy

From best to worst:

1. **Ephemeral resources (Terraform 1.10+).** Secrets never written to state. Best option when available.
2. **External secrets manager with data sources.** Vault, AWS Secrets Manager, Infisical. Secrets referenced at plan/apply time, only the resource attribute (not the raw secret) ends up in state.
3. **Sensitive variables.** Marked `sensitive = true`. Still written to state in plaintext, but masked in CLI output and logs.
4. **Environment variables.** `TF_VAR_db_password`. No audit trail, visible in process lists.
5. **NEVER hardcoded.** Secrets in `.tf` files or committed `.tfvars` is a security incident.

### Write-Only Arguments (Terraform 1.11+)

Write-only arguments are never stored in state or displayed in plans:

```hcl
resource "aws_db_instance" "this" {
  # ...
  password_wo         = var.db_password  # Write-only: never persisted in state
  password_wo_version = 1                # Increment to trigger rotation
}
```

This is the strongest protection for secrets in resource arguments. Use when the provider supports it.

### Policy as Code — Layered Approach

| Layer | Tool | When | Catches |
|-------|------|------|---------|
| **Pre-commit** | tfsec, checkov, trivy | Before code review | Known misconfigurations, CIS benchmarks |
| **Plan-time** | OPA/Conftest, Sentinel | After `terraform plan` | Policy violations against planned changes |
| **Runtime** | AWS Config, Azure Policy, GCP Org Policy | Continuously | Drift, manual changes, runtime violations |

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.88.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_tflint
      - id: terraform_tfsec
      - id: terraform_checkov
```

```rego
# policies/tagging.rego — OPA policy example
package terraform.tagging

required_tags := {"Environment", "Project", "ManagedBy", "Owner"}

deny[msg] {
  resource := input.resource_changes[_]
  resource.change.after.tags != null
  missing := required_tags - {tag | resource.change.after.tags[tag]}
  count(missing) > 0
  msg := sprintf("Resource %s is missing required tags: %v", [resource.address, missing])
}

deny[msg] {
  resource := input.resource_changes[_]
  resource.change.after.tags == null
  msg := sprintf("Resource %s has no tags at all", [resource.address])
}
```

### Service Account Least Privilege

1. **Separate service accounts per environment.** `terraform-dev`, `terraform-staging`, `terraform-prod`.
2. **Scope to managed resources.** Don't give the Terraform service account `AdministratorAccess`. Scope IAM policies to the resource types the configuration actually manages.
3. **Use OIDC federation.** GitHub Actions, GitLab CI, and Spacelift all support OIDC for short-lived credentials. No long-lived access keys.

```hcl
# OIDC provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "terraform_ci" {
  name = "terraform-ci-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:org/infra:ref:refs/heads/main"
        }
      }
    }]
  })
}
```

---

## 9. CI/CD Integration

### Tool Comparison

| Tool | Type | Plan/Apply | Policy | Cost Est. | Drift | Notes |
|------|------|-----------|--------|-----------|-------|-------|
| **Atlantis** | Self-hosted | PR-driven | Conftest | Via Infracost | No | Mature, GitOps-native, free |
| **Spacelift** | SaaS | PR + scheduled | OPA built-in | Built-in | Yes | Strong policy engine, custom runners |
| **HCP Terraform** | SaaS | PR + API | Sentinel | Built-in | Yes | HashiCorp-native, tight integration |
| **GitHub Actions** | SaaS | Workflow-driven | Manual | Via Infracost | No | Flexible, familiar, DIY assembly |
| **Scalr** | SaaS | PR-driven | OPA | Built-in | Yes | Multi-tenant, hierarchical policies |
| **env0** | SaaS | PR-driven | OPA | Built-in | Yes | Budget controls, RBAC |

### Recommended Pipeline Stages

```
fmt ──→ validate ──→ tflint ──→ tfsec/checkov ──→ infracost ──→ plan ──→ approval ──→ apply
 │         │           │            │                 │           │          │           │
 │         │           │            │                 │           │          │           │
 fast      fast        fast         medium            medium      slow       human       slow
 (lint)    (syntax)    (rules)      (security)        (cost)      (cloud)    (gate)      (cloud)
```

**Stage details:**

1. **`terraform fmt -check`** — Enforces canonical formatting. Fails fast on style violations.
2. **`terraform validate`** — Validates syntax and internal consistency. No cloud API calls.
3. **`tflint`** — Catches provider-specific errors (invalid instance types, deprecated arguments). Runs without credentials.
4. **`tfsec` / `checkov` / `trivy`** — Static security scanning against CIS benchmarks and custom rules.
5. **`infracost`** — Cost estimation posted as PR comment. Catches unexpected cost spikes before apply.
6. **`terraform plan`** — Generates execution plan against real infrastructure. Requires cloud credentials.
7. **Approval gate** — Human review of the plan. Required for staging/prod. Auto-approve for dev (optional).
8. **`terraform apply`** — Executes the plan. Should use the saved plan file from step 6.

### Hybrid Pattern

Use GitHub Actions for the fast, credential-free stages (fmt through security scanning) and Atlantis or Spacelift for plan/apply:

```yaml
# .github/workflows/terraform-lint.yml
name: Terraform Lint & Security
on:
  pull_request:
    paths: ["environments/**", "modules/**"]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.10.3"

      - name: Format Check
        run: terraform fmt -check -recursive

      - name: Validate
        run: |
          for dir in $(find environments -name "*.tf" -exec dirname {} \; | sort -u); do
            echo "=== Validating $dir ==="
            terraform -chdir="$dir" init -backend=false
            terraform -chdir="$dir" validate
          done

      - name: TFLint
        uses: terraform-linters/setup-tflint@v4
        with:
          tflint_version: latest
      - run: |
          tflint --init
          tflint --recursive --format compact

      - name: Security Scan
        uses: aquasecurity/tfsec-action@v1.0.3
        with:
          soft_fail: false

      - name: Checkov
        uses: bridgecrewio/checkov-action@v12
        with:
          directory: environments/
          framework: terraform
          quiet: true

      - name: Infracost
        uses: infracost/actions/setup@v3
        with:
          api-key: ${{ secrets.INFRACOST_API_KEY }}
      - run: |
          infracost breakdown --path=environments/dev/compute \
            --format=json --out-file=/tmp/infracost.json
          infracost comment github \
            --path=/tmp/infracost.json \
            --repo=${{ github.repository }} \
            --pull-request=${{ github.event.pull_request.number }} \
            --behavior=update
```

Atlantis or Spacelift then handles `plan` and `apply` with proper cloud credentials, state locking, and approval workflows. This separation ensures security scanning runs on every PR (even if the plan/apply tool is down) and that cloud credentials are never exposed to the linting pipeline.

---

## Quick Reference Card

| Decision | Recommendation |
|----------|---------------|
| Module or inline? | Module if used 2+ times or enforcing standards |
| for_each or count? | for_each; count only for on/off toggles |
| Workspaces or directories? | Directories for permanent envs, workspaces for ephemeral |
| Monorepo or polyrepo? | Monorepo under 15 infra engineers |
| State locking? | S3 `use_lockfile = true` (TF 1.10+) |
| Secrets? | Ephemeral resources > Secrets Manager > sensitive vars |
| Provider version constraint? | `~> major.minor` in root, `>= major.0` in modules |
| Lock file committed? | Always — `.terraform.lock.hcl` |
| Policy as code? | Pre-commit (tfsec) + plan-time (OPA) + runtime (cloud-native) |
| CI/CD? | GHA for lint/security + Atlantis/Spacelift for plan/apply |
