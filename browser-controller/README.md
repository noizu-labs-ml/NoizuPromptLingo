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
| `Browser.Screenshot` | `screenshot` | `full_page?`, `selector?` | `{ format, encoding, image (base64 png), url }` |
| `Browser.Click`      | `click`      | `selector` | `{ clicked, url }` |
| `Browser.Fill`       | `fill`       | `selector`, `value` | `{ filled, url }` |
| `Browser.GetState`   | `state`      | `include_text?` | `{ url, title, text? }` |

Bad commands never crash the controller — they reply with
`{ ok: false, error }` and the cloud tool returns that error string.

## Limitations / follow-ups

- **One browser tab per controller.** All actions run against a single page.
- **One controller per org (v1).** If two controllers join the same org topic,
  the most recent registration receives commands.
- **Screenshot size.** Full-page PNGs of large pages can be multi-MB once
  base64-encoded; prefer a `selector` or viewport capture when possible.
- The controller runs headless by default; pass `--headed` to watch it work.
