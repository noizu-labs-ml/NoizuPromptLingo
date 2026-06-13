## auto-sudo — Architecture Summary

- **What**: Zsh function shims that auto-elevate commands via sudo when the user lacks write permission.
- **Pattern**: Shell function wraps a command, checks `-w` on target files/dirs, calls `sudo` if needed, otherwise passes through.
- **Current shims**: `vim.zsh`
- **Extensible**: Same pattern applies to any command that edits files.
