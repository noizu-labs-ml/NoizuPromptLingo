# Cookbook: Databases

Practical HCL recipes for managed databases (RDS/Aurora, Cloud SQL, Azure PostgreSQL) and self-managed PostgreSQL role/grant management.

---

## 1. RDS Aurora (PostgreSQL)

Uses the community module for Aurora Serverless v2 with multi-AZ, parameter groups, and CloudWatch log export.

```hcl
module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 9.0"

  name            = "${var.environment}-aurora"
  engine          = "aurora-postgresql"
  engine_version  = "16.1"
  master_username = "postgres"

  # Serverless v2 scaling
  serverlessv2_scaling_configuration = {
    min_capacity = 0.5    # Scales to zero-ish (0.5 ACU minimum)
    max_capacity = 16.0
  }

  instance_class = "db.serverless"
  instances = {
    writer = {}
    reader = {
      promotion_tier = 1
    }
  }

  # Networking
  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = aws_db_subnet_group.aurora.name
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }

  # Storage encryption
  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  # Backup
  backup_retention_period      = 35    # Max for Aurora
  preferred_backup_window      = "03:00-04:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"
  copy_tags_to_snapshot        = true

  # Monitoring
  enabled_cloudwatch_logs_exports = ["postgresql"]
  monitoring_interval             = 60
  create_monitoring_role          = true

  # Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # Parameter groups
  create_db_cluster_parameter_group = true
  db_cluster_parameter_group_family = "aurora-postgresql16"
  db_cluster_parameter_group_parameters = [
    {
      name         = "log_min_duration_statement"
      value        = "1000"
      apply_method = "immediate"
    },
    {
      name         = "shared_preload_libraries"
      value        = "pg_stat_statements"
      apply_method = "pending-reboot"
    },
    {
      name         = "log_statement"
      value        = "ddl"
      apply_method = "immediate"
    },
  ]

  # Deletion protection
  deletion_protection = true
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.environment}-aurora-final-${formatdate("YYYY-MM-DD", timestamp())}"

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }

  # CRITICAL: Prevent accidental destruction
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_db_subnet_group" "aurora" {
  name       = "${var.environment}-aurora"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "${var.environment}-aurora"
  }
}

# --- Outputs ---

output "aurora_cluster_endpoint" {
  value = module.aurora.cluster_endpoint
}

output "aurora_reader_endpoint" {
  value = module.aurora.cluster_reader_endpoint
}

output "aurora_cluster_port" {
  value = module.aurora.cluster_port
}
```

---

## 2. Cloud SQL (GCP)

PostgreSQL on GCP with private IP, HA, point-in-time recovery, and deletion protection.

```hcl
# --- Private Services Access (required for private IP) ---

resource "google_compute_global_address" "private_ip_range" {
  project       = var.project_id
  name          = "cloudsql-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  network       = var.network_id
}

resource "google_service_networking_connection" "private_vpc" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}

# --- Cloud SQL Instance ---

resource "google_sql_database_instance" "main" {
  project             = var.project_id
  name                = "${var.environment}-postgres"
  database_version    = "POSTGRES_16"
  region              = var.region
  deletion_protection = true

  depends_on = [google_service_networking_connection.private_vpc]

  settings {
    tier              = var.environment == "prod" ? "db-custom-4-16384" : "db-custom-2-8192"
    availability_type = var.environment == "prod" ? "REGIONAL" : "ZONAL"   # REGIONAL = HA
    disk_size         = 50
    disk_type         = "PD_SSD"
    disk_autoresize   = true

    ip_configuration {
      ipv4_enabled    = false   # No public IP
      private_network = var.network_id
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "03:00"
      transaction_log_retention_days = 7

      backup_retention_settings {
        retained_backups = 30
        retention_unit   = "COUNT"
      }
    }

    maintenance_window {
      day          = 7   # Sunday
      hour         = 4
      update_track = "stable"
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 4500
      record_application_tags = true
      record_client_address   = true
    }

    database_flags {
      name  = "log_min_duration_statement"
      value = "1000"
    }

    database_flags {
      name  = "log_statement"
      value = "ddl"
    }

    database_flags {
      name  = "max_connections"
      value = var.environment == "prod" ? "200" : "100"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

# --- Databases ---

resource "google_sql_database" "databases" {
  for_each = toset(var.database_names)

  project  = var.project_id
  instance = google_sql_database_instance.main.name
  name     = each.value
}

# --- Users ---

resource "random_password" "db_passwords" {
  for_each = toset(var.database_names)
  length   = 32
  special  = false
}

resource "google_sql_user" "app_users" {
  for_each = toset(var.database_names)

  project  = var.project_id
  instance = google_sql_database_instance.main.name
  name     = "${each.value}_app"
  password = random_password.db_passwords[each.value].result
}

# --- Outputs ---

output "connection_name" {
  value = google_sql_database_instance.main.connection_name
}

output "private_ip" {
  value = google_sql_database_instance.main.private_ip_address
}
```

