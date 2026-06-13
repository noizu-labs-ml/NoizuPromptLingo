# Script Reference

## bin/infra-init

Multi-command CLI for developer environment setup and infrastructure import.

| Subcommand | Purpose |
|------------|---------|
| `terraform` | Initialize Terraform provider plugins and run `terraform init` |
| `repos` | Hydrate git submodules |
| `all` | Run `repos` then `terraform` |
| `import` | Batch import existing AWS infrastructure via Terraformer (skips already-imported; `--force` to re-import) |
| `cleanup` | Strip invalid Terraformer attributes + AWS CLI spot-checks |
| `state-upgrade` | Migrate Terraformer legacy provider state to TF 1.x format |
| `doctor` | Verify tooling and configuration health |

Sources shared functions from `k8-lib/*.sh` (resolved relative to script location).

## bin/deploy-one-off

A **template** (not executable as-is) documenting the canonical Helm deployment order for disaster recovery or initial cluster bootstrapping:

1. Uncordon managed nodes
2. Infrastructure caches (Redis)
3. Infrastructure databases (TimescaleDB)
4. Secrets manager (Infisical)
5. Observability stack (SigNoz)
6. Application caches and databases
7. Read replicas and connection poolers
8. Primary database (last, since everything depends on it)
9. Stateless application services (rolling update)
10. Search / auxiliary services
11. Placement verification (managed nodes + Karpenter nodes)

Namespace controlled by `K8_NAMESPACE` (default: `default`).

## bin/open-dashboard

Port-forwards to cluster monitoring dashboards.

| Dashboard | Default Namespace | Default Service | Local Port |
|-----------|-------------------|-----------------|------------|
| `goldilocks` | `goldilocks` | `goldilocks-dashboard` | 8080 |
| `kubecost` | `kubecost` | `kubecost-cost-analyzer` | 9090 |
| `parca` | `parca` | `parca-server` | 7070 |
| `signoz` | `infra` | `signoz-frontend` | 3301 |

All values overridable via `K8_{TOOL}_NS` and `K8_{TOOL}_SVC` environment variables.

## bin/add-import-permissions

Applies the Terraformer IAM policy to the `terraformer-import` AWS IAM user. Reads the policy JSON from `terraform/production/imported/iam/terraformer-import-policy.json`.

| Flag | Purpose |
|------|---------|
| `--profile PROFILE` | AWS CLI profile (default: `$PROFILE` or `$K8_AWS_PROFILE` or `terraformer`) |
| `--dry-run` | Print what would be applied without making changes |
