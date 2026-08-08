import { z } from "zod";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { join } from "node:path";
import fg from "fast-glob";
import { gitRootAndFiles } from "../lib/git.js";
import { readText, dumpBlock } from "../lib/format.js";

const inputSchema = {
  path: z
    .string()
    .optional()
    .describe("Directory to dump. Defaults to the process cwd."),
  glob: z
    .string()
    .optional()
    .describe("Optional glob (relative to git root) to filter tracked files."),
};

export function register(server: McpServer): void {
  server.registerTool(
    "git_dump",
    {
      description:
        "Dump every git-tracked file under `path` as `# relpath / --- / contents / * * *` blocks. Binary or unreadable files are noted and skipped. Optional glob filters the file set.",
      inputSchema,
    },
    async ({ path, glob }) => {
      const base = path ?? process.cwd();
      try {
        const { root, files } = await gitRootAndFiles(base);

        let selected = files;
        if (glob) {
          const matched = new Set(
            await fg(glob, {
              cwd: root,
              dot: true,
              onlyFiles: true,
              followSymbolicLinks: false,
              suppressErrors: true,
            })
          );
          selected = files.filter((f) => matched.has(f));
        }

        const blocks: string[] = [];
        for (const rel of selected) {
          try {
            const text = await readText(join(root, rel));
            blocks.push(dumpBlock(rel, text));
          } catch (e) {
            const reason =
              (e as Error).message === "BINARY" ? "binary file" : (e as Error).message;
            blocks.push(dumpBlock(rel, `(skipped: ${reason})`));
          }
        }

        const header = `# ${selected.length} file(s) dumped from ${root}\n\n`;
        return {
          content: [
            { type: "text", text: blocks.length ? header + blocks.join("\n") : "(no tracked files)" },
          ],
        };
      } catch (e) {
        return {
          isError: true,
          content: [
            { type: "text", text: `git_dump failed: ${(e as Error).message}` },
          ],
        };
      }
    }
  );
}
