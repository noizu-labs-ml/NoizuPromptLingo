# Cookbook: Multi-Cloud Patterns

Practical HCL recipes for coordinated deployments spanning AWS, GCP, Azure, and Cloudflare in a single Terraform root module or across orchestrated state files.

---

## When Multi-Cloud Is (and Isn't) Warranted

| Scenario | Multi-Cloud? | Better Alternative |
|:---------|:-------------|:-------------------|
| Regulatory: data residency requires specific regions only one cloud serves | Yes | -- |
| DR: primary in AWS, failover in GCP | Yes | -- |
| Best-of-breed: GKE for ML workloads + AWS for everything else | Yes | -- |
| Cloudflare CDN/WAF + AWS origin | Yes (lightweight) | -- |
| "Avoid vendor lock-in" with no concrete requirement | **No** | Single cloud + portable abstractions |
| Two teams each picked a different cloud | **No** | Organizational alignment first |

**Rule of thumb:** multi-cloud adds operational cost proportional to the number of provider-specific resources you manage. Only cross cloud boundaries when a concrete business, regulatory, or technical requirement forces it.

---

## 1. Provider Composition in a Single Root Module

When multiple clouds must coordinate in one deployment (shared state, cross-provider references), declare all providers in the same root module.

### Provider Block Layout

```hcl
# providers.tf

terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = var.project_name
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region

  default_labels = {
    environment = var.environment
    managed_by  = "terraform"
    project     = var.project_name
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
```

### Credential Isolation

Never mix credentials in environment variables — use provider-specific auth:

| Provider | Recommended Auth | CI/CD Pattern |
|:---------|:----------------|:-------------|
| AWS | OIDC federation (`assume_role_with_web_identity`) | GitHub Actions OIDC → STS |
| GCP | Workload Identity Federation | GitHub Actions OIDC → WIF |
| Azure | OIDC with federated credentials | GitHub Actions OIDC → Entra ID |
| Cloudflare | Scoped API token (not global key) | Secret in CI vault |

```hcl
# AWS: OIDC federation (no long-lived keys)
provider "aws" {
  region = var.aws_region
  assume_role_with_web_identity {
    role_arn                = var.aws_deploy_role_arn
    web_identity_token_file = var.oidc_token_path
  }
}

# GCP: Workload Identity Federation
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  # Uses GOOGLE_APPLICATION_CREDENTIALS pointing to WIF config
}
```

---

## 2. AWS Primary + Cloudflare CDN/WAF

The most common multi-cloud pattern: AWS hosts the origin; Cloudflare provides CDN, WAF, DDoS protection, and DNS.

### Architecture

```
User → Cloudflare (DNS + CDN + WAF) → AWS ALB → EKS pods
                                     ↘ S3 (static assets via R2 or direct)
```

### Full Recipe

```hcl
# --- AWS: Origin infrastructure ---

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.environment}-vpc"
  cidr = var.vpc_cidr
  azs  = var.availability_zones

  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway     = true
  single_nat_gateway     = var.environment != "prod"
  enable_dns_hostnames   = true
}

resource "aws_lb" "origin" {
  name               = "${var.environment}-origin-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets
}

# Restrict ALB to Cloudflare IPs only
resource "aws_security_group" "alb" {
  name   = "${var.environment}-alb-cf-only"
  vpc_id = module.vpc.vpc_id
}

# Cloudflare publishes their IP ranges — fetch dynamically
data "cloudflare_ip_ranges" "current" {}

resource "aws_security_group_rule" "cloudflare_ipv4" {
  for_each = toset(data.cloudflare_ip_ranges.current.ipv4_cidr_blocks)

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "cloudflare_ipv6" {
  for_each = toset(data.cloudflare_ip_ranges.current.ipv6_cidr_blocks)

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  ipv6_cidr_blocks  = [each.value]
  security_group_id = aws_security_group.alb.id
}

# --- Cloudflare: DNS + proxy + WAF ---

resource "cloudflare_zone" "main" {
  account_id = var.cloudflare_account_id
  zone       = var.domain
}

resource "cloudflare_dns_record" "app" {
  zone_id = cloudflare_zone.main.id
  name    = var.subdomain
  type    = "CNAME"
  content = aws_lb.origin.dns_name
  proxied = true
  ttl     = 1
}

# Authenticated Origin Pull — Cloudflare presents a client cert to ALB
resource "cloudflare_zone_setting" "aop" {
  zone_id    = cloudflare_zone.main.id
  setting_id = "tls_client_auth"
  value      = "on"
}

resource "cloudflare_ruleset" "waf" {
  zone_id = cloudflare_zone.main.id
  name    = "WAF rules"
  kind    = "zone"
  phase   = "http_rq_firewall_managed"

  rules {
    action = "execute"
    action_parameters {
      id = "efb7b8c949ac4650a09736fc376e9aee"
    }
    expression  = "true"
    description = "Cloudflare Managed Ruleset"
    enabled     = true
  }
}
```

