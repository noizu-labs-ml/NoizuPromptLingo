#!/usr/bin/env node

/**
 * styleguide-serve — Preview theme YAML in the interactive style guide viewer.
 *
 * Usage:
 *   npx @noizu/styleguide serve ./path/to/themes/
 *   styleguide-serve ./path/to/themes/ [--port 3000]
 *
 * The theme directory should contain theme-* subdirectories, each with
 * style-guide.meta.yaml at minimum. The base theme (theme-style-guide)
 * is auto-included if not present.
 *
 * First run installs dependencies (~20s). Subsequent runs start in ~3s.
 */

import { execSync, spawn } from "child_process";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const CACHE_DIR = path.join(process.env.HOME || "/tmp", ".cache", "styleguide-viewer");
const SCAFFOLD_DIR = path.join(__dirname, "viewer-scaffold");

const VERSION = (() => {
  try {
    const pkg = JSON.parse(fs.readFileSync(path.join(__dirname, "..", "package.json"), "utf-8"));
    return pkg.version || "0.0.0";
  } catch {
    return "0.0.0";
  }
})();

// ─── CLI parsing ────────────────────────────────────────────────────────────

function printHelp() {
  console.log(`styleguide-serve v${VERSION} — Preview theme YAML in the interactive style guide viewer`);
  console.log("");
  console.log("USAGE:");
  console.log("  styleguide-serve <theme-directory> [options]");
  console.log("  npx @noizu/styleguide serve <theme-directory> [options]");
  console.log("");
  console.log("ARGUMENTS:");
  console.log("  <theme-directory>   Directory containing theme-* subdirectories.");
  console.log("                      Each theme-* dir needs style-guide.meta.yaml at minimum.");
  console.log("");
  console.log("OPTIONS:");
  console.log("  --port <number>     Port for the dev server (default: 3000)");
  console.log("  --clean             Delete cached viewer app and reinstall from scratch");
  console.log("  --help, -h          Show this help message");
  console.log("  --version, -v       Show version number");
  console.log("");
  console.log("EXAMPLES:");
  console.log("  styleguide-serve ./design/viewer/src/config/");
  console.log("  styleguide-serve ./design/theme/ --port 3001");
  console.log("  styleguide-serve ./design/theme/ --clean");
  console.log("");
  console.log("THEME DIRECTORY STRUCTURE:");
  console.log("  <theme-directory>/");
  console.log("    ├── theme-my-brand/");
  console.log("    │   ├── style-guide.meta.yaml   (required)");
  console.log("    │   ├── vars.yaml");
  console.log("    │   └── branding.yaml");
  console.log("    └── theme-style-guide/           (base theme, auto-added if missing)");
  console.log("");
  console.log("CACHE:");
  console.log(`  Viewer app cached at: ${CACHE_DIR}`);
  console.log("  Use --clean to force a full reinstall.");
}

function parseArgs(argv) {
  const args = argv.slice(2);

  // Handle `npx @noizu/styleguide serve ./themes/` (skip "serve" arg)
  const filtered = args.filter((a) => a !== "serve");

  if (filtered.includes("--help") || filtered.includes("-h")) {
    return { action: "help" };
  }

  if (filtered.includes("--version") || filtered.includes("-v")) {
    return { action: "version" };
  }

  const clean = filtered.includes("--clean");

  // Parse --port
  let port = 3000;
  const portIdx = filtered.findIndex((a) => a === "--port" || a.startsWith("--port="));
  if (portIdx !== -1) {
    const portArg = filtered[portIdx];
    const rawPort = portArg.includes("=")
      ? portArg.split("=")[1]
      : filtered[portIdx + 1];

    if (!rawPort || rawPort.startsWith("--")) {
      return { action: "error", message: "Error: --port requires a port number (e.g. --port 3001)" };
    }

    port = parseInt(rawPort, 10);
    if (isNaN(port) || port < 1 || port > 65535) {
      return { action: "error", message: `Error: Invalid port number: ${rawPort} (must be 1-65535)` };
    }
  }

  // Find the theme directory (first positional arg that isn't a flag or flag value)
  const positional = filtered.filter((a, i) => {
    if (a.startsWith("--")) return false;
    // Skip if this is the value for --port
    if (i > 0 && filtered[i - 1] === "--port") return false;
    return true;
  });

  const themeDirArg = positional[0];

  if (!themeDirArg) {
    return { action: "error", message: null }; // show usage
  }

  return { action: "serve", themeDirArg, port: String(port), clean };
}

// ─── Preflight checks ──────────────────────────────────────────────────────

function checkPrerequisites() {
  try {
    execSync("node --version", { stdio: "pipe" });
  } catch {
    console.error("Error: 'node' not found on PATH. Install Node.js >= 18.");
    process.exit(1);
  }

  try {
    execSync("npm --version", { stdio: "pipe" });
  } catch {
    console.error("Error: 'npm' not found on PATH. Install Node.js >= 18 (includes npm).");
    process.exit(1);
  }
}

