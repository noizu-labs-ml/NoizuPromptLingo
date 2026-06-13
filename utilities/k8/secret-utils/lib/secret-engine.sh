#!/usr/bin/env bash
# =============================================================================
# Secret Engine Library
#
# Core functions for secret manipulation across:
# - Infisical (remote storage)
# - .infisical-secrets.yaml (declarative mapping)
# - .envrc.dc (runtime configuration via dc get)
# =============================================================================

set -euo pipefail

# -- Color output ------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
NC='\033[0m'

# -- Logging -----------------------------------------------------------------
log_info()    { echo -e "${BLUE}ℹ${NC} $*"; }
log_success() { echo -e "${GREEN}✓${NC} $*"; }
log_warn()    { echo -e "${YELLOW}⚠${NC}  $*"; }
log_error()   { echo -e "${RED}✗${NC}  $*"; }
die()         { echo -e "${RED}✗${NC}  $*" >&2; exit 1; }

# -- Infisical API Client ----------------------------------------------------

# Global cache for API token to avoid re-auth on every call
declare -g SECRET_ENGINE_API_TOKEN=""
declare -g SECRET_ENGINE_PROJECT_ID=""
declare -g SECRET_ENGINE_HOST=""
declare -g SECRET_ENGINE_ENV=""

# Authenticate with Infisical using universal auth
# Returns: 0 on success, 1 on failure
# Sets: SECRET_ENGINE_API_TOKEN, SECRET_ENGINE_PROJECT_ID, SECRET_ENGINE_HOST, SECRET_ENGINE_ENV
infisical_auth() {
  local host="${1:-}"
  local project_id="${2:-}"
  local project_slug="${3:-}"
  local client_id="${4:-}"
  local client_secret="${5:-}"
  local env="${6:-}"

  # Resolve Infisical host
  SECRET_ENGINE_HOST="${host:-${INFISICAL_HOST:-${K8_INFISICAL_HOST:-$(dc get secrets infisical.host 2>/dev/null || true)}}}"
  [[ -z "$SECRET_ENGINE_HOST" ]] && die "INFISICAL_HOST not set (env, dc secrets.infisical.host, or K8_INFISICAL_HOST)"
  SECRET_ENGINE_HOST="${SECRET_ENGINE_HOST%/api}"
  SECRET_ENGINE_HOST="${SECRET_ENGINE_HOST%/}"

  # Resolve environment
  SECRET_ENGINE_ENV="${env:-${INFISICAL_ENV:-$(dc get secrets infisical.env 2>/dev/null || echo prod)}}"

  # Resolve operator credentials
  local operator_client_id="${client_id:-${EKS_OPERATOR_CLIENT_ID:-${K8_INFISICAL_CLIENT_ID:-$(dc get secrets operator.client_id 2>/dev/null || true)}}}"
  local operator_client_secret="${client_secret:-${EKS_OPERATOR_CLIENT_SECRET:-${K8_INFISICAL_CLIENT_SECRET:-$(dc get secrets operator.client_secret 2>/dev/null || true)}}}"

  [[ -z "$operator_client_id" ]] && die "EKS_OPERATOR_CLIENT_ID not set"
  [[ -z "$operator_client_secret" ]] && die "EKS_OPERATOR_CLIENT_SECRET not set"

  # Cloudflare Access headers
  local cf_access_id="${CF_ACCESS_CLIENT_ID:-$(dc get cf access.client_id 2>/dev/null || true)}"
  local cf_access_secret="${CF_ACCESS_CLIENT_SECRET:-$(dc get cf access.client_secret 2>/dev/null || true)}"
  local cf_headers=()
  if [[ -n "$cf_access_id" && -n "$cf_access_secret" ]]; then
    cf_headers=(-H "CF-Access-Client-Id: ${cf_access_id}" -H "CF-Access-Client-Secret: ${cf_access_secret}")
  fi

  # Authenticate
  SECRET_ENGINE_API_TOKEN=$(curl -s "${cf_headers[@]+"${cf_headers[@]}"}" -X POST "${SECRET_ENGINE_HOST}/api/v1/auth/universal-auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"clientId\":\"${operator_client_id}\",\"clientSecret\":\"${operator_client_secret}\"}" \
    | jq -r '.accessToken // empty' 2>/dev/null || true)
  [[ -z "$SECRET_ENGINE_API_TOKEN" ]] && die "Infisical authentication failed"

  # Resolve project ID
  SECRET_ENGINE_PROJECT_ID="${project_id:-${INFISICAL_PROJECT_ID:-}}"
  if [[ -z "$SECRET_ENGINE_PROJECT_ID" && -n "${project_slug:-}" ]]; then
    SECRET_ENGINE_PROJECT_ID=$(curl -s "${cf_headers[@]+"${cf_headers[@]}"}" -X GET "${SECRET_ENGINE_HOST}/api/v1/projects/slug/${project_slug}" \
      -H "Authorization: Bearer ${SECRET_ENGINE_API_TOKEN}" \
      -H "Content-Type: application/json" | jq -r '.id // .project.id // empty' 2>/dev/null || true)
  fi
  [[ -z "$SECRET_ENGINE_PROJECT_ID" ]] && die "Could not resolve project ID (set INFISICAL_PROJECT_ID or INFISICAL_PROJECT_SLUG)"

  return 0
}

