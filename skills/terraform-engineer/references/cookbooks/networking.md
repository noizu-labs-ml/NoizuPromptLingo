# Cookbook: Networking

Practical HCL recipes for VPCs, peering, tunnels, and connectivity across AWS, GCP, Azure, and Cloudflare.

---

## 1. AWS VPC with Public/Private Subnets

Uses the community VPC module with HA NAT gateways (one per AZ), VPC endpoints for S3/DynamoDB cost savings, and subnet tags for EKS discovery.

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # HA NAT: one gateway per AZ (costs ~$32/mo each but avoids cross-AZ traffic)
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  # VPC Flow Logs
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_iam_role             = true
  flow_log_max_aggregation_interval    = 60

  # DNS
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags required for EKS subnet auto-discovery
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# --- VPC Endpoints (Gateway type — free) ---

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      route_table_ids = flatten([
        module.vpc.private_route_table_ids,
        module.vpc.public_route_table_ids,
      ])
      tags = { Name = "${var.environment}-s3-endpoint" }
    }

    dynamodb = {
      service      = "dynamodb"
      service_type = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags = { Name = "${var.environment}-dynamodb-endpoint" }
    }

    # Interface endpoints (cost: ~$7.20/mo per AZ + data processing)
    # Only add these if NAT savings justify the cost
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_endpoints.id]
    }

    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_endpoints.id]
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.environment}-vpc-endpoints-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = {
    Name = "${var.environment}-vpc-endpoints"
  }

  lifecycle {
    create_before_destroy = true
  }
}
```

**Cost note:** Gateway endpoints (S3, DynamoDB) are free. Interface endpoints cost ~$7.20/mo per AZ + $0.01/GB. Compare against NAT Gateway data processing ($0.045/GB) to decide which interface endpoints are worth it.

---

## 2. Hub-and-Spoke Networking (Transit Gateway)

Central hub VPC with shared services, spoke VPCs for workloads. Route table isolation prevents spoke-to-spoke traffic unless explicitly allowed.

```hcl
# --- Transit Gateway (Hub) ---

resource "aws_ec2_transit_gateway" "hub" {
  description                     = "Hub Transit Gateway"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  auto_accept_shared_attachments  = "enable"

  tags = {
    Name = "hub-tgw"
  }
}

# --- Route Tables ---

resource "aws_ec2_transit_gateway_route_table" "shared" {
  transit_gateway_id = aws_ec2_transit_gateway.hub.id
  tags               = { Name = "shared-rt" }
}

resource "aws_ec2_transit_gateway_route_table" "spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.hub.id
  tags               = { Name = "spoke-rt" }
}

# --- Shared Services VPC Attachment ---

resource "aws_ec2_transit_gateway_vpc_attachment" "shared_services" {
  transit_gateway_id = aws_ec2_transit_gateway.hub.id
  vpc_id             = module.shared_vpc.vpc_id
  subnet_ids         = module.shared_vpc.private_subnets

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = { Name = "shared-services-attachment" }
}

resource "aws_ec2_transit_gateway_route_table_association" "shared" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_services.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared.id
}

# --- Spoke VPC Attachments (use for_each for multiple) ---

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  for_each = var.spoke_vpcs

  transit_gateway_id = aws_ec2_transit_gateway.hub.id
  vpc_id             = each.value.vpc_id
  subnet_ids         = each.value.private_subnets

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = { Name = "${each.key}-attachment" }
}

resource "aws_ec2_transit_gateway_route_table_association" "spoke" {
  for_each = var.spoke_vpcs

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

# Spokes can reach shared services
resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_to_shared" {
  for_each = var.spoke_vpcs

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared.id
}

# Shared services can reach all spokes
resource "aws_ec2_transit_gateway_route_table_propagation" "shared_to_spoke" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_services.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

# --- VPC Route Tables: point spoke traffic to TGW ---

resource "aws_route" "spoke_to_tgw" {
  for_each = var.spoke_vpcs

  route_table_id         = each.value.private_route_table_id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.hub.id
}

# --- Variables ---

