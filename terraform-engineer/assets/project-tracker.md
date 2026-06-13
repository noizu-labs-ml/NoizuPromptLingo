# Terraform Project Tracker

## Project Information

| Field | Value |
|-------|-------|
| **Project Name** | |
| **Cloud Provider(s)** | |
| **Terraform Version** | |
| **State Backend** | |
| **CI/CD Tool** | |
| **Start Date** | |
| **Target Date** | |

## Module Inventory

| Module | Status | State File | Provider(s) | Resources | Tests |
|--------|--------|-----------|-------------|-----------|-------|
| networking | | | | | |
| compute | | | | | |
| data | | | | | |
| monitoring | | | | | |
| security | | | | | |

Status: `planned` | `in-progress` | `tested` | `deployed` | `production`

## Environment Matrix

| Environment | Backend Key | Service Account | Policy Checks | Status |
|-------------|------------|-----------------|---------------|--------|
| dev | | | | |
| staging | | | | |
| production | | | | |

## Quality Gates

| Check | Tool | Passing | Notes |
|-------|------|---------|-------|
| Format | `terraform fmt` | | |
| Validate | `terraform validate` | | |
| Lint | tflint | | |
| Security | Checkov | | |
| Unit Tests | terraform test | | |
| Integration | Terratest | | |
| Cost | Infracost | | |
| Drift | Scheduled plan | | |
| Docs | terraform-docs | | |

## Provider Versions

| Provider | Constraint | Lock File Version | Last Updated |
|----------|-----------|-------------------|--------------|
| | | | |

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| State corruption | Low | Critical | Versioned backend, regular backups |
| Accidental destroy | Medium | Critical | prevent_destroy, plan review |
| Provider breaking change | Medium | High | Version pinning, lock file |
| Secrets exposure | Low | Critical | sensitive=true, encryption, no VCS |
| Concurrent applies | Medium | High | State locking, CI concurrency |

## Notes

<!--
Track decisions, blockers, and learnings here.
-->
