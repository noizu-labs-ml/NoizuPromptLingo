#!/usr/bin/env node
/**
 * Remote-access tunnel client entry point.
 *
 * Claims a named tunnel from the NoizuPromptLingo cloud with an MCP JWT, renders
 * an `frpc.toml`, and launches the bundled `frpc` so a local port is exposed at
 * `https://<name>.remote-access.noizu.com` through the cloud frps server.
 */

import { spawn } from "node:child_process";
import { mkdtemp, rm, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { loadConfig, type Config } from "./config.js";

const __dirname = dirname(fileURLToPath(import.meta.url));

interface ClaimResponse {
  name: string;
  tunnel_token: string;
  url: string;
  expires_at: string;
}

async function main(): Promise<void> {
  const config = loadConfig();

  log(`claiming tunnel "${config.name}" (local ${config.localIp}:${config.port})`);
  const claim = await claimTunnel(config);
  log(`claim ok; tunnel url ${claim.url} (expires ${claim.expires_at})`);

  const workDir = await mkdtemp(join(tmpdir(), "noizu-remote-access-"));
  const tomlPath = join(workDir, "frpc.toml");
  await writeFile(tomlPath, renderFrpcToml(config, claim.tunnel_token), "utf8");

  const frpcBin = resolveFrpcBin();
  log(`launching frpc (${frpcBin}) -c ${tomlPath}`);

  const child = spawn(frpcBin, ["-c", tomlPath], { stdio: ["ignore", "pipe", "pipe"] });

  child.stdout.on("data", (chunk: Buffer) => relay("frpc", chunk));
  child.stderr.on("data", (chunk: Buffer) => relay("frpc", chunk));

  const url = claim.url || `https://${config.name}.remote-access.noizu.com`;
  log(`→ ${url} ready (local ${config.localIp}:${config.port})`);

  let cleaned = false;
  const cleanup = async () => {
    if (cleaned) return;
    cleaned = true;
    await rm(workDir, { recursive: true, force: true }).catch(() => {});
  };

  const shutdown = (signal: NodeJS.Signals) => {
    log(`received ${signal}; stopping frpc`);
    child.kill(signal);
  };
  process.on("SIGINT", () => shutdown("SIGINT"));
  process.on("SIGTERM", () => shutdown("SIGTERM"));

  child.on("error", (err) => {
    log(`failed to launch frpc: ${describe(err)}`);
    void cleanup().then(() => process.exit(1));
  });

  child.on("exit", (code, signal) => {
    log(`frpc exited (code=${code ?? "null"}, signal=${signal ?? "null"})`);
    void cleanup().then(() => process.exit(code ?? 0));
  });
}

async function claimTunnel(config: Config): Promise<ClaimResponse> {
  const endpoint = `${config.api.replace(/\/$/, "")}/api/v1/remote-access/tunnels`;

  let res: Response;
  try {
    res = await fetch(endpoint, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        authorization: `Bearer ${config.token}`,
      },
      body: JSON.stringify({
        name: config.name,
        port: config.port,
        organization: config.orgId,
      }),
    });
  } catch (err) {
    throw new Error(`could not reach ${endpoint}: ${describe(err)}`);
  }

  if (res.status === 201) {
    const data = (await res.json()) as Partial<ClaimResponse>;
    if (!data.tunnel_token) {
      throw new Error("claim succeeded but no tunnel_token in response");
    }
    return {
      name: data.name ?? config.name,
      tunnel_token: data.tunnel_token,
      url: data.url ?? `https://${config.name}.remote-access.noizu.com`,
      expires_at: data.expires_at ?? "unknown",
    };
  }

  const body = await res.text().catch(() => "");
  switch (res.status) {
    case 401:
      throw new Error(
        `unauthorized (401): the MCP JWT is invalid or expired. Re-mint a token ` +
          `(POST ${config.api}/api/mcp/token) and retry.${suffix(body)}`,
      );
    case 403:
      throw new Error(
        `forbidden (403): you must be an editor of organization ${config.orgId} ` +
          `to claim a tunnel.${suffix(body)}`,
      );
    case 409:
      throw new Error(
        `name taken (409): "${config.name}" is already claimed by another owner. ` +
          `Pick a different --name.${suffix(body)}`,
      );
    default:
      throw new Error(
        `tunnel claim failed (${res.status} ${res.statusText}).${suffix(body)}`,
      );
  }
}

function renderFrpcToml(config: Config, tunnelToken: string): string {
  return [
    `serverAddr = "${config.server}"`,
    `serverPort = ${config.serverPort}`,
    `transport.tls.enable = true`,
    `metadatas.token = "${tunnelToken}"`,
    ``,
    `[[proxies]]`,
    `name = "${config.name}"`,
    `type = "http"`,
    `localIP = "${config.localIp}"`,
    `localPort = ${config.port}`,
    `subdomain = "${config.name}"`,
    ``,
  ].join("\n");
}

/**
 * Resolve the frpc binary: `FRPC_BIN` env override, then the vendored copy the
 * postinstall script downloads into `bin/`, then `frpc` on PATH.
 */
function resolveFrpcBin(): string {
  const fromEnv = process.env.FRPC_BIN;
  if (fromEnv) return fromEnv;

  const vendored = join(__dirname, "..", "bin", process.platform === "win32" ? "frpc.exe" : "frpc");
  if (existsSync(vendored)) return vendored;

  return "frpc";
}

function relay(tag: string, chunk: Buffer): void {
  const text = chunk.toString("utf8").replace(/\n$/, "");
  for (const line of text.split("\n")) {
    process.stderr.write(`[${tag}] ${line}\n`);
  }
}

function suffix(body: string): string {
  const trimmed = body.trim();
  return trimmed ? ` Server said: ${trimmed}` : "";
}

function log(message: string): void {
  // Client logs go to stderr so stdout stays clean for any future piping.
  process.stderr.write(`[remote-access] ${message}\n`);
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
  process.stderr.write(`[remote-access] fatal: ${describe(err)}\n`);
  process.exit(1);
});
