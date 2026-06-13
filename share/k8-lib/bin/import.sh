#!/usr/bin/env bash

# =============================================================================
cmd_import() {
  echo ""
  echo -e "${BLU}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${BLU}║  infra-init import                           ║${NC}"
  echo -e "${BLU}╚══════════════════════════════════════════════╝${NC}"

  # --- Flags ------------------------------------------------------------------
  FORCE=false
  for arg in "$@"; do
    [[ "$arg" == "--force" ]] && FORCE=true
  done
  if $FORCE; then
    warn "--force specified: will re-import all groups regardless of existing dirs"
  fi

  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  LOG="$REPO_ROOT/terraform/production/imported/import-${TIMESTAMP}.log"
  mkdir -p "$REPO_ROOT/terraform/production/imported"

  info "Logging to $LOG"

  # Resource groups: label | terraformer resources (comma-sep) | output subdir
  #
  # Recommended import order (dependency-aware):
  #   1. network      — VPC / subnets / SGs — everything else refs these
  #   2. compute      — EC2, ASG, EBS — refs SGs, subnets, IAM instance profiles
  #   3. iam          — roles, policies, instance profiles (global, no region)
  #   4. security     — KMS, ACM, Secrets Manager, SSM, WAF
  #   5. storage      — S3, EFS — refs KMS, IAM
  #   6. database     — RDS, ElastiCache, DynamoDB — refs VPC, SGs, KMS, IAM
  #   7. messaging    — SQS, SNS, Kinesis — refs IAM, KMS
  #   8. loadbalancer — ALB/ELB — refs SGs, subnets, ACM
  #   9. serverless   — Lambda — refs IAM, SGs, VPC
  #  10. appservices  — API GW, Cognito, SES, SFN
  #  11. cdn          — CloudFront — refs S3, ACM, ALB origins
  #  12. dns          — Route53, ACM — refs CloudFront, ALBs
  #  13. cicd         — CodeDeploy, CodePipeline — refs IAM, S3, compute
  #  14. containers   — ECR — refs IAM
  #  15. monitoring   — CloudWatch, logs — refs most other services
  #  16. other        — Glue, EMR, misc
  #  17. global-misc  — Budgets, ECR Public, Org (global, no region)
  IMPORT_GROUPS=(
    # --- Networking ---
    "network-core|vpc,subnet,route_table,nacl,igw,nat|network"
    "network-security|sg,eip,eni,customer_gateway,transit_gateway,vpc_peering,vpc_endpoint|network"
    "network-vpn|vpn_connection,vpn_gateway|network"
    # --- Compute ---
    "compute-instances|ec2_instance,auto_scaling,ebs|compute"
    "compute-containers|ecs,eks|compute"
    "compute-other|elastic_beanstalk,batch|compute"
    # --- IAM (global — no region flag) ---
    "global-iam|iam|iam"
    # --- Security ---
    "security|kms,secretsmanager,ssm,waf,waf_regional,wafv2_cloudfront,wafv2_regional,securityhub,accessanalyzer,config,cloudtrail|security"
    # --- Storage ---
    "storage|s3,efs|storage"
    # --- Databases ---
    "database|rds,elasticache,dynamodb,docdb,redshift,qldb|database"
    # --- Messaging ---
    "messaging|sns,sqs,kinesis,firehose,mq,msk|messaging"
    # --- Load Balancing ---
    "loadbalancer|alb,elb|loadbalancer"
    # --- Serverless ---
    "serverless|lambda|serverless"
    # --- App Services ---
    "appservices|api_gateway,appsync,cognito,ses,sfn,swf|appservices"
    # --- CDN ---
    "cdn|cloudfront|cdn"
    # --- DNS & Certs ---
    "dns|route53,acm|dns"
    # --- CI/CD ---
    "cicd|codebuild,codecommit,codedeploy,codepipeline|cicd"
    # --- Containers Registry ---
    "containers|ecr|containers"
    # --- Monitoring ---
    "monitoring|cloudwatch,logs,xray|monitoring"
    # --- Other ---
    "other|glue,emr,es,iot,workspaces,resourcegroups,servicecatalog,opsworks,cloud9,cloudformation,datapipeline,devicefarm,media_package,media_store,medialive|other"
    # --- Global (no region) ---
    "global-misc|budgets,ecrpublic|global"
  )

  PASS_COUNT=0
  SKIP_COUNT=0
  FAIL_COUNT=0
  declare -a FAILED_IMPORT_GROUPS=()
  declare -a SKIPPED_GROUPS=()

  for group in "${IMPORT_GROUPS[@]}"; do
    IFS='|' read -r LABEL RESOURCES SUBDIR <<< "$group"

    # Global resources have no region
    if [[ "$LABEL" == global-* ]]; then
      REGION_FLAG=""
    else
      REGION_FLAG="--regions=us-east-1"
    fi

    # --- Skip logic: check which resources in this group are already imported --
    # Terraformer writes to: $IMPORTED_DIR/$SUBDIR/$resource/
    # A dir is considered "imported" if it contains a resources.tf file.
    IMPORTED_DIR_PATH="$REPO_ROOT/terraform/production/imported"

    MISSING_RESOURCES=()
    ALREADY_DONE=()
    IFS=',' read -ra RES_ARRAY <<< "$RESOURCES"
    for res in "${RES_ARRAY[@]}"; do
      svc_dir="$IMPORTED_DIR_PATH/$SUBDIR/$res"
      # Terraformer sometimes writes to $svc_dir/resources.tf (no region) or
      # $svc_dir/$REGION/resources.tf (with region). Check both.
      found=false
      if ! $FORCE; then
        # Check for resources.tf or any split .tf files (roles.tf, etc.)
        if [[ -f "$svc_dir/resources.tf" ]] || ls "$svc_dir"/*.tf &>/dev/null 2>&1; then
          found=true
        else
          for region_dir in "$svc_dir"/*/; do
            if [[ -f "${region_dir}resources.tf" ]] || ls "${region_dir}"*.tf &>/dev/null 2>&1; then
              found=true
              break
            fi
          done
        fi
      fi
      if $found; then
        ALREADY_DONE+=("$res")
      else
        MISSING_RESOURCES+=("$res")
      fi
    done

    # If nothing is missing, skip the whole group
    if [[ ${#MISSING_RESOURCES[@]} -eq 0 ]]; then
      info "SKIP $LABEL — all resources already imported: [${ALREADY_DONE[*]}]"
      SKIPPED_GROUPS+=("$LABEL")
      ((SKIP_COUNT++)) || true
      continue
    fi

    # If some resources already imported, report and proceed with remainder
    if [[ ${#ALREADY_DONE[@]} -gt 0 ]]; then
      info "Partial: skipping already-imported [${ALREADY_DONE[*]}], importing [${MISSING_RESOURCES[*]}]"
    fi

    RESOURCES_TO_RUN=$(IFS=','; echo "${MISSING_RESOURCES[*]}")
    step "Importing $LABEL → $RESOURCES_TO_RUN"
    echo "=== $LABEL ===" >> "$LOG"

    # --- IAM: bypass terraformer (it hangs scanning 1000+ AWS-managed policies)
    # Instead: aws CLI list → write HCL stubs → terraform import per resource
    if [[ "$LABEL" == "global-iam" ]]; then
      _import_iam_direct "$LOG"
      TERRAFORMER_EXIT=$?
    else
      info "  (streaming output live — also logged to: $LOG)"
      terraformer import aws \
          --resources="$RESOURCES_TO_RUN" \
          $REGION_FLAG \
          --profile="$PROFILE" \
          --path-output="$REPO_ROOT/terraform/production/imported" \
          --path-pattern="{output}/$SUBDIR/{service}/" \
          --compact \
          2>&1 | tee -a "$LOG"
      TERRAFORMER_EXIT=${PIPESTATUS[0]}
    fi

    if [[ $TERRAFORMER_EXIT -eq 0 ]]; then
      # Scan log tail for "not supported service" errors
      ERRORS_IN_LOG=$(tail -20 "$LOG" | grep "not supported service" || true)
      if [[ -n "$ERRORS_IN_LOG" ]]; then
        warn "$LABEL — some resources not supported:"
        echo "$ERRORS_IN_LOG" | sed 's/^/    /'
        FAILED_IMPORT_GROUPS+=("$LABEL: unsupported resource names in [$RESOURCES_TO_RUN]")
        ((FAIL_COUNT++)) || true
      else
        ok "$LABEL imported"
        ((PASS_COUNT++)) || true
      fi
    else
      fail "$LABEL failed (exit $TERRAFORMER_EXIT) — check $LOG"
      FAILED_IMPORT_GROUPS+=("$LABEL: exited $TERRAFORMER_EXIT")
      ((FAIL_COUNT++)) || true
    fi
  done

  # --- Summary ---------------------------------------------------------------
  echo ""
  echo -e "${BLU}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${BLU}║  Import Summary                              ║${NC}"
  echo -e "${BLU}╚══════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "  ${PASS} $PASS_COUNT groups imported"
  if [[ $SKIP_COUNT -gt 0 ]]; then
    echo -e "  ${INFO} $SKIP_COUNT groups skipped (already imported):"
    for s in "${SKIPPED_GROUPS[@]}"; do
      echo -e "    • $s"
    done
    echo -e "  ${INFO} To re-import skipped groups: infra-init import --force"
  fi
  if [[ $FAIL_COUNT -gt 0 ]]; then
    echo -e "  ${FAIL} $FAIL_COUNT groups had issues:"
    for f in "${FAILED_IMPORT_GROUPS[@]}"; do
      echo -e "    ${WARN} $f"
    done
  fi
  echo ""
  echo -e "  ${INFO} Full log: $LOG"
  echo -e "  ${INFO} Review what landed:"
  echo -e "        find terraform/production/imported -name 'resources.tf' | sort"
  echo -e "  ${INFO} Next steps:"
  echo -e "        infra-init cleanup       # strip Terraformer schema noise"
  echo -e "        infra-init state-upgrade # migrate legacy provider state + init"
  echo ""
}
