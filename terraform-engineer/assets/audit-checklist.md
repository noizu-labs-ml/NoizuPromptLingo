# Terraform Configuration Audit Checklist

Use this checklist before deploying any Terraform configuration to production.

## Structure and Organization

- [ ] File naming follows convention (main.tf, variables.tf, outputs.tf, providers.tf, versions.tf, locals.tf)
- [ ] `versions.tf` declares `required_version` with pessimistic constraint
- [ ] `versions.tf` declares `required_providers` with version constraints
- [ ] `.terraform.lock.hcl` is committed to version control
- [ ] No provider blocks in child modules (passed from root via `providers`)
- [ ] No backend blocks in child modules (only root modules)
- [ ] Large modules split by resource type (networking.tf, compute.tf, iam.tf)

## Variables and Outputs

- [ ] All variables have explicit `type` declarations
- [ ] All variables have `description` fields
- [ ] User-facing variables have `validation` blocks
- [ ] Sensitive variables marked `sensitive = true`
- [ ] No default values for secrets/credentials
- [ ] Boolean variables prefixed with `enable_` or `is_`
- [ ] List/map variables use plural names
- [ ] Outputs have `description` fields
- [ ] Sensitive outputs marked `sensitive = true`
- [ ] Outputs expose only what consumers need

## Resources and Data Sources

- [ ] Resource names use underscores, not dashes
- [ ] Resource names don't repeat the resource type
- [ ] `for_each` used for named collections (not `count`)
- [ ] `count` used only for zero-or-one toggles
- [ ] No hardcoded IDs — data sources used for lookups
- [ ] No circular dependencies
- [ ] `depends_on` used only when implicit dependencies are impossible
- [ ] Dynamic blocks have explicit iterator names when nested

## State Management

- [ ] Remote backend configured with encryption at rest
- [ ] State locking enabled (DynamoDB/native for S3, built-in for GCS/Azure)
- [ ] State bucket blocks public access
- [ ] State bucket has versioning enabled
- [ ] State split by blast radius (networking, compute, data separate)
- [ ] Environments use separate state files

## Security

- [ ] No secrets in `.tf` or `.tfvars` files committed to VCS
- [ ] `.tfvars` with secrets listed in `.gitignore`
- [ ] IAM policies follow least privilege (no wildcard actions or resources)
- [ ] Service accounts scoped per environment
- [ ] CI/CD uses OIDC federation (no long-lived credentials)
- [ ] Policy-as-code scanner (Checkov/tfsec) in CI pipeline
- [ ] `prevent_destroy` on stateful resources (databases, volumes, buckets with data)
- [ ] `-auto-approve` not used in production pipelines

## Lifecycle and Safety

- [ ] `create_before_destroy` on resources that cause downtime when replaced
- [ ] `prevent_destroy` on databases, persistent volumes, S3 buckets with data
- [ ] `ignore_changes` for externally-managed attributes (ASG size, tags from AWS Config)
- [ ] `moved` blocks used for refactoring (not `terraform state mv`)
- [ ] Timeouts set for slow-creating resources (RDS, EKS, CloudFront)

## Testing

- [ ] `terraform fmt` passes
- [ ] `terraform validate` passes
- [ ] tflint passes with provider ruleset
- [ ] Security scanner (Checkov) passes or exceptions documented
- [ ] `.tftest.hcl` files exist for critical modules
- [ ] Plan reviewed before apply (never blind apply)

## Documentation

- [ ] README.md generated with terraform-docs
- [ ] Module has usage examples in examples/ directory
- [ ] CHANGELOG.md tracks version changes (for published modules)
- [ ] Non-obvious design decisions documented in comments

## CI/CD Pipeline

- [ ] Plan-on-PR workflow configured
- [ ] Plan output posted as PR comment
- [ ] Apply requires approval for production
- [ ] Concurrency controls prevent parallel applies
- [ ] Drift detection scheduled (weekday cron)
- [ ] Cost estimation (Infracost) in PR comments