# Get a secret value from Infisical
# Args: path, key
# Returns: secret value to stdout
infisical_get_secret() {
  local path="$1" key="$2"

  [[ -z "$SECRET_ENGINE_API_TOKEN" ]] && die "Not authenticated. Call infisical_auth first"
  [[ -z "$SECRET_ENGINE_PROJECT_ID" ]] && die "Project ID not set"

  local cf_access_id="${CF_ACCESS_CLIENT_ID:-$(dc get cf access.client_id 2>/dev/null || true)}"
  local cf_access_secret="${CF_ACCESS_CLIENT_SECRET:-$(dc get cf access.client_secret 2>/dev/null || true)}"
  local cf_headers=()
  if [[ -n "$cf_access_id" && -n "$cf_access_secret" ]]; then
    cf_headers=(-H "CF-Access-Client-Id: ${cf_access_id}" -H "CF-Access-Client-Secret: ${cf_access_secret}")
  fi

  curl -s "${cf_headers[@]+"${cf_headers[@]}"}" -X GET \
    "${SECRET_ENGINE_HOST}/api/v3/secrets/raw/${key}?workspaceId=${SECRET_ENGINE_PROJECT_ID}&environment=${SECRET_ENGINE_ENV}&secretPath=${path}" \
    -H "Authorization: Bearer ${SECRET_ENGINE_API_TOKEN}" \
    | jq -r '.secret.secretValue // empty' 2>/dev/null
}

