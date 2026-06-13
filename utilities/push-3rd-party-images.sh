#!/usr/bin/env bash
# =============================================================================
# Push 3rd-party Docker images to ops.noizu.com.
#
# Forked/extended services are built from $REPOS_3RD_DIR. Services that use
# upstream images directly are mirrored registry-to-registry when possible.
#
# Usage:
#   ./push-3rd-party-images.sh [--dry-run] [--build-only|--mirror-only] [--filter <pattern>] [image...]
#
# Examples:
#   ./push-3rd-party-images.sh                     # push all
#   ./push-3rd-party-images.sh bottlecrm docmost   # push specific images
#   ./push-3rd-party-images.sh --filter "ghost*"   # glob filter
#   ./push-3rd-party-images.sh --mirror-only        # mirror upstream images only
#   ./push-3rd-party-images.sh --dry-run            # preview only
# =============================================================================
set -uo pipefail

REGISTRY="ops.noizu.com"
REPOS_DIR="${REPOS_3RD_DIR:-$HOME/Github/infra/noizu-infra/repos/3rd}"
BUILDER="${DOCKER_BUILDER:-noizu-multi}"
PLATFORMS="${DOCKER_PLATFORMS:-linux/amd64,linux/arm64}"
DRY_RUN=false
FILTER=""
DO_BUILDS=true
DO_MIRRORS=true
TARGETS=()

# ── Parse args ───────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)  DRY_RUN=true; shift ;;
    --build-only) DO_BUILDS=true; DO_MIRRORS=false; shift ;;
    --mirror-only) DO_BUILDS=false; DO_MIRRORS=true; shift ;;
    --filter)   FILTER="$2"; shift 2 ;;
    --help|-h)
      sed -n '2,/^# ====/s/^# //p' "$0"; exit 0 ;;
    *)          TARGETS+=("$1"); shift ;;
  esac
done

# ── Image definitions ────────────────────────────────────────────
# Format: name|registry_path|context_dir|dockerfile
# context_dir is relative to $REPOS_DIR/<name>/
# If dockerfile is empty, defaults to Dockerfile in context_dir
declare -a IMAGES=(
  # --- Productivity / PM ---
  "bottlecrm|3rd/bottlecrm|.|Dockerfile"
  "docmost|3rd/docmost|.|Dockerfile"
  "listmonk|3rd/listmonk|.|Dockerfile"
  "plane-web|3rd/plane|apps/web|Dockerfile.web"
  "plane-api|3rd/plane|apiserver|Dockerfile.api"
  "plane-proxy|3rd/plane|apps/proxy|Dockerfile.ce"
  "plane-admin|3rd/plane|apps/admin|Dockerfile.admin"
  "taiga|3rd/taiga|.|Dockerfile"
  "nextcloud|3rd/nextcloud|.|Dockerfile"
  "postiz|3rd/postiz|.|Dockerfile.dev"

  # --- Design / Creative ---
  "penpot-frontend|3rd/penpot|docker/images|Dockerfile.frontend"
  "penpot-backend|3rd/penpot|docker/images|Dockerfile.backend"
  "excalidraw|3rd/excalidraw|.|Dockerfile"
  "excalidraw-room|3rd/excalidraw-room|.|Dockerfile"
  "drawio|3rd/drawio|.|Dockerfile"
  "webstudio|3rd/webstudio|.|Dockerfile"
  "mermaid-live-editor|3rd/mermaid-live-editor|.|Dockerfile"
  "livecodes|3rd/livecodes|.|Dockerfile"
  "chartdb|3rd/chartdb|.|Dockerfile"

  # --- AI / ML ---
  "open-webui|3rd/open-webui|.|Dockerfile"
  "langfuse-web|3rd/langfuse|web|Dockerfile"
  "langfuse-worker|3rd/langfuse|worker|Dockerfile"
  "label-studio|3rd/label-studio|.|Dockerfile"
  "livebook|3rd/livebook|.|Dockerfile"
  "phoenix|3rd/phoenix|.|Dockerfile"

  # --- Observability ---
  "signoz|3rd/signoz|cmd/community|Dockerfile"
  "signoz-otel-collector|3rd/signoz-otel-collector|cmd/signozotelcollector|Dockerfile"
  "signoz-schema-migrator|3rd/signoz-otel-collector|cmd/signozschemamigrator|Dockerfile"
  "posthog|3rd/posthog|.|Dockerfile"
  "matomo|3rd/matomo|.|Dockerfile"

  # --- CMS / Content ---
  "ghost|3rd/ghost|.|Dockerfile.production"
  "n8n|3rd/n8n|.|Dockerfile"
  "directus|3rd/directus|.|Dockerfile"
  "growthbook|3rd/growthbook|.|Dockerfile"

  # --- SEO / Marketing ---
  "seonaut|3rd/seonaut|.|Dockerfile"
  "serpbear|3rd/serpbear|.|Dockerfile"
  "mautic|3rd/mautic|.|Dockerfile"

  # --- Dev Tools ---
  "code-server|3rd/code-server|ci/release-image|Dockerfile"
  "hakatime|3rd/hakatime|.|Dockerfile"
  "metabase|3rd/metabase|.|Dockerfile"

  # --- Infrastructure ---
  "infisical|3rd/infisical|.|Dockerfile.standalone-infisical"
  "headlamp|3rd/headlamp|.|Dockerfile"

  # --- Databases / Storage ---
  "qdrant|3rd/qdrant|.|Dockerfile"
  "weaviate|3rd/weaviate|.|Dockerfile"

  # --- TTS ---
  "chatterbox|3rd/chatterbox|.|Dockerfile"
  "kitten-tts-server|3rd/kitten-tts-server|.|Dockerfile"

  # --- Mail ---
  "mailu-admin|3rd/mailu|core/admin|Dockerfile"
  "mailu-postfix|3rd/mailu|core/postfix|Dockerfile"
  "mailu-dovecot|3rd/mailu|core/dovecot|Dockerfile"
  "mailu-rspamd|3rd/mailu|core/rspamd|Dockerfile"
  "mailu-webmail|3rd/mailu|webmails|Dockerfile"

  # --- CRM ---
  "espocrm|3rd/espocrm|.|Dockerfile"

  # --- Diagrams ---
  "plantuml-server|3rd/plantuml-server|.|Dockerfile.jetty"
  "kroki|3rd/kroki|.|Dockerfile"
)

