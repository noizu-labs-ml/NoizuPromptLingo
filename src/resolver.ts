import { readFileSync, existsSync, readdirSync } from "node:fs";
import { join, resolve } from "node:path";
import { homedir } from "node:os";
import { execSync } from "node:child_process";
import { parse as parseYaml } from "yaml";
import type { MallmConfig, ResolvedMallm } from "./schema.js";
import { parseHelp } from "./help-parser.js";

const MALLM_FILENAME = "mallm.yaml";

function findProjectRoot(): string | null {
  let dir = process.cwd();
  while (dir !== "/") {
    if (existsSync(join(dir, ".mallm")) || existsSync(join(dir, ".git"))) {
      return dir;
    }
    dir = resolve(dir, "..");
  }
  return null;
}

function loadYaml(path: string): MallmConfig | null {
  try {
    const content = readFileSync(path, "utf-8");
    return parseYaml(content) as MallmConfig;
  } catch {
    return null;
  }
}

function tryProjectLocal(app: string): ResolvedMallm | null {
  const root = findProjectRoot();
  if (!root) return null;
  const path = join(root, ".mallm", `${app}.yaml`);
  const config = loadYaml(path);
  if (!config) return null;
  return { config, source: "project-local", path };
}

function tryUserConfig(app: string, version?: string): ResolvedMallm | null {
  const base = join(homedir(), ".config", "mallm", app);
  if (version) {
    const path = join(base, version, MALLM_FILENAME);
    const config = loadYaml(path);
    if (config) return { config, source: "user-config", path };
  }
  const latestPath = join(base, "latest", MALLM_FILENAME);
  const config = loadYaml(latestPath);
  if (config) return { config, source: "user-config", path: latestPath };
  const rootPath = join(base, MALLM_FILENAME);
  const rootConfig = loadYaml(rootPath);
  if (rootConfig) return { config: rootConfig, source: "user-config", path: rootPath };
  return null;
}

function tryNative(app: string): ResolvedMallm | null {
  try {
    const output = execSync(`${app} --mallm`, {
      encoding: "utf-8",
      timeout: 5000,
      stdio: ["pipe", "pipe", "pipe"],
    });
    const config = parseYaml(output) as MallmConfig;
    if (config?.mallm) return { config, source: "native" };
  } catch {
    // app doesn't support --mallm
  }
  return null;
}

function tryHelpFallback(app: string): ResolvedMallm | null {
  try {
    const output = execSync(`${app} --help 2>&1 || ${app} -h 2>&1 || true`, {
      encoding: "utf-8",
      timeout: 5000,
      shell: "/bin/sh",
      stdio: ["pipe", "pipe", "pipe"],
    });
    if (!output.trim()) return null;
    const config = parseHelp(app, output);
    return { config, source: "help-generated" };
  } catch {
    return null;
  }
}

export function resolve_mallm(
  app: string,
  options?: { version?: string }
): ResolvedMallm | null {
  return (
    tryProjectLocal(app) ??
    tryUserConfig(app, options?.version) ??
    tryNative(app) ??
    tryHelpFallback(app)
  );
}

export function listAvailable(): Array<{ name: string; source: string; path: string }> {
  const results: Array<{ name: string; source: string; path: string }> = [];

  const root = findProjectRoot();
  if (root) {
    const mallmDir = join(root, ".mallm");
    if (existsSync(mallmDir)) {
      for (const file of readdirSync(mallmDir)) {
        if (file.endsWith(".yaml")) {
          results.push({
            name: file.replace(/\.yaml$/, ""),
            source: "project-local",
            path: join(mallmDir, file),
          });
        }
      }
    }
  }

  const userBase = join(homedir(), ".config", "mallm");
  if (existsSync(userBase)) {
    for (const entry of readdirSync(userBase, { withFileTypes: true })) {
      if (entry.isDirectory()) {
        const yamlPath = join(userBase, entry.name, MALLM_FILENAME);
        if (existsSync(yamlPath)) {
          results.push({
            name: entry.name,
            source: "user-config",
            path: yamlPath,
          });
        }
      }
    }
  }

  return results;
}
