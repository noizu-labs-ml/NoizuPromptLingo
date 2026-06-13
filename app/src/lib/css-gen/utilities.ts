import type { StyleGuideConfig } from "../types";
import { resolveDefaults } from "./defaults";

const TEXT_PROPS: Record<string, string> = {
  color: "color",
  "font-family": "font-family",
  "font-weight": "font-weight",
  "font-size": "font-size",
  "font-style": "font-style",
  "letter-spacing": "letter-spacing",
  "text-transform": "text-transform",
};

// font-size and color excluded from buttons to avoid layout breaks
const BTN_TEXT_PROPS = Object.fromEntries(
  Object.entries(TEXT_PROPS).filter(([k]) => k !== "color" && k !== "font-size")
);

function isColorValue(v: string): boolean {
  return v.startsWith("#") || v.startsWith("rgb") || v.startsWith("color-mix") || v.startsWith("var(");
}

function hexToRgb(hex: string): [number, number, number] {
  const h = hex.replace("#", "");
  const n = parseInt(h.length === 3 ? h.split("").map(c => c + c).join("") : h, 16);
  return [(n >> 16) & 255, (n >> 8) & 255, n & 255];
}

/** Approximate color-mix(in srgb, color 75%, white) for dark mode accent */
function brightenForDark(hex: string): string {
  const [r, g, b] = hexToRgb(hex);
  const mix = (c: number) => Math.round(c * 0.75 + 255 * 0.25);
  return `#${[mix(r), mix(g), mix(b)].map(c => c.toString(16).padStart(2, "0")).join("")}`;
}

