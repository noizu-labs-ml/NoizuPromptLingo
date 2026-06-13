#!/usr/bin/env bash

# =============================================================================
# DOCTOR
# =============================================================================
cmd_doctor() {
  echo ""
  echo -e "${BLU}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${BLU}║  infra-init doctor                           ║${NC}"
  echo -e "${BLU}╚══════════════════════════════════════════════╝${NC}"

  ERRORS=0
  WARNINGS=0

  check_tool() {
    local cmd=$1 label=$2 hint=$3
    if command -v "$cmd" &>/dev/null; then
      local v; v=$("$cmd" --version 2>&1 | head -1)
      ok "$label: $v"
    else
      fail "$label not found — install: $hint"
      ((ERRORS++)) || true
    fi
  }

  # --- Tools -----------------------------------------------------------------
  step "Tools"
  check_tool terraform   "Terraform"   "brew install hashicorp/tap/terraform"
  check_tool terraformer "Terraformer" "brew install terraformer"
  check_tool aws         "AWS CLI"     "brew install awscli"
  check_tool kubectl     "kubectl"     "brew install kubectl"
  check_tool helm        "Helm"        "brew install helm"
  check_tool git         "git"         "xcode-select --install"

  if command -v terraform &>/dev/null; then
    TF_VER=$(terraform version -json 2>/dev/null \
      | python3 -c "import sys,json; print(json.load(sys.stdin)['terraform_version'])" 2>/dev/null \
      || terraform version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    TF_MINOR=$(echo "$TF_VER" | cut -d. -f2)
    TF_MAJOR=$(echo "$TF_VER" | cut -d. -f1)
    if [[ "$TF_MAJOR" -lt 1 ]] || { [[ "$TF_MAJOR" -eq 1 ]] && [[ "$TF_MINOR" -lt 5 ]]; }; then
      warn "Terraform $TF_VER < 1.5 — upgrade: brew upgrade terraform"
      ((WARNINGS++)) || true
    fi
  fi

  # --- AWS credentials -------------------------------------------------------
  step "AWS credentials (profile: $PROFILE)"

  if ! aws configure get aws_access_key_id --profile "$PROFILE" &>/dev/null; then
    fail "Profile '$PROFILE' not configured"
    if [[ -n "$ONE_PASS_LINK" ]]; then
      info "Get keys from: $ONE_PASS_LINK"
    fi
    info "Then run: aws configure --profile $PROFILE"
    ((ERRORS++)) || true
  else
    IDENTITY=$(aws sts get-caller-identity --profile "$PROFILE" 2>&1) && {
      ACCOUNT=$(echo "$IDENTITY" | python3 -c "import sys,json; print(json.load(sys.stdin)['Account'])" 2>/dev/null \
        || echo "$IDENTITY" | grep -oE '"Account": "[0-9]+"' | grep -oE '[0-9]+')
      if [[ -n "$EXPECTED_ACCOUNT" ]]; then
        if [[ "$ACCOUNT" == "$EXPECTED_ACCOUNT" ]]; then
          ok "Authenticated — account $ACCOUNT"
        else
          fail "Wrong account: $ACCOUNT (expected $EXPECTED_ACCOUNT)"
          ((ERRORS++)) || true
        fi
      else
        ok "Authenticated — account $ACCOUNT"
      fi
    } || {
      fail "Credentials invalid or expired"
      info "Re-run: aws configure --profile $PROFILE"
      ((ERRORS++)) || true
    }
  fi

  # --- Terraform provider plugin ---------------------------------------------
  step "Terraform provider plugin"

  DR_OS="$(uname -s)"; DR_ARCH="$(uname -m)"
  case "${DR_OS}_${DR_ARCH}" in
    Darwin_arm64)  DR_PLATFORM="darwin_arm64" ;;
    Darwin_x86_64) DR_PLATFORM="darwin_amd64" ;;
    Linux_aarch64) DR_PLATFORM="linux_arm64"  ;;
    Linux_x86_64)  DR_PLATFORM="linux_amd64"  ;;
    *)             DR_PLATFORM="unknown"       ;;
  esac

  DR_PLUGIN_DIR="$HOME/.terraform.d/plugins/$DR_PLATFORM"
  DR_PLUGIN_FOUND=false

  if [[ -d "$DR_PLUGIN_DIR" ]] && find "$DR_PLUGIN_DIR" -name "terraform-provider-aws*" 2>/dev/null | grep -q .; then
    DR_PLUGIN_FOUND=true
  fi
  if ! $DR_PLUGIN_FOUND && find "$HOME/.terraform.d/plugins" -name "terraform-provider-aws*" 2>/dev/null | grep -q .; then
    DR_PLUGIN_FOUND=true
  fi

  if $DR_PLUGIN_FOUND; then
    ok "AWS provider plugin cached ($DR_PLATFORM)"
  else
    warn "AWS provider plugin not found for $DR_PLATFORM — run: infra-init terraform"
    ((WARNINGS++)) || true
  fi

  # --- Terraform init --------------------------------------------------------
  step "Terraform ($TF_DIR)"

  if [[ ! -d "$TF_DIR" ]]; then
    warn "$TF_DIR does not exist"
    ((WARNINGS++)) || true
  elif ! ls "$TF_DIR"/*.tf &>/dev/null 2>&1; then
    warn "No .tf files in $TF_DIR yet"
    ((WARNINGS++)) || true
  elif [[ ! -d "$TF_DIR/.terraform" ]]; then
    warn "terraform init not run — run: infra-init terraform"
    ((WARNINGS++)) || true
  else
    ok "$TF_DIR initialized"
  fi

  # --- Submodules ------------------------------------------------------------
  step "Git submodules (repos/)"

  cd "$REPO_ROOT"

  if [[ ! -f ".gitmodules" ]]; then
    info "No .gitmodules — skipping"
  else
    UNINITIALIZED=$(git submodule status 2>/dev/null | grep '^-' | awk '{print $2}')
    if [[ -n "$UNINITIALIZED" ]]; then
      fail "Uninitialized submodules:"
      echo "$UNINITIALIZED" | sed 's/^/    /'
      info "Fix: infra-init repos"
      ((ERRORS++)) || true
    else
      BEHIND=$(git submodule status 2>/dev/null | grep '^+' | awk '{print $2}')
      if [[ -n "$BEHIND" ]]; then
        warn "Submodules out of date (new commits available):"
        echo "$BEHIND" | sed 's/^/    /'
        info "Update: infra-init repos"
        ((WARNINGS++)) || true
      else
        ok "All submodules initialized and current"
      fi
    fi
  fi

  # --- direnv ----------------------------------------------------------------
  step "direnv (PATH_add utils)"

  if command -v direnv &>/dev/null; then
    ok "direnv installed"
    if ! command -v infra-init &>/dev/null; then
      warn "infra-init not in PATH — run 'direnv allow' in the repo root"
      ((WARNINGS++)) || true
    else
      ok "infra-init available in PATH"
    fi
  else
    warn "direnv not installed — utils/ won't be auto-added to PATH"
    info "Install: brew install direnv  then add 'eval \"\$(direnv hook bash)\"' to your shell rc"
    ((WARNINGS++)) || true
  fi

  # --- Summary ---------------------------------------------------------------
  echo ""
  echo -e "${BLU}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${BLU}║  Doctor Summary                              ║${NC}"
  echo -e "${BLU}╚══════════════════════════════════════════════╝${NC}"
  echo ""

  if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
    echo -e "  ${PASS} Everything looks healthy"
  elif [[ $ERRORS -eq 0 ]]; then
    echo -e "  ${WARN} $WARNINGS warning(s) — review above"
  else
    echo -e "  ${FAIL} $ERRORS error(s), $WARNINGS warning(s) — fix above and re-run"
  fi
  echo ""
}