---

## 3. AWS Primary + GCP Disaster Recovery

Active-passive DR: AWS runs production, GCP hosts a warm standby that can be promoted via DNS failover.

### Architecture

```
                     ┌─── Cloudflare DNS (weighted/failover) ───┐
                     │                                           │
              ┌──────▼──────┐                           ┌───────▼───────┐
              │  AWS (primary)  │                       │  GCP (standby)   │
              │  EKS + RDS     │  ── DB replication ──▶ │  GKE + Cloud SQL │
              └────────────────┘                        └─────────────────┘
```

### State Separation Strategy

DR deployments should use **separate state files** per cloud — a failed apply in one cloud must never block the other.

```
infrastructure/
├── modules/
│   ├── app-platform/          # Cloud-agnostic module interface
│   │   ├── variables.tf       # Inputs: cluster_endpoint, db_host, etc.
│   │   └── outputs.tf
│   ├── app-platform-aws/      # AWS implementation
│   └── app-platform-gcp/      # GCP implementation
├── environments/
│   └── prod/
│       ├── aws-primary/       # State 1: AWS resources
│       │   ├── main.tf
│       │   └── backend.tf
│       ├── gcp-standby/       # State 2: GCP resources
│       │   ├── main.tf
│       │   └── backend.tf
│       └── dns-failover/      # State 3: Cloudflare DNS routing
│           ├── main.tf
│           └── backend.tf
```

### Cloud-Agnostic Module Interface

Define a common interface that both cloud-specific modules implement:

```hcl
# modules/app-platform/variables.tf

variable "environment" {
  type = string
}

variable "app_name" {
  type = string
}

variable "db_config" {
  type = object({
    engine         = string
    engine_version = string
    instance_class = string
    storage_gb     = number
    ha_enabled     = bool
  })
}

variable "cluster_config" {
  type = object({
    node_count    = number
    machine_type  = string
    k8s_version   = string
  })
}
```

```hcl
# modules/app-platform/outputs.tf

output "cluster_endpoint" {
  type = string
}

output "db_endpoint" {
  type = string
}

output "db_replica_endpoint" {
  type        = string
  description = "Read replica endpoint for cross-cloud replication target"
}

output "ingress_ip" {
  type        = string
  description = "Public IP or hostname for DNS records"
}
```

### AWS Primary Implementation

```hcl
# environments/prod/aws-primary/main.tf

module "platform" {
  source = "../../../modules/app-platform-aws"

  environment = "prod"
  app_name    = "myapp"

  db_config = {
    engine         = "postgres"
    engine_version = "16"
    instance_class = "db.r7g.xlarge"
    storage_gb     = 500
    ha_enabled     = true
  }

  cluster_config = {
    node_count   = 6
    machine_type = "m6i.xlarge"
    k8s_version  = "1.30"
  }
}

# Cross-region read replica for GCP logical replication source
resource "aws_db_instance" "replica_source" {
  identifier          = "myapp-replica-source"
  replicate_source_db = module.platform.db_instance_id
  instance_class      = "db.r7g.large"

  # Enable logical replication for cross-cloud
  parameter_group_name = aws_db_parameter_group.logical_replication.name
}

resource "aws_db_parameter_group" "logical_replication" {
  name   = "myapp-logical-replication"
  family = "postgres16"

  parameter {
    name  = "rds.logical_replication"
    value = "1"
  }

  parameter {
    name  = "wal_level"
    value = "logical"
  }
}

output "ingress_hostname" {
  value = module.platform.ingress_ip
}
```

