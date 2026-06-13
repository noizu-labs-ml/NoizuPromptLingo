# Worked Example: EKS Platform from Scratch

> End-to-end walkthrough of building a production Kubernetes platform on AWS using Terraform. From architecture decisions through working HCL, testing, CI/CD, and Cloudflare DNS integration. Demonstrates state splitting, module composition, IRSA, managed node groups with spot instances, RDS Aurora, and a monitoring stack -- all wired together with real code.

---

## Scenario

A startup is graduating from a single EC2 instance to Kubernetes. They need:

- **VPC** with public/private subnets across 3 AZs
- **EKS cluster** with managed node groups (system on-demand + workload on spot)
- **RDS Aurora PostgreSQL** for the application database
- **Monitoring stack** (Prometheus + Grafana via kube-prometheus-stack Helm chart)
- **ArgoCD** for GitOps-based application deployment
- **CI/CD pipeline** with GitHub Actions (plan on PR, apply on merge)
- **Cloudflare** for DNS and CDN in front of the ALB

Budget is constrained (startup), so we optimize for cost in dev and reliability in prod. The team is 4 engineers; they need a platform that's auditable, testable, and doesn't require a dedicated platform engineer to operate day-to-day.

---

## Step 1: Architecture Design

### State Splitting Strategy

Three state files per environment, split by **change frequency** and **blast radius**:

| State File | Contents | Change Frequency | Blast Radius |
|-----------|----------|-----------------|-------------|
| `networking` | VPC, subnets, NAT, VPC endpoints, security groups | Rarely | High (everything depends on it) |
| `platform` | EKS, node groups, add-ons, ArgoCD, monitoring | Monthly | High (all workloads affected) |
| `data` | RDS Aurora, parameter groups, backups | Rarely | Critical (data loss risk) |

**Why not a single state file?** A `terraform plan` that touches the VPC shouldn't make anyone nervous about the database. State splitting limits the blast radius of any single apply and allows different teams (if they grow) to own different layers.

**Why not one state per resource?** Over-splitting creates dependency nightmares. Three states is the sweet spot for this scale.

### Module Composition

```
networking ─────┬──────► platform
                │
                └──────► data
```

`platform` and `data` both consume outputs from `networking` (VPC ID, subnet IDs, security group IDs) via `terraform_remote_state` data sources. They don't depend on each other -- the application code handles database connection strings via environment variables injected through Kubernetes secrets.

### Environment Strategy

Directory-based environments with shared modules. Each environment pins its own module versions and variable values:

```
terraform/
  modules/
    networking/           # VPC, subnets, NAT, VPC endpoints, security groups
      main.tf
      variables.tf
      outputs.tf
      versions.tf
    platform/             # EKS, node groups, IRSA, add-ons, ArgoCD, monitoring
      main.tf
      variables.tf
      outputs.tf
      versions.tf
    data/                 # RDS Aurora, parameter groups, security groups
      main.tf
      variables.tf
      outputs.tf
      versions.tf
  environments/
    dev/
      networking/
        main.tf           # Module call with dev values
        backend.tf        # S3 backend config
        terraform.tfvars
      platform/
        main.tf
        backend.tf
        terraform.tfvars
      data/
        main.tf
        backend.tf
        terraform.tfvars
    staging/
      networking/
      platform/
      data/
    prod/
      networking/
      platform/
      data/
  tests/
    networking.tftest.hcl
    platform.tftest.hcl
  .tflint.hcl
  .checkov.yaml
  .github/
    workflows/
      terraform.yaml
```

**Why directory-based instead of workspaces?** Workspaces share the same backend configuration and variable files, making it easy to accidentally apply prod variables to dev. Directory-based environments are explicit -- you `cd` into the environment, and the backend, variables, and state are all scoped. It's harder to make a mistake.

---

## Step 2: Backend Configuration

Terraform 1.10+ supports native S3 state locking without DynamoDB. We use a single S3 bucket with key-path separation per environment and component.

### Bootstrap: Create the State Bucket

This is the one piece of infrastructure we create manually (or via a tiny bootstrap script), because Terraform can't manage its own backend bucket:

