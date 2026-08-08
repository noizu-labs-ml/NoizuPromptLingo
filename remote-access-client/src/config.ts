/**
 * Client configuration, resolved from CLI flags then environment variables.
 *
 *   --name / REMOTE_ACCESS_NAME       subdomain to claim (starlight-robot)
 *   --port / REMOTE_ACCESS_PORT       local port to expose (3000)
 *   --token / REMOTE_ACCESS_TOKEN     MCP JWT (minted from an MCP API key)
 *   --org / REMOTE_ACCESS_ORG         organization id (UUID)
 *   --api / REMOTE_ACCESS_API         NPL API base (https://tobor.locker)
 *   --server / REMOTE_ACCESS_SERVER   frps control host (tunnel.noizu.com)
 *   --server-port / REMOTE_ACCESS_SERVER_PORT  frps control port (7000)
 *   --local-ip / REMOTE_ACCESS_LOCAL_IP        local bind ip (127.0.0.1)
 */

export interface Config {
  name: string;
  port: number;
  token: string;
  orgId: string;
  api: string;
  server: string;
  serverPort: number;
  localIp: string;
}

function parseArgs(argv: string[]): Record<string, string | boolean> {
  const out: Record<string, string | boolean> = {};
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (!arg.startsWith("--")) continue;
    const key = arg.slice(2);
    const next = argv[i + 1];
    if (next === undefined || next.startsWith("--")) {
      out[key] = true;
    } else {
      out[key] = next;
      i++;
    }
  }
  return out;
}

export function loadConfig(argv: string[] = process.argv.slice(2)): Config {
  const args = parseArgs(argv);

  const name = (args.name as string) || process.env.REMOTE_ACCESS_NAME || "";
  const portRaw =
    (args.port as string) || process.env.REMOTE_ACCESS_PORT || "";
  const token = (args.token as string) || process.env.REMOTE_ACCESS_TOKEN || "";
  const orgId = (args.org as string) || process.env.REMOTE_ACCESS_ORG || "";

  const api =
    (args.api as string) ||
    process.env.REMOTE_ACCESS_API ||
    "https://tobor.locker";
  const server =
    (args.server as string) ||
    process.env.REMOTE_ACCESS_SERVER ||
    "tunnel.noizu.com";
  const serverPortRaw =
    (args["server-port"] as string) ||
    process.env.REMOTE_ACCESS_SERVER_PORT ||
    "7000";
  const localIp =
    (args["local-ip"] as string) ||
    process.env.REMOTE_ACCESS_LOCAL_IP ||
    "127.0.0.1";

  const missing: string[] = [];
  if (!name) missing.push("--name / REMOTE_ACCESS_NAME");
  if (!portRaw) missing.push("--port / REMOTE_ACCESS_PORT");
  if (!token) missing.push("--token / REMOTE_ACCESS_TOKEN");
  if (!orgId) missing.push("--org / REMOTE_ACCESS_ORG");
  if (missing.length > 0) {
    throw new Error(
      `Missing required configuration: ${missing.join(", ")}.\n` +
        `Usage: noizu-remote-access --name <subdomain> --port <local-port> ` +
        `--token <mcp-jwt> --org <org-id> ` +
        `[--api https://tobor.locker] [--server tunnel.noizu.com] ` +
        `[--server-port 7000] [--local-ip 127.0.0.1]`,
    );
  }

  const port = Number(portRaw);
  if (!Number.isInteger(port) || port <= 0 || port > 65535) {
    throw new Error(`Invalid --port / REMOTE_ACCESS_PORT: ${portRaw}`);
  }

  const serverPort = Number(serverPortRaw);
  if (!Number.isInteger(serverPort) || serverPort <= 0 || serverPort > 65535) {
    throw new Error(
      `Invalid --server-port / REMOTE_ACCESS_SERVER_PORT: ${serverPortRaw}`,
    );
  }

  return { name, port, token, orgId, api, server, serverPort, localIp };
}