# Set a secret value in Infisical
# Args: path, key, value, dry_run (optional, default: false)
# Returns: 0 on success, 1 on failure
# Output: Status messages
infisical_set_secret() {
  local path="$1" key="$2" value="$3" dry_run="${4:-false}"

  [[ -z "$SECRET_ENGINE_API_TOKEN" ]] && die "Not authenticated. Call infisical_auth first"
  [[ -z "$SECRET_ENGINE_PROJECT_ID" ]] && die "Project ID not set"

  local cf_access_id="${CF_ACCESS_CLIENT_ID:-$(dc get cf access.client_id 2>/dev/null || true)}"
  local cf_access_secret="${CF_ACCESS_CLIENT_SECRET:-$(dc get cf access.client_secret 2>/dev/null || true)}"
  local cf_headers=()
  if [[ -n "$cf_access_id" && -n "$cf_access_secret" ]]; then
    cf_headers=(-H "CF-Access-Client-Id: ${cf_access_id}" -H "CF-Access-Client-Secret: ${cf_access_secret}")
  fi

  local current http_code
  current=$(infisical_get_secret "$path" "$key")
  local json_value
  json_value=$(printf '%s' "$value" | jq -Rs .)

  if $dry_run; then
    if [[ -z "$current" ]]; then
      echo "  🆕  ${path}/${key}"
    elif [[ "$current" == "$value" ]]; then
      echo "  ▪️   ${path}/${key} (unchanged)"
    else
      echo "  ✏️   ${path}/${key} (modified)"
    fi
    return 0
  fi

  if [[ -z "$current" ]]; then
    # Create new secret
    http_code=$(curl -s "${cf_headers[@]+"${cf_headers[@]}"}" -o /dev/null -w "%{http_code}" -X POST "${SECRET_ENGINE_HOST}/api/v3/secrets/raw/${key}" \
      -H "Authorization: Bearer ${SECRET_ENGINE_API_TOKEN}" -H "Content-Type: application/json" \
      -d "{\"workspaceId\":\"${SECRET_ENGINE_PROJECT_ID}\",\"environment\":\"${SECRET_ENGINE_ENV}\",\"secretPath\":\"${path}\",\"secretValue\":${json_value},\"type\":\"shared\"}")
    [[ "$http_code" == "200" || "$http_code" == "201" ]] && { echo "  🆕  ${path}/${key}"; return 0; }
    echo "  ❌  ${path}/${key} (HTTP ${http_code})" >&2; return 1
  elif [[ "$current" == "$value" ]]; then
    echo "  ▪️   ${path}/${key} (unchanged)"
    return 0
  else
    # Update existing secret
    http_code=$(curl -s "${cf_headers[@]+"${cf_headers[@]}"}" -o /dev/null -w "%{http_code}" -X PATCH "${SECRET_ENGINE_HOST}/api/v3/secrets/raw/${key}" \
      -H "Authorization: Bearer ${SECRET_ENGINE_API_TOKEN}" -H "Content-Type: application/json" \
      -d "{\"workspaceId\":\"${SECRET_ENGINE_PROJECT_ID}\",\"environment\":\"${SECRET_ENGINE_ENV}\",\"secretPath\":\"${path}\",\"secretValue\":${json_value},\"type\":\"shared\"}")
    [[ "$http_code" == "200" ]] && { echo "  ✏️   ${path}/${key}"; return 0; }
    echo "  ❌  ${path}/${key} (HTTP ${http_code})" >&2; return 1
  fi
}

# List all secrets in an Infisical path
# Args: path
# Returns: JSON array of {key, value_preview, length} objects
infisical_list_secrets() {
  local path="$1"

  [[ -z "$SECRET_ENGINE_API_TOKEN" ]] && die "Not authenticated. Call infisical_auth first"
  [[ -z "$SECRET_ENGINE_PROJECT_ID" ]] && die "Project ID not set"

  local cf_access_id="${CF_ACCESS_CLIENT_ID:-$(dc get cf access.client_id 2>/dev/null || true)}"
  local cf_access_secret="${CF_ACCESS_CLIENT_SECRET:-$(dc get cf access.client_secret 2>/dev/null || true)}"
  local cf_headers=()
  if [[ -n "$cf_access_id" && -n "$cf_access_secret" ]]; then
    cf_headers=(-H "CF-Access-Client-Id: ${cf_access_id}" -H "CF-Access-Client-Secret: ${cf_access_secret}")
  fi

  curl -s "${cf_headers[@]+"${cf_headers[@]}"}" \
    -X GET "${SECRET_ENGINE_HOST}/api/v3/secrets/raw?workspaceId=${SECRET_ENGINE_PROJECT_ID}&environment=${SECRET_ENGINE_ENV}&secretPath=${path}&recursive=false" \
    -H "Authorization: Bearer ${SECRET_ENGINE_API_TOKEN}" \
    | jq -r '.secrets // []'
}

# -- Secrets YAML Parser -----------------------------------------------------

# Find the secrets YAML config file
# Order: argument → INFISICAL_SECRETS_FILE env → walk up for default names
# Returns: path to config file, or empty if not found
secrets_find_config() {
  local arg="${1:-}"
  if [[ -n "$arg" ]]; then
    [[ -f "$arg" ]] && echo "$arg" && return 0
    return 1
  fi
  if [[ -n "${INFISICAL_SECRETS_FILE:-}" ]]; then
    [[ -f "$INFISICAL_SECRETS_FILE" ]] && echo "$INFISICAL_SECRETS_FILE" && return 0
    return 1
  fi

  local dir="$PWD"
  local candidate
  while [[ "$dir" != "/" ]]; do
    for candidate in \
      "$dir/.infisical-secrets.yaml" \
      "$dir/.infra-config.yaml" \
      "$dir/infisical-secrets.yaml" \
      "$dir/secrets.yaml"; do
      [[ -f "$candidate" ]] && echo "$candidate" && return 0
    done
    dir="$(dirname "$dir")"
  done
  return 1
}