variable "spoke_vpcs" {
  description = "Map of spoke VPC configs"
  type = map(object({
    vpc_id                 = string
    private_subnets        = list(string)
    private_route_table_id = string
    cidr_block             = string
  }))
}
```

**Key isolation rule:** Spokes only propagate to the `shared` route table, not the `spoke` route table. This means spoke A cannot reach spoke B unless you explicitly add a propagation or static route.

---

## 3. GCP Shared VPC

Host project owns the network, service projects consume subnets. Secondary ranges pre-allocated for GKE pods/services.

```hcl
# --- Host Project ---

resource "google_compute_shared_vpc_host_project" "host" {
  project = var.host_project_id
}

# --- Network in Host Project ---

resource "google_compute_network" "shared" {
  project                 = var.host_project_id
  name                    = "shared-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

# --- Subnets with GKE Secondary Ranges ---

resource "google_compute_subnetwork" "gke" {
  for_each = var.gke_subnets

  project       = var.host_project_id
  name          = each.key
  network       = google_compute_network.shared.id
  region        = each.value.region
  ip_cidr_range = each.value.primary_range

  secondary_ip_range {
    range_name    = "${each.key}-pods"
    ip_cidr_range = each.value.pod_range      # /16 gives 65k IPs for pods
  }

  secondary_ip_range {
    range_name    = "${each.key}-services"
    ip_cidr_range = each.value.service_range   # /20 gives 4k IPs for services
  }

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# --- Service Project Attachment ---

resource "google_compute_shared_vpc_service_project" "service" {
  for_each = toset(var.service_project_ids)

  host_project    = var.host_project_id
  service_project = each.value

  depends_on = [google_compute_shared_vpc_host_project.host]
}

# --- IAM: Allow GKE service accounts to use subnets ---

resource "google_compute_subnetwork_iam_member" "gke_network_user" {
  for_each = {
    for pair in setproduct(keys(var.gke_subnets), var.service_project_ids) :
    "${pair[0]}-${pair[1]}" => {
      subnet  = pair[0]
      project = pair[1]
    }
  }

  project    = var.host_project_id
  region     = var.gke_subnets[each.value.subnet].region
  subnetwork = google_compute_subnetwork.gke[each.value.subnet].name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:service-${data.google_project.service[each.value.project].number}@container-engine-robot.iam.gserviceaccount.com"
}

data "google_project" "service" {
  for_each   = toset(var.service_project_ids)
  project_id = each.value
}

# --- Firewall Rules ---

resource "google_compute_firewall" "allow_internal" {
  project = var.host_project_id
  name    = "allow-internal"
  network = google_compute_network.shared.id

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8"]
}

resource "google_compute_firewall" "allow_health_checks" {
  project = var.host_project_id
  name    = "allow-health-checks"
  network = google_compute_network.shared.id

  allow {
    protocol = "tcp"
  }

  # Google health check ranges
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}

# --- Variables ---

variable "gke_subnets" {
  type = map(object({
    region        = string
    primary_range = string
    pod_range     = string
    service_range = string
  }))
  default = {
    "gke-dev" = {
      region        = "us-central1"
      primary_range = "10.10.0.0/24"
      pod_range     = "10.20.0.0/16"
      service_range = "10.30.0.0/20"
    }
    "gke-prod" = {
      region        = "us-central1"
      primary_range = "10.11.0.0/24"
      pod_range     = "10.40.0.0/16"
      service_range = "10.50.0.0/20"
    }
  }
}
```

**IP planning tip:** Allocate `/16` for pod secondary ranges and `/20` for services. GKE uses ~110 pod IPs per node by default — a `/16` supports ~590 nodes.

---

## 4. Azure Virtual Network

VNet with subnets, NSGs, and VNet peering between hub and spoke.

```hcl
# --- Resource Group ---

resource "azurerm_resource_group" "network" {
  name     = "rg-network-${var.environment}"
  location = var.location
}

# --- Virtual Network ---

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.environment}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = ["10.0.0.0/16"]
}

# --- Subnets ---

resource "azurerm_subnet" "aks_system" {
  name                 = "snet-aks-system"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/22"]   # 1022 IPs for system node pool

  service_endpoints = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault"]
}