### GCP Standby Implementation

```hcl
# environments/prod/gcp-standby/main.tf

module "platform" {
  source = "../../../modules/app-platform-gcp"

  environment = "prod"
  app_name    = "myapp"

  db_config = {
    engine         = "POSTGRES_16"
    engine_version = "16"
    instance_class = "db-custom-4-16384"
    storage_gb     = 500
    ha_enabled     = false   # Standby: single-zone to reduce cost
  }

  cluster_config = {
    node_count   = 3         # Fewer nodes than primary
    machine_type = "e2-standard-4"
    k8s_version  = "1.30"
  }
}

# Scale-down: standby runs at reduced capacity
# Promote script scales up node count and enables HA on Cloud SQL

output "ingress_ip" {
  value = module.platform.ingress_ip
}
```

### DNS Failover Layer

```hcl
# environments/prod/dns-failover/main.tf

data "terraform_remote_state" "aws" {
  backend = "s3"
  config = {
    bucket = "myorg-terraform-state"
    key    = "prod/aws-primary/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "gcp" {
  backend = "s3"
  config = {
    bucket = "myorg-terraform-state"
    key    = "prod/gcp-standby/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "cloudflare_dns_record" "primary" {
  zone_id = var.cloudflare_zone_id
  name    = "app"
  type    = "CNAME"
  content = data.terraform_remote_state.aws.outputs.ingress_hostname
  proxied = true
  ttl     = 1
}

# Standby record — not proxied, used by health-check failover
# Cloudflare Load Balancing handles automatic failover
resource "cloudflare_load_balancer_pool" "aws_primary" {
  account_id = var.cloudflare_account_id
  name       = "aws-primary"

  origins {
    name    = "aws-origin"
    address = data.terraform_remote_state.aws.outputs.ingress_hostname
    enabled = true
  }

  notification_email = var.alert_email
}

resource "cloudflare_load_balancer_pool" "gcp_standby" {
  account_id = var.cloudflare_account_id
  name       = "gcp-standby"

  origins {
    name    = "gcp-origin"
    address = data.terraform_remote_state.gcp.outputs.ingress_ip
    enabled = true
  }

  notification_email = var.alert_email
}

resource "cloudflare_load_balancer_monitor" "health" {
  account_id     = var.cloudflare_account_id
  type           = "https"
  expected_codes = "200"
  path           = "/healthz"
  interval       = 60
  timeout        = 5
  retries        = 2
}

resource "cloudflare_load_balancer" "app" {
  zone_id          = var.cloudflare_zone_id
  name             = "app.${var.domain}"
  fallback_pool_id = cloudflare_load_balancer_pool.gcp_standby.id
  default_pool_ids = [cloudflare_load_balancer_pool.aws_primary.id]
  proxied          = true

  # Failover: if AWS health check fails, route to GCP
  pop_pools {}
  region_pools {}
}
```

---

## 4. Shared Services Pattern: Terraform + Cloudflare + Vault

A common cross-cutting pattern: HashiCorp Vault manages secrets for both AWS and GCP workloads, with Cloudflare handling DNS.

```hcl
# providers.tf

provider "vault" {
  address = var.vault_address
}

provider "aws" {
  region = var.aws_region
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "cloudflare" {
  api_token = data.vault_generic_secret.cloudflare.data["api_token"]
}

# Pull secrets from Vault — single source of truth
data "vault_generic_secret" "cloudflare" {
  path = "secret/infra/cloudflare"
}

data "vault_aws_access_credentials" "deploy" {
  backend = "aws"
  role    = "deploy"
  type    = "sts"
}

data "vault_generic_secret" "gcp_sa" {
  path = "secret/infra/gcp/service-account"
}
```

---

## 5. Multi-Cloud Kubernetes: EKS + GKE Federation

Deploy to both EKS and GKE with a shared Helm chart, using provider aliases to target each cluster.

