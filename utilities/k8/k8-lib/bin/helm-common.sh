#!/usr/bin/env bash
# =============================================================================
# helm-common.sh — Shared definitions for helm-upgrade and helm-rollback
#
# Expects: INFRA_ROOT set before sourcing
# =============================================================================

HELM_DIR="${HELM_DIR:-$INFRA_ROOT/kubernetes/helm}"

# =============================================================================
# Chart path resolver — supports categorical subdirectories
#
# Charts may live at:
#   helm/<chart>/Chart.yaml              (flat — legacy)
#   helm/<category>/<chart>/Chart.yaml   (categorical — new layout)
#
# _resolve_chart_dir builds an associative array mapping chart name → directory.
# All downstream code uses _CHART_DIRS[chart] instead of $HELM_DIR/$chart.
# =============================================================================
declare -A _CHART_DIRS=()

# Load config-driven chart path overrides and scan dirs
_load_chart_path_overrides
_load_helm_scan_dirs

_build_chart_index() {
  _CHART_DIRS=()

  # 1. Auto-discover from HELM_DIR and any additional scan dirs
  local _scan_dirs=("$HELM_DIR")
  if [[ ${#_HELM_SCAN_DIRS[@]} -gt 0 ]]; then
    _scan_dirs+=("${_HELM_SCAN_DIRS[@]}")
  fi

  local _sd chart_yaml
  for _sd in "${_scan_dirs[@]}"; do
    [[ -d "$_sd" ]] || continue
    while IFS= read -r chart_yaml; do
      local dir name
      dir="$(dirname "$chart_yaml")"
      name="$(basename "$dir")"
      [[ -z "${_CHART_DIRS[$name]+x}" ]] && _CHART_DIRS["$name"]="$dir"
    done < <(find "$_sd" -maxdepth 3 -name Chart.yaml -not -path "*/charts/*" 2>/dev/null)
  done

  # 2. Apply explicit overrides (win over auto-discovered paths)
  if [[ ${#_CHART_PATH_OVERRIDES[@]} -gt 0 ]]; then
    local _key _val
    for _key in "${!_CHART_PATH_OVERRIDES[@]}"; do
      _val="${_CHART_PATH_OVERRIDES[$_key]}"
      if [[ "$_val" = /* ]]; then
        _CHART_DIRS["$_key"]="$_val"
      else
        _CHART_DIRS["$_key"]="$INFRA_ROOT/$_val"
      fi
    done
  fi
}
_build_chart_index

_chart_dir() {
  local chart="$1"
  if [[ -n "${_CHART_DIRS[$chart]+x}" ]]; then
    echo "${_CHART_DIRS[$chart]}"
  else
    echo "$HELM_DIR/$chart"
  fi
}

# =============================================================================
# Environment overlay (--env stage, --env production, etc.)
#
# When --env is set to a non-production value (e.g. "stage"), these helpers
# adjust release names, values files, namespace resolution, and chart
# filtering so the same helm charts can be deployed as isolated environment
# instances without modifying the charts themselves.
# =============================================================================
ENV_NAME=""

# Returns the helm release name for a chart. For non-production environments
# the release is prefixed with the env name to avoid collisions.
#   production:  my-frontend
#   stage:       stage-my-frontend
_get_release_name() {
  local chart="$1"
  if [[ -n "$ENV_NAME" && "$ENV_NAME" != "production" ]]; then
    echo "${ENV_NAME}-${chart}"
  else
    echo "$chart"
  fi
}

# Returns the -f flags needed for a helm install/upgrade. For non-production
# Emits the values file paths needed for a helm install/upgrade, one per line.
# For non-production environments this returns both the base values.yaml and
# the overlay (e.g. values-stage.yaml). Emits nothing if no overlay exists.
# Callers consume with: mapfile -t files < <(_get_values_files "$chart")
# This avoids word-splitting issues that occur when returning -f flags as a string.
_get_values_files() {
  local chart="$1"
  local chart_dir="$(_chart_dir "$chart")"
  if [[ -n "$ENV_NAME" && "$ENV_NAME" != "production" ]]; then
    local overlay="$chart_dir/values-${ENV_NAME}.yaml"
    if [[ -f "$overlay" ]]; then
      echo "$chart_dir/values.yaml"
      echo "$overlay"
    fi
  fi
}

# Checks whether a chart has a values overlay file for the current env.
# Always returns true for production (no overlay needed). For other envs,
# returns true only if values-{env}.yaml exists in the chart directory.
# Used to filter out charts that haven't been configured for staging yet.
_has_env_overlay() {
  local chart="$1"
  if [[ -z "$ENV_NAME" || "$ENV_NAME" == "production" ]]; then
    return 0
  fi
  [[ -f "$(_chart_dir "$chart")/values-${ENV_NAME}.yaml" ]]
}

# Resolves the target namespace for a chart+env combination. For non-production
# environments, reads global.namespace from the overlay file (e.g.
# values-stage.yaml declares a staging namespace). Falls back to the standard
# _get_namespace if no overlay or no namespace override is found.
_get_env_namespace() {
  local chart="$1"
  if [[ -n "$ENV_NAME" && "$ENV_NAME" != "production" ]]; then
    local overlay="$(_chart_dir "$chart")/values-${ENV_NAME}.yaml"
    if [[ -f "$overlay" ]]; then
      local ns
      ns=$(grep -A1 'global:' "$overlay" 2>/dev/null \
           | grep 'namespace:' | awk '{print $2}' | tr -d "\"'")
      if [[ -n "$ns" ]]; then
        echo "$ns"
        return
      fi
    fi
  fi
  _get_namespace "$chart"
}

# =============================================================================
# Dependency tiers — tier N completes before tier N+1 begins
#
# Loaded from infra-config.yaml (.tiers section) via config-resolver.sh.
# =============================================================================
_K8_LIB_DIR="${K8_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

TIERS=()
_load_tiers

# =============================================================================
# Chart → helm --namespace
#
# Resolves the target namespace for a chart by checking (in order):
#   1. Hardcoded overrides for infra charts (nginx-ingress, karpenter, etc.)
#   2. global.namespace from the chart's values.yaml
#   3. Convention: infra-* → "infra", app-* → $K8_NAMESPACE, else "default"
#
# Namespace overrides loaded from infra-config.yaml (.namespace_overrides section).
# =============================================================================

# Load namespace overrides
declare -A _NS_OVERRIDES=()
_load_ns_overrides

_get_namespace() {
  local chart="$1"

  # 1. Check config-file overrides
  if [[ -n "${_NS_OVERRIDES[$chart]+x}" ]]; then
    echo "${_NS_OVERRIDES[$chart]}"
    return
  fi

  # 2. Check values.yaml for global.namespace
  local ns
  ns=$(grep -A1 'global:' "$(_chart_dir "$chart")/values.yaml" 2>/dev/null \
       | grep 'namespace:' | awk '{print $2}' | tr -d "\"'")
  if [[ -n "$ns" ]]; then
    echo "$ns"
    return
  fi

  # 3. Convention-based fallback
  case "$chart" in
    infra-*) echo "${K8_INFRA_NAMESPACE:-infra}" ;;
    *)       echo "${K8_NAMESPACE:-default}" ;;
  esac
}

# =============================================================================
# Chart → helm --timeout
#
# Returns the --timeout value for a helm upgrade/rollback. Checks
# infra-config.yaml timeout_overrides, then falls back to 5m default.
# =============================================================================
declare -A _TIMEOUT_OVERRIDES=()
_load_timeout_overrides

_get_timeout() {
  local chart="$1"
  if [[ -n "${_TIMEOUT_OVERRIDES[$chart]+x}" ]]; then
    echo "${_TIMEOUT_OVERRIDES[$chart]}"
  else
    echo "5m"
  fi
}

# =============================================================================
# Array membership check
#
# Returns 0 (true) if $1 appears anywhere in the remaining arguments.
# Used throughout for include/exclude filtering and tier lookups.
# =============================================================================
_in_list() {
  local needle="$1"; shift
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

# =============================================================================
# Change impact analysis
#
# Compares live vs proposed manifests and emits impact tags describing what
# the upgrade will do. Used by the upgrade plan display and the policy
# engine to decide whether to prompt for confirmation.
#
# Impact tags: restart, configmap, secret, ingress, scaling, service, rbac
# =============================================================================
POLICY_FILE="$INFRA_ROOT/.helm-state/upgrade-policy.yaml"

# Renders proposed manifests for a chart. Returns them via stdout.
_render_proposed() {
  local chart="$1"
  local release ns chart_dir
  release="$(_get_release_name "$chart")"
  ns="$(_get_env_namespace "$chart")"
  chart_dir="$(_chart_dir "$chart")"

  local template_cmd=(helm template "$release" "$chart_dir" --namespace "$ns")
  local _vfiles
  mapfile -t _vfiles < <(_get_values_files "$chart")
  for f in "${_vfiles[@]}"; do
    template_cmd+=(-f "$f")
  done

  "${template_cmd[@]}" 2>/dev/null
}

# Compares live vs proposed manifests and emits impact tags, one per line.
# If the release doesn't exist yet, emits "new-release".
_analyze_impacts() {
  local chart="$1"
  local release ns
  release="$(_get_release_name "$chart")"
  ns="$(_get_env_namespace "$chart")"

  local proposed live
  proposed="$(_render_proposed "$chart" 2>/dev/null)" || { echo "template-error"; return; }
  live=$(helm get manifest "$release" -n "$ns" 2>/dev/null || true)

  if [[ -z "$live" ]]; then
    echo "new-release"
    return
  fi

  local impacts=()

  # Split manifests into individual resources and diff each
  local live_deploy proposed_deploy
  live_deploy=$(echo "$live" | awk '/^kind: Deployment$|^kind: StatefulSet$/{found=1} found{print} /^---$/{found=0}')
  proposed_deploy=$(echo "$proposed" | awk '/^kind: Deployment$|^kind: StatefulSet$/{found=1} found{print} /^---$/{found=0}')

  # Check for pod template changes (restart indicator)
  local live_template proposed_template
  live_template=$(echo "$live_deploy" | awk '/spec:/,0' | awk '/template:/,0')
  proposed_template=$(echo "$proposed_deploy" | awk '/spec:/,0' | awk '/template:/,0')
  if [[ -n "$proposed_template" ]] && ! diff -q <(echo "$live_template") <(echo "$proposed_template") &>/dev/null; then
    impacts+=(restart)
  fi

  # Check ConfigMap changes
  local live_cm proposed_cm
  live_cm=$(echo "$live" | awk '/^kind: ConfigMap$/{found=1} found{print} /^---$/{if(found) found=0}')
  proposed_cm=$(echo "$proposed" | awk '/^kind: ConfigMap$/{found=1} found{print} /^---$/{if(found) found=0}')
  if ! diff -q <(echo "$live_cm") <(echo "$proposed_cm") &>/dev/null; then
    impacts+=(configmap)
  fi

  # Check Secret changes
  local live_sec proposed_sec
  live_sec=$(echo "$live" | awk '/^kind: Secret$/{found=1} found{print} /^---$/{if(found) found=0}')
  proposed_sec=$(echo "$proposed" | awk '/^kind: Secret$/{found=1} found{print} /^---$/{if(found) found=0}')
  if ! diff -q <(echo "$live_sec") <(echo "$proposed_sec") &>/dev/null; then
    impacts+=(secret)
  fi

  # Check Ingress changes
  local live_ing proposed_ing
  live_ing=$(echo "$live" | awk '/^kind: Ingress$/{found=1} found{print} /^---$/{if(found) found=0}')
  proposed_ing=$(echo "$proposed" | awk '/^kind: Ingress$/{found=1} found{print} /^---$/{if(found) found=0}')
  if ! diff -q <(echo "$live_ing") <(echo "$proposed_ing") &>/dev/null; then
    impacts+=(ingress)
  fi

  # Check ScaledObject / HPA changes
  local live_scale proposed_scale
  live_scale=$(echo "$live" | awk '/^kind: (ScaledObject|HorizontalPodAutoscaler)$/{found=1} found{print} /^---$/{if(found) found=0}')
  proposed_scale=$(echo "$proposed" | awk '/^kind: (ScaledObject|HorizontalPodAutoscaler)$/{found=1} found{print} /^---$/{if(found) found=0}')
  if ! diff -q <(echo "$live_scale") <(echo "$proposed_scale") &>/dev/null; then
    impacts+=(scaling)
  fi

  # Check Service changes
  local live_svc proposed_svc
  live_svc=$(echo "$live" | awk '/^kind: Service$/{found=1} found{print} /^---$/{if(found) found=0}')
  proposed_svc=$(echo "$proposed" | awk '/^kind: Service$/{found=1} found{print} /^---$/{if(found) found=0}')
  if ! diff -q <(echo "$live_svc") <(echo "$proposed_svc") &>/dev/null; then
    impacts+=(service)
  fi

  # Check RBAC changes
  local live_rbac proposed_rbac
  live_rbac=$(echo "$live" | awk '/^kind: (ServiceAccount|Role|RoleBinding|ClusterRole|ClusterRoleBinding)$/{found=1} found{print} /^---$/{if(found) found=0}')
  proposed_rbac=$(echo "$proposed" | awk '/^kind: (ServiceAccount|Role|RoleBinding|ClusterRole|ClusterRoleBinding)$/{found=1} found{print} /^---$/{if(found) found=0}')
  if ! diff -q <(echo "$live_rbac") <(echo "$proposed_rbac") &>/dev/null; then
    impacts+=(rbac)
  fi

  if (( ${#impacts[@]} == 0 )); then
    echo "no-change"
  else
    printf '%s\n' "${impacts[@]}"
  fi
}

# Reads upgrade-policy.yaml and returns 0 (true) if any of the given impacts
# require confirmation. Merges: defaults → environment override → chart override.
_policy_requires_prompt() {
  local chart="$1"; shift
  local impacts=("$@")

  [[ ! -f "$POLICY_FILE" ]] && return 1

  for impact in "${impacts[@]}"; do
    [[ "$impact" == "new-release" || "$impact" == "no-change" || "$impact" == "template-error" ]] && continue

    local required="false"

    # Check defaults
    if command -v yq &>/dev/null; then
      required=$(yq -r ".defaults.${impact} // false" "$POLICY_FILE" 2>/dev/null)
      # Environment override
      if [[ -n "$ENV_NAME" && "$ENV_NAME" != "production" ]]; then
        local env_val
        env_val=$(yq -r ".environments.${ENV_NAME}.${impact} // null" "$POLICY_FILE" 2>/dev/null)
        [[ "$env_val" != "null" ]] && required="$env_val"
      fi
      # Chart override
      local chart_val
      chart_val=$(yq -r ".charts.${chart}.${impact} // null" "$POLICY_FILE" 2>/dev/null)
      [[ "$chart_val" != "null" ]] && required="$chart_val"
    else
      # Fallback: grep-based parsing for defaults only
      local val
      val=$(grep -A1 "^defaults:" "$POLICY_FILE" 2>/dev/null | grep "${impact}:" | awk '{print $2}' | tr -d "\"'" || true)
      [[ "$val" == "true" ]] && required="true"
    fi

    [[ "$required" == "true" ]] && return 0
  done

  return 1
}

# Formats impact tags into a short human-readable string for the plan table.
_format_impacts() {
  local impacts=("$@")
  local parts=()
  for i in "${impacts[@]}"; do
    case "$i" in
      restart)        parts+=("${RED}restart${NC}") ;;
      configmap)      parts+=("${YEL}configmap${NC}") ;;
      secret)         parts+=("${RED}secret${NC}") ;;
      ingress)        parts+=("ingress") ;;
      scaling)        parts+=("scaling") ;;
      service)        parts+=("service") ;;
      rbac)           parts+=("${YEL}rbac${NC}") ;;
      new-release)    parts+=("${GRN}new${NC}") ;;
      no-change)      parts+=("${GRN}no-change${NC}") ;;
      template-error) parts+=("${RED}error${NC}") ;;
    esac
  done
  local IFS=','
  echo "${parts[*]}"
}

# =============================================================================
# Preview — diff proposed manifests against what's currently deployed
#
# Renders the chart locally with `helm template` (layering env overlay if
# set), fetches live manifests with `helm get manifest`, and diffs them.
# For new releases (not yet deployed) the live side is empty so the diff
# shows the full proposed manifest as new content.
#
# Opens the diff in an external viewer by default. The viewer is chosen by:
#   1. --preview-tool CLI flag (PREVIEW_TOOL variable)
#   2. $K8_DIFF_VIEWER environment variable
#   3. Falls back to "code" (VS Code)
#
# Supported viewers:
#   code     — VS Code side-by-side diff (code --diff --wait)
#   kdiff3   — KDiff3 three-way merge tool
#   opendiff — macOS FileMerge
#   meld     — Meld visual diff
#   terminal — inline coloured diff (no external tool)
#
# Requires: step, info, ok, fail from common.sh
# =============================================================================
PREVIEW_TOOL=""

# Resolves which diff viewer to use. CLI flag wins, then env var, then "code".
_resolve_preview_tool() {
  if [[ -n "$PREVIEW_TOOL" ]]; then
    echo "$PREVIEW_TOOL"
  else
    echo "${K8_DIFF_VIEWER:-code}"
  fi
}

# Opens two temp files in the chosen diff viewer. Blocks until the viewer
# is closed (--wait for VS Code, blocking by default for others).
_open_diff_viewer() {
  local live_file="$1" proposed_file="$2" release="$3"
  local tool
  tool="$(_resolve_preview_tool)"

  case "$tool" in
    code)
      if command -v code &>/dev/null; then
        local _start=$SECONDS
        code --new-window --diff --wait "$live_file" "$proposed_file" || true
        if (( SECONDS - _start < 2 )); then
          warn "VS Code returned immediately — showing terminal diff"
          diff --color=always -u "$live_file" "$proposed_file" || true
        fi
      else
        warn "VS Code not found — falling back to terminal diff"
        diff --color=always -u "$live_file" "$proposed_file" || true
      fi
      ;;
    kdiff3)
      kdiff3 "$live_file" "$proposed_file"
      ;;
    opendiff)
      opendiff "$live_file" "$proposed_file" -merge /dev/null
      ;;
    meld)
      meld "$live_file" "$proposed_file"
      ;;
    terminal)
      diff --color=always -u "$live_file" "$proposed_file" || true
      ;;
    *)
      if command -v "$tool" &>/dev/null; then
        "$tool" "$live_file" "$proposed_file"
      else
        warn "Diff viewer '$tool' not found — falling back to terminal diff"
        diff --color=always -u "$live_file" "$proposed_file" || true
      fi
      ;;
  esac
}

# Global temp dir tracking for signal-safe cleanup.
_PREVIEW_TMPDIR=""
_cleanup_preview() { [[ -n "$_PREVIEW_TMPDIR" ]] && rm -rf "$_PREVIEW_TMPDIR"; _PREVIEW_TMPDIR=""; }
trap '_cleanup_preview' EXIT INT TERM

_preview_chart() {
  local chart="$1"
  local release ns chart_dir
  release="$(_get_release_name "$chart")"
  ns="$(_get_env_namespace "$chart")"
  chart_dir="$(_chart_dir "$chart")"

  step "Preview: $release (namespace=$ns)"

  # Build the helm template command, layering env overlay files if applicable
  local template_cmd=(helm template "$release" "$chart_dir" --namespace "$ns")
  local _vfiles
  mapfile -t _vfiles < <(_get_values_files "$chart")
  for f in "${_vfiles[@]}"; do
    template_cmd+=(-f "$f")
  done

  local proposed live
  if ! proposed=$("${template_cmd[@]}" 2>&1); then
    fail "helm template failed for $release"
    echo "$proposed"
    return 1
  fi

  # Fetch currently deployed manifests (empty if release doesn't exist yet)
  live=$(helm get manifest "$release" -n "$ns" 2>/dev/null || true)

  # Write to labelled temp files so the diff viewer shows meaningful names
  _PREVIEW_TMPDIR=$(mktemp -d)
  local live_file="$_PREVIEW_TMPDIR/${release}.live.yaml"
  local proposed_file="$_PREVIEW_TMPDIR/${release}.proposed.yaml"

  if [[ -z "$live" ]]; then
    echo "# (not deployed yet)" > "$live_file"
  else
    echo "$live" | sed '/^$/d' > "$live_file"
  fi
  echo "$proposed" | sed '/^$/d' > "$proposed_file"

  # Check for actual differences
  if diff -q "$live_file" "$proposed_file" &>/dev/null; then
    ok "$release: no changes vs live cluster"
    _cleanup_preview
    return 0
  fi

  info "Opening diff: $live_file → $proposed_file"
  _open_diff_viewer "$live_file" "$proposed_file" "$release"

  _cleanup_preview
  echo ""
}
