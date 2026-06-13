# Cookbook: Multi-Environment Patterns

Practical HCL recipes and structural patterns for managing dev/staging/prod environments, account vending, spot/preemptible compute, and cleanup automation.

---

## 1. Directory-Based Environments

Each environment gets its own directory with independent state. Shared modules define the infrastructure; environment directories provide the configuration. This is the recommended approach for most teams.

### Structure

```
infrastructure/
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── data/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   ├── dev/
│   │   ├── networking/
│   │   │   ├── main.tf          # module "networking" { source = "../../../modules/networking" }
│   │   │   ├── terraform.tfvars
│   │   │   └── backend.tf       # Independent state per layer
│   │   ├── compute/
│   │   │   ├── main.tf
│   │   │   ├── terraform.tfvars
│   │   │   └── backend.tf
│   │   └── data/
│   │       ├── main.tf
│   │       ├── terraform.tfvars
│   │       └── backend.tf
│   ├── staging/
│   │   ├── networking/
│   │   ├── compute/
│   │   └── data/
│   └── prod/
│       ├── networking/
│       ├── compute/
│       └── data/
└── global/                       # Cross-environment resources (IAM, DNS zones)
    ├── main.tf
    └── backend.tf
```

### Environment Root (e.g., environments/dev/networking/main.tf)

```hcl
terraform {
  required_version = ">= 1.9"

  backend "s3" {
    bucket         = "myorg-terraform-state"
    key            = "dev/networking/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

module "networking" {
  source = "../../../modules/networking"

  environment = "dev"
  region      = "us-east-1"
  vpc_cidr    = "10.10.0.0/16"

  # Dev: single NAT gateway to save cost
  single_nat_gateway = true

  # Dev: no VPC endpoints
  enable_vpc_endpoints = false
}

# Cross-layer data: read networking outputs from state
# Used by compute/ and data/ layers
output "vpc_id" {
  value = module.networking.vpc_id
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}
```

### Cross-Layer State References (e.g., environments/dev/compute/main.tf)

```hcl
# Read networking outputs from its state file
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "myorg-terraform-state"
    key    = "${var.environment}/networking/terraform.tfstate"
    region = "us-east-1"
  }
}

module "compute" {
  source = "../../../modules/compute"

  environment        = "dev"
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids

  # Dev: smaller instances, fewer nodes
  instance_type    = "t3.medium"
  min_nodes        = 1
  max_nodes        = 3
  desired_nodes    = 1
  use_spot         = true
}
```

### Environment tfvars (e.g., environments/prod/networking/terraform.tfvars)

```hcl
# Production overrides
environment          = "prod"
vpc_cidr             = "10.30.0.0/16"
single_nat_gateway   = false          # HA: one per AZ
enable_vpc_endpoints = true           # Cost savings at scale
```

### Pros and Cons

| Pros | Cons |
|:-----|:-----|
| Blast radius limited to one env + one layer | More directories to maintain |
| Independent state = independent apply/destroy | Duplicated backend config |
| Easy to reason about what's deployed where | Cross-layer data requires remote state |
| No conditional logic based on workspace | Module version drift between envs |
| Can promote changes env-by-env | More CI/CD pipeline config |

---

## 2. Workspace-Based Environments

Same code, different state files selected via `terraform workspace`. Appropriate for simple, ephemeral, or identical environments.

```hcl
# --- main.tf ---

terraform {
  required_version = ">= 1.9"

  backend "s3" {
    bucket         = "myorg-terraform-state"
    key            = "app/terraform.tfstate"       # Workspace name auto-prefixed
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"

    workspace_key_prefix = "workspaces"
    # State path: workspaces/<workspace>/app/terraform.tfstate
  }
}

locals {
  environment = terraform.workspace

  config = {
    dev = {
      instance_type      = "t3.medium"
      min_nodes          = 1
      max_nodes          = 3
      single_nat_gateway = true
      deletion_protection = false
      vpc_cidr           = "10.10.0.0/16"
    }
    staging = {
      instance_type      = "t3.large"
      min_nodes          = 2
      max_nodes          = 5
      single_nat_gateway = true
      deletion_protection = true
      vpc_cidr           = "10.20.0.0/16"
    }
    prod = {
      instance_type      = "m6i.xlarge"
      min_nodes          = 3
      max_nodes          = 20
      single_nat_gateway = false
      deletion_protection = true
      vpc_cidr           = "10.30.0.0/16"
    }
  }

  env = local.config[local.environment]
}

module "networking" {
  source = "./modules/networking"

  environment        = local.environment
  vpc_cidr           = local.env.vpc_cidr
  single_nat_gateway = local.env.single_nat_gateway
}

module "compute" {
  source = "./modules/compute"

  environment   = local.environment
  vpc_id        = module.networking.vpc_id
  subnet_ids    = module.networking.private_subnet_ids
  instance_type = local.env.instance_type
  min_nodes     = local.env.min_nodes
  max_nodes     = local.env.max_nodes
}
```