**HA note:** `REGIONAL` availability doubles cost but provides automatic failover with ~30s downtime. Always use REGIONAL for production.

---

## 3. Azure Database for PostgreSQL Flexible Server

Private networking via delegated subnet, geo-redundant backup, and maintenance windows.

```hcl
# --- Private DNS Zone ---

resource "azurerm_private_dns_zone" "postgres" {
  name                = "${var.environment}.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.data.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "postgres-vnet-link"
  resource_group_name   = azurerm_resource_group.data.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = var.vnet_id
}

# --- Flexible Server ---

resource "azurerm_postgresql_flexible_server" "main" {
  name                          = "psql-${var.environment}"
  resource_group_name           = azurerm_resource_group.data.name
  location                      = azurerm_resource_group.data.location
  version                       = "16"
  administrator_login           = "psqladmin"
  administrator_password        = var.admin_password
  delegated_subnet_id           = var.database_subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres.id
  sku_name                      = var.environment == "prod" ? "GP_Standard_D4s_v3" : "B_Standard_B2s"
  storage_mb                    = 65536
  storage_tier                  = "P30"
  zone                          = "1"

  # HA
  high_availability {
    mode                      = var.environment == "prod" ? "ZoneRedundant" : "SameZone"
    standby_availability_zone = "2"
  }

  # Backup
  backup_retention_days        = 35
  geo_redundant_backup_enabled = var.environment == "prod" ? true : false

  maintenance_window {
    day_of_week  = 0    # Sunday
    start_hour   = 4
    start_minute = 0
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]

  lifecycle {
    prevent_destroy = true
  }
}

# --- Server Configuration ---

resource "azurerm_postgresql_flexible_server_configuration" "configs" {
  for_each = {
    "log_min_duration_statement" = "1000"
    "shared_preload_libraries"  = "pg_stat_statements"
    "pg_stat_statements.track"  = "all"
    "log_statement"             = "ddl"
  }

  server_id = azurerm_postgresql_flexible_server.main.id
  name      = each.key
  value     = each.value
}

# --- Databases ---

resource "azurerm_postgresql_flexible_server_database" "databases" {
  for_each  = toset(var.database_names)
  name      = each.value
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# --- Firewall: Allow Azure services (for dev only) ---

resource "azurerm_postgresql_flexible_server_firewall_rule" "azure_services" {
  count = var.environment == "dev" ? 1 : 0

  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
```

---

## 4. Self-Managed PostgreSQL (Roles, Databases, Grants)

Use the `cyrilgdn/postgresql` provider to manage roles, databases, schemas, and fine-grained grants on any PostgreSQL instance. Implements the three-role-per-database pattern: admin, app, readonly.