function validateThemeDir(themeDirArg) {
  const themeDir = path.resolve(themeDirArg);

  if (!fs.existsSync(themeDir)) {
    console.error(`Error: Theme directory not found: ${themeDir}`);
    process.exit(1);
  }

  if (!fs.statSync(themeDir).isDirectory()) {
    console.error(`Error: Not a directory: ${themeDir}`);
    process.exit(1);
  }

  const themeDirs = fs.readdirSync(themeDir).filter(
    (d) => d.startsWith("theme-") && fs.statSync(path.join(themeDir, d)).isDirectory()
  );

  if (themeDirs.length === 0) {
    console.error(`Error: No theme-* directories found in ${themeDir}`);
    console.error("");
    console.error("Expected structure:");
    console.error(`  ${themeDir}/`);
    console.error("    └── theme-{slug}/");
    console.error("        └── style-guide.meta.yaml");
    console.error("");
    console.error("Run with --help for more information.");
    process.exit(1);
  }

  const validThemes = [];
  const skippedThemes = [];

  for (const d of themeDirs) {
    if (fs.existsSync(path.join(themeDir, d, "style-guide.meta.yaml"))) {
      validThemes.push(d);
    } else {
      skippedThemes.push(d);
    }
  }

  if (validThemes.length === 0) {
    console.error("Error: No valid themes found — every theme-* directory is missing style-guide.meta.yaml");
    console.error("");
    console.error("Directories found but missing style-guide.meta.yaml:");
    for (const d of skippedThemes) {
      console.error(`  - ${d}/`);
    }
    process.exit(1);
  }

  if (skippedThemes.length > 0) {
    console.warn(`Warning: Skipping ${skippedThemes.length} theme dir(s) missing style-guide.meta.yaml:`);
    for (const d of skippedThemes) {
      console.warn(`  - ${d}/`);
    }
    console.warn("");
  }

  return { themeDir, validThemes };
}

// ─── Core functions ─────────────────────────────────────────────────────────

function ensureBaseTheme(themeDir) {
  const baseThemeTarget = path.join(themeDir, "theme-style-guide");
  if (fs.existsSync(baseThemeTarget)) return;

  console.log("Adding base theme (theme-style-guide)...");

  // Try to find it from the installed package
  const pkgPaths = [
    path.join(__dirname, "..", "dist", "engine-src", "config", "theme-style-guide"),
    path.join(__dirname, "..", "..", "src", "config", "theme-style-guide"),
  ];

  for (const src of pkgPaths) {
    if (fs.existsSync(src)) {
      fs.cpSync(src, baseThemeTarget, { recursive: true });
      console.log("  Copied base theme from package");
      return;
    }
  }

  console.warn("  Warning: Could not find base theme-style-guide. Themes may not cascade correctly.");
}

function cleanCache() {
  if (fs.existsSync(CACHE_DIR)) {
    console.log(`Removing cached viewer app at ${CACHE_DIR}...`);
    fs.rmSync(CACHE_DIR, { recursive: true });
    console.log("Cache cleared.");
  } else {
    console.log("No cached viewer app found — nothing to clean.");
  }
}

function ensureViewerApp() {
  const pkgJsonPath = path.join(CACHE_DIR, "package.json");
  const nodeModulesPath = path.join(CACHE_DIR, "node_modules");

  // Check if scaffold source exists
  if (!fs.existsSync(path.join(SCAFFOLD_DIR, "package.json"))) {
    console.error(`Error: Viewer scaffold not found at ${SCAFFOLD_DIR}`);
    console.error("This is a packaging bug — the bin/viewer-scaffold/ directory is missing from the installed package.");
    process.exit(1);
  }

  // Check if scaffold needs updating
  const scaffoldPkg = JSON.parse(fs.readFileSync(path.join(SCAFFOLD_DIR, "package.json"), "utf-8"));
  let needsInstall = false;

  if (!fs.existsSync(pkgJsonPath)) {
    needsInstall = true;
  } else {
    const cachedPkg = JSON.parse(fs.readFileSync(pkgJsonPath, "utf-8"));
    if (JSON.stringify(cachedPkg.dependencies) !== JSON.stringify(scaffoldPkg.dependencies)) {
      needsInstall = true;
    }
  }

  if (!fs.existsSync(nodeModulesPath)) {
    needsInstall = true;
  }

  // Copy scaffold files (always, to pick up viewer component changes)
  console.log("Syncing viewer app...");
  fs.mkdirSync(CACHE_DIR, { recursive: true });
  fs.cpSync(SCAFFOLD_DIR, CACHE_DIR, {
    recursive: true,
    filter: (src) => !src.includes("node_modules") && !src.includes(".next"),
  });

  if (needsInstall) {
    console.log("Installing dependencies (first run, ~20s)...");
    try {
      execSync("npm install --prefer-offline", {
        cwd: CACHE_DIR,
        stdio: "inherit",
        env: { ...process.env, NPM_TOKEN: process.env.NPM_TOKEN || "" },
      });
    } catch (err) {
      console.error("");
      console.error("Error: npm install failed in the viewer scaffold.");
      if (!process.env.NPM_TOKEN) {
        console.error("");
        console.error("Hint: The @noizu/styleguide package requires authentication.");
        console.error("Set NPM_TOKEN in your environment:");
        console.error("  1. npm login --registry=https://npm.noizu.com");
        console.error("  2. export NPM_TOKEN=$(grep npm.noizu.com ~/.npmrc | cut -d= -f2)");
      }
      process.exit(1);
    }
  }

  // Patch localStorage SSR bug if present
  patchLocalStorageBug();
}

