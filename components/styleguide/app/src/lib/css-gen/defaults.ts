// ═══════════════════════════════════════════════════════════════
// CSS Variable Cascade — Multi-Pass Builder
//
// An agent only needs to set ~10-15 seed values to get a complete
// theme. Each level builds on the previous:
//
//   Seeds (unit, font-size-base, colors)
//     → Level 1: Full base tokens (spacing scale, font scale, gray ramp, color variants)
//     → Level 2: Component foundations (micro-label, transitions, borders, etc.)
//     → Level 3: Component properties (card-*, btn-*, field-*, etc.)
//     → YAML overrides win at every level
// ═══════════════════════════════════════════════════════════════

// ─── Color helpers ───

function hexToRgb(hex: string): [number, number, number] {
  const h = hex.replace("#", "");
  const n = parseInt(h.length === 3 ? h.split("").map(c => c + c).join("") : h, 16);
  return [(n >> 16) & 255, (n >> 8) & 255, n & 255];
}

function rgbToHex(r: number, g: number, b: number): string {
  return "#" + [r, g, b].map(c => Math.round(c).toString(16).padStart(2, "0")).join("");
}

function lerp(a: number, b: number, t: number): number {
  return a + (b - a) * t;
}

function lerpColor(hex1: string, hex2: string, t: number): string {
  const [r1, g1, b1] = hexToRgb(hex1);
  const [r2, g2, b2] = hexToRgb(hex2);
  return rgbToHex(lerp(r1, r2, t), lerp(g1, g2, t), lerp(b1, b2, t));
}