```hcl
terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.22"
    }
  }
}

provider "postgresql" {
  host     = var.postgres_host
  port     = var.postgres_port
  username = var.postgres_admin_user
  password = var.postgres_admin_password
  sslmode  = "require"

  # Superuser required for CREATE ROLE and ALTER DEFAULT PRIVILEGES
  superuser = false
}

# --- Three-Role-Per-Database Pattern ---
# admin: DDL (migrations), owns the schema
# app: DML (application), SELECT/INSERT/UPDATE/DELETE
# readonly: SELECT only (dashboards, analytics)

locals {
  databases = {
    "myapp" = {
      schemas = ["public", "analytics"]
    }
    "billing" = {
      schemas = ["public"]
    }
  }
}

# --- Roles ---

resource "postgresql_role" "admin" {
  for_each = local.databases

  name     = "${each.key}_admin"
  login    = true
  password = var.db_passwords["${each.key}_admin"]

  lifecycle {
    prevent_destroy = true
  }
}

resource "postgresql_role" "app" {
  for_each = local.databases

  name     = "${each.key}_app"
  login    = true
  password = var.db_passwords["${each.key}_app"]
}

resource "postgresql_role" "readonly" {
  for_each = local.databases

  name     = "${each.key}_readonly"
  login    = true
  password = var.db_passwords["${each.key}_readonly"]
}

# --- Databases ---

resource "postgresql_database" "main" {
  for_each = local.databases

  name  = each.key
  owner = postgresql_role.admin[each.key].name

  lc_collate = "en_US.UTF-8"
  lc_ctype   = "en_US.UTF-8"

  lifecycle {
    prevent_destroy = true
  }
}

# --- Schemas ---

resource "postgresql_schema" "schemas" {
  for_each = {
    for pair in flatten([
      for db_name, db_config in local.databases : [
        for schema in db_config.schemas : {
          key    = "${db_name}.${schema}"
          db     = db_name
          schema = schema
        } if schema != "public"
      ]
    ]) : pair.key => pair
  }

  database = each.value.db
  name     = each.value.schema
  owner    = postgresql_role.admin[each.value.db].name

  depends_on = [postgresql_database.main]
}

# --- Grants: App Role ---

resource "postgresql_grant" "app_usage" {
  for_each = {
    for pair in flatten([
      for db_name, db_config in local.databases : [
        for schema in db_config.schemas : {
          key    = "${db_name}.${schema}"
          db     = db_name
          schema = schema
        }
      ]
    ]) : pair.key => pair
  }

  database    = each.value.db
  role        = postgresql_role.app[each.value.db].name
  schema      = each.value.schema
  object_type = "schema"
  privileges  = ["USAGE"]
}

resource "postgresql_grant" "app_tables" {
  for_each = {
    for pair in flatten([
      for db_name, db_config in local.databases : [
        for schema in db_config.schemas : {
          key    = "${db_name}.${schema}"
          db     = db_name
          schema = schema
        }
      ]
    ]) : pair.key => pair
  }

  database    = each.value.db
  role        = postgresql_role.app[each.value.db].name
  schema      = each.value.schema
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

resource "postgresql_grant" "app_sequences" {
  for_each = {
    for pair in flatten([
      for db_name, db_config in local.databases : [
        for schema in db_config.schemas : {
          key    = "${db_name}.${schema}"
          db     = db_name
          schema = schema
        }
      ]
    ]) : pair.key => pair
  }

  database    = each.value.db
  role        = postgresql_role.app[each.value.db].name
  schema      = each.value.schema
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT"]
}

# --- Default Privileges (for future tables created by admin) ---

resource "postgresql_default_privileges" "app_tables" {
  for_each = {
    for pair in flatten([
      for db_name, db_config in local.databases : [
        for schema in db_config.schemas : {
          key    = "${db_name}.${schema}"
          db     = db_name
          schema = schema
        }
      ]
    ]) : pair.key => pair
  }

  database    = each.value.db
  role        = postgresql_role.app[each.value.db].name
  owner       = postgresql_role.admin[each.value.db].name
  schema      = each.value.schema
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

resource "postgresql_default_privileges" "app_sequences" {
  for_each = {
    for pair in flatten([
      for db_name, db_config in local.databases : [
        for schema in db_config.schemas : {
          key    = "${db_name}.${schema}"
          db     = db_name
          schema = schema
        }
      ]
    ]) : pair.key => pair
  }

  database    = each.value.db
  role        = postgresql_role.app[each.value.db].name
  owner       = postgresql_role.admin[each.value.db].name
  schema      = each.value.schema
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT"]
}

# --- Grants: Readonly Role ---

resource "postgresql_grant" "readonly_usage" {
  for_each = {
    for pair in flatten([
      for db_name, db_config in local.databases : [
        for schema in db_config.schemas : {
          key    = "${db_name}.${schema}"
          db     = db_name
          schema = schema
        }
      ]
    ]) : pair.key => pair
  }

  database    = each.value.db
  role        = postgresql_role.readonly[each.value.db].name
  schema      = each.value.schema
  object_type = "schema"
  privileges  = ["USAGE"]
}

resource "postgresql_grant" "readonly_tables" {
  for_each = {
    for pair in flatten([
      for db_name, db_config in local.databases : [
        for schema in db_config.schemas : {
          key    = "${db_name}.${schema}"
          db     = db_name
          schema = schema
        }
      ]
    ]) : pair.key => pair
  }

  database    = each.value.db
  role        = postgresql_role.readonly[each.value.db].name
  schema      = each.value.schema
  object_type = "table"
  privileges  = ["SELECT"]
}

resource "postgresql_default_privileges" "readonly_tables" {
  for_each = {
    for pair in flatten([
      for db_name, db_config in local.databases : [
        for schema in db_config.schemas : {
          key    = "${db_name}.${schema}"
          db     = db_name
          schema = schema
        }
      ]
    ]) : pair.key => pair
  }

  database    = each.value.db
  role        = postgresql_role.readonly[each.value.db].name
  owner       = postgresql_role.admin[each.value.db].name
  schema      = each.value.schema
  object_type = "table"
  privileges  = ["SELECT"]
}
```

