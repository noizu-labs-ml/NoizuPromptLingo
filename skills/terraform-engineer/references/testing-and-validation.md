# Testing and Validation

Comprehensive guide to testing Terraform infrastructure code — from static analysis through integration tests and drift detection.

---

## Testing Pyramid

```
                    ┌─────────────────┐
                    │  Manual Review   │  ← Highest confidence, highest cost
                    ├─────────────────┤
                  ┌─┤Integration Tests├─┐  ← Real resources, slow, expensive
                  │ ├─────────────────┤ │
                ┌─┤ │ Policy as Code  │ ├─┐  ← OPA/Conftest/Sentinel on plan JSON
                │ │ ├─────────────────┤ │ │
              ┌─┤ │ │   Unit Tests    │ │ ├─┐  ← terraform test, mock providers
              │ │ │ ├─────────────────┤ │ │ │
            ┌─┤ │ │ │ Static Analysis │ │ │ ├─┐  ← tflint, Checkov, Trivy — fast, free
            │ └─┘ └─┴─────────────────┴─┘ └─┘ │
            └───────────────────────────────────┘
                   Run every layer, bottom-up.
         Lower layers are fast and cheap — run them first.
```

Each layer catches a different class of defect:

| Layer | Catches | Speed |
|-------|---------|-------|
| Static Analysis | Syntax errors, deprecated attrs, insecure defaults | Seconds |
| Unit Tests | Logic errors in conditionals, locals, outputs | Seconds (with mocks) |
| Policy as Code | Compliance violations, tag requirements, region locks | Seconds |
| Integration Tests | Runtime failures, API incompatibilities, real-world behavior | Minutes to hours |
| Manual Review | Architecture flaws, business logic errors, naming conventions | Hours |

---

## Built-in Testing (`terraform test`, 1.6+)

Terraform 1.6 introduced native testing via `.tftest.hcl` files. Terraform 1.7 added mock providers, making it possible to test without any cloud access.

### File Structure

Test files live alongside your module or in a `tests/` directory:

```
module/
├── main.tf
├── variables.tf
├── outputs.tf
├── tests/
│   ├── basic.tftest.hcl
│   ├── validation.tftest.hcl
│   └── edge_cases.tftest.hcl
```

### Basic Test: Plan-Only Validation

```hcl
# tests/basic.tftest.hcl

variables {
  environment = "staging"
  instance_type = "t3.micro"
  enable_monitoring = true
}

run "validates_instance_configuration" {
  command = plan  # Default — does NOT create resources

  assert {
    condition     = aws_instance.app.instance_type == "t3.micro"
    error_message = "Instance type should be t3.micro for staging"
  }

  assert {
    condition     = aws_instance.app.monitoring == true
    error_message = "Monitoring should be enabled"
  }

  assert {
    condition     = length(aws_instance.app.tags) > 0
    error_message = "Instance must have at least one tag"
  }
}
```

### Apply Test: Real Resource Validation

```hcl
# tests/integration.tftest.hcl

variables {
  environment = "test"
  vpc_cidr    = "10.99.0.0/16"
}

run "creates_vpc_and_validates" {
  command = apply  # Creates real resources — destroyed after test

  assert {
    condition     = aws_vpc.main.cidr_block == "10.99.0.0/16"
    error_message = "VPC CIDR block mismatch"
  }

  assert {
    condition     = aws_vpc.main.enable_dns_hostnames == true
    error_message = "DNS hostnames should be enabled"
  }
}

run "subnet_inherits_vpc" {
  command = plan

  # This run block can reference outputs from the previous apply
  assert {
    condition     = aws_subnet.private.vpc_id == run.creates_vpc_and_validates.aws_vpc.main.id
    error_message = "Subnet must belong to the created VPC"
  }
}
```

### Error Condition Validation with `expect_failures`

