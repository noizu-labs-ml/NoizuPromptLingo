#!/usr/bin/env bash
# =============================================================================
# project-registry.sh — project.yaml registry loader for k8-lib tools
#
# Reads project.yaml files from $PROJECTS_DIR/*/ and populates parallel
# arrays for use by helm-upgrade, deploy-service, and CLI tooling.
#
# Requires: yq (https://github.com/mikefarah/yq/)
# =============================================================================

# Guard against double-sourcing
if [[ -n "${_PROJECT_REGISTRY_LOADED:-}" ]]; then
  return 0 2>/dev/null || true
fi
_PROJECT_REGISTRY_LOADED=1

# =============================================================================
# REGISTRY ARRAYS
# =============================================================================
PROJECT_NAMES=()
PROJECT_RELEASES=()
PROJECT_NAMESPACES=()
PROJECT_TIERS=()
PROJECT_TIMEOUTS=()
PROJECT_DIRS=()
PROJECT_STATUSES=()
PROJECT_CHART_PATHS=()
PROJECT_UPSTREAM_REPOS=()
PROJECT_UPSTREAM_URLS=()
PROJECT_UPSTREAM_CHARTS=()
PROJECT_UPSTREAM_VERSIONS=()
PROJECT_PRE_APPLY=()
PROJECT_POST_APPLY=()

# =============================================================================
# REGISTRY LOADER
# =============================================================================
load_project_registry() {
  local projects_dir="${1:-${PROJECTS_DIR:-}}"

  if [[ -z "$projects_dir" ]]; then
    echo "❌ PROJECTS_DIR not set and no argument given to load_project_registry" >&2
    echo "   Set paths.projects_dir in infra-config.yaml or pass a path argument" >&2
    return 1
  fi

  _k8_require_yq

  local yaml
  for yaml in "$projects_dir"/*/project.yaml; do
    [[ -f "$yaml" ]] || continue

    local proj_dir
    proj_dir="$(dirname "$yaml")"

    local status
    status="$(yq -r '.status // "active"' "$yaml")"

    case "$status" in
      disabled|kickoff-only) continue ;;
    esac

    local release ns tier timeout chart_path
    release="$(yq -r '.helm.release // ""' "$yaml")"
    ns="$(yq -r '.helm.namespace // ""' "$yaml")"
    tier="$(yq -r '.helm.tier // 5' "$yaml")"
    timeout="$(yq -r '.helm.timeout // "10m"' "$yaml")"
    chart_path="$(yq -r '.helm.path // ""' "$yaml")"

    [[ -z "$release" ]] && continue

    local up_repo up_url up_chart up_version
    up_repo="$(yq -r '.helm.upstream.repo // ""' "$yaml")"
    up_url="$(yq -r '.helm.upstream.url // ""' "$yaml")"
    up_chart="$(yq -r '.helm.upstream.chart // ""' "$yaml")"
    up_version="$(yq -r '.helm.upstream.version // ""' "$yaml")"

    local pre_apply post_apply
    pre_apply="$(yq -r '.helm.preApply // [] | .[]' "$yaml" 2>/dev/null || true)"
    post_apply="$(yq -r '.helm.postApply // [] | .[]' "$yaml" 2>/dev/null || true)"

    local proj_name
    proj_name="$(basename "$proj_dir")"

    PROJECT_NAMES+=("$proj_name")
    PROJECT_RELEASES+=("$release")
    PROJECT_NAMESPACES+=("$ns")
    PROJECT_TIERS+=("$tier")
    PROJECT_TIMEOUTS+=("$timeout")
    PROJECT_DIRS+=("$proj_dir")
    PROJECT_STATUSES+=("$status")
    PROJECT_CHART_PATHS+=("$chart_path")
    PROJECT_UPSTREAM_REPOS+=("$up_repo")
    PROJECT_UPSTREAM_URLS+=("$up_url")
    PROJECT_UPSTREAM_CHARTS+=("$up_chart")
    PROJECT_UPSTREAM_VERSIONS+=("$up_version")
    PROJECT_PRE_APPLY+=("$pre_apply")
    PROJECT_POST_APPLY+=("$post_apply")
  done
}

# =============================================================================
# LOOKUP FUNCTIONS
# =============================================================================

lookup_namespace() {
  local name="$1" i=0
  while [[ $i -lt ${#PROJECT_RELEASES[@]} ]]; do
    [[ "${PROJECT_RELEASES[$i]}" == "$name" ]] && { echo "${PROJECT_NAMESPACES[$i]}"; return; }
    i=$((i + 1))
  done
  echo ""
}

lookup_tier() {
  local name="$1" i=0
  while [[ $i -lt ${#PROJECT_RELEASES[@]} ]]; do
    [[ "${PROJECT_RELEASES[$i]}" == "$name" ]] && { echo "${PROJECT_TIERS[$i]}"; return; }
    i=$((i + 1))
  done
  echo "5"
}

lookup_tier_by_namespace() {
  local ns="$1" i=0
  while [[ $i -lt ${#PROJECT_NAMESPACES[@]} ]]; do
    [[ "${PROJECT_NAMESPACES[$i]}" == "$ns" ]] && { echo "${PROJECT_TIERS[$i]}"; return; }
    i=$((i + 1))
  done
  echo ""
}

lookup_timeout() {
  local name="$1" i=0
  while [[ $i -lt ${#PROJECT_RELEASES[@]} ]]; do
    [[ "${PROJECT_RELEASES[$i]}" == "$name" ]] && { echo "${PROJECT_TIMEOUTS[$i]}"; return; }
    i=$((i + 1))
  done
  echo "10m"
}

lookup_project_name_by_release() {
  local name="$1" i=0
  while [[ $i -lt ${#PROJECT_RELEASES[@]} ]]; do
    [[ "${PROJECT_RELEASES[$i]}" == "$name" ]] && { echo "${PROJECT_NAMES[$i]}"; return; }
    i=$((i + 1))
  done
  echo ""
}

lookup_project_dir() {
  local name="$1" i=0
  while [[ $i -lt ${#PROJECT_RELEASES[@]} ]]; do
    [[ "${PROJECT_RELEASES[$i]}" == "$name" ]] && { echo "${PROJECT_DIRS[$i]}"; return; }
    i=$((i + 1))
  done
  echo ""
}

is_upstream_chart() {
  local name="$1" i=0
  while [[ $i -lt ${#PROJECT_RELEASES[@]} ]]; do
    if [[ "${PROJECT_RELEASES[$i]}" == "$name" ]]; then
      [[ -z "${PROJECT_CHART_PATHS[$i]}" && -n "${PROJECT_UPSTREAM_CHARTS[$i]}" ]] && return 0
      return 1
    fi
    i=$((i + 1))
  done
  return 1
}

lookup_upstream_chart() {
  local name="$1" i=0
  while [[ $i -lt ${#PROJECT_RELEASES[@]} ]]; do
    [[ "${PROJECT_RELEASES[$i]}" == "$name" ]] && { echo "${PROJECT_UPSTREAM_CHARTS[$i]}"; return; }
    i=$((i + 1))
  done
  echo ""
}
