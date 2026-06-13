# secrets-tools Architecture Summary

CLI toolkit for bootstrapping Kubernetes secrets via Infisical. Two Bash scripts: `hydrate-envrc` generates `.envrc` from annotated templates (password/hex/django generators, cross-variable inheritance), and `infisical-populate-secrets` pushes resolved values into 18 Infisical folders via REST API with parallel writes and idempotent create-or-update logic. Supports prod seeding, prod-to-staging cloning, and dry-run preview. Installed to `~/.local/bin` via Makefile.
