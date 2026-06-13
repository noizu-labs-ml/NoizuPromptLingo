#!/usr/bin/env bash
# =============================================================================
# docker-config.sh — Shared configuration and state management for docker
#                    build/push workflow.
#
# Sourced by: utils/docker-build, utils/docker-push
#
# Configuration loaded from infra-config.yaml (merged config):
#   docker.registry   — Docker registry host
#   docker.repos      — List of repo names (or auto-discovered from .project section)
#   docker.mappings   — Image-to-directory/dockerfile overrides
#   project.*         — Project definitions (composite or flat docker images)
#
# Env var overrides:
#   K8_DOCKER_REPOS    — Space-separated repo list (overrides YAML)
#   K8_DOCKER_REGISTRY — Registry host (overrides YAML)
# =============================================================================

_DOCKER_CFG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load infra-config.yaml (sets K8_DOCKER_REGISTRY, etc.)
source "$_DOCKER_CFG_DIR/config.sh"

# --- Auto-yes flag (set by --yes/-y in callers) ------------------------------
AUTO_YES=${AUTO_YES:-false}

# --- Confirm prompt (loops until valid input) --------------------------------
# Usage: _confirm "prompt text" → returns 0 (yes) or 1 (no)
#        _confirm_yiN "prompt text" → sets CONFIRM_RESULT to "y", "i", or "n"
# When AUTO_YES=true, auto-accepts and prints "(auto)" for auditability.
_is_yes() {
  case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
    y|yes|si) return 0 ;;
    *)        return 1 ;;
  esac
}

_confirm() {
  local prompt="$1"
  if [[ "$AUTO_YES" == "true" ]]; then
    echo "${prompt} [y/N] y (auto)"
    return 0
  fi
  local answer
  while true; do
    read -r -p "${prompt} [y/N] " answer
    if [[ -z "$answer" ]] || [[ "$answer" =~ ^[Nn]([Oo])?$ ]]; then
      return 1
    elif _is_yes "$answer"; then
      return 0
    fi
    echo "   Please enter y or n."
  done
}

_confirm_yiN() {
  local prompt="$1"
  if [[ "$AUTO_YES" == "true" ]]; then
    echo "${prompt} [y/i/N] y (auto)"
    CONFIRM_RESULT="y"; return 0
  fi
  local answer
  while true; do
    read -r -p "${prompt} [y/i/N] " answer
    if [[ -z "$answer" ]] || [[ "$answer" =~ ^[Nn]([Oo])?$ ]]; then
      CONFIRM_RESULT="n"; return 0
    elif _is_yes "$answer"; then
      CONFIRM_RESULT="y"; return 0
    elif [[ "$answer" =~ ^[Ii]$ ]]; then
      CONFIRM_RESULT="i"; return 0
    fi
    echo "   Please enter y, i, or n."
  done
}

# --- Docker repos list -------------------------------------------------------
# Load from: 1) K8_DOCKER_REPOS env var (space-separated)
#            2) .project section in merged infra-config.yaml
#            3) docker.repos section in merged infra-config.yaml
#            4) Empty array (caller must populate)

DOCKER_REPOS=()
REGISTRY="${K8_DOCKER_REGISTRY:-}"

# --- State directory (persists build/push tracking) ---
DOCKER_STATE_DIR="${INFRA_ROOT:-.}/.docker-state"

# =============================================================================
# Repo mapping tables
# =============================================================================
declare -A _DOCKER_DIR_MAP
declare -A _DOCKER_DOCKERFILE_MAP
declare -A _DOCKER_SINGLE_STAGE_MAP
declare -A _DOCKER_REGISTRY_PATH_MAP
declare -A _DOCKER_BUILD_ARGS_MAP
declare -A _DOCKER_PLATFORM_MAP