```hcl
# tests/validation.tftest.hcl

# Test that invalid inputs are rejected
run "rejects_invalid_environment" {
  command = plan

  variables {
    environment = "invalid"  # Not in allowed list
  }

  expect_failures = [
    var.environment,  # Expect the variable validation to fail
  ]
}

run "rejects_oversized_instance" {
  command = plan

  variables {
    environment   = "production"
    instance_type = "x2idn.metal"  # Blocked by validation rule
  }

  expect_failures = [
    var.instance_type,
  ]
}

# Validate that a check block fails under specific conditions
run "check_block_warns_on_public_access" {
  command = plan

  variables {
    enable_public_access = true
  }

  expect_failures = [
    check.no_public_access,
  ]
}
```

### Mock Providers (1.7+)

Mock providers let you test modules without any cloud credentials or API calls.

```hcl
# tests/with_mocks.tftest.hcl

# Mock the AWS provider entirely — no credentials needed
mock_provider "aws" {}

variables {
  environment   = "production"
  instance_type = "t3.large"
  ami_id        = "ami-mock12345"
}

run "production_gets_large_instance" {
  command = plan

  assert {
    condition     = aws_instance.app.instance_type == "t3.large"
    error_message = "Production should use t3.large"
  }
}

run "tags_include_environment" {
  command = plan

  assert {
    condition     = aws_instance.app.tags["Environment"] == "production"
    error_message = "Environment tag must match variable"
  }
}
```

### Mock Provider with Overrides

```hcl
# tests/mock_with_overrides.tftest.hcl

# Mock provider with specific return values for data sources
mock_provider "aws" {
  # Override a data source to return controlled values
  override_data {
    target = data.aws_ami.latest
    values = {
      id           = "ami-test99999"
      architecture = "x86_64"
      name         = "test-ami-2026"
    }
  }

  # Override a resource to control computed attributes
  override_resource {
    target = aws_instance.app
    values = {
      public_ip  = "203.0.113.50"
      private_ip = "10.0.1.100"
    }
  }
}

variables {
  environment = "staging"
}

run "ami_lookup_returns_expected_id" {
  command = plan

  assert {
    condition     = aws_instance.app.ami == "ami-test99999"
    error_message = "Instance should use the mocked AMI"
  }
}

run "outputs_use_overridden_ip" {
  command = apply

  assert {
    condition     = output.app_public_ip == "203.0.113.50"
    error_message = "Output should reflect the mocked public IP"
  }
}
```

### Running Tests

```bash
# Run all tests
terraform test

# Run a specific test file
terraform test -filter=tests/basic.tftest.hcl

# Verbose output
terraform test -verbose

# With variable overrides
terraform test -var="environment=staging"
```

---

## Terratest (Go)

Use Terratest when you need to validate **external behavior** that Terraform cannot observe — HTTP endpoints, SSH connectivity, DNS resolution, API responses, database connectivity.

### When to Use Terratest Over Native Tests

| Scenario | Use |
|----------|-----|
| Validate plan output, variable logic, conditionals | `terraform test` |
| Check computed attributes match expectations | `terraform test` with mocks |
| Verify a deployed web server responds with 200 | **Terratest** |
| SSH into a VM and check installed packages | **Terratest** |
| Validate a Kubernetes deployment is healthy | **Terratest** |
| Test cross-module interactions with real APIs | **Terratest** |

### Basic Test Pattern

```go
// test/vpc_test.go
package test

import (
    "testing"

    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestVpcModule(t *testing.T) {
    t.Parallel()

    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../modules/vpc",
        Vars: map[string]interface{}{
            "vpc_cidr":     "10.99.0.0/16",
            "environment":  "test",
            "subnet_count": 2,
        },
    })

    // Clean up resources after test
    defer terraform.Destroy(t, terraformOptions)

    // Deploy
    terraform.InitAndApply(t, terraformOptions)

    // Validate outputs
    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcId)
    assert.Regexp(t, `^vpc-[a-z0-9]+$`, vpcId)

    subnetIds := terraform.OutputList(t, terraformOptions, "subnet_ids")
    assert.Len(t, subnetIds, 2)
}
```

### HTTP Validation

