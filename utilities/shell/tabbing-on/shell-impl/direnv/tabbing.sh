# direnv stdlib helper for tabbing-on
#
# Source: ~/.config/direnv/lib/tabbing.sh
# Install: tabbing-on ships this file; `make install` copies it.
#
# Usage in .envrc:
#   use_tabbing "project-name"
#   use_tabbing "project-name" "status" --emoji rocket --color blue --urgency 2
#
# When tabbing-on is active (TABBING_DC_UUID is set), use_tabbing is a
# no-op — the session file is the source of truth and the precmd hook
# handles restoration. This prevents direnv from clobbering manually-set
# tab state on directory changes.
#
# For dc-based tab defaults (e.g. theme from dc tab config), use
# use_tabbing_dc after dc_export. It reads directly from the dc store
# and only sets values not already present.

use_tabbing() {
  # If tabbing-on is active, skip — precmd hook owns state restoration
  if [ -n "${TABBING_DC_UUID:-}" ]; then
    return 0
  fi

  local title="" status="" emoji="" urgency="" highlight=""

  # Parse positional args first, then flags
  while [ $# -gt 0 ]; do
    case "$1" in
      --emoji|-e)     emoji="$2"; shift 2 ;;
      --emoji=*)      emoji="${1#--emoji=}"; shift ;;
      --color|-h)     highlight="$2"; shift 2 ;;
      --color=*)      highlight="${1#--color=}"; shift ;;
      --highlight)    highlight="$2"; shift 2 ;;
      --highlight=*)  highlight="${1#--highlight=}"; shift ;;
      --urgency|-p)   urgency="$2"; shift 2 ;;
      --urgency=*)    urgency="${1#--urgency=}"; shift ;;
      --pri=*)        urgency="${1#--pri=}"; shift ;;
      -*)
        local maybe="${1#-}"
        if [ -z "$emoji" ]; then
          emoji="$maybe"
        else
          highlight="$maybe"
        fi
        shift
        ;;
      *)
        if [ -z "$title" ]; then
          title="$1"
        elif [ -z "$status" ]; then
          status="$1"
        fi
        shift
        ;;
    esac
  done

  # Export ALL five vars unconditionally so direnv snapshots every one.
  # An empty export still gets captured by direnv's env diff and restored on cd-out.
  export TAB_TITLE="$title"
  export TAB_STATUS="$status"
  export TAB_EMOJI="$emoji"
  export TAB_URGENCY="$urgency"
  export TAB_HIGHLIGHT="$highlight"
}

# ---------------------------------------------------------------------------
# use_tabbing_dc — Apply tab defaults from dc store (merge, don't override)
#
# Reads tab.* keys from the dc store and exports them as TAB_* env vars,
# but ONLY when tabbing-on is not active. When tabbing-on IS active,
# this is a complete no-op — the session file is authoritative.
#
# Usage in .envrc (AFTER dc_export):
#   use_tabbing_dc
#
# This replaces the dc flatten rule `tab.*: TAB_*` which clobbers
# manually-set state. Remove `tab` from _dc.export and the flatten
# rule, then call this function instead.
# ---------------------------------------------------------------------------
use_tabbing_dc() {
  # If tabbing-on is active, skip entirely — precmd hook owns state
  if [ -n "${TABBING_DC_UUID:-}" ]; then
    return 0
  fi

  command -v dc >/dev/null 2>&1 || return 0

  local _val
  _val="$(dc get tab title --raw 2>/dev/null)" && [ -n "$_val" ] && export TAB_TITLE="$_val"
  _val="$(dc get tab status --raw 2>/dev/null)" && [ -n "$_val" ] && export TAB_STATUS="$_val"
  _val="$(dc get tab theme --raw 2>/dev/null)" && [ -n "$_val" ] && export TAB_THEME="$_val"
  _val="$(dc get tab highlight --raw 2>/dev/null)" && [ -n "$_val" ] && export TAB_HIGHLIGHT="$_val"
  _val="$(dc get tab emoji --raw 2>/dev/null)" && [ -n "$_val" ] && export TAB_EMOJI="$_val"
  _val="$(dc get tab urgency --raw 2>/dev/null)" && [ -n "$_val" ] && export TAB_URGENCY="$_val"
}
