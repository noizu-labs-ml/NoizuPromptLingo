# Platform and Utility Provider Patterns

Patterns for infrastructure, DNS, identity, monitoring, GitOps, database, utility, and NixOS providers. Each section covers when to use, key resources, gotchas, and HCL examples.

---

## Infrastructure Providers

### Kubernetes (`hashicorp/kubernetes`)

**When to use vs Helm/ArgoCD:** Use the Kubernetes provider for foundational resources that must exist before apps deploy (namespaces, RBAC, service accounts, CRDs). Use Helm for application packaging. Use ArgoCD for GitOps-driven continuous delivery. They complement, not replace, each other.

**Critical limitation:** The Kubernetes provider requires a running, reachable cluster at `terraform plan` time. This means you cannot create a cluster and deploy into it in the same `apply` -- split into separate root modules or use `depends_on` with careful staging.

```hcl
provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

# Typed resources: validated at plan time, full schema support
resource "kubernetes_namespace" "app" {
  metadata {
    name = "my-app"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# kubernetes_manifest: arbitrary YAML, no schema validation at plan
# Use for CRDs or resources the provider doesn't have typed support for
resource "kubernetes_manifest" "custom_resource" {
  manifest = yamldecode(file("${path.module}/manifests/my-crd-instance.yaml"))
}
```

**`kubernetes_manifest` vs typed resources:** Prefer typed resources (`kubernetes_namespace`, `kubernetes_deployment`, etc.) -- they validate at plan time, show meaningful diffs, and have proper schema support. Use `kubernetes_manifest` only for CRD instances or resources the provider does not yet cover.

### Helm (`hashicorp/helm`)

```hcl
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.main.token
  }
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.11.3"  # ALWAYS pin the version
  namespace        = "ingress-nginx"
  create_namespace = true

  wait          = true
  wait_for_jobs = true
  timeout       = 600  # seconds

  values = [
    templatefile("${path.module}/values/ingress-nginx.yaml", {
      replica_count = var.environment == "production" ? 3 : 1
    })
  ]

  # Use set_sensitive for secrets -- values won't appear in plan output
  set_sensitive {
    name  = "controller.extraArgs.default-ssl-certificate"
    value = "${var.tls_namespace}/${var.tls_secret_name}"
  }

  set {
    name  = "controller.replicaCount"
    value = var.environment == "production" ? 3 : 1
  }
}
```

**Key rules:**
- **Always pin `version`** -- unpinned charts pull latest on every apply, causing drift.
- **Use `set_sensitive`** for any value containing secrets.
- **Set `wait = true` and `timeout`** to catch failed deployments during apply rather than discovering them later.
- **`create_namespace = true`** is convenient but means Terraform owns the namespace lifecycle.

### Docker (`kreuzwerker/docker`)

```hcl
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"

  # For remote Docker hosts
  # host = "ssh://user@remote-host:22"

  # For registries requiring auth
  registry_auth {
    address  = "ghcr.io"
    username = var.github_user
    password = var.github_token
  }
}

resource "docker_image" "app" {
  name = "ghcr.io/my-org/my-app:${var.image_tag}"

  build {
    context    = "${path.module}/app"
    dockerfile = "Dockerfile"
    tag        = ["ghcr.io/my-org/my-app:${var.image_tag}"]

    build_arg = {
      NODE_ENV = "production"
    }
  }
}

resource "docker_container" "app" {
  name  = "my-app"
  image = docker_image.app.image_id

  ports {
    internal = 3000
    external = 3000
  }

  volumes {
    host_path      = "/data/app"
    container_path = "/app/data"
  }

  networks_advanced {
    name = docker_network.app.id
  }
}

resource "docker_network" "app" {
  name   = "app-network"
  driver = "bridge"
}

resource "docker_volume" "data" {
  name = "app-data"
}
```

Manages containers, images, networks, and volumes. Supports buildx for multi-platform builds. Best for development environments and single-host deployments; for orchestration at scale, use Kubernetes.