### Usage

```bash
# Create and switch workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Deploy to dev
terraform workspace select dev
terraform plan
terraform apply

# Deploy to prod
terraform workspace select prod
terraform plan
terraform apply

# List workspaces
terraform workspace list

# Ephemeral preview environment
terraform workspace new preview-pr-123
terraform apply
# ... test ...
terraform destroy
terraform workspace select dev
terraform workspace delete preview-pr-123
```

### When Workspaces Are Appropriate

| Good Fit | Bad Fit |
|:---------|:--------|
| Ephemeral preview/PR environments | Environments with very different architectures |
| Simple infrastructure (few resources) | Environments requiring different providers/regions |
| All environments truly identical | Teams that need independent apply permissions |
| Single-person/small team | Large teams with separate env ownership |

### Risks

- `terraform destroy` in the wrong workspace is catastrophic. No directory-level guardrail.
- Conditional logic (`terraform.workspace == "prod"`) creates hidden complexity.
- All environments share the same code version — cannot promote gradually.
- RBAC is harder (same state backend, different workspace names).

---

## 3. Terragrunt

DRY configuration management that eliminates duplication across environments. Becomes worthwhile at 3+ environments.

### Structure

```
infrastructure/
├── modules/                           # Same Terraform modules
│   ├── networking/
│   ├── compute/
│   └── data/
├── terragrunt.hcl                     # Root config (backend, providers)
├── _envcommon/                        # Shared per-component config
│   ├── networking.hcl
│   ├── compute.hcl
│   └── data.hcl
└── environments/
    ├── dev/
    │   ├── env.hcl                    # environment = "dev", account_id = "111..."
    │   ├── networking/
    │   │   └── terragrunt.hcl         # include + env-specific overrides
    │   ├── compute/
    │   │   └── terragrunt.hcl
    │   └── data/
    │       └── terragrunt.hcl
    ├── staging/
    │   ├── env.hcl
    │   ├── networking/
    │   ├── compute/
    │   └── data/
    └── prod/
        ├── env.hcl
        ├── networking/
        ├── compute/
        └── data/
```

### Root terragrunt.hcl

```hcl
# infrastructure/terragrunt.hcl

# Auto-generate backend config for every module
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "myorg-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

# Auto-generate provider config
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}
EOF
}
```

### Environment Config (environments/dev/env.hcl)

```hcl
locals {
  environment = "dev"
  account_id  = "111111111111"
  region      = "us-east-1"
}
```

### Common Component Config (_envcommon/networking.hcl)

```hcl
terraform {
  source = "${get_repo_root()}/modules/networking"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  environment = local.env_vars.locals.environment
}

inputs = {
  environment = local.environment
  region      = local.env_vars.locals.region
}
```

### Environment-Specific Overrides (environments/dev/networking/terragrunt.hcl)

```hcl
include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/networking.hcl"
  merge_strategy = "deep"
}

# Dev-specific overrides
inputs = {
  vpc_cidr           = "10.10.0.0/16"
  single_nat_gateway = true
  enable_vpc_endpoints = false
}
```

### Dependencies Between Components

```hcl
# environments/dev/compute/terragrunt.hcl

include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/compute.hcl"
  merge_strategy = "deep"
}

# Declare dependency on networking
dependency "networking" {
  config_path = "../networking"

  # Mock outputs for plan when networking hasn't been applied yet
  mock_outputs = {
    vpc_id             = "vpc-mock"
    private_subnet_ids = ["subnet-mock-1", "subnet-mock-2"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  vpc_id             = dependency.networking.outputs.vpc_id
  private_subnet_ids = dependency.networking.outputs.private_subnet_ids
  instance_type      = "t3.medium"
}
```

### Terragrunt Commands

```bash
# Apply a single component
cd environments/dev/networking
terragrunt apply

# Apply all components in an environment (respects dependencies)
cd environments/dev
terragrunt run-all apply

# Plan all (parallel where possible)
cd environments/dev
terragrunt run-all plan

# Apply across ALL environments
cd environments
terragrunt run-all apply

# Destroy in reverse dependency order
cd environments/dev
terragrunt run-all destroy
```

### Terragrunt 1.0 Stacks

Terragrunt 1.0 introduces the `stack` block for explicit multi-unit orchestration:

