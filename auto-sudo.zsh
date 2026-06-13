# --- auto-sudo vim shim ---
# Automatically uses sudo when editing files you don't have write access to.
vim() {
  local need_sudo=false
  local files=()

  # Collect file arguments (skip flags: -x, +x)
  for arg in "$@"; do
    [[ "$arg" == -* || "$arg" == +* ]] && continue
    files+=("$arg")
  done

  # No file args → just open vim normally
  if (( ${#files[@]} == 0 )); then
    command vim "$@"
    return
  fi

  local prompt_sudo=false

  for f in "${files[@]}"; do
    if [[ -e "$f" ]]; then
      if [[ ! -w "$f" ]]; then
        if [[ "$(stat -f %u "$f")" == "$UID" ]]; then
          prompt_sudo=true
        else
          need_sudo=true
        fi
        break
      fi
    else
      local dir="${f:h}"  # zsh dirname
      [[ ! -w "$dir" ]] && need_sudo=true && break
    fi
  done

  if $prompt_sudo; then
    printf '\033[1;33m⚡ %s is owned by you but not writable.\033[0m\n' "${files[*]}"
    printf 'Use sudo? [y/N] '
    read -q && echo && sudo vim "$@" || { echo; command vim "$@"; }
  elif $need_sudo; then
    printf '\033[1;33m⚡ auto-sudo vim\033[0m %s\n' "${files[*]}"
    sudo vim "$@"
  else
    command vim "$@"
  fi
}

# --- auto-sudo chown/chgrp/chmod shims ---
# Automatically uses sudo when target files are not owned by the current user.
for _cmd in chown chgrp chmod; do
  eval "
  ${_cmd}() {
    local files=()
    for arg in \"\$@\"; do
      [[ \"\$arg\" == -* ]] && continue
      [[ -e \"\$arg\" ]] && files+=(\"\$arg\")
    done

    local need_sudo=false
    for f in \"\${files[@]}\"; do
      if [[ \"\$(stat -f %u \"\$f\")\" != \"\$UID\" ]]; then
        need_sudo=true
        break
      fi
    done

    if \$need_sudo; then
      printf '\033[1;33m⚡ auto-sudo ${_cmd}\033[0m %s\n' \"\${files[*]}\"
      sudo command ${_cmd} \"\$@\"
    else
      command ${_cmd} \"\$@\"
    fi
  }
  "
done
unset _cmd
