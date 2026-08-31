# PROJ-HOWTO.md — run-claude

Task-oriented guides for the things you'll actually do with `run-claude`. For *what it is*, see [PROJ-ARCH.md](PROJ-ARCH.md); for *where things live*, see [PROJ-LAYOUT.md](PROJ-LAYOUT.md).

## First Hour

### How to: install run-claude and get a directory routing through it

**Goal:** go from a fresh checkout to `claude` running through the LiteLLM proxy in one directory.
**Prereqs:** `uv` installed; `direnv` installed with its shell hook loaded.

1. Install dev deps and the CLI:
   ```bash
   cd utilities/agent/run-claude
   make dev
   make install
   ```
2. Install the shell hook (auto-detects bash/zsh):
   ```bash
   ./hooks/install.sh
   ```
3. Restart your shell (or `source ~/.bashrc` / `source ~/.zshrc`), making sure `direnv hook` loads **before** the run-claude hook line it appended.
4. Configure a project directory with a profile:
   ```bash
   cd /path/to/my/project
   run-claude set-folder anthropic
   direnv allow
   ```
5. Confirm the proxy is up (it auto-starts on first `enter`):
   ```bash
   run-claude proxy status
   ```

**Verify:** `run-claude status` shows the active token/profile for the directory, and `env | grep ANTHROPIC_BASE_URL` points at `http://localhost:4443` (or `:4444` if you bypassed the front proxy).
**Gotchas:**
- If `direnv hook` isn't loaded first, `AGENT_SHIM_TOKEN` changes go undetected and nothing routes. Check hook order in your rc file.
- First run also creates `~/.config/run-claude/.secrets` — see [howto/manage-secrets.md](howto/manage-secrets.md) before you need real API keys.
- `make install` silently no-ops if `uv` isn't on PATH; it prints a warning instead of failing the whole command.

### How to: configure a project directory for a specific provider

**Goal:** make one directory always route through a chosen profile (e.g. Cerebras, Groq, native Anthropic) when you `cd` into it.
**Prereqs:** run-claude installed (see above); a profile name from `run-claude profiles list`.

1. From inside the target directory:
   ```bash
   run-claude set-folder <profile>
   direnv allow
   ```
   This writes `.envrc` (gitignored, only if missing) and `.envrc.user` (gitignored, always rewritten) with `AGENT_SHIM_PROFILE=<profile>`.
2. Leave and re-enter the directory (or just `direnv reload`) to trigger the hook.

**Verify:** `run-claude status` shows the directory's token registered with the chosen profile's models.
**Gotchas:**
- `run-claude set-folder` only writes `.envrc` if one doesn't already exist — if you already have a custom `.envrc`, add `source_env_if_exists .envrc.user` and the `eval "$(run-claude env "$AGENT_SHIM_PROFILE")"` block yourself.
- Profile must exist first — check spelling with `run-claude profiles list`.

## Recurring Workflow

### How to: check what's running and pick a provider on the fly

**Goal:** see proxy/model state, and run one-off commands against a provider without touching directory config.
**Prereqs:** run-claude installed.

1. Check overall state:
   ```bash
   run-claude status              # token/profile/proxy summary
   run-claude proxy status        # is the LiteLLM proxy up
   run-claude models enabled      # models currently live in the proxy
   ```
2. Run a single command against a specific profile without `set-folder`:
   ```bash
   with-agent-shim cerebras -- claude
   with-agent-shim groq -- python inference.py
   ```
3. Or launch Claude directly through run-claude's own profile flag:
   ```bash
   run-claude with cerebras -- claude
   ```

**Verify:** the launched process's `ANTHROPIC_BASE_URL`/model env vars match the chosen profile (`run-claude env <profile>` prints what would be set).
**Gotchas:** `with-agent-shim`/`run-claude with` register models for the lifetime of that one command and don't persist a directory profile — use `set-folder` if you want it to stick.

### How to: use the `-x` / `-xx` shortcuts to grab every provider at once