### Provider Aliases for Multiple Clusters

```hcl
# Two Kubernetes providers — one per cloud's cluster

provider "kubernetes" {
  alias = "eks"

  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

provider "kubernetes" {
  alias = "gke"

  host                   = "https://${google_container_cluster.main.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.main.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}

provider "helm" {
  alias = "eks"

  kubernetes {
    host                   = data.aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.main.token
  }
}

provider "helm" {
  alias = "gke"

  kubernetes {
    host                   = "https://${google_container_cluster.main.endpoint}"
    cluster_ca_certificate = base64decode(google_container_cluster.main.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.current.access_token
  }
}
```

### Deploying the Same App to Both Clusters

```hcl
module "app_eks" {
  source = "./modules/app-deploy"

  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }

  app_name    = "myapp"
  namespace   = "myapp"
  image       = var.app_image
  replicas    = var.eks_replicas
  environment = var.environment

  cloud_specific = {
    service_type         = "LoadBalancer"
    storage_class        = "gp3"
    service_account_arn  = module.eks_irsa.role_arn
  }
}

module "app_gke" {
  source = "./modules/app-deploy"

  providers = {
    kubernetes = kubernetes.gke
    helm       = helm.gke
  }

  app_name    = "myapp"
  namespace   = "myapp"
  image       = var.app_image
  replicas    = var.gke_replicas
  environment = var.environment

  cloud_specific = {
    service_type         = "LoadBalancer"
    storage_class        = "premium-rwo"
    service_account_arn  = ""
  }
}
```

---

## 6. Cross-Cloud Networking: VPN/Interconnect

Connect AWS VPC to GCP VPC for private communication between clouds.

### AWS Site-to-Site VPN ↔ GCP Cloud VPN

```hcl
# --- GCP side ---

resource "google_compute_vpn_gateway" "to_aws" {
  name    = "vpn-to-aws"
  network = google_compute_network.main.id
  region  = var.gcp_region
}

resource "google_compute_external_vpn_gateway" "aws" {
  name            = "aws-vpn-gateway"
  redundancy_type = "TWO_IPS_REDUNDANCY"

  interface {
    id         = 0
    ip_address = aws_vpn_connection.to_gcp.tunnel1_address
  }
  interface {
    id         = 1
    ip_address = aws_vpn_connection.to_gcp.tunnel2_address
  }
}

resource "google_compute_ha_vpn_gateway" "to_aws" {
  name    = "ha-vpn-to-aws"
  network = google_compute_network.main.id
  region  = var.gcp_region
}

resource "google_compute_vpn_tunnel" "to_aws_0" {
  name                            = "vpn-to-aws-tunnel-0"
  region                          = var.gcp_region
  vpn_gateway                     = google_compute_ha_vpn_gateway.to_aws.id
  peer_external_gateway           = google_compute_external_vpn_gateway.aws.id
  peer_external_gateway_interface = 0
  shared_secret                   = var.vpn_shared_secret
  router                          = google_compute_router.vpn.id
  vpn_gateway_interface           = 0
  ike_version                     = 2
}

resource "google_compute_vpn_tunnel" "to_aws_1" {
  name                            = "vpn-to-aws-tunnel-1"
  region                          = var.gcp_region
  vpn_gateway                     = google_compute_ha_vpn_gateway.to_aws.id
  peer_external_gateway           = google_compute_external_vpn_gateway.aws.id
  peer_external_gateway_interface = 1
  shared_secret                   = var.vpn_shared_secret
  router                          = google_compute_router.vpn.id
  vpn_gateway_interface           = 1
  ike_version                     = 2
}

resource "google_compute_router" "vpn" {
  name    = "vpn-router"
  network = google_compute_network.main.id
  region  = var.gcp_region

  bgp {
    asn = 65001
  }
}

resource "google_compute_router_interface" "tunnel_0" {
  name       = "vpn-tunnel-0-interface"
  router     = google_compute_router.vpn.name
  region     = var.gcp_region
  ip_range   = "169.254.0.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.to_aws_0.name
}

resource "google_compute_router_peer" "aws_0" {
  name                      = "aws-bgp-peer-0"
  router                    = google_compute_router.vpn.name
  region                    = var.gcp_region
  peer_ip_address           = "169.254.0.2"
  peer_asn                  = 64512
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.tunnel_0.name
}

# --- AWS side ---

resource "aws_vpn_gateway" "main" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "${var.environment}-vpn-gw"
  }
}

resource "aws_customer_gateway" "gcp" {
  bgp_asn    = 65001
  ip_address = google_compute_ha_vpn_gateway.to_aws.vpn_interfaces[0].ip_address
  type       = "ipsec.1"

  tags = {
    Name = "${var.environment}-cgw-gcp"
  }
}

resource "aws_vpn_connection" "to_gcp" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.gcp.id
  type                = "ipsec.1"
  static_routes_only  = false

  tunnel1_preshared_key = var.vpn_shared_secret
  tunnel2_preshared_key = var.vpn_shared_secret

  tags = {
    Name = "${var.environment}-vpn-to-gcp"
  }
}

# Propagate GCP routes into AWS route tables
resource "aws_vpn_gateway_route_propagation" "private" {
  for_each = toset(module.vpc.private_route_table_ids)

  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = each.value
}
```

