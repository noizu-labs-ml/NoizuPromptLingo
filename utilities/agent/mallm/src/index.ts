#!/usr/bin/env node

import { readFileSync } from "node:fs";
import { Command } from "commander";
import chalk from "chalk";
import { parse as parseYaml } from "yaml";
import { resolve_mallm, listAvailable } from "./resolver.js";
import { formatMarkdown, formatJson } from "./formatter.js";
import { initMallm } from "./init.js";

const program = new Command();

program
  .name("mallm")
  .description("man pages for LLMs — structured CLI documentation for AI agents")
  .version("0.1.0");

program
  .command("show <app>")
  .description("Show mallm documentation for a command")
  .option("--json", "Output as structured JSON instead of markdown")
  .option("--version <ver>", "Request documentation for a specific version")
  .action((app: string, opts: { json?: boolean; version?: string }) => {
    showApp(app, opts);
  });

program
  .command("init <app>")
  .description("Create a mallm.yaml stub for a command (seeds from --help if available)")
  .option("--global", "Create in ~/.config/mallm/ instead of project .mallm/")
  .action((app: string, opts: { global?: boolean }) => {
    const result = initMallm(app, {
      global: opts.global,
      project: !opts.global,
    });
    console.log(result);
  });

program
  .command("list")
  .description("List all available mallm definitions")
  .option("--json", "Output as JSON")
  .action((opts: { json?: boolean }) => {
    const items = listAvailable();

    if (items.length === 0) {
      console.log(chalk.dim("No mallm definitions found."));
      console.log(chalk.dim("Create one with: mallm init <app>"));
      return;
    }

    if (opts.json) {
      console.log(JSON.stringify(items, null, 2));
      return;
    }

    console.log(chalk.bold("Available mallm definitions:\n"));

    const bySource = new Map<string, typeof items>();
    for (const item of items) {
      const group = bySource.get(item.source) ?? [];
      group.push(item);
      bySource.set(item.source, group);
    }

    for (const [source, group] of bySource) {
      console.log(chalk.underline(source));
      for (const item of group) {
        console.log(`  ${chalk.green(item.name)}  ${chalk.dim(item.path)}`);
      }
      console.log("");
    }
  });

program
  .command("validate <path>")
  .description("Validate a mallm.yaml file")
  .action((path: string) => {
    try {
      const content = readFileSync(path, "utf-8");
      const config = parseYaml(content);

      const errors: string[] = [];
      if (!config.mallm) errors.push("Missing 'mallm' version field");
      if (!config.name) errors.push("Missing 'name' field");
      if (!config.summary) errors.push("Missing 'summary' field");

      if (config.arguments) {
        for (const arg of config.arguments) {
          if (!arg.name) errors.push("Argument missing 'name'");
          if (!arg.type) errors.push(`Argument '${arg.name}' missing 'type'`);
          if (!arg.description)
            errors.push(`Argument '${arg.name}' missing 'description'`);
        }
      }

      if (errors.length > 0) {
        console.error(chalk.red("Validation failed:"));
        for (const err of errors) {
          console.error(chalk.red(`  - ${err}`));
        }
        process.exit(1);
      }

      console.log(chalk.green(`Valid: ${path}`));
      console.log(chalk.dim(`  name: ${config.name}`));
      console.log(chalk.dim(`  summary: ${config.summary}`));
      if (config.arguments)
        console.log(chalk.dim(`  arguments: ${config.arguments.length}`));
      if (config.subcommands)
        console.log(chalk.dim(`  subcommands: ${config.subcommands.length}`));
    } catch (e) {
      console.error(chalk.red(`Failed to parse: ${e}`));
      process.exit(1);
    }
  });

program
  .command("schema")
  .description("Print the mallm.yaml JSON Schema")
  .action(() => {
    const schemaPath = new URL("../schemas/mallm.schema.json", import.meta.url);
    try {
      const schema = readFileSync(schemaPath, "utf-8");
      console.log(schema);
    } catch {
      console.error(chalk.red("Schema file not found. Run from installed package."));
      process.exit(1);
    }
  });

function showApp(app: string, opts?: { json?: boolean; version?: string }) {
  const resolved = resolve_mallm(app, { version: opts?.version });

  if (!resolved) {
    console.error(chalk.red(`No mallm documentation found for '${app}'.`));
    console.error(
      chalk.dim(
        `\nTo create one:\n  mallm init ${app}\n  mallm init ${app} --global`
      )
    );
    process.exit(1);
  }

  if (opts?.json) {
    console.log(formatJson(resolved));
  } else {
    console.log(formatMarkdown(resolved));
  }
}

// Default: `mallm <app>` as shorthand for `mallm show <app>`
program.argument("[app]", "Command to look up (shorthand for 'mallm show <app>')");
program.option("--json", "Output as structured JSON");
program.action((app?: string, opts?: { json?: boolean }) => {
  if (!app) {
    program.help();
    return;
  }
  showApp(app, opts);
});

program.parse();
