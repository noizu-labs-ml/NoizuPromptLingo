#!/usr/bin/env bash

# =============================================================================
# HELP
# =============================================================================
cmd_help() {
cat <<EOF

  ${BLU}infra-init${NC} — Infrastructure setup tool

  ${BLU}Usage:${NC}
    infra-init <command>

  ${BLU}Commands:${NC}
    terraform      Set up Terraform: install AWS provider plugin, run terraform init
    repos          Hydrate git submodules (application repos)
    all            Run repos then terraform
    import         Batch import existing AWS infra via Terraformer; skips already-imported dirs
    import --force Re-import all groups even if resources.tf already exists
    cleanup        Strip Terraformer schema noise + AWS CLI spot-checks on counts
    state-upgrade  Migrate Terraformer legacy provider addresses to TF 1.x format,
                   then run terraform init in every imported service directory
    doctor         Verify tools, credentials, submodules and Terraform are all healthy
    --help         Show this help

  ${BLU}Examples:${NC}
    infra-init all           # First-time setup after cloning
    infra-init doctor        # Check everything is still working
    infra-init import        # Pull all existing AWS resources into imported/ (skips done)
    infra-init import --force  # Re-import everything
    infra-init cleanup       # Strip Terraformer schema noise
    infra-init state-upgrade # Fix legacy provider state + init all imported dirs
    infra-init terraform     # Re-run just the Terraform setup

  ${BLU}AWS Credentials:${NC}
    Requires the ${K8_AWS_PROFILE} AWS profile.${K8_CREDENTIALS_LINK:+
    Get keys from: $K8_CREDENTIALS_LINK}
    Then run: aws configure --profile ${K8_AWS_PROFILE}

EOF
}