# Get secret definition from config by secret name
# Args: config_file, secret_name
# Returns: JSON object with {scope, key, section, path} or empty if not found
# The scope is extracted from the dc field (e.g., "dc: secrets smtp.host" → scope=secrets)
secrets_get_by_name() {
  local config="$1" secret_name="$2"

  [[ ! -f "$config" ]] && return 1

  local config_version="legacy"
  yq -e '.apiVersion == "secrets-tools/v1"' "$config" &>/dev/null && config_version="v1"

  if [[ "$config_version" == "v1" ]]; then
    # v1 format: sections with secrets map
    yq -o=json "$config" | jq -r --arg name "$secret_name" '
      .sections[]?
      | select(.secrets[$name])
      | {
          name: $name,
          section: .id,
          path: .path,
          scope: (.secrets[$name].dc // "" | split(" ")[0]),
          item_path: (.secrets[$name].dc // "" | if contains(" ") then (split(" ")[1:]) | join(" ") else empty end),
          definition: (.secrets[$name] | tojson)
        }
    ' 2>/dev/null
  else
    # Legacy format: need to walk through mappings
    yq -o=json "$config" | jq -r --arg name "$secret_name" '
      # Find mappings where $name is used
      .mappings // {} | to_entries[]?
      | select(.value | (type == "!!str" and . == $name)
                          or (type == "array" and (.[0] | tostring | startswith("?")) and (.[1:]? | .[] | tostring == $name)))
      | {
          name: $name,
          folder: .key,
          scope: "infra",  # Legacy format has no explicit scope
          item_path: "",
          definition: (.value | tojson)
        }
    ' 2>/dev/null
  fi
}

# List all secret names from config
# Args: config_file, section_filter (optional)
# Returns: newline-separated list of secret names
secrets_list_names() {
  local config="$1" section_filter="${2:-}"

  [[ ! -f "$config" ]] && return 1

  local config_version="legacy"
  yq -e '.apiVersion == "secrets-tools/v1"' "$config" &>/dev/null && config_version="v1"

  if [[ "$config_version" == "v1" ]]; then
    if [[ -n "$section_filter" ]]; then
      yq -r ".sections[]? | select(.id == \"$section_filter\") | .secrets | keys | .[]" "$config" 2>/dev/null
    else
      yq -r '.sections[]? | .secrets | keys | .[]' "$config" 2>/dev/null
    fi
  else
    yq -r '.mappings // {} | .[] | keys[]' "$config" 2>/dev/null
  fi
}

# Get sections/groups from config
# Args: config_file
# Returns: JSON with {sections: [], groups: {}}
secrets_get_structure() {
  local config="$1"

  [[ ! -f "$config" ]] && return 1

  local config_version="legacy"
  yq -e '.apiVersion == "secrets-tools/v1"' "$config" &>/dev/null && config_version="v1"

  if [[ "$config_version" == "v1" ]]; then
    yq -o=json "$config" | jq '{sections: [.sections[]? | {id: .id, title: .title, path: .path}], groups: (.groups // {})}'
  else
    yq -o=json "$config" | jq '{sections: (.folders[]? | {id: ., title: ., path: .}), groups: {}}'
  fi
}

# -- .envrc.dc Parser / Editor -----------------------------------------------

# Find .envrc.dc file in current directory or parent chain
# Returns: path to .envrc.dc file, or empty if not found
envrc_find_file() {
  local dir="${PWD}"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.envrc.dc" ]]; then
      echo "$dir/.envrc.dc"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

# Parse all dc get directives from .envrc.dc file
# Args: dc_file_path
# Returns: JSON array of {line_number, scope, item_path, line} objects
envrc_parse_get_lines() {
  local file="$1"

  [[ ! -f "$file" ]] && return 1

  local line_num=0
  local json_output="["
  local first=true

  while IFS= read -r line; do
    ((line_num++))

    # Match dc get SCOPE ITEM.PATTERN
    if [[ "$line" =~ ^[[:space:]]*dc[[:space:]]+get[[:space:]]+([^[:space:]]+)[[:space:]]+(.+)$ ]]; then
      local scope="${BASH_REMATCH[1]}"
      local item_path="${BASH_REMATCH[2]}"
      # Strip trailing comments
      item_path="${item_path%%#*}"
      item_path="${item_path//\"/}"
      item_path="${item_path//\'/}"
      item_path="${item_path%"${item_path##*[![:space:]]}"}"  # trim whitespace

      if $first; then first=false; else json_output+=","; fi
      json_output+="{\"line_number\":$line_num,\"scope\":\"$scope\",\"item_path\":\"$item_path\",\"line\":\"$line\"}"
    fi
  done < "$file"

  echo "$json_output]"
}

# Find dc get line by scope and item_path
# Args: dc_file_path, scope, item_path
# Returns: JSON object with line_number, scope, item_path, line, or null if not found
envrc_find_line() {
  local file="$1" scope="$2" item_path="$3"

  envrc_parse_get_lines "$file" | jq --arg scope "$scope" --arg path "$item_path" '
    .[] | select(.scope == $scope and .item_path == $path)
  '
}

# Edit a line in .envrc.dc file
# Args: dc_file_path, line_number, new_line, backup (optional, default: true)
# Returns: 0 on success, 1 on failure
# Creates backup with .bak extension if backup=true
envrc_edit_line() {
  local file="$1" line_num="$2" new_line="$3" backup="${4:-true}"

  [[ ! -f "$file" ]] && { log_error "File not found: $file"; return 1; }

  local line_count
  line_count=$(wc -l < "$file")
  if [[ "$line_num" -lt 1 ]] || [[ "$line_num" -gt "$line_count" ]]; then
    log_error "Invalid line number: $line_num (file has $line_count lines)"
    return 1
  fi

  # Create backup if requested
  if $backup; then
    cp "$file" "$file.bak"
  fi

  # Use sed to edit the line
  sed -i '' "${line_num}s/.*/${new_line}/" "$file"

  return 0
}

# -- Value Resolve Functions --------------------------------------------------

# Resolve a dc field to its actual value
# Args: dc_field (e.g., "secrets smtp.host" or "auto pg_password")
# Returns: resolved value to stdout
# Also accepts: --override VAR, --fallback PATH, --auto TYPE LENGTH, --default VALUE
secrets_resolve_dc_value() {
  local dc_field="$1"
  local override="" fallback="" auto_type="" auto_length="" default=""

  shift
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --override) override="$2"; shift 2 ;;
      --fallback) fallback="$2"; shift 2 ;;
      --auto) auto_type="$2"; shift; [[ $# -gt 0 && ! "$1" =~ ^- ]] && { auto_length="$1"; shift; } ;;
      --default) default="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  # Check override environment variable
  if [[ -n "$override" && -n "${!override:-}" ]]; then
    printf '%s' "${!override}"
    return 0
  fi

  # Parse dc field: first token is scope, rest is item path
  local scope item_path
  read -r scope item_path <<< "$dc_field"

  if [[ -n "$scope" && -n "$item_path" ]]; then
    # Try dc get
    local value
    value=$(dc get "$scope" "$item_path" 2>/dev/null || true)
    if [[ -n "$value" ]]; then
      printf '%s' "$value"
      return 0
    fi
  fi

  # Try fallback
  if [[ -n "$fallback" ]]; then
    read -r fb_scope fb_path <<< "$fallback"
    if [[ -n "$fb_scope" && -n "$fb_path" ]]; then
      local fb_value
      fb_value=$(dc get "$fb_scope" "$fb_path" 2>/dev/null || true)
      if [[ -n "$fb_value" ]]; then
        printf '%s' "$fb_value"
        return 0
      fi
    fi
  fi

  # Try auto-generation
  if [[ -n "$auto_type" ]]; then
    local len="${auto_length:-32}"
    case "$auto_type" in
      password) openssl rand -base64 "$((len * 2))" | tr -d '=+/' | cut -c1-"$len" ;;
      hex) openssl rand -hex "$len" ;;
      django) python3 -c "import secrets,string;print(''.join(secrets.choice(string.ascii_letters+string.digits+'!@#\$%^&*(-_=+)') for _ in range(50)))" 2>/dev/null || openssl rand -hex 32 ;;
      *) ;;
    esac
    return 0
  fi

  # Return default
  printf '%s' "$default"
}

