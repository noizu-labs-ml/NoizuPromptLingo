# Cookbook: Kubernetes

Practical HCL recipes for provisioning managed Kubernetes clusters (EKS, GKE, AKS) and bootstrapping the Day 1 platform stack.

---

## 1. EKS Cluster

Uses the community EKS module v20+ with managed node groups, IRSA, EKS add-ons, and spot instances for workloads.

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.environment}-cluster"
  cluster_version = "1.30"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Public endpoint for kubectl, private for node communication
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # EKS Managed Add-ons
  cluster_addons = {
    coredns = {
      most_recent = true
      configuration_values = jsonencode({
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Exists"
          }
        ]
      })
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"   # More IPs per node
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  # IMPORTANT: Always have at least one managed node group.
  # CoreDNS add-on needs compute during cluster creation.
  eks_managed_node_groups = {
    # System node group — on-demand for reliability
    system = {
      instance_types = ["m6i.large", "m5.large"]
      capacity_type  = "ON_DEMAND"

      min_size     = 2
      max_size     = 4
      desired_size = 2

      labels = {
        role = "system"
      }

      taints = [
        {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
    }

    # Workload node group — spot for cost savings
    workloads = {
      # List 4-6+ instance types for spot diversity
      instance_types = [
        "m6i.xlarge", "m5.xlarge", "m5a.xlarge",
        "m6a.xlarge", "m5n.xlarge", "m5zn.xlarge"
      ]
      capacity_type = "SPOT"

      min_size     = 1
      max_size     = 10
      desired_size = 3

      labels = {
        role = "workloads"
      }

      # Block device for container images/ephemeral storage
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 100
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
    }
  }

  # Cluster access management
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    admin = {
      kubernetes_groups = []
      principal_arn     = var.admin_role_arn
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

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# --- IRSA for VPC CNI ---

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${var.environment}-vpc-cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

# --- IRSA for EBS CSI Driver ---

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${var.environment}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

# --- Outputs ---

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}
```

---

## 2. GKE Autopilot

Google-managed cluster where you pay per pod, not per node. Google handles node provisioning, scaling, security patching, and OS updates.

```hcl
resource "google_container_cluster" "autopilot" {
  name     = "${var.environment}-autopilot"
  location = var.region
  project  = var.project_id

  enable_autopilot = true

  network    = var.network_id
  subnetwork = var.subnetwork_id

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.subnet_name}-pods"
    services_secondary_range_name = "${var.subnet_name}-services"
  }

  # Private cluster — nodes have no public IPs
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false   # Set true for fully private
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  # Control plane authorized networks
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr
        display_name = cidr_blocks.value.name
      }
    }
  }

  # Release channel — Autopilot requires one
  release_channel {
    channel = "REGULAR"   # RAPID for bleeding edge, STABLE for conservative
  }

  # Workload Identity (automatic with Autopilot, but declare for clarity)
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Maintenance window
  maintenance_policy {
    recurring_window {
      start_time = "2024-01-01T04:00:00Z"
      end_time   = "2024-01-01T08:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
    }
  }

  # Binary Authorization
  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  deletion_protection = var.environment == "prod" ? true : false
}

# --- Workload Identity IAM Binding ---

resource "google_service_account" "workload" {
  for_each = var.workload_identities

  account_id   = each.key
  display_name = each.value.description
  project      = var.project_id
}

resource "google_service_account_iam_member" "workload_identity" {
  for_each = var.workload_identities

  service_account_id = google_service_account.workload[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${each.value.namespace}/${each.value.k8s_sa}]"
}

resource "google_project_iam_member" "workload_roles" {
  for_each = {
    for pair in flatten([
      for sa_key, sa_val in var.workload_identities : [
        for role in sa_val.roles : {
          key  = "${sa_key}-${role}"
          sa   = sa_key
          role = role
        }
      ]
    ]) : pair.key => pair
  }

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.workload[each.value.sa].email}"
}

# --- Variables ---

