# Anti-Patterns and Pitfalls

A comprehensive reference for recognizing, diagnosing, and fixing the most common Terraform mistakes — from architectural blunders to subtle runtime gotchas.

**Severity scale:** CRITICAL (data loss / security breach), HIGH (outages / state corruption), MEDIUM (tech debt / slow operations), LOW (maintainability / style)

---

## Anti-Patterns

### 1. Monolithic Root Modules

**Severity: HIGH**

**Description:** Everything lives in a single root module — networking, compute, databases, IAM, DNS. Plan times hit 20+ minutes. A typo in a tag destroys a database.

**Why it happens:** Projects start small. "We'll split it later" never happens.

**The fix:** Split by lifecycle, blast radius, and team ownership.

```hcl
# BAD: one root module with everything
# main.tf — 2,000 lines, 500 resources, 22-minute plans

# GOOD: separate root modules per concern
# infrastructure/
#   networking/        -> VPC, subnets, NAT, TGW
#   data/              -> RDS, ElastiCache, S3
#   compute/           -> EKS, ASGs, launch templates
#   identity/          -> IAM roles, policies, OIDC
#   dns/               -> Route53, certificates

# Each has its own state, its own blast radius.
# Use terraform_remote_state or SSM parameters to share outputs.

# networking/outputs.tf
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

# compute/data.tf — reads networking outputs
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "myorg-terraform-state"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_eks_cluster" "main" {
  vpc_config {
    subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids
  }
}
```

**Rule of thumb:** If your `terraform plan` takes more than 60 seconds, your module is too big.

---

### 2. Over-Modularization

**Severity: MEDIUM**

**Description:** Every single resource gets its own module. A VPC module wraps one `aws_vpc`. A subnet module wraps one `aws_subnet`. You end up with 40 modules, each with 3 files, for what should be 15 resources.

**Why it happens:** Someone read "use modules" and overcorrected. Or: copying patterns from general-purpose programming where "small functions" is always good advice.

**The fix:** Module when 3+ resources form a logical unit with a clear interface.

```hcl
# BAD: single-resource wrappers
module "vpc" {
  source = "./modules/vpc"   # wraps one aws_vpc
}
module "subnet_a" {
  source = "./modules/subnet" # wraps one aws_subnet
}
module "subnet_b" {
  source = "./modules/subnet"
}
module "igw" {
  source = "./modules/igw"    # wraps one aws_internet_gateway
}
# 4 modules for 4 resources — pointless indirection

# GOOD: one module for the logical unit
module "vpc" {
  source = "./modules/vpc"

  cidr_block         = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = true
}
# One module, clean interface, encapsulates ~15 resources
```

**Test:** If your module wraps fewer than 3 resources and has no conditional logic, it's probably not worth the indirection.

---

### 3. Hard-Coded Values

**Severity: MEDIUM**

**Description:** AMI IDs, CIDR blocks, account IDs, and region names baked directly into resource blocks.

**Why it happens:** Copy-paste from console or documentation. "I'll parameterize it later."

**The fix:** Data sources for dynamic lookups, variables for user input, locals for computed values.

```hcl
# BAD
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"  # what region? what OS? when does it expire?
  instance_type = "t3.medium"
  subnet_id     = "subnet-0bb1c79de3EXAMPLE"

  tags = {
    Environment = "production"
    CostCenter  = "CC-12345"
  }
}

# GOOD
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

locals {
  common_tags = {
    Environment = var.environment
    CostCenter  = var.cost_center
    ManagedBy   = "terraform"
    Module      = basename(path.module)
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = data.aws_subnet.selected.id

  tags = merge(local.common_tags, {
    Name = "${var.project}-web-${var.environment}"
  })
}
```

---

### 4. State File Abuse — One State for the Entire Org

**Severity: CRITICAL**

**Description:** A single state file contains every resource across every environment, every team, every region. A bad apply in dev destroys prod. Plans take forever. Lock contention blocks everyone.

**Why it happens:** Started with one state, never split. Or: "we want a single source of truth."

**The fix:** One state per blast radius per environment. Use workspaces or directory structure.

