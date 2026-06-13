#!/usr/bin/env bash

# =============================================================================
# STATE-UPGRADE
# Terraformer writes tfstate files with the legacy pre-0.13 provider address
# "aws" instead of "registry.terraform.io/hashicorp/aws".  Terraform 1.x
# refuses to init until the state is migrated.  This command:
#   1. Backs up each terraform.tfstate
#   2. Runs `terraform state replace-provider` to rewrite the address
#   3. Runs `terraform init` in the directory (creates .terraform.lock.hcl)
#   4. Fixes aws_default_network_acl: Terraformer state omits default_network_acl_id
#      causing destroy+create drift — re-imports each affected resource natively
# =============================================================================
cmd_state_upgrade() {
  echo ""
  echo -e "${BLU}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${BLU}║  infra-init state-upgrade                    ║${NC}"
  echo -e "${BLU}╚══════════════════════════════════════════════╝${NC}"

  IMPORTED_DIR="$REPO_ROOT/terraform/production/imported"

  if [[ ! -d "$IMPORTED_DIR" ]]; then
    fail "No imported/ directory — run infra-init import first"
    exit 1
  fi

  # Find all directories that have a terraform.tfstate
  STATE_DIRS=()
  while IFS= read -r statefile; do
    STATE_DIRS+=("$(dirname "$statefile")")
  done < <(find "$IMPORTED_DIR" -name "terraform.tfstate" | sort)

  TOTAL=${#STATE_DIRS[@]}
  if [[ $TOTAL -eq 0 ]]; then
    warn "No terraform.tfstate files found in $IMPORTED_DIR"
    info "Already upgraded, or nothing imported yet"
    return
  fi

  info "Found $TOTAL state files to upgrade"

  # --- Generate .envrc anchors so direnv chains up to root credentials -------
  # Each service dir needs source_up so terraform plan picks up AWS_PROFILE
  step "Generating .envrc chain files"

  for anchor in "$REPO_ROOT/terraform/production" "$IMPORTED_DIR"; do
    if [[ ! -f "$anchor/.envrc" ]]; then
      printf '# Chain up to root .envrc for AWS credentials, PATH, etc.\nsource_up\n' \
        > "$anchor/.envrc"
      ok "Created ${anchor#$REPO_ROOT/}/.envrc"
    else
      info "${anchor#$REPO_ROOT/}/.envrc already exists"
    fi
  done

  while IFS= read -r pf; do
    svc_dir="$(dirname "$pf")"
    if [[ ! -f "$svc_dir/.envrc" ]]; then
      printf '# Chain up to root .envrc for AWS credentials (AWS_PROFILE, keys, PATH)\nsource_up\n' \
        > "$svc_dir/.envrc"
      ok "Created ${svc_dir#$REPO_ROOT/}/.envrc"
    fi
  done < <(find "$IMPORTED_DIR" -name "provider.tf" | sort)

  UPGRADED=0
  SKIPPED=0
  FAILED=0

  for dir in "${STATE_DIRS[@]}"; do
    REL="${dir#$REPO_ROOT/}"
    STATE="$dir/terraform.tfstate"

    # Skip if this state file is empty or whitespace only
    if ! grep -q '"resources"' "$STATE" 2>/dev/null; then
      info "$REL — empty state, skipping replace-provider"
      # Still run init so the lock file gets created
    fi

    step "$REL"

    # 0. Convert Terraform v3 (0.12.x) state format to v4 before anything else.
    #    v3 uses modules[].resources dict; v4 uses top-level resources array.
    #    The replace-provider and init steps both require v4 format.
    STATE_VERSION=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('version',0))" "$STATE" 2>/dev/null || echo 0)
    if [[ "$STATE_VERSION" == "3" ]]; then
      info "Terraform v3 state detected — converting to v4..."
      cp "$STATE" "${STATE}.v3.bak"
      python3 - "$STATE" << 'V3_PYEOF'
import json, sys, shutil

path = sys.argv[1]
with open(path) as f:
    s = json.load(f)

modules = s.get('modules', [{}])
root = next((m for m in modules if m.get('path') == ['root']), modules[0])

outputs = {}
for k, v in root.get('outputs', {}).items():
    outputs[k] = {'value': v.get('value'), 'type': v.get('type', 'string'), 'sensitive': v.get('sensitive', False)}

resources = []
for key, res in root.get('resources', {}).items():
    dot = key.find('.')
    if dot < 0:
        continue
    rtype, rname = key[:dot], key[dot+1:]
    primary = res.get('primary', {})
    resources.append({
        'mode': 'managed', 'type': rtype, 'name': rname,
        'provider': 'provider["registry.terraform.io/hashicorp/aws"]',
        'instances': [{'schema_version': int(primary.get('meta', {}).get('schema_version', 0)),
                       'attributes': primary.get('attributes', {}),
                       'sensitive_attributes': [], 'private': ''}]
    })

v4 = {'version': 4, 'terraform_version': '1.5.0',
      'serial': s.get('serial', 1) + 1, 'lineage': s.get('lineage', ''),
      'outputs': outputs, 'resources': resources, 'check_results': None}

with open(path, 'w') as f:
    json.dump(v4, f, indent=2)

print(f"  Converted: {len(resources)} resources, {len(outputs)} outputs")
V3_PYEOF
      ok "v3 → v4 conversion complete"
    fi

    # 1. Check if the state still has the legacy provider address
    if grep -q '"registry.terraform.io/-/aws"' "$STATE" 2>/dev/null || \
       grep -q '"provider":"provider\[\"aws\"\]"' "$STATE" 2>/dev/null || \
       grep -q '"provider":"provider.aws"' "$STATE" 2>/dev/null; then

      info "Legacy provider address found — migrating..."

      # Backup
      cp "$STATE" "${STATE}.pre-upgrade"

      # Run replace-provider (auto-approves via -auto-approve)
      if terraform -chdir="$dir" state replace-provider \
          -auto-approve \
          "registry.terraform.io/-/aws" \
          "registry.terraform.io/hashicorp/aws" \
          2>&1 | sed 's/^/    /'; then
        ok "Provider address migrated"
      else
        warn "replace-provider returned non-zero — may already be migrated, continuing"
      fi
    else
      info "Provider address already in modern format"
    fi

    # 2. terraform init
    info "Running terraform init..."
    if terraform -chdir="$dir" init -no-color \
        -input=false \
        2>&1 | grep -E "Initializing|initialized|provider|Success|Error" | sed 's/^/    /'; then
      ok "terraform init complete"
      ((UPGRADED++)) || true
    else
      fail "terraform init failed in $REL"
      ((FAILED++)) || true
      continue
    fi

    # 3. Fix aws_default_network_acl: Terraformer state omits default_network_acl_id,
    #    causing Terraform to plan destroy+create on every run.
    #    Detection: state has aws_default_network_acl resources with empty default_network_acl_id.
    #    Fix: state rm + terraform import (native import records all attrs correctly).
    if [[ -f "$dir/resources.tf" ]] && grep -q 'aws_default_network_acl' "$dir/resources.tf" 2>/dev/null; then
      NACL_FIX_PY=$(cat <<'NACL_PYEOF'
import json, re, sys

state_file  = sys.argv[1]
tf_dir      = sys.argv[2]
resources_tf = tf_dir + "/resources.tf"

try:
    with open(state_file) as f:
        state = json.load(f)
    with open(resources_tf) as f:
        hcl = f.read()
except Exception:
    sys.exit(0)

# Map resource name -> acl_id from HCL
acl_map = {}
for m in re.finditer(
    r'resource\s+"aws_default_network_acl"\s+"([^"]+)"\s*\{[^}]*default_network_acl_id\s*=\s*"([^"]+)"',
    hcl, re.DOTALL
):
    acl_map[m.group(1)] = m.group(2)

if not acl_map:
    sys.exit(0)

# Emit REIMPORT lines for any state entry missing default_network_acl_id
for res in state.get("resources", []):
    if res.get("type") != "aws_default_network_acl":
        continue
    rname = res.get("name", "")
    if rname not in acl_map:
        continue
    for inst in res.get("instances", []):
        if not inst.get("attributes", {}).get("default_network_acl_id"):
            print(f"REIMPORT:aws_default_network_acl.{rname}:{acl_map[rname]}")
            break
NACL_PYEOF
)
      REIMPORTS=$(python3 <(echo "$NACL_FIX_PY") "$STATE" "$dir" 2>/dev/null || true)
      if [[ -n "$REIMPORTS" ]]; then
        info "Fixing aws_default_network_acl state (missing default_network_acl_id)..."
        while IFS= read -r line; do
          # line format: REIMPORT:aws_default_network_acl.<name>:<acl-id>
          resource_addr=$(echo "$line" | cut -d: -f2)
          acl_id=$(echo "$line" | cut -d: -f3)
          info "  Re-importing $resource_addr → $acl_id"
          terraform -chdir="$dir" state rm "$resource_addr" 2>&1 | sed 's/^/    /' || true
          terraform -chdir="$dir" import "$resource_addr" "$acl_id" 2>&1 | sed 's/^/    /' || true
        done <<< "$REIMPORTS"
        ok "aws_default_network_acl state repaired"
      fi
    fi
  done

  # --- Summary ---------------------------------------------------------------
  echo ""
  echo -e "${BLU}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${BLU}║  State Upgrade Summary                       ║${NC}"
  echo -e "${BLU}╚══════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "  ${PASS} $UPGRADED directories upgraded + initialized"
  [[ $FAILED -gt 0 ]] && echo -e "  ${FAIL} $FAILED directories failed — check output above"
  echo ""
  echo -e "  ${INFO} To verify, run terraform plan in the simplest directory first:"
  echo -e "        terraform -chdir=terraform/production/imported/network/vpc plan"
  echo -e "  ${INFO} Note: dirs with terraform_remote_state refs (igw, subnet, sg, etc.)"
  echo -e "        will need the remote backend configured before plan will pass."
  echo ""
}
