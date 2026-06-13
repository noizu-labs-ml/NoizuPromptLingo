# SigNoz Monitoring — Terraform

Manages SigNoz alert rules, notification channels, and routing policies for `*.noizu.com` infrastructure via the [SigNoz Terraform Provider](https://github.com/SigNoz/terraform-provider-signoz) built from `repos/3rd/terraform-provider-signoz/`.

## Quick Start

```bash
# 1. Build provider from local source
./scripts/build-provider.sh

# 2. Configure
cp terraform.tfvars.example terraform.tfvars
# Set signoz_access_token from SigNoz > Settings > API Keys
# Or: export TF_VAR_signoz_access_token="..."

# 3. Deploy
terraform init
terraform plan
terraform apply
```

If Cloudflare Access blocks the provider's API calls:

```bash
./scripts/tf-with-portforward.sh plan
./scripts/tf-with-portforward.sh apply
```

## Provider

Uses the local build from `repos/3rd/terraform-provider-signoz/`. Run `./scripts/build-provider.sh` to compile and install, then configure `~/.terraformrc`:

```hcl
provider_installation {
  dev_overrides {
    "signoz/signoz" = "/Users/keithbrings/.local/share/terraform/plugins"
  }
  direct {}
}
```

## Alert Coverage

### Log-Based Alerts (10 rules via for_each)

| Alert | Tier | Namespace | Severity | Threshold | Services at Risk |
|-------|------|-----------|----------|-----------|-----------------|
| Production Error Logs | Application | all | Critical | >25 errors / 5m | All services |
| SigNoz/OTEL Export Failures | Observability | observability-ns | Warning | >3 failures / 5m | Telemetry pipeline |
| ClickHouse Errors | Data | data-ns | Critical | >5 errors / 5m | SigNoz, PostHog |
| Shared Postgres Errors | Data | data-ns | Critical | >10 errors / 5m | 17 app databases |
| Shared MySQL Errors | Data | data-ns | Critical | >10 errors / 5m | ghost, matomo, mautic, espocrm, seonaut |
| Mailu Postfix Errors | Mail | mail-ns | Warning | >5 errors / 5m | therobotlives.com email |
| vLLM Errors | AI | ai-ns | Warning | >5 errors / 5m | Weaviate vectorizer |
| Authentik Auth Errors | Platform | platform-ns | Critical | >10 errors / 5m | SSO (auth.noizu.com, auth.derobot.is) |
| Infisical Secret Sync | Secrets | infisical | Critical | >3 errors / 5m | All namespace secrets |

### Metric-Based Alerts (10 individual resources)

| Alert | Target | Severity | Threshold | Context |
|-------|--------|----------|-----------|---------|
| Shared Postgres Memory | data-ns/shared-postgres | Warning | >3 GiB (limit 4 GiB) | TimescaleDB, 17 databases |
| ClickHouse Memory | data-ns/shared-clickhouse | Critical | >12 GiB (max_memory 12GB, limit 15 GiB) | SigNoz + PostHog backend |
| Shared MySQL Memory | data-ns/shared-mysql | Warning | >6 GiB (limit 8 GiB) | 5 app databases |
| Redis/Valkey Memory | data-ns/shared-redis,valkey | Warning | >768 MiB (limit 1 GiB) | Cache evictions |
| vLLM Pod Memory | ai-ns/vllm | Warning | >20 GiB (limit 24 GiB) | e5-mistral-7b on V100 |
| Weaviate Memory | ai-ns/weaviate | Warning | >10 GiB (limit 12 GiB) | NPL memory system |
| Node Disk Usage | all nodes | Critical | >85% filesystem | ~985 GiB total PVC |
| Pod Restart Loop | all namespaces | Warning | >3 restarts / 15m | CrashLoopBackOff |
| Dovecot Storage | mail-ns | Warning | >40 GiB (PVC 50 GiB) | therobotlives.com mail |
| Docker Registry Storage | platform-ns | Warning | >400 GiB (PVC 500 GiB) | ops.noizu.com pushes |

## Phased Activation

All feature gates default to `false`. Enable in order:

1. **Apply with defaults** — creates alert rules (disabled) and channel/routing stubs
2. **Discover live state** — `./scripts/discover-api-state.sh`
3. **Enable channels** — `channels_enabled = true`, apply
4. **Test delivery** — send test alerts via SigNoz UI
5. **Enable routing** — `routing_enabled = true`, apply
6. **Enable alerts** — `alerts_enabled = true`, apply

## Scripts

| Script | Purpose |
|--------|---------|
| `build-provider.sh` | Build provider from `repos/3rd/terraform-provider-signoz/` |
| `tf-with-portforward.sh` | Run terraform via kubectl port-forward |
| `discover-api-state.sh` | Read-only SigNoz API state dump |
| `check-activation-status.sh` | Show feature gates, resource counts, env vars |

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `TF_VAR_signoz_access_token` | SigNoz API token |
| `TF_VAR_slack_webhook_url` | Slack incoming webhook |
| `TF_VAR_ops_webhook_url` | Operations webhook (n8n, PagerDuty, etc.) |
