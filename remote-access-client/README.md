# @noizu/remote-access-client

A thin [frpc](https://github.com/fatedier/frp) wrapper for NoizuPromptLingo. It
claims a **named, authenticated, revocable** tunnel from the cloud, then runs
frpc so a local port is exposed at `https://<name>.remote-access.noizu.com`
through the cloud frps server.

```
┌──────────────┐  POST /tunnels (MCP JWT)  ┌──────────────────────┐
│ NPL cloud    │ ◀──────────────────────── │ remote-access-client │
│ (tobor.locker)│ ──────────────────────▶  │   (this package)     │
└──────────────┘   201 { tunnel_token }    └──────────┬───────────┘
                                                       │ frpc (TLS, control :7000)
                                                       ▼
        https://<name>.remote-access.noizu.com  ──▶  frps  ──▶  127.0.0.1:<port>
```

The name claim and `tunnel_token` come from NPL (the single audit/issue/revoke
point); frpc only forwards traffic. The cloud frps server validates the
`tunnel_token` and that the requested subdomain belongs to its owner.

## Requirements

- Node.js >= 22
- A NoizuPromptLingo **MCP API key** for the organization you want to tunnel under.
- `frpc` — vendored automatically on install (see below), or bring your own.

## Install & build

```bash
cd remote-access-client
npm install        # also downloads the pinned frpc binary into bin/
npm run build
```

The `postinstall` step (`scripts/fetch-frpc.mjs`) downloads frp `0.61.0` for your
OS/arch from the official GitHub releases and extracts `frpc` into `bin/`. It is
**best-effort**: if the download fails (offline, blocked, unsupported arch) the
install still succeeds and prints instructions. In that case install frp
yourself and either put `frpc` on your `PATH` or set `FRPC_BIN=/path/to/frpc`.
The download is skipped when `FRPC_BIN` is set or `bin/frpc` already exists.

## Authentication

The client authenticates to the cloud with an **MCP JWT** — the same short-lived
token the MCP gateway and browser-controller accept. Mint one from your raw MCP
API key:

```bash
curl -s -X POST https://tobor.locker/api/mcp/token \
  -H 'content-type: application/json' \
  -d '{"key":"<your-raw-mcp-api-key>"}'
# => {"token":"<mcp-jwt>","expires_at":"..."}
```

NPL verifies this JWT (signature, issuer `tobor-locker`, expiry, active API key)
and requires the caller to be an **editor** of the organization. JWTs are valid
for 30 days; re-mint and restart the client when it expires.

## Flow

1. **Claim the name** — `POST ${api}/api/v1/remote-access/tunnels` with header
   `Authorization: Bearer <mcp-jwt>` and JSON body
   `{ "name": "<subdomain>", "port": <local-port>, "organization": "<org-id>" }`.
   On `201` the response is `{ name, tunnel_token, url, expires_at }`.
   `401` (bad/expired JWT), `403` (not an org editor), and `409` (name taken)
   are reported with clear messages.
2. **Render `frpc.toml`** into a temp dir:
   ```toml
   serverAddr = "tunnel.noizu.com"
   serverPort = 7000
   transport.tls.enable = true
   metadatas.token = "<tunnel_token>"

   [[proxies]]
   name = "<name>"
   type = "http"
   localIP = "127.0.0.1"
   localPort = <port>
   subdomain = "<name>"
   ```
3. **Launch frpc** (`frpc -c <frpc.toml>`), piping its output to stderr. On
   `SIGINT`/`SIGTERM` the child is signalled and the temp dir is cleaned up.
4. On success it prints
   `→ https://<name>.remote-access.noizu.com ready (local 127.0.0.1:<port>)`.

## Run

```bash
# via CLI flags
node dist/index.js \
  --name starlight-robot \
  --port 3000 \
  --token <mcp-jwt> \
  --org <organization-id>

# or via environment variables
export REMOTE_ACCESS_NAME=starlight-robot
export REMOTE_ACCESS_PORT=3000
export REMOTE_ACCESS_TOKEN=<mcp-jwt>
export REMOTE_ACCESS_ORG=<organization-id>
npm start
```

For iterative development without a build step:

```bash
npm run dev -- --name starlight-robot --port 3000 --token <mcp-jwt> --org <org-id>
```

Or use the env-driven installer (mints nothing — bring your token):

```bash
export REMOTE_ACCESS_NAME=starlight-robot
export REMOTE_ACCESS_PORT=3000
export REMOTE_ACCESS_TOKEN=<mcp-jwt>
export REMOTE_ACCESS_ORG=<organization-id>
bash install.sh
```

## Configuration

| Flag | Env var | Default | Description |
|------|---------|---------|-------------|
| `--name`        | `REMOTE_ACCESS_NAME`        | _(required)_ | Subdomain to claim |
| `--port`        | `REMOTE_ACCESS_PORT`        | _(required)_ | Local port to expose |
| `--token`       | `REMOTE_ACCESS_TOKEN`       | _(required)_ | MCP JWT |
| `--org`         | `REMOTE_ACCESS_ORG`         | _(required)_ | Organization id (UUID) |
| `--api`         | `REMOTE_ACCESS_API`         | `https://tobor.locker` | NPL API base |
| `--server`      | `REMOTE_ACCESS_SERVER`      | `tunnel.noizu.com` | frps control host |
| `--server-port` | `REMOTE_ACCESS_SERVER_PORT` | `7000` | frps control port |
| `--local-ip`    | `REMOTE_ACCESS_LOCAL_IP`    | `127.0.0.1` | Local bind address |
| _(n/a)_         | `FRPC_BIN`                  | vendored `bin/frpc` → `frpc` on PATH | Path to an frpc binary |

## Run as a server-side pod

For unattended tunnels (CI, scheduled jobs, the headless-browser pod reaching a
local endpoint) the client can run as a container, driven entirely by env vars:

```bash
cd remote-access-client
docker build -t noizu/remote-access-client .

docker run --rm --network host \
  -e REMOTE_ACCESS_NAME=starlight-robot \
  -e REMOTE_ACCESS_PORT=3000 \
  -e REMOTE_ACCESS_TOKEN=<mcp-jwt> \
  -e REMOTE_ACCESS_ORG=<organization-id> \
  noizu/remote-access-client
```

`--network host` (or an appropriate `localIP`) lets frpc reach the local service.

## Limitations / follow-ups

- **HTTP proxies only (v1).** TCP services need `type = "tcp"` and an in-cluster
  frps TCP Service; not wired up here yet.
- **One proxy per process.** Run multiple instances for multiple names.
- The vendored frpc is pinned to frp `0.61.0`; bump `FRP_VERSION` in
  `scripts/fetch-frpc.mjs` to change it.