```go
package test

import (
    "crypto/tls"
    "testing"
    "time"

    http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
    "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestWebServerResponds(t *testing.T) {
    t.Parallel()

    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../modules/web-server",
        Vars: map[string]interface{}{
            "environment": "test",
        },
    })

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    url := terraform.Output(t, terraformOptions, "endpoint_url")

    // Retry up to 30 times with 10s between attempts (eventual consistency)
    tlsConfig := &tls.Config{}
    http_helper.HttpGetWithRetryWithCustomValidation(
        t,
        url,
        tlsConfig,
        30,              // max retries
        10*time.Second,  // sleep between retries
        func(statusCode int, body string) bool {
            return statusCode == 200
        },
    )
}
```

### Test Stages for Expensive Resources

Skip deploy/destroy when iterating on validation logic:

```go
package test

import (
    "testing"

    "github.com/gruntwork-io/terratest/modules/terraform"
    test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
    "github.com/stretchr/testify/assert"
)

func TestExpensiveInfra(t *testing.T) {
    t.Parallel()
    workingDir := "../modules/expensive"

    // STAGE: deploy
    test_structure.RunTestStage(t, "deploy", func() {
        terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
            TerraformDir: workingDir,
        })
        test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)
        terraform.InitAndApply(t, terraformOptions)
    })

    // STAGE: validate — skip deploy/destroy with SKIP_deploy=true SKIP_destroy=true
    test_structure.RunTestStage(t, "validate", func() {
        terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
        endpoint := terraform.Output(t, terraformOptions, "endpoint")
        assert.NotEmpty(t, endpoint)
    })

    // STAGE: destroy
    test_structure.RunTestStage(t, "destroy", func() {
        terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
        terraform.Destroy(t, terraformOptions)
    })
}
```

Usage: `SKIP_deploy=true SKIP_destroy=true go test -run TestExpensiveInfra` to re-run only the validation stage.

### Kubernetes Helpers

```go
package test

import (
    "testing"

    "github.com/gruntwork-io/terratest/modules/k8s"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/require"
)

func TestK8sDeployment(t *testing.T) {
    t.Parallel()

    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../modules/k8s-app",
    })

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    kubeconfig := terraform.Output(t, terraformOptions, "kubeconfig_path")
    options := k8s.NewKubectlOptions("", kubeconfig, "default")

    // Wait for deployment to be available
    k8s.WaitUntilDeploymentAvailable(t, options, "my-app", 30, 10)

    // Validate the service exists
    service := k8s.GetService(t, options, "my-app-service")
    require.Equal(t, "LoadBalancer", string(service.Spec.Type))
}
```

---

## Static Analysis Tools

### tflint

Provider-aware linter that catches issues `terraform validate` misses — invalid instance types, deprecated arguments, naming convention violations.

**AWS ruleset alone has 700+ rules.**

#### Configuration

```hcl
# .tflint.hcl

config {
  # Module inspection — follow module sources
  call_module_type = "local"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.35.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Custom rules
rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}
```

#### Usage

```bash
# Install plugins
tflint --init

# Run against current directory
tflint

# Run recursively across modules
tflint --recursive

# Output as SARIF for GitHub code scanning
tflint --format sarif > results.sarif

# Specific config file
tflint --config .tflint.hcl
```

### terraform-docs

Auto-generates module documentation from variable/output/resource declarations.

#### Configuration

```yaml
# .terraform-docs.yml
formatter: markdown table

output:
  file: README.md
  mode: inject  # Replace content between markers

content: |-
  {{ .Header }}

  ## Usage

  ```hcl
  module "example" {
    source = "path/to/module"
    {{ range .Module.RequiredInputs }}
    {{ .Name }} = # {{ .Description }}
    {{ end }}
  }
  ```

  {{ .Requirements }}
  {{ .Providers }}
  {{ .Inputs }}
  {{ .Outputs }}

sort:
  enabled: true
  by: required
```

#### Pre-commit Hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/terraform-docs/terraform-docs
    rev: v0.19.0
    hooks:
      - id: terraform-docs-go
        args: ["markdown", "table", "--output-file", "README.md"]
