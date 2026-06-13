# CI/CD Patterns for Terraform

## Plan-on-PR, Apply-on-Merge

The foundational Terraform CI/CD workflow follows a strict gate pattern:

```
PR Opened → fmt check → validate → lint → security scan → cost estimate → plan → post plan as PR comment → require approval → merge → apply → post result
```

Every step before merge is **read-only** — nothing touches infrastructure until code lands on the default branch. This gives reviewers full visibility into what will change before it happens.

### Saved Plan Artifacts

Always use saved plans to guarantee what was reviewed is what gets applied:

```bash
# During PR (plan stage)
terraform plan -out=plan.tfplan

# After merge (apply stage)
terraform apply plan.tfplan
```

Saved plans capture the exact set of changes at plan time. Without them, infrastructure can drift between plan and apply, causing unexpected modifications. Store the `.tfplan` artifact in your CI system (GitHub Actions artifact, S3 bucket, etc.) and pass it to the apply stage.

**Important**: Plan files contain sensitive data (resource attributes, variable values). Encrypt at rest and restrict access. They are also version-locked — a plan generated with Terraform 1.8 cannot be applied with 1.9.

---

## Tool Deep Dives

### Atlantis (Self-Hosted, Free)

Atlantis is an open-source application that listens for GitHub/GitLab/Bitbucket webhooks and runs `terraform plan` and `terraform apply` directly from pull requests.

#### atlantis.yaml Configuration

```yaml
version: 3
automerge: false
parallel_plan: true
parallel_apply: false

projects:
  - name: networking
    dir: environments/prod/networking
    workspace: default
    terraform_version: v1.8.5
    autoplan:
      when_modified:
        - "*.tf"
        - "*.tfvars"
        - "../modules/vpc/**"
      enabled: true
    apply_requirements:
      - approved
      - mergeable
    workflow: custom

  - name: compute
    dir: environments/prod/compute
    workspace: default
    autoplan:
      when_modified:
        - "*.tf"
        - "../../modules/ec2/**"
      enabled: true

workflows:
  custom:
    plan:
      steps:
        - run: terraform fmt -check -recursive
        - run: tflint --init && tflint
        - run: tfsec .
        - init
        - plan
    apply:
      steps:
        - apply
```

#### Custom Workflows with Pre/Post Steps

```yaml
workflows:
  production:
    plan:
      steps:
        - run: |
            echo "Planning ${REPO_REL_DIR} in workspace ${WORKSPACE}"
        - run: conftest test . --policy ../policies -o table
        - init:
            extra_args: ["-upgrade=false"]
        - plan:
            extra_args: ["-var-file=prod.tfvars"]
    apply:
      steps:
        - run: echo "Applying to production — point of no return"
        - apply
        - run: |
            curl -X POST "$SLACK_WEBHOOK" \
              -d "{\"text\": \"Applied ${PROJECT_NAME} in ${REPO_REL_DIR}\"}"
```

#### Conftest Integration for Policy Checks

Conftest evaluates Terraform plan JSON against OPA (Rego) policies:

```rego
# policy/terraform.rego
package main

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket"
  not resource.change.after.server_side_encryption_configuration
  msg := sprintf("S3 bucket %s must have encryption enabled", [resource.address])
}

deny[msg] {
  resource := input.resource_changes[_]
  resource.change.actions[_] == "delete"
  msg := sprintf("Deleting %s requires manual approval", [resource.address])
}
```

#### Lock Behavior

Atlantis locks a directory (project) when a plan is generated on a PR. Only one PR can hold the lock for a given directory at a time. Other PRs touching the same directory must wait. This prevents conflicting applies. Use `atlantis unlock` to manually release locks if a PR is abandoned.

#### When to Choose Atlantis

- Teams wanting PR-based plan/apply with full control over the execution environment
- Self-hosted requirement (air-gapped, compliance, data sovereignty)
- No vendor lock-in — runs on any compute (VM, container, Kubernetes)
- Budget-conscious teams (free, open-source)
- Moderate complexity (not managing hundreds of workspaces)

---

### Spacelift (SaaS)

Spacelift is a managed CI/CD platform purpose-built for infrastructure-as-code.

#### Stack Configuration

Stacks are Spacelift's unit of work, equivalent to a Terraform workspace/root module:

- **Source**: Git repo + branch + subdirectory
- **Runner image**: Custom Docker image for plan/apply environment
- **Contexts**: Shared environment variable bundles attached to stacks
- **Policies (OPA)**: Plan policies (block applies), push policies (trigger rules), approval policies (who can approve)

#### Multi-IaC Support

Spacelift natively supports Terraform, OpenTofu, Terragrunt, Pulumi, Ansible, Kubernetes, and CloudFormation. This makes it suitable for organizations with heterogeneous IaC stacks.

