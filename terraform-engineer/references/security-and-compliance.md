# Security and Compliance

Hardening Terraform configurations, managing secrets, enforcing policies, and detecting drift.

## State File Security

State files contain every attribute of every managed resource — including passwords, tokens, and private keys in plain text. Treat state as a **highly sensitive asset**.

### Encryption and Access

| Backend | Encryption at Rest | Access Control | Versioning |
|---------|-------------------|----------------|------------|
| S3 | SSE-S3, SSE-KMS | IAM policies, bucket policy | S3 versioning |
| GCS | Default (Google-managed), CMEK | IAM bindings | Object versioning |
| Azure Blob | SSE with Microsoft-managed or customer-managed keys | RBAC, SAS tokens | Blob versioning |
| Terraform Cloud | AES-256 at rest, TLS in transit | Team/workspace permissions | Built-in |

### S3 Backend Hardening

```hcl
resource "aws_s3_bucket" "terraform_state" {
  bucket = "myorg-terraform-state"

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
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.terraform_state.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyUnencryptedTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}
```

## Secrets Management Hierarchy

From best to worst — always use the highest tier available:

### Tier 1: Ephemeral Resources (Terraform 1.10+)

Data never persisted in state. The gold standard.

```hcl
ephemeral "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/database/password"
}

resource "aws_db_instance" "main" {
  password = ephemeral.aws_secretsmanager_secret_version.db_password.secret_string
}
```

### Tier 2: Write-Only Arguments (Terraform 1.11+)

Resource arguments that never persist in plan or state.

```hcl
resource "aws_db_instance" "main" {
  password = var.db_password  # write-only: value applied but never stored in state
}
```

### Tier 3: External Secrets Manager + Data Source

Secret stored externally, read at plan/apply time. Value appears in state but encrypted at rest.

```hcl
data "vault_generic_secret" "db" {
  path = "secret/data/production/database"
}

resource "aws_db_instance" "main" {
  password = data.vault_generic_secret.db.data["password"]
}
```

### Tier 4: Sensitive Variables

Injected from CI/CD environment, marked sensitive. Still in state, but redacted from plan output.

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

### Tier 5: NEVER — Hardcoded or Committed

```hcl
# NEVER DO THIS
resource "aws_db_instance" "main" {
  password = "my-plaintext-password"  # exposed in state, plan, AND git history
}
```

## IAM Patterns

### Least Privilege for Terraform Service Accounts

```hcl
# Separate service accounts per environment
resource "aws_iam_role" "terraform_prod" {
  name = "terraform-prod"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:sub" = "repo:myorg/infra:environment:production"
        }
      }
    }]
  })
}

# Scope permissions to what Terraform actually manages
resource "aws_iam_role_policy" "terraform_prod" {
  role = aws_iam_role.terraform_prod.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:*", "ec2:*", "rds:*"]
        Resource = "arn:aws:*:us-east-1:${data.aws_caller_identity.current.account_id}:*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = "us-east-1" }
        }
      }
    ]
  })
}
```

### OIDC Federation for CI/CD (No Long-Lived Credentials)

```hcl
# AWS
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# GCP
resource "google_iam_workload_identity_pool" "ci" {
  workload_identity_pool_id = "github-actions"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.ci.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
  attribute_condition = "assertion.repository_owner == 'myorg'"
  oidc { issuer_uri = "https://token.actions.githubusercontent.com" }
}
```

## Policy as Code

### Layered Approach

```
┌─────────────────────────────────────┐
│  Runtime: Cloud-Native Guardrails   │  AWS SCPs, Azure Policy, GCP Org Policies
├─────────────────────────────────────┤
│  Plan-Time: Custom Org Policies     │  OPA/Conftest, Sentinel
├─────────────────────────────────────┤
│  Pre-Commit / Early CI: Scanning    │  Checkov, Trivy, tflint
└─────────────────────────────────────┘
```

### Checkov (Recommended Open-Source Scanner)

```bash
# Scan Terraform directory
checkov -d . --framework terraform

# Scan specific file
checkov -f main.tf

# Skip specific checks
checkov -d . --skip-check CKV_AWS_18,CKV_AWS_21

# Output as JUnit for CI
checkov -d . -o junitxml > checkov-results.xml

# Custom check (Python)
# checkov/checks/resource/aws/S3BucketCustomEncryption.py
```

### OPA/Conftest (Vendor-Neutral Policy)

```rego
# policy/terraform.rego
package main

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket"
  actions := resource.change.actions
  actions[_] == "create"
  not resource.change.after.server_side_encryption_configuration
  msg := sprintf("S3 bucket '%s' must have encryption enabled", [resource.address])
}

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_db_instance"
  resource.change.after.publicly_accessible == true
  msg := sprintf("RDS instance '%s' must not be publicly accessible", [resource.address])
}

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_instance"
  not resource.change.after.metadata_options
  msg := sprintf("EC2 instance '%s' must have IMDSv2 enforced", [resource.address])
}
```

```bash
# Usage
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
conftest test tfplan.json -p policy/
```

### Sentinel (HCP Terraform/Enterprise Only)

```sentinel
import "tfplan/v2" as tfplan

# Require encryption on all S3 buckets
main = rule {
  all tfplan.resource_changes as _, rc {
    rc.type is not "aws_s3_bucket" or
    rc.change.after.server_side_encryption_configuration is not null
  }
}
```

## Drift Detection

### Scheduled Plan

```yaml
# .github/workflows/drift-detection.yml
name: Terraform Drift Detection
on:
  schedule:
    - cron: '0 8 * * 1-5'  # Weekdays at 8 AM

jobs:
  detect-drift:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        component: [networking, platform, data]
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - run: terraform init
        working-directory: environments/prod/${{ matrix.component }}
      - run: terraform plan -refresh-only -detailed-exitcode
        working-directory: environments/prod/${{ matrix.component }}
        continue-on-error: true
        id: drift
      - name: Notify on drift
        if: steps.drift.outcome == 'failure'
        run: |
          # Send Slack notification, create GitHub issue, etc.
          echo "Drift detected in ${{ matrix.component }}"
```

### Exit Code Interpretation

| Exit Code | Meaning |
|-----------|---------|
| 0 | No changes — state matches reality |
| 1 | Error — something went wrong |
| 2 | Changes detected — drift exists |

## Security Checklist

- [ ] Remote backend with encryption at rest enabled
- [ ] State bucket has versioning enabled
- [ ] State bucket blocks public access
- [ ] State bucket requires TLS transport
- [ ] DynamoDB/native locking enabled (prevents concurrent applies)
- [ ] No secrets in .tf or .tfvars files committed to VCS
- [ ] All sensitive variables marked `sensitive = true`
- [ ] Service accounts use least-privilege IAM
- [ ] CI/CD uses OIDC federation (no long-lived credentials)
- [ ] Policy-as-code scanner (Checkov minimum) in CI pipeline
- [ ] `prevent_destroy` on stateful resources (databases, volumes)
- [ ] `-auto-approve` never used in production
- [ ] Drift detection runs on schedule
- [ ] `.terraform.lock.hcl` committed to VCS
- [ ] Provider versions pinned with pessimistic constraints