variable "workload_identities" {
  type = map(object({
    description = string
    namespace   = string
    k8s_sa      = string
    roles       = list(string)
  }))
  default = {
    "app-backend" = {
      description = "Backend application"
      namespace   = "default"
      k8s_sa      = "backend-sa"
      roles       = ["roles/cloudsql.client", "roles/storage.objectViewer"]
    }
  }
}
```

**Autopilot vs Standard:** Use Autopilot when you want zero node management and predictable per-pod pricing. Use Standard when you need GPUs, custom machine types, DaemonSets on every node, or fine-grained node configuration.

---

## 3. AKS Cluster

Azure Kubernetes Service with system + workload node pools, Azure CNI, workload identity, and optional spot pools.

```hcl
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.environment}"
  kubernetes_version  = var.kubernetes_version

  # System node pool (required, runs kube-system)
  default_node_pool {
    name                = "system"
    vm_size             = "Standard_D4s_v5"
    vnet_subnet_id      = var.system_subnet_id
    min_count           = 2
    max_count           = 4
    auto_scaling_enabled = true
    os_disk_size_gb     = 128
    os_disk_type        = "Managed"

    only_critical_addons_enabled = true   # Taint: CriticalAddonsOnly

    node_labels = {
      "nodepool-type" = "system"
    }
  }

  # Azure CNI — every pod gets a VNet IP
  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    service_cidr      = "10.100.0.0/16"
    dns_service_ip    = "10.100.0.10"
    load_balancer_sku = "standard"

    load_balancer_profile {
      managed_outbound_ip_count = 2
    }
  }

  # Workload Identity
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Azure AD integration
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = var.tenant_id
  }

  identity {
    type = "SystemAssigned"
  }

  # Monitoring
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  maintenance_window {
    allowed {
      day   = "Saturday"
      hours = [0, 1, 2, 3, 4]
    }
  }

  tags = {
    Environment = var.environment
  }
}

# --- Workload Node Pool ---

resource "azurerm_kubernetes_cluster_node_pool" "workloads" {
  name                  = "workloads"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_D4s_v5"
  vnet_subnet_id        = var.workload_subnet_id

  auto_scaling_enabled = true
  min_count            = 1
  max_count            = 10

  os_disk_size_gb = 128
  os_disk_type    = "Managed"

  node_labels = {
    "nodepool-type" = "workloads"
  }

  tags = {
    Environment = var.environment
  }
}

# --- Spot Node Pool (optional, for batch/CI) ---

resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_D4s_v5"
  vnet_subnet_id        = var.workload_subnet_id
  priority              = "Spot"
  eviction_policy       = "Delete"
  spot_max_price        = -1   # Pay up to on-demand price

  auto_scaling_enabled = true
  min_count            = 0
  max_count            = 20

  node_labels = {
    "kubernetes.azure.com/scalesetpriority" = "spot"
  }

  node_taints = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]

  tags = {
    Environment = var.environment
  }
}

# --- Workload Identity: Federated Credential ---

resource "azurerm_user_assigned_identity" "app" {
  name                = "id-app-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_federated_identity_credential" "app" {
  name                = "fed-app-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  parent_id           = azurerm_user_assigned_identity.app.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.main.oidc_issuer_url
  subject             = "system:serviceaccount:default:app-sa"
}
```

**Azure CNI IP planning:** With Azure CNI, every pod consumes a VNet IP. Formula: `(max_pods_per_node × max_nodes) + nodes + 5_reserved`. Default max_pods is 30. For 10 nodes: `(30 × 10) + 10 + 5 = 315` IPs minimum. Use a `/22` (1022 IPs) for headroom.

---

## 4. ArgoCD Bootstrap

Install ArgoCD via Helm, then deploy an app-of-apps pattern that manages everything else in the cluster.

```hcl
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.3.4"
  namespace        = "argocd"
  create_namespace = true

  # Wait for CRDs to be ready
  wait          = true
  wait_for_jobs = true
  timeout       = 600

  values = [
    yamlencode({
      server = {
        ingress = {
          enabled = var.enable_ingress
          hosts   = [var.argocd_hostname]
          tls = [{
            secretName = "argocd-tls"
            hosts      = [var.argocd_hostname]
          }]
        }
        extraArgs = ["--insecure"]   # TLS terminated at ingress
      }

      configs = {
        params = {
          "server.insecure" = true
        }
        repositories = {
          private-repo = {
            url      = var.gitops_repo_url
            password = var.github_token
            username = "git"
          }
        }
      }

      controller = {
        resources = {
          requests = { cpu = "250m", memory = "512Mi" }
          limits   = { cpu = "1",    memory = "1Gi" }
        }
      }

      redis = {
        resources = {
          requests = { cpu = "100m", memory = "128Mi" }
          limits   = { cpu = "200m", memory = "256Mi" }
        }
      }
    })
  ]
}

# --- App of Apps ---
# This is the root Application that discovers and deploys everything else