#### Drift Detection

Spacelift can run scheduled plans (e.g., every 6 hours) to detect infrastructure drift. If drift is found, it can auto-create a PR, notify via webhook, or auto-reconcile.

#### When to Choose Spacelift

- Multi-IaC organizations needing one platform for Terraform + K8s + Ansible
- Teams preferring SaaS over self-hosted
- Need built-in drift detection without custom scripting
- Complex policy requirements (OPA-native)
- Large-scale operations with hundreds of stacks

---

### HCP Terraform (Formerly Terraform Cloud)

HashiCorp's managed Terraform platform, rebranded from Terraform Cloud in 2024.

#### Workflow Types

**VCS-driven**: Connect a Git repo. PRs trigger speculative plans; merges trigger applies. Simplest setup.

**API-driven**: External CI system triggers runs via the HCP Terraform API. More flexible, supports custom pipelines.

**CLI-driven**: Run `terraform plan` and `terraform apply` locally but execute remotely. Good for migration from local workflows.

#### Sentinel Policy Integration

Sentinel is HashiCorp's policy-as-code framework (proprietary, included in HCP Terraform Plus):

```python
# restrict-instance-types.sentinel
import "tfplan/v2" as tfplan

allowed_types = ["t3.micro", "t3.small", "t3.medium"]

main = rule {
  all tfplan.resource_changes as _, rc {
    rc.type is "aws_instance" implies
      rc.change.after.instance_type in allowed_types
  }
}
```

#### Run Triggers for Cross-Workspace Dependencies

When workspace A (networking) completes an apply, it can auto-trigger a plan in workspace B (compute) that depends on networking outputs. This enables ordered multi-workspace deployments without orchestration scripts.

#### Pricing

- **Free tier**: Up to 500 managed resources (note: the legacy free tier sunset on March 31, 2026; new free tier has resource limits)
- **Standard**: Per-resource pricing with team management features
- **Plus**: Sentinel, SSO, audit logging, drift detection

#### When to Choose HCP Terraform

- HashiCorp-native teams already invested in the ecosystem
- Need Sentinel policy enforcement (not available elsewhere)
- Prefer managed service with strong Terraform integration
- Cross-workspace dependency orchestration via run triggers
- Small teams on free tier with fewer than 500 resources

---

### GitHub Actions

GitHub Actions provides maximum flexibility for teams already on GitHub. You build the pipeline yourself using reusable workflows and community actions.

#### Reusable Workflow Example

```yaml
# .github/workflows/terraform.yml
name: Terraform
on:
  pull_request:
    paths:
      - 'infra/**'
  push:
    branches: [main]
    paths:
      - 'infra/**'

permissions:
  id-token: write    # OIDC
  contents: read
  pull-requests: write  # Post plan comments

concurrency:
  group: terraform-${{ github.head_ref || github.ref }}
  cancel-in-progress: false  # Never cancel in-progress applies

jobs:
  plan:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: infra/
    steps:
      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.8.5
          terraform_wrapper: false  # Disable wrapper for clean output

      - name: Configure AWS Credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-actions-terraform
          aws-region: us-east-1

      - name: Terraform Init
        run: terraform init -backend-config=backend.hcl

      - name: Terraform Format Check
        run: terraform fmt -check -recursive

      - name: Terraform Validate
        run: terraform validate

      - name: TFLint
        uses: terraform-linters/setup-tflint@v4
        with:
          tflint_version: latest
      - run: tflint --init && tflint

      - name: Terraform Plan
        id: plan
        run: |
          terraform plan -no-color -out=plan.tfplan 2>&1 | tee plan_output.txt
          echo "exitcode=$?" >> $GITHUB_OUTPUT

      - name: Post Plan to PR
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const plan = fs.readFileSync('infra/plan_output.txt', 'utf8');
            const truncated = plan.length > 60000
              ? plan.substring(0, 60000) + '\n... (truncated)'
              : plan;
            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: `### Terraform Plan\n\`\`\`\n${truncated}\n\`\`\``
            });

      - name: Upload Plan Artifact
        uses: actions/upload-artifact@v4
        with:
          name: tfplan
          path: infra/plan.tfplan
          retention-days: 5

  apply:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production  # Requires environment approval
    defaults:
      run:
        working-directory: infra/
    steps:
      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.8.5

      - name: Configure AWS Credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-actions-terraform
          aws-region: us-east-1

      - name: Terraform Init
        run: terraform init -backend-config=backend.hcl

      - name: Terraform Apply
        run: terraform apply -auto-approve