resource "azurerm_subnet" "aks_workloads" {
  name                 = "snet-aks-workloads"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.4.0/22"]
}

resource "azurerm_subnet" "databases" {
  name                 = "snet-databases"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.8.0/24"]

  delegation {
    name = "postgresql-delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# --- Network Security Groups ---

resource "azurerm_network_security_group" "aks" {
  name                = "nsg-aks-${var.environment}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "aks_system" {
  subnet_id                 = azurerm_subnet.aks_system.id
  network_security_group_id = azurerm_network_security_group.aks.id
}

# --- VNet Peering (Hub ↔ Spoke) ---

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-${var.environment}"
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.main.id

  allow_forwarded_traffic = true
  allow_gateway_transit   = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "${var.environment}-to-hub"
  resource_group_name       = azurerm_resource_group.network.name
  virtual_network_name      = azurerm_virtual_network.main.name
  remote_virtual_network_id = var.hub_vnet_id

  allow_forwarded_traffic = true
  use_remote_gateways     = true
}
```

**Azure CNI note:** When using Azure CNI for AKS, every pod gets a VNet IP. Size your subnet for `(max_pods_per_node × max_nodes) + reserved`. Default max pods is 30/node, so a 10-node cluster needs 300+ IPs minimum.

---

## 5. Cloudflare Tunnel (Zero Trust)

Deploy a Cloudflare Tunnel via Terraform to expose Kubernetes services without public ingress. Includes access policies for authentication.

```hcl
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# --- Tunnel ---

resource "random_id" "tunnel_secret" {
  byte_length = 32
}

resource "cloudflare_tunnel" "k8s" {
  account_id = var.cloudflare_account_id
  name       = "${var.environment}-k8s-tunnel"
  secret     = random_id.tunnel_secret.b64_std
}

# --- DNS Records ---

resource "cloudflare_record" "tunnel" {
  for_each = var.tunnel_hostnames

  zone_id = var.cloudflare_zone_id
  name    = each.key
  type    = "CNAME"
  content = "${cloudflare_tunnel.k8s.id}.cfargotunnel.com"
  proxied = true
}

# --- Tunnel Config ---

resource "cloudflare_tunnel_config" "k8s" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.k8s.id

  config {
    # Catch-all rule (must be last)
    ingress_rule {
      service = "http_status:404"
    }

    dynamic "ingress_rule" {
      for_each = var.tunnel_hostnames
      content {
        hostname = ingress_rule.key
        service  = ingress_rule.value.service

        dynamic "origin_request" {
          for_each = ingress_rule.value.no_tls_verify ? [1] : []
          content {
            no_tls_verify = true
          }
        }
      }
    }
  }
}

# --- Access Application + Policy ---

resource "cloudflare_access_application" "apps" {
  for_each = { for k, v in var.tunnel_hostnames : k => v if v.protected }

  zone_id          = var.cloudflare_zone_id
  name             = each.key
  domain           = each.key
  session_duration = "24h"
  type             = "self_hosted"
}

resource "cloudflare_access_policy" "email_allow" {
  for_each = { for k, v in var.tunnel_hostnames : k => v if v.protected }

  application_id = cloudflare_access_application.apps[each.key].id
  zone_id        = var.cloudflare_zone_id
  name           = "Allow team emails"
  precedence     = 1
  decision       = "allow"

  include {
    email_domain = var.allowed_email_domains
  }
}

# --- Deploy cloudflared on Kubernetes ---

resource "kubernetes_namespace" "cloudflared" {
  metadata {
    name = "cloudflared"
  }
}

resource "kubernetes_secret" "tunnel_credentials" {
  metadata {
    name      = "tunnel-credentials"
    namespace = kubernetes_namespace.cloudflared.metadata[0].name
  }

  data = {
    "credentials.json" = jsonencode({
      AccountTag   = var.cloudflare_account_id
      TunnelID     = cloudflare_tunnel.k8s.id
      TunnelSecret = random_id.tunnel_secret.b64_std
    })
  }
}