**Goal:** skip picking a profile when you just want the broadest model lineup available.
**Prereqs:** `claude-enhanced` and `kitchen-sink` profiles present (built-in, see `profiles.yaml`).

1. Enhanced (curated multi-provider set):
   ```bash
   run-claude --enhanced          # shorthand for: run-claude with claude-enhanced
   ```
2. Kitchen sink (every configured provider, including DeepSeek/OpenAI/Grok):
   ```bash
   run-claude --kitchen-sink      # shorthand for: run-claude with kitchen-sink
   ```

**Verify:** `run-claude models enabled` lists the full provider set after either command starts.
**Gotchas:** kitchen-sink registers the most models, which means the longest first-registration delay and the most API keys needed in your secrets file — missing keys degrade to per-model failures, not a hard stop.

### How to: see which models are available and what they're good/bad at

**Goal:** decide which profile or model to use for a task based on real strengths/weaknesses, not just names.
**Prereqs:** proxy running (`run-claude proxy status`).

```bash
run-claude models avail            # descriptions + strengths/weaknesses
run-claude models avail --short    # compact one-line-per-model
run-claude models avail --json     # machine-readable
run-claude models show <name>      # full LiteLLM config for one model
```

**Verify:** output lists model names matching what `run-claude models enabled` reports as live.
**Gotchas:** `avail` describes *enabled* models — a model defined in `models.yaml` but never registered (no profile has pulled it in yet) won't show until something enters a directory that needs it.

## Non-Obvious Capabilities

### How to: manage API keys and database secrets
→ *See [howto/manage-secrets.md](howto/manage-secrets.md)*
Set up `~/.config/run-claude/.secrets` once and export it for both CLI use and the Docker Compose TimescaleDB stack.

### How to: keep the proxy pair alive across crashes
→ *See [howto/watchdog-and-proxy-lifecycle.md](howto/watchdog-and-proxy-lifecycle.md)*
Run the self-healing watchdog so the front proxy (:4443) and LiteLLM proxy (:4444) auto-restart, without undoing a deliberate `proxy stop`.

### How to: override or add your own models and profiles
→ *See [howto/customize-models-and-profiles.md](howto/customize-models-and-profiles.md)*
Layer user config on top of built-ins without editing the package, including disabling a built-in model entirely.

### How to: keep my Claude subscription billing while trying other providers
→ *See [howto/use-claude-plan-passthrough.md](howto/use-claude-plan-passthrough.md)*
Use the `claude-plan` profile so Claude-model calls forward with your own OAuth token (subscription billing) while other providers in the same profile still bill as API usage.

## Sharp Edges

### How to: get out of a stuck/half-registered directory state
→ *See [howto/troubleshoot-stuck-state.md](howto/troubleshoot-stuck-state.md)*
Diagnose refcount/lease weirdness, force a model refresh, or wipe the proxy's model table when things get inconsistent.

### How to: fix proxy logging so it doesn't break your CLI
**Goal:** understand why `run-claude proxy status` (or any command) might warn instead of crash when logging can't write, and where the log actually lands.
**Prereqs:** none — this is default behavior as of the m4 milestone.

Proxy logs prefer the XDG state dir (`~/.local/state/run-claude/proxy.log`), falling back to `/var/log` only if that's writable. A logging setup failure can no longer prevent CLI commands from running.

**Verify:** `run-claude proxy status` still returns output even if `~/.local/state/run-claude/` is briefly unwritable (e.g. full disk) — it degrades, it doesn't crash.
**Gotchas:**
- Sensitive keys (API tokens, credentials in URLs) are redacted in proxy logs automatically via `SENSITIVE_LOG_KEYS` — don't expect to find raw secrets there for debugging, that's intentional.
- For deep httpx/httpcore wire-level debugging, set `RUN_CLAUDE_HTTPX_LOG_FILE=/path/to/file` before starting the proxy; it has its own safe-fallback path logic separate from the main proxy log.