### CIDR Planning for Multi-Cloud

| Cloud | Environment | CIDR | Purpose |
|:------|:-----------|:-----|:--------|
| AWS | prod | `10.0.0.0/16` | Primary VPC |
| AWS | staging | `10.1.0.0/16` | Staging VPC |
| GCP | prod | `10.100.0.0/16` | DR VPC |
| GCP | staging | `10.101.0.0/16` | DR staging VPC |
| Azure | prod | `10.200.0.0/16` | If needed |
| Link-local | VPN tunnels | `169.254.0.0/16` | BGP peering |

**Critical:** non-overlapping CIDRs across all clouds and environments. Plan this upfront — re-addressing a live network is painful.

---

## 7. Testing Multi-Cloud Configurations

### terraform test with Multiple Mocked Providers

```hcl
# tests/multi_cloud.tftest.hcl

mock_provider "aws" {}
mock_provider "google" {}
mock_provider "cloudflare" {}

variables {
  environment          = "test"
  aws_region           = "us-east-1"
  gcp_project_id       = "test-project"
  gcp_region           = "us-central1"
  cloudflare_account_id = "mock-account"
  domain               = "example.com"
}

run "providers_dont_conflict" {
  command = plan

  assert {
    condition     = length(aws_security_group.alb.id) > 0
    error_message = "AWS security group must be planned"
  }
}

run "dns_points_to_aws_origin" {
  command = plan

  assert {
    condition     = cloudflare_dns_record.app.content == aws_lb.origin.dns_name
    error_message = "Cloudflare DNS must point to the AWS ALB"
  }
}
```

### Terratest: Cross-Cloud Validation

```go
func TestMultiCloudConnectivity(t *testing.T) {
    t.Parallel()

    awsOpts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../environments/test/aws-primary",
    })
    gcpOpts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../environments/test/gcp-standby",
    })

    defer terraform.Destroy(t, awsOpts)
    defer terraform.Destroy(t, gcpOpts)

    // Deploy both clouds
    terraform.InitAndApply(t, awsOpts)
    terraform.InitAndApply(t, gcpOpts)

    awsEndpoint := terraform.Output(t, awsOpts, "ingress_hostname")
    gcpEndpoint := terraform.Output(t, gcpOpts, "ingress_ip")

    // Verify both endpoints respond
    tlsConfig := &tls.Config{}
    http_helper.HttpGetWithRetry(t, fmt.Sprintf("https://%s/healthz", awsEndpoint),
        tlsConfig, 200, "", 30, 10*time.Second)
    http_helper.HttpGetWithRetry(t, fmt.Sprintf("https://%s/healthz", gcpEndpoint),
        tlsConfig, 200, "", 30, 10*time.Second)
}
```

### OPA Policy: Cross-Cloud Consistency