```hcl
# stacks/dev.hcl
stack {
  units = [
    {
      source = "../environments/dev/networking"
    },
    {
      source = "../environments/dev/compute"
      depends_on = ["../environments/dev/networking"]
    },
    {
      source = "../environments/dev/data"
      depends_on = ["../environments/dev/networking"]
    },
  ]
}
```

### Break-Even Analysis

| Environments | Without Terragrunt | With Terragrunt | Verdict |
|:-------------|:-------------------|:----------------|:--------|
| 1 | Simple | Overhead, not worth it | Skip |
| 2 | Manageable duplication | Slight benefit | Optional |
| 3+ | Painful duplication | Clear DRY wins | Use it |
| 5+ | Unsustainable | Essential | Required |

---

## 4. Account/Project Vending

Automated creation of cloud accounts or projects with baseline security, networking, and IAM.

### AWS: Control Tower Account Factory for Terraform (AFT)

```hcl
# --- AFT Account Request ---
# This goes in your AFT account-requests repo

module "account_request" {
  source = "github.com/aws-ia/terraform-aws-control_tower_account_factory//modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail              = "aws+${var.account_name}@example.com"
    AccountName               = var.account_name
    ManagedOrganizationalUnit = var.ou_name
    SSOUserEmail              = "admin@example.com"
    SSOUserFirstName          = "Admin"
    SSOUserLastName           = "User"
  }

  account_tags = {
    Environment = var.environment
    CostCenter  = var.cost_center
    Team        = var.team
  }

  # Customizations applied after account creation
  account_customizations_name = var.environment   # Maps to customizations repo folder

  change_management_parameters = {
    change_requested_by = "terraform"
    change_reason       = "New ${var.environment} account for ${var.team}"
  }
}
```

### GCP: Project Factory

```hcl
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 15.0"

  name                    = "${var.team}-${var.environment}"
  org_id                  = var.org_id
  billing_account         = var.billing_account_id
  folder_id               = var.folder_id
  random_project_id       = true
  default_service_account = "disable"

  # APIs to enable
  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]

  # Shared VPC attachment
  shared_vpc         = var.host_project_id
  shared_vpc_subnets = var.shared_subnets

  # Labels
  labels = {
    environment = var.environment
    team        = var.team
    managed_by  = "terraform"
  }

  # Budget alert
  budget_amount                  = var.monthly_budget
  budget_alert_spent_percents    = [0.5, 0.75, 0.9, 1.0]
  budget_alert_pubsub_topic      = var.budget_alert_topic
}

# --- Baseline IAM ---

resource "google_project_iam_member" "team_editors" {
  for_each = toset(var.team_members)

  project = module.project.project_id
  role    = "roles/editor"
  member  = "user:${each.value}"
}

# --- Default VPC Firewall Rules ---

resource "google_compute_firewall" "deny_all_ingress" {
  project  = module.project.project_id
  name     = "deny-all-ingress"
  network  = "default"
  priority = 65534

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}
```

---

## 5. Spot/Preemptible Patterns

Mixed instance policies for cost savings with reliability. Key principle: diversify across 4-6+ instance types to reduce interruption risk.

### AWS: Mixed Instances Policy

```hcl
# For use with EKS managed node groups or ASGs

resource "aws_autoscaling_group" "mixed" {
  name                = "${var.environment}-mixed-asg"
  vpc_zone_identifier = var.private_subnet_ids
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_size

  mixed_instances_policy {
    instances_distribution {
      # Baseline on-demand (for stability)
      on_demand_base_capacity                  = var.on_demand_base     # e.g., 2
      on_demand_percentage_above_base_capacity = var.on_demand_percent  # e.g., 25
      spot_allocation_strategy                 = "price-capacity-optimized"
      spot_max_price                           = ""   # Empty = up to on-demand price
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.node.id
        version            = "$Latest"
      }

      # 6+ instance types for spot diversity
      # Same family different sizes, or different families same size
      override {
        instance_type     = "m6i.xlarge"
        weighted_capacity = "4"
      }
      override {
        instance_type     = "m5.xlarge"
        weighted_capacity = "4"
      }
      override {
        instance_type     = "m5a.xlarge"
        weighted_capacity = "4"
      }
      override {
        instance_type     = "m6a.xlarge"
        weighted_capacity = "4"
      }
      override {
        instance_type     = "m5n.xlarge"
        weighted_capacity = "4"
      }
      override {
        instance_type     = "r6i.large"
        weighted_capacity = "2"   # Different size, weight accordingly
      }
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-mixed-node"
    propagate_at_launch = true
  }
}
```

### GCP: Preemptible/Spot VMs in Managed Instance Group