```

---

## Security Scanning

### Checkov (Recommended)

1000+ built-in policies with graph-based cross-resource analysis. Actively maintained by Prisma Cloud (Palo Alto Networks). Supports custom checks in Python or YAML.

#### Basic Usage

```bash
# Scan current directory
checkov -d .

# Scan a specific plan file
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
checkov -f tfplan.json

# Output formats
checkov -d . -o json         # JSON output
checkov -d . -o sarif        # SARIF for GitHub
checkov -d . -o cli          # Terminal (default)

# Skip specific checks
checkov -d . --skip-check CKV_AWS_18,CKV_AWS_21

# Run only specific frameworks
checkov -d . --framework terraform

# External checks directory
checkov -d . --external-checks-dir ./custom_checks/
```

#### Custom Check (Python)

```python
# custom_checks/require_encryption.py
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck
from checkov.common.models.enums import CheckResult, CheckCategories

class S3BucketEncryption(BaseResourceCheck):
    def __init__(self):
        name = "Ensure S3 bucket has server-side encryption"
        id = "CUSTOM_AWS_001"
        supported_resources = ["aws_s3_bucket"]
        categories = [CheckCategories.ENCRYPTION]
        super().__init__(name=name, id=id,
                         categories=categories,
                         supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        # Check for encryption configuration
        if "server_side_encryption_configuration" in conf:
            return CheckResult.PASSED
        return CheckResult.FAILED

check = S3BucketEncryption()
```

#### Custom Check (YAML)

```yaml
# custom_checks/require_tags.yaml
metadata:
  id: "CUSTOM_001"
  name: "Ensure all resources have required tags"
  severity: "HIGH"
  category: "CONVENTION"

scope:
  provider: aws

definition:
  cond_type: attribute
  resource_types:
    - aws_instance
    - aws_s3_bucket
    - aws_rds_instance
  attribute: tags.Environment
  operator: exists
```

#### CI/CD Integration (GitHub Actions)

```yaml
# .github/workflows/checkov.yml
name: Checkov
on: [pull_request]

jobs:
  checkov:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Checkov
        uses: bridgecrewio/checkov-action@v12
        with:
          directory: .
          framework: terraform
          output_format: sarif
          output_file_path: results.sarif
          soft_fail: false  # Fail the pipeline on violations
      - name: Upload SARIF
        if: always()
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: results.sarif
```

### Trivy (formerly tfsec)

> **WARNING (2026):** In March 2026, a supply chain compromise was discovered affecting certain Trivy distribution channels. Before using Trivy, verify installation integrity:
> - Install only via official channels (aquasecurity GitHub releases, `brew install trivy`)
> - Verify checksums against https://github.com/aquasecurity/trivy/releases
> - Pin to a specific verified version in CI/CD
> - Monitor https://github.com/aquasecurity/trivy/security for advisories

tfsec is deprecated and has been merged into Trivy. All tfsec rules are available in Trivy's config scanner.

#### Usage

```bash
# Scan Terraform files
trivy config .

# Scan with specific severity threshold
trivy config --severity HIGH,CRITICAL .

# Output as SARIF
trivy config --format sarif --output results.sarif .

# Scan a plan file
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
trivy config tfplan.json

# Skip specific checks
trivy config --skip-dirs modules/legacy --skip-policy AVD-AWS-0086 .
```

### Terrascan

> **ARCHIVED (November 2025):** Terrascan was archived by Tenable in November 2025 and is no longer maintained. Migrate existing Terrascan policies to **Checkov** or **KICS** (Keeping Infrastructure as Code Secure).
>
> Migration path:
> - Terrascan custom Rego policies → Checkov custom Python/YAML checks or OPA/Conftest
> - Terrascan built-in rules → Checkov covers all equivalent checks with its 1000+ policy library

---

## Policy as Code

### OPA / Conftest (Vendor-Neutral, Recommended for Open-Source)

Open Policy Agent with Conftest provides vendor-neutral policy enforcement against Terraform plan JSON. Works with Spacelift, Scalr, and any CI system.

#### Generate Plan JSON

```bash
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
```

#### Rego Policies

```rego
# policy/terraform/required_tags.rego
package terraform.required_tags

import rego.v1

# Define required tags for all resources
required_tags := {"Environment", "Owner", "Project", "CostCenter"}

# Find resources missing required tags
deny contains msg if {
    resource := input.resource_changes[_]
    resource.change.actions[_] == "create"

    tags := object.get(resource.change.after, "tags", {})
    missing := required_tags - {key | tags[key]}
    count(missing) > 0

    msg := sprintf(
        "%s '%s' is missing required tags: %v",
        [resource.type, resource.address, missing]
    )
}
```

```rego
# policy/terraform/no_public_s3.rego
package terraform.s3_security

import rego.v1

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_acl"
    resource.change.actions[_] == "create"
    resource.change.after.acl == "public-read"

    msg := sprintf(
        "S3 bucket ACL '%s' must not be public-read",
        [resource.address]
    )
}

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    resource.change.actions[_] == "create"
    resource.change.after.block_public_acls == false

    msg := sprintf(
        "S3 public access block '%s' must block public ACLs",
        [resource.address]
    )
}
```

```rego
# policy/terraform/restrict_regions.rego
package terraform.regions