# Format: name|source_image|registry_path
# These are services/images consumed directly by Terraform or chart values, not
# images built from our forked/extended third-party repo checkouts.
declare -a MIRROR_IMAGES=(
  # --- Shared utility/base images ---
  "busybox-1.36|docker.io/library/busybox:1.36|3rd/library/busybox:1.36"
  "busybox-1.37|docker.io/library/busybox:1.37|3rd/library/busybox:1.37"
  "busybox-latest|docker.io/library/busybox:latest|3rd/library/busybox:latest"
  "node-22-alpine|docker.io/library/node:22-alpine|3rd/library/node:22-alpine"
  "nginx-1.27-alpine|docker.io/library/nginx:1.27-alpine|3rd/library/nginx:1.27-alpine"
  "postgres-16-alpine|docker.io/library/postgres:16-alpine|3rd/library/postgres:16-alpine"
  "redis-7-alpine|docker.io/library/redis:7-alpine|3rd/library/redis:7-alpine"

  # --- Infrastructure ---
  "registry-2|docker.io/library/registry:2|3rd/library/registry:2"
  "timescaledb-ha-with-age|docker.io/noizu/timescaledb-ha-with-age:pg17.9-ts2.25.2-all-age1.7.0-r2|3rd/noizu/timescaledb-ha-with-age:pg17.9-ts2.25.2-all-age1.7.0-r2"
  "clickhouse-25.5.6|docker.io/clickhouse/clickhouse-server:25.5.6|3rd/clickhouse/clickhouse-server:25.5.6"
  "valkey-8.1-alpine|docker.io/valkey/valkey:8.1-alpine|3rd/valkey/valkey:8.1-alpine"
  "zookeeper-3.9|docker.io/library/zookeeper:3.9|3rd/library/zookeeper:3.9"
  "signoz-zookeeper-3.7.1|docker.io/signoz/zookeeper:3.7.1|3rd/signoz/zookeeper:3.7.1"
  "minio|quay.io/minio/minio:RELEASE.2025-09-07T16-13-09Z|3rd/minio/minio:RELEASE.2025-09-07T16-13-09Z"
  "minio-2024|docker.io/minio/minio:RELEASE.2024-11-07T00-52-20Z|3rd/minio/minio:RELEASE.2024-11-07T00-52-20Z"
  "minio-mc|docker.io/minio/mc:RELEASE.2024-11-17T19-35-25Z|3rd/minio/mc:RELEASE.2024-11-17T19-35-25Z"

  # --- Infra services ---
  "authentik|ghcr.io/goauthentik/server:2025.6.0|3rd/goauthentik/server:2025.6.0"
  "headlamp-upstream|ghcr.io/headlamp-k8s/headlamp:v0.42.0|3rd/headlamp-k8s/headlamp:v0.42.0"
  "verdaccio|docker.io/verdaccio/verdaccio:6.7.2|3rd/verdaccio/verdaccio:6.7.2"
  "signoz-upstream|docker.io/signoz/signoz:v0.104.0|3rd/signoz/signoz:v0.104.0"
  "phoenix-upstream|docker.io/arizephoenix/phoenix:12.18.0|3rd/arizephoenix/phoenix:12.18.0"
  "posthog-upstream|docker.io/posthog/posthog:latest-release|3rd/posthog/posthog:latest-release"
  "posthog-redpanda|docker.io/redpandadata/redpanda:v24.3.1|3rd/redpandadata/redpanda:v24.3.1"
  "posthog-clickhouse|docker.io/clickhouse/clickhouse-server:22.8.21.38|3rd/clickhouse/clickhouse-server:22.8.21.38"
  "infisical-upstream|docker.io/infisical/infisical:v0.154.5|3rd/infisical/infisical:v0.154.5"

  # --- Mail ---
  "mailu-front|ghcr.io/mailu/nginx:2024.06|3rd/mailu/nginx:2024.06"
  "mailu-admin-upstream|ghcr.io/mailu/admin:2024.06|3rd/mailu/admin:2024.06"
  "mailu-postfix-upstream|ghcr.io/mailu/postfix:2024.06|3rd/mailu/postfix:2024.06"
  "mailu-dovecot-upstream|ghcr.io/mailu/dovecot:2024.06|3rd/mailu/dovecot:2024.06"
  "mailu-rspamd-upstream|ghcr.io/mailu/rspamd:2024.06|3rd/mailu/rspamd:2024.06"
  "mailu-webmail-upstream|ghcr.io/mailu/webmail:2024.06|3rd/mailu/webmail:2024.06"

  # --- Creative / content ---
  "penpot-backend-upstream|docker.io/penpotapp/backend:2.4.2|3rd/penpotapp/backend:2.4.2"
  "penpot-exporter-upstream|docker.io/penpotapp/exporter:2.4.2|3rd/penpotapp/exporter:2.4.2"
  "penpot-frontend-upstream|docker.io/penpotapp/frontend:2.4.2|3rd/penpotapp/frontend:2.4.2"

  # --- AI / notebooks ---
  "open-webui-upstream|ghcr.io/open-webui/open-webui:0.9.6|3rd/open-webui/open-webui:0.9.6"
  "litellm|ghcr.io/berriai/litellm:main-v1.83.7-stable|3rd/berriai/litellm:main-v1.83.7-stable"
  "alpine-socat|docker.io/alpine/socat:1.8.0.3|3rd/alpine/socat:1.8.0.3"
  "livebook-upstream|ghcr.io/livebook-dev/livebook:latest|3rd/livebook-dev/livebook:latest"
  "langfuse-upstream|docker.io/langfuse/langfuse:2|3rd/langfuse/langfuse:2"
  "vllm-openai|docker.io/vllm/vllm-openai:latest|3rd/vllm/vllm-openai:latest"
  "qdrant-upstream|docker.io/qdrant/qdrant:v1.17.1|3rd/qdrant/qdrant:v1.17.1"
  "weaviate-upstream|docker.io/semitechnologies/weaviate:1.34.0|3rd/semitechnologies/weaviate:1.34.0"
  "jupyterhub-singleuser|quay.io/jupyterhub/k8s-singleuser-sample:4.3.2|3rd/jupyterhub/k8s-singleuser-sample:4.3.2"
)

