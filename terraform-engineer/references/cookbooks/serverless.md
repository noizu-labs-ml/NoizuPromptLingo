# Cookbook: Serverless

Practical HCL recipes for Lambda, Cloud Functions, Azure Functions, API Gateway integrations, and GitHub Actions self-hosted runners on Kubernetes.

---

## 1. Lambda Functions

Uses the community Lambda module with packaging, layers, VPC access, and least-privilege IAM.

```hcl
module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = "${var.environment}-api-handler"
  description   = "API request handler"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  architectures = ["arm64"]   # Graviton — cheaper and faster

  # Source code
  source_path = [
    {
      path             = "${path.module}/src"
      npm_requirements = true   # Auto-installs from package.json
    }
  ]

  # Environment
  environment_variables = {
    NODE_ENV     = var.environment
    DATABASE_URL = var.database_url
    LOG_LEVEL    = var.environment == "prod" ? "warn" : "debug"
  }

  # VPC access (for RDS, ElastiCache, etc.)
  vpc_subnet_ids         = var.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.lambda.id]
  attach_network_policy  = true

  # Timeout and memory
  timeout     = 30
  memory_size = 512

  # Layers
  layers = [
    module.lambda_layer.lambda_layer_arn,
  ]

  # CloudWatch Logs
  cloudwatch_logs_retention_in_days = 30

  # Reserved concurrency (protect downstream services)
  reserved_concurrent_executions = var.environment == "prod" ? 100 : 10

  # Dead letter queue
  dead_letter_target_arn = aws_sqs_queue.lambda_dlq.arn
  attach_dead_letter_policy = true

  # IAM policies
  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect = "Allow"
      actions = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:Query",
      ]
      resources = [var.dynamodb_table_arn, "${var.dynamodb_table_arn}/index/*"]
    }
    secrets = {
      effect    = "Allow"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = [var.secret_arn]
    }
    sqs_dlq = {
      effect    = "Allow"
      actions   = ["sqs:SendMessage"]
      resources = [aws_sqs_queue.lambda_dlq.arn]
    }
  }

  tags = {
    Environment = var.environment
  }
}

# --- Lambda Layer (shared dependencies) ---

module "lambda_layer" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  create_layer = true
  layer_name   = "${var.environment}-shared-deps"
  description  = "Shared Node.js dependencies"

  compatible_runtimes      = ["nodejs20.x"]
  compatible_architectures = ["arm64"]

  source_path = [
    {
      path             = "${path.module}/layers/shared"
      npm_requirements = true
      prefix_in_zip    = "nodejs"
    }
  ]
}

# --- Security Group for Lambda in VPC ---

resource "aws_security_group" "lambda" {
  name_prefix = "${var.environment}-lambda-"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --- Dead Letter Queue ---

resource "aws_sqs_queue" "lambda_dlq" {
  name                      = "${var.environment}-lambda-dlq"
  message_retention_seconds = 1209600   # 14 days
}
```

---

## 2. API Gateway + Lambda (HTTP API v2)

HTTP API (v2) is cheaper and simpler than REST API (v1). Use REST API only when you need request validation, API keys, usage plans, or WAF integration.

```hcl
# --- HTTP API ---

resource "aws_apigatewayv2_api" "main" {
  name          = "${var.environment}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.cors_origins
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 3600
  }
}

# --- Stage with auto-deploy ---

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
      integrationError = "$context.integrationErrorMessage"
    })
  }

  default_route_settings {
    throttling_burst_limit = 100
    throttling_rate_limit  = 50
  }
}

# --- Lambda Integration ---

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = module.lambda_function.lambda_function_invoke_arn
  payload_format_version = "2.0"
}

# --- Routes ---

resource "aws_apigatewayv2_route" "routes" {
  for_each = {
    "GET /api/items"      = "GET /api/items"
    "POST /api/items"     = "POST /api/items"
    "GET /api/items/{id}" = "GET /api/items/{id}"
    "PUT /api/items/{id}" = "PUT /api/items/{id}"
  }

  api_id    = aws_apigatewayv2_api.main.id
  route_key = each.value
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# --- Lambda Permission ---

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

# --- Custom Domain ---

resource "aws_apigatewayv2_domain_name" "api" {
  domain_name = "api.${var.domain}"

  domain_name_configuration {
    certificate_arn = var.acm_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "api" {
  api_id      = aws_apigatewayv2_api.main.id
  domain_name = aws_apigatewayv2_domain_name.api.id
  stage       = aws_apigatewayv2_stage.default.id
}

resource "aws_route53_record" "api" {
  zone_id = var.route53_zone_id
  name    = "api.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

# --- CloudWatch Logs ---

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/apigateway/${var.environment}-api"
  retention_in_days = 30
}

# --- Outputs ---

output "api_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}

output "custom_domain_url" {
  value = "https://api.${var.domain}"
}
```

