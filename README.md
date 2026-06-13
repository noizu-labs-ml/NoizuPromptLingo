# terraform-tools — Terraform Plan & State Migration

Utilities for batch Terraform planning and S3 state migration.

## Installation

```bash
make install    # Installs tf-plan-all and migrate-tfstate to ~/.local/bin
```

## Prerequisites

- `terraform` CLI
- `yq` (for config loading)
- AWS credentials configured (for S3 state migration)

## Configuration

`migrate-tfstate` loads settings from `infra-config.yaml` via the shared k8-lib config chain (see [k8-lib README](../k8-lib/README.md)). Relevant sections:

| YAML Path | Env Override | Purpose |
|-----------|-------------|---------|
| `.terraform.state_bucket` | `K8_TF_STATE_BUCKET` | S3 bucket for state storage |
| `.terraform.kms_alias` | `K8_TF_KMS_ALIAS` | KMS alias for state encryption |
| `.terraform.lock_table` | `K8_TF_LOCK_TABLE` | DynamoDB lock table (default: `terraform-lock`) |
| `.aws.profile` | `K8_AWS_PROFILE` | AWS CLI profile (default: `terraformer`) |
| `.aws.region` | `K8_AWS_REGION` | AWS region (default: `us-east-1`) |

`tf-plan-all` does not require configuration — it runs `terraform plan` across all root modules in a directory tree.

Every tool accepts `--config <path>` to specify an alternative config file.

## Tools

| Command | Purpose |
|---------|---------|
| `migrate-tfstate` | Add S3 backend config to a module and migrate its local state |
| `tf-plan-all` | Run `terraform plan` in every root module; print summary table |

## Usage

```bash
# Batch plan all modules
tf-plan-all                                     # Plan from current directory
tf-plan-all terraform/production/imported        # Plan a subtree

# Migrate local state to S3
migrate-tfstate terraform/production/services/eks
migrate-tfstate --dry-run terraform/production/iam    # Preview only
migrate-tfstate --upload terraform/production/iam     # Auto-approve migration
```

### tf-plan-all output

Prints a status table after scanning all root modules:

| Status | Meaning |
|--------|---------|
| No Changes | Module is clean |
| Has Changes | Drift detected — log retained in `tf-plan-logs/` |
| Error | `terraform plan` failed — log retained |

Logs for modules with changes or errors are saved to `<dir>/tf-plan-logs/`.