```rego
# policy/multi-cloud/consistent_tags.rego
package multicloud.consistency

import rego.v1

deny contains msg if {
    resource := input.resource_changes[_]
    resource.provider_name == "registry.terraform.io/hashicorp/aws"
    not resource.change.after.tags.Environment

    msg := sprintf("AWS resource '%s' missing Environment tag", [resource.address])
}

deny contains msg if {
    resource := input.resource_changes[_]
    resource.provider_name == "registry.terraform.io/hashicorp/google"
    not resource.change.after.labels.environment

    msg := sprintf("GCP resource '%s' missing environment label", [resource.address])
}
```

---

## 8. CI/CD for Multi-Cloud

### GitHub Actions: Parallel Cloud Deploys

```yaml
# .github/workflows/multi-cloud-deploy.yml
name: Multi-Cloud Deploy

on:
  push:
    branches: [main]
    paths: ['environments/prod/**']

jobs:
  plan-aws:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3

      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ vars.AWS_DEPLOY_ROLE_ARN }}
          aws-region: us-east-1

      - name: Terraform Plan (AWS)
        working-directory: environments/prod/aws-primary
        run: |
          terraform init
          terraform plan -out=tfplan
          terraform show -no-color tfplan > plan-output.txt

      - uses: actions/upload-artifact@v4
        with:
          name: aws-plan
          path: environments/prod/aws-primary/tfplan

  plan-gcp:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3

      - uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: ${{ vars.GCP_WIF_PROVIDER }}
          service_account: ${{ vars.GCP_SA_EMAIL }}

      - name: Terraform Plan (GCP)
        working-directory: environments/prod/gcp-standby
        run: |
          terraform init
          terraform plan -out=tfplan

      - uses: actions/upload-artifact@v4
        with:
          name: gcp-plan
          path: environments/prod/gcp-standby/tfplan

  apply:
    needs: [plan-aws, plan-gcp]
    runs-on: ubuntu-latest
    environment: production    # Requires manual approval
    strategy:
      matrix:
        cloud: [aws-primary, gcp-standby]
      fail-fast: false         # Don't cancel one cloud if the other fails
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3

      - uses: actions/download-artifact@v4
        with:
          name: ${{ matrix.cloud == 'aws-primary' && 'aws-plan' || 'gcp-plan' }}
          path: environments/prod/${{ matrix.cloud }}

      - name: Terraform Apply
        working-directory: environments/prod/${{ matrix.cloud }}
        run: |
          terraform init
          terraform apply -auto-approve tfplan

  deploy-dns:
    needs: [apply]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3

      - name: Update DNS Failover
        working-directory: environments/prod/dns-failover
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
        run: |
          terraform init
          terraform apply -auto-approve
```

### Deploy Order

```
┌───────────────┐     ┌───────────────┐
│  Plan AWS     │     │  Plan GCP     │     Parallel: no dependencies
└───────┬───────┘     └───────┬───────┘
        │                     │
        ▼                     ▼
┌───────────────┐     ┌───────────────┐
│  Apply AWS    │     │  Apply GCP    │     Parallel: fail-fast=false
└───────┬───────┘     └───────┬───────┘
        │                     │
        └──────────┬──────────┘
                   ▼
          ┌────────────────┐
          │  Update DNS    │                 Sequential: depends on both
          └────────────────┘
```

---

## Anti-Patterns

| Anti-Pattern | Why It's Bad | Fix |
|:-------------|:-------------|:----|
| Single state file for all clouds | One cloud's API failure blocks all changes | Separate state per cloud |
| Abstracting away cloud differences into one module | Leaky abstraction; cloud-specific features get hidden or hacked in | Common interface + cloud-specific implementations |
| Sharing provider credentials across clouds | Credential compromise spreads | OIDC federation per cloud, scoped API tokens |
| Using `terraform_remote_state` across cloud boundaries in the same apply | Circular dependency risk, coupled blast radii | Read cross-cloud state in a dedicated coordination layer |
| Hardcoded cloud-specific values in shared modules | Breaks when adding a new cloud | Use variables with validation; let the caller provide cloud-specific config |
| Assuming identical API semantics | e.g., GCP labels ≠ AWS tags (key restrictions differ) | Test per-cloud; validate naming in variables |
