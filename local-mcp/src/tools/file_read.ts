import { z } from "zod";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { stat } from "node:fs/promises";
import { resolveWithin } from "../lib/paths.js";
import { readText, withLineNumbers } from "../lib/format.js";

const inputSchema = {
  path: z.string().describe("File path to read (relative to `root` or absolute within it)."),
  root: z
    .string()
    .optional()
    .describe("Base directory the path must resolve within. Defaults to the process cwd."),
  start_line: z
    .number()
    .int()
    .positive()
    .optional()
    .describe("1-based first line to return (inclusive)."),
  end_line: z
    .number()
    .int()
    .positive()
    .optional()
    .describe("1-based last line to return (inclusive)."),
};

export function register(server: McpServer): void {
  server.registerTool(
    "file_read",
    {
      description:
        "Read a file (or a 1-based line range of it) and return it with cat -n style line numbers. Path is guarded to resolve within `root`.",
      inputSchema,
    },
    async ({ path, root, start_line, end_line }) => {
      const base = root ?? process.cwd();
      try {
        const abs = resolveWithin(base, path);
        const st = await stat(abs);
        if (!st.isFile()) {
          return {
            isError: true,
            content: [{ type: "text", text: `file_read failed: not a regular file: ${path}` }],
          };
        }

        const text = await readText(abs);
        const allLines = text.split("\n");
        // Drop trailing empty element from a final newline for range math.
        if (allLines.length > 0 && allLines[allLines.length - 1] === "") {
          allLines.pop();
        }

        const start = start_line ?? 1;
        const end = end_line ?? allLines.length;
        if (start > end) {
          return {
            isError: true,
            content: [
              { type: "text", text: `file_read failed: start_line (${start}) > end_line (${end})` },
            ],
          };
        }

        const slice = allLines.slice(start - 1, end);
        const numbered = withLineNumbers(slice.join("\n") + "\n", start);
        return { content: [{ type: "text", text: numbered }] };
      } catch (e) {
        const reason =
          (e as Error).message === "BINARY"
            ? "binary file (cannot display as text)"
            : (e as NodeJS.ErrnoException).code === "ENOENT"
              ? "file not found"
              : (e as Error).message;
        return {
          isError: true,
          content: [{ type: "text", text: `file_read failed: ${reason}` }],
        };
      }
    }
  );
}