### Proxmox (`bpg/proxmox`)

```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70"
    }
  }
}

provider "proxmox" {
  endpoint = "https://proxmox.example.com:8006/"
  username = "terraform@pam"
  password = var.proxmox_password
  insecure = false

  ssh {
    agent    = true
    username = "root"
  }
}

resource "proxmox_virtual_environment_vm" "k8s_node" {
  count     = 3
  name      = "k8s-node-${count.index}"
  node_name = "pve1"

  clone {
    vm_id = 9000  # Template VM ID
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 50
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.1.${10 + count.index}/24"
        gateway = "10.0.1.1"
      }
    }
    user_account {
      keys     = [var.ssh_public_key]
      username = "ubuntu"
    }
  }
}
```

**`bpg/proxmox` vs `Telmate/proxmox`:** The `bpg/proxmox` provider has 111+ resources vs Telmate's 5. It is actively maintained, covers VMs, containers, networking, storage, users, pools, firewalls, and cluster configuration. Use `bpg/proxmox` for all new projects -- Telmate is effectively legacy.

---

## DNS & CDN Providers

### Cloudflare (`cloudflare/cloudflare`)

```hcl
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token  # Scoped token, not global API key
}

# DNS records
resource "cloudflare_dns_record" "app" {
  zone_id = var.cloudflare_zone_id
  name    = "app"
  content = var.origin_ip
  type    = "A"
  proxied = true
  ttl     = 1  # Auto when proxied
}

# Cloudflare Tunnel (replaces exposing origin IP)
resource "cloudflare_zero_trust_tunnel_cloudflared" "main" {
  account_id = var.cloudflare_account_id
  name       = "app-tunnel"
  secret     = random_id.tunnel_secret.b64_std
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "main" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.main.id

  config {
    ingress_rule {
      hostname = "app.example.com"
      service  = "http://localhost:3000"
    }
    ingress_rule {
      service = "http_status:404"  # Catch-all (required)
    }
  }
}

# WAF custom rule
resource "cloudflare_ruleset" "waf" {
  zone_id = var.cloudflare_zone_id
  name    = "Custom WAF Rules"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  rules {
    action      = "block"
    expression  = "(ip.geoip.country eq \"XX\")"
    description = "Block traffic from country XX"
  }
}

# Workers
resource "cloudflare_workers_script" "api_gateway" {
  account_id = var.cloudflare_account_id
  name       = "api-gateway"
  content    = file("${path.module}/workers/gateway.js")
  module     = true
}
```

**v5 migration notes:**
- Resource names changed (e.g., `cloudflare_record` to `cloudflare_dns_record`).
- QUIC is now the default transport for tunnels.
- Zone settings resources restructured.
- Use the official migration tool: `cf-terraform migrate`.

**Key resources:** DNS records, tunnels, WAF rulesets, Workers, Zero Trust access policies, page rules (deprecated -- use rulesets), SSL/TLS settings.

---

## Identity & Security Providers

### Vault (`hashicorp/vault`)

```hcl
provider "vault" {
  address = "https://vault.example.com:8200"
  # Auth via VAULT_TOKEN env var or other auth method
}

# Enable a secrets engine
resource "vault_mount" "kv" {
  path    = "secret"
  type    = "kv-v2"
}

# Dynamic database credentials
resource "vault_database_secrets_mount" "db" {
  path = "database"

  postgresql {
    name           = "prod-db"
    username       = "vault-admin"
    password       = var.db_admin_password
    connection_url = "postgresql://{{username}}:{{password}}@db.example.com:5432/app"
    allowed_roles  = ["app-readonly", "app-readwrite"]
  }
}

resource "vault_database_secret_backend_role" "readonly" {
  name    = "app-readonly"
  backend = vault_database_secrets_mount.db.path
  db_name = "prod-db"

  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
  ]

  default_ttl = "1h"
  max_ttl     = "24h"
}

# PKI secrets engine for internal TLS
resource "vault_mount" "pki" {
  path                  = "pki"
  type                  = "pki"
  max_lease_ttl_seconds = 315360000  # 10 years
}

resource "vault_pki_secret_backend_root_cert" "ca" {
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = "Internal CA"
  ttl         = "87600h"
}

# Auth backend: Kubernetes
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "main" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = var.kubernetes_host
  kubernetes_ca_cert = var.kubernetes_ca_cert
}
```

