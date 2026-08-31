#!/usr/bin/env tsx
import { render } from "ink";
import React from "react";
import { ensureApi } from "@llm-toolkit/shared";
import { App } from "./src/app.tsx";
import { parseInvocation } from "./src/interface-selection.js";
import { runRecentCommand } from "./src/commands/recent.js";

const rawArgs = process.argv.slice(2);
const { command, args, warnings } = parseInvocation(rawArgs);

const NEEDS_API = new Set(["search", "list", "show", "edit", "convert", "dataset", "serve", "merge", "rehome", "index", "interactive"]);

async function main() {
  for (const warning of warnings) {
    console.error(warning);
  }
  if (command === "recent") {
    process.exitCode = runRecentCommand(args);
    return;
  }
  if (NEEDS_API.has(command)) {
    const { alreadyRunning } = await ensureApi();
    if (!alreadyRunning) {
      console.error("Started API server on http://localhost:3100");
    }
  }
  render(React.createElement(App, { command, args }));
}

main();