# ── Helpers ──────────────────────────────────────────────────────
_log()  { echo -e "\033[36m▸\033[0m $*"; }
_ok()   { echo -e "\033[32m✓\033[0m $*"; }
_warn() { echo -e "\033[33m⚠\033[0m $*" >&2; }
_err()  { echo -e "\033[31m✗\033[0m $*" >&2; }

_should_build() {
  local name="$1"
  if [[ ${#TARGETS[@]} -gt 0 ]]; then
    for t in "${TARGETS[@]}"; do
      [[ "$name" == "$t" ]] && return 0
    done
    return 1
  fi
  if [[ -n "$FILTER" ]]; then
    # shellcheck disable=SC2053
    [[ "$name" == $FILTER ]] && return 0 || return 1
  fi
  return 0
}

_mirror_tool() {
  if command -v skopeo >/dev/null 2>&1; then
    echo "skopeo"
  elif command -v crane >/dev/null 2>&1; then
    echo "crane"
  elif docker buildx imagetools --help >/dev/null 2>&1; then
    echo "imagetools"
  else
    echo "docker"
  fi
}

_mirror_image() {
  local source="$1"
  local dest="$2"
  local tool
  local skopeo_policy_args=()
  local skopeo_copy_args=()
  tool="$(_mirror_tool)"

  case "$tool" in
    skopeo)
      if [[ ! -f "$HOME/.config/containers/policy.json" && ! -f /etc/containers/policy.json ]]; then
        _warn "No containers policy.json found; using skopeo --insecure-policy"
        skopeo_policy_args+=(--insecure-policy)
      fi
      if [[ -f "$HOME/.docker/config.json" ]]; then
        skopeo_copy_args+=(--authfile "$HOME/.docker/config.json")
      fi
      skopeo "${skopeo_policy_args[@]}" copy "${skopeo_copy_args[@]}" --all "docker://$source" "docker://$dest"
      ;;
    crane)
      crane copy "$source" "$dest"
      ;;
    imagetools)
      docker buildx imagetools create -t "$dest" "$source"
      ;;
    docker)
      _warn "skopeo/crane not found; falling back to Docker pull/tag/push for local platform only"
      docker pull "$source" &&
        docker tag "$source" "$dest" &&
        docker push "$dest"
      ;;
  esac
}

