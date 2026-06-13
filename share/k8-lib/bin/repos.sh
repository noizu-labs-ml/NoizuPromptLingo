#!/usr/bin/env bash

# =============================================================================
# REPOS
# =============================================================================
cmd_repos() {
  echo ""
  echo -e "${BLU}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${BLU}║  infra-init repos                            ║${NC}"
  echo -e "${BLU}╚══════════════════════════════════════════════╝${NC}"

  step "Hydrating git submodules"

  cd "$REPO_ROOT"

  if [[ ! -f ".gitmodules" ]]; then
    info "No .gitmodules found — nothing to do"
    return
  fi

  git submodule update --init --recursive 2>&1 | sed 's/^/  /' || {
    warn "Some submodules failed — you may need repo access"
    info "Check .gitmodules and ensure you have access to each repo"
    return
  }

  ok "All submodules hydrated"

  echo ""
  echo -e "  ${PASS} Repos ready in repos/"
  echo ""
}
