import fs from "fs";
import path from "path";
import crypto from "crypto";
import { loadConfig, loadConfigRaw, loadAllConfigs, loadConfigRawForDir, listThemes, OVERRIDES_FILE } from "@styleguide-engine/config/loader";
import { generateCSS, generateCSSSections } from "@styleguide-engine/lib/css-gen";
import { generateJsxFiles } from "@styleguide-engine/lib/jsx-gen";

const CACHE_DIR = path.join(process.cwd(), ".cache");
const CACHE_PREFIX = "styles-";
const GENERATED_CSS_PATH = process.env.STYLEGUIDE_OUTPUT || path.join(process.cwd(), "src", "app", "design-system.generated.css");
const THEME_CSS_DIR = process.env.STYLEGUIDE_THEME_DIR || path.join(process.cwd(), "public", "themes");

function ensureCacheDir() {
  if (!fs.existsSync(CACHE_DIR)) {
    fs.mkdirSync(CACHE_DIR, { recursive: true });
  }
}

/** Compute a checksum from ALL themes' YAML source files */
function yamlChecksum(): string {
  const hash = crypto.createHash("sha256");
  const themes = listThemes();
  for (const theme of themes) {
    hash.update(`__theme__${theme.slug}`);
    const overridesFile = path.join(theme.dir, "style-guide.overrides.yaml");
    if (fs.existsSync(overridesFile)) {
      hash.update(fs.readFileSync(overridesFile, "utf-8"));
    }
    const files = loadConfigRawForDir(theme.dir);
    for (const f of files) {
      hash.update(f.name);
      hash.update(f.content);
    }
  }
  return hash.digest("hex").slice(0, 16);
}

function cachePath(checksum: string): string {
  return path.join(CACHE_DIR, `${CACHE_PREFIX}${checksum}.css`);
}

function purgeStale(currentChecksum: string) {
  try {
    const files = fs.readdirSync(CACHE_DIR).filter(
      (f) => f.startsWith(CACHE_PREFIX) && f.endsWith(".css")
    );
    for (const f of files) {
      if (!f.includes(currentChecksum)) {
        fs.unlinkSync(path.join(CACHE_DIR, f));
      }
    }
  } catch {
    // ignore cleanup errors
  }
}

/**
 * Load generated CSS with file-based caching.
 * Generates CSS for ALL discovered themes into one composite file.
 */
export function loadCachedCSS(): string {
  ensureCacheDir();
  const checksum = yamlChecksum();
  const file = cachePath(checksum);

  if (fs.existsSync(file)) {
    syncGeneratedFile(file);
    const config = loadConfig();
    generateJsxFiles(config);
    return fs.readFileSync(file, "utf-8");
  }

  // Cache miss — generate composite CSS for all themes
  const themes = listThemes();
  const allFiles: { name: string; content: string }[] = [];
  const themeSections: string[] = [];

  for (const theme of themes) {
    const themeFiles = loadConfigRawForDir(theme.dir);
    allFiles.push(...themeFiles.map((f) => ({ name: `${theme.slug}/${f.name}`, content: f.content })));

    try {
      const config = loadAllConfigs().find((c) => c.slug === theme.slug);
      if (!config) continue;
      const sections = generateCSSSections(config);
      // Sections already self-scoped (vars, scoped-vars) stay as-is.
      // All other sections get each selector prefixed with the theme selector.
      const SELF_SCOPED = new Set(["vars", "scoped-vars", "globals", "css-snippets"]);
      const themeSelector = `html[data-design-theme="${config.slug}"]`;
      const themeCSS = sections
        .map((s) => {
          const srcNote = s.sources?.length ? ` (from: ${s.sources.join(", ")})` : "";
          const header = `/* ── ${s.name.toUpperCase()} ──${srcNote} */`;
          if (!s.css.trim()) return `${header}\n/* (empty) */`;
          if (SELF_SCOPED.has(s.name)) return `${header}\n${s.css}`;
          // Prefix each top-level CSS rule selector with the theme selector
          // Skip @keyframes, @media, indented lines, and comment lines
          const scoped = scopeCSS(s.css, themeSelector);
          return `${header}\n${scoped}`;
        })
        .join("\n\n");
      themeSections.push(`/* ════════════════════════════════════\n * THEME: ${theme.name} (${theme.slug})\n * ════════════════════════════════════ */\n\n${themeCSS}`);

      // Write per-theme CSS file for lazy loading
      writePerThemeCSS(theme.slug, theme.name, themeCSS);
    } catch (e) {
      console.error(`[css-cache] Error generating theme "${theme.slug}":`, e);
    }
  }

  const maxName = Math.max(...allFiles.map((f) => f.name.length), 1);
  const sourceTable = allFiles
    .map((f) => {
      const fileHash = crypto.createHash("sha256").update(f.content).digest("hex").slice(0, 8);
      return ` * ${f.name.padEnd(maxName)}  ${fileHash}`;
    })
    .join("\n");
  const header = `/* design-system.generated.css\n * checksum: ${checksum}\n * themes: ${themes.map((t) => t.slug).join(", ")}\n * generated: ${new Date().toISOString()}\n *\n * sources:\n${sourceTable}\n */`;

  const css = [header, ...themeSections].join("\n\n");
  fs.writeFileSync(file, css, "utf-8");
  purgeStale(checksum);
  syncGeneratedFile(file);

  // Generate JSX files from primary theme
  const config = loadConfig();
  generateJsxFiles(config);

  return css;
}

