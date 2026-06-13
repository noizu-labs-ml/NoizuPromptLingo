#!/usr/bin/env bash
# =============================================================================
# docker-vsn.sh — Resolve VSN_MAJOR, VSN_MINOR, BUILD_ENV from a version
#                  string or by auto-detecting from the most recent build.
#
# Usage:
#   source utils/lib/docker-vsn.sh
#   resolve_vsn "registry" "image" ["vsn_string"]
#   check_stale_local_tags "registry" "image" major minor current_patch ["env_suffix"]
#   cleanup_version_tag "registry" "image" "version_tag"
#
# On success (return 0), sets:
#   VSN_MAJOR       e.g. 3
#   VSN_MINOR       e.g. 2
#   BUILD_ENV        e.g. "prod", "stage", "dev"
#   ENV_SUFFIX       e.g. "" (prod), "-stage", "-dev"
#   PLACEHOLDER_TAG  e.g. registry/image:v3.2.edge-stage
#   VERSION_KEY      e.g. image-v3.2.edge-stage
#
# On failure (return 1), sets:
#   RECENT_TAGS      comma-separated list of tags found on the image
# =============================================================================

# _scan_tags_for_vsn — scan tags on an image ID for a vM.m.edge pattern
#   Sets VSN_MAJOR, VSN_MINOR, BUILD_ENV, ENV_SUFFIX, RECENT_TAGS on match.
#   Returns 0 if found, 1 if not.
_scan_tags_for_vsn() {
  local registry="$1"
  local image="$2"
  local image_id="$3"

  local all_tags
  all_tags=$(docker image inspect "${image_id}" --format '{{range .RepoTags}}{{.}} {{end}}' 2>/dev/null || echo "")

  local found=""
  for tag in $all_tags; do
    local tag_suffix="${tag#"${registry}/${image}:"}"
    RECENT_TAGS="${RECENT_TAGS:+${RECENT_TAGS}, }${tag_suffix}"

    if [[ "$tag_suffix" =~ ^v([0-9]+)\.([0-9]+)\.edge(-(.+))?$ ]]; then
      VSN_MAJOR="${BASH_REMATCH[1]}"
      VSN_MINOR="${BASH_REMATCH[2]}"
      if [[ -n "${BASH_REMATCH[4]}" ]]; then
        BUILD_ENV="${BASH_REMATCH[4]}"
        ENV_SUFFIX="-${BUILD_ENV}"
      else
        BUILD_ENV="prod"
        ENV_SUFFIX=""
      fi
      found="$tag_suffix"
      break
    fi
  done

  [[ -n "$found" ]]
}