---

## 3. Cloud Functions v2 (GCP)

Second-generation Cloud Functions built on Cloud Run, with VPC connector and event triggers.

```hcl
# --- VPC Connector (for private network access) ---

resource "google_vpc_access_connector" "functions" {
  project       = var.project_id
  name          = "fn-connector-${var.environment}"
  region        = var.region
  network       = var.network_name
  ip_cidr_range = "10.8.0.0/28"   # Dedicated /28 for the connector

  min_instances = 2
  max_instances = 10

  machine_type = "e2-micro"
}

# --- HTTP-Triggered Function ---

resource "google_cloudfunctions2_function" "api" {
  project  = var.project_id
  name     = "api-handler-${var.environment}"
  location = var.region

  build_config {
    runtime     = "nodejs20"
    entry_point = "handler"

    source {
      storage_source {
        bucket = google_storage_bucket.functions_source.name
        object = google_storage_bucket_object.api_source.name
      }
    }
  }

  service_config {
    max_instance_count             = var.environment == "prod" ? 100 : 10
    min_instance_count             = var.environment == "prod" ? 1 : 0
    available_memory               = "512Mi"
    timeout_seconds                = 60
    max_instance_request_concurrency = 80
    available_cpu                  = "1"

    environment_variables = {
      NODE_ENV     = var.environment
      DATABASE_URL = var.database_url
    }

    vpc_connector                  = google_vpc_access_connector.functions.id
    vpc_connector_egress_settings  = "PRIVATE_RANGES_ONLY"
    ingress_settings               = "ALLOW_ALL"

    service_account_email = google_service_account.function_sa.email
  }
}

# Allow unauthenticated access (public API)
resource "google_cloud_run_service_iam_member" "api_public" {
  project  = var.project_id
  location = var.region
  service  = google_cloudfunctions2_function.api.service_config[0].service
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# --- Event-Triggered Function (Storage) ---

resource "google_cloudfunctions2_function" "image_processor" {
  project  = var.project_id
  name     = "image-processor-${var.environment}"
  location = var.region

  build_config {
    runtime     = "python312"
    entry_point = "process_image"

    source {
      storage_source {
        bucket = google_storage_bucket.functions_source.name
        object = google_storage_bucket_object.processor_source.name
      }
    }
  }

  service_config {
    max_instance_count    = 50
    available_memory      = "1Gi"
    timeout_seconds       = 540   # 9 minutes max
    service_account_email = google_service_account.function_sa.email

    vpc_connector                 = google_vpc_access_connector.functions.id
    vpc_connector_egress_settings = "PRIVATE_RANGES_ONLY"
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.storage.object.v1.finalized"

    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.uploads.name
    }

    retry_policy = "RETRY_POLICY_RETRY"
  }
}

# --- Pub/Sub-Triggered Function ---

resource "google_cloudfunctions2_function" "queue_processor" {
  project  = var.project_id
  name     = "queue-processor-${var.environment}"
  location = var.region

  build_config {
    runtime     = "go122"
    entry_point = "ProcessMessage"

    source {
      storage_source {
        bucket = google_storage_bucket.functions_source.name
        object = google_storage_bucket_object.queue_source.name
      }
    }
  }

  service_config {
    max_instance_count    = 100
    available_memory      = "256Mi"
    timeout_seconds       = 60
    service_account_email = google_service_account.function_sa.email
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.tasks.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }
}

# --- Service Account ---

resource "google_service_account" "function_sa" {
  project      = var.project_id
  account_id   = "fn-${var.environment}"
  display_name = "Cloud Functions ${var.environment}"
}

resource "google_project_iam_member" "function_roles" {
  for_each = toset([
    "roles/cloudsql.client",
    "roles/storage.objectAdmin",
    "roles/secretmanager.secretAccessor",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# --- Source Bucket ---

resource "google_storage_bucket" "functions_source" {
  project  = var.project_id
  name     = "${var.project_id}-functions-source"
  location = var.region

  uniform_bucket_level_access = true
}
```