# =============================================================================
# YAML-based auto-discovery from merged infra-config.yaml
#
# Reads the .project section of $_K8_MERGED_CONFIG for docker service
# definitions. Supports both composite (project.type: composite,
# project.projects[].services[]) and flat (project.docker.images[]) layouts.
#
# For composite projects, image keys are "{domain}/{service-name}".
# For flat projects, image keys are the service name.
# =============================================================================
_DOCKER_YAML_LOADED=0

_require_yq() {
  if ! command -v yq &>/dev/null; then
    echo "❌ yq is required but not installed. Install via: brew install yq" >&2
    return 1
  fi
}

_load_composite_docker_services() {
  local yaml="$1"
  local config_dir="${_K8_CONFIG_DIR:-.}"

  # Resolve composite project root via PROJECTS_DIR + project.name
  # e.g., PROJECTS_DIR=<root>/repos, project.name=incubator → <root>/repos/incubator
  local project_name
  project_name="$(yq eval '.project.name // ""' "$yaml" 2>/dev/null || echo "")"
  local project_root="${config_dir}"
  if [[ -n "${PROJECTS_DIR:-}" && -n "$project_name" && "$project_name" != "null" ]]; then
    project_root="${PROJECTS_DIR}/${project_name}"
  fi

  local domains
  domains="$(yq eval '.project.projects[] | .domain' "$yaml" 2>/dev/null || true)"

  for domain in $domains; do
    local svc_count
    svc_count="$(yq eval ".project.projects[] | select(.domain==\"$domain\") | .services | length // 0" "$yaml" 2>/dev/null || echo "0")"
    [[ "$svc_count" -eq 0 || "$svc_count" == "null" ]] && continue

    local _dc_base_path
    _dc_base_path="$(yq eval ".project.projects[] | select(.domain==\"$domain\") | .base_path // \"\"" "$yaml" 2>/dev/null || echo "")"

    local svc_idx=0
    while [[ $svc_idx -lt $svc_count ]]; do
      local svc_base=".project.projects[] | select(.domain==\"$domain\") | .services[$svc_idx]"
      local svc_name svc_context svc_dockerfile svc_registry_path svc_auto_detect

      svc_name="$(yq eval "${svc_base}.name" "$yaml" 2>/dev/null || echo "")"
      [[ -z "$svc_name" || "$svc_name" == "null" ]] && { svc_idx=$((svc_idx + 1)); continue; }

      svc_context="$(yq eval "${svc_base}.context // \"\"" "$yaml" 2>/dev/null || echo "")"
      svc_dockerfile="$(yq eval "${svc_base}.dockerfile // \"\"" "$yaml" 2>/dev/null || echo "")"
      svc_registry_path="$(yq eval "${svc_base}.registry_path // \"\"" "$yaml" 2>/dev/null || echo "")"
      svc_auto_detect="$(yq eval "${svc_base}.auto_detect // \"\"" "$yaml" 2>/dev/null || echo "")"

      [[ "$svc_auto_detect" == "false" ]] || true

      local image_key="${domain}/${svc_name}"
      local abs_context
      if [[ -n "$_dc_base_path" && "$_dc_base_path" != "null" ]]; then
        abs_context="${project_root}/${_dc_base_path}"
      else
        abs_context="${project_root}/projects/${domain}"
      fi
      [[ -n "$svc_context" && "$svc_context" != "null" ]] && abs_context="${abs_context}/${svc_context}"

      DOCKER_REPOS+=("$image_key")
      _DOCKER_DIR_MAP["$image_key"]="$abs_context"

      if [[ -n "$svc_dockerfile" && "$svc_dockerfile" != "null" ]]; then
        local df_relative="$svc_dockerfile"
        if [[ -n "$svc_context" && "$svc_context" != "null" && "$svc_dockerfile" == "${svc_context}/"* ]]; then
          df_relative="${svc_dockerfile#${svc_context}/}"
        fi
        _DOCKER_DOCKERFILE_MAP["$image_key"]="$df_relative"
      fi

      if [[ -n "$svc_registry_path" && "$svc_registry_path" != "null" ]]; then
        _DOCKER_REGISTRY_PATH_MAP["$image_key"]="$svc_registry_path"
      fi

      # Build args as newline-separated KEY=VALUE
      local arg_count
      arg_count="$(yq eval "${svc_base}.build_args | keys | length // 0" "$yaml" 2>/dev/null || echo "0")"
      if [[ "$arg_count" -gt 0 && "$arg_count" != "null" ]]; then
        local args_str=""
        while IFS= read -r line; do
          [[ -n "$line" ]] && args_str+="${line}"$'\n'
        done < <(yq eval "${svc_base}.build_args | to_entries | .[] | .key + \"=\" + .value" "$yaml" 2>/dev/null || true)
        [[ -n "$args_str" ]] && _DOCKER_BUILD_ARGS_MAP["$image_key"]="$args_str"
      fi

      local svc_platform
      svc_platform="$(yq eval "${svc_base}.platform // \"\"" "$yaml" 2>/dev/null || echo "")"
      [[ -n "$svc_platform" && "$svc_platform" != "null" ]] && _DOCKER_PLATFORM_MAP["$image_key"]="$svc_platform"

      svc_idx=$((svc_idx + 1))
    done
  done
}

