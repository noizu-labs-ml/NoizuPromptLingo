# @noizu/browser-controller

Local browser controller for NoizuPromptLingo. It connects to the cloud over a
Phoenix channel and drives a [Playwright](https://playwright.dev) chromium
browser on **your** machine, so cloud `Browser.*` MCP tools can navigate, click,
fill, screenshot, and read page state in a real browser you control.

```
┌──────────────┐   command (request_id)   ┌──────────────────┐   Playwright   ┌─────────┐
│ Cloud Browser│ ───────────────────────▶ │ browser-controller│ ─────────────▶ │ Chromium│
│  MCP tools   │ ◀─────────────────────── │   (this package)  │ ◀───────────── │         │
└──────────────┘   command_result         └──────────────────┘                └─────────┘
        ▲  blocks on Relay (≤30s)  via Phoenix channel  browser:<org_id>
```

## Requirements

- Node.js >= 22
- A NoizuPromptLingo **MCP API key** for the organization you want to control.

## Install & build

```bash
cd browser-controller
npm install        # also runs `playwright install chromium`
npm run build
```

## Authentication

The controller authenticates to the cloud socket with an **MCP JWT** — the same
short-lived token the MCP gateway accepts. Mint one from your raw MCP API key:

```bash
curl -s -X POST https://tobor.locker/api/mcp/token \
  -H 'content-type: application/json' \
  -d '{"key":"<your-raw-mcp-api-key>"}'
# => {"token":"<mcp-jwt>","expires_at":"..."}
```

The socket verifies this JWT (signature, issuer, expiry, active API key) and
takes the owning user from its `sub` claim. Joining `browser:<org_id>`
additionally requires that user to be an **editor** of the organization.

> JWTs are valid for 30 days; re-mint and restart the controller when it expires.

## Run

```bash
# via CLI flags
node dist/index.js \
  --url wss://tobor.locker/socket \
  --token <mcp-jwt> \
  --org <organization-id> \
  --headed                 # optional: show a visible browser window

# or via environment variables
export BROWSER_CONTROLLER_URL=wss://tobor.locker/socket
export BROWSER_CONTROLLER_TOKEN=<mcp-jwt>
export BROWSER_CONTROLLER_ORG=<organization-id>
npm start
```

For iterative development without a build step:

```bash
npm run dev -- --token <mcp-jwt> --org <organization-id>
```

Once it logs `joined browser:<org_id>; ready for commands`, the cloud
`Browser.Overview` tool will report `controller_connected: true` for that org,
and the other `Browser.*` tools will drive this browser.

## Configuration

| Flag | Env var | Default | Description |
|------|---------|---------|-------------|
| `--url`   | `BROWSER_CONTROLLER_URL`   | `wss://tobor.locker/socket` | Cloud Phoenix socket URL |
| `--token` | `BROWSER_CONTROLLER_TOKEN` | _(required)_ | MCP JWT |
| `--org`   | `BROWSER_CONTROLLER_ORG`   | _(required)_ | Organization id (UUID) |
| `--headed`| `BROWSER_CONTROLLER_HEADED`| `false` (headless) | Launch a visible browser |

## Supported actions

| Cloud tool | Action | Params | Result data |
|------------|--------|--------|-------------|
| `Browser.Navigate`   | `navigate`   | `url` | `{ url, title }` |
| `Browser.Screenshot` | `screenshot` | `full_page?`, `selector?`, `upload_url?`, `key?` | see below |
| `Browser.Click`      | `click`      | `selector` | `{ clicked, url }` |
| `Browser.Fill`       | `fill`       | `selector`, `value` | `{ filled, url }` |
| `Browser.GetState`   | `state`      | `include_text?` | `{ url, title, text? }` |
| `Browser.RecordStart`| `record_start` | _(none)_ | `{ recording: true }` |
| `Browser.RecordStop` | `record_stop`  | `upload_url`, `key`, `content_type?` | `{ key, uploaded: true }` |

Bad commands never crash the controller — they reply with
`{ ok: false, error }` and the cloud tool returns that error string.

### Screenshot upload protocol

`screenshot` has two modes:

- **Inline (no `upload_url`)** — replies with the PNG inline:
  `{ format: "png", encoding: "base64", image: "<base64>", width, height, url }`.
- **Presigned upload (`upload_url` + `key`)** — when the cloud mints a presigned
  S3/MinIO `PUT` URL, the controller captures the PNG (honoring `full_page` /
  `selector`), `PUT`s the raw bytes to `upload_url` with
  `content-type: image/png`, and replies
  `{ key, width, height, uploaded: true }`. The image bytes never travel back
  over the channel. On upload failure it replies `{ ok: false, error }`.

### Video recording protocol

Playwright records video per browser context, so recording is a start/stop pair:

- `record_start` — (re)creates the active page inside a context launched with
  `recordVideo`, re-navigating to the current url if one is open, and replies
  `{ recording: true }`. Navigate/click/fill/state continue to work against the
  recording page.
- `record_stop` (`{ upload_url, key, content_type }`, `content_type` typically
  `"video/webm"`) — closes the recording page/context so Playwright flushes the
  `.webm`, reads the produced file, `PUT`s its bytes to `upload_url` with the
  given content type, and replies `{ key, uploaded: true }`. A fresh
  non-recording page is created afterward so subsequent commands keep working,
  and the temp recording dir is removed. On failure it replies
  `{ ok: false, error }`.

## Run as a server-side pod

For unattended capture (CI, scheduled jobs, headless cloud workers) the
controller can run as a container/pod instead of on your laptop. The image is
built on the official Playwright base (matching chromium + OS deps preinstalled)
and is driven entirely by env vars. Screenshots and videos are streamed straight
to MinIO via the cloud-minted presigned `PUT` URLs, so the pod needs **no**
object-store credentials of its own.

```bash
cd browser-controller
docker build -t noizu/browser-controller .

docker run --rm \
  -e BROWSER_CONTROLLER_URL=wss://tobor.locker/socket \
  -e BROWSER_CONTROLLER_TOKEN=<mcp-jwt> \
  -e BROWSER_CONTROLLER_ORG=<organization-id> \
  noizu/browser-controller
```

It runs headless by default (`BROWSER_CONTROLLER_HEADED=false`); a headed
browser inside a container would need a virtual display, so leave it headless
for pod use. When the cloud sends a `screenshot` with an `upload_url` (or a
`record_stop`), the bytes go straight to object storage — the pod is stateless.

## Limitations / follow-ups

- **One browser tab per controller.** All actions run against a single page.
- **One controller per org (v1).** If two controllers join the same org topic,
  the most recent registration receives commands.
- **Screenshot size.** Full-page PNGs of large pages can be multi-MB once
  base64-encoded; prefer a `selector` or viewport capture when possible.
- The controller runs headless by default; pass `--headed` to watch it work.