import rego.v1

allowed_regions := {"us-east-1", "us-west-2", "eu-west-1"}

deny contains msg if {
    resource := input.configuration.provider_config.aws
    region := resource.expressions.region.constant_value
    not region in allowed_regions

    msg := sprintf("AWS region '%s' is not allowed. Use one of: %v", [region, allowed_regions])
}
```

#### Running Conftest

```bash
# Test plan JSON against policies
conftest test tfplan.json -p policy/terraform/

# Test with specific output format
conftest test tfplan.json -p policy/ -o json

# Test with custom namespace
conftest test tfplan.json -p policy/ --namespace terraform.required_tags

# Combine with policy bundles from OCI registries
conftest pull oci://registry.example.com/policies/terraform:latest
conftest test tfplan.json -p policy/
```

### Sentinel (HashiCorp Enterprise)

Available only in HCP Terraform (formerly Terraform Cloud) and Terraform Enterprise. Requires Plus tier — the free tier was discontinued in March 2026.

#### Sentinel Policy Example

```python
# restrict-instance-types.sentinel
import "tfplan/v2" as tfplan

allowed_types = ["t3.micro", "t3.small", "t3.medium", "t3.large"]

main = rule {
    all tfplan.resource_changes as _, rc {
        rc.type is "aws_instance" and
        rc.change.actions contains "create" implies
        rc.change.after.instance_type in allowed_types
    }
}
```

```python
# enforce-tags.sentinel
import "tfplan/v2" as tfplan

required_tags = ["Environment", "Owner", "Project"]

main = rule {
    all tfplan.resource_changes as _, rc {
        rc.change.actions contains "create" implies
        all required_tags as tag {
            rc.change.after.tags contains tag
        }
    }
}
```

#### Sentinel Policy Set Configuration

```json
{
  "sentinel": {
    "version": "0.25.1"
  },
  "policies": [
    {
      "path": "restrict-instance-types.sentinel",
      "enforcement_level": "hard-mandatory"
    },
    {
      "path": "enforce-tags.sentinel",
      "enforcement_level": "soft-mandatory"
    }
  ]
}
```

---

## Cost Estimation

### Infracost

Estimates cloud costs from Terraform code before deployment. Supports AWS, GCP, Azure, and 1M+ price points.

#### Basic Usage

```bash
# Generate cost breakdown for current directory
infracost breakdown --path .

# Compare costs between current state and planned changes
infracost diff --path .

# Use with a plan file for accuracy
terraform plan -out=tfplan
infracost breakdown --path tfplan.json

# Output as JSON for programmatic use
infracost breakdown --path . --format json > costs.json
```

#### PR Comment Integration (GitHub Actions)

```yaml
# .github/workflows/infracost.yml
name: Infracost
on: [pull_request]

