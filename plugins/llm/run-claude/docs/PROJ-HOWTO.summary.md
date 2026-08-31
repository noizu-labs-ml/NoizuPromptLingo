# PROJ-HOWTO Summary — run-claude

Task list only, no steps. Full guides: [PROJ-HOWTO.md](PROJ-HOWTO.md).

## First Hour
- **Install run-claude and get a directory routing through it** — go from a fresh checkout to `claude` running through the LiteLLM proxy in one directory.
- **Configure a project directory for a specific provider** — make one directory always route through a chosen profile when you `cd` into it.

## Recurring Workflow
- **Check what's running and pick a provider on the fly** — see proxy/model state, and run one-off commands against a provider without touching directory config.
- **Use the `-x` / `-xx` shortcuts to grab every provider at once** — skip picking a profile when you just want the broadest model lineup available.
- **See which models are available and what they're good/bad at** — decide which profile or model to use for a task based on real strengths/weaknesses.

## Non-Obvious Capabilities
- **Manage API keys and database secrets** — set up `~/.config/run-claude/.secrets` once and export it for both CLI use and the Docker Compose TimescaleDB stack. → [howto/manage-secrets.md](howto/manage-secrets.md)
- **Keep the proxy pair alive across crashes** — run the self-healing watchdog so the front proxy (:4443) and LiteLLM proxy (:4444) auto-restart without undoing a deliberate `proxy stop`. → [howto/watchdog-and-proxy-lifecycle.md](howto/watchdog-and-proxy-lifecycle.md)
- **Override or add your own models and profiles** — layer user config on top of built-ins without editing the package, including disabling a built-in model. → [howto/customize-models-and-profiles.md](howto/customize-models-and-profiles.md)
- **Keep my Claude subscription billing while trying other providers** — use the `claude-plan` profile so Claude-model calls pass through with your own OAuth token instead of billing as API usage. → [howto/use-claude-plan-passthrough.md](howto/use-claude-plan-passthrough.md)

## Sharp Edges
- **Get out of a stuck/half-registered directory state** — diagnose refcount/lease weirdness, force a model refresh, or wipe the proxy's model table. → [howto/troubleshoot-stuck-state.md](howto/troubleshoot-stuck-state.md)
- **Fix proxy logging so it doesn't break your CLI** — understand the XDG-first log path fallback and why logging failures can no longer crash CLI commands.
