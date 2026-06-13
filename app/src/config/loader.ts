import fs from "fs";
import path from "path";
import yaml from "js-yaml";
import type { SimpleStyleGuideConfig, PageSectionGroup } from "@styleguide-engine/lib/types";
import { normalizeConfig } from "@styleguide-engine/lib/normalizer";
import type { StyleGuideConfig } from "@styleguide-engine/lib/types";

const CONFIG_ROOT = process.env.STYLEGUIDE_CONFIG_ROOT || path.join(process.cwd(), "src", "config");
export const THEME_DIR = path.join(CONFIG_ROOT, "theme-style-guide");
export const OVERRIDES_FILE = path.join(THEME_DIR, "style-guide.overrides.yaml");
export const BASE_THEME_DIR = THEME_DIR;

export interface ThemeInfo {
  slug: string;
  name: string;
  dir: string;
}

/** Discover all theme-* directories and return their metadata */
export function listThemes(): ThemeInfo[] {
  return fs.readdirSync(CONFIG_ROOT)
    .filter((d) => d.startsWith("theme-") && fs.statSync(path.join(CONFIG_ROOT, d)).isDirectory())
    .map((d) => {
      const dir = path.join(CONFIG_ROOT, d);
      const metaFile = path.join(dir, "style-guide.meta.yaml");
      if (!fs.existsSync(metaFile)) return null;
      const meta = yaml.load(fs.readFileSync(metaFile, "utf-8")) as { slug?: string; name?: string };
      return { slug: meta.slug || d.replace("theme-", ""), name: meta.name || d, dir };
    })
    .filter((t): t is ThemeInfo => t !== null);
}

/** Load config from a specific theme directory */
export function loadConfigForTheme(themeDir: string): StyleGuideConfig {
  const savedThemeDir = THEME_DIR;
  // Temporarily point internals at this theme dir
  (globalThis as Record<string, unknown>).__themeDir = themeDir;
  const result = loadConfigFromDir(themeDir);
  (globalThis as Record<string, unknown>).__themeDir = undefined;
  return result;
}

/** Load all themes' configs */
export function loadAllConfigs(): StyleGuideConfig[] {
  return listThemes().map((t) => loadConfigForTheme(t.dir));
}

export interface OverrideManifest {
  overrides: Record<string, string | null>;
}

/** Read the override manifest, or return empty if it doesn't exist */
export function loadOverrideManifest(): OverrideManifest {
  if (!fs.existsSync(OVERRIDES_FILE)) return { overrides: {} };
  try {
    const raw = fs.readFileSync(OVERRIDES_FILE, "utf-8");
    const parsed = yaml.load(raw) as Partial<OverrideManifest>;
    return { overrides: parsed?.overrides ?? {} };
  } catch {
    return { overrides: {} };
  }
}

/** Get all base subsection files (style-guide.{section}.yaml) */
function getBaseFiles(): string[] {
  return fs
    .readdirSync(THEME_DIR)
    .filter((f) => {
      if (!f.startsWith("style-guide.") || !f.endsWith(".yaml")) return false;
      if (f === "style-guide.overrides.yaml") return false;
      // Base files have exactly 3 dot-separated parts: style-guide.{section}.yaml
      const parts = f.replace(".yaml", "").split(".");
      return parts.length === 2; // "style-guide" + "{section}"
    })
    .sort();
}

/** Extract section name from base filename: style-guide.vars.yaml → vars */
function sectionOf(filename: string): string {
  return filename.replace("style-guide.", "").replace(".yaml", "");
}

/**
 * Resolve each base file to its override if one is active.
 * style-guide.vars.yaml + override "dark" → style-guide.vars.dark.yaml
 */
function resolveFiles(): string[] {
  const manifest = loadOverrideManifest();
  return getBaseFiles().map((base) => {
    const section = sectionOf(base);
    const variant = manifest.overrides[section];
    if (!variant) return base;
    const overrideFile = `style-guide.${section}.${variant}.yaml`;
    const overridePath = path.join(THEME_DIR, overrideFile);
    return fs.existsSync(overridePath) ? overrideFile : base;
  });
}