---

## 4. Azure Functions

Linux Function App on Consumption, Premium, and Flex Consumption plans.

```hcl
# --- Storage Account (required for Azure Functions) ---

resource "azurerm_storage_account" "functions" {
  name                     = "stfn${var.environment}${random_id.storage.hex}"
  resource_group_name      = azurerm_resource_group.functions.name
  location                 = azurerm_resource_group.functions.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_id" "storage" {
  byte_length = 4
}

# --- App Service Plan ---

# Option A: Consumption (serverless, pay-per-execution)
resource "azurerm_service_plan" "consumption" {
  count = var.plan_type == "consumption" ? 1 : 0

  name                = "asp-fn-${var.environment}"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

# Option B: Premium (VNet integration, no cold start, min instances)
resource "azurerm_service_plan" "premium" {
  count = var.plan_type == "premium" ? 1 : 0

  name                = "asp-fn-${var.environment}"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
  os_type             = "Linux"
  sku_name            = "EP1"   # EP1, EP2, EP3

  maximum_elastic_worker_count = 20
}

# --- Linux Function App ---

resource "azurerm_linux_function_app" "main" {
  name                       = "fn-${var.environment}-api"
  resource_group_name        = azurerm_resource_group.functions.name
  location                   = azurerm_resource_group.functions.location
  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key
  service_plan_id            = var.plan_type == "premium" ? azurerm_service_plan.premium[0].id : azurerm_service_plan.consumption[0].id

  site_config {
    application_stack {
      node_version = "20"
    }

    # Premium only: VNet integration
    dynamic "ip_restriction" {
      for_each = var.plan_type == "premium" ? [1] : []
      content {
        virtual_network_subnet_id = var.function_subnet_id
        action                    = "Allow"
        priority                  = 100
        name                      = "AllowVNet"
      }
    }

    cors {
      allowed_origins = var.cors_origins
    }

    application_insights_connection_string = azurerm_application_insights.functions.connection_string
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"       = "node"
    "WEBSITE_RUN_FROM_PACKAGE"       = "1"
    "DATABASE_URL"                   = "@Microsoft.KeyVault(VaultName=${var.keyvault_name};SecretName=database-url)"
    "AzureWebJobsDisableHomepage"    = "true"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
  }
}

# --- Key Vault Access for Managed Identity ---

resource "azurerm_key_vault_access_policy" "function" {
  key_vault_id = var.keyvault_id
  tenant_id    = azurerm_linux_function_app.main.identity[0].tenant_id
  object_id    = azurerm_linux_function_app.main.identity[0].principal_id

  secret_permissions = ["Get", "List"]
}

# --- Application Insights ---

resource "azurerm_application_insights" "functions" {
  name                = "ai-fn-${var.environment}"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
  application_type    = "Node.JS"
  retention_in_days   = 30
}

# --- Outputs ---

output "function_app_url" {
  value = "https://${azurerm_linux_function_app.main.default_hostname}"
}

output "function_app_identity" {
  value = azurerm_linux_function_app.main.identity[0].principal_id
}
```

### Plan Comparison

| Feature | Consumption (Y1) | Premium (EP1-3) | Flex Consumption |
|:--------|:-:|:-:|:-:|
| Cold start | Yes (seconds) | No (always warm) | Reduced |
| VNet integration | No | Yes | Yes |
| Min instances | 0 | 1+ | 0 |
| Max timeout | 10 min | 60 min | 10 min |
| Price model | Per execution | Per instance/hr | Per execution (discounted) |
| Use when | Low/sporadic traffic | Latency-sensitive, VNet | High traffic, cost-conscious |

---

## 5. GitHub Actions Self-Hosted Runners on K8s

Deploy Actions Runner Controller (ARC) for autoscaling ephemeral runners.

