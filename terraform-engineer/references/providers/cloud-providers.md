# Cloud Provider Patterns

Production patterns for the three major cloud providers. Each section covers provider configuration, critical gotchas, and the resources you will use most often.

---

## AWS (`hashicorp/aws`)

**Registry:** `hashicorp/aws` | **Current major:** v6.x | **Maintenance:** v5 receives security patches only

### Provider Configuration

```hcl
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = var.project_name
      CostCenter  = var.cost_center
    }
  }
}
```

`default_tags` eliminates tag repetition across every resource. Tags declared here propagate automatically; resource-level tags merge with (and override) defaults.

### Multi-Account with `assume_role`

```hcl
provider "aws" {
  alias  = "production"
  region = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::${var.production_account_id}:role/TerraformDeployRole"
    session_name = "terraform-${var.environment}"
    external_id  = var.external_id  # optional but recommended
  }

  default_tags {
    tags = {
      Environment = "production"
      ManagedBy   = "terraform"
    }
  }
}

# Use the aliased provider explicitly
resource "aws_s3_bucket" "logs" {
  provider = aws.production
  bucket   = "prod-application-logs"
}
```

Pattern: one AWS account per environment, a central "management" account runs Terraform and assumes roles into workload accounts.

### Most-Used Resources

| Resource | Purpose |
|----------|---------|
| `aws_vpc`, `aws_subnet`, `aws_route_table` | Networking foundation |
| `aws_eks_cluster`, `aws_eks_node_group` | Managed Kubernetes |
| `aws_db_instance`, `aws_rds_cluster` | Relational databases |
| `aws_lambda_function`, `aws_lambda_permission` | Serverless compute |
| `aws_iam_role`, `aws_iam_policy`, `aws_iam_role_policy_attachment` | Identity and access |
| `aws_s3_bucket`, `aws_s3_bucket_policy` | Object storage |
| `aws_security_group`, `aws_security_group_rule` | Network ACLs |
| `aws_cloudwatch_log_group`, `aws_cloudwatch_metric_alarm` | Observability |

### v6 Breaking Changes

- **AMI data sources require `owners`** -- queries without an owner filter no longer work. Always specify `owners = ["amazon"]` or your account ID.
- **OpsWorks resources removed** -- the service was deprecated by AWS.
- **Redshift defaults changed** -- encryption is now enabled by default, cluster type defaults differ.
- **S3 bucket ACLs** -- `acl` argument removed from `aws_s3_bucket`; use `aws_s3_bucket_acl` resource instead (this started in v4 but v6 fully enforces it).

### IAM Eventual Consistency

IAM changes propagate globally but not instantly. Resources that depend on a newly created role or policy may fail on first apply.

```hcl
resource "aws_iam_role" "lambda_exec" {
  name               = "lambda-exec-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Allow IAM to propagate before Lambda tries to assume the role
resource "time_sleep" "wait_for_iam" {
  depends_on      = [aws_iam_role_policy_attachment.lambda_basic]
  create_duration = "15s"
}

resource "aws_lambda_function" "api" {
  depends_on    = [time_sleep.wait_for_iam]
  function_name = "api-handler"
  role          = aws_iam_role.lambda_exec.arn
  # ...
}
```

### OIDC Federation for CI/CD

Eliminate long-lived AWS credentials in CI/CD pipelines.

```hcl
# GitHub Actions OIDC provider (create once per account)
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]
}

# Role that GitHub Actions can assume
resource "aws_iam_role" "github_deploy" {
  name = "github-actions-deploy"

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
          "token.actions.githubusercontent.com:sub" = "repo:my-org/my-repo:ref:refs/heads/main"
        }
      }
    }]
  })
}
```

### IRSA Pattern for EKS Workloads

IAM Roles for Service Accounts lets pods assume AWS roles without node-level credentials.

```hcl
# OIDC provider for the EKS cluster
data "aws_eks_cluster" "main" {
  name = var.cluster_name
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]
}

# IAM role scoped to a specific service account
resource "aws_iam_role" "app_role" {
  name = "eks-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
          "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

# Annotate the K8s service account
resource "kubernetes_service_account" "app" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.app_role.arn
    }
  }
}
```