```hcl
# BAD: one backend for everything
# s3://company-terraform/terraform.tfstate — 3,000 resources, all envs

# GOOD: directory-based separation
# environments/
#   production/
#     us-east-1/
#       networking/   -> s3://tf-state/prod/us-east-1/networking/terraform.tfstate
#       compute/      -> s3://tf-state/prod/us-east-1/compute/terraform.tfstate
#       data/         -> s3://tf-state/prod/us-east-1/data/terraform.tfstate
#   staging/
#     us-east-1/
#       networking/   -> s3://tf-state/staging/us-east-1/networking/terraform.tfstate

# backend.tf per root module
terraform {
  backend "s3" {
    bucket         = "myorg-terraform-state"
    key            = "prod/us-east-1/networking/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

**Guideline:** Each state file should contain fewer than 200 resources and represent a single team's blast radius in a single environment.

---

### 5. Provider Blocks in Child Modules

**Severity: HIGH**

**Description:** Declaring `provider` blocks inside reusable modules. This has been a hard constraint since Terraform v0.13 — modules with internal provider configurations cannot use `for_each`, `count`, or `depends_on`.

**Why it happens:** Feels natural to "encapsulate" the provider config inside the module. Some older tutorials show this pattern.

**The fix:** Declare providers in the root module only. Pass to child modules via the `providers` argument.

```hcl
# BAD: provider inside child module
# modules/s3-bucket/main.tf
provider "aws" {
  region = var.region  # breaks for_each, count, depends_on
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

# GOOD: provider declared in root, passed to module
# root/main.tf
provider "aws" {
  region = "us-east-1"
  alias  = "east"
}

provider "aws" {
  region = "eu-west-1"
  alias  = "europe"
}

module "bucket_east" {
  source = "./modules/s3-bucket"
  providers = {
    aws = aws.east
  }
  bucket_name = "my-bucket-east"
}

module "bucket_europe" {
  source = "./modules/s3-bucket"
  providers = {
    aws = aws.europe
  }
  bucket_name = "my-bucket-europe"
}

# modules/s3-bucket/main.tf — NO provider block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}
```

---

### 6. Terraform as a Programming Language

**Severity: MEDIUM**

**Description:** Nested ternaries, deeply chained `try()` calls, `regexall` for parsing, complex `for` expressions with conditionals. HCL is a configuration language — when it starts looking like Perl, you've lost.

**Why it happens:** Developers bring programming instincts to a declarative language. Terraform doesn't have if/else blocks, so ternaries stack up.

**The fix:** Use maps and lookups. Push complex logic to external data (JSON/YAML files, data sources).

```hcl
# BAD: nested ternary hell
locals {
  instance_type = (
    var.environment == "production"
    ? (var.high_memory ? "r6i.2xlarge" : "m6i.xlarge")
    : (var.environment == "staging"
      ? (var.high_memory ? "r6i.large" : "m6i.large")
      : "t3.medium"
    )
  )
}

# GOOD: map lookup
locals {
  instance_type_map = {
    production = {
      default     = "m6i.xlarge"
      high_memory = "r6i.2xlarge"
    }
    staging = {
      default     = "m6i.large"
      high_memory = "r6i.large"
    }
    development = {
      default     = "t3.medium"
      high_memory = "t3.medium"
    }
  }

  memory_profile = var.high_memory ? "high_memory" : "default"
  instance_type  = local.instance_type_map[var.environment][local.memory_profile]
}
```

---

### 7. Count for Named Resources

**Severity: HIGH**

**Description:** Using `count` to create a list of resources (e.g., subnets). Removing an item from the middle of the list shifts all indices, causing Terraform to destroy and recreate the wrong resources.

**Why it happens:** `count` was the only option before Terraform 0.12.6 introduced `for_each`. Old habits die hard. Old tutorials still teach it.

**The fix:** Use `for_each` with stable keys. Reserve `count` only for boolean toggles (0 or 1).

```hcl
# BAD: count with a list — index-dependent
variable "subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

resource "aws_subnet" "private" {
  count      = length(var.subnet_cidrs)
  cidr_block = var.subnet_cidrs[count.index]
  vpc_id     = aws_vpc.main.id
}
# Removing "10.0.1.0/24" from position 0 shifts everything:
#   subnet[0] "10.0.2.0/24" replaces "10.0.1.0/24" — IN-PLACE UPDATE (wrong CIDR!)
#   subnet[1] "10.0.3.0/24" replaces "10.0.2.0/24" — IN-PLACE UPDATE
#   subnet[2] — DESTROYED
# Result: two wrong subnets and one destroyed

# GOOD: for_each with stable keys
variable "subnets" {
  default = {
    "private-a" = { cidr = "10.0.1.0/24", az = "us-east-1a" }
    "private-b" = { cidr = "10.0.2.0/24", az = "us-east-1b" }
    "private-c" = { cidr = "10.0.3.0/24", az = "us-east-1c" }
  }
}

resource "aws_subnet" "private" {
  for_each          = var.subnets
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  vpc_id            = aws_vpc.main.id

  tags = {
    Name = each.key
  }
}
# Removing "private-a" only destroys that one subnet. Others untouched.

# ACCEPTABLE: count as a boolean toggle
resource "aws_cloudwatch_log_group" "this" {
  count             = var.enable_logging ? 1 : 0
  name              = "/app/${var.name}"
  retention_in_days = 30
}
```

---

### 8. Ignoring Lifecycle Rules

**Severity: HIGH**

**Description:** Not using lifecycle meta-arguments when resources need special handling during updates or destruction. Blue/green deployments fail. Accidental deletions of databases. Terraform fights with external systems over resource attributes.

**Why it happens:** Lifecycle rules aren't needed until they are — and then it's too late.

**The fix:** Proactively apply lifecycle rules based on resource type and operational requirements.

```hcl
# Zero-downtime replacement — create new before destroying old
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  lifecycle {
    create_before_destroy = true
  }
}

# Prevent accidental deletion of stateful resources
resource "aws_rds_instance" "main" {
  identifier     = "production-db"
  engine         = "postgres"
  instance_class = var.db_instance_class

  lifecycle {
    prevent_destroy = true
  }
}

# Ignore changes made outside Terraform (e.g., ASG desired count set by autoscaler)
resource "aws_autoscaling_group" "web" {
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

# Replace instead of update when AMI changes
resource "aws_instance" "immutable" {
  ami           = data.aws_ami.app.id
  instance_type = var.instance_type

  lifecycle {
    replace_triggered_by = [terraform_data.ami_change.output]
  }
}
```

**Lifecycle rule decision table:**

| Rule | When to Use | Example Resources |
|------|-------------|-------------------|
| `create_before_destroy` | Zero-downtime replacements, DNS cutover | Instances, launch templates, security groups, certificates |
| `prevent_destroy` | Stateful resources you must never accidentally delete | RDS, S3 buckets, DynamoDB, EFS, KMS keys |
| `ignore_changes` | External system modifies attribute (autoscaler, CI/CD, console) | ASG desired_capacity, ECS task_definition, Lambda code |
| `replace_triggered_by` | Force replacement based on another resource changing | Instances when AMI updates, ECS services on new task defs |
| `precondition` / `postcondition` (1.2+) | Validate assumptions before/after apply | Subnet has enough IPs, instance is in desired state |

---

### 9. Not Using Data Sources

**Severity: MEDIUM**

**Description:** Hardcoding AWS account IDs, VPC IDs, AMI IDs, and availability zones instead of looking them up dynamically.

**Why it happens:** It's faster to paste an ID than write a data source. "It never changes." (It always changes.)

**The fix:** Data sources for anything that exists outside your module's management.

```hcl
# BAD
resource "aws_iam_role" "lambda" {
  assume_role_policy = jsonencode({
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = "123456789012"  # hardcoded account ID
        }
      }
    }]
  })
}