**Critical rules:**
- **Never use the root token** in provider config for production. Use AppRole, Kubernetes auth, or OIDC.
- **Dynamic credentials** are the primary value prop -- databases, AWS, GCP, Azure all support lease-based creds.
- **PKI** for internal mTLS eliminates manual certificate management.

### Auth0 (`auth0/auth0`)

```hcl
provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_tf_client_id
  client_secret = var.auth0_tf_client_secret
}

resource "auth0_client" "spa" {
  name            = "My SPA"
  app_type        = "spa"
  callbacks       = ["https://app.example.com/callback"]
  allowed_origins = ["https://app.example.com"]

  jwt_configuration {
    alg = "RS256"
  }
}

resource "auth0_connection" "google" {
  name     = "google-oauth2"
  strategy = "google-oauth2"

  options {
    client_id     = var.google_client_id
    client_secret = var.google_client_secret
    scopes        = ["email", "profile"]
  }
}

resource "auth0_action" "enrich_token" {
  name    = "Enrich Access Token"
  runtime = "node18"
  deploy  = true

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }

  code = file("${path.module}/actions/enrich-token.js")
}
```

### Okta (`okta/okta`)

```hcl
provider "okta" {
  org_name  = var.okta_org_name
  base_url  = "okta.com"
  api_token = var.okta_api_token
}

resource "okta_app_oauth" "app" {
  label                     = "My Application"
  type                      = "web"
  grant_types               = ["authorization_code", "refresh_token"]
  redirect_uris             = ["https://app.example.com/callback"]
  post_logout_redirect_uris = ["https://app.example.com"]
  response_types            = ["code"]
}

resource "okta_group" "developers" {
  name        = "Developers"
  description = "Development team"
}

resource "okta_app_group_assignment" "developers" {
  app_id   = okta_app_oauth.app.id
  group_id = okta_group.developers.id
}
```

**Key rule:** Manage Okta via Terraform OR the admin console, not both. Mixed management causes constant drift. Pick one source of truth per resource type.

---

## Monitoring Providers

### Datadog (`DataDog/datadog`)

```hcl
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.datadoghq.com/"  # EU: api.datadoghq.eu
}

# Monitor
resource "datadog_monitor" "high_error_rate" {
  name    = "High Error Rate - ${var.service_name}"
  type    = "query alert"
  message = "Error rate exceeded threshold. @slack-alerts @pagerduty-${var.service_name}"
  query   = "sum(last_5m):sum:trace.http.request.errors{service:${var.service_name}}.as_count() / sum:trace.http.request.hits{service:${var.service_name}}.as_count() > 0.05"

  monitor_thresholds {
    critical = 0.05
    warning  = 0.02
  }

  tags = ["service:${var.service_name}", "env:${var.environment}", "managed-by:terraform"]
}

# Dashboard -- prefer JSON definition for complex dashboards
resource "datadog_dashboard_json" "service" {
  dashboard = file("${path.module}/dashboards/${var.service_name}.json")
}

# SLO
resource "datadog_service_level_objective" "availability" {
  name = "${var.service_name} Availability"
  type = "monitor"

  monitor_ids = [datadog_monitor.high_error_rate.id]

  thresholds {
    timeframe = "30d"
    target    = 99.9
    warning   = 99.95
  }

  tags = ["service:${var.service_name}", "env:${var.environment}"]
}
```