_load_flat_docker_services() {
  local yaml="$1"
  local config_dir="${_K8_CONFIG_DIR:-.}"

  local img_count
  img_count="$(yq eval '.project.docker.images | length // 0' "$yaml" 2>/dev/null || echo "0")"
  [[ "$img_count" -eq 0 || "$img_count" == "null" ]] && return

  local img_idx=0
  while [[ $img_idx -lt $img_count ]]; do
    local img_base=".project.docker.images[$img_idx]"
    local img_name img_context img_dockerfile img_registry_path

    img_name="$(yq eval "${img_base}.name" "$yaml" 2>/dev/null || echo "")"
    [[ -z "$img_name" || "$img_name" == "null" ]] && { img_idx=$((img_idx + 1)); continue; }

    img_context="$(yq eval "${img_base}.context // \"\"" "$yaml" 2>/dev/null || echo "")"
    img_dockerfile="$(yq eval "${img_base}.dockerfile // \"\"" "$yaml" 2>/dev/null || echo "")"
    img_registry_path="$(yq eval "${img_base}.registry_path // \"\"" "$yaml" 2>/dev/null || echo "")"

    local abs_context="$config_dir"
    [[ -n "$img_context" && "$img_context" != "null" ]] && abs_context="${config_dir}/${img_context}"

    DOCKER_REPOS+=("$img_name")
    _DOCKER_DIR_MAP["$img_name"]="$abs_context"

    if [[ -n "$img_dockerfile" && "$img_dockerfile" != "null" ]]; then
      _DOCKER_DOCKERFILE_MAP["$img_name"]="$img_dockerfile"
    fi

    if [[ -n "$img_registry_path" && "$img_registry_path" != "null" ]]; then
      _DOCKER_REGISTRY_PATH_MAP["$img_name"]="$img_registry_path"
    fi

    local arg_count
    arg_count="$(yq eval "${img_base}.build_args | keys | length // 0" "$yaml" 2>/dev/null || echo "0")"
    if [[ "$arg_count" -gt 0 && "$arg_count" != "null" ]]; then
      local args_str=""
      while IFS= read -r line; do
        [[ -n "$line" ]] && args_str+="${line}"$'\n'
      done < <(yq eval "${img_base}.build_args | to_entries | .[] | .key + \"=\" + .value" "$yaml" 2>/dev/null || true)
      [[ -n "$args_str" ]] && _DOCKER_BUILD_ARGS_MAP["$img_name"]="$args_str"
    fi

    local img_platform
    img_platform="$(yq eval "${img_base}.platform // \"\"" "$yaml" 2>/dev/null || echo "")"
    [[ -n "$img_platform" && "$img_platform" != "null" ]] && _DOCKER_PLATFORM_MAP["$img_name"]="$img_platform"

    img_idx=$((img_idx + 1))
  done
}