/** List all available variants for each section */
export function listVariants(): Record<string, string[]> {
  const files = fs.readdirSync(THEME_DIR).filter((f) =>
    f.startsWith("style-guide.") && f.endsWith(".yaml") && f !== "style-guide.overrides.yaml"
  );
  const result: Record<string, string[]> = {};
  for (const f of files) {
    const withoutExt = f.replace(".yaml", "").replace("style-guide.", "");
    const parts = withoutExt.split(".");
    if (parts.length === 2) {
      const [section, variant] = parts;
      if (!result[section]) result[section] = [];
      result[section].push(variant);
    }
  }
  return result;
}

/** Read the base-theme field from a theme's meta YAML, defaulting to BASE_THEME_DIR */
function resolveBaseThemeDir(themeDir: string): string | null {
  // If this IS the base theme, no fallback
  if (path.resolve(themeDir) === path.resolve(BASE_THEME_DIR)) return null;
  const metaFile = path.join(themeDir, "style-guide.meta.yaml");
  if (!fs.existsSync(metaFile)) return BASE_THEME_DIR;
  try {
    const meta = yaml.load(fs.readFileSync(metaFile, "utf-8")) as { "base-theme"?: string };
    const baseThemeName = meta?.["base-theme"] ?? "theme-style-guide";
    return path.join(CONFIG_ROOT, baseThemeName);
  } catch {
    return BASE_THEME_DIR;
  }
}

export function loadConfig(): StyleGuideConfig {
  return loadConfigFromDir(THEME_DIR);
}