resource "kubectl_manifest" "app_of_apps" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "app-of-apps"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.gitops_repo_url
        targetRevision = var.gitops_branch
        path           = "apps"   # Directory containing Application manifests
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true",
          "PrunePropagationPolicy=foreground",
        ]
      }
    }
  })

  depends_on = [helm_release.argocd]
}
```

**Required provider:** The `kubectl_manifest` resource comes from `alekc/kubectl` (or `gavinbunney/kubectl`). Add it to your `required_providers`:

```hcl
terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
  }
}
```

---

## 5. cert-manager + Let's Encrypt

Install cert-manager via Helm, then create ClusterIssuers for staging and production. DNS01 solver for wildcard certificates.

```hcl
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.15.1"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "crds.enabled"
    value = "true"
  }

  # For AWS DNS01 solver — enable IRSA
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cert_manager_irsa.iam_role_arn
  }

  wait = true
}

# --- IRSA for cert-manager (Route53 access) ---

module "cert_manager_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                     = "${var.environment}-cert-manager"
  attach_cert_manager_policy    = true
  cert_manager_hosted_zone_arns = [var.route53_zone_arn]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }
}

# --- ClusterIssuer: Staging (test first!) ---

resource "kubectl_manifest" "letsencrypt_staging" {
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-staging"
    }
    spec = {
      acme = {
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        email  = var.acme_email
        privateKeySecretRef = {
          name = "letsencrypt-staging-key"
        }
        solvers = [
          {
            dns01 = {
              route53 = {
                region       = var.region
                hostedZoneID = var.route53_zone_id
              }
            }
            selector = {
              dnsZones = [var.domain]
            }
          }
        ]
      }
    }
  })

  depends_on = [helm_release.cert_manager]
}

# --- ClusterIssuer: Production ---

resource "kubectl_manifest" "letsencrypt_prod" {
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.acme_email
        privateKeySecretRef = {
          name = "letsencrypt-prod-key"
        }
        solvers = [
          {
            dns01 = {
              route53 = {
                region       = var.region
                hostedZoneID = var.route53_zone_id
              }
            }
            selector = {
              dnsZones = [var.domain]
            }
          }
        ]
      }
    }
  })

  depends_on = [helm_release.cert_manager]
}

# --- Wildcard Certificate ---

resource "kubectl_manifest" "wildcard_cert" {
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "wildcard-${replace(var.domain, ".", "-")}"
      namespace = "default"
    }
    spec = {
      secretName = "wildcard-${replace(var.domain, ".", "-")}-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        var.domain,
        "*.${var.domain}",
      ]
    }
  })

  depends_on = [kubectl_manifest.letsencrypt_prod]
}
```

**Always test with staging first.** Let's Encrypt production has strict rate limits (50 certs/domain/week). The staging server has much higher limits and issues untrusted certs for testing.

**DNS01 vs HTTP01:** DNS01 is required for wildcard certificates. HTTP01 is simpler (no DNS provider access needed) but only works for specific hostnames. Use DNS01 if you need `*.example.com`.

---

## 6. Prometheus + Grafana (kube-prometheus-stack)

Full monitoring stack with persistent storage and sensible defaults.

```hcl
resource "helm_release" "kube_prometheus_stack" {
  name             = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "61.3.0"
  namespace        = "monitoring"
  create_namespace = true

  timeout = 900   # CRDs take a while

  values = [
    yamlencode({
      # --- Prometheus ---
      prometheus = {
        prometheusSpec = {
          retention         = "30d"
          retentionSize     = "45GB"
          replicas          = 1   # 2 for HA
          scrapeInterval    = "30s"
          evaluationInterval = "30s"

          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = var.storage_class
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "50Gi"
                  }
                }
              }
            }
          }

          resources = {
            requests = { cpu = "500m", memory = "2Gi" }
            limits   = { memory = "4Gi" }
          }

          # Pod monitors and service monitors from all namespaces
          podMonitorSelectorNilUsesHelmValues     = false
          serviceMonitorSelectorNilUsesHelmValues = false
          ruleSelectorNilUsesHelmValues            = false
        }
      }

      # --- Alertmanager ---
      alertmanager = {
        alertmanagerSpec = {
          storage = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = var.storage_class
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "10Gi"
                  }
                }
              }
            }
          }
        }

        config = {
          route = {
            receiver       = "slack"
            group_by       = ["alertname", "namespace"]
            group_wait     = "30s"
            group_interval = "5m"
            repeat_interval = "4h"
          }
          receivers = [
            {
              name = "slack"
              slack_configs = [{
                api_url  = var.slack_webhook_url
                channel  = "#alerts"
                title    = "{{ .GroupLabels.alertname }}"
                text     = "{{ range .Alerts }}{{ .Annotations.description }}\n{{ end }}"
              }]
            }
          ]
        }
      }

      # --- Grafana ---
      grafana = {
        adminPassword = var.grafana_admin_password

        persistence = {
          enabled          = true
          storageClassName = var.storage_class
          size             = "10Gi"
        }

        ingress = {
          enabled = var.enable_ingress
          hosts   = [var.grafana_hostname]
          tls = [{
            secretName = "grafana-tls"
            hosts      = [var.grafana_hostname]
          }]
        }

        # Additional data sources
        additionalDataSources = var.additional_datasources

        resources = {
          requests = { cpu = "100m", memory = "256Mi" }
          limits   = { memory = "512Mi" }
        }

        sidecar = {
          dashboards = {
            enabled         = true
            searchNamespace = "ALL"
          }
        }
      }

      # --- Node Exporter ---
      nodeExporter = {
        enabled = true
      }

      # --- kube-state-metrics ---
      kubeStateMetrics = {
        enabled = true
      }
    })
  ]
}