_load_yaml_docker_repos() {
  _require_yq || return

  local yaml="${_K8_MERGED_CONFIG:-}"
  [[ -z "$yaml" || ! -f "$yaml" ]] && return

  # Check if the merged config has a .project section
  local project_type
  project_type="$(yq eval '.project.type // ""' "$yaml" 2>/dev/null || true)"
  [[ -z "$project_type" && "$(yq eval '.project // ""' "$yaml" 2>/dev/null)" == "" ]] && return

  if [[ "$project_type" == "composite" ]]; then
    _load_composite_docker_services "$yaml"
  fi

  _load_flat_docker_services "$yaml"
}

_init_docker_repos() {
  [[ $_DOCKER_YAML_LOADED -eq 1 ]] && return

  if [[ -n "${K8_DOCKER_REPOS:-}" ]]; then
    read -ra DOCKER_REPOS <<< "$K8_DOCKER_REPOS"
  else
    _load_yaml_docker_repos
  fi

  # Fallback: load from infra-config.yaml docker.repos / docker.mappings
  if [[ ${#DOCKER_REPOS[@]} -eq 0 && -n "${_K8_CONFIG_PATH:-}" ]]; then
    _load_docker_repos
    _load_docker_mappings
  fi

  _DOCKER_YAML_LOADED=1
}

_init_docker_repos

# =============================================================================
# PUBLIC API
# =============================================================================

# -----------------------------------------------------------------------------
# get_all_docker_repos — list all known docker image keys
# -----------------------------------------------------------------------------
get_all_docker_repos() {
  printf '%s\n' "${DOCKER_REPOS[@]}"
}

# -----------------------------------------------------------------------------
# _registry_path_for_image — return the registry path override for an image
#   Falls back to image name if no override configured.
# -----------------------------------------------------------------------------
_registry_path_for_image() {
  local image="$1"
  if [[ -n "${_DOCKER_REGISTRY_PATH_MAP[$image]+x}" ]]; then
    echo "${_DOCKER_REGISTRY_PATH_MAP[$image]}"
  else
    echo "$image"
  fi
}

# -----------------------------------------------------------------------------
# _get_build_args — emit --build-arg flags for an image (one per line)
# -----------------------------------------------------------------------------
_get_build_args() {
  local image="$1"
  if [[ -n "${_DOCKER_BUILD_ARGS_MAP[$image]+x}" ]]; then
    local line
    while IFS= read -r line; do
      [[ -n "$line" ]] && echo "--build-arg" && echo "$line"
    done <<< "${_DOCKER_BUILD_ARGS_MAP[$image]}"
  fi
}

# -----------------------------------------------------------------------------
# _repo_dir_name — return the directory path for an image
#   For YAML-discovered repos this is an absolute path.
#   For legacy repos, relative name under repos/.
# -----------------------------------------------------------------------------
_repo_dir_name() {
  local image="$1"
  if [[ -n "${_DOCKER_DIR_MAP[$image]+x}" ]]; then
    echo "${_DOCKER_DIR_MAP[$image]}"
  else
    echo "$image"
  fi
}

# -----------------------------------------------------------------------------
# _image_for_dir — reverse lookup: directory path → image name
# -----------------------------------------------------------------------------
_image_for_dir() {
  local dir="$1"
  for image in "${!_DOCKER_DIR_MAP[@]}"; do
    if [[ "${_DOCKER_DIR_MAP[$image]}" == "$dir" ]]; then
      echo "$image"
      return
    fi
  done
  echo "$dir"
}

# -----------------------------------------------------------------------------
# _dockerfile_for_image — return the Dockerfile path for an image
#   Returns empty string for images using the default Dockerfile.
# -----------------------------------------------------------------------------
_dockerfile_for_image() {
  local image="$1"
  if [[ -n "${_DOCKER_DOCKERFILE_MAP[$image]+x}" ]]; then
    echo "${_DOCKER_DOCKERFILE_MAP[$image]}"
  else
    echo ""
  fi
}

# -----------------------------------------------------------------------------
# _platform_for_image — return per-image platform override, or empty string
# -----------------------------------------------------------------------------
_platform_for_image() {
  local image="$1"
  if [[ -n "${_DOCKER_PLATFORM_MAP[$image]+x}" ]]; then
    echo "${_DOCKER_PLATFORM_MAP[$image]}"
  else
    echo ""
  fi
}

# -----------------------------------------------------------------------------
# _is_single_stage — returns 0 if image uses a single-stage Dockerfile
# -----------------------------------------------------------------------------
_is_single_stage() {
  local image="$1"
  if [[ -n "${_DOCKER_SINGLE_STAGE_MAP[$image]+x}" ]]; then
    [[ "${_DOCKER_SINGLE_STAGE_MAP[$image]}" == "true" ]] && return 0
    return 1
  fi
  return 1
}

# -----------------------------------------------------------------------------
# normalize_repo_name — resolve directory names / shorthand to canonical image
# -----------------------------------------------------------------------------
normalize_repo_name() {
  local name="$1"
  for repo in "${DOCKER_REPOS[@]}"; do
    [[ "$repo" == "$name" ]] && echo "$name" && return 0
  done
  local image
  image="$(_image_for_dir "$name")"
  for repo in "${DOCKER_REPOS[@]}"; do
    [[ "$repo" == "$image" ]] && echo "$image" && return 0
  done
  # Domain fallback: "<domain>" resolves to "<domain>/<service>" when the
  # domain has exactly one service (composite single-service convenience).
  local _match="" _count=0
  for repo in "${DOCKER_REPOS[@]}"; do
    if [[ "$repo" == "${name}/"* ]]; then
      _match="$repo"
      _count=$((_count + 1))
    fi
  done
  [[ $_count -eq 1 ]] && { echo "$_match"; return 0; }
  return 1
}

# -----------------------------------------------------------------------------
# is_docker_repo — check if a name is a known docker repo
# -----------------------------------------------------------------------------
is_docker_repo() {
  normalize_repo_name "$1" > /dev/null 2>&1
}

# -----------------------------------------------------------------------------
# detect_docker_repo — detect repo from a directory path
#   Sets DETECTED_REPO on success, returns 1 if not in a known repo.
# -----------------------------------------------------------------------------
detect_docker_repo() {
  local dir="$1"
  for repo in "${DOCKER_REPOS[@]}"; do
    local repo_dir
    repo_dir="${_DOCKER_DIR_MAP[$repo]:-}"
    [[ -z "$repo_dir" ]] && continue
    if [[ "$dir" == "$repo_dir" || "$dir" == "$repo_dir"/* ]]; then
      DETECTED_REPO="$repo"
      return 0
    fi
  done
  return 1
}

# -----------------------------------------------------------------------------
# get_repo_dir — return absolute path for a repo's build context
# -----------------------------------------------------------------------------
get_repo_dir() {
  local image="$1"
  local dir
  dir="$(_repo_dir_name "$image")"
  # YAML-discovered repos store absolute paths
  if [[ "$dir" == /* ]]; then
    echo "$dir"
  else
    echo "${INFRA_ROOT}/repos/${dir}"
  fi
}

# =============================================================================
# STATE MANAGEMENT
#
# State files:
#   .docker-state/last      — last build vars (sourced)
#   .docker-state/shadow    — shadow of last pushed build (sourced)
#   .docker-state/builds    — unpushed build queue (line log, max 10)
#   .docker-state/pushes    — push history (line log, max 10)
#
# Line format: epoch|image|sha|vsn
# =============================================================================

_ensure_state_dir() {
  mkdir -p "$DOCKER_STATE_DIR"
}

# --- Save after a build ---
save_build_state() {
  local image="$1" sha="$2" vsn="$3"
  local now
  now=$(date +%s)
  _ensure_state_dir

  cat > "$DOCKER_STATE_DIR/last" <<EOF
LAST_BUILD_TIME=${now}
LAST_BUILD_IMAGE=${image}
LAST_BUILD_SHA=${sha}
LAST_BUILD_VSN=${vsn}
EOF

  # Append to unpushed builds queue, cap at 10
  echo "${now}|${image}|${sha}|${vsn}" >> "$DOCKER_STATE_DIR/builds"
  tail -10 "$DOCKER_STATE_DIR/builds" > "$DOCKER_STATE_DIR/builds.tmp"
  mv "$DOCKER_STATE_DIR/builds.tmp" "$DOCKER_STATE_DIR/builds"
}

# --- Load last build vars ---
load_build_state() {
  LAST_BUILD_TIME="" LAST_BUILD_IMAGE="" LAST_BUILD_SHA="" LAST_BUILD_VSN=""
  if [[ -f "$DOCKER_STATE_DIR/last" ]]; then
    source "$DOCKER_STATE_DIR/last"
  fi
}

# --- Record a push (moves build→shadow, clears last, logs push) ---
record_push_state() {
  local image="$1" sha="$2" vsn="$3"
  local now
  now=$(date +%s)
  _ensure_state_dir

  # Copy current last → shadow
  if [[ -f "$DOCKER_STATE_DIR/last" ]]; then
    sed 's/^LAST_/SHADOW_/' "$DOCKER_STATE_DIR/last" > "$DOCKER_STATE_DIR/shadow"
  fi

  # Clear last build
  cat > "$DOCKER_STATE_DIR/last" <<EOF
LAST_BUILD_TIME=
LAST_BUILD_IMAGE=
LAST_BUILD_SHA=
LAST_BUILD_VSN=
EOF

  # Remove matching entry from builds queue
  if [[ -f "$DOCKER_STATE_DIR/builds" ]]; then
    grep -v "|${image}|${sha}|" "$DOCKER_STATE_DIR/builds" \
      > "$DOCKER_STATE_DIR/builds.tmp" 2>/dev/null || true
    mv "$DOCKER_STATE_DIR/builds.tmp" "$DOCKER_STATE_DIR/builds"
  fi

  # Append to push history, cap at 10
  echo "${now}|${image}|${sha}|${vsn}" >> "$DOCKER_STATE_DIR/pushes"
  tail -10 "$DOCKER_STATE_DIR/pushes" > "$DOCKER_STATE_DIR/pushes.tmp"
  mv "$DOCKER_STATE_DIR/pushes.tmp" "$DOCKER_STATE_DIR/pushes"
}

# --- Load shadow build vars ---
load_shadow_state() {
  SHADOW_BUILD_TIME="" SHADOW_BUILD_IMAGE="" SHADOW_BUILD_SHA="" SHADOW_BUILD_VSN=""
  if [[ -f "$DOCKER_STATE_DIR/shadow" ]]; then
    source "$DOCKER_STATE_DIR/shadow"
  fi
}

# --- Get unpushed builds (raw lines) ---
get_unpushed_builds() {
  if [[ -f "$DOCKER_STATE_DIR/builds" && -s "$DOCKER_STATE_DIR/builds" ]]; then
    cat "$DOCKER_STATE_DIR/builds"
  fi
}

# --- Seconds since last build (999999 if none) ---
seconds_since_last_build() {
  load_build_state
  if [[ -z "${LAST_BUILD_TIME:-}" ]]; then
    echo "999999"
    return
  fi
  local now
  now=$(date +%s)
  echo $(( now - LAST_BUILD_TIME ))
}
