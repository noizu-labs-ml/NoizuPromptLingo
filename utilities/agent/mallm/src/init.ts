import { writeFileSync, mkdirSync, existsSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";
import { execSync } from "node:child_process";
import { stringify } from "yaml";
import { parseHelp } from "./help-parser.js";
import type { MallmConfig } from "./schema.js";

export function initMallm(
  app: string,
  options: { global?: boolean; project?: boolean }
): string {
  let seed: MallmConfig | null = null;

  try {
    const helpOutput = execSync(`${app} --help 2>&1 || ${app} -h 2>&1 || true`, {
      encoding: "utf-8",
      timeout: 5000,
      shell: "/bin/sh",
      stdio: ["pipe", "pipe", "pipe"],
    });
    if (helpOutput.trim()) {
      seed = parseHelp(app, helpOutput);
    }
  } catch {
    // couldn't get help output
  }

  if (!seed) {
    seed = {
      mallm: "1.0",
      name: app,
      summary: `${app} — TODO: add summary`,
      usage: {
        synopsis: `${app} [OPTIONS]`,
        examples: [
          { command: `${app} --help`, description: "Show help" },
        ],
      },
      context: {
        when_to_use: "TODO: describe when an LLM agent should use this tool",
        when_not_to_use: "TODO: describe when to avoid this tool",
      },
    };
  }

  // clean up auto-generated fields for a nicer template
  delete (seed as Partial<MallmConfig>).description;
  if (seed.context?.gotchas) {
    seed.context.gotchas = seed.context.gotchas.filter(
      (g) => !g.includes("auto-generated")
    );
    if (seed.context.gotchas.length === 0) delete seed.context.gotchas;
  }

  const yaml = stringify(seed, { lineWidth: 100 });
  let targetPath: string;

  if (options.global) {
    const dir = join(homedir(), ".config", "mallm", app);
    mkdirSync(dir, { recursive: true });
    targetPath = join(dir, "mallm.yaml");
  } else {
    let root = process.cwd();
    try {
      root = execSync("git rev-parse --show-toplevel", {
        encoding: "utf-8",
      }).trim();
    } catch {
      // not in a git repo, use cwd
    }
    const dir = join(root, ".mallm");
    mkdirSync(dir, { recursive: true });
    targetPath = join(dir, `${app}.yaml`);
  }

  if (existsSync(targetPath)) {
    return `Already exists: ${targetPath}`;
  }

  writeFileSync(targetPath, yaml);
  return `Created: ${targetPath}`;
}