resource "kubernetes_deployment" "cloudflared" {
  metadata {
    name      = "cloudflared"
    namespace = kubernetes_namespace.cloudflared.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "cloudflared"
      }
    }

    template {
      metadata {
        labels = {
          app = "cloudflared"
        }
      }

      spec {
        container {
          name  = "cloudflared"
          image = "cloudflare/cloudflared:latest"
          args  = ["tunnel", "--no-autoupdate", "run", "--token", cloudflare_tunnel.k8s.tunnel_token]

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

# --- Variables ---

variable "tunnel_hostnames" {
  description = "Map of hostname → service config"
  type = map(object({
    service       = string     # e.g. "http://my-service.default.svc.cluster.local:8080"
    protected     = bool       # Wrap in Cloudflare Access?
    no_tls_verify = bool       # Skip origin TLS verification?
  }))
  default = {
    "grafana.example.com" = {
      service       = "http://grafana.monitoring.svc.cluster.local:3000"
      protected     = true
      no_tls_verify = false
    }
    "api.example.com" = {
      service       = "http://api.default.svc.cluster.local:8080"
      protected     = false
      no_tls_verify = false
    }
  }
}

variable "allowed_email_domains" {
  type    = list(string)
  default = ["example.com"]
}
```

**Tunnel token vs credentials file:** The `tunnel_token` approach (shown above) is simpler — no credential file mounting needed. For older setups, mount the `credentials.json` secret and use `--credentials-file` instead.

---

## 6. VPC Endpoints: Interface vs Gateway

Decision guide and cost comparison for choosing between endpoint types.

### Cost Comparison

| Endpoint Type | Hourly Cost | Data Processing | Services |
|:-------------|:-----------|:---------------|:---------|
| Gateway | Free | Free | S3, DynamoDB only |
| Interface | ~$0.01/hr/AZ ($7.20/mo/AZ) | $0.01/GB | ECR, STS, SSM, CloudWatch, etc. |
| NAT Gateway | $0.045/hr ($32.40/mo) | $0.045/GB | All internet traffic |

### Decision Matrix

```
If traffic goes to S3 or DynamoDB → Gateway endpoint (always, it's free)
If traffic goes to AWS service AND >160GB/mo through NAT → Interface endpoint saves money
If traffic goes to AWS service AND <160GB/mo through NAT → NAT is cheaper (avoid endpoint hourly cost)
If traffic goes to the internet → NAT Gateway (endpoints can't help)
```

### Break-Even Calculation

Interface endpoint cost per AZ: $7.20/mo + $0.01/GB
NAT cost for same traffic: $0.045/GB

Break-even: $7.20 / ($0.045 - $0.01) = 205 GB/mo per AZ

If a single service sends >205 GB/mo through NAT in one AZ, the interface endpoint pays for itself.

### Common High-Value Interface Endpoints

```hcl
# These services generate the most NAT traffic in typical K8s clusters:
locals {
  high_value_endpoints = {
    # ECR image pulls — often the biggest NAT cost for K8s
    "ecr.api" = { service = "com.amazonaws.${var.region}.ecr.api" }
    "ecr.dkr" = { service = "com.amazonaws.${var.region}.ecr.dkr" }

    # S3 for ECR layer storage (use Gateway, not Interface!)
    # "s3" handled by Gateway endpoint above

    # STS for IRSA token exchange — high call volume, low data
    "sts" = { service = "com.amazonaws.${var.region}.sts" }

    # CloudWatch Logs — can be high volume in logging-heavy clusters
    "logs" = { service = "com.amazonaws.${var.region}.logs" }

    # SSM for parameter store lookups
    "ssm" = { service = "com.amazonaws.${var.region}.ssm" }
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.high_value_endpoints

  vpc_id              = module.vpc.vpc_id
  service_name        = each.value.service
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.vpc_endpoints.id]

  tags = {
    Name = "${var.environment}-${each.key}-endpoint"
  }
}
```

**Monitoring tip:** Check VPC Flow Logs or NAT Gateway CloudWatch metrics (`BytesOutToDestination` grouped by destination) to identify which AWS services generate the most NAT traffic before adding interface endpoints.
