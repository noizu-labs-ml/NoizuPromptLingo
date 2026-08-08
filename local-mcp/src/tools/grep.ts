import { z } from "zod";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import fg from "fast-glob";
import { readText, DEFAULT_IGNORE, buildRegex } from "../lib/format.js";

const execFileAsync = promisify(execFile);

const inputSchema = {
  root: z
    .string()
    .optional()
    .describe("Base directory to search under. Defaults to the process cwd."),
  pattern: z.string().describe("Regular expression to search file contents for."),
  glob: z
    .string()
    .optional()
    .describe('Optional glob to restrict which files are searched, e.g. "**/*.ex".'),
  max_results: z
    .number()
    .int()
    .positive()
    .optional()
    .default(200)
    .describe("Maximum number of matching lines to return (default 200)."),
  ignore_case: z
    .boolean()
    .optional()
    .default(false)
    .describe("Case-insensitive matching."),
};

/** Detect whether ripgrep is on PATH (cached after first check). */
let rgAvailable: boolean | null = null;
async function hasRipgrep(): Promise<boolean> {
  if (rgAvailable !== null) return rgAvailable;
  try {
    await execFileAsync("which", ["rg"]);
    rgAvailable = true;
  } catch {
    rgAvailable = false;
  }
  return rgAvailable;
}

export function register(server: McpServer): void {
  server.registerTool(
    "grep",
    {
      description:
        "Search file contents by regex under root. Uses ripgrep when available, otherwise a Node fallback. Returns `relpath:lineno: line` rows.",
      inputSchema,
    },
    async ({ root, pattern, glob, max_results, ignore_case }) => {
      const base = root ?? process.cwd();
      const limit = max_results ?? 200;
      const ci = ignore_case ?? false;

      try {
        // Validate the regex up front for a clean error message.
        buildRegex(pattern, ci);

        let rows: string[];
        if (await hasRipgrep()) {
          rows = await grepWithRg(base, pattern, glob, limit, ci);
        } else {
          rows = await grepWithNode(base, pattern, glob, limit, ci);
        }

        const header = `${rows.length} match(es) (limit ${limit})`;
        const body = rows.length ? rows.join("\n") : "(no matches)";
        return { content: [{ type: "text", text: `${header}\n${body}` }] };
      } catch (e) {
        return {
          isError: true,
          content: [{ type: "text", text: `grep failed: ${(e as Error).message}` }],
        };
      }
    }
  );
}

async function grepWithRg(
  base: string,
  pattern: string,
  glob: string | undefined,
  limit: number,
  ignoreCase: boolean
): Promise<string[]> {
  const args = ["--line-number", "--no-heading", "--color", "never"];
  if (ignoreCase) args.push("--ignore-case");
  if (glob) args.push("--glob", glob);
  args.push("--", pattern, ".");

  try {
    const { stdout } = await execFileAsync("rg", args, {
      cwd: base,
      maxBuffer: 64 * 1024 * 1024,
    });
    return stdout
      .split("\n")
      .filter((l) => l.length > 0)
      .slice(0, limit)
      // rg prints `path:line:content` — already in our desired shape.
      .map((l) => l.replace(/^(.+?):(\d+):/, "$1:$2: "));
  } catch (e: any) {
    // rg exits 1 when there are no matches — treat as empty, not an error.
    if (e && typeof e.code === "number" && e.code === 1) return [];
    throw e;
  }
}

async function grepWithNode(
  base: string,
  pattern: string,
  glob: string | undefined,
  limit: number,
  ignoreCase: boolean
): Promise<string[]> {
  const re = buildRegex(pattern, ignoreCase);
  const files = await fg(glob ?? "**/*", {
    cwd: base,
    ignore: DEFAULT_IGNORE,
    dot: true,
    onlyFiles: true,
    followSymbolicLinks: false,
    suppressErrors: true,
  });
  files.sort();

  const rows: string[] = [];
  for (const rel of files) {
    if (rows.length >= limit) break;
    let text: string;
    try {
      text = await readText(`${base}/${rel}`);
    } catch {
      continue; // binary / unreadable
    }
    const lines = text.split("\n");
    for (let i = 0; i < lines.length; i++) {
      if (re.test(lines[i])) {
        rows.push(`${rel}:${i + 1}: ${lines[i]}`);
        if (rows.length >= limit) break;
      }
    }
  }
  return rows;
}
