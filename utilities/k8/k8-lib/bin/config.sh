#!/usr/bin/env bash
# =============================================================================
# config.sh — Load configuration for k8-lib tools
#
# Reads from infra-config.yaml via config-resolver.sh.
# All values can also be set as environment variables before sourcing.
# =============================================================================

_K8_LIB_DIR="${K8_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Source the unified config resolver
source "$_K8_LIB_DIR/bin/config-resolver.sh"

# Resolve the config file
_resolve_config

# Load all K8_* variables from YAML (env vars override)
_load_k8_vars