```hcl
# --- ARC System (controller) ---

resource "helm_release" "arc_system" {
  name             = "arc-systems"
  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart            = "gha-runner-scale-set-controller"
  version          = "0.9.3"
  namespace        = "arc-systems"
  create_namespace = true

  wait = true
}

# --- Runner Scale Set ---

resource "helm_release" "arc_runners" {
  name             = "arc-runners"
  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart            = "gha-runner-scale-set"
  version          = "0.9.3"
  namespace        = "arc-runners"
  create_namespace = true

  values = [
    yamlencode({
      githubConfigUrl = "https://github.com/${var.github_org}"

      githubConfigSecret = {
        github_token = var.github_pat
      }

      # Runner group (optional, for org-level runners)
      # runnerGroup = "default"

      # Min/max runners
      minRunners = var.environment == "prod" ? 2 : 0
      maxRunners = var.environment == "prod" ? 20 : 5

      # Runner pod template
      template = {
        spec = {
          containers = [{
            name  = "runner"
            image = "ghcr.io/actions/actions-runner:latest"
            command = ["/home/runner/run.sh"]

            resources = {
              requests = {
                cpu    = "1"
                memory = "2Gi"
              }
              limits = {
                cpu    = "4"
                memory = "8Gi"
              }
            }

            # Ephemeral storage for builds
            volumeMounts = [{
              name      = "work"
              mountPath = "/home/runner/_work"
            }]

            env = [
              {
                name  = "ACTIONS_RUNNER_REQUIRE_JOB_CONTAINER"
                value = "false"
              }
            ]
          }]

          volumes = [{
            name = "work"
            emptyDir = {
              sizeLimit = "20Gi"
            }
          }]

          # Schedule on workload nodes, not system
          nodeSelector = {
            "nodepool-type" = "workloads"
          }

          # Tolerate spot node taints
          tolerations = [{
            key      = "kubernetes.azure.com/scalesetpriority"
            operator = "Equal"
            value    = "spot"
            effect   = "NoSchedule"
          }]
        }
      }

      # Listener pod (watches for workflow jobs)
      listenerTemplate = {
        spec = {
          containers = [{
            name = "listener"
            resources = {
              requests = {
                cpu    = "100m"
                memory = "128Mi"
              }
              limits = {
                cpu    = "500m"
                memory = "256Mi"
              }
            }
          }]
        }
      }
    })
  ]

  depends_on = [helm_release.arc_system]
}

# --- Docker-in-Docker Runner (for container builds) ---

resource "helm_release" "arc_runners_dind" {
  name             = "arc-runners-dind"
  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart            = "gha-runner-scale-set"
  version          = "0.9.3"
  namespace        = "arc-runners"
  create_namespace = true

  values = [
    yamlencode({
      githubConfigUrl = "https://github.com/${var.github_org}"

      githubConfigSecret = {
        github_token = var.github_pat
      }

      # Label these runners differently
      # In workflows: runs-on: [self-hosted, dind]
      runnerScaleSetName = "dind-runners"

      minRunners = 0
      maxRunners = 10

      # Use Docker-in-Docker mode
      containerMode = {
        type = "dind"
      }

      template = {
        spec = {
          containers = [
            {
              name  = "runner"
              image = "ghcr.io/actions/actions-runner:latest"
              command = ["/home/runner/run.sh"]

              resources = {
                requests = { cpu = "2", memory = "4Gi" }
                limits   = { cpu = "4", memory = "8Gi" }
              }
            }
          ]

          # DinD needs privileged or use Sysbox for rootless
          # Consider security implications
        }
      }
    })
  ]

  depends_on = [helm_release.arc_system]
}
```

### Usage in GitHub Actions Workflows

```yaml
# .github/workflows/build.yaml
jobs:
  build:
    runs-on: arc-runners         # Matches runnerScaleSetName
    steps:
      - uses: actions/checkout@v4
      - run: npm ci && npm test

  docker-build:
    runs-on: dind-runners        # DinD runners for container builds
    steps:
      - uses: actions/checkout@v4
      - run: docker build -t myapp .
```

**Security note:** Self-hosted runners should only be used with private repositories or with runner groups restricted to specific repositories. Public repos can run arbitrary code on your runners.

**Cost tip:** Set `minRunners: 0` for non-production to avoid paying for idle compute. The scale-up latency is typically 30-60 seconds, which is acceptable for CI/CD.