resolve_vsn() {
  local registry="$1"
  local image="$2"
  local vsn="${3:-}"

  # Reset outputs
  VSN_MAJOR="" VSN_MINOR="" BUILD_ENV="" ENV_SUFFIX=""
  PLACEHOLDER_TAG="" VERSION_KEY="" VERSION_TYPE_KEY="" RECENT_TAGS=""

  if [[ -n "$vsn" ]]; then
    # ------------------------------------------------------------------
    # Path 1: explicit version string passed in
    #   Accepts: 234.43.edge-stage, v3.2.edge, 4.2.edge-dev, v1.0.edge
    # ------------------------------------------------------------------
    vsn="${vsn#v}"  # strip leading v

    if [[ "$vsn" =~ ^([0-9]+)\.([0-9]+)\.edge(-(.+))?$ ]]; then
      VSN_MAJOR="${BASH_REMATCH[1]}"
      VSN_MINOR="${BASH_REMATCH[2]}"
      if [[ -n "${BASH_REMATCH[4]}" ]]; then
        BUILD_ENV="${BASH_REMATCH[4]}"
        ENV_SUFFIX="-${BUILD_ENV}"
      else
        BUILD_ENV="prod"
        ENV_SUFFIX=""
      fi
    else
      echo "❌  Invalid version format: v${vsn}"
      echo "   Expected: [v]Major.Minor.edge[-env]  (e.g., 3.2.edge, v1.0.edge-stage)"
      return 1
    fi

  else
    # ------------------------------------------------------------------
    # Path 2: auto-detect from most recent build
    #   Try git SHA first, then fall back to :latest tag
    # ------------------------------------------------------------------
    local image_id=""
    local detect_source=""

    # 2a: Try git SHA
    local git_sha
    git_sha=$(git rev-parse --short HEAD 2>/dev/null || echo "")

    if [[ -n "$git_sha" ]]; then
      local sha_image="${registry}/${image}:${git_sha}"
      if docker image inspect "${sha_image}" &>/dev/null; then
        image_id=$(docker image inspect "${sha_image}" --format '{{.Id}}' 2>/dev/null)
        detect_source="commit ${git_sha}"
      fi
    fi

    # 2b: Fall back to :latest
    if [[ -z "$image_id" ]]; then
      local latest_image="${registry}/${image}:latest"
      if docker image inspect "${latest_image}" &>/dev/null; then
        image_id=$(docker image inspect "${latest_image}" --format '{{.Id}}' 2>/dev/null)
        detect_source="latest"
      fi
    fi

    if [[ -z "$image_id" ]]; then
      echo "❌  No built image found for ${image} (tried${git_sha:+ git:${git_sha},} latest)"
      echo "   Run ./docker-build.sh first"
      return 1
    fi

    # Scan tags on the resolved image
    if ! _scan_tags_for_vsn "$registry" "$image" "$image_id"; then
      echo "⚠️  No vMajor.Minor.edge tag found on ${detect_source} build"
      echo "   Found tags: ${RECENT_TAGS}"
      return 1
    fi
  fi

  # Set derived outputs
  PLACEHOLDER_TAG="${registry}/${image}:v${VSN_MAJOR}.${VSN_MINOR}.edge${ENV_SUFFIX}"

  VERSION_KEY="${image}-v${VSN_MAJOR}.${VSN_MINOR}.edge"
  VERSION_TYPE_KEY="${VERSION_KEY}${ENV_SUFFIX}"
  return 0
}

# check_stale_local_tags — detect local versioned tags ahead of remote patch
#   Args: registry image vsn_major vsn_minor current_patch [env_suffix]
#   If stale tags found: prompts user to delete or returns 1.
#   Returns 0 if clean (no stale tags, or user chose to delete them).
check_stale_local_tags() {
  local registry="$1"
  local image="$2"
  local vsn_major="$3"
  local vsn_minor="$4"
  local current_patch="$5"
  local env_suffix="${6:-}"

  local stale_tags=()
  local env_suffix_re
  env_suffix_re=$(printf '%s' "$env_suffix" | sed 's/[.[\*^$()+?{|\\]/\\&/g')

  local local_versioned
  local_versioned=$(docker image ls "${registry}/${image}" --format '{{.Tag}}' 2>/dev/null \
    | grep -E "^v${vsn_major}\.${vsn_minor}\.[0-9]+${env_suffix_re}$" || true)

  local ltag local_patch
  for ltag in $local_versioned; do
    local_patch="${ltag#v${vsn_major}.${vsn_minor}.}"
    local_patch="${local_patch%${env_suffix}}"
    if [[ "$local_patch" =~ ^[0-9]+$ ]] && (( local_patch > current_patch )); then
      stale_tags+=("$ltag")
    fi
  done

  if (( ${#stale_tags[@]} == 0 )); then
    return 0
  fi

  echo ""
  echo "⚠️  Found local tag(s) ahead of remote patch version (${current_patch}):"
  local st
  for st in "${stale_tags[@]}"; do
    echo "     - ${registry}/${image}:${st}"
  done
  echo ""
  echo "   This usually means a previous push failed after tagging locally."
  if _confirm "   Delete stale local tag(s) and continue?"; then
    for st in "${stale_tags[@]}"; do
      docker rmi "${registry}/${image}:${st}" 2>/dev/null || true
      echo "   🗑️  Removed ${registry}/${image}:${st}"
    done
    return 0
  else
    echo "   Aborting. Remove tags manually or update remote version to match."
    return 1
  fi
}

# cleanup_version_tag — remove a local docker tag to prevent version drift
#   Args: registry image version_tag
cleanup_version_tag() {
  local registry="$1"
  local image="$2"
  local version_tag="$3"

  docker rmi "${registry}/${image}:${version_tag}" 2>/dev/null || true
  echo "     Removed ${registry}/${image}:${version_tag}"
}