jobs:
  infracost:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v4

      - name: Setup Infracost
        uses: infracost/actions/setup@v3
        with:
          api-key: ${{ secrets.INFRACOST_API_KEY }}

      - name: Generate cost diff
        run: |
          infracost diff \
            --path=. \
            --format=json \
            --out-file=/tmp/infracost.json

      - name: Post PR comment
        uses: infracost/actions/comment@v3
        with:
          path: /tmp/infracost.json
          behavior: update  # Update existing comment instead of new one
```

#### Budget Guardrails with OPA

```rego
# policy/cost/budget.rego
package cost.budget

import rego.v1

monthly_budget := 5000  # USD

deny contains msg if {
    cost := input.totalMonthlyCost
    to_number(cost) > monthly_budget
    msg := sprintf(
        "Estimated monthly cost $%s exceeds budget of $%d",
        [cost, monthly_budget]
    )
}

warn contains msg if {
    cost := input.totalMonthlyCost
    to_number(cost) > monthly_budget * 0.8
    to_number(cost) <= monthly_budget
    msg := sprintf(
        "Estimated monthly cost $%s is within 20%% of budget ($%d)",
        [cost, monthly_budget]
    )
}
```

```bash
# Run cost policy check
infracost breakdown --path . --format json | conftest test - -p policy/cost/
```

---

## Drift Detection

Infrastructure drift occurs when the real-world state diverges from the Terraform state — manual changes, out-of-band scripts, other tools modifying the same resources.

### Scheduled Plan with `-refresh-only`

```bash
# detect-drift.sh — run on a cron schedule
#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="/path/to/terraform/root"
ALERT_WEBHOOK="${DRIFT_ALERT_WEBHOOK_URL}"

cd "$WORKSPACE_DIR"
terraform init -input=false

# Refresh state without applying, capture exit code
# Exit code 0 = no drift, 2 = drift detected
set +e
terraform plan -refresh-only -detailed-exitcode -out=drift.tfplan 2>&1 | tee drift-output.txt
EXIT_CODE=$?
set -e

if [ "$EXIT_CODE" -eq 2 ]; then
    DRIFT_SUMMARY=$(terraform show drift.tfplan | head -50)
    curl -X POST "$ALERT_WEBHOOK" \
        -H "Content-Type: application/json" \
        -d "{
            \"text\": \"Infrastructure drift detected\",
            \"details\": \"$(echo "$DRIFT_SUMMARY" | jq -Rs .)\"
        }"
    echo "DRIFT DETECTED — alert sent"
    exit 2
elif [ "$EXIT_CODE" -eq 0 ]; then
    echo "No drift detected"
else
    echo "Error running plan: exit code $EXIT_CODE"
    exit 1
fi
```

#### Cron Schedule

```cron
# Run drift detection every 6 hours
0 */6 * * * /opt/scripts/detect-drift.sh >> /var/log/drift-detection.log 2>&1
```

### Platform-Native Drift Detection

| Platform | Feature | How |
|----------|---------|-----|
| HCP Terraform | Health Assessments | Enable in workspace settings → automatic drift + continuous validation |
| Spacelift | Drift Detection | Enable per stack → scheduled plans with auto-reconciliation option |
| Terrateam | Drift Detection | Configure in `.terrateam/config.yml` → PR-based remediation |
| Atlantis | N/A | No built-in drift detection — use cron + `atlantis plan` |
| env0 | Drift Detection | Enable per environment → configurable schedule and notifications |

### Alerting Patterns

```yaml
# Example: GitHub Actions cron for drift detection
name: Drift Detection
on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours

jobs:
  detect-drift:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform init -input=false

      - name: Detect Drift
        id: drift
        run: |
          terraform plan -refresh-only -detailed-exitcode -no-color 2>&1 | tee plan-output.txt
          echo "exitcode=$?" >> $GITHUB_OUTPUT
        continue-on-error: true

      - name: Create Issue on Drift
        if: steps.drift.outputs.exitcode == '2'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const output = fs.readFileSync('plan-output.txt', 'utf8');
            await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `Infrastructure Drift Detected - ${new Date().toISOString().split('T')[0]}`,
              body: `## Drift detected\n\n\`\`\`\n${output.substring(0, 60000)}\n\`\`\``,
              labels: ['drift', 'infrastructure']
            });