**JSON dashboards vs HCL:** Use `datadog_dashboard_json` for complex dashboards -- export from the UI, check into version control. Use `datadog_dashboard` (HCL) only for simple, templatized dashboards. JSON is more maintainable for anything non-trivial.

**Co-locate monitors with infrastructure:** Define Datadog monitors in the same Terraform module as the infrastructure they monitor. When the service is destroyed, its monitors go with it.

### Grafana (`grafana/grafana`)

```hcl
provider "grafana" {
  url  = "https://grafana.example.com"
  auth = var.grafana_api_key
}

resource "grafana_folder" "services" {
  title = "Services"
}

# Dashboard by UID for stable references
resource "grafana_dashboard" "app" {
  folder      = grafana_folder.services.id
  config_json = file("${path.module}/dashboards/app.json")

  overwrite = true
}

resource "grafana_data_source" "prometheus" {
  name = "Prometheus"
  type = "prometheus"
  url  = "http://prometheus.monitoring.svc.cluster.local:9090"

  json_data_encoded = jsonencode({
    httpMethod   = "POST"
    timeInterval = "15s"
  })
}

# Alerting
resource "grafana_contact_point" "slack" {
  name = "Slack Alerts"

  slack {
    url     = var.slack_webhook_url
    channel = "#alerts"
  }
}

resource "grafana_rule_group" "app_alerts" {
  name             = "App Alerts"
  folder_uid       = grafana_folder.services.uid
  interval_seconds = 60

  rule {
    name      = "High Latency"
    condition = "C"

    data {
      ref_id = "A"
      relative_time_range {
        from = 600
        to   = 0
      }
      datasource_uid = grafana_data_source.prometheus.uid
      model = jsonencode({
        expr = "histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m])) > 2"
      })
    }

    data {
      ref_id = "C"
      relative_time_range {
        from = 0
        to   = 0
      }
      datasource_uid = "__expr__"
      model = jsonencode({
        type       = "threshold"
        conditions = [{ evaluator = { type = "gt", params = [0] } }]
      })
    }
  }
}
```

**Dashboard UIDs:** Always set explicit UIDs in dashboard JSON. Auto-generated UIDs change on re-import, breaking links and bookmarks.

### PagerDuty (`PagerDuty/pagerduty`)

```hcl
provider "pagerduty" {
  token = var.pagerduty_token
}

# Escalation policy (required before creating services)
resource "pagerduty_escalation_policy" "engineering" {
  name      = "Engineering Escalation"
  num_loops = 2

  rule {
    escalation_delay_in_minutes = 10
    target {
      type = "schedule_reference"
      id   = pagerduty_schedule.primary.id
    }
  }

  rule {
    escalation_delay_in_minutes = 15
    target {
      type = "user_reference"
      id   = pagerduty_user.engineering_lead.id
    }
  }
}

# Service: requires exactly 1 escalation policy
resource "pagerduty_service" "app" {
  name              = "My Application"
  escalation_policy = pagerduty_escalation_policy.engineering.id

  alert_creation = "create_alerts_and_incidents"

  incident_urgency_rule {
    type    = "constant"
    urgency = "high"
  }

  auto_resolve_timeout    = "null"  # Don't auto-resolve
  acknowledgement_timeout = 1800    # 30 minutes
}

resource "pagerduty_schedule" "primary" {
  name      = "Primary On-Call"
  time_zone = "America/New_York"

  layer {
    name                         = "Weekly Rotation"
    start                        = "2024-01-01T00:00:00-05:00"
    rotation_virtual_start       = "2024-01-01T00:00:00-05:00"
    rotation_turn_length_seconds = 604800  # 1 week
    users                        = var.oncall_user_ids
  }
}

# Event orchestration for routing and enrichment
resource "pagerduty_event_orchestration" "main" {
  name = "Main Router"
  team = var.team_id
}
```

**Key constraint:** Every PagerDuty service requires exactly one escalation policy. Create policies before services.

---

## GitOps Providers