---

## GCP (`hashicorp/google` + `hashicorp/google-beta`)

**Registry:** `hashicorp/google`, `hashicorp/google-beta` | New features land in `google-beta` first

### Provider Configuration

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}

# Beta provider for features not yet GA
provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Use beta when needed
resource "google_container_cluster" "primary" {
  provider = google-beta  # Autopilot features often require beta
  name     = "primary"
  location = var.region

  enable_autopilot = true

  release_channel {
    channel = "REGULAR"
  }
}
```

Always declare both providers. Resources default to `google`; add `provider = google-beta` on individual resources that need beta features.

### Project Factory

Google's opinionated module for creating projects with consistent configuration.

```hcl
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 17.0"

  name                 = "my-service-prod"
  org_id               = var.org_id
  billing_account      = var.billing_account
  folder_id            = var.folder_id
  default_service_account = "disable"

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "iam.googleapis.com",
  ]

  labels = {
    environment = "production"
    managed_by  = "terraform"
  }
}
```

### Workload Identity Federation for CI/CD

```hcl
resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_condition = "assertion.repository_owner == 'my-org'"
}

# Allow the pool to impersonate a service account
resource "google_service_account_iam_member" "github_impersonate" {
  service_account_id = google_service_account.deploy.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/my-org/my-repo"
}
```

### IAM: `_binding` vs `_member` -- Critical Distinction

This is the single most common source of IAM-related outages in GCP Terraform.

| Resource | Behavior | Risk |
|----------|----------|------|
| `google_project_iam_binding` | **Authoritative** for the role -- removes all other members | Will revoke access granted outside Terraform |
| `google_project_iam_member` | **Additive** -- adds one member to one role | Safe alongside console-managed IAM |
| `google_project_iam_policy` | **Fully authoritative** for the entire project | Will remove ALL IAM not in Terraform |

```hcl
# SAFE: additive, won't touch other bindings
resource "google_project_iam_member" "deployer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.deploy.email}"
}

# DANGEROUS: authoritative for this role -- removes all other members with this role
resource "google_project_iam_binding" "deployer" {
  project = var.project_id
  role    = "roles/container.developer"
  members = [
    "serviceAccount:${google_service_account.deploy.email}",
  ]
}
```

**Rule of thumb:** Use `_member` unless you have a deliberate reason to enforce authoritative control over a role.

### API Enablement and Dependency Ordering

APIs must be enabled before resources can be created. This creates implicit dependency chains.

```hcl
resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false  # Don't disable API on terraform destroy
}

resource "google_project_service" "container" {
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_container_cluster" "primary" {
  depends_on = [
    google_project_service.compute,
    google_project_service.container,
  ]
  # ...
}
```

Set `disable_on_destroy = false` to prevent cascading destruction of all resources using that API when the service resource is removed from state.

### Shared VPC Pattern

```hcl
# Host project owns the VPC
resource "google_compute_shared_vpc_host_project" "host" {
  project = var.host_project_id
}

# Service projects consume subnets from the host
resource "google_compute_shared_vpc_service_project" "service" {
  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = var.service_project_id
}