# ── Main ─────────────────────────────────────────────────────────
_log "Registry: $REGISTRY"
_log "Repos:    $REPOS_DIR"
_log "Builder:  $BUILDER"
_log "Platforms: $PLATFORMS"
_log "Mode:     builds=$DO_BUILDS mirrors=$DO_MIRRORS"
$DRY_RUN && _warn "DRY RUN — no images will be pushed"
echo ""

built=0; mirrored=0; skipped=0; failed=0; errors=()

if $DO_BUILDS; then
  for entry in "${IMAGES[@]}"; do
    IFS='|' read -r name registry_path context_rel dockerfile <<< "$entry"

    _should_build "$name" || continue

    # For entries like "3rd/plane", extract the repo name.
    repo_base=$(echo "$registry_path" | sed 's|^3rd/||' | cut -d'/' -f1)
    repo_dir="$REPOS_DIR/$repo_base"
    build_context="$repo_dir/$context_rel"
    image_tag="$REGISTRY/$name:latest"

    if [[ ! -d "$build_context" ]]; then
      _warn "SKIP $name — context not found: $build_context"
      ((skipped++))
      continue
    fi

    if [[ ! -f "$build_context/$dockerfile" ]]; then
      _warn "SKIP $name — Dockerfile not found: $build_context/$dockerfile"
      ((skipped++))
      continue
    fi

    _log "Building $name → $image_tag"
    _log "  context:    $build_context"
    _log "  dockerfile: $dockerfile"

    if $DRY_RUN; then
      _ok "DRY RUN: would push $image_tag"
      ((built++))
      continue
    fi

    if docker buildx build \
      --builder "$BUILDER" \
      --platform "$PLATFORMS" \
      --push \
      -t "$image_tag" \
      -f "$build_context/$dockerfile" \
      "$build_context" 2>&1 | tail -5; then
      _ok "Pushed $image_tag"
      ((built++))
    else
      _err "FAILED build $name"
      errors+=("build:$name")
      ((failed++))
    fi
    echo ""
  done
fi

if $DO_MIRRORS; then
  mirror_tool="$(_mirror_tool)"
  _log "Mirror tool: $mirror_tool"
  echo ""

  for entry in "${MIRROR_IMAGES[@]}"; do
    IFS='|' read -r name source registry_path <<< "$entry"

    _should_build "$name" || continue

    image_tag="$REGISTRY/$registry_path"

    _log "Mirroring $name"
    _log "  source: $source"
    _log "  dest:   $image_tag"

    if $DRY_RUN; then
      _ok "DRY RUN: would mirror $source → $image_tag"
      ((mirrored++))
      continue
    fi

    if _mirror_image "$source" "$image_tag"; then
      _ok "Mirrored $image_tag"
      ((mirrored++))
    else
      _err "FAILED mirror $name"
      errors+=("mirror:$name")
      ((failed++))
    fi
    echo ""
  done
fi

# ── Summary ──────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
_ok "Built:   $built"
_ok "Mirrored: $mirrored"
[[ $skipped -gt 0 ]] && _warn "Skipped: $skipped"
[[ $failed -gt 0 ]]  && _err  "Failed:  $failed — ${errors[*]}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
