# Project Architecture Summary

CLI utilities and SQL templates for managing TimescaleDB/PostgreSQL on Kubernetes with AWS EBS storage.

## Components

- **bin/tsdb-snapshot** -- EBS snapshot tool with crash-consistent (default) and app-consistent modes
- **bin/pgbouncer-auth-setup.sql** -- PgBouncer auth user + read-only user provisioning
- **bin/sql/create-migrate-user.sql** -- Migration role with scoped DDL privileges
- **Makefile** -- Installs tsdb-snapshot to ~/.local/bin

## Design Principles

- Crash-consistent snapshots by default; app-consistent opt-in via --consistent flag
- Least-privilege SQL roles with SECURITY DEFINER for credential lookup
- Template-based SQL with manual variable substitution before execution

## Dependencies

k8-lib/common.sh (shell helpers), kubectl, aws CLI, psql