# -- Verification Engine ------------------------------------------------------

# Verify a single secret across the chain
# Args: config_file, secret_name, env, show_values (optional, default: false)
# Returns: JSON with {name, yaml_value, dc_value, infisical_value, status, path}
# Status: ok | mismatch | missing_yaml | missing_dc | missing_infisical
verify_secret() {
  local config="$1" name="$2" env="${3:-prod}" show_values="${4:-false}"

  local secret_def
  secret_def=$(secrets_get_by_name "$config" "$name")
  [[ -z "$secret_def" ]] && { jq -nc --arg name "$name" '{name: $name, status: "missing_yaml"}'; return 0; }

  local scope item_path infisical_path
  scope=$(echo "$secret_def" | jq -r '.scope // empty')
  item_path=$(echo "$secret_def" | jq -r '.item_path // empty')
  infisical_path=$(echo "$secret_def" | jq -r '.path // empty')

  local yaml_value dc_value infisical_value status="ok"

  # Get dc value
  if [[ -n "$scope" && -n "$item_path" ]]; then
    dc_value=$(dc get "$scope" "$item_path" 2>/dev/null || true)
  fi
  [[ -z "$dc_value" ]] && status="missing_dc"

  # Get Infisical value
  if [[ -n "$name" && -n "$infisical_path" ]]; then
    infisical_value=$(infisical_get_secret "$infisical_path" "$name" 2>/dev/null || true)
  fi
  [[ -z "$infisical_value" ]] && status="missing_infisical"
  [[ "$status" == "missing_dc" && -z "$infisical_value" ]] && status="missing_all"

  # Compare values (if we have both)
  if [[ -n "$dc_value" && -n "$infisical_value" ]]; then
    if [[ "$dc_value" != "$infisical_value" ]]; then
      status="mismatch"
    fi
  fi

  # Build output
  local output
  output=$(jq -nc --arg name "$name" \
    --arg status "$status" \
    --arg yaml_value "$dc_value" \
    --arg yaml_value_display "$dc_value" \
    --arg dc_value "$dc_value" \
    --arg dc_value_display "$dc_value" \
    --arg infisical_value "$infisical_value" \
    --arg infisical_value_display "$infisical_value" \
    --arg scope "$scope" \
    --arg item_path "$item_path" \
    --arg infisical_path "$infisical_path" \
    '{
      name: $name,
      status: $status,
      yaml: {value: $yaml_value, display: $yaml_value_display},
      dc: {scope: $scope, path: $item_path, value: $dc_value, display: $dc_value_display},
      infisical: {path: $infisical_path, value: $infisical_value, display: $infisical_value_display}
    }')

  echo "$output"
}

# Verify all secrets in a section
# Args: config_file, section_id, env, show_values (optional)
# Returns: JSON array of verification results
verify_section() {
  local config="$1" section="$2" env="${3:-prod}" show_values="${4:-false}"

  local names
  names=$(secrets_list_names "$config" "$section")

  local output="["
  local first=true
  while IFS= read -r name; do
    [[ -z "$name" ]] && continue
    $first || output+=","
    first=false
    output+="$(verify_secret "$config" "$name" "$env" "$show_values")"
  done <<< "$names"

  echo "$output]"
}

# Verify all secrets in config
# Args: config_file, env, show_values (optional)
# Returns: JSON array of verification results
verify_all() {
  local config="$1" env="${2:-prod}" show_values="${3:-false}"

  local names
  names=$(secrets_list_names "$config")

  local output="["
  local first=true
  while IFS= read -r name; do
    [[ -z "$name" ]] && continue
    $first || output+=","
    first=false
    output+="$(verify_secret "$config" "$name" "$env" "$show_values")"
  done <<< "$names"

  echo "$output]"
}