function loadConfigFromDir(dir: string): StyleGuideConfig {
  const overridesFile = path.join(dir, "style-guide.overrides.yaml");
  const manifest: OverrideManifest = fs.existsSync(overridesFile)
    ? (() => { try { const p = yaml.load(fs.readFileSync(overridesFile, "utf-8")) as Partial<OverrideManifest>; return { overrides: p?.overrides ?? {} }; } catch { return { overrides: {} }; } })()
    : { overrides: {} };

  const ownBaseFiles = fs.readdirSync(dir)
    .filter((f) => f.startsWith("style-guide.") && f.endsWith(".yaml") && f !== "style-guide.overrides.yaml" && f.replace(".yaml", "").split(".").length === 2)
    .sort();

  // Build the set of sections this theme owns
  const ownSections = new Set(
    ownBaseFiles.map((f) => f.replace("style-guide.", "").replace(".yaml", ""))
  );

  // Collect fallback files from base theme for sections not in this theme
  const baseThemeDir = resolveBaseThemeDir(dir);
  const fallbackEntries: Array<{ file: string; dir: string }> = [];
  if (baseThemeDir && fs.existsSync(baseThemeDir)) {
    const baseFallbackFiles = fs.readdirSync(baseThemeDir)
      .filter((f) => f.startsWith("style-guide.") && f.endsWith(".yaml") && f !== "style-guide.overrides.yaml" && f.replace(".yaml", "").split(".").length === 2)
      .sort();
    for (const f of baseFallbackFiles) {
      const section = f.replace("style-guide.", "").replace(".yaml", "");
      if (!ownSections.has(section)) {
        fallbackEntries.push({ file: f, dir: baseThemeDir });
      }
    }
  }

  // Resolve overrides for own files, then append fallbacks
  const files: Array<{ file: string; dir: string }> = [
    ...ownBaseFiles.map((base) => {
      const section = base.replace("style-guide.", "").replace(".yaml", "");
      const variant = manifest.overrides[section];
      if (!variant) return { file: base, dir };
      const overrideFile = `style-guide.${section}.${variant}.yaml`;
      return { file: fs.existsSync(path.join(dir, overrideFile)) ? overrideFile : base, dir };
    }),
    ...fallbackEntries,
  ];

  // Collectors for mergeable YAML keys
  const allScopedVars: unknown[] = [];
  let scopedVarsConfig: Record<string, unknown> | null = null;
  const allCssSnippets: unknown[] = [];
  const allJsxSnippets: unknown[] = [];
  const allCssLoads: unknown[] = [];
  const allJsxLoads: unknown[] = [];

  const MERGEABLE_KEYS = [
    "scoped-vars", "scoped-vars-defaults",
    "css-snippets", "css-snippets-defaults",
    "jsx-snippets", "jsx-snippets-defaults",
    "css-load", "jsx-load",
  ];

  const merged = files.reduce((acc: Record<string, unknown>, entry: { file: string; dir: string }) => {
    const raw = fs.readFileSync(path.join(entry.dir, entry.file), "utf-8");
    const parsed = yaml.load(raw) as Record<string, unknown>;

    // ── Scoped vars ──
    const scopedDefaults = parsed["scoped-vars-defaults"] as
      | { section?: string; prefix?: string; selector?: string; "selector-body"?: string }
      | undefined;
    const fileVars = parsed["scoped-vars"];

    if (fileVars && typeof fileVars === "object" && !Array.isArray(fileVars)) {
      const cfg = fileVars as Record<string, unknown>;
      scopedVarsConfig = cfg;
      const centralVars = (cfg.vars as unknown[]) || [];
      if (scopedDefaults) {
        for (const v of centralVars) applyFileDefaults(v as Record<string, unknown>, scopedDefaults);
      }
      allScopedVars.push(...centralVars);
    } else if (Array.isArray(fileVars)) {
      for (const v of fileVars) {
        if (scopedDefaults) applyFileDefaults(v as Record<string, unknown>, scopedDefaults);
        allScopedVars.push(v);
      }
    }

    // ── CSS snippets ──
    const cssDefaults = parsed["css-snippets-defaults"] as { "target-section"?: string } | undefined;
    const cssSnippets = parsed["css-snippets"];
    if (Array.isArray(cssSnippets)) {
      for (const s of cssSnippets) {
        const snippet = s as Record<string, unknown>;
        if (cssDefaults?.["target-section"] && !snippet["target-section"]) {
          snippet["target-section"] = cssDefaults["target-section"];
        }
        allCssSnippets.push(snippet);
      }
    }

    // ── JSX snippets ──
    const jsxDefaults = parsed["jsx-snippets-defaults"] as { "target-section"?: string; imports?: string[] } | undefined;
    const jsxSnippets = parsed["jsx-snippets"];
    if (Array.isArray(jsxSnippets)) {
      for (const s of jsxSnippets) {
        const snippet = s as Record<string, unknown>;
        if (jsxDefaults?.["target-section"] && !snippet["target-section"]) {
          snippet["target-section"] = jsxDefaults["target-section"];
        }
        allJsxSnippets.push(snippet);
      }
    }

    // ── File loaders ──
    if (Array.isArray(parsed["css-load"])) allCssLoads.push(...(parsed["css-load"] as unknown[]));
    if (Array.isArray(parsed["jsx-load"])) allJsxLoads.push(...(parsed["jsx-load"] as unknown[]));

    // Remove mergeable keys before Object.assign
    for (const key of MERGEABLE_KEYS) delete parsed[key];

    return Object.assign(acc, parsed);
  }, {});

  // Reassemble merged collections
  if (scopedVarsConfig || allScopedVars.length > 0) {
    const base = (scopedVarsConfig || {}) as Record<string, unknown>;
    base.vars = allScopedVars;
    (merged as Record<string, unknown>)["scoped-vars"] = base;
  }
  if (allCssSnippets.length) (merged as Record<string, unknown>)["css-snippets"] = allCssSnippets;
  if (allJsxSnippets.length) (merged as Record<string, unknown>)["jsx-snippets"] = allJsxSnippets;
  if (allCssLoads.length) (merged as Record<string, unknown>)["css-load"] = allCssLoads;
  if (allJsxLoads.length) (merged as Record<string, unknown>)["jsx-load"] = allJsxLoads;

  return normalizeConfig(merged as unknown as SimpleStyleGuideConfig, dir);
}

