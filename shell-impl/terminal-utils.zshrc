# terminal-utils.zshrc — LEGACY COMPATIBILITY SHIM
#
# This file is preserved for backward compatibility.
# Prefer adding this to your .zshrc instead:
#   eval "$(path/to/tabbing-on/bin/tabbing-init zsh)"
#
# Or directly:
#   source path/to/tabbing-on/shell/tabbing.zsh
#
# Env vars (per-tab, exported):
#   TAB_TITLE         — tab title text
#   TAB_STATUS        — tab status text
#   TAB_HIGHLIGHT     — color name for title highlight
#   TAB_URGENCY       — 0-5 (0=critical/red, 5=nominal/green)
#   TAB_EMOJI         — named emoji (overrides urgency dot)
#   TAB_COLOR_SUPPORT — "true" to include unicode indicators
#   TAB_TERMINAL      — detected terminal emulator
#   TAB_ID            — unique tab fingerprint

source "${0:A:h}/shell/tabbing.zsh"
