/**
 * Controller configuration, resolved from CLI flags then environment variables.
 *
 *   --api / BROWSER_CONTROLLER_API     cloud API base (https://tobor.locker)
 *   --url / BROWSER_CONTROLLER_URL     cloud socket URL (wss://tobor.locker/socket)
 *   --token / BROWSER_CONTROLLER_TOKEN MCP JWT (minted from an MCP API key)
 *   --org / BROWSER_CONTROLLER_ORG     organization id (UUID)
 *   --headed / BROWSER_CONTROLLER_HEADED  launch a visible browser (default headless)
 *
 * token + org are optional: when absent the controller prompts for an MCP API
 * key on boot and exchanges it via <api>/api/mcp/browser-bootstrap.
 */

export interface Config {
  apiBase: string;
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

  const apiBase = (
    (args.api as string) ||
    process.env.BROWSER_CONTROLLER_API ||
    "https://tobor.locker"
  ).replace(/\/+$/, "");
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

  // token + org are resolved at boot via the API-key prompt when not supplied.
  return { apiBase, url, token, orgId, headless: !headedFlag };
}
