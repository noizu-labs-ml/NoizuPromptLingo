# direnv-stdlib extension for direnv-config
# Loaded automatically by direnv from ~/.config/direnv/lib/dc.sh
# Provides: dc_yaml, dc_get, dc_set, dc_unset, dc_prune, dc_bump, dc_export

dc_yaml() {
  local name="$1"; shift
  dc yaml "$name" "$@" < /dev/stdin
}

dc_get() {
  local name="$1"; shift
  dc get "$name" "$@"
}

dc_set() {
  local name="$1" key="$2" value="$3"; shift 3
  dc set "$name" "$key" "$value" "$@"
}

dc_unset() {
  local name="$1"; shift
  dc unset "$name" "$@"
}

dc_prune() {
  local name="$1"; shift
  dc prune "$name" "$@"
}

dc_bump() {
  dc bump
}

dc_export() {
  if [ $# -eq 0 ]; then
    eval "$(dc env)"
    return
  fi
  # dc_export NAME=config path [--default VAL] [--fallback ENV] [--override ENV] [--auto TYPE [LEN]]
  local assignment="$1"; shift
  local var_name="${assignment%%=*}"
  local config_name="${assignment#*=}"
  local result
  if result="$(dc get "$config_name" "$@")"; then
    export "$var_name=$result"
  fi
}