/** Compute whether white or black text is more readable on a given color */
function contrastText(value: string): string {
  let r = 128, g = 128, b = 128;
  if (value.startsWith("#") && value.length >= 7) {
    r = parseInt(value.slice(1, 3), 16);
    g = parseInt(value.slice(3, 5), 16);
    b = parseInt(value.slice(5, 7), 16);
  } else {
    const m = value.match(/rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/);
    if (m) { r = +m[1]; g = +m[2]; b = +m[3]; }
  }
  // Approximate color-mix(in srgb, #hex pct%, ...) by mixing hex with white
  const cm = value.match(/color-mix\(\s*in\s+srgb\s*,\s*(#[0-9a-fA-F]{6})\s+(\d+)%/);
  if (cm) {
    const [cr, cg, cb] = hexToRgb(cm[1]);
    const pct = parseInt(cm[2]) / 100;
    // Assume mixing with white (surface in light mode)
    r = Math.round(cr * pct + 255 * (1 - pct));
    g = Math.round(cg * pct + 255 * (1 - pct));
    b = Math.round(cb * pct + 255 * (1 - pct));
  }
  // W3C relative luminance threshold
  return (r * 0.299 + g * 0.587 + b * 0.114) > 150 ? "var(--black)" : "var(--white)";
}

/** Generate all color utility variants for a given name→var mapping */
function colorVariants(name: string, varRef: string, textOnColor: string, darkTextOnColor?: string): string {
  const rules = [
    `.color-${name} { color: ${varRef}; }`,
    `.bg-${name} { background: ${varRef}; }`,
    `.text-on-${name} { color: ${textOnColor}; }`,
    `.border-${name} { border-color: ${varRef}; }`,
    `.ring-${name} { --ring-color: ${varRef}; box-shadow: 0 0 0 var(--ring-width, 3px) var(--ring-color); }`,
    `.outline-${name} { outline-color: ${varRef}; }`,
    `.accent-${name} { accent-color: ${varRef}; }`,
  ];
  if (darkTextOnColor && darkTextOnColor !== textOnColor) {
    rules.push(`.dark .text-on-${name} { color: ${darkTextOnColor}; }`);
  }
  return rules.join("\n");
}

export function generateUtilityCSS(config: StyleGuideConfig): string {
  const textUtils = config.semanticClasses
    .map((sc) => {
      const declarations = sc.vars
        .filter((v) => v.name in TEXT_PROPS)
        .map((v) => `  ${TEXT_PROPS[v.name]}: var(--semantic-${sc.name}-${v.name});`)
        .join("\n");

      const btnDeclarations = sc.vars
        .filter((v) => v.name in BTN_TEXT_PROPS)
        .map((v) => `  ${BTN_TEXT_PROPS[v.name]}: var(--semantic-${sc.name}-${v.name});`)
        .join("\n");

      const parts = [`.text-${sc.class} {\n${declarations}\n}`];
      if (btnDeclarations) {
        parts.push(`.btn.text-${sc.class} {\n${btnDeclarations}\n}`);
      }
      return parts.join("\n");
    })
    .join("\n");

  // Full color variants for every color var
  const seen = new Set<string>();
  const varColorUtils = config.vars.groups
    .flatMap((g) => g.vars)
    .filter((v) => isColorValue(v.value))
    .map((v) => {
      seen.add(v.name);
      return colorVariants(v.name, `var(--${v.name})`, contrastText(v.value));
    })
    .join("\n");

  // Full color variants for semantic classes (skip if already covered by a raw var)
  // Compute text-on contrast for BOTH light and dark mode
  const semanticColorUtils = config.semanticClasses
    .filter((sc) => !seen.has(sc.class))
    .map((sc) => {
      const accentVar = sc.vars.find((v) => v.name === "accent");
      const resolved = accentVar ? config.flatVars[accentVar.value.replace(/var\(--/, "").replace(/\)/, "")] : undefined;
      const lightTextOn = resolved ? contrastText(resolved) : "var(--white)";
      // Dark mode accent is color-mix(accent 75%, white) — approximate it
      const darkAccent = resolved && isColorValue(resolved) ? brightenForDark(resolved) : undefined;
      const darkTextOn = darkAccent ? contrastText(darkAccent) : lightTextOn;
      return colorVariants(sc.class, `var(--semantic-${sc.name}-accent)`, lightTextOn, darkTextOn);
    })
    .join("\n");

  // Color variants for foundation vars (slate-*, semantic surfaces)
  // Merge resolved defaults + color mode light values for full lookup
  const allResolved = resolveDefaults(config.flatVars);
  if (config.colorModes) {
    for (const [k, v] of Object.entries(config.colorModes.light)) {
      allResolved[k] = v;
    }
  }

  // Helper: chase var() refs to a concrete value
  function resolveValue(startValue: string, lookup: Record<string, string>): string {
    let v = startValue;
    for (let i = 0; i < 5 && v.startsWith("var(--"); i++) {
      const key = v.replace(/^var\(--/, "").replace(/\)$/, "");
      v = lookup[key] || v;
    }
    return v;
  }

  // Also build a dark-mode lookup for semantic surface tokens
  const darkResolved = { ...allResolved };
  if (config.colorModes) {
    for (const [k, v] of Object.entries(config.colorModes.dark)) {
      darkResolved[k] = v;
    }
  }

  // Gather ALL resolved vars that look like colors and weren't already emitted from YAML groups
  const foundationColorNames = Object.keys(allResolved).filter((name) => {
    if (seen.has(name)) return false;
    const resolved = resolveValue(allResolved[name] || "", allResolved);
    // Include if it's a hex color, color-mix, rgba, or a known color var name pattern
    return isColorValue(resolved)
      || resolved.startsWith("color-mix(")
      || resolved.startsWith("rgba(")
      || name.startsWith("slate-")
      || name.startsWith("gray-")
      || name.startsWith("brand-")
      || name === "white" || name === "black" || name === "off-white"
      || name.endsWith("-light") || name.endsWith("-mid") || name.endsWith("-tint");
  });
  // Also add color-mode keys not yet covered
  if (config.colorModes) {
    for (const name of Object.keys(config.colorModes.light)) {
      if (!seen.has(name) && !foundationColorNames.includes(name)) {
        foundationColorNames.push(name);
      }
    }
  }
  const foundationColorUtils = foundationColorNames
    .filter((name) => !seen.has(name))
    .map((name) => {
      seen.add(name);
      const varRef = `var(--${name})`;

      // Light mode contrast
      const lightValue = resolveValue(allResolved[name] || "", allResolved);
      const lightTextOn = isColorValue(lightValue) ? contrastText(lightValue) : "var(--text)";

      // Dark mode contrast (semantic surfaces resolve differently in dark)
      const darkValue = resolveValue(darkResolved[name] || "", darkResolved);
      const darkTextOn = isColorValue(darkValue) ? contrastText(darkValue) : "var(--text)";

      return colorVariants(name, varRef, lightTextOn, darkTextOn);
    })
    .join("\n");

  return [
    textUtils,
    `/* ─── Color & Background Utilities ─── */`,
    varColorUtils,
    semanticColorUtils,
    foundationColorUtils,
  ].filter(Boolean).join("\n\n");
}