### GitHub (`integrations/github`)

```hcl
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Prefer GitHub App authentication over PAT
provider "github" {
  owner = "my-org"
  app_auth {
    id              = var.github_app_id
    installation_id = var.github_app_installation_id
    pem_file        = var.github_app_pem
  }
}

resource "github_repository" "service" {
  name        = "my-service"
  description = "My service repository"
  visibility  = "private"

  has_issues   = true
  has_projects = false
  has_wiki     = false

  allow_merge_commit = false
  allow_squash_merge = true
  allow_rebase_merge = false

  delete_branch_on_merge = true

  template {
    owner      = "my-org"
    repository = "service-template"
  }
}

resource "github_branch_protection" "main" {
  repository_id = github_repository.service.node_id
  pattern       = "main"

  required_pull_request_reviews {
    required_approving_review_count = 1
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
  }

  required_status_checks {
    strict   = true
    contexts = ["ci/test", "ci/lint"]
  }

  enforce_admins = true
}

resource "github_team" "backend" {
  name    = "backend"
  privacy = "closed"
}

resource "github_team_repository" "backend_service" {
  team_id    = github_team.backend.id
  repository = github_repository.service.name
  permission = "push"
}

# Actions secrets
resource "github_actions_secret" "deploy_token" {
  repository      = github_repository.service.name
  secret_name     = "DEPLOY_TOKEN"
  plaintext_value = var.deploy_token
}
```

**Prefer GitHub App auth** over personal access tokens. Apps have fine-grained permissions, don't expire like PATs, and aren't tied to individual users.

### GitLab (`gitlabhq/gitlab`)

```hcl
provider "gitlab" {
  token   = var.gitlab_token
  base_url = "https://gitlab.example.com/api/v4"
}

resource "gitlab_project" "service" {
  name             = "my-service"
  namespace_id     = var.group_id
  visibility_level = "private"

  default_branch = "main"

  merge_requests_enabled = true
  issues_enabled         = true
}

# CI/CD variable -- protected and masked
resource "gitlab_project_variable" "api_key" {
  project   = gitlab_project.service.id
  key       = "API_KEY"
  value     = var.api_key
  protected = true   # Only available on protected branches
  masked    = true   # Hidden in job logs
}

# Deploy token for registry access
resource "gitlab_deploy_token" "registry" {
  project  = gitlab_project.service.id
  name     = "registry-token"
  scopes   = ["read_registry"]
}

# Runner configuration
resource "gitlab_runner" "shared" {
  registration_token = var.runner_registration_token
  description        = "Shared Docker Runner"
  tag_list           = ["docker", "linux"]
  run_untagged       = true
  locked             = false
}
```

**Protected + masked variables:** Use `protected = true` to limit secrets to protected branches. Use `masked = true` to hide values in CI job logs. Both should be set for production secrets.

---

## Database Providers

### PostgreSQL (`cyrilgdn/postgresql`)

```hcl
terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.24"
    }
  }
}

provider "postgresql" {
  host     = var.db_host
  port     = 5432
  username = var.db_admin_user
  password = var.db_admin_password
  sslmode  = "require"
}

resource "postgresql_role" "app" {
  name     = "app_user"
  login    = true
  password = random_password.app_db.result
}

resource "postgresql_database" "app" {
  name  = "myapp"
  owner = postgresql_role.app.name

  lc_collate = "en_US.UTF-8"
  lc_ctype   = "en_US.UTF-8"
}

resource "postgresql_schema" "app" {
  name     = "app"
  database = postgresql_database.app.name
  owner    = postgresql_role.app.name
}

# Explicit grants
resource "postgresql_grant" "app_tables" {
  database    = postgresql_database.app.name
  role        = postgresql_role.app.name
  schema      = "app"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

# Default privileges: auto-grant on future tables
resource "postgresql_default_privileges" "app_tables" {
  database    = postgresql_database.app.name
  role        = postgresql_role.app.name
  owner       = postgresql_role.app.name
  schema      = "app"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}
```