# Grant subnet access to service project's GKE service account
resource "google_compute_subnetwork_iam_member" "gke_subnet" {
  project    = var.host_project_id
  region     = var.region
  subnetwork = google_compute_subnetwork.gke.name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${var.service_project_number}@cloudservices.gserviceaccount.com"
}
```

### GKE: Autopilot vs Standard

| Feature | Autopilot | Standard |
|---------|-----------|----------|
| Node management | Fully managed | You manage node pools |
| Pricing | Per-pod resource requests | Per-node (VM pricing) |
| GPU/TPU | Supported (with limitations) | Full control |
| DaemonSets | Restricted | Full access |
| Best for | Most workloads | Custom kernel, DaemonSets, GPU-heavy |

Autopilot is the recommended default for new clusters. Use Standard only when you need DaemonSets, specific machine types, or GPU scheduling control.

---

## Azure (`hashicorp/azurerm`)

**Registry:** `hashicorp/azurerm` | **Current major:** v4.x

### Provider Configuration

```hcl
provider "azurerm" {
  subscription_id = var.subscription_id

  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown               = true
      skip_shutdown_and_force_delete  = false
    }
  }
}
```

The `features {}` block is **required** -- the provider will not initialize without it. Even an empty `features {}` is valid, but explicit configuration prevents surprises.

### v4 Breaking Changes from v3

- **Resource renames** -- many resources changed names for consistency (e.g., `azurerm_kubernetes_cluster` arguments restructured).
- **Removed deprecated attributes** -- arguments that had replacement alternatives in v3 are now gone.
- **Identity blocks restructured** -- `identity` blocks use a more consistent schema.
- **Default behavior changes** -- several resources changed defaults for security (encryption on by default, public access off by default).

Migration: Use `terraform state mv` for renamed resources. Run `terraform plan` after upgrading to identify all breaking changes before applying.

### AKS with Managed Identity and Workload Identity

```hcl
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.environment}"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "system"
    vm_size             = "Standard_D4s_v5"
    auto_scaling_enabled = true
    min_count           = 2
    max_count           = 5
    vnet_subnet_id      = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  network_profile {
    network_plugin = "azure"  # Azure CNI
    service_cidr   = "10.0.4.0/22"
    dns_service_ip = "10.0.4.10"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }
}

# Workload identity: federated credential for a K8s service account
resource "azurerm_user_assigned_identity" "app" {
  name                = "id-app-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_federated_identity_credential" "app" {
  name                = "fed-app"
  resource_group_name = azurerm_resource_group.main.name
  parent_id           = azurerm_user_assigned_identity.app.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.main.oidc_issuer_url
  subject             = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
}
```

### Azure CNI IP Planning

Azure CNI assigns real VNet IPs to pods. Each node reserves IPs equal to its max pod count.

```
Calculation:
  nodes * max_pods_per_node = pod IPs needed
  + nodes                   = node IPs
  + 5                       = Azure reserved per subnet
  = minimum subnet size

Example (5 nodes, 30 max pods):
  5 * 30 = 150 pod IPs
  + 5    = 155 node IPs
  + 5    = 160 total
  → /24 subnet (256 IPs) works
  → /25 subnet (128 IPs) does NOT
```

Plan subnets generously. Running out of IPs in a subnet requires cluster recreation.

### Azure Verified Modules (AVM)

Microsoft-maintained, tested, and supported Terraform modules. Use these over hand-rolling resources for production.

```hcl
module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.7"

  name                = "vnet-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  address_space = ["10.0.0.0/16"]

  subnets = {
    aks = {
      name             = "snet-aks"
      address_prefixes = ["10.0.0.0/22"]
    }
    db = {
      name             = "snet-db"
      address_prefixes = ["10.0.8.0/24"]
      delegation = [{
        name = "postgresql"
        service_delegation = {
          name = "Microsoft.DBforPostgreSQL/flexibleServers"
        }
      }]
    }
  }
}
```

AVM modules follow consistent naming (`avm-res-{service}-{resource}`), support diagnostic settings, role assignments, and locks as first-class inputs.

### Key Vault for Secrets

```hcl
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                       = "kv-${var.project}-${var.environment}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled   = true
  enable_rbac_authorization  = true  # Prefer RBAC over access policies
}

# Grant Terraform's identity access
resource "azurerm_role_assignment" "terraform_kv" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Store a secret
resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = random_password.db.result
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_role_assignment.terraform_kv]
}
```

Use RBAC authorization (`enable_rbac_authorization = true`) over legacy access policies. RBAC integrates with Azure AD and supports conditional access.

---

## Cross-Cloud Patterns

### Multi-Cloud Provider Configuration

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
```

### Common Pitfalls Across All Clouds

1. **State contains secrets** -- cloud provider credentials, database passwords, and API keys end up in state. Always use encrypted remote backends.
2. **Provider authentication in CI** -- use OIDC/workload identity federation, never long-lived credentials.
3. **API rate limiting** -- large configurations hit cloud API rate limits. Use `-parallelism=5` to throttle.
4. **Drift detection** -- schedule `terraform plan` in CI to detect manual changes.
5. **Import existing resources** -- use `terraform import` or `import` blocks (1.5+) to bring existing infrastructure under management without recreation.
