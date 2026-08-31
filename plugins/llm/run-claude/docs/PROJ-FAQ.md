# PROJ-FAQ.md — run-claude

Anticipated why/when/compared-to-what questions. For *how to*, see [PROJ-HOWTO.md](PROJ-HOWTO.md); for *what it is*, see [PROJ-ARCH.md](PROJ-ARCH.md).

## Motivation

### Why would I route through a local LiteLLM proxy instead of just setting `ANTHROPIC_BASE_URL` myself?

Because the proxy adds model registration, refcounting, and credential handling you'd otherwise hand-roll per shell session. Setting `ANTHROPIC_BASE_URL` alone gets you to *a* backend, but you'd still need to keep an always-on process healthy, track which models are currently live so requests don't 404, and swap auth per-provider. run-claude's front proxy (`:4443`) does the auth swap and stays stable across LiteLLM restarts; the LiteLLM proxy (`:4444`) does the actual provider routing and request logging. The honest trade-off: two extra local processes and a bit of first-registration latency versus one exported variable.

→ *See [PROJ-ARCH.md](PROJ-ARCH.md#front-proxy--passthrough-mode) for the two-proxy rationale.*

### Why does switching providers require directory `enter`/`leave` instead of just exporting env vars in `.envrc`?

Because the target isn't just env vars — it's live model *registration* in a shared, long-running proxy. A plain `.envrc` export can point `ANTHROPIC_BASE_URL` wherever you like, but it can't register a model with the LiteLLM proxy, track how many directories are using it, or safely tear it down when the last user leaves. `enter`/`leave` exist to keep the shared proxy's model table in sync with which directories are actually active, via refcounts.

→ *See [PROJ-HOWTO.md](PROJ-HOWTO.md#how-to-configure-a-project-directory-for-a-specific-provider) to configure a directory.*

### Why two proxies (front + LiteLLM) instead of pointing straight at LiteLLM?

Because the front proxy is what buys OAuth passthrough for Claude subscription billing. Pointing directly at `:4444` works and is simpler, but every request goes through LiteLLM's master key — meaning Anthropic calls get billed as API usage even if you have a Claude Pro/Max subscription. The front proxy's passthrough mode forwards Anthropic-model requests to `api.anthropic.com` with your original OAuth token instead, while non-Anthropic requests still swap to the LiteLLM master key.

→ *See [PROJ-ARCH.md](PROJ-ARCH.md#front-proxy--passthrough-mode).*

## Fit

### When should I skip run-claude and just use native `claude` with Anthropic auth directly?

When you only ever use Claude models and never need to switch providers per-directory. If Anthropic-only is your whole workflow, the `anthropic` profile through run-claude adds proxy hops for no multi-provider benefit — going direct is simpler and has one less moving part to keep alive. run-claude earns its keep the moment a second provider (Cerebras, Groq, DeepSeek, local Ollama, etc.) enters the picture.

### When would I point `ANTHROPIC_BASE_URL` straight at the LiteLLM proxy (`:4444`) instead of the front proxy (`:4443`)?

Rarely, and mostly for debugging — the front proxy is what you want in every normal setup. `set-folder`/`with`/`with-agent-shim` all point at `:4443` by default; going straight to `:4444` skips the auth-swap and passthrough layer entirely, which means Claude-model requests always bill as LiteLLM API usage even under a `claude-plan`-style profile. The one legitimate reason to do it deliberately is isolating whether a problem is in the front proxy or in LiteLLM itself while troubleshooting.

→ *See [PROJ-ARCH.md](PROJ-ARCH.md#front-proxy--passthrough-mode) and [howto/use-claude-plan-passthrough.md](howto/use-claude-plan-passthrough.md).*

### When is `--kitchen-sink` the wrong choice?

When you don't have API keys for most of the providers it registers, or when you're on a slow/first-touch proxy start. Kitchen-sink pulls in every configured provider, which is the longest registration delay and the largest surface of "missing key → per-model failure" noise. `--enhanced` (a curated subset) or a single named profile is the better default; reach for kitchen-sink only when you deliberately want the broadest lineup visible to `models avail`.

→ *See [PROJ-HOWTO.md](PROJ-HOWTO.md#how-to-use-the--x---xx-shortcuts-to-grab-every-provider-at-once).*

## Comparison

### How does `set-folder` differ from `with-agent-shim` / `run-claude with`?

`set-folder` is persistent (writes `.envrc`/`.envrc.user`, sticks every time you `cd` in); `with-agent-shim`/`run-claude with` are one-shot (register a profile for the lifetime of a single command, nothing persisted). Use `set-folder` for a project you always want on a given provider; use `with`/`with-agent-shim` to try a provider once without touching directory config.

→ *See [PROJ-HOWTO.md](PROJ-HOWTO.md#how-to-check-whats-running-and-pick-a-provider-on-the-fly).*

### How does passthrough mode differ from standard mode in terms of billing?

Standard mode bills everything as LiteLLM/provider API usage; passthrough mode (the `claude-plan`-style profile) bills Anthropic-model calls against your Claude subscription plan instead, by forwarding with your original OAuth token rather than the LiteLLM master key. Non-Anthropic models in the same session still go through the LiteLLM master key regardless of mode — passthrough only changes the Anthropic path.

### How is this different from just using `direnv` alone for provider switching?

`direnv` is the trigger, not the mechanism — run-claude is what direnv calls. Bare `direnv` can toggle env vars per directory, but it has no concept of a shared proxy's model table, no refcounting across directories, and no watchdog to keep a backend alive. run-claude layers directory-awareness (via the same `direnv`-detected token change) on top of a stateful proxy system that plain `.envrc` exports can't provide.

## Capability

### Can I keep my Claude subscription billing while also using other providers in the same session?

Yes, via the passthrough-mode profile — Anthropic-model calls forward with your OAuth token (subscription billing), while non-Anthropic models in the same session route through the LiteLLM proxy with API-key billing. This is the one surprising "yes": most proxy-based multi-provider setups force everything onto API-key billing, but the front proxy specifically special-cases the Anthropic path to avoid that.

### Does it survive proxy crashes automatically?

Yes, as long as the watchdog is running (it's auto-spawned by `proxy start` and the shell-hook `enter` path) — it polls both proxies every ~5s and restarts whichever is down. The one case it deliberately does *not* auto-recover: a `run-claude proxy stop` you ran on purpose, which writes a `stop.marker` sentinel the watchdog respects.

→ *See [howto/watchdog-and-proxy-lifecycle.md](howto/watchdog-and-proxy-lifecycle.md).*

### Can two directories on different profiles run against the proxy at the same time?

Yes — models are refcounted, not directory-exclusive, so directory A on `cerebras` and directory B on `groq` can both have their models live in the same LiteLLM proxy simultaneously. Each `enter` increments the refcount for the models its profile needs; each `leave` decrements it; a model only gets a teardown lease once its refcount hits zero.

### Does `run-claude models avail` show every model I have defined, or just the ones currently in use?

Just the ones currently registered ("enabled") in the running LiteLLM proxy — a model sitting in `models.yaml` that no active profile has pulled in yet won't appear. This trips people up right after adding a custom model: it exists in config but stays invisible to `avail`/`show` until some directory `enter`s a profile that references it (or you register it via a one-off `with`).

→ *See [PROJ-HOWTO.md](PROJ-HOWTO.md#how-to-see-which-models-are-available-and-what-theyre-goodbad-at) and [howto/customize-models-and-profiles.md](howto/customize-models-and-profiles.md).*

## Caveats

### What happens if `direnv hook` isn't loaded before the run-claude shell hook line?

Nothing routes, silently — `AGENT_SHIM_TOKEN` changes go undetected, so `enter`/`leave` never fire and your shell keeps whatever env it already had. This is the most common "why isn't this working" report and it's a hook-ordering bug, not a run-claude bug: check that `direnv hook` appears before the appended run-claude line in your rc file.

→ *See [PROJ-HOWTO.md](PROJ-HOWTO.md#how-to-install-run-claude-and-get-a-directory-routing-through-it).*

### Does the proxy log my prompts or my API keys?

It logs request metadata to TimescaleDB and errors to the proxy log, but API keys and other sensitive values are redacted before anything is written. `SENSITIVE_LOG_KEYS` matching plus URL-credential scrubbing strip secrets from the proxy log path specifically (added in the m4 milestone) — so don't expect raw credentials there for debugging, that's intentional, not a bug. Prompt/response *content* logging is a LiteLLM/TimescaleDB behavior, not something run-claude adds redaction for beyond the credential scrubbing described here — treat the TimescaleDB store as containing real request data.

### Is there a latency or resource cost to the two-proxy chain?

Yes, a small one on every request (one extra local hop) plus a first-registration delay the first time a directory needs a model not yet live in LiteLLM. Subsequent requests to an already-registered model are just the proxy hop, not a re-registration. Kitchen-sink profiles have the worst first-touch delay since they register the most models at once.

### Why does `make install` warn and skip instead of failing when `uv` isn't on PATH?

Because a missing `uv` is treated as an environment gap for the caller to fix, not a build break to fail loudly on — `make install`/`make refresh` print `run-claude: uv not found; skipping install.` and exit success rather than a non-zero code. The trade-off: a CI script or wrapper `make` chain that doesn't itself check for the binary can silently move on believing install succeeded. If you need a hard failure on missing `uv`, check for it yourself before calling `make install` rather than relying on its exit code.

### Why does `set-folder` write two files (`.envrc` and `.envrc.user`) instead of one?

So your customizations survive re-runs. `.envrc` is only created if missing and holds just the boilerplate `source_env_if_exists .envrc.user` plus the `run-claude env` eval — it's meant to be committed or left alone. `.envrc.user` is unconditionally rewritten on every `set-folder` call and gitignored, so it's safe for run-claude to regenerate it (e.g. when you switch profiles) without clobbering any hand-edits you made to `.envrc` itself. If you'd rather have one file, hand-maintain `.envrc` and skip `set-folder` for that directory.

→ *See [PROJ-HOWTO.md](PROJ-HOWTO.md#how-to-configure-a-project-directory-for-a-specific-provider).*

### Why isn't run-claude installed by `make install-utilities` like other Noizu utilities?

Because it isn't a shell utility — it's a self-contained Python package (hatchling + uv) with its own lockfile, venv, and console scripts (`run-claude`, `run-open-code`, `run-litellm-proxy`). It deliberately doesn't source `share/k8-lib` or ship an `.infra-config.yaml` build target; it's installed via its own `make dev && make install` (`uv tool install .`). Don't expect it to show up in the shared utilities install flow — that's by design, not an oversight.

→ *See [PROJ-ARCH.md](PROJ-ARCH.md#ecosystem-fit-noizu-monorepo).*

## Trust

### Where are my API keys stored, and how are they protected?

In `~/.config/run-claude/.secrets` (YAML), created with `0600` permissions and excluded from version control. It's the single source both the CLI and the Docker Compose TimescaleDB stack read from — `run-claude secrets export` generates the `.env` Docker needs without you hand-copying keys. Nothing here is encrypted at rest beyond filesystem permissions; treat that file like any other plaintext credentials file on disk.

→ *See [howto/manage-secrets.md](howto/manage-secrets.md).*

### What lands in TimescaleDB, and can I inspect or purge it?

Request-level metadata and logs from the LiteLLM proxy — model, timing, and outcome data used for the request-logging features, stored in the TimescaleDB container on port `5433`. It's your own local Docker Compose stack, not a remote service, so you can inspect or truncate it directly with any Postgres client; run-claude doesn't currently ship a built-in purge command for it.
