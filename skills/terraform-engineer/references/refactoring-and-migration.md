# Refactoring and Migration

## moved Blocks (TF 1.1+)

The `moved` block tells Terraform that a resource's address has changed without recreating it. Terraform updates the state file automatically during `terraform apply`.

### Rename a Resource

```hcl
# Old: aws_s3_bucket.data
# New: aws_s3_bucket.application_data
resource "aws_s3_bucket" "application_data" {
  bucket = "my-app-data-bucket"
}

moved {
  from = aws_s3_bucket.data
  to   = aws_s3_bucket.application_data
}
```

### Move a Resource into a Module

```hcl
# Old: aws_vpc.main (root module)
# New: module.networking.aws_vpc.main
module "networking" {
  source = "./modules/networking"
}

moved {
  from = aws_vpc.main
  to   = module.networking.aws_vpc.main
}

moved {
  from = aws_subnet.public
  to   = module.networking.aws_subnet.public
}

moved {
  from = aws_internet_gateway.main
  to   = module.networking.aws_internet_gateway.main
}
```

### Rename a Module

```hcl
# Old: module.web_servers
# New: module.compute
module "compute" {
  source = "./modules/compute"
}

moved {
  from = module.web_servers
  to   = module.compute
}
```

### Migrate from count to for_each

```hcl
# Old: aws_instance.worker[0], aws_instance.worker[1]
# New: aws_instance.worker["alpha"], aws_instance.worker["bravo"]
variable "workers" {
  default = {
    alpha = { instance_type = "t3.medium" }
    bravo = { instance_type = "t3.large" }
  }
}

resource "aws_instance" "worker" {
  for_each      = var.workers
  ami           = "ami-0abcdef1234567890"
  instance_type = each.value.instance_type
}

moved {
  from = aws_instance.worker[0]
  to   = aws_instance.worker["alpha"]
}

moved {
  from = aws_instance.worker[1]
  to   = aws_instance.worker["bravo"]
}
```

### Chained Moves for Multi-Version Module Upgrades

When upgrading a module across multiple versions, chain moves:

```hcl
# v1 → v2: resource was renamed
moved {
  from = aws_iam_role.lambda
  to   = aws_iam_role.function_execution
}

# v2 → v3: resource was moved into a sub-module
moved {
  from = aws_iam_role.function_execution
  to   = module.iam.aws_iam_role.execution
}
```

Terraform resolves the chain: `aws_iam_role.lambda` → `aws_iam_role.function_execution` → `module.iam.aws_iam_role.execution`.

### Limitations and Lifecycle

- **Cannot cross state boundaries**: `moved` only works within a single state file. For cross-state moves, use `terraform state mv`.
- **Shared modules**: Keep `moved` blocks indefinitely in reusable/shared modules — consumers may upgrade at different times.
- **Root modules**: Safe to remove `moved` blocks after the apply has run and all environments have been updated.

---

## import Blocks (TF 1.5+)

Declarative import replaces the `terraform import` CLI command. The import is defined in config and executed during `terraform plan`/`apply`.

### Basic Import

```hcl
# Import an existing S3 bucket into Terraform management
import {
  to = aws_s3_bucket.legacy_data
  id = "my-legacy-data-bucket"
}

resource "aws_s3_bucket" "legacy_data" {
  bucket = "my-legacy-data-bucket"
}
```

### Auto-Generate Configuration

When importing resources you haven't written config for yet, Terraform can generate the HCL:

```bash
# Step 1: Write the import block only (no resource block yet)
# main.tf:
#   import {
#     to = aws_s3_bucket.legacy_data
#     id = "my-legacy-data-bucket"
#   }

# Step 2: Generate config
terraform plan -generate-config-out=generated.tf

# Step 3: Review generated.tf, clean up, move into proper files
# Step 4: Run terraform plan — should show no changes (import only)
# Step 5: Apply
terraform apply
```

The generated config will include every attribute, including computed values. Clean it up: remove computed-only attributes, replace hardcoded values with variables, organize into your file structure.

### Bulk Import with for_each