function linkThemes(themeDir) {
  const configDir = path.join(CACHE_DIR, "src", "config");

  // Remove existing theme symlinks
  if (fs.existsSync(configDir)) {
    for (const entry of fs.readdirSync(configDir)) {
      const full = path.join(configDir, entry);
      if (entry.startsWith("theme-") && fs.lstatSync(full).isSymbolicLink()) {
        fs.unlinkSync(full);
      }
    }
  } else {
    fs.mkdirSync(configDir, { recursive: true });
  }

  // Symlink user's themes into the viewer's config
  let linked = 0;
  for (const entry of fs.readdirSync(themeDir)) {
    if (!entry.startsWith("theme-")) continue;
    const src = path.join(themeDir, entry);
    if (!fs.statSync(src).isDirectory()) continue;
    const dest = path.join(configDir, entry);
    fs.symlinkSync(src, dest);
    linked++;
  }
  console.log(`Linked ${linked} theme(s) into viewer.`);

  // Clear Next.js cache so it picks up new themes
  const nextDir = path.join(CACHE_DIR, ".next");
  if (fs.existsSync(nextDir)) {
    fs.rmSync(nextDir, { recursive: true });
  }
}

function patchLocalStorageBug() {
  const cookieFile = path.join(
    CACHE_DIR, "node_modules", "@noizu", "styleguide",
    "dist", "engine-src", "lib", "section-cookie.ts"
  );
  if (!fs.existsSync(cookieFile)) return;

  let content = fs.readFileSync(cookieFile, "utf-8");
  if (content.includes('typeof localStorage === "undefined"')) {
    content = content.replaceAll(
      'typeof localStorage === "undefined"',
      'typeof window === "undefined" || typeof localStorage?.getItem !== "function"'
    );
    fs.writeFileSync(cookieFile, content);
  }
}

// ─── Main ───────────────────────────────────────────────────────────────────

function main() {
  const parsed = parseArgs(process.argv);

  if (parsed.action === "help") {
    printHelp();
    process.exit(0);
  }

  if (parsed.action === "version") {
    console.log(`styleguide-serve v${VERSION}`);
    process.exit(0);
  }

  if (parsed.action === "error") {
    if (parsed.message) {
      console.error(parsed.message);
    } else {
      printHelp();
    }
    process.exit(1);
  }

  // action === "serve"
  const { themeDirArg, port, clean } = parsed;

  checkPrerequisites();

  if (clean) {
    cleanCache();
  }

  const { themeDir, validThemes } = validateThemeDir(themeDirArg);

  console.log("╭─────────────────────────────────────╮");
  console.log("│   Style Guide Viewer                │");
  console.log("╰─────────────────────────────────────╯");
  console.log("");
  console.log(`  Version: ${VERSION}`);
  console.log(`  Themes:  ${validThemes.join(", ")}`);
  console.log(`  Source:  ${themeDir}`);
  console.log(`  Port:    ${port}`);
  console.log(`  Cache:   ${CACHE_DIR}`);
  console.log("");

  ensureBaseTheme(themeDir);
  ensureViewerApp();
  linkThemes(themeDir);

  // Generate CSS
  console.log("Generating CSS...");
  try {
    execSync("npm run regen", {
      cwd: CACHE_DIR,
      env: { ...process.env, STYLEGUIDE_CONFIG_ROOT: path.join(CACHE_DIR, "src", "config") },
      stdio: "inherit",
    });
  } catch {
    console.error("");
    console.error("Error: CSS generation failed. Check your theme YAML files for syntax errors.");
    console.error("Try running with --clean to rebuild the viewer cache.");
    process.exit(1);
  }

  console.log("");
  console.log(`Starting viewer on http://localhost:${port}`);
  console.log("Press Ctrl+C to stop");
  console.log("");

  const child = spawn("npx", ["next", "dev", "--port", port], {
    cwd: CACHE_DIR,
    env: { ...process.env, STYLEGUIDE_CONFIG_ROOT: path.join(CACHE_DIR, "src", "config") },
    stdio: "inherit",
  });

  child.on("exit", (code) => process.exit(code || 0));
  child.on("error", (err) => {
    console.error(`Error: Failed to start Next.js dev server: ${err.message}`);
    process.exit(1);
  });
  process.on("SIGINT", () => { child.kill("SIGINT"); });
  process.on("SIGTERM", () => { child.kill("SIGTERM"); });
}

main();
