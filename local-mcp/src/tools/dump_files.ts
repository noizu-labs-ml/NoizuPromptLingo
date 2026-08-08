import { z } from "zod";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { relative } from "node:path";
import { stat } from "node:fs/promises";
import { resolveWithin } from "../lib/paths.js";
import { readText, dumpBlock } from "../lib/format.js";

const inputSchema = {
  files: z
    .array(z.string())
    .min(1)
    .describe("List of file paths to dump (relative to `root` or absolute within it)."),
  root: z
    .string()
    .optional()
    .describe("Base directory paths must resolve within. Defaults to the process cwd."),
};

export function register(server: McpServer): void {
  server.registerTool(
    "dump_files",
    {
      description:
        "Dump an explicit list of files as `# path / --- / contents / * * *` blocks. Each path is validated to exist and to resolve within `root` (guards against ../ escape).",
      inputSchema,
    },
    async ({ files, root }) => {
      const base = root ?? process.cwd();
      try {
        const blocks: string[] = [];
        for (const p of files) {
          let abs: string;
          try {
            abs = resolveWithin(base, p);
          } catch (e) {
            blocks.push(dumpBlock(p, `(skipped: ${(e as Error).message})`));
            continue;
          }
          try {
            const st = await stat(abs);
            if (!st.isFile()) {
              blocks.push(dumpBlock(p, "(skipped: not a regular file)"));
              continue;
            }
            const rel = relative(base, abs) || p;
            const text = await readText(abs);
            blocks.push(dumpBlock(rel, text));
          } catch (e) {
            const reason =
              (e as Error).message === "BINARY"
                ? "binary file"
                : (e as NodeJS.ErrnoException).code === "ENOENT"
                  ? "file not found"
                  : (e as Error).message;
            blocks.push(dumpBlock(p, `(skipped: ${reason})`));
          }
        }
        return { content: [{ type: "text", text: blocks.join("\n") }] };
      } catch (e) {
        return {
          isError: true,
          content: [
            { type: "text", text: `dump_files failed: ${(e as Error).message}` },
          ],
        };
      }
    }
  );
}
