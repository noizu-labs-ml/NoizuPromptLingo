# terraform-tools — Architecture Summary

Lightweight CLI toolkit with two Terraform helper scripts installed via Makefile.

- **tf-plan-all**: Batch `terraform plan` across a directory tree; zsh-based; logs + Unicode summary table
- **migrate-tfstate**: Generates S3 backend config and migrates local state; bash-based; env-var driven
- **Makefile**: `compile`/`test`/`install` targets; installs scripts to `~/.local/bin`
- **Design**: Independent scripts, zsh glob qualifiers for discovery, environment-driven S3 config