const GLOBALS_CSS_PATH = path.join(process.cwd(), "src", "app", "globals.css");

function syncGeneratedFile(cacheFile: string) {
  const cached = fs.readFileSync(cacheFile, "utf-8");
  const existing = fs.existsSync(GENERATED_CSS_PATH)
    ? fs.readFileSync(GENERATED_CSS_PATH, "utf-8")
    : "";
  if (cached !== existing) {
    fs.writeFileSync(GENERATED_CSS_PATH, cached, "utf-8");
    const now = new Date();
    fs.utimesSync(GLOBALS_CSS_PATH, now, now);
  }
}

/**
 * Prefix all top-level CSS selectors with a theme scope selector.
 * Handles @keyframes (pass through), @media (recurse), and nested rules.
 */
function scopeCSS(css: string, themeSelector: string): string {
  const lines = css.split("\n");
  const result: string[] = [];
  let depth = 0;
  let inAtRule = false;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const trimmed = line.trim();

    // Track brace depth
    const opens = (line.match(/\{/g) || []).length;
    const closes = (line.match(/\}/g) || []).length;

    // Skip empty lines and comments
    if (!trimmed || trimmed.startsWith("/*") || trimmed.startsWith("*")) {
      result.push(line);
      depth += opens - closes;
      continue;
    }

    // @keyframes — pass through entirely (don't scope internal selectors)
    if (trimmed.startsWith("@keyframes")) {
      inAtRule = true;
      result.push(line);
      depth += opens - closes;
      continue;
    }

    if (inAtRule) {
      result.push(line);
      depth += opens - closes;
      if (depth <= 0) { inAtRule = false; depth = 0; }
      continue;
    }

    // Top-level selector (depth 0, contains {, doesn't start with @ or space or property)
    if (depth === 0 && trimmed.includes("{") && !trimmed.startsWith("@") && !trimmed.startsWith("}")) {
      // This is a selector line — prefix each comma-separated selector
      const selectorPart = trimmed.replace(/\s*\{.*$/, "");
      const bodyPart = trimmed.slice(trimmed.indexOf("{"));
      const prefixed = selectorPart
        .split(",")
        .map((sel) => `${themeSelector} ${sel.trim()}`)
        .join(",\n");
      result.push(`${prefixed} ${bodyPart}`);
    } else {
      result.push(line);
    }

    depth += opens - closes;
    if (depth < 0) depth = 0;
  }

  return result.join("\n");
}

/** Write a single theme's CSS to public/themes/{slug}.css for lazy loading */
function writePerThemeCSS(slug: string, name: string, themeCSS: string) {
  if (!fs.existsSync(THEME_CSS_DIR)) {
    fs.mkdirSync(THEME_CSS_DIR, { recursive: true });
  }
  const header = `/* theme: ${name} (${slug})\n * generated: ${new Date().toISOString()}\n * For lazy-loading via ThemeCSS component\n */`;
  const outPath = path.join(THEME_CSS_DIR, `${slug}.css`);
  const content = `${header}\n\n${themeCSS}`;
  const existing = fs.existsSync(outPath) ? fs.readFileSync(outPath, "utf-8") : "";
  if (content !== existing) {
    fs.writeFileSync(outPath, content, "utf-8");
  }
}

export function ensureGeneratedCSS(): string {
  loadCachedCSS();
  return GENERATED_CSS_PATH;
}
