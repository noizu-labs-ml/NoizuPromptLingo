# run-claude

**Per-directory model routing for Claude Code & OpenCode, backed by a self-healing local LLM gateway.**

`cd` into a project, get the right models. `run-claude` hot-registers whichever provider models a
directory declares (via direnv + a shell hook) on a running gateway, routes all traffic through a
front proxy that swaps auth per provider — including **Anthropic OAuth passthrough, so your Claude
Pro/Max subscription gets used instead of API billing** — and keeps itself alive with a watchdog
daemon. Claude Code and OpenCode just work. 145+ cataloged models across ~25 profiles are one
`set-folder` away.

```
 your directories                 run-claude                       providers
┌──────────────────┐   direnv +   ┌──────────────────────────┐
│ ~/work/project-a │──shell hook──▶      front proxy :4443    │──auth-swapped──▶ Anthropic (OAuth)
│ profile: groq    │              │  auth swap · logging ·   │                 Cerebras
├──────────────────┤              │  model bootstrap         │                 Groq · Z.AI
│ ~/work/project-b │              └────────────┬─────────────┘                 Wafer · OpenAI
│ profile: claude- │                           ▼                                  ...
│ plan             │                    gateway :4444
└──────────────────┘              (go-litellm / ex-litellm)
```

**Highlights**

- **Directory-scoped routing** — `run-claude set-folder groq` + `direnv allow`; from then on,
  entering the directory registers its models on the live gateway. Refcounted with a 15-minute
  lease and cleaned by a janitor, so shared models don't thrash.
- **Claude-plan OAuth passthrough** — the front proxy forwards Anthropic requests with your
  original OAuth token (subscription billing) while other providers swap to the gateway master
  key. JSONL request logging and persisted auth state included.
- **Self-healing** — a detached watchdog daemon auto-restarts crashed proxies (~5s poll) and
  respects intentional stops via a `stop.marker` sentinel.
- **Pluggable gateway** — default `go-litellm`: one static CGO-free Go binary serving the front
  proxy and LiteLLM on one port. Optional Elixir/OTP `ex-litellm` or legacy Python LiteLLM.
- **Two agents, one shim** — fronts both Claude Code and OpenCode (`run-open-code`), plus a
  multi-turn `chat` model tester, `run-claude with <profile>` one-shots, and bash/zsh completions.

<details>
<summary>Table of contents</summary>