function applyFileDefaults(
  v: Record<string, unknown>,
  defaults: { section?: string; prefix?: string; selector?: string; "selector-body"?: string },
) {
  if (defaults.selector && !v.selector) v.selector = defaults.selector;
  if (defaults["selector-body"] && !v["selector-body"]) v["selector-body"] = defaults["selector-body"];
  // If value is a string (simple var) and a default section is specified,
  // wrap it in a sectioned entry so it lands in the right section
  if (defaults.section && typeof v.value === "string" && !Array.isArray(v.value)) {
    v.value = [{ section: defaults.section, value: v.value }];
  }
}

export function loadConfigRaw(): { name: string; content: string }[] {
  return loadConfigRawForDir(THEME_DIR);
}

export function loadConfigRawForDir(dir: string): { name: string; content: string; fallback?: boolean }[] {
  const overridesFile = path.join(dir, "style-guide.overrides.yaml");
  const manifest: OverrideManifest = fs.existsSync(overridesFile)
    ? (() => { try { const p = yaml.load(fs.readFileSync(overridesFile, "utf-8")) as Partial<OverrideManifest>; return { overrides: p?.overrides ?? {} }; } catch { return { overrides: {} }; } })()
    : { overrides: {} };

  const ownBaseFiles = fs.readdirSync(dir)
    .filter((f) => f.startsWith("style-guide.") && f.endsWith(".yaml") && f !== "style-guide.overrides.yaml" && f.replace(".yaml", "").split(".").length === 2)
    .sort();

  const ownSections = new Set(
    ownBaseFiles.map((f) => f.replace("style-guide.", "").replace(".yaml", ""))
  );

  const resolved: Array<{ file: string; dir: string; fallback: boolean }> = ownBaseFiles.map((base) => {
    const section = base.replace("style-guide.", "").replace(".yaml", "");
    const variant = manifest.overrides[section];
    if (!variant) return { file: base, dir, fallback: false };
    const overrideFile = `style-guide.${section}.${variant}.yaml`;
    return { file: fs.existsSync(path.join(dir, overrideFile)) ? overrideFile : base, dir, fallback: false };
  });

  const baseThemeDir = resolveBaseThemeDir(dir);
  if (baseThemeDir && fs.existsSync(baseThemeDir)) {
    const baseFallbackFiles = fs.readdirSync(baseThemeDir)
      .filter((f) => f.startsWith("style-guide.") && f.endsWith(".yaml") && f !== "style-guide.overrides.yaml" && f.replace(".yaml", "").split(".").length === 2)
      .sort();
    for (const f of baseFallbackFiles) {
      const section = f.replace("style-guide.", "").replace(".yaml", "");
      if (!ownSections.has(section)) {
        resolved.push({ file: f, dir: baseThemeDir, fallback: true });
      }
    }
  }

  return resolved.map(({ file, dir: fileDir, fallback }) => ({
    name: file,
    content: fs.readFileSync(path.join(fileDir, file), "utf-8"),
    ...(fallback ? { fallback: true } : {}),
  }));
}

export function loadPageSections(themeDir?: string): PageSectionGroup[] {
  const file = path.join(themeDir || THEME_DIR, "style-guide.page-sections.yaml");
  if (!fs.existsSync(file)) return loadPageSections(THEME_DIR); // fallback to primary
  const raw = fs.readFileSync(file, "utf-8");
  const parsed = yaml.load(raw) as { "page-sections": PageSectionGroup[] };
  return parsed["page-sections"];
}

/** Load page sections for all themes, keyed by slug */
export function loadAllPageSections(): Record<string, PageSectionGroup[]> {
  const result: Record<string, PageSectionGroup[]> = {};
  for (const theme of listThemes()) {
    result[theme.slug] = loadPageSections(theme.dir);
  }
  return result;
}