**`default_privileges`** is essential -- without it, tables created after the initial grant (e.g., by migrations) won't be accessible to the role.

### MySQL (`petoju/mysql`)

```hcl
terraform {
  required_providers {
    mysql = {
      source  = "petoju/mysql"
      version = "~> 3.0"
    }
  }
}

# Note: petoju/mysql is the community fork. The official hashicorp/mysql
# provider is deprecated and unmaintained. Always use the community fork.

provider "mysql" {
  endpoint = "${var.db_host}:3306"
  username = var.db_admin_user
  password = var.db_admin_password
  tls      = true
}

resource "mysql_database" "app" {
  name                  = "myapp"
  default_character_set = "utf8mb4"
  default_collation     = "utf8mb4_unicode_ci"
}

resource "mysql_user" "app" {
  user               = "app_user"
  host               = "%"
  plaintext_password  = random_password.app_db.result
  tls_option          = "SSL"
}

resource "mysql_grant" "app" {
  user       = mysql_user.app.user
  host       = mysql_user.app.host
  database   = mysql_database.app.name
  privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

# MySQL 8.0+ role support
resource "mysql_role" "readonly" {
  name = "app_readonly"
}

resource "mysql_grant" "readonly_grant" {
  role       = mysql_role.readonly.name
  database   = mysql_database.app.name
  privileges = ["SELECT"]
}
```

---

## Utility Providers

### Random (`hashicorp/random`)

```hcl
# Unique identifier for resource naming (hex string)
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Cryptographic password
resource "random_password" "db" {
  length  = 32
  special = true
  override_special = "!@#$%"  # Limit special chars for compatibility
}

# Human-readable names for dev environments
resource "random_pet" "server" {
  length    = 2
  separator = "-"
}

# Usage
resource "aws_s3_bucket" "data" {
  bucket = "data-${random_id.bucket_suffix.hex}"
}
```

**Values are stored in state.** Changing any input parameter forces a new random value, which cascades to all dependent resources. Plan carefully.

### Null (`hashicorp/null`) and `terraform_data`

```hcl
# LEGACY: null_resource with triggers
resource "null_resource" "run_migrations" {
  triggers = {
    migration_hash = filemd5("${path.module}/migrations/latest.sql")
  }

  provisioner "local-exec" {
    command = "psql -f ${path.module}/migrations/latest.sql"
  }
}

# PREFERRED (Terraform 1.4+): terraform_data replaces null_resource
resource "terraform_data" "run_migrations" {
  triggers_replace = [
    filemd5("${path.module}/migrations/latest.sql")
  ]

  provisioner "local-exec" {
    command = "psql -f ${path.module}/migrations/latest.sql"
  }
}
```

`terraform_data` is a built-in replacement for `null_resource` -- no provider needed, cleaner semantics. Use it for all new code.

### Local (`hashicorp/local`)

```hcl
# Generate a config file from template
resource "local_file" "kubeconfig" {
  content  = templatefile("${path.module}/templates/kubeconfig.tpl", {
    cluster_endpoint = aws_eks_cluster.main.endpoint
    cluster_ca       = aws_eks_cluster.main.certificate_authority[0].data
    cluster_name     = aws_eks_cluster.main.name
  })
  filename = "${path.module}/generated/kubeconfig.yaml"
}

# Sensitive file: restricted permissions, hidden from plan output
resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.main.private_key_pem
  filename        = "${path.module}/generated/key.pem"
  file_permission = "0600"
}
```

### TLS (`hashicorp/tls`)

```hcl
resource "tls_private_key" "ca" {
  algorithm = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem
  subject {
    common_name  = "Dev Internal CA"
    organization = "My Org"
  }
  validity_period_hours = 8760  # 1 year
  is_ca_certificate     = true
  allowed_uses = ["cert_signing", "crl_signing"]
}
```

