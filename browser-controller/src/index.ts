#!/usr/bin/env node
/**
 * Local browser controller entry point.
 *
 * Connects to the NoizuPromptLingo cloud UserSocket with an MCP JWT, joins
 * `browser:<org_id>`, launches a Playwright chromium browser, and serves
 * `command` messages pushed by the cloud Browser.* MCP tools — replying with a
 * `command_result` keyed by the command's request_id.
 */

import { createInterface } from "node:readline/promises";
import { Socket } from "phoenix";
import WebSocket from "ws";
import { loadConfig, type Config } from "./config.js";
import { BrowserDriver } from "./browser.js";

interface IncomingCommand {
  request_id: string;
  action: string;
  params?: unknown;
}

/**
 * When a token + org weren't supplied via flags/env, prompt for an MCP API key
 * (copy/paste from the web UI) and exchange it for a short-lived JWT + the
 * caller's org id via <api>/api/mcp/browser-bootstrap.
 */
async function ensureCredentials(config: Config): Promise<Config> {
  if (config.token && config.orgId) return config;

  const rl = createInterface({ input: process.stdin, output: process.stderr });
  let key: string;
  try {
    key = (await rl.question("Paste your Noizu MCP API key: ")).trim();
  } finally {
    rl.close();
  }
  if (!key) throw new Error("an MCP API key is required to connect");

  const endpoint = `${config.apiBase}/api/mcp/browser-bootstrap`;
  log(`exchanging API key at ${endpoint}`);
  const resp = await fetch(endpoint, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ key }),
  });
  if (!resp.ok) {
    const body = await resp.text().catch(() => "");
    throw new Error(`bootstrap failed (HTTP ${resp.status}): ${body || resp.statusText}`);
  }
  const data = (await resp.json()) as {
    token: string;
    org_id: string;
    url?: string;
  };
  if (!data.token || !data.org_id) {
    throw new Error("bootstrap response missing token or org_id");
  }
  return {
    ...config,
    token: data.token,
    orgId: data.org_id,
    url: data.url || config.url,
  };
}

async function main(): Promise<void> {
  const config = await ensureCredentials(loadConfig());
  const driver = new BrowserDriver(config.headless);

  log(`launching chromium (headless=${config.headless})`);
  await driver.start();

  // The phoenix client expects a browser-style WebSocket constructor; `ws`
  // provides a compatible one for Node.
  const socket = new Socket(config.url, {
    transport: WebSocket as unknown as new (url: string) => WebSocket,
    params: { mcp_token: config.token },
  });

  socket.onError((err) => log(`socket error: ${describe(err)}`));
  socket.onClose(() => log("socket closed"));
  socket.connect();

  const topic = `browser:${config.orgId}`;
  const channel = socket.channel(topic, {});

  channel.on("command", (payload: IncomingCommand) => {
    void handleCommand(channel, driver, payload);
  });

  channel
    .join()
    .receive("ok", () => log(`joined ${topic}; ready for commands`))
    .receive("error", (resp: unknown) =>
      log(`failed to join ${topic}: ${describe(resp)}`),
    )
    .receive("timeout", () => log(`join timed out for ${topic}`));

  const shutdown = async () => {
    log("shutting down");
    try {
      channel.leave();
      socket.disconnect();
    } finally {
      await driver.stop();
      process.exit(0);
    }
  };
  process.on("SIGINT", () => void shutdown());
  process.on("SIGTERM", () => void shutdown());
}

async function handleCommand(
  channel: ReturnType<Socket["channel"]>,
  driver: BrowserDriver,
  payload: IncomingCommand,
): Promise<void> {
  const { request_id, action, params } = payload ?? ({} as IncomingCommand);
  if (!request_id) {
    log("ignoring command without request_id");
    return;
  }

  log(`command ${action} (${request_id})`);
  const result = await driver.execute(action, params);
  channel.push("command_result", { request_id, ...result });
}

function log(message: string): void {
  // Controller logs go to stderr so stdout stays clean for any future piping.
  process.stderr.write(`[browser-controller] ${message}\n`);
}

function describe(value: unknown): string {
  if (value instanceof Error) return value.message;
  try {
    return JSON.stringify(value);
  } catch {
    return String(value);
  }
}

main().catch((err) => {
  process.stderr.write(`[browser-controller] fatal: ${describe(err)}\n`);
  process.exit(1);
});