```hcl
locals {
  existing_buckets = {
    logs    = "company-logs-bucket"
    backups = "company-backups-bucket"
    assets  = "company-assets-bucket"
  }
}

import {
  for_each = local.existing_buckets
  to       = aws_s3_bucket.managed[each.key]
  id       = each.value
}

resource "aws_s3_bucket" "managed" {
  for_each = local.existing_buckets
  bucket   = each.value
}
```

---

## removed Blocks (TF 1.7+)

The `removed` block removes a resource from Terraform state without destroying the actual infrastructure. This replaces `terraform state rm`.

### Remove from State, Keep Infrastructure

```hcl
# We no longer want Terraform to manage this bucket,
# but we do NOT want to delete it.
removed {
  from = aws_s3_bucket.legacy_data

  lifecycle {
    destroy = false
  }
}
```

Run `terraform apply` — Terraform removes `aws_s3_bucket.legacy_data` from state. The actual S3 bucket remains untouched.

### Remove an Entire Module

```hcl
removed {
  from = module.deprecated_monitoring

  lifecycle {
    destroy = false
  }
}
```

This removes every resource managed by `module.deprecated_monitoring` from state without destroying any of them.

### When to Use

- Migrating a resource to a different Terraform state/workspace
- Handing off infrastructure management to another team
- Decommissioning Terraform management of resources that must persist (DNS records, databases, etc.)
- Cleaning up after `terraform import` mistakes

---

## State Surgery (When Blocks Aren't Enough)

Sometimes `moved`, `import`, and `removed` blocks are insufficient — you need direct state manipulation. This is the escape hatch. Use it carefully.

### Essential Commands

```bash
# List all resources in state
terraform state list

# Show details of a specific resource
terraform state show aws_instance.web

# Move a resource to a new address (within same state)
terraform state mv aws_instance.web aws_instance.application

# Move a resource to a new address (same state, module context)
terraform state mv aws_instance.web module.compute.aws_instance.web

# Remove a resource from state (does NOT destroy infrastructure)
terraform state rm aws_s3_bucket.old_bucket

# Download state to a local file
terraform state pull > current.tfstate

# Upload a local state file (dangerous — last resort)
terraform state push modified.tfstate
```

### Always Backup First

```bash
# Before ANY state surgery
terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate

# Verify the backup is valid
terraform show backup-*.tfstate | head -20
```

### Cross-State Moves

Moving resources between completely separate state files (different backends, different workspaces):

```bash
# Step 1: Backup both states
terraform -chdir=source state pull > source-backup.tfstate
terraform -chdir=dest state pull > dest-backup.tfstate

# Step 2: Remove from source state
terraform -chdir=source state mv \
  -state-out=dest/terraform.tfstate \
  'aws_instance.web' \
  'aws_instance.web'

# Step 3: If using remote backends, push the modified dest state
# (Step 2 writes to a local file — you may need to push it)

# Step 4: Move the HCL resource definition from source to dest config

# Step 5: Verify both sides
terraform -chdir=source plan   # Should show no changes (resource removed from config + state)
terraform -chdir=dest plan     # Should show no changes (resource now in config + state)
```

**Note**: As of Terraform 1.8+, cross-backend `state mv` is limited. The recommended approach is: `state pull` from source, `state rm` from source, manually edit the pulled JSON to create a partial state, then use `import` blocks in the destination. This avoids the fragile `state push` path.

---

## Splitting Monoliths

Large Terraform states become slow to plan, risky to apply (blast radius), and contentious in teams (state locking conflicts). Here is a systematic approach to splitting them.

### Step-by-Step Process

**1. Map dependencies**

```bash
# Visualize the dependency graph
terraform graph | dot -Tpng > graph.png

# List all resources
terraform state list | sort > resources.txt

# Count resources (rule of thumb: split when >200)
terraform state list | wc -l
```

**2. Group by lifecycle**

Identify natural boundaries:
- **Networking** (VPC, subnets, route tables) — changes rarely
- **Compute** (instances, ASGs, ECS services) — changes frequently
- **Data** (RDS, S3, DynamoDB) — changes rarely, high-risk
- **DNS/CDN** (Route53, CloudFront) — changes rarely
- **IAM** (roles, policies) — changes moderately

