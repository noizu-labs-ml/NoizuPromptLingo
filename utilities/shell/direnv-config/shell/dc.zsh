# Zsh completions for dc (direnv-config)
# Source this or place in $fpath

_dc() {
  local -a commands
  commands=(
    'yaml:Merge YAML from stdin into a named config'
    'get:Read a config value by path'
    'set:Set a config value'
    'unset:Remove a key from a named config'
    'prune:Remove named configs or branches'
    'purge:Permanently delete a config or entire store'
    'env:Export resolved config as shell env vars'
    'bump:Bump the version counter'
    'init:Initialize a config store'
    'status:Show current config state'
    'list:List all known config stores'
  )

  _arguments -C \
    '--version[Show version]' \
    '--help[Show help]' \
    '1:command:->cmd' \
    '*::arg:->args'

  case $state in
    cmd)
      _describe 'command' commands
      ;;
    args)
      case $words[1] in
        yaml|get|set|unset|prune)
          _arguments '1:config name:' '*:args:'
          ;;
        purge)
          local -a configs
          configs=(${(f)"$(dc __complete-purge 2>/dev/null)"})
          _arguments '1:config name:(${configs})'
          ;;
      esac
      ;;
  esac
}

compdef _dc dc
