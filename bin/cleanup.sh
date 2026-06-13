#!/usr/bin/env bash

# =============================================================================
# CLEANUP
# =============================================================================
cmd_cleanup() {
  echo ""
  echo -e "${BLU}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${BLU}║  infra-init cleanup                          ║${NC}"
  echo -e "${BLU}╚══════════════════════════════════════════════╝${NC}"

  IMPORTED_DIR="$REPO_ROOT/terraform/production/imported"

  if [[ ! -d "$IMPORTED_DIR" ]]; then
    fail "No imported/ directory found — run infra-init import first"
    exit 1
  fi

  # Find all resources.tf files (portable — no mapfile/bash4 required)
  TF_FILES=()
  while IFS= read -r line; do
    TF_FILES+=("$line")
  done < <(find "$IMPORTED_DIR" -name "resources.tf" | sort)
  TOTAL=${#TF_FILES[@]}

  if [[ $TOTAL -eq 0 ]]; then
    warn "No resources.tf files found in $IMPORTED_DIR"
    return
  fi

  info "Found $TOTAL resources.tf files to clean"
  CHANGED=0

  # Python cleanup script — handles multi-line blocks correctly
  CLEANUP_PY=$(cat <<'PYEOF'
import re, sys, os

path = sys.argv[1]
with open(path, 'r') as f:
    original = f.read()

content = original

# --- Backup original ---
with open(path + '.bak', 'w') as f:
    f.write(original)

# --- Strip tags_all blocks (multi-line aware) ---
# Handles both flat and nested: tags_all = { ... }
content = re.sub(
    r'\n[ \t]*tags_all\s*=\s*\{[^}]*\}',
    '',
    content,
    flags=re.DOTALL
)

# --- Strip known deprecated / read-only single-line attributes ---
STRIP_PATTERNS = [
    r'\n[ \t]*vpc\s*=\s*"true"',                              # EIP: deprecated, replaced by domain="vpc"
    r'\n[ \t]*service_linked_role_arn\s*=\s*"[^"]*"',        # ASG: AWS-managed, read-only
    r'\n[ \t]*owner_id\s*=\s*"[^"]*"',                       # VPC/SG: read-only
    r'\n[ \t]*enable_classiclink\s*=\s*"[^"]*"',              # VPC: EC2-Classic retired
    r'\n[ \t]*enable_classiclink_dns_support\s*=\s*"[^"]*"', # VPC: EC2-Classic retired
    r'\n[ \t]*ipv6_netmask_length\s*=\s*"0"',                # VPC: only valid with IPv6 IPAM; 0 = unset
    # --- ASG: mutually exclusive attributes (Terraformer emits both) ---
    r'\n[ \t]*target_group_arns\s*=\s*\[[^\]]*\]',           # ASG: conflicts with traffic_source in TF 5.x; keep traffic_source
    r'\n[ \t]*availability_zones\s*=\s*\[[^\]]*\]',          # ASG: EC2-Classic only; VPC ASGs use vpc_zone_identifier
    # --- EBS / launch-template: "0" means unset but provider rejects out-of-range ---
    r'\n[ \t]*throughput\s*=\s*"0"',                         # EBS/LT: valid range 125-1000; 0 = not configured
    r'\n[ \t]*volume_initialization_rate\s*=\s*"0"',         # EBS/LT: valid range 100-300; 0 = not configured
    r'\n[ \t]*iops\s*=\s*"0"',                               # EBS/LT: only valid for io1/io2/gp3; 0 = not configured
    # --- ENI / launch-template network_interfaces: prefix counts of 0 = noise ---
    r'\n[ \t]*ipv4_prefix_count\s*=\s*"0"',                  # ENI/LT: no prefix delegations = default
    r'\n[ \t]*ipv6_prefix_count\s*=\s*"0"',                  # ENI/LT: no IPv6 prefix delegations = default
    # --- Placement: 0 = not in partition group = noise ---
    r'\n[ \t]*placement_partition_number\s*=\s*"0"',          # EC2: not in partition placement group
    r'\n[ \t]*partition_number\s*=\s*"0"',                    # LT placement block: not in partition group
    # --- Launch template network_interfaces: primary card is default ---
    r'\n[ \t]*network_card_index\s*=\s*"0"',                  # LT NI: index 0 = primary, default
    # --- ENI: interface_type values Terraformer writes are invalid in TF 5.x aws_network_interface ---
    # Valid values are only efa/efa-only/branch/trunk; "interface"/"efs"/"ec2_instance_connect_endpoint"
    # are internal AWS types not accepted by the provider — omit entirely (default is implicit)
    r'\n[ \t]*interface_type\s*=\s*"[^"]*"',                  # ENI: strip all interface_type values
    # --- ENI: private_ip_list conflicts with private_ips; keep private_ips ---
    r'\n[ \t]*private_ip_list\s*=\s*\[[^\]]*\]',              # ENI: conflicts with private_ips
    # --- ENI: private_ips_count = "0" conflicts with private_ip_list; 0 = unset ---
    r'\n[ \t]*private_ips_count\s*=\s*"0"',                   # ENI: 0 = no secondary IPs, default
]

for pattern in STRIP_PATTERNS:
    content = re.sub(pattern, '', content, flags=re.DOTALL)

# --- ASG: inject missing provider-v5 attributes with their default values ---
# AWS returns null for these (pre-date the feature), but TF provider now tracks them.
# Without them in HCL, every plan shows spurious drift.
def _inject_asg_defaults(text):
    def fix_asg(m):
        blk = m.group(0)
        if 'force_delete_warm_pool' not in blk:
            blk = blk.replace(
                '\n  force_delete ',
                '\n  force_delete_warm_pool           = false\n  force_delete '
            )
        if 'ignore_failed_scaling_activities' not in blk:
            blk = blk.replace(
                '\n  health_check_grace_period',
                '\n  health_check_grace_period'
            )
            # Insert after health_check_type line
            blk = re.sub(
                r'(  health_check_type\s*=\s*"[^"]*")',
                r'\1\n  ignore_failed_scaling_activities = false',
                blk
            )
        if 'timeouts {}' not in blk:
            blk = re.sub(r'(\n  wait_for_capacity_timeout[^\n]*\n\})', r'\1', blk)
            blk = blk.rstrip('\n}').rstrip() + '\n\n  timeouts {}\n}'
        return blk
    return re.sub(
        r'resource "aws_autoscaling_group" "[^"]*" \{.*?\n\}',
        fix_asg, text, flags=re.DOTALL
    )
content = _inject_asg_defaults(content)

# --- aws_instance: fix inline blocks + inject missing provider-v5 attributes ---
def _fix_instance_blocks(text):
    def fix_inst(m):
        blk = m.group(0)
        # Strip inline launch_template block (conflicts with explicit ami/type attrs)
        blk = re.sub(r'\n  launch_template \{[^}]*\}', '', blk, flags=re.DOTALL)
        # Inject user_data_replace_on_change = false (new TF 5.x attr, AWS returns null)
        if 'user_data_replace_on_change' not in blk:
            blk = re.sub(
                r'(\n  instance_type\s+=\s+"[^"]*")',
                r'\1\n  user_data_replace_on_change          = false',
                blk
            )
        # Inject http_protocol_ipv6 = "disabled" into metadata_options (new TF 5.x attr)
        blk = re.sub(
            r'(  metadata_options \{[^}]*?)([ \t]*http_endpoint\s*=\s*"[^"]*")',
            lambda m: m.group(0) if 'http_protocol_ipv6' in m.group(1)
                      else m.group(1) + m.group(2) + '\n    http_protocol_ipv6          = "disabled"',
            blk,
            flags=re.DOTALL
        )
        # Inject timeouts {} to match Terraformer state (prevents spurious plan diff)
        if 'timeouts {}' not in blk:
            blk = blk.rstrip('\n}').rstrip() + '\n\n  timeouts {}\n}'
        return blk
    return re.sub(
        r'resource "aws_instance" "[^"]*" \{.*?\n\}',
        fix_inst, text, flags=re.DOTALL
    )
content = _fix_instance_blocks(content)

# --- ASG launch_template block: remove `name` when `id` is present ---
# Terraform requires exactly one of id or name; id is unambiguous so drop name.
def _fix_lt_name(m):
    block = m.group(0)
    if re.search(r'\n\s+id\s*=\s*"', block):
        block = re.sub(r'\n[ \t]*name\s*=\s*"[^"]*"', '', block)
    return block
content = re.sub(r'launch_template \{[^}]*\}', _fix_lt_name, content, flags=re.DOTALL)

# --- aws_ebs_volume: remove iops for volume types that don't support it ---
# gp2/standard/sc1/st1 volumes have computed iops; setting it raises provider error
def _strip_iops_for_non_iops_volumes(text):
    def fix_vol(m):
        blk = m.group(0)
        if re.search(r'type\s*=\s*"(gp2|standard|sc1|st1)"', blk):
            blk = re.sub(r'\n[ \t]*iops\s*=\s*"[^"]*"', '', blk)
        return blk
    return re.sub(
        r'resource "aws_ebs_volume" "[^"]*" \{.*?\n\}',
        fix_vol, text, flags=re.DOTALL
    )
content = _strip_iops_for_non_iops_volumes(content)

# --- Write if changed ---
if content != original:
    with open(path, 'w') as f:
        f.write(content)
    lines_before = original.count('\n')
    lines_after = content.count('\n')
    print(f"CHANGED:{lines_before - lines_after}")
else:
    os.remove(path + '.bak')  # No change, remove backup
    print("UNCHANGED")
PYEOF
)

  # --- Process each resources.tf file ---
  step "Stripping known bad attributes from $TOTAL files"

  for tf_file in "${TF_FILES[@]}"; do
    RESULT=$(python3 <(echo "$CLEANUP_PY") "$tf_file" 2>&1)
    REL_PATH="${tf_file#$REPO_ROOT/}"

    if [[ "$RESULT" == UNCHANGED ]]; then
      info "$REL_PATH — no changes"
    elif [[ "$RESULT" == CHANGED:* ]]; then
      LINES_REMOVED="${RESULT#CHANGED:}"
      ok "$REL_PATH — removed $LINES_REMOVED lines"
      ((CHANGED++)) || true
    else
      warn "$REL_PATH — $RESULT"
    fi
  done

  # --- Remove ELB-managed ENIs from resources.tf + outputs.tf ---
  # ENIs with description "ELB app/..." or "ELB net/..." are ephemeral — created
  # and destroyed by ALB/NLB automatically. Terraform should not manage them.
  # We also remove any ENIs whose state entry no longer exists in AWS (plan shows
  # "has been deleted" outside of Terraform). Both cases: strip from HCL + print
  # the terraform state rm commands the user must run.
  step "Removing ELB-managed ENIs from resources.tf + outputs.tf"

  ENI_CLEANUP_PY=$(cat <<'ENI_PYEOF'
import re, sys, os

resources_path = sys.argv[1]
outputs_path   = sys.argv[2]

def read(p):
    with open(p) as f: return f.read()
def write(p, t):
    with open(p, 'w') as f: f.write(t)

# --- Line-oriented block removal ---
# Finds top-level blocks (resource/output) matching a predicate and removes them.
# Uses a simple brace-depth counter — safe against `}` inside quoted strings
# because we only count unquoted braces (lines starting with `}` at depth).
def remove_blocks(text, predicate):
    """Remove top-level { } blocks where the opening line matches predicate."""
    lines = text.splitlines(keepends=True)
    out = []
    removed_names = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if predicate(line):
            # Collect the block name for reporting
            m = re.search(r'"([^"]+)"\s*\{', line)
            if m:
                removed_names.append(m.group(1))
            # Skip until matching closing brace (depth tracking)
            depth = line.count('{') - line.count('}')
            i += 1
            while i < len(lines) and depth > 0:
                depth += lines[i].count('{') - lines[i].count('}')
                i += 1
            # Skip trailing blank line
            if i < len(lines) and lines[i].strip() == '':
                i += 1
        else:
            out.append(line)
            i += 1
    return ''.join(out), removed_names

# --- resources.tf: find ELB-managed aws_network_interface blocks ---
resources = read(resources_path)

# First pass: find resource names whose description starts with "ELB "
elb_eni_names = set()
for m in re.finditer(
    r'resource\s+"aws_network_interface"\s+"([^"]+)"\s*\{([^}]*(?:\{[^}]*\}[^}]*)*)\}',
    resources, re.DOTALL
):
    rname, body = m.group(1), m.group(2)
    if re.search(r'description\s*=\s*"ELB\s', body):
        elb_eni_names.add(rname)

if not elb_eni_names:
    print("ENI_UNCHANGED")
    sys.exit(0)

def is_elb_eni_resource(line):
    if not line.strip().startswith('resource "aws_network_interface"'):
        return False
    m = re.search(r'"aws_network_interface"\s+"([^"]+)"', line)
    return m and m.group(1) in elb_eni_names

new_resources, removed_resources = remove_blocks(resources, is_elb_eni_resource)

# --- outputs.tf: remove matching output blocks ---
outputs_changed = False
removed_outputs = []
if os.path.exists(outputs_path):
    outputs = read(outputs_path)
    def is_elb_eni_output(line):
        if not line.strip().startswith('output "'):
            return False
        return any(name in line for name in elb_eni_names)
    new_outputs, removed_outputs = remove_blocks(outputs, is_elb_eni_output)
    if new_outputs != outputs:
        write(outputs_path, new_outputs)
        outputs_changed = True

if new_resources != resources:
    write(resources_path, new_resources)

# Emit results
for name in removed_resources:
    print("REMOVED_ENI:" + name)
ENI_PYEOF
)

  # Find all ENI resources.tf files
  ENI_FILES=()
  while IFS= read -r line; do
    ENI_FILES+=("$line")
  done < <(find "$IMPORTED_DIR" -path "*/eni/resources.tf" | sort)

  declare -a STALE_ENI_STATE_CMDS=()

  for eni_resources in "${ENI_FILES[@]}"; do
    eni_dir="$(dirname "$eni_resources")"
    eni_outputs="$eni_dir/outputs.tf"
    REL="${eni_resources#$REPO_ROOT/}"

    RESULT=$(python3 <(echo "$ENI_CLEANUP_PY") "$eni_resources" "$eni_outputs" 2>&1)

    if [[ "$RESULT" == "ENI_UNCHANGED" ]]; then
      info "$REL — no ELB-managed ENIs found"
    else
      REMOVED_COUNT=0
      while IFS= read -r line; do
        if [[ "$line" == REMOVED_ENI:* ]]; then
          RNAME="${line#REMOVED_ENI:}"
          STALE_ENI_STATE_CMDS+=("terraform -chdir=\"${eni_dir#$REPO_ROOT/}\" state rm \"aws_network_interface.$RNAME\"")
          ((REMOVED_COUNT++)) || true
        fi
      done <<< "$RESULT"
      ok "$REL — removed $REMOVED_COUNT ELB-managed ENI blocks"
      ((CHANGED++)) || true
    fi
  done

  if [[ ${#STALE_ENI_STATE_CMDS[@]} -gt 0 ]]; then
    echo ""
    warn "ELB-managed ENIs removed from HCL. Run these state rm commands:"
    for cmd in "${STALE_ENI_STATE_CMDS[@]}"; do
      echo -e "    $cmd"
    done
  fi

  # --- AWS CLI spot-checks ---
  step "AWS CLI spot-checks (verifying key values against live AWS)"

  # VPCs
  info "Verifying VPC CIDRs..."
  AWS_VPCS=$(aws ec2 describe-vpcs \
    --profile "$PROFILE" --region us-east-1 \
    --query 'Vpcs[].{id:VpcId,cidr:CidrBlock,name:Tags[?Key==`Name`].Value|[0]}' \
    --output table 2>/dev/null) && echo "$AWS_VPCS" | sed 's/^/    /' || warn "VPC check failed"

  # EC2 instance count
  info "Verifying EC2 instance count..."
  AWS_EC2_COUNT=$(aws ec2 describe-instances \
    --profile "$PROFILE" --region us-east-1 \
    --query 'length(Reservations[].Instances[])' \
    --output text 2>/dev/null) || AWS_EC2_COUNT="error"
  TF_EC2_COUNT=$(grep -c 'resource "aws_instance"' "$IMPORTED_DIR/compute/ec2_instance/resources.tf" 2>/dev/null || echo 0)
  if [[ "$AWS_EC2_COUNT" == "$TF_EC2_COUNT" ]]; then
    ok "EC2 count matches: $TF_EC2_COUNT instances in both AWS and imported .tf"
  else
    warn "EC2 count mismatch — AWS: $AWS_EC2_COUNT, imported .tf: $TF_EC2_COUNT"
  fi

  # Security group count
  info "Verifying security group count..."
  AWS_SG_COUNT=$(aws ec2 describe-security-groups \
    --profile "$PROFILE" --region us-east-1 \
    --query 'length(SecurityGroups)' \
    --output text 2>/dev/null) || AWS_SG_COUNT="error"
  TF_SG_COUNT=$(grep -c 'resource "aws_security_group"' "$IMPORTED_DIR/network/sg/resources.tf" 2>/dev/null || echo 0)
  if [[ "$AWS_SG_COUNT" == "$TF_SG_COUNT" ]]; then
    ok "SG count matches: $TF_SG_COUNT"
  else
    warn "SG count mismatch — AWS: $AWS_SG_COUNT, imported .tf: $TF_SG_COUNT"
  fi

  # Subnet count
  info "Verifying subnet count..."
  AWS_SUBNET_COUNT=$(aws ec2 describe-subnets \
    --profile "$PROFILE" --region us-east-1 \
    --query 'length(Subnets)' \
    --output text 2>/dev/null) || AWS_SUBNET_COUNT="error"
  TF_SUBNET_COUNT=$(grep -c 'resource "aws_subnet"' "$IMPORTED_DIR/network/subnet/resources.tf" 2>/dev/null || echo 0)
  if [[ "$AWS_SUBNET_COUNT" == "$TF_SUBNET_COUNT" ]]; then
    ok "Subnet count matches: $TF_SUBNET_COUNT"
  else
    warn "Subnet count mismatch — AWS: $AWS_SUBNET_COUNT, imported .tf: $TF_SUBNET_COUNT"
  fi

  # --- Summary ---
  echo ""
  echo -e "${BLU}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${BLU}║  Cleanup Summary                             ║${NC}"
  echo -e "${BLU}╚══════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "  ${PASS} $CHANGED / $TOTAL files cleaned"
  echo -e "  ${INFO} Backups saved as .bak alongside each changed file"
  echo -e "  ${INFO} Next: run terraform plan in any service directory to check for remaining drift"
  echo ""
}