# GOOD
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_iam_role" "lambda" {
  assume_role_policy = jsonencode({
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }]
  })
}

# Common data sources every project should have:
# data.aws_caller_identity.current  -> .account_id, .arn
# data.aws_region.current           -> .name
# data.aws_availability_zones.available -> .names
# data.aws_partition.current        -> .partition (aws, aws-cn, aws-us-gov)
```

---

### 10. Circular Dependencies

**Severity: HIGH**

**Description:** Two resources reference each other, creating a cycle Terraform cannot resolve. Most common with security groups: SG-A allows traffic from SG-B, SG-B allows traffic from SG-A.

**Why it happens:** Bidirectional network rules are a natural requirement. Terraform's DAG requires acyclic dependencies.

**The fix:** Use separate rule resources instead of inline rules.

```hcl
# BAD: inline rules create circular dependency
resource "aws_security_group" "web" {
  name   = "web"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]  # references alb SG
  }
}

resource "aws_security_group" "alb" {
  name   = "alb"
  vpc_id = aws_vpc.main.id

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]  # references web SG -> CYCLE
  }
}

# GOOD: separate rule resources — no cycle
resource "aws_security_group" "web" {
  name   = "web"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "alb" {
  name   = "alb"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "web_from_alb" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_to_web" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.web.id
}
```

**General rule:** If a resource type has both an inline block and a standalone resource for the same thing (security group rules, route table routes, IAM policy attachments), always use the standalone resource.

---

### 11. Secrets in Plain Text

**Severity: CRITICAL**

**Description:** Database passwords, API keys, and tokens stored in `.tfvars` files, committed to git, visible in state files, or logged in plan output.

**Why it happens:** Terraform needs secrets as inputs. The path of least resistance is a variable with a default value.

**The fix:** Layer your defenses — `sensitive = true`, secrets manager, ephemeral variables (1.10+).

```hcl
# BAD: secret in .tfvars, committed to git
# terraform.tfvars
# db_password = "hunter2"

# BAD: secret as variable default
variable "db_password" {
  default = "hunter2"  # committed to repo, visible in plan
}

# BETTER: sensitive flag + external secret store
variable "db_password" {
  type      = string
  sensitive = true  # hides from plan/apply output
}

# Read from secrets manager instead of variables
data "aws_secretsmanager_secret_version" "db" {
  secret_id = "production/database/password"
}

resource "aws_rds_cluster" "main" {
  master_password = data.aws_secretsmanager_secret_version.db.secret_string
}

# BEST (Terraform 1.10+): ephemeral variables — never stored in state
ephemeral "aws_secretsmanager_secret_version" "db" {
  secret_id = "production/database/password"
}

resource "aws_rds_cluster" "main" {
  master_password = ephemeral.aws_secretsmanager_secret_version.db.secret_string
}
```

**Defense layers:**

| Layer | What It Does | Limitation |
|-------|-------------|------------|
| `sensitive = true` | Hides from plan/apply CLI output | Still in state file |
| Secrets manager data source | Secret never in `.tfvars` | Still in state file |
| Ephemeral resources (1.10+) | Never written to state at all | Requires recent Terraform |
| Encrypted state backend | State encrypted at rest | Decrypted during operations |
| `.gitignore` for `*.tfvars` | Prevents accidental commits | Doesn't help state exposure |

---

### 12. No Remote State

**Severity: CRITICAL**

**Description:** State file lives on someone's laptop, shared via git, or stored on an unencrypted S3 bucket without locking.

**Why it happens:** Local state "just works" for solo developers. Adding a backend feels like premature optimization.

**The fix:** Remote backend with locking from day 1. Non-negotiable.

```hcl
# Minimum viable backend — S3 + DynamoDB
terraform {
  backend "s3" {
    bucket         = "myorg-terraform-state"
    key            = "project/env/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"

    # Optional but recommended
    kms_key_id = "alias/terraform-state"
  }
}

# Bootstrap the backend itself (chicken-and-egg):
# 1. Create S3 bucket + DynamoDB table manually or with a bootstrap script
# 2. Run terraform init to migrate local state to remote
# 3. Commit backend config, delete local terraform.tfstate

# DynamoDB lock table (only needs partition key "LockID")
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

---

### 13. `terraform apply -auto-approve` in Production

**Severity: CRITICAL**

**Description:** Skipping the plan review step in production pipelines. A bad merge goes straight to destroying infrastructure.

**Why it happens:** "The CI pipeline is slow enough already." Or: cargo-culting the dev workflow into prod.

**The fix:** Always separate plan and apply. Use plan files. Require human approval for production.

```hcl
# BAD: CI/CD pipeline
# terraform apply -auto-approve  # YOLO

# GOOD: separate plan and apply stages
# Stage 1: Plan (automated)
# terraform plan -out=tfplan -detailed-exitcode
# Exit code 0 = no changes, 1 = error, 2 = changes pending

# Stage 2: Review (human)
# terraform show tfplan  # review the saved plan

# Stage 3: Apply (automated after approval)
# terraform apply tfplan  # applies exactly what was planned

# Even better: use Atlantis, Spacelift, or Terraform Cloud
# atlantis.yaml
# version: 3
# projects:
#   - dir: infrastructure/production
#     workflow: production
#     apply_requirements: [approved, mergeable]
```

---

### 14. Giant Blast Radius

**Severity: HIGH**

**Description:** A single `terraform apply` touches 500+ resources across multiple teams, environments, or regions. One mistake takes down everything.

**Why it happens:** Organic growth without intentional boundaries. "We'll refactor later."

**The fix:** Split by four dimensions — team, change frequency, risk level, environment.

```
# Splitting dimensions:
#
# 1. TEAM: Who owns it?
#    networking/ — platform team
#    compute/    — platform team
#    app-foo/    — product team A
#    app-bar/    — product team B
#
# 2. FREQUENCY: How often does it change?
#    networking/ — monthly
#    iam/        — weekly
#    app-config/ — daily
#
# 3. RISK: What breaks if it goes wrong?
#    dns/        — everything breaks
#    monitoring/ — visibility breaks
#    app-foo/    — one app breaks
#
# 4. ENVIRONMENT: prod != staging != dev
#    environments/prod/networking/
#    environments/staging/networking/
#    environments/dev/networking/

# Target: each state file has 50-200 resources, plans in <30 seconds
```

---

### 15. Not Using Moved Blocks

**Severity: MEDIUM**

**Description:** Refactoring module structure with `terraform state mv` commands. Error-prone, not version-controlled, requires state access, and can't be code-reviewed.

**Why it happens:** `moved` blocks are relatively new (Terraform 1.1+). Many teams don't know they exist.

**The fix:** Declarative `moved` blocks — version-controlled, reviewable, safe.

```hcl
# BAD: manual state surgery
# terraform state mv 'aws_instance.web' 'module.compute.aws_instance.web'
# terraform state mv 'aws_instance.web[0]' 'aws_instance.web["primary"]'
# Hope you got the quoting right. Hope no one applies in the middle.

# GOOD: moved blocks (Terraform 1.1+)
moved {
  from = aws_instance.web
  to   = module.compute.aws_instance.web
}

# Rename a resource
moved {
  from = aws_s3_bucket.data
  to   = aws_s3_bucket.application_data
}

# Migrate from count to for_each
moved {
  from = aws_subnet.private[0]
  to   = aws_subnet.private["us-east-1a"]
}

moved {
  from = aws_subnet.private[1]
  to   = aws_subnet.private["us-east-1b"]
}

# Move into a module
moved {
  from = aws_security_group.web
  to   = module.networking.aws_security_group.web
}

# After successful apply, keep moved blocks for one release cycle, then remove.
```

---

### 16. Ignoring `.terraform.lock.hcl`

**Severity: MEDIUM**

**Description:** Not committing the dependency lock file. Builds are non-reproducible — different machines get different provider versions.

**Why it happens:** Gitignore templates sometimes include it. Developers don't understand what it does.

**The fix:** Always commit `.terraform.lock.hcl`. Update it intentionally.

```bash
# .gitignore — make sure this is NOT in your gitignore:
# .terraform.lock.hcl   <-- DO NOT IGNORE THIS

# When you intentionally want to upgrade providers:
terraform init -upgrade

# When adding a new platform (e.g., CI runs on linux_amd64, you dev on darwin_arm64):
terraform providers lock \
  -platform=linux_amd64 \
  -platform=darwin_arm64 \
  -platform=linux_arm64

# Commit the updated lock file with your provider version changes
git add .terraform.lock.hcl
git commit -m "chore: update provider lock for multi-platform"
```

---

### 17. Wildcard IAM Policies

**Severity: CRITICAL**

**Description:** `Action: "*"` or `Resource: "*"` in IAM policies. Grants far more access than needed. Violates principle of least privilege.

**Why it happens:** "I'll scope it down later." Or: debugging permission errors by adding `*` and never removing it.

**The fix:** Scope both Action AND Resource. Use IAM Access Analyzer to right-size.

```hcl
# BAD
data "aws_iam_policy_document" "lambda" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

# BAD — scoped action, wildcard resource
data "aws_iam_policy_document" "lambda" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["*"]  # all buckets in the account
  }
}

# GOOD — scoped action AND resource
data "aws_iam_policy_document" "lambda" {
  statement {
    sid    = "ReadWriteAppBucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "${aws_s3_bucket.app.arn}/*",
    ]
  }

  statement {
    sid    = "ListAppBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.app.arn,
    ]
  }
}
```

---

### 18. Not Using `terraform_data` (Still Using `null_resource`)

**Severity: LOW**

**Description:** Using `null_resource` with triggers for lifecycle management when `terraform_data` (Terraform 1.4+) does the same thing without a provider dependency.

**Why it happens:** `null_resource` has been around since forever. `terraform_data` is newer and less documented in tutorials.

**The fix:** Replace `null_resource` with `terraform_data`. No provider required.

```hcl
# BAD: requires hashicorp/null provider
resource "null_resource" "cluster_config" {
  triggers = {
    cluster_id = aws_eks_cluster.main.id
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name}"
  }
}

# GOOD: built-in, no provider needed (Terraform 1.4+)
resource "terraform_data" "cluster_config" {
  triggers_replace = [aws_eks_cluster.main.id]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name}"
  }
}

# terraform_data can also store and expose values:
resource "terraform_data" "build_timestamp" {
  input = timestamp()
}

output "deployed_at" {
  value = terraform_data.build_timestamp.output
}
```

---

### 19. Inline Provisioners for Things With Native Resources

**Severity: MEDIUM**

**Description:** Using `remote-exec` or `local-exec` provisioners to install packages, configure services, or create cloud resources that have native Terraform resources or better tooling.

**Why it happens:** Provisioners feel familiar to sysadmins. "I'll just SSH in and run the script."

**The fix:** Use cloud-init for instance configuration, native resources for cloud operations, and configuration management tools for complex setups.

```hcl
# BAD: provisioner to install packages
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl enable nginx",
    ]
  }
}

# GOOD: cloud-init / user_data
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  user_data     = file("${path.module}/cloud-init.yaml")
}

# cloud-init.yaml
# #cloud-config
# packages:
#   - nginx
# runcmd:
#   - systemctl enable nginx
#   - systemctl start nginx

# BAD: local-exec to create a DNS record
resource "terraform_data" "dns" {
  provisioner "local-exec" {
    command = "aws route53 change-resource-record-sets --hosted-zone-id Z123 --change-batch file://dns.json"
  }
}

# GOOD: native resource
resource "aws_route53_record" "web" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "web.example.com"
  type    = "A"
  ttl     = 300
  records = [aws_instance.web.public_ip]
}
```

---

### 20. Not Validating Variables

**Severity: MEDIUM**

**Description:** Variables accept any input — typos in environment names, invalid CIDR blocks, out-of-range ports. Errors surface deep in the apply, not at plan time.

**Why it happens:** Validation blocks are extra work. "The caller knows what to pass."

**The fix:** Validation blocks with clear error messages. Catch errors early.

```hcl
variable "environment" {
  type        = string
  description = "Deployment environment"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

variable "cidr_block" {
  type        = string
  description = "VPC CIDR block"

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "Must be a valid CIDR block (e.g., 10.0.0.0/16)."
  }

  validation {
    condition     = tonumber(split("/", var.cidr_block)[1]) >= 16 && tonumber(split("/", var.cidr_block)[1]) <= 24
    error_message = "CIDR prefix must be between /16 and /24."
  }
}

variable "port" {
  type        = number
  description = "Application port"

  validation {
    condition     = var.port >= 1 && var.port <= 65535
    error_message = "Port must be between 1 and 65535."
  }
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]+\\.[a-z0-9]+$", var.instance_type))
    error_message = "Must be a valid EC2 instance type (e.g., t3.medium, m6i.xlarge)."
  }
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"

  validation {
    condition     = contains(keys(var.tags), "Environment")
    error_message = "Tags must include an 'Environment' key."
  }
}
```

---

### 21. Not Using `import` Blocks (Still Using CLI `terraform import`)

**Severity: MEDIUM**

**Description:** Importing existing resources with the CLI command `terraform import`, which requires manual state manipulation and isn't reviewable in version control.

**Why it happens:** CLI import has been around forever. Declarative `import` blocks are newer (Terraform 1.5+).

**The fix:** Use `import` blocks — they're plannable, reviewable, and version-controlled.

```hcl
# BAD: imperative CLI import
# terraform import aws_s3_bucket.legacy my-existing-bucket
# Not in code, not reviewable, easy to forget

# GOOD: declarative import block (Terraform 1.5+)
import {
  to = aws_s3_bucket.legacy
  id = "my-existing-bucket"
}

resource "aws_s3_bucket" "legacy" {
  bucket = "my-existing-bucket"
  # Fill in config to match actual state, or use:
  # terraform plan -generate-config-out=generated.tf
}

# After successful import and plan shows no changes,
# remove the import block — it's a one-time operation.
```

---

### 22. Outputs Without Descriptions

**Severity: LOW**

**Description:** Module outputs with no descriptions, unclear names, or missing entirely. Consumers of the module have to read the source to understand what's available.

**Why it happens:** Outputs feel like boilerplate. "I know what `vpc_id` means."

**The fix:** Every output gets a description. Group logically. Include what consumers need.

```hcl
# BAD
output "id" {
  value = aws_vpc.main.id
}

output "subs" {
  value = aws_subnet.private[*].id
}

# GOOD
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs, one per availability zone"
  value       = [for s in aws_subnet.private : s.id]
}

output "private_subnet_cidrs" {
  description = "Map of AZ name to private subnet CIDR block"
  value       = { for s in aws_subnet.private : s.availability_zone => s.cidr_block }
}

output "database_endpoint" {
  description = "RDS cluster endpoint for application connection strings"
  value       = aws_rds_cluster.main.endpoint
  sensitive   = true
}
```

---

## Common Pitfalls

### 1. Provider Version Drift

**What happens:** Provider versions aren't pinned. A `terraform init` on a different machine pulls a newer provider version that changes behavior, renames arguments, or introduces bugs. Your plan shows unexpected changes or fails entirely.

**How to detect:**
- `terraform plan` shows changes you didn't make
- Different results on different machines or in CI
- Lock file keeps changing unexpectedly

**How to fix:**

```hcl
terraform {
  required_version = ">= 1.5, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"  # allows 5.40.x through 5.99.x
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
  }
}

# Pin strategy:
# ~> 5.40    — recommended: allows patch updates, blocks breaking minor versions
# >= 5.40, < 6.0 — same effect, more explicit
# = 5.40.0  — exact pin: maximum reproducibility, manual upgrade burden
# >= 5.0    — dangerous: allows any minor/major within constraint
```

---

### 2. State Conflicts — Concurrent Applies

**What happens:** Two engineers (or two CI pipelines) run `terraform apply` at the same time. Without locking, both read the same state, make changes, and one overwrites the other. Resources get orphaned or duplicated.

**How to detect:**
- State file has unexpected content after apply
- Resources exist in cloud but not in state (or vice versa)
- Error: "Error acquiring the state lock"

**How to fix:**

```hcl
# S3 backend with DynamoDB locking — the standard
terraform {
  backend "s3" {
    bucket         = "myorg-terraform-state"
    key            = "project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"  # THIS IS THE CRITICAL LINE
    encrypt        = true
  }
}

# If someone's lock is stuck (they closed their laptop mid-apply):
# terraform force-unlock LOCK_ID
# ^^^ Use with extreme caution — verify no apply is actually running first
```

---

### 3. Dependency Ordering — Implicit vs. Explicit

**What happens:** Resources deploy in the wrong order because Terraform doesn't detect the dependency. A security group rule references a group that hasn't been created yet. An IAM policy hasn't propagated before the Lambda function tries to use it.

**How to detect:**
- Intermittent apply failures that succeed on retry
- "ResourceNotFoundException" or "AccessDenied" during apply
- Works when applied twice but not once

**How to fix:**

```hcl
# Terraform automatically detects dependencies from resource references.
# IMPLICIT dependency — Terraform knows to create the role first:
resource "aws_iam_role" "lambda" {
  name = "my-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_lambda_function" "main" {
  role = aws_iam_role.lambda.arn  # implicit dependency via reference
}

# EXPLICIT dependency — when there's no direct reference but order matters:
resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.logging.arn
}

resource "aws_lambda_function" "main" {
  role = aws_iam_role.lambda.arn

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logging,
    # Without this, the Lambda might deploy before the logging policy
    # is attached, causing CloudWatch permission errors at runtime.
  ]
}

# RULE: Use depends_on sparingly. If you need it often, your module
# structure probably needs rethinking. Prefer implicit dependencies
# through resource references whenever possible.
```

---

### 4. Destroy Ordering

**What happens:** Terraform destroys resources in the wrong order — tries to delete a VPC before its subnets, or a security group while instances still reference it. Apply fails partway through, leaving a mess.

**How to detect:**
- `terraform destroy` fails with "DependencyViolation" errors
- Partial destroys leave orphaned resources
- Manual cleanup required after failed destroy

**How to fix:**

```hcl
# Terraform usually handles destroy ordering (reverse of create).
# Problems arise when:
# 1. Dependencies aren't expressed in code
# 2. Cloud APIs have additional constraints
# 3. Resources were imported without full dependency graph

# Fix: explicit depends_on for destroy ordering
resource "aws_security_group" "web" {
  vpc_id = aws_vpc.main.id
  # Terraform knows to destroy this before the VPC
}

# Fix: create_before_destroy for resources that can't be deleted while in use
resource "aws_security_group" "web" {
  name_prefix = "web-"
  vpc_id      = aws_vpc.main.id

  lifecycle {
    create_before_destroy = true
  }
}

# Fix: timeouts for resources that take time to fully release
resource "aws_db_instance" "main" {
  # ...
  timeouts {
    delete = "60m"
  }
}
```

---

### 5. Timeouts

**What happens:** Resources like RDS instances, EKS clusters, CloudFront distributions, and NAT Gateways take 15-45 minutes to create, modify, or destroy. Terraform's default timeouts may be too short, causing apply to fail even though the operation would eventually succeed.

**How to detect:**
- "Error waiting for X to become available: timeout while waiting for state"
- Operations that succeed when retried manually
- CI/CD pipelines timing out

**How to fix:**

```hcl
resource "aws_rds_cluster" "main" {
  cluster_identifier = "production"
  engine             = "aurora-postgresql"

  timeouts {
    create = "60m"
    update = "90m"
    delete = "60m"
  }
}

resource "aws_eks_cluster" "main" {
  name = "production"

  timeouts {
    create = "45m"
    update = "60m"
    delete = "30m"
  }
}

# Common timeout-heavy resources:
# RDS instances/clusters:  create 30-60m, modify 60-90m
# EKS clusters:            create 20-45m, delete 15-30m
# CloudFront distributions: create 15-30m, update 15-30m
# NAT Gateways:            create 10m, delete 15m
# ElastiCache clusters:    create 20-40m
# Redshift clusters:       create 30-60m
```

---

### 6. Eventually Consistent APIs

**What happens:** Cloud APIs return success but the resource isn't actually ready. The next Terraform resource that depends on it fails because the API hasn't propagated yet. AWS IAM is the worst offender — policy attachments can take up to 30 seconds to propagate globally.

**How to detect:**
- Intermittent "AccessDenied" or "ResourceNotFoundException" errors
- Works on retry, fails on first apply
- More common in new accounts or regions

**How to fix:**

```hcl
# Unfortunately, there's no clean solution. Options:

# 1. Add a time_sleep (hacky but effective for IAM)
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

resource "time_sleep" "wait_for_iam" {
  depends_on      = [aws_iam_role_policy_attachment.this]
  create_duration = "15s"
}

resource "aws_lambda_function" "main" {
  depends_on = [time_sleep.wait_for_iam]
  role       = aws_iam_role.lambda.arn
  # ...
}

# 2. Use -parallelism=1 for initial applies (slow but safe)
# terraform apply -parallelism=1

# 3. Just retry — sometimes it's the pragmatic answer
# terraform apply  # failed? wait 30s, try again

# Known offenders:
# AWS IAM:          policies, roles, instance profiles (up to 30s)
# AWS Route53:      DNS propagation (up to 60s)
# AWS CloudFront:   distribution deployment (up to 15min)
# GCP IAM:          policy bindings (up to 60s)
# Azure AD:         service principals, role assignments (up to 5min)
```

---

### 7. Plan != Apply

**What happens:** The plan shows clean changes, but apply fails. Causes: rate limits hit during apply, concurrent changes by another user or system, provider bugs, or API-side validations that only trigger on write.

**How to detect:**
- Plan succeeds, apply fails with API errors
- Plan shows 0 changes, apply modifies resources (state drift)
- Different plan output on consecutive runs

**How to fix:**

```bash
# 1. Always use saved plan files
terraform plan -out=tfplan
terraform apply tfplan
# This ensures what was reviewed is what gets applied

# 2. Detect drift before planning
terraform plan -refresh-only
# Shows what changed outside Terraform without modifying anything

# 3. Use -refresh=true (default) but be aware of rate limits
# For large configs, refresh can hit API rate limits
terraform plan -parallelism=5  # reduce concurrent API calls

# 4. Investigate plan/apply mismatches
# Enable provider logging to see raw API calls:
TF_LOG=DEBUG terraform apply tfplan 2>debug.log
```

---

### 8. Data Source Timing

**What happens:** Data sources are evaluated at plan time. If the data source depends on a resource being created in the same apply, it reads stale or nonexistent data. Terraform may error or return wrong values.

**How to detect:**
- "Error: your query returned no results" for resources being created in the same run
- Data source returns stale values (previous deployment's state)
- Circular dependency errors involving data sources

**How to fix:**

```hcl
# BAD: data source reads something created in the same apply
resource "aws_iam_role" "new_role" {
  name = "my-new-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_role" "lookup" {
  name = "my-new-role"  # doesn't exist at plan time!
}

# GOOD: reference the resource directly instead of using a data source
resource "aws_iam_role" "new_role" {
  name = "my-new-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_lambda_function" "main" {
  role = aws_iam_role.new_role.arn  # direct reference, not data source
}

# RULE: Use data sources for resources managed OUTSIDE your module.
# Use direct references for resources managed INSIDE your module.

# If you must use a data source for something in the same apply,
# add an explicit depends_on (but prefer direct references):
data "aws_iam_role" "lookup" {
  name       = "my-new-role"
  depends_on = [aws_iam_role.new_role]
}
```

---

### 9. Module Source Caching

**What happens:** You update a module in a git repository or registry, but `terraform plan` still uses the old version. Terraform caches module sources in `.terraform/modules/` and doesn't automatically fetch updates.

**How to detect:**
- Module changes aren't reflected in plan
- Different behavior on fresh clone vs. existing checkout
- "But I updated the module!" debugging sessions

**How to fix:**

```bash
# Force re-download of all modules
terraform init -upgrade

# For git-sourced modules, ALWAYS pin to a ref
# BAD: unpinned — caches once, never updates
module "vpc" {
  source = "git::https://github.com/myorg/terraform-modules.git//vpc"
}

# GOOD: pinned to tag — explicit upgrade path
module "vpc" {
  source = "git::https://github.com/myorg/terraform-modules.git//vpc?ref=v2.3.1"
}

# GOOD: registry module with version constraint
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5"
}

# When upgrading:
# 1. Update the version/ref in code
# 2. Run terraform init -upgrade
# 3. Run terraform plan to see impact
# 4. Commit updated .terraform.lock.hcl
```

---

### 10. Terraform Cloud / Enterprise Networking

**What happens:** Terraform Cloud runners can't reach private infrastructure — private registries, internal APIs, databases behind VPNs. Plans fail with connection timeouts.

**How to detect:**
- "connection timed out" errors in TFC runs
- Plans succeed locally but fail in TFC
- Can't pull modules from private registries

**How to fix:**

```
# Options (in order of preference):

# 1. Terraform Cloud Agents (self-hosted runners)
#    - Run inside your VPC/network
#    - Connect outbound to TFC, no inbound ports needed
#    - Best for accessing private infra

# 2. VPC Peering / PrivateLink to TFC
#    - Direct network path from TFC to your infra
#    - Requires Terraform Enterprise (self-hosted)

# 3. IP Allowlisting
#    - TFC publishes runner IP ranges
#    - Allowlist in security groups / firewalls
#    - Fragile: IPs can change

# 4. Redesign to avoid private access at plan time
#    - Use SSM Parameter Store / Secrets Manager data sources
#      instead of direct DB connections
#    - Pre-bake AMIs instead of looking them up

# Agent pool configuration (terraform block):
terraform {
  cloud {
    organization = "myorg"
    workspaces {
      name = "production"
    }
    # Runs execute on self-hosted agents inside your VPC
  }
}
```

---

### 11. Forgetting About State File Size

**What happens:** State files grow to tens of megabytes. Every plan/apply downloads and parses the entire state. Operations slow to a crawl. S3 API calls start timing out.

**How to detect:**
- `terraform plan` takes minutes before showing anything
- State file exceeds 10MB
- "Error refreshing state" timeouts

**How to fix:**

```bash
# Check state size
terraform state list | wc -l
# If > 200 resources, consider splitting

ls -lh terraform.tfstate
# If > 5MB, definitely split

# Split strategies:
# 1. Extract stable infrastructure into its own state
# 2. Move frequently-changing resources to a separate state
# 3. Use moved blocks to relocate resources cleanly

# Remove resources from state that shouldn't be managed:
# terraform state rm 'aws_instance.temp'  # last resort — prefer import blocks
```

---

## Debugging Techniques

### 1. TF_LOG — Terraform Logging

Terraform supports granular log levels, separable by core engine and provider.

```bash
# Log levels: TRACE, DEBUG, INFO, WARN, ERROR
# TRACE = maximum verbosity (raw HTTP requests/responses)
# DEBUG = internal logic and decision flow
# INFO  = major operations
# WARN  = non-fatal issues
# ERROR = failures only

# Set overall log level
export TF_LOG=DEBUG
terraform plan

# Separate core and provider logs (Terraform 0.15+)
export TF_LOG_CORE=WARN          # quiet core engine
export TF_LOG_PROVIDER=DEBUG     # verbose provider operations

# Write logs to file instead of stderr
export TF_LOG=TRACE
export TF_LOG_PATH="./terraform-debug.log"
terraform apply

# Clean up after debugging
unset TF_LOG TF_LOG_CORE TF_LOG_PROVIDER TF_LOG_PATH
```

---

### 2. `terraform console` — Interactive REPL

Test expressions, inspect state, and debug interpolations without running a plan.

```bash
# Launch console (loads current state and config)
terraform console

# Test expressions
> length(var.subnet_cidrs)
3

> cidrsubnet("10.0.0.0/16", 8, 1)
"10.0.1.0/24"

> { for az, subnet in aws_subnet.private : az => subnet.cidr_block }
{
  "us-east-1a" = "10.0.1.0/24"
  "us-east-1b" = "10.0.2.0/24"
}

> can(regex("^t[23]\\.", "t3.medium"))
true

> try(local.optional_config.nested.value, "default")
"default"

# Pipe expressions for scripting
echo 'aws_vpc.main.id' | terraform console
# "vpc-0abc123def456"
```

---

### 3. State Inspection

```bash
# List all resources in state
terraform state list

# Filter by type
terraform state list | grep aws_iam_role

# Show detailed state for a resource
terraform state show 'aws_instance.web'
terraform state show 'module.vpc.aws_subnet.private["us-east-1a"]'

# Show entire state as JSON (pipe to jq for queries)
terraform show -json | jq '.values.root_module.resources[] | select(.type == "aws_instance")'

# Show planned changes as JSON
terraform show -json tfplan | jq '.resource_changes[] | select(.change.actions | index("delete"))'
```

---

### 4. Dependency Graph

```bash
# Generate DOT format dependency graph
terraform graph > graph.dot

# Filter to specific resource types
terraform graph -type=plan > plan-graph.dot

# Visualize (requires graphviz)
terraform graph | dot -Tpng > graph.png

# For large graphs, filter with grep before rendering:
terraform graph | grep -E '(aws_instance|aws_security_group|->)' | dot -Tpng > filtered.png
```

---

### 5. Refresh-Only Mode

```bash
# Detect drift without modifying anything (Terraform 1.1+)
terraform plan -refresh-only
# Shows what changed outside Terraform

# Apply only the state refresh (update state to match reality)
terraform apply -refresh-only

# The old way (DEPRECATED — do not use)
# terraform refresh   # modifies state as side effect, no plan review
```

---

### 6. Crash Logs

When Terraform crashes (panics), it writes a `crash.log` in the working directory.

```bash
# Check for crash logs
ls -la crash.log

# The crash log contains:
# - Terraform version
# - Go runtime info
# - Stack trace
# - Provider versions

# What to do:
# 1. Check if the crash is a known issue on GitHub
# 2. Try upgrading Terraform and/or the provider
# 3. File a bug report with the crash log (redact sensitive info first)
# 4. As a workaround, try -parallelism=1 or target specific resources:
terraform apply -target=aws_instance.web -parallelism=1
```

---

### 7. Provider-Specific Debugging

```bash
# AWS Provider — detailed API logging
export AWS_DEBUG=true                           # SDK-level debug
export TF_LOG_PROVIDER=DEBUG                    # Terraform provider debug

# Google Cloud Provider
export GOOGLE_LOG_HTTP=true                     # Log all HTTP requests
export TF_LOG_PROVIDER=DEBUG

# Azure Provider
export ARM_LOG_LEVEL=DEBUG                      # ARM client logging
export TF_LOG_PROVIDER=DEBUG

# Kubernetes Provider
export KUBE_LOG_LEVEL=5                         # kubectl verbosity (0-10)
export TF_LOG_PROVIDER=TRACE

# All providers — see raw HTTP requests/responses
export TF_LOG_PROVIDER=TRACE
# WARNING: TRACE level logs may contain secrets in API responses
# Never commit trace logs to version control
```

---

## Quick Reference Decision Table

| Situation | Do This |
|-----------|---------|
| Creating 3+ related resources with a shared interface | Write a module |
| Creating 1-2 resources | Inline in root module, do not wrap in a module |
| Referencing a resource managed in another state | Use `terraform_remote_state` data source or SSM parameters |
| Referencing a resource managed in the same state | Direct resource reference (never a data source) |
| Need to conditionally create a resource | `count = var.enabled ? 1 : 0` |
| Need to create multiple instances of a resource | `for_each` with a map (never `count` with a list) |
| Renaming or moving a resource | `moved` block (never `terraform state mv` for planned changes) |
| Importing an existing resource | `import` block with `-generate-config-out` (Terraform 1.5+) |
| Storing secrets | Secrets manager data source + `sensitive = true`; ephemeral resources if on 1.10+ |
| CI/CD pipeline for Terraform | Separate plan and apply stages; require approval for production |
| Plan takes > 60 seconds | Split the root module by lifecycle or blast radius |
| State file > 5MB | Split state; you have too many resources in one root module |
| Need to run a script after resource creation | `terraform_data` with provisioner (not `null_resource`) |
| Two security groups need to reference each other | Standalone `aws_security_group_rule` resources (not inline rules) |
| Provider version upgrade | Pin with `~>`, run `terraform init -upgrade`, review plan carefully |
| Debugging a failed apply | `TF_LOG_PROVIDER=DEBUG`, check state with `terraform state show` |
| Suspect drift from manual changes | `terraform plan -refresh-only` |
| Need cross-platform provider hashes | `terraform providers lock -platform=linux_amd64 -platform=darwin_arm64` |
| Complex conditional logic in HCL | Replace nested ternaries with map lookups |
| Starting a brand new Terraform project | Remote backend with locking, provider version pins, and `.terraform.lock.hcl` committed — before writing a single resource |
