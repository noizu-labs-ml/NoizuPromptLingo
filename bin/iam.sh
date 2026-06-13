#!/usr/bin/env bash

# =============================================================================
# IMPORT — IAM (all resource types)
# =============================================================================
# _import_iam_direct: Import IAM resources via aws CLI + terraform import
# Bypasses terraformer which hangs enumerating 1000+ AWS-managed policies.
#
# Import order (dependency-aware):
#   1. Customer-managed policies  — leaf dependency, no deps of its own
#   2. Users + inline/attachments — needed before group_membership
#   3. Groups + inline/attachments
#   4. Group memberships          — depends on both groups and users
#   5. Roles + inline/attachments — assume_role_policy can ref users/groups
#   6. Instance profiles          — references roles
#
# NOTE: This function disables set -e internally because the combination of
# pipefail + command substitutions + AWS CLI calls causes silent exits on
# macOS bash 3.2. Error handling is done explicitly with if/else.
# =============================================================================
_import_iam_direct() {
  set +e
  trap 'set -e' RETURN

  local LOG="$1"
  local IAM_DIR="$REPO_ROOT/terraform/production/imported/iam/iam"
  mkdir -p "$IAM_DIR"

  # Write provider stub if missing
  if [[ ! -f "$IAM_DIR/provider.tf" ]]; then
    cat > "$IAM_DIR/provider.tf" << 'PROVEOF'
provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      version = "~> 5.100.0"
    }
  }
}
PROVEOF
  fi

  local OUT_FILE="$IAM_DIR/outputs.tf"

  local IMPORT_OK=0
  local IMPORT_FAIL=0
  local IMPORT_TOTAL=0
  local INIT_DONE=0

  # Per-type counters
  local COUNT_policies=0 COUNT_users=0 COUNT_user_policies=0 COUNT_user_policy_attachments=0
  local COUNT_groups=0 COUNT_group_policies=0 COUNT_group_policy_attachments=0 COUNT_group_memberships=0
  local COUNT_roles=0 COUNT_role_policies=0 COUNT_role_policy_attachments=0 COUNT_instance_profiles=0

  # Helper: sanitize name for terraform resource identifier
  _tf_name() {
    perl -e '$n = $ARGV[0]; $n =~ s{[/.:]}{_}g; print "tfer--$n"' "$1"
  }

  # Helper: resolve .tf filename for a resource type
  _tf_file_for() {
    case "$1" in
      aws_iam_policy)                   echo "policies.tf" ;;
      aws_iam_user)                     echo "users.tf" ;;
      aws_iam_user_policy)              echo "user_policies.tf" ;;
      aws_iam_user_policy_attachment)   echo "user_policy_attachments.tf" ;;
      aws_iam_group)                    echo "groups.tf" ;;
      aws_iam_group_policy)             echo "group_policies.tf" ;;
      aws_iam_group_policy_attachment)  echo "group_policy_attachments.tf" ;;
      aws_iam_group_membership)         echo "group_memberships.tf" ;;
      aws_iam_role)                     echo "roles.tf" ;;
      aws_iam_role_policy)              echo "role_policies.tf" ;;
      aws_iam_role_policy_attachment)   echo "role_policy_attachments.tf" ;;
      aws_iam_instance_profile)         echo "instance_profiles.tf" ;;
      *)                                echo "resources.tf" ;;
    esac
  }

  # Helper: increment per-type counter
  _tf_count_incr() {
    case "$1" in
      aws_iam_policy)                   COUNT_policies=$((COUNT_policies + 1)) ;;
      aws_iam_user)                     COUNT_users=$((COUNT_users + 1)) ;;
      aws_iam_user_policy)              COUNT_user_policies=$((COUNT_user_policies + 1)) ;;
      aws_iam_user_policy_attachment)   COUNT_user_policy_attachments=$((COUNT_user_policy_attachments + 1)) ;;
      aws_iam_group)                    COUNT_groups=$((COUNT_groups + 1)) ;;
      aws_iam_group_policy)             COUNT_group_policies=$((COUNT_group_policies + 1)) ;;
      aws_iam_group_policy_attachment)  COUNT_group_policy_attachments=$((COUNT_group_policy_attachments + 1)) ;;
      aws_iam_group_membership)         COUNT_group_memberships=$((COUNT_group_memberships + 1)) ;;
      aws_iam_role)                     COUNT_roles=$((COUNT_roles + 1)) ;;
      aws_iam_role_policy)              COUNT_role_policies=$((COUNT_role_policies + 1)) ;;
      aws_iam_role_policy_attachment)   COUNT_role_policy_attachments=$((COUNT_role_policy_attachments + 1)) ;;
      aws_iam_instance_profile)         COUNT_instance_profiles=$((COUNT_instance_profiles + 1)) ;;
    esac
  }

  # Helper: write resource stub + run terraform import
  _tf_import_resource() {
    local type="$1" name="$2" id="$3" extra_hcl="$4"
    IMPORT_TOTAL=$((IMPORT_TOTAL + 1))

    local tf_fname
    tf_fname=$(_tf_file_for "$type")
    local res_file="$IAM_DIR/$tf_fname"

    # Append HCL stub
    printf 'resource "%s" "%s" {\n%b}\n\n' "$type" "$name" "$extra_hcl" >> "$res_file"
    printf 'output "%s_%s_id" {\n  value = %s.%s.id\n}\n\n' \
      "$type" "$name" "$type" "$name" >> "$OUT_FILE"

    _tf_count_incr "$type"

    # Terraform init once on first resource
    if [[ $INIT_DONE -eq 0 ]]; then
      info "Running terraform init..."
      if terraform -chdir="$IAM_DIR" init -input=false >> "$LOG" 2>&1; then
        INIT_DONE=1
      else
        fail "terraform init FAILED"
        IMPORT_FAIL=$((IMPORT_FAIL + 1))
        return 1
      fi
    fi

    # Resources that don't support terraform import — HCL stub only
    if [[ "$type" == "aws_iam_group_membership" ]]; then
      info "    [${IMPORT_TOTAL}/~${IMPORT_ESTIMATE}] stub-only $type.$name (import not supported)"
      IMPORT_OK=$((IMPORT_OK + 1))
      return 0
    fi

    if terraform -chdir="$IAM_DIR" import "$type.$name" "$id" >> "$LOG" 2>&1; then
      ok "    [${IMPORT_TOTAL}/~${IMPORT_ESTIMATE}] imported $type.$name"
      IMPORT_OK=$((IMPORT_OK + 1))
    else
      warn "    [${IMPORT_TOTAL}/~${IMPORT_ESTIMATE}] FAILED $type.$name ($id)"
      IMPORT_FAIL=$((IMPORT_FAIL + 1))
    fi
  }

  # Helper: run AWS CLI, write output to temp file
  # For single-column output, converts tabs to newlines.
  # For multi-column output (tab-separated rows), pass --multi as first arg
  # to preserve tabs within each row.
  _aws_to_lines() {
    local _outvar="$1"; shift
    local _multi=false
    if [[ "$1" == "--multi" ]]; then
      _multi=true; shift
    fi
    local _tmpf
    _tmpf=$(mktemp)
    if aws "$@" 2>>"$LOG" > "$_tmpf"; then
      if $_multi; then
        # Multi-column: keep tabs, just strip blank lines
        perl -ne 'print if /\S/' "$_tmpf" > "${_tmpf}.clean"
      else
        # Single-column: convert tabs to newlines, strip blanks
        perl -pe 's/\t/\n/g' "$_tmpf" | perl -ne 'print if /\S/' > "${_tmpf}.clean"
      fi
      mv "${_tmpf}.clean" "$_tmpf"
    else
      > "$_tmpf"
    fi
    eval "$_outvar='$_tmpf'"
  }

  # Helper: check if a role/profile is user-managed (not AWS-managed)
  _is_user_role() {
    local role="$1"
    case "$role" in
      AWSServiceRoleFor*)                     return 1 ;;
      AWSReservedSSO_*)                       return 1 ;;
      AWSBackupDefaultServiceRole)            return 1 ;;
      AWSDataLifecycleManagerDefaultRole)     return 1 ;;
      AmazonWamMarketplace_Default_Role)      return 1 ;;
      workspaces_DefaultRole)                 return 1 ;;
      aws-elasticbeanstalk-ec2-role)          return 1 ;;
      aws-elasticbeanstalk-service-role)      return 1 ;;
      aws-quicksight-service-role-v0)         return 1 ;;
      aws-quicksight-secretsmanager-role-v0)  return 1 ;;
      cdk-hnb659fds-*)                        return 1 ;;
      dms-cloudwatch-logs-role)               return 1 ;;
      dms-vpc-role)                           return 1 ;;
      ecsInstanceRole)                        return 1 ;;
      ecsTaskExecutionRole)                   return 1 ;;
      rds-monitoring-role)                    return 1 ;;
      *)                                      return 0 ;;
    esac
  }

  # ══════════════════════════════════════════════════════════════════════════════
  # PRE-COUNT — estimate total resources for progress display
  # Each top-level entity (role/user/group) has ~2 sub-resources on average
  # (inline policies + managed policy attachments)
  # ══════════════════════════════════════════════════════════════════════════════
  info "Counting IAM resources..."

  # Use --no-paginate to get a single count value (paginated results return one per page)
  local _cnt_policies _cnt_users _cnt_groups _cnt_roles _cnt_profs
  _cnt_policies=$(aws iam list-policies --scope Local --profile "$PROFILE" --no-paginate \
    --query 'length(Policies)' --output text 2>>"$LOG") || _cnt_policies=0
  _cnt_users=$(aws iam list-users --profile "$PROFILE" --no-paginate \
    --query 'length(Users)' --output text 2>>"$LOG") || _cnt_users=0
  _cnt_groups=$(aws iam list-groups --profile "$PROFILE" --no-paginate \
    --query 'length(Groups)' --output text 2>>"$LOG") || _cnt_groups=0
  _cnt_roles=$(aws iam list-roles --profile "$PROFILE" --no-paginate \
    --query 'length(Roles)' --output text 2>>"$LOG") || _cnt_roles=0
  _cnt_profs=$(aws iam list-instance-profiles --profile "$PROFILE" --no-paginate \
    --query 'length(InstanceProfiles)' --output text 2>>"$LOG") || _cnt_profs=0

  # Estimate: each user/group/role has ~2 sub-resources, groups also have membership
  local IMPORT_ESTIMATE=$(( _cnt_policies + _cnt_users * 3 + _cnt_groups * 4 + _cnt_roles * 3 + _cnt_profs ))
  info "Estimated ~$IMPORT_ESTIMATE resources to import"

  # ══════════════════════════════════════════════════════════════════════════════
  # 1. CUSTOMER-MANAGED POLICIES
  # ══════════════════════════════════════════════════════════════════════════════
  if [[ -f "$IAM_DIR/policies.tf" ]]; then
    info "SKIP policies — already imported"
  else
    step "Importing customer-managed policies"
    > "$IAM_DIR/policies.tf"
    local POL_FILE
    _aws_to_lines POL_FILE --multi iam list-policies \
      --scope Local \
      --profile "$PROFILE" \
      --query 'Policies[*].[PolicyName,Arn]' \
      --output text

    local POL_COUNT=0
    while IFS=$'\t' read -r pname parn; do
      [[ -z "$pname" || -z "$parn" ]] && continue
      local tf_name
      tf_name=$(_tf_name "$pname")
      _tf_import_resource "aws_iam_policy" "$tf_name" "$parn" \
        "  name   = \"$pname\"\n  policy = \"{}\"\n"
      POL_COUNT=$((POL_COUNT + 1))
    done < "$POL_FILE"
    rm -f "$POL_FILE"
    info "Processed $POL_COUNT policies"
  fi

  # ══════════════════════════════════════════════════════════════════════════════
  # 2. USERS + user relationships
  # ══════════════════════════════════════════════════════════════════════════════
  if [[ -f "$IAM_DIR/users.tf" ]]; then
    info "SKIP users — already imported"
  else
    step "Importing users"
    > "$IAM_DIR/users.tf"
    > "$IAM_DIR/user_policies.tf"
    > "$IAM_DIR/user_policy_attachments.tf"
    local USERS_FILE
    _aws_to_lines USERS_FILE iam list-users \
      --profile "$PROFILE" \
      --query 'Users[*].UserName' \
      --output text

    local USER_COUNT=0
    while IFS= read -r user; do
      [[ -z "$user" ]] && continue
      local tf_name
      tf_name=$(_tf_name "$user")
      _tf_import_resource "aws_iam_user" "$tf_name" "$user" \
        "  name = \"$user\"\n"
      USER_COUNT=$((USER_COUNT + 1))

      # ── User inline policies ──
      local UPOL_FILE
      _aws_to_lines UPOL_FILE iam list-user-policies \
        --user-name "$user" \
        --profile "$PROFILE" \
        --query 'PolicyNames[*]' \
        --output text

      while IFS= read -r upol; do
        [[ -z "$upol" || "$upol" == "None" ]] && continue
        local up_tf_name
        up_tf_name=$(_tf_name "${user}:${upol}")
        _tf_import_resource "aws_iam_user_policy" "$up_tf_name" "${user}:${upol}" \
          "  name   = \"$upol\"\n  user   = \"$user\"\n  policy = \"{}\"\n"
      done < "$UPOL_FILE"
      rm -f "$UPOL_FILE"

      # ── User managed policy attachments ──
      local UATT_FILE
      _aws_to_lines UATT_FILE --multi iam list-attached-user-policies \
        --user-name "$user" \
        --profile "$PROFILE" \
        --query 'AttachedPolicies[*].[PolicyName,PolicyArn]' \
        --output text

      while IFS=$'\t' read -r att_name att_arn; do
        [[ -z "$att_arn" || "$att_arn" == "None" ]] && continue
        local ua_tf_name
        ua_tf_name=$(_tf_name "${user}/${att_arn}")
        _tf_import_resource "aws_iam_user_policy_attachment" "$ua_tf_name" "${user}/${att_arn}" \
          "  user       = \"$user\"\n  policy_arn = \"$att_arn\"\n"
      done < "$UATT_FILE"
      rm -f "$UATT_FILE"
    done < "$USERS_FILE"
    rm -f "$USERS_FILE"
    info "Processed $USER_COUNT users"
  fi

  # ══════════════════════════════════════════════════════════════════════════════
  # 3. GROUPS + group inline policies + group attachments
  # ══════════════════════════════════════════════════════════════════════════════
  # Groups list is also needed by step 4 (memberships), so always fetch it
  local GROUPS_FILE
  _aws_to_lines GROUPS_FILE iam list-groups \
    --profile "$PROFILE" \
    --query 'Groups[*].GroupName' \
    --output text

  if [[ -f "$IAM_DIR/groups.tf" ]]; then
    info "SKIP groups — already imported"
  else
    step "Importing groups"
    > "$IAM_DIR/groups.tf"
    > "$IAM_DIR/group_policies.tf"
    > "$IAM_DIR/group_policy_attachments.tf"

    local GRP_COUNT=0
    while IFS= read -r grp; do
      [[ -z "$grp" ]] && continue
      local tf_name
      tf_name=$(_tf_name "$grp")
      _tf_import_resource "aws_iam_group" "$tf_name" "$grp" \
        "  name = \"$grp\"\n"
      GRP_COUNT=$((GRP_COUNT + 1))

      # ── Group inline policies ──
      local GPOL_FILE
      _aws_to_lines GPOL_FILE iam list-group-policies \
        --group-name "$grp" \
        --profile "$PROFILE" \
        --query 'PolicyNames[*]' \
        --output text

      while IFS= read -r gpol; do
        [[ -z "$gpol" || "$gpol" == "None" ]] && continue
        local gp_tf_name
        gp_tf_name=$(_tf_name "${grp}:${gpol}")
        _tf_import_resource "aws_iam_group_policy" "$gp_tf_name" "${grp}:${gpol}" \
          "  name   = \"$gpol\"\n  group  = \"$grp\"\n  policy = \"{}\"\n"
      done < "$GPOL_FILE"
      rm -f "$GPOL_FILE"

      # ── Group managed policy attachments ──
      local GATT_FILE
      _aws_to_lines GATT_FILE --multi iam list-attached-group-policies \
        --group-name "$grp" \
        --profile "$PROFILE" \
        --query 'AttachedPolicies[*].[PolicyName,PolicyArn]' \
        --output text

      while IFS=$'\t' read -r att_name att_arn; do
        [[ -z "$att_arn" || "$att_arn" == "None" ]] && continue
        local ga_tf_name
        ga_tf_name=$(_tf_name "${grp}/${att_arn}")
        _tf_import_resource "aws_iam_group_policy_attachment" "$ga_tf_name" "${grp}/${att_arn}" \
          "  group      = \"$grp\"\n  policy_arn = \"$att_arn\"\n"
      done < "$GATT_FILE"
      rm -f "$GATT_FILE"
    done < "$GROUPS_FILE"
    info "Processed $GRP_COUNT groups"
  fi

  # ══════════════════════════════════════════════════════════════════════════════
  # 4. GROUP MEMBERSHIPS (depends on both groups and users)
  # ══════════════════════════════════════════════════════════════════════════════
  if [[ -f "$IAM_DIR/group_memberships.tf" ]]; then
    info "SKIP group memberships — already imported"
  else
    step "Importing group memberships"
    > "$IAM_DIR/group_memberships.tf"
    local GMEM_COUNT=0
    while IFS= read -r grp; do
      [[ -z "$grp" ]] && continue

      local GMEM_FILE
      _aws_to_lines GMEM_FILE iam get-group \
        --group-name "$grp" \
        --profile "$PROFILE" \
        --query 'Users[*].UserName' \
        --output text

      local _mem_count
      _mem_count=$(wc -l < "$GMEM_FILE" | tr -d ' ')
      if [[ "$_mem_count" -gt 0 ]]; then
        local users_list=""
        while IFS= read -r gu; do
          [[ -z "$gu" || "$gu" == "None" ]] && continue
          users_list="${users_list}\"${gu}\", "
        done < "$GMEM_FILE"
        users_list="${users_list%, }"

        if [[ -n "$users_list" ]]; then
          local gm_tf_name
          gm_tf_name=$(_tf_name "${grp}-membership")
          _tf_import_resource "aws_iam_group_membership" "$gm_tf_name" "$grp" \
            "  name  = \"${grp}-membership\"\n  group = \"$grp\"\n  users = [$users_list]\n"
          GMEM_COUNT=$((GMEM_COUNT + 1))
        fi
      fi
      rm -f "$GMEM_FILE"
    done < "$GROUPS_FILE"
    info "Processed $GMEM_COUNT group memberships"
  fi
  rm -f "$GROUPS_FILE"

  # ══════════════════════════════════════════════════════════════════════════════
  # 5. ROLES + role relationships (filtered to user-managed)
  # ══════════════════════════════════════════════════════════════════════════════
  if [[ -f "$IAM_DIR/roles.tf" ]]; then
    info "SKIP roles — already imported"
  else
    step "Importing roles"
    > "$IAM_DIR/roles.tf"
    > "$IAM_DIR/role_policies.tf"
    > "$IAM_DIR/role_policy_attachments.tf"
    local ROLES_FILE
    local _roles_tmpf
    _roles_tmpf=$(mktemp)
    aws iam list-roles \
      --profile "$PROFILE" \
      --query 'Roles[*].[RoleName,Path]' \
      --output text 2>>"$LOG" > "$_roles_tmpf" || true
    ROLES_FILE="$_roles_tmpf"

    local ROLE_COUNT=0
    while IFS=$'\t' read -r role role_path; do
      [[ -z "$role" ]] && continue
      # Skip AWS-managed roles
      [[ "$role_path" == */aws-service-role/* ]] && continue
      _is_user_role "$role" || continue

      local tf_name
      tf_name=$(_tf_name "$role")
      _tf_import_resource "aws_iam_role" "$tf_name" "$role" \
        "  name               = \"$role\"\n  assume_role_policy = \"{}\"\n"
      ROLE_COUNT=$((ROLE_COUNT + 1))

      # ── Role inline policies ──
      local RPOL_FILE
      _aws_to_lines RPOL_FILE iam list-role-policies \
        --role-name "$role" \
        --profile "$PROFILE" \
        --query 'PolicyNames[*]' \
        --output text

      while IFS= read -r rpol; do
        [[ -z "$rpol" || "$rpol" == "None" ]] && continue
        local rp_tf_name
        rp_tf_name=$(_tf_name "${role}:${rpol}")
        _tf_import_resource "aws_iam_role_policy" "$rp_tf_name" "${role}:${rpol}" \
          "  name   = \"$rpol\"\n  role   = \"$role\"\n  policy = \"{}\"\n"
      done < "$RPOL_FILE"
      rm -f "$RPOL_FILE"

      # ── Role managed policy attachments ──
      local RATT_FILE
      _aws_to_lines RATT_FILE --multi iam list-attached-role-policies \
        --role-name "$role" \
        --profile "$PROFILE" \
        --query 'AttachedPolicies[*].[PolicyName,PolicyArn]' \
        --output text

      while IFS=$'\t' read -r att_name att_arn; do
        [[ -z "$att_arn" || "$att_arn" == "None" ]] && continue
        local ra_tf_name
        ra_tf_name=$(_tf_name "${role}/${att_arn}")
        _tf_import_resource "aws_iam_role_policy_attachment" "$ra_tf_name" "${role}/${att_arn}" \
          "  role       = \"$role\"\n  policy_arn = \"$att_arn\"\n"
      done < "$RATT_FILE"
      rm -f "$RATT_FILE"
    done < "$ROLES_FILE"
    rm -f "$ROLES_FILE"
    info "Processed $ROLE_COUNT roles (user-managed)"
  fi

  # ══════════════════════════════════════════════════════════════════════════════
  # 6. INSTANCE PROFILES (filtered to user-managed)
  # ══════════════════════════════════════════════════════════════════════════════
  if [[ -f "$IAM_DIR/instance_profiles.tf" ]]; then
    info "SKIP instance profiles — already imported"
  else
    step "Importing instance profiles"
    > "$IAM_DIR/instance_profiles.tf"
    local PROFS_FILE
    _aws_to_lines PROFS_FILE iam list-instance-profiles \
      --profile "$PROFILE" \
      --query 'InstanceProfiles[*].InstanceProfileName' \
      --output text

    local PROF_COUNT=0
    while IFS= read -r prof; do
      [[ -z "$prof" ]] && continue
      _is_user_role "$prof" || continue

      local tf_name
      tf_name=$(_tf_name "$prof")
      _tf_import_resource "aws_iam_instance_profile" "$tf_name" "$prof" \
        "  name = \"$prof\"\n"
      PROF_COUNT=$((PROF_COUNT + 1))
    done < "$PROFS_FILE"
    rm -f "$PROFS_FILE"
    info "Processed $PROF_COUNT instance profiles (user-managed)"
  fi

  # ── Summary ──
  echo "" | tee -a "$LOG"
  echo "=== IAM direct import summary ===" | tee -a "$LOG"
  echo "  Total processed: $IMPORT_TOTAL" | tee -a "$LOG"
  echo "  Imported OK:     $IMPORT_OK" | tee -a "$LOG"
  echo "  Failed:          $IMPORT_FAIL" | tee -a "$LOG"
  echo "" | tee -a "$LOG"
  echo "  Resources per file:" | tee -a "$LOG"
  [ "$COUNT_policies" -gt 0 ]                   && printf "    %-40s → %s (%d)\n" "aws_iam_policy" "policies.tf" "$COUNT_policies" | tee -a "$LOG"
  [ "$COUNT_users" -gt 0 ]                      && printf "    %-40s → %s (%d)\n" "aws_iam_user" "users.tf" "$COUNT_users" | tee -a "$LOG"
  [ "$COUNT_user_policies" -gt 0 ]              && printf "    %-40s → %s (%d)\n" "aws_iam_user_policy" "user_policies.tf" "$COUNT_user_policies" | tee -a "$LOG"
  [ "$COUNT_user_policy_attachments" -gt 0 ]    && printf "    %-40s → %s (%d)\n" "aws_iam_user_policy_attachment" "user_policy_attachments.tf" "$COUNT_user_policy_attachments" | tee -a "$LOG"
  [ "$COUNT_groups" -gt 0 ]                     && printf "    %-40s → %s (%d)\n" "aws_iam_group" "groups.tf" "$COUNT_groups" | tee -a "$LOG"
  [ "$COUNT_group_policies" -gt 0 ]             && printf "    %-40s → %s (%d)\n" "aws_iam_group_policy" "group_policies.tf" "$COUNT_group_policies" | tee -a "$LOG"
  [ "$COUNT_group_policy_attachments" -gt 0 ]   && printf "    %-40s → %s (%d)\n" "aws_iam_group_policy_attachment" "group_policy_attachments.tf" "$COUNT_group_policy_attachments" | tee -a "$LOG"
  [ "$COUNT_group_memberships" -gt 0 ]          && printf "    %-40s → %s (%d)\n" "aws_iam_group_membership" "group_memberships.tf" "$COUNT_group_memberships" | tee -a "$LOG"
  [ "$COUNT_roles" -gt 0 ]                      && printf "    %-40s → %s (%d)\n" "aws_iam_role" "roles.tf" "$COUNT_roles" | tee -a "$LOG"
  [ "$COUNT_role_policies" -gt 0 ]              && printf "    %-40s → %s (%d)\n" "aws_iam_role_policy" "role_policies.tf" "$COUNT_role_policies" | tee -a "$LOG"
  [ "$COUNT_role_policy_attachments" -gt 0 ]    && printf "    %-40s → %s (%d)\n" "aws_iam_role_policy_attachment" "role_policy_attachments.tf" "$COUNT_role_policy_attachments" | tee -a "$LOG"
  [ "$COUNT_instance_profiles" -gt 0 ]          && printf "    %-40s → %s (%d)\n" "aws_iam_instance_profile" "instance_profiles.tf" "$COUNT_instance_profiles" | tee -a "$LOG"
  echo "=================================" | tee -a "$LOG"

  [[ $IMPORT_FAIL -eq 0 ]]
}
