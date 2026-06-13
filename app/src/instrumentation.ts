/**
 * Next.js instrumentation hook — runs once on server startup.
 * Generates the design-system CSS and watches YAML for changes in dev.
 */
export async function register() {
  if (process.env.NEXT_RUNTIME === "nodejs") {
    const fs = await import("fs");
    const path = await import("path");
    const { ensureGeneratedCSS } = await import("@/lib/css-cache");

    // Generate on startup
    ensureGeneratedCSS();

    // In dev, watch YAML files and regenerate on change
    if (process.env.NODE_ENV === "development") {
      const CONFIG_ROOT = process.env.STYLEGUIDE_CONFIG_ROOT || path.join(process.cwd(), "src", "config");
      const THEME_DIR = path.join(CONFIG_ROOT, "theme-style-guide");
      let timer: ReturnType<typeof setTimeout> | null = null;

      fs.watch(THEME_DIR, { recursive: false }, (_event, filename) => {
        if (!filename?.endsWith(".yaml")) return;
        if (timer) clearTimeout(timer);
        timer = setTimeout(() => {
          try {
            // Clear module cache so fresh YAML is loaded
            Object.keys(require.cache).forEach((key) => {
              if (key.includes("css-cache") || key.includes("loader") || key.includes("css-gen") || key.includes("normalizer")) {
                delete require.cache[key];
              }
            });
            const { ensureGeneratedCSS: regen } = require("@/lib/css-cache");
            regen();
            console.log(`[yaml-watch] Regenerated CSS (${filename} changed)`);
          } catch (e) {
            console.error(`[yaml-watch] Error regenerating CSS:`, e);
          }
        }, 300);
      });

      console.log(`[yaml-watch] Watching ${THEME_DIR} for changes`);
    }
  }
}