```hcl
resource "google_compute_instance_template" "spot" {
  name_prefix  = "${var.environment}-spot-"
  machine_type = "e2-standard-4"
  region       = var.region

  scheduling {
    preemptible                 = false
    provisioning_model          = "SPOT"
    automatic_restart           = false
    instance_termination_action = "STOP"
  }

  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
    disk_size_gb = 50
  }

  network_interface {
    subnetwork = var.subnetwork
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "spot" {
  name               = "${var.environment}-spot-mig"
  region             = var.region
  base_instance_name = "${var.environment}-spot"

  version {
    instance_template = google_compute_instance_template.spot.id
  }

  target_size = var.desired_size

  auto_healing_policies {
    health_check      = google_compute_health_check.default.id
    initial_delay_sec = 300
  }
}
```

### Spot Instance Selection Tips

1. **Diversify across 4-6+ instance types** — reduces simultaneous interruption risk
2. **Mix instance families** — m5, m5a, m6i, m6a use different hardware pools
3. **Use `price-capacity-optimized`** — AWS selects the pool with most capacity and lowest price
4. **Keep an on-demand baseline** — 2+ instances to handle spot interruptions gracefully
5. **Use weighted capacity** — allows mixing different instance sizes in the same ASG
6. **Set `spot_max_price` to empty** — caps at on-demand price, avoids surprise bills

---

## 6. Cleanup Automation

Prevent dev/staging environments from accumulating cost by automating teardown.

### HCP Terraform (Terraform Cloud) Auto-Destroy

```hcl
# In your workspace configuration or via API

resource "tfe_workspace" "ephemeral" {
  name         = "preview-pr-${var.pr_number}"
  organization = var.tfe_org
  project_id   = var.tfe_project_id

  auto_apply            = true
  working_directory     = "environments/preview"
  terraform_version     = "~> 1.9"

  # Auto-destroy after inactivity
  auto_destroy_at               = timeadd(timestamp(), "72h")   # 3 days from now
  auto_destroy_activity_duration = "24h"                         # Reset timer on activity
}
```

### GitHub Actions: Scheduled Destroy

```yaml
# .github/workflows/cleanup-dev.yaml
name: Cleanup Dev Environment

on:
  schedule:
    - cron: '0 2 * * 6'   # Every Saturday at 2 AM

  workflow_dispatch:       # Manual trigger

jobs:
  cleanup:
    runs-on: ubuntu-latest
    environment: dev-cleanup   # Requires approval in GitHub

    steps:
      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3

      - name: Terraform Destroy Non-Essential
        working-directory: environments/dev/compute
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          terraform init
          terraform destroy -auto-approve \
            -target=module.compute.aws_autoscaling_group.workloads

      - name: Scale Down EKS
        run: |
          aws eks update-nodegroup-config \
            --cluster-name dev-cluster \
            --nodegroup-name workloads \
            --scaling-config minSize=0,maxSize=0,desiredSize=0
```

### env0 Scheduling

```hcl
# env0 environment configuration (via env0 Terraform provider)

resource "env0_environment" "preview" {
  name               = "preview-${var.feature_name}"
  project_id         = var.env0_project_id
  template_id        = var.env0_template_id
  approve_plan_automatically = true

  # TTL: auto-destroy after 48 hours
  ttl {
    type  = "HOURS"
    value = 48
  }

  # Cron-based schedule: destroy Friday night, recreate Monday morning
  # (configured via env0 UI or API)
}
```

### Tagging-Based Cleanup Script

```hcl
# Tag all dev resources with an expiry date

locals {
  expiry_tags = var.environment == "prod" ? {} : {
    AutoExpire = formatdate("YYYY-MM-DD", timeadd(timestamp(), "${var.ttl_hours}h"))
    Environment = var.environment
  }
}

# Then use a Lambda/Cloud Function to scan for expired tags:
# 1. List all resources with AutoExpire tag
# 2. Compare tag value to current date
# 3. Terminate expired resources
# 4. Send Slack notification
```

### Cleanup Decision Matrix

| Environment | Strategy | Frequency | What Survives |
|:------------|:---------|:----------|:-------------|
| PR preview | Auto-destroy on PR close | Per PR | Nothing |
| Dev | Weekend shutdown + weekday recreate | Weekly | State files, DNS |
| Staging | Scale to zero off-hours | Daily | Everything (just scaled down) |
| Load test | TTL-based auto-destroy | Per test | Test results only |
| Prod | Never auto-destroy | -- | Everything |

**Critical rule:** Never auto-destroy anything with `prevent_destroy` in its lifecycle block. The cleanup automation should skip those resources and alert instead.
