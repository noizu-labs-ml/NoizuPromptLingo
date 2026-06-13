/**
 * Standalone CSS generation entry point.
 * Uses absolute paths to engine source — no @/ alias needed.
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function main() {
  // In dev (engine repo): __dirname = .../app/pkg/src → ../../src = .../app/src
  // Published (npm):      __dirname = .../styleguide/src → ../dist/engine-src
  const devPath = path.resolve(__dirname, "../../src");
  const pubPath = path.resolve(__dirname, "../dist/engine-src");
  const ENGINE_SRC = fs.existsSync(path.join(pubPath, "config")) ? pubPath : devPath;

  const { listThemes, loadAllConfigs } = await import(path.join(ENGINE_SRC, "config", "loader.ts"));
  const { generateCSSSections } = await import(path.join(ENGINE_SRC, "lib", "css-gen", "index.ts"));

  const OUTPUT = process.env.STYLEGUIDE_OUTPUT || path.join(process.cwd(), "src", "app", "design-system.generated.css");
  const THEME_CSS_DIR = process.env.STYLEGUIDE_THEME_DIR || path.join(path.dirname(OUTPUT), "..", "..", "public", "themes");
  const SELF_SCOPED = new Set(["vars", "scoped-vars", "globals", "css-snippets"]);

  fs.mkdirSync(THEME_CSS_DIR, { recursive: true });
  fs.mkdirSync(path.dirname(OUTPUT), { recursive: true });

  const themes = listThemes();
  const allConfigs = loadAllConfigs();
  const themeSections: string[] = [];

  for (const theme of themes) {
    const config = allConfigs.find((c: any) => c.slug === theme.slug);
    if (!config) continue;

    const sections = generateCSSSections(config);
    const themeSelector = `html[data-design-theme="${config.slug}"]`;

    const themeCSS = sections
      .map((s: any) => {
        const header = `/* ── ${s.name.toUpperCase()} ── */`;
        if (!s.css.trim()) return `${header}\n/* (empty) */`;
        if (SELF_SCOPED.has(s.name)) return `${header}\n${s.css}`;
        return `${header}\n${scopeCSS(s.css, themeSelector)}`;
      })
      .join("\n\n");

    themeSections.push(
      `/* ═══════════════════════════════\n * THEME: ${theme.name} (${theme.slug})\n * ═══════════════════════════════ */\n\n${themeCSS}`
    );

    fs.writeFileSync(path.join(THEME_CSS_DIR, `${theme.slug}.css`), themeCSS, "utf-8");
  }

  const header = `/* design-system.generated.css\n * themes: ${themes.map((t: any) => t.slug).join(", ")}\n * generated: ${new Date().toISOString()}\n */`;
  const css = [header, ...themeSections].join("\n\n");

  fs.writeFileSync(OUTPUT, css, "utf-8");
  console.log(`Generated: ${OUTPUT}`);
  console.log(`  Themes: ${themes.map((t: any) => t.slug).join(", ")}`);
  console.log(`  Per-theme CSS: ${THEME_CSS_DIR}/`);
}

/** Prefix top-level CSS selectors with a theme scope. From engine css-cache.ts. */
function scopeCSS(css: string, themeSelector: string): string {
  const lines = css.split("\n");
  const result: string[] = [];
  let depth = 0;
  let inAtRule = false;

  for (const line of lines) {
    const trimmed = line.trim();
    const opens = (line.match(/\{/g) || []).length;
    const closes = (line.match(/\}/g) || []).length;

    if (!trimmed || trimmed.startsWith("/*") || trimmed.startsWith("*")) {
      result.push(line);
      depth += opens - closes;
      continue;
    }

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

    if (depth === 0 && trimmed.includes("{") && !trimmed.startsWith("@") && !trimmed.startsWith("}")) {
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

main().catch((e) => { console.error(e); process.exit(1); });
