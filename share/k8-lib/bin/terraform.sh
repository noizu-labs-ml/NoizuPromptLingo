#!/usr/bin/env bash

# =============================================================================
# TERRAFORM
# =============================================================================
cmd_terraform() {
  echo ""
  echo -e "${BLU}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${BLU}║  infra-init terraform                        ║${NC}"
  echo -e "${BLU}╚══════════════════════════════════════════════╝${NC}"

  # --- Detect OS + arch ------------------------------------------------------
  OS="$(uname -s)"   # Darwin or Linux
  ARCH="$(uname -m)" # arm64, x86_64

  case "${OS}_${ARCH}" in
    Darwin_arm64)   PLUGIN_PLATFORM="darwin_arm64" ;;
    Darwin_x86_64)  PLUGIN_PLATFORM="darwin_amd64" ;;
    Linux_aarch64)  PLUGIN_PLATFORM="linux_arm64"  ;;
    Linux_x86_64)   PLUGIN_PLATFORM="linux_amd64"  ;;
    *)              PLUGIN_PLATFORM="unknown"       ;;
  esac

  info "Platform: $OS $ARCH ($PLUGIN_PLATFORM)"

  # --- Provider plugin -------------------------------------------------------
  step "Installing Terraform AWS provider plugin"

  PLUGIN_DIR="$HOME/.terraform.d/plugins/$PLUGIN_PLATFORM"
  PLUGIN_FOUND=false

  if [[ -d "$PLUGIN_DIR" ]] && find "$PLUGIN_DIR" -name "terraform-provider-aws*" 2>/dev/null | grep -q .; then
    PLUGIN_FOUND=true
  fi

  # Fallback: check generic plugins dir (older Terraform layout)
  if ! $PLUGIN_FOUND && find "$HOME/.terraform.d/plugins" -name "terraform-provider-aws*" 2>/dev/null | grep -q .; then
    PLUGIN_FOUND=true
  fi

  if $PLUGIN_FOUND; then
    ok "AWS provider plugin already cached for $PLUGIN_PLATFORM"
  else
    info "Downloading provider and mirroring to $PLUGIN_DIR..."
    INIT_DIR=$(mktemp -d)
    cat > "$INIT_DIR/main.tf" <<'EOF'
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" { region = "us-east-1" }
EOF
    terraform -chdir="$INIT_DIR" init -no-color 2>&1 \
      | grep -E "Installing|installed|provider" | sed 's/^/  /'

    # Mirror to the platform-specific path Terraformer expects
    mkdir -p "$HOME/.terraform.d/plugins"
    terraform -chdir="$INIT_DIR" providers mirror "$HOME/.terraform.d/plugins" -no-color 2>&1 \
      | sed 's/^/  /'

    rm -rf "$INIT_DIR"

    if find "$HOME/.terraform.d/plugins" -name "terraform-provider-aws*" 2>/dev/null | grep -q .; then
      ok "AWS provider plugin installed for $PLUGIN_PLATFORM"
    else
      fail "Plugin install failed — check output above"
      return 1
    fi
  fi

  # --- Terraform init --------------------------------------------------------
  step "Running terraform init in terraform/production/"

  if [[ ! -d "$TF_DIR" ]]; then
    warn "terraform/production/ does not exist yet — skipping"
    info "Create your .tf files there first, then re-run infra-init terraform"
    return
  fi

  if ! ls "$TF_DIR"/*.tf &>/dev/null 2>&1; then
    warn "No .tf files in terraform/production/ yet — skipping terraform init"
    info "Add your Terraform files then re-run infra-init terraform"
    return
  fi

  terraform -chdir="$TF_DIR" init -no-color 2>&1 \
    | grep -E "Initializing|Success|provider|backend" | sed 's/^/  /' \
    || { warn "terraform init had issues — check output above"; return; }

  ok "terraform init complete"

  echo ""
  echo -e "  ${PASS} Terraform ready"
  echo -e "  ${INFO} Next: terraform -chdir=terraform/production plan"
  echo ""
}
