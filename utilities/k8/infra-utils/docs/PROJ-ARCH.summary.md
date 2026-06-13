# infra-tools — Architecture Summary

CLI toolkit for Kubernetes cluster management. Four scripts in `bin/` handle developer setup (`infra-init`), ordered Helm deployments (`deploy-one-off`), monitoring dashboard port-forwarding (`open-dashboard`), and AWS IAM policy management (`add-import-permissions`). Installed via `make install` to `~/.local/bin`. `infra-init` shares a common shell library (`k8-lib/`); other scripts are self-contained. Configuration is environment-driven via `K8_*` variables with defaults.