```

---

## Recommended Testing Stack (2026)

Run these in order — each layer catches issues the previous layers miss:

```
┌─────────────────────────────────────────────────────────────────────────┐
│  1. tflint           Lint + provider rules          Every commit       │
│  2. Checkov          Security scanning              Every commit       │
│  3. terraform test   Unit tests with mocks          Every commit       │
│  4. OPA/Conftest     Policy enforcement             Every PR           │
│  5. Terratest        Integration tests              Nightly / pre-prod │
│  6. Infracost        Cost estimation + guardrails   Every PR           │
│  7. Scheduled plan   Drift detection                Every 6 hours      │
│  8. terraform-docs   Documentation generation       Every commit       │
└─────────────────────────────────────────────────────────────────────────┘
```

### Unified CI Pipeline Example

```yaml
# .github/workflows/terraform-ci.yml
name: Terraform CI
on:
  pull_request:
    paths: ['**/*.tf', '**/*.tftest.hcl']

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: terraform-linters/setup-tflint@v4
      - run: tflint --init && tflint --recursive

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: bridgecrewio/checkov-action@v12
        with:
          directory: .
          framework: terraform

  unit-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - run: terraform init && terraform test

  policy:
    runs-on: ubuntu-latest
    needs: [lint, security]
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - uses: open-policy-agent/setup-opa@v2
      - run: |
          terraform init
          terraform plan -out=tfplan
          terraform show -json tfplan > tfplan.json
          conftest test tfplan.json -p policy/

  cost:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
      - uses: infracost/actions/setup@v3
        with:
          api-key: ${{ secrets.INFRACOST_API_KEY }}
      - run: infracost diff --path=. --format=json --out-file=/tmp/infracost.json
      - uses: infracost/actions/comment@v3
        with:
          path: /tmp/infracost.json

  docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: terraform-docs/gh-actions@v1
        with:
          working-dir: .
          output-method: inject
```

---

## Testing Strategy Matrix

| Strategy | Tools | Deploys Real Resources? | Speed | Confidence Level | CI Stage |
|----------|-------|------------------------|-------|-----------------|----------|
| Format & Validate | `terraform fmt -check`, `terraform validate` | No | Seconds | Low — syntax only | Pre-commit |
| Linting | tflint | No | Seconds | Medium — catches bad attrs, types | Every commit |
| Security Scan | Checkov, Trivy | No | Seconds | Medium-High — known anti-patterns | Every commit |
| Unit Test (mock) | `terraform test` + mock providers | No | Seconds | Medium-High — logic correctness | Every commit |
| Unit Test (plan) | `terraform test` with `command = plan` | No (needs creds for plan) | 10-30s | High — validates real provider schema | Every PR |
| Policy as Code | OPA/Conftest, Sentinel | No (reads plan JSON) | Seconds | High — org compliance | Every PR |
| Cost Estimation | Infracost | No | 10-30s | Medium — estimates, not actuals | Every PR |
| Integration Test | Terratest, `terraform test` with `command = apply` | **Yes** | Minutes-Hours | Very High — real-world behavior | Nightly / pre-release |
| Drift Detection | `terraform plan -refresh-only` | No (read-only refresh) | 30-60s | High — detects out-of-band changes | Scheduled (cron) |
| Manual Review | Human review of plan output | No | Hours | Highest — catches design flaws | Pre-merge |

### Cost vs. Confidence Tradeoff

```
Confidence ▲
           │                                          ● Manual Review
           │                                   ● Integration (Terratest)
           │                            ● Policy + Unit (plan)
           │                      ● Unit (mock) + Security
           │               ● Linting
           │        ● Format/Validate
           │
           └──────────────────────────────────────────► Cost / Time
```

Invest in the bottom layers first — they are fast, cheap, and catch the majority of issues. Add higher layers as your infrastructure matures and the blast radius of failures increases.
