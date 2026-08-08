import { z } from "zod";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import fg from "fast-glob";
import { readText, DEFAULT_IGNORE, buildRegex } from "../lib/format.js";

const inputSchema = {
  root: z
    .string()
    .optional()
    .describe("Base directory to search under. Defaults to the process cwd."),
  glob: z
    .string()
    .describe('Glob pattern to match files, e.g. "**/*.ts".'),
  content: z
    .string()
    .optional()
    .describe(
      "Optional regex; only files whose text matches are kept (also reports first matching line)."
    ),
  max_results: z
    .number()
    .int()
    .positive()
    .optional()
    .default(200)
    .describe("Maximum number of files to return (default 200)."),
};

export function register(server: McpServer): void {
  server.registerTool(
    "file_search",
    {
      description:
        "Find files matching a glob under root; optionally keep only files whose contents match a regex. Returns a newline-separated list of relative paths (with the first matching line when content is given).",
      inputSchema,
    },
    async ({ root, glob, content, max_results }) => {
      const base = root ?? process.cwd();
      const limit = max_results ?? 200;
      try {
        const matches = await fg(glob, {
          cwd: base,
          ignore: DEFAULT_IGNORE,
          dot: true,
          onlyFiles: true,
          followSymbolicLinks: false,
          suppressErrors: true,
        });
        matches.sort();

        const contentRe = content ? buildRegex(content) : null;
        const rows: string[] = [];

        for (const rel of matches) {
          if (rows.length >= limit) break;
          if (!contentRe) {
            rows.push(rel);
            continue;
          }
          try {
            const text = await readText(`${base}/${rel}`);
            const line = text.split("\n").find((l) => contentRe.test(l));
            if (line !== undefined) {
              rows.push(`${rel}:${line.trim()}`);
            }
          } catch {
            // Binary or unreadable — skip when filtering by content.
          }
        }

        const header = `${rows.length} file(s) matched (limit ${limit})`;
        const body = rows.length ? rows.join("\n") : "(no matches)";
        return { content: [{ type: "text", text: `${header}\n${body}` }] };
      } catch (e) {
        return {
          isError: true,
          content: [
            { type: "text", text: `file_search failed: ${(e as Error).message}` },
          ],
        };
      }
    }
  );
}
