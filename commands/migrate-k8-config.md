# Migrate Legacy Config to k8-util-config.yaml

Convert a project's legacy DevOps configuration files into the unified `k8-util-config.yaml` + `.k8-secrets.yaml` format used by k8-lib tools.

## Instructions

You are migrating legacy config files to the new unified YAML format. Follow these steps exactly.

### Step 1: Locate Legacy Files

Find and read these files at the project root (the directory containing `.git`):

| File | Required | Format |
|------|----------|--------|
| `config.env` | yes | Shell `KEY=VALUE` exports |
| `tiers.yaml` | yes | YAML with `.tiers[].charts[]` |
| `namespaces.conf` | yes | `release-name=namespace` per line |
| `timeout-overrides.conf` | yes | `chart-name=timeout` per line |
| `.envrc` | optional | Shell exports (may contain secrets to extract) |

If any are missing, note it and proceed with what exists.

### Step 2: Read the Schema Template

Read the example file for reference:
```
utilities/devops/k8-lib/k8-util-config.yaml.example
utilities/devops/k8-lib/.k8-secrets.yaml.example
```

### Step 3: Generate k8-util-config.yaml

Create `k8-util-config.yaml` at the project root with these rules:

1. **`apiVersion: k8-lib/v1`** at the top
2. **`secrets_file: .k8-secrets.yaml`** pointer
3. **`paths`** section — compute relative paths from the config file to:
   - `helm_dir`: where Helm charts live (usually `helm`)
   - `terraform_dir`: Terraform root (usually `terraform`)
   - `projects_dir`: where `project.yaml` files are discovered
4. **`aws`** section — from `config.env` `K8_AWS_PROFILE`, `K8_AWS_REGION`. Do NOT include `K8_AWS_ACCOUNT_ID` (goes in secrets).
5. **`docker`** section — from `K8_DOCKER_REGISTRY`
6. **`kubernetes`** section — from `K8_NAMESPACE`, `K8_STAGING_NAMESPACE`, `K8_INFRA_NAMESPACE`
7. **`infisical`** section — `host` and `project_id` only. `client_id`/`client_secret` go in secrets file.
8. **`terraform`** section — from `K8_TF_STATE_BUCKET`, `K8_TF_KMS_ALIAS`, `K8_TF_LOCK_TABLE`, `K8_TF_IMPORT_USER`, `K8_TF_IMPORT_POLICY_NAME`
9. **`helm`** section — `oci_registry` and `registry_host` only. `registry_user` goes in secrets.
10. **`preferences`** section — from `K8_DIFF_VIEWER`, `K8_ADMIN_EMAIL`, `K8_CREDENTIALS_LINK`
11. **`database`** section — from `K8_DB_NAME`, `K8_DB_USER_PREFIX`, `K8_PGBOUNCER_HOST` (if present)
12. **`status_patterns`** section — from `K8_STATUS_*_PATTERN` variables (if present)
13. **`tiers`** section — copy the `.tiers` array from `tiers.yaml` verbatim
14. **`namespace_overrides`** section — convert `namespaces.conf` KEY=VALUE lines to YAML map:
    ```
    infisical=infisical  →  infisical: infisical
    shared-postgres=data-ns  →  shared-postgres: data-ns
    ```
    Skip comment lines (starting with `#`) and blank lines.
15. **`timeout_overrides`** section — convert `timeout-overrides.conf` the same way:
    ```
    vllm=120m  →  vllm: 120m
    ```

### Step 4: Generate .k8-secrets.yaml

Create `.k8-secrets.yaml` at the project root with credential values extracted from `config.env` and `.envrc`:

```yaml
aws:
  account_id: "<from K8_AWS_ACCOUNT_ID>"
infisical:
  client_id: "<from K8_INFISICAL_CLIENT_ID or OPERATOR_CLIENT_ID>"
  client_secret: "<from K8_INFISICAL_CLIENT_SECRET or OPERATOR_CLIENT_SECRET>"
helm:
  registry_user: "<from K8_HELM_REGISTRY_USER>"
```

If values reference env vars (e.g., `${OPERATOR_CLIENT_ID}`), leave them as empty strings with a comment noting which env var to set.

### Step 5: Update .gitignore

Add `.k8-secrets.yaml` to `.gitignore` if not already present.

### Step 6: Verify

1. Run `yq eval '.' k8-util-config.yaml` to validate YAML syntax
2. Run `yq eval '.' .k8-secrets.yaml` to validate secrets YAML
3. Count entries: namespace_overrides should match lines in namespaces.conf, timeout_overrides should match timeout-overrides.conf, tiers should match tiers.yaml

### Step 7: Report

Show a summary:
- Files created
- Number of settings migrated per section
- Any values that couldn't be migrated (with reason)
- Reminder to test with `helm-upgrade --config ./k8-util-config.yaml --list`

## Important

- NEVER put secrets in `k8-util-config.yaml` — it will be committed to git
- All paths must be RELATIVE to the config file's directory
- Preserve comments from the example template where helpful
- Do not delete the legacy files — they serve as fallback until verified
- Empty string values (`""`) are fine for optional fields
