#!/usr/bin/env tsx
import { render } from "ink";
import React from "react";
import { ensureApi } from "@claude-assist/shared";
import { App } from "./src/app.tsx";

const args = process.argv.slice(2);
const command = args[0] ?? "help";

const NEEDS_API = new Set(["search", "list", "show", "edit", "convert", "dataset", "serve", "merge", "rehome", "index", "interactive"]);

async function main() {
  if (NEEDS_API.has(command)) {
    const { alreadyRunning } = await ensureApi();
    if (!alreadyRunning) {
      console.error("Started API server on http://localhost:3100");
    }
  }
  render(React.createElement(App, { command, args: args.slice(1) }));
}

main();
