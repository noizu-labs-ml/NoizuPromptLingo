/**
 * Controller configuration, resolved from CLI flags then environment variables.
 *
 *   --url / BROWSER_CONTROLLER_URL     cloud socket URL (wss://tobor.locker/socket)
 *   --token / BROWSER_CONTROLLER_TOKEN MCP JWT (minted from an MCP API key)
 *   --org / BROWSER_CONTROLLER_ORG     organization id (UUID)
 *   --headed / BROWSER_CONTROLLER_HEADED  launch a visible browser (default headless)
 */

export interface Config {
  url: string;
  token: string;
  orgId: string;
  headless: boolean;
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

  const url =
    (args.url as string) ||
    process.env.BROWSER_CONTROLLER_URL ||
    "wss://tobor.locker/socket";
  const token =
    (args.token as string) || process.env.BROWSER_CONTROLLER_TOKEN || "";
  const orgId =
    (args.org as string) || process.env.BROWSER_CONTROLLER_ORG || "";

  const headedFlag =
    args.headed === true ||
    process.env.BROWSER_CONTROLLER_HEADED === "1" ||
    process.env.BROWSER_CONTROLLER_HEADED === "true";

  const missing: string[] = [];
  if (!token) missing.push("--token / BROWSER_CONTROLLER_TOKEN");
  if (!orgId) missing.push("--org / BROWSER_CONTROLLER_ORG");
  if (missing.length > 0) {
    throw new Error(
      `Missing required configuration: ${missing.join(", ")}.\n` +
        `Usage: noizu-browser-controller --url <wss://host/socket> --token <mcp-jwt> --org <org-id> [--headed]`,
    );
  }

  return { url, token, orgId, headless: !headedFlag };
}