Resources that change together should stay together.

**3. Create new state backend**

```hcl
# networking/backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "networking/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

**4. Move resources**

For each resource moving to the new state:

```bash
# Option A: state mv (direct, works within same backend)
terraform state mv -state-out=networking/terraform.tfstate \
  'aws_vpc.main' 'aws_vpc.main'

# Option B: moved blocks (preferred for clarity)
# Add moved blocks in the NEW config, pointing from old address to new
```

**5. Wire cross-state references with terraform_remote_state**

```hcl
# In compute/main.tf — reference networking outputs
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "my-terraform-state"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "web" {
  subnet_id = data.terraform_remote_state.networking.outputs.public_subnet_id
  # ...
}
```

**6. Validate: plan shows no changes on both sides**

```bash
cd networking && terraform plan   # "No changes. Your infrastructure matches the configuration."
cd ../compute && terraform plan   # "No changes. Your infrastructure matches the configuration."
```

If either plan shows changes, something was missed. Do NOT apply until both are clean.

**7. Clean up**

- Remove moved blocks from root modules (after all environments are updated)
- Archive the old monolith backend configuration
- Update CI/CD pipelines to plan/apply each state independently
- Document the new state layout

---

## Module Extraction

When you see the same pattern repeated across configurations, extract it into a reusable module.

### Process

```hcl
# BEFORE: repeated in root module
resource "aws_security_group" "app" {
  name        = "my-app-sg"
  description = "Application security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# AFTER: extracted to modules/app-sg/main.tf
# (move the resource definition into the module)

# Root module now calls:
module "app_sg" {
  source = "./modules/app-sg"
  name   = "my-app-sg"
  vpc_id = aws_vpc.main.id
}

# Tell Terraform the resource moved:
moved {
  from = aws_security_group.app
  to   = module.app_sg.aws_security_group.this
}
```

Run `terraform plan` — it should show **no changes** (only a state move). Apply, then remove the `moved` block after all consumers have upgraded.

---

## Provider Version Upgrades

Provider upgrades can introduce breaking changes to resource schemas, attribute names, and default behaviors.

### Strategy

1. **Pin the new version** in your version constraint
2. **Run `terraform init -upgrade`** to download it
3. **Run `terraform plan`** and review every proposed change carefully
4. **Address deprecation warnings** — they become errors in the next major version
5. **Apply in non-prod first** — always test provider upgrades in dev/staging before production
6. **Lock provider versions BEFORE upgrading Terraform core** — upgrade providers and core separately

### Version Constraint Patterns

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Pin to minor version range — allows patch updates
      version = "~> 5.40"
    }
  }
}
```

### AWS Provider v5 to v6 Migration Highlights

Key breaking changes to watch for:
- **S3 bucket refactoring**: Several inline arguments removed in v4 are now errors (ACL, CORS, lifecycle, logging, versioning — must use separate resources)
- **Default tags propagation changes**: Review `default_tags` behavior carefully
- **Removed data sources and resources**: Check the upgrade guide for any resources you use
- **New required arguments**: Some resources gain required fields in major versions

Always consult the provider's UPGRADE guide:
```
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-6-upgrade
```

---

## Terraform Version Upgrades

### Golden Rule

**Upgrade one minor/major version at a time.** Get a clean plan at each step before proceeding to the next. Skipping versions can compound breaking changes into an undebuggable mess.

### Version Migration Path

| From | To | Key Changes |
|------|-----|-------------|
| 0.12 | 0.13 | `required_providers` block with `source`; automatic `terraform 0.13upgrade` tool |
| 0.13 | 0.14 | Sensitive variable marking; concise diff output; lock file (`.terraform.lock.hcl`) |
| 0.14 | 0.15 | `terraform state replace-provider`; `moved` precursor (`terraform state mv` improvements) |
| 0.15 | 1.0 | Stability guarantee; no breaking changes from 0.15; symbolic milestone |
| 1.0 | 1.1 | `moved` blocks |
| 1.1 | 1.3 | `Optional` object type attributes |
| 1.3 | 1.4 | `terraform_data` resource (replaces `null_resource`) |
| 1.4 | 1.5 | `import` blocks; `check` blocks; `terraform plan -generate-config-out` |
| 1.5 | 1.6 | `terraform test` (built-in testing framework); last MPL-licensed version |
| 1.6 | 1.7 | `removed` blocks; BSL license begins |
| 1.7 | 1.8 | Provider-defined functions; `templatestring()` function; backend improvements |
| 1.8 | 1.9 | Ephemeral resources; `terraform output -json` improvements |

### Upgrade Procedure

```bash
# Step 1: Ensure clean state at current version
terraform plan   # Must show "No changes"

# Step 2: Update version constraint
# required_version = "~> 1.8.0"  →  required_version = "~> 1.9.0"

# Step 3: Install new version (tfenv, mise, asdf, or manual)
tfenv install 1.9.5
tfenv use 1.9.5

# Step 4: Re-init and upgrade providers
terraform init -upgrade

# Step 5: Plan and review
terraform plan

# Step 6: Address any deprecation warnings or errors

# Step 7: Apply in non-prod, then prod
terraform apply
```

### OpenTofu Migration

OpenTofu is a drop-in replacement for Terraform, forked at v1.5.7 (the last MPL-licensed version).

```bash
# For Terraform <= 1.5.x, direct swap:
# 1. Install OpenTofu
brew install opentofu

# 2. Replace terraform with tofu in your commands
tofu init
tofu plan
tofu apply

# State files are compatible. No migration needed for TF <= 1.5.
# For TF 1.6+, test carefully — features like `removed` blocks
# may have divergent implementations.
```

OpenTofu tracks its own feature set post-fork. Notable additions: client-side state encryption, early `moved` block enhancements. Check compatibility before migrating from TF 1.6+.

---

## Replacing Deprecated Patterns

### null_resource to terraform_data (TF 1.4+)

`null_resource` requires the `hashicorp/null` provider. `terraform_data` is built-in.

```hcl
# OLD (deprecated)
resource "null_resource" "bootstrap" {
  triggers = {
    cluster_id = aws_eks_cluster.main.id
  }

  provisioner "local-exec" {
    command = "kubectl apply -f manifests/"
  }
}

# NEW
resource "terraform_data" "bootstrap" {
  triggers_replace = [aws_eks_cluster.main.id]

  provisioner "local-exec" {
    command = "kubectl apply -f manifests/"
  }
}
```

`terraform_data` also supports `input` and `output` for passing values through the graph without a provider:

```hcl
resource "terraform_data" "version" {
  input = var.app_version
}

# Reference: terraform_data.version.output
```

### Provisioners to Better Alternatives

Provisioners are a last resort. Prefer:

| Instead of... | Use... |
|----------------|--------|
| `remote-exec` for server config | **cloud-init** / **user_data** scripts |
| `remote-exec` for software install | **Packer** to bake AMIs/images |
| `local-exec` for API calls | **Native Terraform resources** or **provider data sources** |
| `local-exec` for kubectl | **Kubernetes provider** resources |
| `local-exec` for shell scripts | **terraform_data** with `provisioner` (if truly needed) |
| `file` provisioner | **cloud-init write_files** or **S3 + instance profile** |

### Inline Security Group Rules to Separate Resources

Inline rules cause full replacement on any change and conflict with separate rule resources.

```hcl
# OLD (avoid)
resource "aws_security_group" "web" {
  name = "web-sg"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# NEW (preferred)
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Web security group"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.web.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "HTTPS from anywhere"
}
```

### terraform refresh to terraform apply -refresh-only

`terraform refresh` silently modifies state without confirmation. Use the safer alternative:

```bash
# OLD (deprecated, modifies state without confirmation)
terraform refresh

# NEW (shows what will change in state, requires confirmation)
terraform apply -refresh-only

# To auto-approve (CI/CD):
terraform apply -refresh-only -auto-approve
```

`apply -refresh-only` shows you exactly which state attributes will be updated before writing, giving you a chance to catch unexpected drift.
