#!/usr/bin/env node
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

import { register as registerFileSearch } from "./tools/file_search.js";
import { register as registerGrep } from "./tools/grep.js";
import { register as registerGitTree } from "./tools/git_tree.js";
import { register as registerGitDump } from "./tools/git_dump.js";
import { register as registerDumpFiles } from "./tools/dump_files.js";
import { register as registerFileRead } from "./tools/file_read.js";

async function main(): Promise<void> {
  const server = new McpServer({
    name: "noizu-local-mcp",
    version: "0.1.0",
  });

  registerFileSearch(server);
  registerGrep(server);
  registerGitTree(server);
  registerGitDump(server);
  registerDumpFiles(server);
  registerFileRead(server);

  const transport = new StdioServerTransport();
  await server.connect(transport);

  // stdio servers communicate over stdout; keep diagnostics on stderr only.
  process.stderr.write("noizu-local-mcp: ready on stdio\n");
}

main().catch((err) => {
  process.stderr.write(`noizu-local-mcp: fatal: ${err?.stack ?? err}\n`);
  process.exit(1);
});