**Why three roles?** Least privilege. Migrations run as `admin` (can CREATE/ALTER/DROP tables). The application connects as `app` (can only read/write data). Dashboards use `readonly` (can only SELECT). A compromised app connection cannot drop tables.

---

## 5. Database Backup Patterns

### Cross-Region Read Replica (RDS)

```hcl
# Primary in us-east-1 (managed by aurora module above)
# Cross-region replica in us-west-2

resource "aws_rds_cluster" "replica" {
  provider = aws.us_west_2

  cluster_identifier            = "${var.environment}-aurora-replica"
  engine                        = "aurora-postgresql"
  engine_version                = "16.1"
  replication_source_identifier = module.aurora.cluster_arn

  db_subnet_group_name   = aws_db_subnet_group.replica.name
  vpc_security_group_ids = [aws_security_group.aurora_replica.id]

  storage_encrypted = true
  kms_key_id        = var.replica_kms_key_arn   # Must be in replica region

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [replication_source_identifier]
  }
}

resource "aws_rds_cluster_instance" "replica" {
  provider = aws.us_west_2

  identifier         = "${var.environment}-aurora-replica-1"
  cluster_identifier = aws_rds_cluster.replica.id
  instance_class     = "db.serverless"
  engine             = "aurora-postgresql"
}
```

### Automated Snapshot Copy (Cross-Region)

```hcl
# Copy automated snapshots to another region for DR
resource "aws_db_event_subscription" "backup_notification" {
  name             = "${var.environment}-backup-events"
  sns_topic        = aws_sns_topic.db_events.arn
  source_type      = "db-cluster"
  source_ids       = [module.aurora.cluster_id]
  event_categories = ["backup"]
}

# Use Lambda + EventBridge to trigger cross-region snapshot copy
# (Aurora doesn't natively support cross-region automated snapshot copy)
```

### Cloud SQL Export to GCS

```hcl
# Automated export via Cloud Scheduler + Cloud Function
resource "google_cloud_scheduler_job" "db_export" {
  name     = "db-export-${var.environment}"
  schedule = "0 4 * * *"   # Daily at 4 AM

  http_target {
    uri         = google_cloudfunctions_function.db_export.https_trigger_url
    http_method = "POST"
    body = base64encode(jsonencode({
      instance = google_sql_database_instance.main.name
      project  = var.project_id
      bucket   = google_storage_bucket.db_backups.name
    }))
    oidc_token {
      service_account_email = google_service_account.db_export.email
    }
  }
}

resource "google_storage_bucket" "db_backups" {
  name     = "${var.project_id}-db-backups"
  location = var.region

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }

  versioning {
    enabled = true
  }
}
```

---

## 6. Lifecycle Protection

Every database resource should have `prevent_destroy` and `deletion_protection` where supported.

```hcl
# Pattern: Apply to ALL database resources

resource "aws_rds_cluster" "example" {
  # ... config ...

  deletion_protection = true
  skip_final_snapshot = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_sql_database_instance" "example" {
  # ... config ...

  deletion_protection = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_postgresql_flexible_server" "example" {
  # ... config ...

  lifecycle {
    prevent_destroy = true
  }
}

# Also protect the database itself
resource "postgresql_database" "example" {
  # ... config ...

  lifecycle {
    prevent_destroy = true
  }
}

# And the roles
resource "postgresql_role" "example" {
  # ... config ...

  lifecycle {
    prevent_destroy = true
  }
}
```

### How to Actually Delete (When Intended)

When you legitimately need to destroy a protected database:

1. Remove `prevent_destroy` from the lifecycle block
2. Set `deletion_protection = false`
3. Run `terraform apply` (updates the protection settings)
4. Run `terraform destroy -target=<resource>` (now allowed)
5. Or remove the resource from config and `terraform apply`

**Never remove `prevent_destroy` as a shortcut.** If it's blocking a destroy, that's working as intended. Verify the destroy is intentional before removing protection.

### Protecting Terraform State

```hcl
# S3 backend with versioning and deletion protection
terraform {
  backend "s3" {
    bucket         = "myorg-terraform-state"
    key            = "databases/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

# The state bucket itself should have:
# - Versioning enabled (recover from bad applies)
# - MFA delete enabled (prevent accidental bucket deletion)
# - Lifecycle policy to keep N versions
```

**State backup tip:** Even with S3 versioning, pull a local state backup before risky operations: `terraform state pull > backup.tfstate`