function hexToRgba(hex: string, alpha: number): string {
  const [r, g, b] = hexToRgb(hex);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

// ─── Level 1: Build base tokens from seeds ───
//
// Seeds an agent can provide (all optional, sane defaults):
//   unit            → spacing scale multiplier (default: 8)
//   font-size-base  → type scale anchor (default: 16)
//   font-sans       → primary font stack
//   font-mono       → code font stack
//   radius          → default border radius (default: 2)
//   white, black    → surface endpoints → gray ramp
//   red, blue, yellow → primaries → light/mid variants
//   success, warning, error, info → semantics → bg variants

function buildBaseTokens(seed: Record<string, string>): Record<string, string> {
  const vars: Record<string, string> = {};

  // ── Spacing scale from unit ──
  // Computed values match YAML → emit directly. Where they disagree, emit
  // {name}-lerp with computed value and {name} with YAML value + TODO comment.
  const unit = parseInt(seed.unit || seed["space-1"] || "8") || 8;
  vars["unit"] = `${unit}px`;
  vars["radius"] = seed.radius || "2px";

  // Helper: set var, only add -lerp indirection if yamlVal disagrees
  function setVar(name: string, computed: string, yamlVal?: string) {
    if (yamlVal && yamlVal !== computed) {
      vars[`${name}-lerp`] = computed;
      vars[name] = yamlVal; // TODO: patch lerp logic to match YAML
    } else {
      vars[name] = computed;
    }
  }

  setVar("space-half", `${unit / 2}px`, seed["space-half"]);
  setVar("col-gap", `${unit * 2}px`, seed["col-gap"]);

  const spacingMultipliers: Record<string, number> = {
    "space-1": 1, "space-2": 2, "space-3": 3, "space-4": 4,
    "space-5": 5, "space-6": 6, "space-7": 7, "space-8": 8,
    "space-9": 9, "space-10": 10, "space-11": 11, "space-12": 12,
    "space-15": 15, "space-16": 16, "space-18": 18, "space-20": 20,
    "space-25": 25, "space-30": 30, "space-32": 32, "space-35": 35,
    "space-37": 37, "space-48": 48, "space-52": 52, "space-60": 60,
    "space-64": 64, "space-80": 80, "space-90": 90, "space-96": 96,
    "space-108": 108, "space-112": 112, "space-128": 128, "space-144": 144,
    "space-150": 150, "space-160": 160,
  };
  for (const [name, mult] of Object.entries(spacingMultipliers)) {
    vars[name] = `${unit * mult}px`;
  }

  // Mid-point spacings
  setVar("space-0-mid", `${unit / 2}px`, seed["space-0-mid"]);
  setVar("space-quarter", `${unit / 4}px`, seed["space-quarter"]);
  vars["space-1-mid"] = `${Math.round(unit * 1.5)}px`;
  vars["space-2-mid"] = `${Math.round(unit * 2.5)}px`;
  vars["space-4-mid"] = `${Math.round(unit * 4.5)}px`;
  vars["space-5-mid"] = `${Math.round(unit * 5.5)}px`;
  vars["space-7-mid"] = `${Math.round(unit * 7.5)}px`;
  vars["space-32-mid"] = `${Math.round(unit * 32.5)}px`;
  vars["space-37-mid"] = `${Math.round(unit * 37.5)}px`;
  vars["space-52-mid"] = `${Math.round(unit * 52.5)}px`;

  // Border size tokens (absolute, not derived from unit)
  vars["size-border-thin"] = "1px";
  vars["size-border-thick"] = "2px";
  vars["size-border-heavy"] = "3px";
  vars["size-border-extra-heavy"] = "4px";
  vars["size-border-medium"] = "1.5px";
  vars["size-border-accent"] = "5px";

  // Component size tokens
  setVar("size-lg", `${Math.round(unit * 2.5)}px`, seed["size-lg"]);
  setVar("size-md-sm", `${Math.round(unit * 1.75)}px`, seed["size-md-sm"]);
  setVar("size-2xs", `${Math.round(unit * 1.25)}px`, seed["size-2xs"]);
  vars["size-space-1-mid"] = `${Math.round(unit * 1.5)}px`;
  vars["size-space-2"] = `${Math.round(unit * 2)}px`;
  vars["size-space-2-qtr"] = `${Math.round(unit * 2.25)}px`;

  // ── Font size scale from base ──
  const base = parseInt(seed["font-size-base"] || "16") || 16;
  // Ratios relative to base that produce a harmonious scale
  const fontScale: Record<string, number> = {
    "font-size-xs": 0.6875,   // 11/16
    "font-size-sm": 0.8125,   // 13/16
    "font-size-md": 1,        // 16/16
    "font-size-lg": 1.25,     // 20/16
    "font-size-xl": 1.5,      // 24/16
    "font-size-2xl": 2,       // 32/16
    "font-size-3xl": 2.5,     // 40/16
    "font-size-display": 3.5, // 56/16
  };
  // Font-size: YAML uses var(--size-*) indirection, lerp computes px
  vars["line-height-base"] = seed["line-height-base"] || "1.5";
  const fontYaml: Record<string, string> = {
    "font-size-base": "var(--size-md)",
    "font-size-xs": "var(--size-xs)", "font-size-sm": "var(--size-sm)",
    "font-size-md": "var(--size-md)", "font-size-lg": "var(--size-lg)",
    "font-size-xl": "var(--size-xl)", "font-size-2xl": "var(--space-4)",
    "font-size-3xl": "var(--space-5)", "font-size-display": "var(--space-7)",
  };
  setVar("font-size-base", `${base}px`, fontYaml["font-size-base"]);
  for (const [name, ratio] of Object.entries(fontScale)) {
    setVar(name, `${Math.round(base * ratio)}px`, fontYaml[name]);
  }

  // Font-derived size tokens
  setVar("size-xs", `${Math.round(base * 0.6875)}px`, seed["size-xs"]);
  setVar("size-sm", `${Math.round(base * 0.8125)}px`, seed["size-sm"]);
  setVar("size-md", `${base}px`, seed["size-md"]);
  setVar("size-xl", `${Math.round(base * 1.5)}px`, seed["size-xl"]);

  // ── Font stacks ──
  vars["font-sans"] = seed["font-sans"] || "'Space Grotesk', -apple-system, sans-serif";
  vars["font-mono"] = seed["font-mono"] || "'IBM Plex Mono', 'Menlo', monospace";

  // ── Surface ramp from white/black ──
  const white = seed.white || "#ffffff";
  const black = seed.black || "#000000";
  vars["white"] = white;
  vars["black"] = black;
  setVar("off-white", lerpColor(white, black, 0.02), seed["off-white"]);
  // Gray ramp: interpolate between white and black
  const grayStops: Record<string, number> = {
    "gray-50": 0.04, "gray-100": 0.07, "gray-200": 0.12, "gray-300": 0.26,
    "gray-400": 0.38, "gray-500": 0.54, "gray-600": 0.62, "gray-700": 0.74,
    "gray-800": 0.87, "gray-900": 0.93,
  };
  // Gray ramp: lerp is computed value; seed/YAML value wins if it differs.
  for (const [name, t] of Object.entries(grayStops)) {
    const computed = lerpColor(white, black, t);
    setVar(name, computed, seed[name]);
  }

  // ── Slate ramp: blue-tinted neutrals for surfaces ──
  // Use Tailwind's actual slate values as defaults, seed-overridable
  const SLATE_DEFAULTS: Record<string, string> = {
    "slate-50": "#f8fafc",
    "slate-100": "#f1f5f9",
    "slate-200": "#e2e8f0",
    "slate-300": "#cbd5e1",
    "slate-400": "#94a3b8",
    "slate-500": "#64748b",
    "slate-600": "#475569",
    "slate-700": "#334155",
    "slate-800": "#1e293b",
    "slate-900": "#0f172a",
    "slate-950": "#020617",
  };
  for (const [name, defaultVal] of Object.entries(SLATE_DEFAULTS)) {
    vars[name] = seed[name] || defaultVal;
  }

  // ── Primary colors + light/mid variants ──
  const primaries: Record<string, { light: number; mid: number }> = {
    "brand-red":    { light: 0.12, mid: 0.2 },
    "brand-blue":   { light: 0.12, mid: 0.2 },
    "brand-yellow": { light: 0.18, mid: 0.35 },
  };
  for (const [name, pcts] of Object.entries(primaries)) {
    const bare = name.replace("brand-", "") as "red" | "blue" | "yellow";
    const hex = seed[name] || seed[bare] || (bare === "red" ? "#e20613" : bare === "blue" ? "#0047ab" : "#f5c518");
    vars[name] = hex;
    // Use color-mix with surface (opaque) not rgba (transparent)
    const lightPct = Math.round(pcts.light * 100);
    const midPct = Math.round(pcts.mid * 100);
    vars[`${name}-light`] = seed[`${name}-light`] || seed[`${bare}-light`] || `color-mix(in srgb, ${hex} ${lightPct}%, var(--surface))`;
    vars[`${name}-mid`] = seed[`${name}-mid`] || seed[`${bare}-mid`] || `color-mix(in srgb, ${hex} ${midPct}%, var(--surface))`;
  }

  // ── Palette colors (extended utility) ──
  // Defaults ensure semantic aliases resolve even in minimal themes without full YAML.
  const paletteDefaults: Record<string, string> = {
    rose:    "#e11d48",
    orange:  "#ea580c",
    amber:   "#d97706",
    lime:    "#65a30d",
    emerald: "#059669",
    teal:    "#0d9488",
    cyan:    "#0891b2",
    sky:     "#0284c7",
    indigo:  "#4f46e5",
    violet:  "#7c3aed",
    purple:  "#9333ea",
    fuchsia: "#c026d3",
    pink:    "#db2777",
  };
  for (const [name, defaultHex] of Object.entries(paletteDefaults)) {
    vars[name] = seed[name] || defaultHex;
    vars[`${name}-light`] = seed[`${name}-light`] || `color-mix(in srgb, var(--${name}) 12%, var(--surface))`;
  }

  // ── Semantic colors + tint variants ──
  // Aliases into palette/brand — not fixed hex. Tints use color-mix with surface.
  const semanticAliases: Record<string, string> = {
    success: "var(--emerald)",
    warning: "var(--amber)",
    error:   "var(--rose)",
    info:    "var(--brand-blue)",
  };
  for (const [name, defaultAlias] of Object.entries(semanticAliases)) {
    vars[name] = seed[name] || defaultAlias;
    vars[`${name}-tint`] = seed[`${name}-tint`] || `color-mix(in srgb, var(--${name}) 12%, var(--surface))`;
  }

  // ── Base aliases ──
  vars["base-font-family"] = "var(--font-sans)";
  vars["base-font-color"] = "var(--text)";
  vars["base-background"] = "var(--surface)";
  vars["base-line-height"] = "var(--line-height-base)";
  vars["base-font-size"] = "var(--font-size-base)";

  return vars;
}

// ─── Level 2: Component Foundations ───
// Shared visual patterns used across multiple generators.
// These reference Level 1 tokens via var() — changes cascade automatically.

const LEVEL_2: Record<string, string> = {
  // Micro label — mono, small, bold, uppercase (forms, spacing, sections, indicators, branding)
  "micro-label-font-family": "var(--font-mono)",
  "micro-label-font-size": "var(--font-size-xs)",
  "micro-label-font-weight": "var(--font-weight-bold)",
  "micro-label-letter-spacing": "var(--letter-spacing-wider)",
  "micro-label-text-transform": "uppercase",
  "micro-label-color": "var(--gray-500)",

  // Font weights
  "font-weight-normal": "400",
  "font-weight-medium": "500",
  "font-weight-semibold": "600",
  "font-weight-bold": "700",

  // Line heights
  "line-height-tight": "1.3",
  "line-height-normal": "1.5",
  "line-height-relaxed": "1.6",

  // Transitions
  "transition-fast": "0.1s",
  "transition-base": "0.15s",
  "transition-slow": "0.3s",

  // Radius scale
  "radius-none": "0%",
  "radius-sm": "5%",
  "radius-lg": "25%",
  "radius-xl": "50%",
  "radius-circle": "50%",

  // System constants
  "z-chrome": "300",
  "z-panel": "200",
  "z-dropdown": "50",
  "z-overlay": "100",
  "z-dialog": "101",
  "z-floating": "90",
  "on-semantic-color": "var(--white)",

  // Overlay colors
  "overlay-highlight": "rgba(255,255,255,0.22)",
  "overlay-shadow": "rgba(0,0,0,0.18)",
  "overlay-backdrop": "rgba(0,0,0,0.4)",

  // Border widths
  "border-thin": "var(--size-border-thin)",
  "border-thick": "var(--size-border-thick)",
  "border-heavy": "var(--size-border-heavy)",

  // Divider heights
  "hr-height": "var(--border-thin)",
  "hr-thick": "var(--border-thick)",
  "hr-heavy": "var(--border-heavy)",

  // Radius scale
  "radius-md": "var(--space-1-mid)",

  // Shadow elevation
  "shadow-elevation": "0 var(--space-1) var(--space-3) var(--shadow-color), 0 var(--space-half) var(--space-2) var(--shadow-color)",

  // Letter spacing
  "letter-spacing-tight": "-0.02em",

  // Line height for headings
  "line-height-heading": "1.2",

  // Extra-extra-small font
  "font-size-2xs": "10px",

  // Accent border width
  "accent-width": "var(--space-1)",

  // Letter spacing: wide (labels, micro, uppercase)
  "letter-spacing-wide": "0.05em",
  "letter-spacing-wider": "0.08em",

  // Control border (checkboxes, radios, switches — between thin and thick)
  "border-control": "var(--size-border-medium)",

  // Opacity scale
  "opacity-muted": "0.45",
  "opacity-subtle": "0.55",
  "opacity-soft": "0.75",

  // Small component sizes (dots, icons, action buttons)
  "size-dot": "6px",
  "size-icon-sm": "18px",
  "size-action": "28px",

  // Semantic layout aliases
  "control-height": "var(--space-5)",
  "navbar-height": "var(--space-7)",
  "dropdown-max-height": "var(--space-25)",
  "popover-min-width": "var(--space-25)",
  "sidebar-width": "var(--space-30)",
  "url-bar-max-width": "var(--space-30)",
  "aside-width": "var(--space-32-mid)",
  "card-min-width": "var(--space-35)",
  "dialog-width": "var(--space-52-mid)",
  "prose-max-width": "var(--space-60)",

  // Toast accent border
  "border-accent": "var(--size-border-accent)",

  // Component shadows (lighter than elevation)
  "shadow-sm": "0 var(--space-quarter) var(--border-heavy) rgba(0,0,0,0.25)",
  "shadow-inset": "inset 0 var(--space-quarter) var(--space-half) rgba(0,0,0,0.06)",
  "shadow-overlay": "0 var(--space-1) var(--space-4) rgba(0,0,0,0.18), 0 var(--space-half) var(--space-1) rgba(0,0,0,0.1)",
  "shadow-toast": "0 var(--space-half) var(--space-1) rgba(0,0,0,0.35)",
  "shadow-control": "inset 0 var(--size-border-thin) var(--border-heavy) rgba(0,0,0,0.04)",
  "shadow-thumb": "0 var(--size-border-thin) var(--size-border-extra-heavy) rgba(0,0,0,0.18), 0 var(--size-border-thin) var(--size-border-thick) rgba(0,0,0,0.1)",
  "shadow-panel": "0 var(--space-1) var(--space-4) var(--shadow-color), 0 var(--space-half) var(--space-1) rgba(0,0,0,0.06), 0 0 var(--size-border-thin) rgba(0,0,0,0.06)",
  "shadow-dialog": "0 var(--space-3) var(--space-8) rgba(0,0,0,0.18), 0 var(--space-1) var(--space-4) var(--shadow-color), 0 0 var(--size-border-thick) rgba(0,0,0,0.06)",
  "shadow-floating": "0 var(--space-half) var(--space-3) rgba(0,0,0,0.12), 0 var(--size-border-thin) var(--size-dot) rgba(0,0,0,0.08)",

  // Line height: compact (single-line UI elements like buttons)
  "line-height-compact": "1",

  // Letter spacing: snug (buttons, subtle tightening)
  "letter-spacing-snug": "-0.01em",
  // Letter spacing: label (between wide and wider, for form labels)
  "letter-spacing-label": "0.06em",
  // Letter spacing: widest (for expanded showcase labels)
  "letter-spacing-widest": "0.1em",

  // Transitions: medium (between base and slow)
  "transition-medium": "0.22s",

  // Opacity: disabled and faint
  "opacity-disabled": "0.4",
  "opacity-faint": "0.3",
};

// ─── Level 3: Component Properties ───
// Per-component defaults. References Level 1/2 via var().

const LEVEL_3: Record<string, string> = {

  // ── Cards ──
  "card-grid-gap": "var(--space-2)",
  "card-grid-min-width": "var(--card-min-width)",
  "card-border-width": "var(--border-thin)",
  "card-border-style": "solid",
  "card-border": "var(--card-border-width) var(--card-border-style) var(--card-border-color)",
  "card-border-width-accent": "var(--accent-width)",
  "card-accent-side": "top",
  "card-padding": "var(--space-3)",
  "card-transition": "var(--transition-base)",
  "card-background": "var(--surface)",
  "card-header-background": "var(--surface)",
  "card-header-color": "var(--text-secondary)",
  "card-footer-background": "var(--surface-alt)",
  "card-footer-color": "var(--text-secondary)",
  "card-border-color": "var(--text)",
  "card-hover-background": "var(--surface-alt)",
  "card-accent-color": "var(--brand-red)",
  "card-filled-background": "var(--black)",
  "card-filled-color": "var(--text-inverse)",
  "card-filled-hover-background": "var(--gray-900)",
  "card-title-font-size": "var(--font-size-md)",
  "card-title-font-weight": "var(--font-weight-bold)",
  "card-title-letter-spacing": "var(--letter-spacing-tight)",
  "card-title-margin-bottom": "var(--space-1)",
  "card-title-line-height": "var(--line-height-heading)",
  "card-body-padding": "var(--space-1) var(--card-padding) var(--space-1) var(--card-padding)",
  "card-body-font-size": "var(--font-size-sm)",
  "card-body-color": "var(--text-secondary)",
  "card-body-line-height": "var(--line-height-relaxed)",
  "card-body-filled-color": "var(--text-muted)",
  "card-tag-font-family": "var(--font-mono)",
  "card-tag-font-size": "var(--font-size-2xs)",
  "card-tag-font-weight": "var(--font-weight-medium)",
  "card-tag-padding": "var(--space-half) var(--space-1)",
  "card-tag-background": "var(--surface-alt)",
  "card-tag-color": "var(--gray-700)",
  "card-tag-margin-top": "var(--space-2)",
  "card-rounded-radius": "var(--radius-md)",
  "card-drop-shadow": "var(--shadow-elevation)",
  "card-drop-shadow-color": "var(--shadow-color)",
  "card-footer-font-size": "var(--font-size-sm)",
  "card-separator-width": "var(--border-thin)",
  "card-separator-color": "var(--border)",
  "table-cell-padding": "var(--space-2) var(--space-1)",
  "table-header-font-size": "var(--micro-label-font-size)",
  "table-header-font-family": "var(--micro-label-font-family)",
  "table-header-letter-spacing": "var(--letter-spacing-wide)",
  "table-header-border-width": "var(--border-thick)",

  // ── Tokens ──
  "token-grid-min-width": "var(--space-37-mid)",
  "token-grid-gap": "var(--space-2)",
  "token-card-background": "var(--surface)",
  "token-card-border": "var(--border-thin) solid var(--border)",
  "token-card-padding": "var(--space-3)",
  "token-card-title-font-size": "var(--micro-label-font-size)",
  "token-card-title-font-weight": "var(--micro-label-font-weight)",
  "token-card-title-text-transform": "var(--micro-label-text-transform)",
  "token-card-title-letter-spacing": "var(--micro-label-letter-spacing)",
  "token-card-title-color": "var(--base-font-color)",
  "token-card-title-margin-bottom": "var(--space-2)",
  "token-card-title-padding-bottom": "var(--space-1)",
  "token-card-title-border-bottom": "var(--border-thin) solid var(--border)",
  "token-row-padding": "var(--border-heavy) 0",
  "token-row-font-family": "var(--font-mono)",
  "token-row-font-size": "var(--font-size-xs)",
  "token-row-gap": "var(--space-1)",
  "token-name-color": "var(--gray-500)",
  "token-value-color": "var(--base-font-color)",
  "token-value-font-weight": "var(--font-weight-medium)",
  "token-preview-color-size": "var(--size-space-2)",
  "token-preview-color-border": "var(--border-thin) solid var(--border)",
  "token-preview-font-size": "var(--font-size-sm)",
  "token-preview-space-max-width": "var(--space-6)",
  "token-preview-space-max-height": "var(--space-2)",
  "token-preview-radius-size": "var(--space-3)",
  "token-preview-radius-border": "var(--border-thick) solid var(--token-value-color)",

  // ── Buttons ──
  "btn-font-family": "var(--font-sans)",
  "btn-font-weight": "var(--font-weight-semibold)",

  "btn-font-size": "var(--font-size-sm)",
  "btn-line-height": "var(--line-height-compact)",
  "btn-letter-spacing": "var(--letter-spacing-snug)",
  "btn-padding-y": "var(--space-1)",
  "btn-padding-x": "var(--space-2)",
  "btn-border-width": "var(--border-thin)",
  "btn-border-style": "solid",
  "btn-border-color": "var(--border-strong)",
  "btn-background": "var(--surface-alt)",
  "btn-color": "var(--text)",
  "btn-hover-background": "var(--border)",
  "btn-hover-border-color": "var(--border-strong)",
  "btn-transition": "var(--transition-base)",
  "btn-rounded-radius": "var(--radius-md)",
  "btn-drop-shadow": "var(--shadow-elevation)",
  "btn-sm-font-size": "var(--space-1-mid)",
  "btn-sm-padding-y": "var(--space-half)",
  "btn-sm-padding-x": "var(--space-1)",
  "btn-lg-font-size": "var(--font-size-md)",
  "btn-lg-padding-y": "var(--space-2)",
  "btn-lg-padding-x": "var(--space-3)",
  "btn-xl-font-size": "var(--size-icon-sm)",
  "btn-xl-padding-y": "var(--space-3)",
  "btn-xl-padding-x": "var(--space-4)",
  "btn-outline-background": "transparent",
  "btn-outline-color": "var(--text)",
  "btn-outline-hover-background": "var(--surface-alt)",
  "btn-active-offset": "var(--border-thin)",
  "btn-overlay-highlight": "var(--overlay-highlight)",
  "btn-overlay-shadow": "var(--overlay-shadow)",

  // ── Toggle ──
  "toggle-icon-collapsed": "'\\25B6'",
  "toggle-icon-expanded": "'\\25BC'",
  "toggle-icon-size": "var(--font-size-2xs)",
  "toggle-icon-color": "var(--gray-400)",
  "toggle-transition": "var(--transition-base) ease",
  "collapse-section-height": "var(--space-16)",
  "collapse-subsection-height": "var(--space-8)",

  // ── Indicators ──
  "badge-padding": "var(--space-half) var(--space-1)",
  "badge-radius": "var(--radius-md)",
  "badge-font-size": "var(--font-size-xs)",
  "badge-font-weight": "var(--font-weight-semibold)",
  "badge-font-family": "var(--font-mono)",
  "badge-line-height": "var(--line-height-tight)",
  "badge-count-min-width": "var(--size-icon-sm)",
  "badge-count-height": "var(--size-icon-sm)",
  "badge-count-padding": "0 var(--space-half)",

  "alert-border-width": "var(--border-heavy)",
  "alert-gap": "var(--space-half)",
  "alert-title-font-weight": "var(--font-weight-semibold)",
  "alert-title-font-size": "var(--font-size-sm)",
  "alert-title-line-height": "var(--line-height-tight)",
  "alert-body-font-size": "var(--font-size-sm)",
  "alert-body-line-height": "var(--line-height-normal)",

  "toast-gap": "var(--space-2)",
  "toast-padding": "var(--space-3) var(--space-3)",
  "toast-bg": "var(--surface)",
  "toast-bg-success": "var(--success-tint)",
  "toast-bg-error": "var(--error-tint)",
  "toast-bg-warning": "var(--warning-tint)",
  "toast-bg-info": "var(--info-tint)",
  "toast-color": "var(--text)",
  "toast-color-success": "var(--success)",
  "toast-color-error": "var(--error)",
  "toast-color-warning": "var(--warning)",
  "toast-color-info": "var(--info)",
  "toast-font-size": "var(--font-size-sm)",
  "toast-font-weight": "var(--font-weight-normal)",
  "toast-line-height": "var(--line-height-tight)",
  "toast-max-width": "var(--prose-max-width)",
  "toast-border-width": "var(--border-accent)",
  "toast-shadow": "var(--shadow-toast)",
  "toast-dot-size": "var(--radius-md)",

  "progress-height": "var(--space-1)",
  "progress-height-sm": "var(--space-half)",
  "progress-height-lg": "var(--radius-md)",
  "progress-radius": "var(--radius-none)",
  "progress-transition": "width var(--transition-slow) ease",

  "status-dot-row-gap": "var(--size-dot)",
  "status-dot-row-font-size": "var(--font-size-sm)",
  "status-dot-size": "var(--space-1)",

  "tag-padding": "var(--space-half) var(--space-1)",
  "tag-radius": "var(--radius)",
  "tag-font-size": "var(--font-size-xs)",
  "tag-font-weight": "var(--font-weight-medium)",
  "tag-font-family": "var(--font-mono)",
  "tag-border-width": "var(--border-thin)",

  // ── Forms ──
  "field-height": "var(--hui-field-height)",
  "field-padding-x": "var(--hui-field-padding-x)",
  "field-font-size": "var(--hui-field-font-size)",
  "field-bg": "var(--hui-field-bg)",
  "field-border-color": "var(--hui-field-border)",
  "field-border-hover": "var(--hui-field-border-hover)",
  "field-focus-border": "var(--hui-field-focus-border)",
  "field-shadow": "var(--hui-field-shadow)",
  "field-border-width": "var(--hui-field-border-width)",
  "field-transition": "border-color var(--transition-base) ease, box-shadow var(--transition-base) ease, background var(--transition-base) ease",
  "field-focus-ring": "0 0 0 var(--hui-focus-ring-width) var(--hui-focus-ring-color)",
  "field-textarea-padding": "var(--space-1) var(--space-2)",
  "field-textarea-min-height": "var(--space-11)",
  "field-textarea-line-height": "var(--line-height-normal)",
  "field-select-padding-right": "var(--space-4)",
  "field-validation-bar-width": "var(--border-heavy)",
  "field-label-gap": "var(--space-half)",
  "field-group-gap": "var(--space-1)",
  "field-label-font-size": "var(--micro-label-font-size)",
  "field-label-font-weight": "var(--micro-label-font-weight)",
  "field-label-letter-spacing": "var(--micro-label-letter-spacing)",
  "field-checkbox-font-size": "var(--font-size-sm)",

  "control-size": "var(--space-2)",
  "control-border-width": "var(--border-control)",
  "control-border-color": "var(--border-strong)",
  "control-transition": "border-color var(--transition-fast), background var(--transition-fast)",
  "control-shadow": "var(--shadow-inset)",
  "control-checked-color": "var(--brand-blue)",

  "switch-width": "var(--space-4-mid)",
  "switch-height": "var(--size-lg)",
  "switch-radius": "var(--size-2xs)",
  "switch-transition": "background var(--transition-base)",
  "switch-thumb-size": "var(--size-md-sm)",
  "switch-thumb-radius": "calc(var(--space-1) - var(--border-thin))",
  "switch-thumb-inset": "var(--size-border-heavy)",
  "switch-thumb-checked-pos": "calc(var(--size-lg) - var(--size-border-thin))",
  "switch-thumb-shadow": "var(--shadow-sm)",
  "switch-thumb-transition": "left var(--transition-base)",

  "radio-size": "var(--space-2)",
  "radio-border-width": "var(--border-control)",
  "radio-inner-shadow": "inset 0 0 0 var(--size-border-extra-heavy) var(--brand-blue)",

  "field-hint-font-size": "var(--font-size-xs)",
  "field-hint-line-height": "var(--line-height-tight)",
  "field-hint-margin-top": "var(--size-border-thin)",
  "field-hint-margin-left": "var(--size-border-thick)",
  "field-char-count-line-height": "var(--line-height-tight)",

  "fieldset-legend-padding": "var(--size-dot)",
  "fieldset-legend-margin-bottom": "var(--border-thick)",
  "fieldset-border-width": "var(--border-thin)",

  // ── Shells ──
  "shell-navbar-height": "var(--navbar-height)",
  "shell-navbar-z-index": "var(--z-chrome)",
  "shell-navbar-font-size": "var(--font-size-sm)",
  "shell-navbar-border-width": "var(--border-thin)",
  "shell-navbar-link-gap": "var(--border-thick)",
  "shell-navbar-link-padding": "var(--space-half) var(--space-1)",
  "shell-navbar-link-font-size": "var(--font-size-sm)",
  "shell-navbar-link-radius": "var(--radius)",
  "shell-navbar-link-transition": "opacity var(--transition-fast), background var(--transition-fast)",
  "shell-navbar-link-opacity": "var(--opacity-soft)",
  "shell-navbar-link-active-weight": "var(--font-weight-semibold)",
  "shell-navbar-action-size": "var(--size-action)",
  "shell-navbar-action-font-size": "var(--font-size-sm)",
  "shell-navbar-action-radius": "var(--radius)",
  "shell-navbar-action-transition": "background var(--transition-fast)",
  "shell-navbar-dismiss-padding": "var(--space-half) var(--space-1)",
  "shell-navbar-dismiss-font-size": "var(--font-size-xs)",
  "shell-navbar-dismiss-radius": "var(--radius)",
  "shell-navbar-dismiss-transition": "background var(--transition-fast)",

  "shell-sidebar-width": "var(--sidebar-width)",
  "shell-sidebar-z-index": "var(--z-panel)",
  "shell-sidebar-border-width": "var(--border-thin)",
  "shell-sidebar-section-font-size": "var(--micro-label-font-size)",
  "shell-sidebar-section-letter-spacing": "var(--micro-label-letter-spacing)",
  "shell-sidebar-section-opacity": "var(--opacity-muted)",
  "shell-sidebar-item-gap": "var(--space-1)",
  "shell-sidebar-item-padding": "var(--space-1) var(--space-3)",
  "shell-sidebar-item-font-size": "var(--font-size-sm)",
  "shell-sidebar-item-transition": "background var(--transition-fast)",
  "shell-sidebar-item-active-weight": "var(--font-weight-semibold)",
  "shell-sidebar-glyph-size": "var(--size-icon-sm)",
  "shell-sidebar-glyph-font-size": "var(--font-size-sm)",
  "shell-sidebar-divider-width": "var(--border-thin)",

  "shell-aside-width": "var(--aside-width)",
  "shell-aside-z-index": "var(--z-panel)",
  "shell-aside-border-width": "var(--border-thin)",
  "shell-aside-section-font-size": "var(--font-size-xs)",
  "shell-aside-section-letter-spacing": "var(--letter-spacing-wide)",
  "shell-aside-section-opacity": "var(--opacity-muted)",
  "shell-aside-row-padding": "var(--space-1) var(--space-3)",
  "shell-aside-row-font-size": "var(--font-size-sm)",
  "shell-aside-row-border-width": "var(--border-thin)",
  "shell-aside-meta-font-size": "var(--font-size-xs)",
  "shell-aside-meta-opacity": "var(--opacity-subtle)",

  "shell-footer-height": "var(--space-4)",
  "shell-footer-z-index": "var(--z-chrome)",
  "shell-footer-font-size": "var(--font-size-xs)",
  "shell-footer-border-width": "var(--border-thin)",
  "shell-footer-dot-size": "var(--size-dot)",
  "shell-footer-dot-opacity": "var(--opacity-faint)",

  "screen-frame-radius": "var(--space-1)",
  "screen-frame-shadow": "var(--shadow-overlay)",
  "screen-frame-border-width": "var(--border-thin)",
  "screen-titlebar-gap": "var(--size-dot)",
  "screen-titlebar-padding": "var(--space-1) var(--space-2)",
  "screen-titlebar-font-size": "var(--font-size-xs)",
  "screen-dots-gap": "var(--space-half)",
  "screen-dot-size": "var(--font-size-2xs)",
  "screen-dot-close": "#ff5f56",
  "screen-dot-minimize": "#ffbd2e",
  "screen-dot-maximize": "#27c93f",
  "screen-url-padding": "var(--space-half) var(--space-1)",
  "screen-url-radius": "var(--space-half)",
  "screen-url-max-width": "var(--url-bar-max-width)",
  "screen-url-border-width": "var(--border-thin)",

  // ── Sections ──
  "sg-border": "var(--border-thin) solid var(--border)",
  "sg-screen-url-max-width": "var(--space-37-mid)",
  "sg-screen-body-min-height": "var(--space-25)",
  "sg-screen-shadow": "var(--size-dot) var(--size-dot) 0 var(--gray-200)",
  "sg-section-number-padding": "var(--border-heavy) var(--space-1)",
  "sg-section-number-letter-spacing": "var(--micro-label-letter-spacing)",
  "sg-section-number-bg": "var(--surface-alt)",
  "sg-section-number-border": "var(--sg-border)",
  "sg-section-number-color": "var(--text-muted)",
  "sg-section-number-radius": "var(--radius)",
  "sg-section-title-font-family": "inherit",
  "sg-section-title-font-size": "var(--font-size-lg)",
  "sg-section-title-letter-spacing": "var(--letter-spacing-tight)",
  "sg-section-title-text-transform": "none",
  "sg-section-title-color": "var(--text)",
  "sg-section-desc-font-family": "var(--font-mono)",
  "sg-section-desc-color": "var(--text-muted)",
  "sg-type-specimen-bg": "transparent",
  "sg-type-specimen-border": "none",
  "sg-type-specimen-border-bottom": "1px solid var(--border)",
  "sg-type-specimen-radius": "0",
  "sg-type-specimen-padding": "0 0 var(--space-2) 0",
  "sg-type-specimen-margin": "0 0 var(--space-2) 0",
  "sg-type-specimen-name-color": "var(--text)",
  "sg-type-specimen-name-font": "var(--font-mono)",
  "sg-principle-label-width": "var(--space-9)",
  "sg-description-max-width": "var(--prose-max-width)",
  "sg-hairline": "var(--border-thick)",
  "sg-group-content-padding": "var(--border-thick) var(--size-dot)",
  "sg-group-content-gap": "var(--border-thick)",
  "sg-group-item-margin-right": "var(--space-half)",

  // ── Branding card ──
  "branding-grid-width": "var(--card-min-width)",
  // Card-level border and background — theme can override without touching global semantics
  "branding-border": "var(--card-border)",
  "branding-logo-bg": "var(--surface-alt)",
  "branding-logo-max-width": "var(--space-20)",
  "branding-logo-max-height": "var(--space-15)",
  "branding-placeholder-width": "var(--space-15)",
  "branding-placeholder-height": "var(--space-10)",
  "branding-placeholder-border": "var(--border-thick) dashed var(--border-strong)",
  "branding-name-font-size": "var(--space-2-mid)",
  "branding-name-font-weight": "var(--font-weight-bold)",
  "branding-name-letter-spacing": "var(--letter-spacing-tight)",
  "branding-name-border": "var(--card-border)",
  "branding-field-label-font-size": "var(--micro-label-font-size)",
  "branding-field-label-font-weight": "var(--micro-label-font-weight)",
  "branding-field-label-letter-spacing": "var(--letter-spacing-wide)",
  "branding-field-value-font-size": "var(--font-size-sm)",
  "branding-field-value-line-height": "var(--line-height-relaxed)",
  "branding-field-value-color": "var(--text-secondary)",
  "branding-keyword-font-size": "var(--micro-label-font-size)",
  "branding-keyword-font-weight": "var(--micro-label-font-weight)",
  "branding-keyword-letter-spacing": "var(--micro-label-letter-spacing)",
  "branding-keyword-color": "var(--text-secondary)",
  "branding-keyword-padding": "var(--border-heavy) var(--font-size-2xs)",
  "branding-keyword-border": "var(--border-thin) solid var(--border-strong)",
  "branding-keyword-gap": "var(--space-half)",
  "branding-keyword-margin-top": "var(--space-half)",
  // ThemeLogo shell — controls the wordmark rendered in the nav/header
  "branding-logo-font-size": "var(--font-size-xl)",
  "branding-logo-font-weight": "var(--font-weight-black)",
  "branding-logo-letter-spacing": "var(--letter-spacing-wide)",
  "branding-logo-text-transform": "uppercase",
  "branding-logo-padding": "0",
  "branding-logo-border-radius": "var(--radius)",

  // ── Dividers ──
  "hr-glow-blur": "0.3px",
  "hr-overline-length": "var(--space-6)",

  // ── Spacing (styleguide demo components) ──
  "sg-bar-height": "var(--size-lg)",
  "sg-bar-min-width": "var(--space-half)",
  "sg-bar-radius": "var(--radius)",
  "sg-bar-label-font-size": "var(--micro-label-font-size)",
  "sg-spacing-label-width": "var(--space-10)",
  "sg-spacing-value-width": "var(--space-7-mid)",
  "sg-spacing-gap": "var(--size-dot)",
  "sg-principles-font-size": "var(--font-size-sm)",
  "sg-principles-line-height": "var(--line-height-relaxed)",
  "sg-diagram-min-height": "var(--space-15)",
  "sg-diagram-gutter-width": "var(--space-5)",
  "sg-diagram-hatch-width": "var(--border-thick)",
  "sg-diagram-hatch-gap": "var(--space-1)",
  "sg-diagram-annotation-font-size": "var(--space-1)",
  "sg-diagram-padding-height": "var(--space-2)",
  "sg-diagram-padding-height-sm": "var(--space-1)",
  "sg-diagram-detail-font-size": "var(--font-size-sm)",
  "sg-diagram-detail-font-weight": "var(--font-weight-semibold)",
  "sg-diagram-note-font-size": "var(--micro-label-font-size)",

  // ── HUI: Focus & Interaction ──
  "hui-focus-ring-color": "color-mix(in srgb, var(--brand-blue) 25%, transparent)",
  "hui-focus-ring-width": "var(--border-heavy)",

  // ── HUI: Controls ──
  "hui-control-color": "var(--brand-blue)",
  "hui-control-bg": "var(--surface)",
  "hui-control-border": "var(--border-strong)",
  "hui-control-size": "var(--size-lg)",
  "hui-checkbox-radius": "var(--border-heavy)",
  "hui-switch-track-width": "var(--space-5-mid)",
  "hui-switch-track-height": "var(--space-3)",
  "hui-switch-track-radius": "var(--radius-md)",
  "hui-switch-track-off-bg": "var(--gray-300)",
  "hui-switch-track-on-bg": "var(--brand-blue)",
  "hui-switch-thumb-size": "var(--size-space-2-qtr)",
  "hui-switch-thumb-bg": "var(--white)",
  "hui-radio-option-padding-y": "var(--size-dot)",
  "hui-radio-option-padding-x": "var(--font-size-2xs)",
  "hui-radio-option-border": "var(--border)",
  "hui-radio-option-border-active": "var(--brand-blue)",
  "hui-radio-option-bg-active": "color-mix(in srgb, var(--brand-blue) 8%, var(--white))",
  "hui-radio-dot-size": "var(--size-space-2)",
  "hui-control-gap": "var(--space-1)",
  "hui-control-border-width": "var(--size-border-medium)",
  "hui-control-transition": "background var(--transition-base) ease, border-color var(--transition-base) ease",
  "hui-control-shadow": "var(--shadow-control)",
  "hui-control-label-color": "var(--text-secondary)",
  "hui-switch-gap": "var(--space-3)",
  "hui-switch-thumb-radius": "var(--radius-circle)",
  "hui-switch-thumb-inset": "var(--border-heavy)",
  "hui-switch-thumb-shadow": "var(--shadow-thumb)",
  "hui-switch-thumb-transition": "left var(--transition-medium) cubic-bezier(0.4, 0, 0.2, 1)",
  "hui-switch-track-transition": "background var(--transition-medium) ease",
  "hui-radio-border-width": "var(--border-thin)",
  "hui-radio-transition": "border-color var(--transition-base) ease, background var(--transition-base) ease",
  "hui-radio-dot-radius": "var(--radius-circle)",
  "hui-radio-dot-inner-size": "calc(var(--space-1) - var(--border-thin))",
  "hui-radio-dot-inner-radius": "var(--radius-circle)",

  // ── HUI: Trigger Buttons ──
  "hui-trigger-padding-y": "var(--space-1)",
  "hui-trigger-padding-x": "var(--size-space-1-mid)",
  "hui-trigger-font-size": "var(--font-size-sm)",
  "hui-trigger-font-weight": "var(--font-weight-medium)",
  "hui-trigger-bg": "var(--surface)",
  "hui-trigger-border": "var(--border)",
  "hui-trigger-border-hover": "var(--border-strong)",
  "hui-trigger-color": "var(--text)",
  "hui-trigger-gap": "var(--size-dot)",
  "hui-trigger-border-width": "var(--border-thin)",
  "hui-trigger-transition": "border-color var(--transition-base) ease, background var(--transition-base) ease",

  // ── HUI: Overlay Panels ──
  "hui-panel-bg": "var(--surface)",
  "hui-panel-border": "var(--border)",
  "hui-panel-shadow": "var(--shadow-panel)",
  "hui-panel-padding": "var(--size-dot)",
  "hui-panel-margin-top": "var(--size-dot)",
  "hui-panel-item-padding-y": "var(--space-1)",
  "hui-panel-item-padding-x": "var(--font-size-2xs)",
  "hui-panel-item-font-size": "var(--font-size-sm)",
  "hui-panel-item-color": "var(--text)",
  "hui-panel-item-active-bg": "var(--surface-alt)",
  "hui-panel-item-active-color": "var(--text)",
  "hui-panel-sep-color": "var(--border)",
  "hui-popover-padding": "var(--space-3)",
  "hui-panel-border-width": "var(--border-thin)",
  "hui-panel-z-index": "var(--z-dropdown)",
  "hui-panel-item-gap": "var(--space-1)",
  "hui-panel-item-radius-inset": "var(--border-thick)",
  "hui-panel-item-transition": "background var(--transition-fast) ease, color var(--transition-fast) ease",
  "hui-panel-item-disabled-opacity": "var(--opacity-disabled)",
  "hui-panel-item-selected-weight": "var(--font-weight-semibold)",
  "hui-panel-sep-height": "var(--border-thin)",
  "hui-panel-sep-margin-y": "var(--space-half)",
  "hui-panel-max-height": "var(--dropdown-max-height)",
  "hui-menu-min-width": "var(--space-20)",
  "hui-popover-min-width": "var(--popover-min-width)",
  "hui-combo-icon-area": "var(--space-4-mid)",
  "hui-combo-placeholder-color": "var(--gray-400)",
  "hui-combo-btn-color": "var(--gray-500)",

  // ── HUI: Tabs ──
  "hui-tab-padding-y": "var(--font-size-2xs)",
  "hui-tab-padding-x": "var(--size-space-2)",
  "hui-tab-font-size": "var(--font-size-sm)",
  "hui-tab-font-weight": "var(--font-weight-medium)",
  "hui-tab-font-weight-selected": "var(--font-weight-semibold)",
  "hui-tab-color": "var(--gray-400)",
  "hui-tab-color-hover": "var(--gray-700)",
  "hui-tab-color-selected": "var(--text)",
  "hui-tab-border-selected": "var(--text)",
  "hui-tab-list-border": "var(--border)",
  "hui-tab-panel-color": "var(--text-secondary)",
  "hui-tab-indicator-width": "var(--border-thick)",
  "hui-tab-indicator-offset": "calc(-1 * var(--border-thin))",
  "hui-tab-transition": "color var(--transition-base) ease, border-color var(--transition-base) ease",
  "hui-tab-list-border-width": "var(--border-thin)",

  // ── HUI: Disclosure ──
  "hui-disclosure-bg": "var(--surface-alt)",
  "hui-disclosure-bg-hover": "var(--surface-alt)",
  "hui-disclosure-border": "var(--border)",
  "hui-disclosure-padding-y": "var(--font-size-2xs)",
  "hui-disclosure-padding-x": "var(--size-md-sm)",
  "hui-disclosure-font-size": "var(--font-size-sm)",
  "hui-disclosure-font-weight": "var(--font-weight-medium)",
  "hui-disclosure-color": "var(--text)",
  "hui-disclosure-panel-bg": "var(--surface)",
  "hui-disclosure-panel-color": "var(--text-secondary)",
  "hui-disclosure-border-width": "var(--border-thin)",
  "hui-disclosure-transition": "background var(--transition-base) ease",
  "hui-disclosure-chevron-size": "var(--size-md-sm)",
  "hui-disclosure-chevron-color": "var(--gray-400)",
  "hui-disclosure-chevron-transition": "transform var(--transition-medium) cubic-bezier(0.4, 0, 0.2, 1)",
  "hui-disclosure-panel-line-height": "var(--line-height-relaxed)",

  // ── HUI: Field Controls ──
  "hui-field-height": "var(--control-height)",
  "hui-field-padding-x": "var(--size-space-1-mid)",
  "hui-field-font-size": "var(--font-size-sm)",
  "hui-field-bg": "var(--surface)",
  "hui-field-border": "var(--border)",
  "hui-field-border-hover": "var(--border-strong)",
  "hui-field-focus-border": "var(--brand-blue)",
  "hui-field-shadow": "var(--shadow-control)",
  "hui-field-color": "var(--text)",
  "hui-field-border-width": "var(--border-thin)",
  "hui-field-transition": "border-color var(--transition-base) ease, box-shadow var(--transition-base) ease",
  "hui-field-icon-area": "var(--space-4)",
  "hui-field-chevron-color": "var(--gray-400)",
  "hui-field-chevron-size": "var(--size-dot)",
  "hui-field-chevron-border-width": "var(--size-border-medium)",
  "hui-field-chevron-offset": "var(--size-space-1-mid)",
  "hui-label-font-size": "var(--font-size-xs)",
  "hui-label-font-weight": "var(--font-weight-semibold)",
  "hui-label-letter-spacing": "var(--letter-spacing-label)",
  "hui-label-color": "var(--text-muted)",
  "hui-description-font-size": "var(--font-size-xs)",
  "hui-description-color": "var(--text-muted)",
  "hui-textarea-resize": "none",

  // ── HUI: Dialog ──
  "hui-dialog-backdrop": "var(--overlay-backdrop)",
  "hui-dialog-bg": "var(--surface)",
  "hui-dialog-shadow": "var(--shadow-dialog)",
  "hui-dialog-padding": "var(--space-4)",
  "hui-dialog-max-width": "var(--dialog-width)",
  "hui-dialog-backdrop-z-index": "var(--z-overlay)",
  "hui-dialog-z-index": "var(--z-dialog)",
  "hui-dialog-positioner-padding": "var(--space-4)",
  "hui-dialog-title-weight": "var(--font-weight-bold)",
  "hui-dialog-title-color": "var(--text)",
  "hui-dialog-body-color": "var(--text-secondary)",
  "hui-dialog-body-line-height": "var(--line-height-relaxed)",

  // ── HUI: Showcase Grid ──
  "hui-showcase-accent": "var(--brand-red)",
  "hui-showcase-bg": "var(--surface-alt)",
  "hui-showcase-border": "var(--border-strong)",
  "hui-showcase-cell-bg": "var(--surface)",
  "hui-showcase-cell-border": "var(--border)",
  "hui-showcase-cell-padding": "var(--space-3)",
  "hui-showcase-cell-min-height": "140px",
  "hui-showcase-label-color": "var(--text-muted)",
  "hui-showcase-border-width": "var(--border-thin)",
  "hui-showcase-accent-width": "var(--border-heavy)",
  "hui-showcase-grid-gap": "var(--border-thin)",
  "hui-showcase-label-font-size": "var(--font-size-2xs)",
  "hui-showcase-label-weight": "var(--font-weight-bold)",
  "hui-showcase-label-letter-spacing": "var(--letter-spacing-wider)",
  "hui-showcase-label-padding-bottom": "var(--font-size-2xs)",
  "hui-showcase-label-border-width": "var(--border-thin)",

  // ── Code blocks ──
  "code-bg": "var(--gray-900)",
  "code-text": "var(--gray-100)",
  "code-border": "var(--gray-700)",
  "code-keyword": "var(--brand-blue)",
  "code-string": "var(--success)",
  "code-comment": "var(--gray-500)",
  "code-function": "var(--amber)",
  "code-number": "var(--brand-red)",
  "code-line-number": "var(--gray-600)",

  // ── Terminal ──
  "terminal-bg": "var(--gray-900)",
  "terminal-text": "var(--gray-100)",
  "terminal-border": "var(--gray-700)",
  "terminal-title-bar-bg": "var(--gray-800)",
  "terminal-prompt": "var(--success)",
  "terminal-command": "var(--gray-100)",
  "terminal-output": "var(--gray-400)",
  "terminal-success": "var(--success)",
  "terminal-error": "var(--error)",
  "terminal-warning": "var(--warning)",
};

// ─── Exported for var categorization ───
export const FOUNDATION_KEYS = new Set(Object.keys(LEVEL_2));

// ─── Multi-pass resolver ───

export function resolveDefaults(yamlVars: Record<string, string>): Record<string, string> {
  // Pass 1: Build base tokens from seeds (unit, font-size-base, colors)
  // YAML values act as seeds — buildBaseTokens reads them to compute the full scale
  const base = buildBaseTokens(yamlVars);

  // Pass 2: Layer foundations on top of base
  // LEVEL_2 uses var() refs to base tokens — changes cascade at runtime
  const withFoundations = { ...base, ...LEVEL_2 };

  // Pass 3: Layer component properties on top of foundations
  // LEVEL_3 uses var() refs to L1/L2 — changes cascade at runtime
  const withComponents = { ...withFoundations, ...LEVEL_3 };

  // Pass 4: YAML overrides win at every level
  return { ...withComponents, ...yamlVars };
}