```

#### OIDC Federation (No Static Credentials)

OIDC eliminates long-lived credentials entirely. GitHub Actions requests a short-lived JWT, exchanges it for cloud provider credentials:

**AWS**: Configure an IAM OIDC identity provider for `token.actions.githubusercontent.com`, create a role with a trust policy scoping to your repo/branch.

**GCP**: Configure a Workload Identity Pool and Provider, map GitHub claims to GCP service account impersonation.

**Azure**: Configure a federated credential on an Azure AD app registration, scoped to your repo/branch.

#### Concurrency Controls

```yaml
concurrency:
  group: terraform-apply
  cancel-in-progress: false  # Critical: never cancel a running apply
```

Always set `cancel-in-progress: false` for apply jobs. Canceling an in-progress apply can leave state locked or infrastructure in a partial state.

#### When to Choose GitHub Actions

- Already using GitHub for source control and CI
- Want full control over the pipeline without a separate tool
- Simple to moderate Terraform setups (1-20 workspaces)
- Prefer OIDC-native credential management
- Need custom steps (security scanning, cost estimation, notifications)

---

### env0 and Scalr

#### env0

SaaS platform with strong cost management and governance features. Includes cost estimation, RBAC, custom flows, and drift detection. Best for organizations prioritizing cloud cost visibility alongside IaC automation.

#### Scalr

SaaS platform offering hierarchical RBAC (account → environment → workspace), OPA policy integration, and module registry. Positions itself as a Terraform Cloud alternative with stronger multi-tenancy. Best for managed service providers or organizations with complex team hierarchies.

| Aspect | env0 | Scalr |
|--------|------|-------|
| Strength | Cost governance | Multi-tenant RBAC |
| Policy | OPA | OPA |
| Drift detection | Yes | Yes |
| Pricing | Per-run | Per-workspace |
| Best for | Cost-conscious orgs | MSPs, complex hierarchies |

---

## Credentials Management

### OIDC Federation Patterns

OIDC federation is the gold standard — no static credentials to rotate or leak.

**AWS**:
```hcl
# IAM OIDC provider + role (one-time setup)
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-terraform"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
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

**GCP**:
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
    "attribute.repository" = "assertion.repository"
  }
  oidc { issuer_uri = "https://token.actions.githubusercontent.com" }
}
```

**Azure**:
```bash
az ad app federated-credential create \
  --id <app-object-id> \
  --parameters '{
    "name": "github-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:my-org/my-repo:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

### Short-Lived Tokens and Role Assumption Chains

- CI obtains OIDC token (valid ~10 minutes)
- Exchanges for cloud provider session credentials (1-hour default)
- For cross-account access: assume a hub role, then assume spoke roles per environment
- Never store credentials in CI variables if OIDC is available

### Service Account Per Environment

Maintain separate credentials/roles per environment (dev, staging, prod). This limits blast radius — a compromised dev pipeline cannot modify production infrastructure.

```
CI OIDC Token
  → arn:aws:iam::DEV_ACCOUNT:role/terraform-dev       (dev branch)
  → arn:aws:iam::STAGING_ACCOUNT:role/terraform-staging (staging branch)
  → arn:aws:iam::PROD_ACCOUNT:role/terraform-prod      (main branch, requires approval)
```

---

## Pipeline Comparison Table

| Tool | Self-Hosted | Managed | PR Comments | Policy Engine | Drift Detection | Cost |
|------|:-----------:|:-------:|:-----------:|:--------------|:---------------:|------|
| Atlantis | Yes | No | Yes | Conftest (OPA) | No (DIY) | Free |
| Spacelift | No | Yes | Yes | OPA (native) | Yes | Per-worker |
| HCP Terraform | No | Yes | Yes | Sentinel + OPA | Yes (Plus) | Per-resource |
| GitHub Actions | N/A | Yes | DIY | DIY | No (DIY) | Per-minute |
| env0 | No | Yes | Yes | OPA | Yes | Per-run |
| Scalr | No | Yes | Yes | OPA | Yes | Per-workspace |
| Atlantis + GHA | Yes | Hybrid | Yes | OPA + custom | No (DIY) | Free + per-minute |

---

## Hybrid Pattern

Combine GitHub Actions for fast, parallelizable checks with Atlantis or Spacelift for the plan/apply lifecycle:

```
GitHub Actions (on PR):
  ├── terraform fmt -check        (parallel)
  ├── tflint                      (parallel)
  ├── tfsec / trivy               (parallel)
  ├── infracost diff              (parallel)
  └── conftest test               (parallel)

Atlantis / Spacelift (on PR):
  ├── terraform plan
  └── post plan as PR comment

Atlantis / Spacelift (on merge):
  └── terraform apply
```

This gives you fast feedback on style and security (GitHub Actions runs in seconds) while the heavier plan/apply lifecycle is managed by the specialized tool. The hybrid approach works well for teams that want custom linting and security scanning without building the entire plan/apply pipeline in GitHub Actions.
