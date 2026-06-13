/**
 * Pre-build script: generates design-system.generated.css from YAML config.
 * Run before `next build` or anytime to refresh the CSS.
 *
 * Usage: npx tsx src/scripts/generate-css.ts
 */
import { ensureGeneratedCSS } from "../lib/css-cache";

const path = ensureGeneratedCSS();
console.log(`Generated: ${path}`);
