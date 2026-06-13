/**
 * Watches YAML config files and regenerates design-system.generated.css on change.
 * Run alongside the dev server: npx tsx src/scripts/watch-yaml.ts
 *
 * Or use concurrently in package.json:
 *   "dev": "concurrently \"next dev\" \"tsx src/scripts/watch-yaml.ts\""
 */
import fs from "fs";
import path from "path";

const THEME_DIR = path.join(process.cwd(), "src", "config", "theme-style-guide");
const DEBOUNCE_MS = 300;

let timer: ReturnType<typeof setTimeout> | null = null;

function regenerate() {
  // Dynamic import to avoid caching stale config
  delete require.cache[require.resolve("../lib/css-cache")];
  delete require.cache[require.resolve("../config/loader")];
  delete require.cache[require.resolve("../lib/css-gen")];
  delete require.cache[require.resolve("../lib/normalizer")];

  const { ensureGeneratedCSS } = require("../lib/css-cache");
  const result = ensureGeneratedCSS();
  const now = new Date().toLocaleTimeString();
  console.log(`[${now}] Regenerated ${path.basename(result)}`);
}

// Initial generation
regenerate();

console.log(`Watching ${THEME_DIR} for YAML changes...`);
fs.watch(THEME_DIR, { recursive: false }, (_event, filename) => {
  if (!filename?.endsWith(".yaml")) return;
  if (timer) clearTimeout(timer);
  timer = setTimeout(() => {
    console.log(`[change] ${filename}`);
    regenerate();
  }, DEBOUNCE_MS);
});