- [Quick start](#quick-start)
- [Example session](#example-session)
- [One-shot runs: the `with` family](#one-shot-runs-the-with-family)
- [The catalog: profiles & models](#the-catalog-profiles--models)
- [How it works](#how-it-works)
- [Reliability: watchdog & lifecycle](#reliability-watchdog--lifecycle)
- [Gateways](#gateways)
- [Command reference](#command-reference)
- [Claude Code & OpenCode](#claude-code--opencode)
- [Configuration, paths & secrets](#configuration-paths--secrets)
- [Why not just…?](#why-not-just)
- [Documentation](#documentation)

</details>

## Quick start

```bash
git clone <this repo> && cd run-claude
make install                      # CLI + go-litellm gateway + shell completions
run-claude secrets init --generate   # provider API keys + auto-generated DB password

cd /path/to/my/project
run-claude set-folder cerebras    # writes .envrc; prints your stable dir token
direnv allow                      # activate

claude                            # models registered on entry; just works
run-claude status --health        # verify: proxies, DB, refcounts as JSON
```

Provider keys live in `~/.config/run-claude/.secrets` — see [SECRETS_QUICKSTART.md](SECRETS_QUICKSTART.md).
Never commit that file.

## Example session

```console
$ cd ~/work/api-server            # profile: zai-pro
$ run-claude status --health
{"front_proxy": "healthy", "litellm": "healthy", "db": "running", ...}

$ run-claude models avail --short # what's live in the gateway right now
zai/opus  zai/sonnet  zai/haiku  zai/opus[1m]  ...

$ run-claude chat zai/sonnet      # kick the tires without launching Claude
You: reply with OK
Model: OK
You: /exit

$ claude                          # real session, routed through the gateway
```

## One-shot runs: the `with` family

Don't want to pin a whole directory? Run a single command under a profile:

```bash
run-claude with groq                    # = groq profile + claude
run-claude with groq -- python infer.py # any command
run-claude -x                           # --enhanced → with claude-enhanced
run-claude -xx                          # --kitchen-sink → with kitchen-sink (every provider)
```

`with` accepts `--refresh` to force re-registration. The older `with-agent-shim` wrapper still
works but is legacy.

## The catalog: profiles & models

~26 built-in profiles over 145+ model definitions (`run-claude profiles list`,
`run-claude models list`). Highlights by group:

| Group | Profiles | Notes |
|---|---|---|
| Fast inference | `cerebras`, `cerebras2`, `cerebras-pro`, `groq`, `groq2`, `groq-mix`, `groq-pro`, `fast-glm` | `-pro` variants use provider subscriptions |
| Subscription passthrough | `claude-plan`, `zai-pro`, `zai-oa`, `wafer`, `alibaba` | Claude Pro/Max OAuth, Z.AI subs, Wafer PAYG, Alibaba Qwen Token Plan |
| Mega-profiles | `all-sub`, `claude-enhanced` (`-x`), `kitchen-sink` (`-xx`) | Everything you have keys for |
| Majors | `anthropic`, `openai`, `azure`, `gemini`, `grok`, `deepseek`, `mistral`, `perplexity` | |
| Local / blended | `local` (Ollama/vLLM/LM Studio), `multi` (best-of-breed) | |

- `run-claude models avail` — live gateway models with **descriptions, strengths, and weaknesses**,
  grouped by provider (`--json` / `--short` for scripts).
- `[1m]` suffix aliases — Claude Code ≥ v2.1.116 requests 1M-context variants with a `[1m]`
  suffix; run-claude pre-registers those aliases (27 of them) so they route instead of 404.
- Profiles map opus/sonnet/haiku/fable tiers onto models, so tier-aware agents get sane defaults:

```yaml
meta:
  name: "My Profile"
  opus_model: "zai/opus"
  sonnet_model: "zai/sonnet"
  haiku_model: "cerebras-pro/haiku"
  fable_model: "alibaba/fable"
```

Customizing: [docs/howto/customize-models-and-profiles.md](docs/howto/customize-models-and-profiles.md).

## How it works

1. **Shell hook** fires on every prompt; detects the `AGENT_SHIM_TOKEN` direnv sets per directory
   (stable SHA256 hash of the path).
2. **`run-claude enter <token> <profile>`** registers the directory's models with the running
   gateway and bumps refcounts. `leave` decrements.
3. **Janitor** expires models at refcount 0 after a 15-minute lease (anti-thrash).
4. **Env vars** route the agent at the front proxy:

   ```bash
   ANTHROPIC_BASE_URL=http://127.0.0.1:4443
   API_TIMEOUT_MS=3000000
   ANTHROPIC_DEFAULT_OPUS_MODEL=<profile opus>       # set when the profile defines the tier
   ANTHROPIC_DEFAULT_SONNET_MODEL=<profile sonnet>
   ANTHROPIC_DEFAULT_HAIKU_MODEL=<profile haiku>
   ANTHROPIC_DEFAULT_FABLE_MODEL=<profile fable>     # fable_model, else opus
   ```

   No auth token is exported — the front proxy does the per-provider auth swap.
5. **Front proxy** (`:4443`) swaps auth: Anthropic requests keep your OAuth token (subscription
   billing, `claude-plan`), everything else gets the gateway master key. It also serves
   `/api/claude_cli/bootstrap` so the Claude CLI sees live models, and writes JSONL request logs.
6. **Gateway** (`:4444`) does the actual provider routing.

Deeper detail, with diagrams: [docs/PROJ-ARCH.md](docs/PROJ-ARCH.md).

## Reliability: watchdog & lifecycle

```bash
run-claude proxy start            # front proxy + gateway; clears stop marker, starts watchdog
run-claude proxy stop [--all]     # --all also removes the DB container + volumes
run-claude proxy status           # names the live gateway implementation (go-litellm, ex-litellm, …)
run-claude watchdog start         # detached daemon; auto-restarts crashed proxies (~5s poll)
run-claude watchdog stop          # respects stop.marker — intentional stops stick
run-claude db start               # TimescaleDB container (host port 5433)
```

`proxy supervise` still exists but is deprecated — use `watchdog start`. Full lifecycle notes:
[docs/howto/watchdog-and-proxy-lifecycle.md](docs/howto/watchdog-and-proxy-lifecycle.md);
stuck-state recovery: [docs/howto/troubleshoot-stuck-state.md](docs/howto/troubleshoot-stuck-state.md).

## Gateways

| Gateway | What it is | When |
|---|---|---|
| `go-litellm` *(default)* | Single static CGO-free Go binary; front proxy + LiteLLM on one port, no Postgres/Prisma | Default install (`make install`) |
| `ex-litellm` | Elixir/OTP; SQLite-backed, runtime-alterable routing, status page with login/session auth | `FRONT_PROXY_COMMAND=ex-litellm` at proxy start |
| Python LiteLLM | Legacy two-process front proxy + LiteLLM | `FRONT_PROXY_COMMAND=python` at proxy start |

`FRONT_PROXY_COMMAND` selects the front-proxy implementation when the proxy starts (runtime env
var, not an install option). `run-claude proxy status` tells you which implementation is live.
go-litellm internals: [repos/go-litellm/INTEGRATION.md](repos/go-litellm/INTEGRATION.md).

## Command reference

One line each — `run-claude <cmd> --help` for the rest.

| Area | Commands |
|---|---|
| Directory | `set-folder <profile>`, `enter <token> <profile>`, `leave <token>`, `janitor` |
| Status / env | `status [--health]`, `env <profile> [--export]` |
| Proxy | `proxy start\|stop\|restart\|status\|health\|db-test` |
| Watchdog | `watchdog start\|stop\|restart\|status` |
| Database | `db start\|stop\|status\|migrate` (TimescaleDB :5433) |
| Profiles | `profiles list\|show <name>\|install` |
| Models | `models list`, `models enabled [--names-only]`, `models show <name>`, `models avail [--json\|--short]`, `models wipe [--force]` |
| Keys | `keys list`, `keys add <name> [--env VAR]`, `keys switch zai tyna`, `keys delete <name>` |
| Chat | `chat [model] [--system S] [--prompt P] [--timeout N]` |
| One-shot | `with <profile> [cmd…] [--refresh]`; global `-x` / `-xx` shorthands |
| Secrets | `secrets init [--generate]`, `secrets path`, `secrets export` |
| Install | `install [--force]` (templates + docker-compose infra) |
| Global | `--version`, `--debug`, `--enhanced/-x`, `--kitchen-sink/-xx` |

Shell completions: `make install-completions` (bash + zsh).

## Claude Code & OpenCode

The same machinery fronts both agents:

- **Claude Code** — `run-claude` exports `ANTHROPIC_BASE_URL` + tier defaults (above).
- **OpenCode** — the sibling `run-open-code` CLI (same subcommands, minus `watchdog`/`chat`/
  `models enabled`/`models avail`; `with` defaults to launching `opencode`) exports
  `OPENAI_BASE_URL` + `OPENAI_API_KEY` pointed at the same front proxy.

## Configuration, paths & secrets

| Type | Path |
|---|---|
| Config, secrets, user profiles | `~/.config/run-claude/` |
| State, pid files, logs, generated gateway config | `~/.local/state/run-claude/` |
| Built-in models / profiles | `run_claude/models.yaml`, root `profiles.yaml` |
| User overrides | `~/.config/run-claude/models.yaml`, `~/.config/run-claude/profiles/` |

User definitions with the same name override built-ins; `model: null` in an override disables an
entry and falls through. Secrets (`--generate` auto-creates a DB password):
[SECRETS.md](SECRETS.md) · [SECRETS_ADVANCED.md](SECRETS_ADVANCED.md) ·
[docs/howto/manage-secrets.md](docs/howto/manage-secrets.md).

## Why not just…?

> **…export `ANTHROPIC_BASE_URL` myself?**
> That gets you to *a* backend — but you'd still hand-roll an always-on process, track which
> models are live so requests don't 404, and swap auth per provider. run-claude's front proxy does
> the auth swap and survives gateway restarts. The honest trade-off: two extra local processes
> and a little first-registration latency versus one exported variable.

| | plain LiteLLM | run-claude |
|---|---|---|
| Auth per provider / OAuth passthrough | manual | front proxy handles it |
| Per-directory hot model registration | restart w/ new config | refcounted, on `cd` |
| Keeps itself alive | — | watchdog daemon |
| Agent sees live models | — | `/api/claude_cli/bootstrap` |

More: [docs/PROJ-FAQ.md](docs/PROJ-FAQ.md).

## Documentation

- [docs/PROJ-HOWTO.md](docs/PROJ-HOWTO.md) — first-hour walkthrough
- [docs/PROJ-FAQ.md](docs/PROJ-FAQ.md) — why/when/comparisons
- [docs/howto/](docs/howto/) — customize profiles · manage secrets · Claude-plan passthrough ·
  watchdog lifecycle · stuck-state recovery
- [SECRETS.md](SECRETS.md) / [SECRETS_QUICKSTART.md](SECRETS_QUICKSTART.md) — secrets in depth
- [CHANGELOG.md](CHANGELOG.md) — milestones & release notes