```hcl
# bootstrap/main.tf -- apply this once manually
# After apply, all other Terraform configs use this bucket.

terraform {
  required_version = ">= 1.10"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "acme-startup-terraform-state"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### Backend Config Per Component

Each component gets a unique key path. Here are the three backend files for the dev environment:

**`environments/dev/networking/backend.tf`**
```hcl
terraform {
  backend "s3" {
    bucket       = "acme-startup-terraform-state"
    key          = "dev/networking/terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
```

**`environments/dev/platform/backend.tf`**
```hcl
terraform {
  backend "s3" {
    bucket       = "acme-startup-terraform-state"
    key          = "dev/platform/terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
```

**`environments/dev/data/backend.tf`**
```hcl
terraform {
  backend "s3" {
    bucket       = "acme-startup-terraform-state"
    key          = "dev/data/terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
```

For prod, the keys become `prod/networking/terraform.tfstate`, etc. Same bucket, different paths.

The `use_lockfile = true` flag enables Terraform 1.10's native S3 locking -- no DynamoDB table needed. This uses S3 conditional writes to prevent concurrent applies.

---

## Step 3: Networking Module

### Module: `modules/networking/`

**`modules/networking/versions.tf`**
```hcl
terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**`modules/networking/variables.tf`**
```hcl
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "acme"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway (cost saving for non-prod)"
  type        = bool
  default     = false
}

variable "enable_vpc_endpoints" {
  description = "Create VPC endpoints for ECR and S3"
  type        = bool
  default     = true
}
```

**`modules/networking/main.tf`**
```hcl
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  name = "${var.project_name}-${var.environment}"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 4, i)]
  public_subnets  = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 4, i + 4)]

  # Database subnets -- isolated, no NAT route
  database_subnets                   = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 4, i + 8)]
  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway
  # One NAT per AZ in prod, single in dev
  one_nat_gateway_per_az = !var.single_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

  # EKS requires these tags on subnets for automatic subnet discovery
  public_subnet_tags = {
    "kubernetes.io/role/elb"                        = 1
    "kubernetes.io/cluster/${local.name}-eks"        = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"               = 1
    "kubernetes.io/cluster/${local.name}-eks"        = "shared"
  }

  tags = local.tags
}

# --- VPC Endpoints ---
# These save significant NAT gateway costs by routing AWS service
# traffic over the private AWS network instead of through NAT.

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags            = { Name = "${local.name}-s3-endpoint" }
    }

    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_endpoints.id]
      tags                = { Name = "${local.name}-ecr-api-endpoint" }
    }

    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_endpoints.id]
      tags                = { Name = "${local.name}-ecr-dkr-endpoint" }
    }

    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_endpoints.id]
      tags                = { Name = "${local.name}-sts-endpoint" }
    }
  }

  tags = local.tags
}

resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${local.name}-vpc-endpoints-"
  description = "Security group for VPC endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTPS from VPC"
  }

  tags = merge(local.tags, {
    Name = "${local.name}-vpc-endpoints"
  })

  lifecycle {
    create_before_destroy = true
  }
}
```

**`modules/networking/outputs.tf`**
```hcl
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs (for EKS nodes and internal services)"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "Public subnet IDs (for load balancers)"
  value       = module.vpc.public_subnets
}

output "database_subnet_group_name" {
  description = "Database subnet group name (for RDS)"
  value       = module.vpc.database_subnet_group_name
}

output "database_subnet_ids" {
  description = "Database subnet IDs"
  value       = module.vpc.database_subnets
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "nat_public_ips" {
  description = "NAT gateway public IPs (for allowlisting)"
  value       = module.vpc.nat_public_ips
}
```

### Environment Call: `environments/dev/networking/main.tf`

```hcl
provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Project     = "acme"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

module "networking" {
  source = "../../../modules/networking"

  environment        = "dev"
  project_name       = "acme"
  vpc_cidr           = "10.0.0.0/16"
  single_nat_gateway = true    # Cost saving: one NAT for dev
}

output "vpc_id" {
  value = module.networking.vpc_id
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "database_subnet_group_name" {
  value = module.networking.database_subnet_group_name
}
```

For prod, the only difference is `single_nat_gateway = false` (one NAT per AZ for HA).

---

## Step 4: Platform Module

### Module: `modules/platform/`

**`modules/platform/variables.tf`**
```hcl
variable "environment" {
  type = string
}

variable "project_name" {
  type    = string
  default = "acme"
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "vpc_id" {
  description = "VPC ID from networking state"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS nodes"
  type        = list(string)
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "system_node_instance_types" {
  description = "Instance types for system node group"
  type        = list(string)
  default     = ["m6i.large"]
}

variable "workload_node_instance_types" {
  description = "Instance types for workload node group (spot)"
  type        = list(string)
  default     = ["m6i.large", "m6a.large", "m5.large", "m5a.large"]
}

variable "system_node_desired" {
  type    = number
  default = 2
}

variable "workload_node_min" {
  type    = number
  default = 1
}

variable "workload_node_max" {
  type    = number
  default = 10
}

variable "workload_node_desired" {
  type    = number
  default = 2
}

variable "enable_argocd" {
  description = "Deploy ArgoCD via Helm"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Deploy kube-prometheus-stack via Helm"
  type        = bool
  default     = true
}

variable "argocd_chart_version" {
  type    = string
  default = "7.7.0"
}

variable "kube_prometheus_chart_version" {
  type    = string
  default = "65.1.0"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = ""
}
```

**`modules/platform/main.tf`**
```hcl
locals {
  name = "${var.project_name}-${var.environment}"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# --- EKS Cluster ---

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${local.name}-eks"
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Public endpoint for kubectl access; restrict in prod
  cluster_endpoint_public_access = true

  # Enable IRSA (IAM Roles for Service Accounts)
  enable_irsa = true

  # Cluster add-ons -- managed by AWS, auto-upgraded
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
  }

  # Managed node groups
  eks_managed_node_groups = {
    # System node group: on-demand, always available
    # Runs CoreDNS, kube-proxy, monitoring, ArgoCD
    system = {
      name            = "${local.name}-system"
      instance_types  = var.system_node_instance_types
      capacity_type   = "ON_DEMAND"
      desired_size    = var.system_node_desired
      min_size        = var.system_node_desired
      max_size        = var.system_node_desired + 1

      labels = {
        "node-role" = "system"
      }

      taints = []

      tags = merge(local.tags, {
        NodeGroup = "system"
      })
    }

    # Workload node group: spot instances, autoscaled
    # Runs application workloads -- tolerates interruption
    workload = {
      name            = "${local.name}-workload"
      instance_types  = var.workload_node_instance_types
      capacity_type   = "SPOT"
      desired_size    = var.workload_node_desired
      min_size        = var.workload_node_min
      max_size        = var.workload_node_max

      labels = {
        "node-role" = "workload"
      }

      taints = []

      tags = merge(local.tags, {
        NodeGroup = "workload"
      })
    }
  }

  # Allow the CI/CD OIDC role to manage the cluster
  access_entries = {
    ci_cd = {
      principal_arn = aws_iam_role.github_actions.arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = local.tags
}

# --- IRSA: EBS CSI Driver ---
# The EBS CSI driver needs IAM permissions to create/attach EBS volumes.
# IRSA maps a Kubernetes ServiceAccount to an IAM role -- no instance
# profiles, no shared node-level permissions.

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${local.name}-ebs-csi-controller"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

# --- GitHub Actions OIDC ---
# Allows GitHub Actions to assume an IAM role without long-lived
# credentials. The trust policy restricts to our specific repo.

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_actions" {
  name = "${local.name}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:acme-startup/infra:*"
          }
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "github_actions_eks" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  # In production, scope this down to only the permissions needed:
  # - EKS management
  # - S3 state access
  # - ECR push
  # AdministratorAccess is a starting point; replace with a custom policy.
}

# --- ArgoCD ---

resource "helm_release" "argocd" {
  count = var.enable_argocd ? 1 : 0

  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version

  values = [yamlencode({
    server = {
      service = {
        type = "ClusterIP"
      }
      ingress = {
        enabled          = true
        ingressClassName = "nginx"
        hosts            = ["argocd.internal.acme.com"]
        tls = [{
          secretName = "argocd-tls"
          hosts      = ["argocd.internal.acme.com"]
        }]
      }
    }
    configs = {
      params = {
        "server.insecure" = true  # TLS terminated at ingress
      }
    }
    # Pin ArgoCD to system nodes
    controller = {
      nodeSelector = { "node-role" = "system" }
    }
    server = {
      nodeSelector = { "node-role" = "system" }
    }
    repoServer = {
      nodeSelector = { "node-role" = "system" }
    }
  })]

  depends_on = [module.eks]
}

# --- Monitoring: kube-prometheus-stack ---

resource "helm_release" "kube_prometheus_stack" {
  count = var.enable_monitoring ? 1 : 0

  name             = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = var.kube_prometheus_chart_version
  timeout          = 900

  values = [yamlencode({
    prometheus = {
      prometheusSpec = {
        retention         = "15d"
        nodeSelector      = { "node-role" = "system" }
        storageSpec = {
          volumeClaimTemplate = {
            spec = {
              storageClassName = "gp3"
              accessModes      = ["ReadWriteOnce"]
              resources = {
                requests = {
                  storage = "50Gi"
                }
              }
            }
          }
        }
      }
    }

    grafana = {
      adminPassword = var.grafana_admin_password != "" ? var.grafana_admin_password : null
      nodeSelector  = { "node-role" = "system" }
      ingress = {
        enabled          = true
        ingressClassName = "nginx"
        hosts            = ["grafana.internal.acme.com"]
        tls = [{
          secretName = "grafana-tls"
          hosts      = ["grafana.internal.acme.com"]
        }]
      }
      persistence = {
        enabled          = true
        storageClassName = "gp3"
        size             = "10Gi"
      }
    }

    alertmanager = {
      alertmanagerSpec = {
        nodeSelector = { "node-role" = "system" }
      }
    }

    # Collect metrics from kube-state-metrics, node-exporter, etc.
    kubeStateMetrics = {
      enabled = true
    }
    nodeExporter = {
      enabled = true
    }
  })]

  depends_on = [module.eks]
}
```

**`modules/platform/outputs.tf`**
```hcl
output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded CA cert for the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN (for creating additional IRSA roles)"
  value       = module.eks.oidc_provider_arn
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ID attached to EKS nodes"
  value       = module.eks.node_security_group_id
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC"
  value       = aws_iam_role.github_actions.arn
}
```

### Environment Call: `environments/dev/platform/main.tf`

```hcl
provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Project     = "acme"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

# Read networking outputs from remote state
data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "acme-startup-terraform-state"
    key    = "dev/networking/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.platform.cluster_endpoint
    cluster_ca_certificate = base64decode(module.platform.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.platform.cluster_name]
    }
  }
}

module "platform" {
  source = "../../../modules/platform"

  environment        = "dev"
  project_name       = "acme"
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids

  cluster_version = "1.31"

  # Dev sizing: small and cheap
  system_node_instance_types   = ["m6i.large"]
  system_node_desired          = 2
  workload_node_instance_types = ["m6i.large", "m6a.large", "m5.large"]
  workload_node_min            = 1
  workload_node_max            = 5
  workload_node_desired        = 1

  enable_argocd     = true
  enable_monitoring = true

  grafana_admin_password = var.grafana_admin_password
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}
```

---

## Step 5: Data Module

### Module: `modules/data/`

**`modules/data/variables.tf`**
```hcl
variable "environment" {
  type = string
}

variable "project_name" {
  type    = string
  default = "acme"
}

variable "vpc_id" {
  type = string
}

variable "database_subnet_group_name" {
  type = string
}

variable "database_subnet_ids" {
  type = list(string)
}

variable "vpc_cidr_block" {
  description = "VPC CIDR for security group ingress"
  type        = string
}

variable "eks_node_security_group_id" {
  description = "EKS node security group ID (allowed to connect to RDS)"
  type        = string
}

variable "engine_version" {
  type    = string
  default = "16.4"
}

variable "instance_class" {
  description = "Aurora instance class"
  type        = string
  default     = "db.r6g.large"
}

variable "instances" {
  description = "Number of Aurora instances (1 for dev, 2+ for prod)"
  type        = number
  default     = 1
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "master_username" {
  type    = string
  default = "app_admin"
}
```

**`modules/data/main.tf`**
```hcl
locals {
  name = "${var.project_name}-${var.environment}"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# --- Security Group ---
# Only allows inbound PostgreSQL from the EKS node security group.
# No public access, no broad CIDR rules.

resource "aws_security_group" "rds" {
  name_prefix = "${local.name}-rds-"
  description = "Security group for Aurora PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id]
    description     = "PostgreSQL from EKS nodes"
  }

  tags = merge(local.tags, {
    Name = "${local.name}-rds"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# --- RDS Aurora PostgreSQL ---

module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 9.0"

  name            = "${local.name}-aurora"
  engine          = "aurora-postgresql"
  engine_version  = var.engine_version
  master_username = var.master_username

  # Networking
  vpc_id               = var.vpc_id
  db_subnet_group_name = var.database_subnet_group_name
  security_group_rules = {
    eks_ingress = {
      source_security_group_id = var.eks_node_security_group_id
    }
  }

  # Instances
  instances = {
    for i in range(var.instances) : "instance-${i}" => {
      instance_class = var.instance_class
    }
  }

  # Storage
  storage_encrypted = true

  # Backups and maintenance
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = "03:00-04:00"
  preferred_maintenance_window = "sun:05:00-sun:06:00"
  skip_final_snapshot          = var.environment == "dev" ? true : false
  final_snapshot_identifier    = var.environment != "dev" ? "${local.name}-final-snapshot" : null
  deletion_protection          = var.environment == "prod" ? true : false

  # Monitoring
  enabled_cloudwatch_logs_exports = ["postgresql"]
  monitoring_interval             = 60
  create_monitoring_role          = true

  # Parameter group: tune for our workload
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name

  apply_immediately = var.environment == "dev" ? true : false

  tags = local.tags

  # CRITICAL: prevent accidental deletion of production data
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_rds_cluster_parameter_group" "this" {
  name_prefix = "${local.name}-aurora-"
  family      = "aurora-postgresql16"
  description = "Custom parameter group for ${local.name}"

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"  # Log queries slower than 1 second
  }

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }

  parameter {
    name         = "pg_stat_statements.track"
    value        = "all"
    apply_method = "pending-reboot"
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}
```

**`modules/data/outputs.tf`**
```hcl
output "cluster_endpoint" {
  description = "Aurora cluster writer endpoint"
  value       = module.aurora.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = module.aurora.cluster_reader_endpoint
}

output "cluster_port" {
  description = "Aurora cluster port"
  value       = module.aurora.cluster_port
}

output "cluster_master_username" {
  description = "Master username"
  value       = module.aurora.cluster_master_username
}

output "cluster_master_password" {
  description = "Master password"
  value       = module.aurora.cluster_master_password
  sensitive   = true
}
```

### Environment Call: `environments/dev/data/main.tf`

```hcl
provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Project     = "acme"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "acme-startup-terraform-state"
    key    = "dev/networking/terraform.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "platform" {
  backend = "s3"
  config = {
    bucket = "acme-startup-terraform-state"
    key    = "dev/platform/terraform.tfstate"
    region = "us-west-2"
  }
}

module "data" {
  source = "../../../modules/data"

  environment = "dev"

  vpc_id                     = data.terraform_remote_state.networking.outputs.vpc_id
  database_subnet_group_name = data.terraform_remote_state.networking.outputs.database_subnet_group_name
  database_subnet_ids        = data.terraform_remote_state.networking.outputs.database_subnet_ids
  vpc_cidr_block             = data.terraform_remote_state.networking.outputs.vpc_cidr_block
  eks_node_security_group_id = data.terraform_remote_state.platform.outputs.node_security_group_id

  # Dev sizing: single instance, smallest Aurora class
  instance_class          = "db.r6g.large"
  instances               = 1
  backup_retention_period = 3
}
```

---

## Step 6: Testing

### Terraform Native Tests: `tests/networking.tftest.hcl`

Plan-only tests that validate module configuration without creating real infrastructure:

```hcl
# tests/networking.tftest.hcl

provider "aws" {
  region = "us-west-2"
}

variables {
  environment        = "test"
  project_name       = "acme"
  vpc_cidr           = "10.0.0.0/16"
  single_nat_gateway = true
}

run "vpc_cidr_is_valid" {
  command = plan

  module {
    source = "./modules/networking"
  }

  assert {
    condition     = module.vpc.vpc_cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR does not match expected value"
  }
}

run "creates_three_private_subnets" {
  command = plan

  module {
    source = "./modules/networking"
  }

  assert {
    condition     = length(module.vpc.private_subnets) == 3
    error_message = "Expected 3 private subnets, got ${length(module.vpc.private_subnets)}"
  }
}

run "creates_three_public_subnets" {
  command = plan

  module {
    source = "./modules/networking"
  }

  assert {
    condition     = length(module.vpc.public_subnets) == 3
    error_message = "Expected 3 public subnets"
  }
}

run "rejects_invalid_environment" {
  command = plan

  module {
    source = "./modules/networking"
  }

  variables {
    environment = "invalid"
  }

  expect_failures = [
    var.environment,
  ]
}

run "rejects_invalid_cidr" {
  command = plan

  module {
    source = "./modules/networking"
  }

  variables {
    vpc_cidr = "not-a-cidr"
  }

  expect_failures = [
    var.vpc_cidr,
  ]
}
```

### Checkov Configuration: `.checkov.yaml`

```yaml
# .checkov.yaml
framework:
  - terraform
directory:
  - modules/
soft-fail: false
skip-check:
  # We intentionally use public subnets for ALBs
  - CKV_AWS_130  # "Ensure VPC subnets do not assign public IP by default"
output:
  - cli
  - junitxml
compact: true
```

### TFLint Configuration: `.tflint.hcl`

```hcl
# .tflint.hcl

config {
  call_module_type = "local"
}

plugin "aws" {
  enabled = true
  version = "0.34.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

rule "terraform_naming_convention" {
  enabled = true

  custom_formats = {}

  variable {
    format = "snake_case"
  }

  output {
    format = "snake_case"
  }

  resource {
    format = "snake_case"
  }
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}
```

Run the test suite:

```bash
# Format check
terraform fmt -check -recursive

# Native tests (plan-only, no infra created)
terraform test -test-directory=tests

# Lint
tflint --recursive --config .tflint.hcl

# Security scan
checkov -d modules/ --config-file .checkov.yaml
```

---

## Step 7: CI/CD Pipeline

### GitHub Actions: `.github/workflows/terraform.yaml`

```yaml
name: Terraform

on:
  pull_request:
    paths:
      - 'terraform/**'
  push:
    branches: [main]
    paths:
      - 'terraform/**'

permissions:
  id-token: write    # OIDC federation
  contents: read
  pull-requests: write  # Post plan output as PR comment

concurrency:
  group: terraform-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: true

env:
  TF_VERSION: "1.10.3"
  AWS_REGION: "us-west-2"

jobs:
  # --------------------------------------------------
  # Detect which components changed
  # --------------------------------------------------
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      networking: ${{ steps.changes.outputs.networking }}
      platform: ${{ steps.changes.outputs.platform }}
      data: ${{ steps.changes.outputs.data }}
    steps:
      - uses: actions/checkout@v4
      - uses: dorny/paths-filter@v3
        id: changes
        with:
          filters: |
            networking:
              - 'terraform/modules/networking/**'
              - 'terraform/environments/*/networking/**'
            platform:
              - 'terraform/modules/platform/**'
              - 'terraform/environments/*/platform/**'
            data:
              - 'terraform/modules/data/**'
              - 'terraform/environments/*/data/**'

  # --------------------------------------------------
  # Validate: fmt, tflint, checkov (runs on all PRs)
  # --------------------------------------------------
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Terraform Format Check
        run: terraform fmt -check -recursive -diff
        working-directory: terraform

      - name: Install tflint
        uses: terraform-linters/setup-tflint@v4
        with:
          tflint_version: "v0.53.0"

      - name: Init tflint plugins
        run: tflint --init --config .tflint.hcl
        working-directory: terraform

      - name: Run tflint
        run: tflint --recursive --config .tflint.hcl
        working-directory: terraform

      - name: Run checkov
        uses: bridgecrewio/checkov-action@v12
        with:
          directory: terraform/modules
          config_file: terraform/.checkov.yaml
          output_format: cli

  # --------------------------------------------------
  # Plan (per-component, only if changed)
  # --------------------------------------------------
  plan:
    needs: [detect-changes, validate]
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        component: [networking, platform, data]
        environment: [dev]  # Expand to [dev, staging, prod] when ready
        exclude:
          - component: networking
            environment: dev
            # Dynamically skip unchanged components
    steps:
      - uses: actions/checkout@v4

      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/acme-${{ matrix.environment }}-github-actions
          aws-region: ${{ env.AWS_REGION }}

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Terraform Init
        run: terraform init -input=false
        working-directory: terraform/environments/${{ matrix.environment }}/${{ matrix.component }}

      - name: Terraform Plan
        id: plan
        run: |
          terraform plan -input=false -no-color -out=tfplan \
            2>&1 | tee plan-output.txt
        working-directory: terraform/environments/${{ matrix.environment }}/${{ matrix.component }}

      - name: Post Plan to PR
        uses: actions/github-script@v7
        if: github.event_name == 'pull_request'
        with:
          script: |
            const fs = require('fs');
            const planPath = `terraform/environments/${{ matrix.environment }}/${{ matrix.component }}/plan-output.txt`;
            const plan = fs.readFileSync(planPath, 'utf8');

            // Truncate if too long for a PR comment
            const maxLen = 60000;
            const truncated = plan.length > maxLen
              ? plan.substring(0, maxLen) + '\n\n... truncated ...'
              : plan;

            const body = `### Terraform Plan: \`${{ matrix.environment }}/${{ matrix.component }}\`

            \`\`\`
            ${truncated}
            \`\`\`

            *Triggered by @${{ github.actor }} in ${{ github.event.pull_request.html_url }}*`;

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: body
            });

  # --------------------------------------------------
  # Apply (only on merge to main)
  # --------------------------------------------------
  apply:
    needs: [detect-changes, validate]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    environment: production  # Requires manual approval in GitHub settings
    strategy:
      max-parallel: 1  # Apply one at a time, in order
      matrix:
        include:
          # Ordered: networking first, then platform, then data
          - component: networking
            environment: dev
            order: 1
          - component: platform
            environment: dev
            order: 2
          - component: data
            environment: dev
            order: 3
    steps:
      - uses: actions/checkout@v4

      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/acme-${{ matrix.environment }}-github-actions
          aws-region: ${{ env.AWS_REGION }}

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Terraform Init
        run: terraform init -input=false
        working-directory: terraform/environments/${{ matrix.environment }}/${{ matrix.component }}

      - name: Terraform Apply
        run: terraform apply -input=false -auto-approve
        working-directory: terraform/environments/${{ matrix.environment }}/${{ matrix.component }}
```

### OIDC Federation Setup

The GitHub Actions OIDC provider must be created once per AWS account. If it doesn't already exist (the `data` source in the platform module assumes it does), create it:

```hcl
# bootstrap/github-oidc.tf -- apply once

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]
  # AWS ignores the thumbprint for GitHub's OIDC but requires the field
}
```

---

## Step 8: Cloudflare DNS

### Cloudflare Provider Configuration

```hcl
# modules/dns/versions.tf

terraform {
  required_version = ">= 1.10"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}
```

### DNS Records for the EKS ALB

```hcl
# modules/dns/main.tf

variable "zone_id" {
  description = "Cloudflare zone ID for the domain"
  type        = string
}

variable "domain" {
  description = "Root domain (e.g., acme.com)"
  type        = string
}

variable "alb_hostname" {
  description = "ALB DNS name from the AWS load balancer controller"
  type        = string
}

variable "environment" {
  type = string
}

locals {
  # dev uses dev.acme.com, prod uses acme.com
  subdomain_prefix = var.environment == "prod" ? "" : "${var.environment}."
}

# Main application: app.acme.com (prod) or app.dev.acme.com (dev)
resource "cloudflare_dns_record" "app" {
  zone_id = var.zone_id
  name    = "${local.subdomain_prefix}app"
  content = var.alb_hostname
  type    = "CNAME"
  proxied = true
  ttl     = 1  # Auto when proxied
  comment = "EKS ALB - managed by Terraform"
}

# API endpoint: api.acme.com
resource "cloudflare_dns_record" "api" {
  zone_id = var.zone_id
  name    = "${local.subdomain_prefix}api"
  content = var.alb_hostname
  type    = "CNAME"
  proxied = true
  ttl     = 1
  comment = "EKS ALB API - managed by Terraform"
}

# Grafana (internal, not proxied through Cloudflare CDN)
resource "cloudflare_dns_record" "grafana" {
  zone_id = var.zone_id
  name    = "${local.subdomain_prefix}grafana.internal"
  content = var.alb_hostname
  type    = "CNAME"
  proxied = false  # Internal tool, use Cloudflare Tunnel instead
  ttl     = 300
  comment = "Grafana - managed by Terraform"
}
```

### Cloudflare Zero Trust Tunnel for Private Access

Instead of exposing internal tools (Grafana, ArgoCD) to the public internet, use a Cloudflare Tunnel:

```hcl
# modules/dns/tunnel.tf

resource "cloudflare_zero_trust_tunnel_cloudflared" "eks_internal" {
  account_id = var.cloudflare_account_id
  name       = "eks-${var.environment}-internal"
  secret     = var.tunnel_secret  # base64-encoded random secret
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "eks_internal" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.eks_internal.id

  config {
    ingress_rule {
      hostname = "grafana.internal.${var.domain}"
      service  = "http://kube-prometheus-stack-grafana.monitoring.svc.cluster.local:80"
    }

    ingress_rule {
      hostname = "argocd.internal.${var.domain}"
      service  = "http://argocd-server.argocd.svc.cluster.local:80"
    }

    # Catch-all: return 404 for unmatched hostnames
    ingress_rule {
      service = "http_status:404"
    }
  }
}

# DNS records for tunneled services
resource "cloudflare_dns_record" "tunnel_grafana" {
  zone_id = var.zone_id
  name    = "${local.subdomain_prefix}grafana.internal"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.eks_internal.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
  ttl     = 1
  comment = "Cloudflare Tunnel for Grafana - managed by Terraform"
}

resource "cloudflare_dns_record" "tunnel_argocd" {
  zone_id = var.zone_id
  name    = "${local.subdomain_prefix}argocd.internal"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.eks_internal.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
  ttl     = 1
  comment = "Cloudflare Tunnel for ArgoCD - managed by Terraform"
}

# Access policy: require authentication
resource "cloudflare_zero_trust_access_application" "internal_tools" {
  zone_id          = var.zone_id
  name             = "EKS Internal Tools (${var.environment})"
  domain           = "*.internal.${local.subdomain_prefix}${var.domain}"
  session_duration = "24h"
  type             = "self_hosted"
}

resource "cloudflare_zero_trust_access_policy" "internal_tools" {
  zone_id        = var.zone_id
  application_id = cloudflare_zero_trust_access_application.internal_tools.id
  name           = "Allow team members"
  decision       = "allow"
  precedence     = 1

  include {
    email_domain = [var.domain]
  }
}
```

---

## Deployment Order

Execute in this sequence for a fresh environment:

```bash
# 1. Bootstrap (once per AWS account)
cd terraform/bootstrap
terraform init && terraform apply

# 2. Networking (rarely changes after initial setup)
cd terraform/environments/dev/networking
terraform init && terraform apply

# 3. Platform (depends on networking outputs)
cd terraform/environments/dev/platform
terraform init && terraform apply -var="grafana_admin_password=<secret>"

# 4. Data (depends on networking + platform outputs)
cd terraform/environments/dev/data
terraform init && terraform apply

# 5. DNS (depends on ALB hostname from platform)
cd terraform/environments/dev/dns
terraform init && terraform apply

# Verify
aws eks update-kubeconfig --name acme-dev-eks --region us-west-2
kubectl get nodes
kubectl get pods -A
```

---

## Lessons Learned

### 1. Start with networking state -- it rarely changes

The VPC, subnets, and NAT gateways are the foundation. Once they're up, you almost never touch them. Isolating networking state means your most frequent operations (platform changes, data tweaks) never risk the foundation.

### 2. Always have at least one managed node group

EKS add-ons like CoreDNS need compute to schedule onto. If you use only Fargate or Karpenter with no baseline nodes, CoreDNS can't start, and without CoreDNS, nothing else can resolve DNS. The system node group (on-demand, fixed size) guarantees that critical cluster services always have a home.

### 3. Use IRSA, not instance profiles

Instance profiles grant IAM permissions to every pod on a node. IRSA (IAM Roles for Service Accounts) grants permissions to specific Kubernetes ServiceAccounts. This is the difference between "every pod on this node can create EBS volumes" and "only the ebs-csi-controller pod can create EBS volumes." Always use IRSA.

### 4. `prevent_destroy` on databases from day 1

Add `lifecycle { prevent_destroy = true }` to your RDS module on day one, not after the first accidental deletion. A `terraform destroy` that nukes production data is unrecoverable (snapshots help, but restoring takes time and coordination). The `prevent_destroy` lifecycle meta-argument makes Terraform refuse to destroy the resource, forcing you to explicitly remove the lifecycle block first -- a deliberate, reviewable act.

### 5. VPC endpoints save significant NAT costs

Without VPC endpoints, every ECR image pull and S3 access from private subnets routes through the NAT gateway. NAT gateway pricing is $0.045/GB processed. For a cluster pulling dozens of container images daily and writing logs to S3, this adds up fast. VPC endpoints for S3 (Gateway, free) and ECR (Interface, ~$7/month per AZ) pay for themselves within days.

### 6. Spot instance diversification matters

Don't specify a single instance type for spot node groups. AWS reclaims spot capacity per instance type per AZ. If your workload node group only uses `m6i.large`, a capacity reclamation event takes out your entire workload tier. Specifying 4+ instance types across families (`m6i`, `m6a`, `m5`, `m5a`) dramatically reduces the chance of simultaneous reclamation.

### 7. Plan output in PR comments is non-negotiable

Engineers must see what Terraform will change before approving a PR. Posting `terraform plan` output as a PR comment means reviewers see the exact resources being created, modified, or destroyed. This catches "I changed a variable and accidentally triggered a database replacement" before it reaches production.

### 8. Pin module versions and upgrade deliberately

The community modules (`terraform-aws-modules/vpc/aws`, `terraform-aws-modules/eks/aws`) release frequently. Using `~> 5.0` gives you patch updates but prevents major version jumps. Even so, run `terraform plan` after any module version bump and review the diff. A minor version bump in the EKS module once changed the default node AMI, triggering a rolling replacement of every node in the cluster.

---

## Cost Estimation (Dev Environment)

| Resource | Monthly Estimate |
|----------|-----------------|
| EKS control plane | $73 |
| 2x m6i.large system nodes (on-demand) | ~$140 |
| 1x m6i.large workload node (spot, ~70% discount) | ~$21 |
| NAT gateway (single) | ~$32 + data processing |
| VPC endpoints (3 interface) | ~$22 |
| RDS Aurora db.r6g.large (single instance) | ~$197 |
| S3 state bucket | <$1 |
| **Total** | **~$486/month** |

Prod adds: multi-AZ NAT ($96), second Aurora instance ($197), more workload nodes, and the Cloudflare Tunnel (free on the Zero Trust plan). Expect ~$900-1200/month for a minimal prod setup.

---

## What This Example Demonstrated

| Terraform Engineer Skill Area | Where It Appeared |
|------------------------------|-------------------|
| State splitting strategy | Step 1, Step 2 |
| Module composition with remote state | Steps 3-5 (environment calls) |
| Community module usage | VPC, EKS, RDS Aurora, IAM |
| IRSA (IAM for Kubernetes) | Step 4 (EBS CSI driver) |
| Helm provider integration | Step 4 (ArgoCD, monitoring) |
| Variable validation | Step 3 (CIDR, environment) |
| `prevent_destroy` lifecycle | Step 5 (Aurora) |
| Native Terraform tests | Step 6 (.tftest.hcl) |
| Checkov + tflint | Step 6 |
| GitHub Actions CI/CD with OIDC | Step 7 |
| Cloudflare DNS + Zero Trust Tunnel | Step 8 |
| Cost-conscious environment design | Throughout (spot, single NAT, sizing) |
