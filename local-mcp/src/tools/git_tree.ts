import { z } from "zod";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { relative, basename } from "node:path";
import { gitRootAndFiles } from "../lib/git.js";

const inputSchema = {
  path: z
    .string()
    .optional()
    .describe("Directory to render. Defaults to the process cwd."),
  depth: z
    .number()
    .int()
    .positive()
    .optional()
    .describe("Optional max depth; subtrees deeper than this are pruned."),
};

interface TreeNode {
  name: string;
  children: Map<string, TreeNode>;
}

function makeNode(name: string): TreeNode {
  return { name, children: new Map() };
}

export function register(server: McpServer): void {
  server.registerTool(
    "git_tree",
    {
      description:
        "Render a directory tree of git-tracked files under `path` using box-drawing characters. Resolves the git root and respects .gitignore. Optional depth prunes deeper subtrees.",
      inputSchema,
    },
    async ({ path, depth }) => {
      const base = path ?? process.cwd();
      try {
        const { root, files } = await gitRootAndFiles(base);
        // Restrict to files under the requested path, relative to that path.
        const prefix = relative(root, base);
        const rels: string[] = [];
        for (const f of files) {
          if (prefix === "" || prefix === ".") {
            rels.push(f);
          } else if (f === prefix || f.startsWith(prefix + "/")) {
            rels.push(relative(prefix, f));
          }
        }

        const rootNode = makeNode(basename(base) || base);
        for (const rel of rels) {
          const parts = rel.split("/");
          let node = rootNode;
          const climb = depth ? Math.min(parts.length, depth) : parts.length;
          for (let i = 0; i < climb; i++) {
            const part = parts[i];
            if (!node.children.has(part)) {
              node.children.set(part, makeNode(part));
            }
            node = node.children.get(part)!;
          }
        }

        const lines: string[] = [rootNode.name];
        renderChildren(rootNode, "", lines);
        return { content: [{ type: "text", text: lines.join("\n") }] };
      } catch (e) {
        return {
          isError: true,
          content: [
            { type: "text", text: `git_tree failed: ${(e as Error).message}` },
          ],
        };
      }
    }
  );
}

function renderChildren(node: TreeNode, prefix: string, out: string[]): void {
  const entries = [...node.children.values()].sort((a, b) => {
    // Directories (have children) before files, then alphabetical.
    const aDir = a.children.size > 0 ? 0 : 1;
    const bDir = b.children.size > 0 ? 0 : 1;
    if (aDir !== bDir) return aDir - bDir;
    return a.name.localeCompare(b.name);
  });

  entries.forEach((child, idx) => {
    const last = idx === entries.length - 1;
    const branch = last ? "└── " : "├── ";
    out.push(`${prefix}${branch}${child.name}`);
    const childPrefix = prefix + (last ? "    " : "│   ");
    renderChildren(child, childPrefix, out);
  });
}
