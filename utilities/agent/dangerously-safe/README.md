# agent-sandbox

A TUI + docker builder for running coding agents (claude / codex / opencode) in
**dangerous / auto-approve mode** safely — inside an isolated git worktree mounted
into a per-project docker container with controlled env, ports, and network.

Supersedes the legacy `bin/dangerously-safe` bash script (kept alongside).

## Usage

```
agent-sandbox                 # launch the interactive wizard
agent-sandbox build-image node,rust [--dry-run]
agent-sandbox list-images     # local sandbox images + their app sets
agent-sandbox doctor          # check docker/git/tools
agent-sandbox template list
agent-sandbox template save <name>
agent-sandbox preview         # run the TUI wizard with fixture data (no docker/git needed)
```

The wizard: reads `.agent-sandbox/config` (or bootstraps from a template/empty),
confirms the app set, lets you pick or create a worktree under
`.agent-sandbox/worktrees/`, resolves/builds the image, then drops you into an
interactive shell in the container with the agents on `PATH`.

## How images are named & reused

App slugs are normalized to a sorted set and baked into a lowercase tag
`agent-sandbox:<slug>-<slug>` plus an OCI label `org.agent-sandbox.apps`. On
launch the tool:

1. reuses an **exact** image if one exists;
2. else finds the closest existing image whose app set is a **subset** of the
   request, uses it as the base, and adds only the delta apps;
3. else builds from `snippets/base.dockerfile`.

Images are generated from the per-app fragment library in `snippets/apps/`
(front-matter: `requires`, `apt`; body: install steps). User overrides live in
`~/.config/agent-sandbox/snippets/`.

## Config: `.agent-sandbox/config` (YAML)

See `templates/default/config.yaml` for a starting point. Key fields: `apps`,
`agent` (default/available/run_cmd/dangerous), `env`, `ports`, `mounts`,
`internet_access`, `hooks` (before_launch host / on_docker_start in-container),
`tools` (copy_bins/copy_shares + PATH prepend), `worktree`.

## Install

```
make install   # binary -> ~/.local/bin, snippets -> ~/.local/share/agent-sandbox,
               # templates -> ~/.config/agent-sandbox
```

If your repo lives on a full/separate volume, set `CARGO_TARGET_DIR` to a volume
with space before building.

## Compose & outbound logging

When the config defines `compose.services`, a `compose.base_file`, or a
`compose.network`, launch uses docker-compose instead of `docker run`: a shared
external network (`agent-sandbox` by default) is created, an optional shared
infra base is brought up, and a per-worktree overlay is generated at
`{worktree}/.agent-sandbox/compose.overlay.yaml` (the interactive `agent`
service plus any outbound services). For an outbound service with
`mitmproxy: { enabled: true, mode: log, upstream, listen_port }`, a
`mitmproxy/mitmproxy` sidecar (`<name>-mitm`) reverse-proxies to the upstream and
dumps flows to `{worktree}/.agent-sandbox/mitm/<name>/` — point the agent's
client env at `<name>-mitm:<listen_port>` to capture its traffic.

## Branch-name inference

When `AGENT_SANDBOX_INFERENCE_API_KEY` (or `OPENAI_API_KEY`) is set, the new
worktree flow asks an OpenAI-compatible endpoint
(`AGENT_SANDBOX_INFERENCE_API_BASE`, model `AGENT_SANDBOX_INFERENCE_MODEL`) for a
3-5 word kebab branch slug from your description; you can edit the suggestion. It
always falls back to a deterministic slug and never blocks creation.

## Config layering

Parent `.agent-sandbox/config` files found by scanning upward are deep-merged as
shared defaults: `template <- parent(far→near) <- project` (mappings merge
recursively; scalars/sequences are replaced by the higher layer).

## Development

```bash
# Run tests
cargo test

# Generate HTML coverage report (installs cargo-tarpaulin on first run)
make coverage
open coverage/tarpaulin-report.html

# Manually exercise all TUI screens without docker or git
cargo run -- preview
```

**Test coverage** (as of last run): 83 tests, ~33% line coverage across 17 modules.
Fully covered: `config/schema`, `image/closest`, `image/dockerfile`, `image/slug`, `tui/fixtures`.
High coverage (>90%): `compose/overlay`, `docker/run`.
The uncovered ~67% is almost entirely subprocess-heavy orchestrators (`docker/`, `worktree/create`,
`launch/hooks`, `config/mod`, `tui/mod`) — unit-testing them requires mocking `std::process::Command`
or a live docker/git environment.

## Scope

**Implemented:** config read + parent-config layering, app-set image build/find
with closest-match layering, worktree list/create (worktree + rsync untracked +
restrict-access hook + best-effort chown), tool staging + PATH,
`before_launch`/`on_docker_start`/`init_worktree` hooks, env + mount + port
assembly, interactive `docker run` launch, docker-compose base + per-worktree
overlays, outbound `mitmproxy` log sidecars, inference-generated branch names,
and the TUI wizard.

**Designed in the schema, not yet wired:** `dc` (direnv-config) env layers
(`EnvValue::FromDc`), tabbing-on state pull, `post_container_start` hook,
`mitmproxy` intercept mode, and `docker-build` push/multiarch.

> Note: with `docker run`, `internet_access: false` attaches `--network none`
> (best-effort isolation). In compose mode the shared network is a normal bridge;
> true egress control (an `internal` network) is a later milestone.