**For development and testing only.** Never use self-signed certificates in production. Use Vault PKI, Let's Encrypt, or your cloud provider's certificate manager.

### External (`hashicorp/external`)

```hcl
# Calls a script that MUST return JSON to stdout
data "external" "account_info" {
  program = ["python3", "${path.module}/scripts/get-account-info.py"]

  query = {
    account_id = var.account_id
  }
}

# Access results
output "account_name" {
  value = data.external.account_info.result["name"]
}
```

**The script runs on every `terraform plan`**, not just apply. Keep scripts fast and idempotent. The script must return a flat JSON object (string values only) to stdout and exit 0 on success.

### Archive (`hashicorp/archive`)

```hcl
# ZIP a directory for Lambda/Cloud Functions deployment
data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/src/lambda"
  output_path = "${path.module}/build/lambda.zip"
  excludes    = ["__pycache__", "*.pyc", ".env"]
}

resource "aws_lambda_function" "api" {
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  function_name    = "api-handler"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "main.handler"
  runtime          = "python3.12"
}
```

`source_code_hash` ensures Lambda updates when the ZIP contents change, even if the filename stays the same.

---

## NixOS Providers

The NixOS-Terraform ecosystem is functional but fragmented. There is no single dominant approach -- choose based on your deployment model.

### terraform-nixos (`nix-community/terraform-nixos`)

The `deploy_nixos` module deploys a NixOS configuration to a remote machine over SSH.

```hcl
module "server" {
  source = "github.com/nix-community/terraform-nixos//deploy_nixos?ref=master"

  target_host = aws_instance.nixos.public_ip
  target_user = "root"

  nixos_config = "${path.module}/configuration.nix"

  keys = {
    "secret-key" = var.secret_key
  }

  # SSH connection
  ssh_private_key = var.ssh_private_key
  ssh_agent       = false
}
```

Works well for individual machines. Requires the target to already be running NixOS. Handles `nixos-rebuild switch` over SSH with secret injection.

### nixos-anywhere

Installs NixOS on any machine (even non-NixOS) via Terraform. Uses kexec to boot into a NixOS installer from any running Linux, then formats disks and installs.

```hcl
module "nixos_anywhere" {
  source = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"

  nixos_system_attr = ".#nixosConfigurations.server.config.system.build.toplevel"
  nixos_partitioner_attr = ".#nixosConfigurations.server.config.system.build.diskoScript"

  target_host = hcloud_server.main.ipv4_address
  install_user = "root"
  install_ssh_key = var.ssh_private_key
}
```

Best for initial provisioning of bare metal or cloud VMs. Pairs with disko for declarative disk partitioning.

### terranix

Replaces HCL entirely -- write Terraform configuration in Nix.

```nix
# config.nix
{ ... }:
{
  resource.aws_instance.web = {
    ami           = "ami-0c55b159cbfafe1f0";
    instance_type = "t3.micro";
    tags = {
      Name = "web-server";
    };
  };

  resource.aws_s3_bucket.data = {
    bucket = "my-data-bucket";
  };
}
```

```bash
# Generate Terraform JSON and apply
terranix config.nix > config.tf.json
terraform init && terraform apply
```

Terranix generates `config.tf.json` which Terraform consumes natively. Benefits: Nix module system for composition, type checking, functions. Drawbacks: team must know Nix, tooling support (IDE, linters) is limited compared to HCL.

### Assessment

| Approach | Best For | Maturity |
|----------|----------|----------|
| `deploy_nixos` | Deploying to existing NixOS machines | Stable, low maintenance |
| `nixos-anywhere` | Provisioning new machines from scratch | Active development |
| `terranix` | Teams already deep in Nix | Stable, niche |

The ecosystem is functional but fragmented. No single tool covers the full lifecycle. For teams not already invested in Nix, the learning curve is steep relative to the benefits. For Nix-native teams, these tools integrate well with flakes and the broader Nix ecosystem.