# --- Custom ServiceMonitor for application metrics ---

resource "kubectl_manifest" "app_service_monitor" {
  yaml_body = yamlencode({
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "app-metrics"
      namespace = "monitoring"
      labels = {
        release = "monitoring"
      }
    }
    spec = {
      namespaceSelector = {
        matchNames = ["default", "apps"]
      }
      selector = {
        matchLabels = {
          "app.kubernetes.io/monitored" = "true"
        }
      }
      endpoints = [{
        port     = "metrics"
        interval = "30s"
        path     = "/metrics"
      }]
    }
  })

  depends_on = [helm_release.kube_prometheus_stack]
}
```

---

## 7. Day 0/1 vs Day 2 — Decision Table

What belongs in Terraform vs what belongs in Helm/ArgoCD/Flux?

### Decision Matrix

| Resource | Terraform (Day 0/1) | GitOps/Helm (Day 2) | Rationale |
|:---------|:-------------------:|:--------------------:|:----------|
| Cloud provider infra (VPC, IAM, DNS) | Yes | -- | Cloud API, not K8s API |
| K8s cluster itself | Yes | -- | Must exist before anything else |
| Namespaces (core) | Yes | -- | Bootstrap, needed by Helm releases |
| Namespaces (app) | -- | Yes | App teams own these |
| cert-manager install | Yes | -- | Platform prerequisite |
| ClusterIssuers | Yes | -- | Cluster-wide policy |
| Certificates | -- | Yes | Per-app concern |
| ArgoCD install | Yes | -- | Bootstrap the GitOps engine |
| ArgoCD Applications | -- | Yes | Self-managed via app-of-apps |
| Monitoring stack install | Either | Either | See below |
| ServiceMonitors | -- | Yes | Per-app concern |
| Application Deployments | Never | Yes | Too dynamic for Terraform |
| CRDs | Either | Either | See below |
| Secrets (cloud) | Yes | -- | AWS Secrets Manager, etc. |
| Secrets (K8s) | -- | Yes | External Secrets Operator |
| Storage classes | Yes | -- | Cluster infrastructure |
| Ingress controller | Yes | -- | Platform prerequisite |
| Ingress resources | -- | Yes | Per-app concern |

### Rules of Thumb

1. **If it must exist before the cluster is usable** → Terraform
2. **If application teams manage it** → GitOps
3. **If it changes frequently** → GitOps (Terraform state churn is expensive)
4. **If it spans cloud + K8s** (e.g., IAM role + ServiceAccount) → Terraform for cloud, GitOps for K8s, with outputs bridging them
5. **If destroying it would be catastrophic** → Terraform with `prevent_destroy`

### The Handoff Pattern

```
Terraform (Day 0/1)              ArgoCD (Day 2)
├── VPC / Networking             ├── Application deployments
├── EKS / GKE / AKS             ├── Application configs
├── IAM / Service Accounts       ├── Certificates
├── DNS zones                    ├── Ingress resources
├── ArgoCD (bootstrap)           ├── CronJobs
├── cert-manager (bootstrap)     ├── HPA / VPA
├── monitoring (bootstrap)       ├── ServiceMonitors
├── ingress-nginx (bootstrap)    └── Dashboards (ConfigMaps)
├── external-secrets (bootstrap)
└── StorageClasses
         │
         │  outputs: cluster endpoint, OIDC ARN,
         │           IAM role ARNs, DNS zone IDs
         ▼
    GitOps repo consumes these as
    Helm values or Kustomize patches
```

**Anti-pattern:** Managing Kubernetes Deployments in Terraform. The Kubernetes provider creates a tight coupling between `terraform apply` and app deploys. Use Terraform for infrastructure, GitOps for applications.
