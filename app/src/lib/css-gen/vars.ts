import type { StyleGuideConfig } from "../types";
import { resolveDefaults, FOUNDATION_KEYS } from "./defaults";

// Desired output order for YAML groups
const GROUP_ORDER = [
  // Colors
  "Primaries - Bauhaus",  // Brand
  "Surfaces",             // Gray
  // Slate is computed (foundation)
  "Palette",
  "Semantic",
  // Spacing & Grid
  "Grid & Spacing",
  // Typography
  "Typography",
  // Base
  "Base",
  // Components
  "Cards",
  "Tokens",
  "Buttons",
  "Toggle",
];

function groupSortKey(name: string): number {
  const idx = GROUP_ORDER.indexOf(name);
  if (idx >= 0) return idx;
  // HUI groups after Toggle
  if (name.startsWith("HUI")) return GROUP_ORDER.length + 1;
  return GROUP_ORDER.length + 2;
}

export function generateVarsCSS(config: StyleGuideConfig): string {
  const resolved = resolveDefaults(config.flatVars);

  // Collect var names already emitted by YAML groups
  const yamlVarNames = new Set<string>();
  for (const group of config.vars.groups) {
    for (const v of group.vars) {
      yamlVarNames.add(v.name);
    }
  }

  // Sort groups by desired order
  const sortedGroups = [...config.vars.groups].sort((a, b) => groupSortKey(a.name) - groupSortKey(b.name));

  // Categorize foundation vars (not in YAML) by topic and emit under section headings
  const allFoundation = Object.entries(resolved)
    .filter(([name]) => !yamlVarNames.has(name));

  // Categorize by prefix/topic
  const foundationCategories: Record<string, [string, string][]> = {
    "Slate": [],
    "Grid & Spacing": [],
    "Foundations: Typography": [],
    "Foundations: Borders & Radius": [],
    "Foundations: Transitions": [],
    "Foundations: Shadows & Elevation": [],
    "Foundations: Opacity": [],
    "Foundations: Layout": [],
    "Foundations: Micro Label": [],
    "Component Defaults: Cards": [],
    "Component Defaults: Buttons": [],
    "Component Defaults: Indicators": [],
    "Component Defaults: Forms": [],
    "Component Defaults: Shells": [],
    "Component Defaults: Sections": [],
    "Component Defaults: Branding": [],
    "Component Defaults: Spacing": [],
    "Component Defaults: Dividers": [],
    "Component Defaults: Tokens": [],
    "Component Defaults: Other": [],
  };

  for (const [name, value] of allFoundation) {
    if (name.startsWith("slate-")) foundationCategories["Slate"].push([name, value]);
    // Spacing, sizing, and unit tokens → Grid & Spacing
    else if (name.startsWith("space-") || name.startsWith("size-") || name === "unit" || name === "col-gap" || name === "radius" || name === "off-white") foundationCategories["Grid & Spacing"].push([name, value]);
    else if (name.startsWith("opacity-")) foundationCategories["Foundations: Opacity"].push([name, value]);
    else if (name.startsWith("micro-label")) foundationCategories["Foundations: Micro Label"].push([name, value]);
    else if (name.startsWith("font-weight-") || name.startsWith("line-height-") || name.startsWith("letter-spacing-") || name === "font-size-2xs") foundationCategories["Foundations: Typography"].push([name, value]);
    else if (name.startsWith("border-") || name.startsWith("radius") || name === "accent-width") foundationCategories["Foundations: Borders & Radius"].push([name, value]);
    else if (name.startsWith("transition-")) foundationCategories["Foundations: Transitions"].push([name, value]);
    else if (name.startsWith("shadow-") || name.startsWith("overlay-")) foundationCategories["Foundations: Shadows & Elevation"].push([name, value]);
    else if (name.startsWith("z-") || name === "on-semantic-color" || ["control-height", "navbar-height", "dropdown-max-height", "popover-min-width", "sidebar-width", "url-bar-max-width", "aside-width", "card-min-width", "dialog-width", "prose-max-width"].includes(name)) foundationCategories["Foundations: Layout"].push([name, value]);
    else if (name.startsWith("card-") || name.startsWith("table-")) foundationCategories["Component Defaults: Cards"].push([name, value]);
    else if (name.startsWith("btn-")) foundationCategories["Component Defaults: Buttons"].push([name, value]);
    else if (name.startsWith("badge-") || name.startsWith("alert-") || name.startsWith("toast-") || name.startsWith("progress-") || name.startsWith("status-dot") || name.startsWith("tag-")) foundationCategories["Component Defaults: Indicators"].push([name, value]);
    else if (name.startsWith("field-") || name.startsWith("control-") || name.startsWith("switch-") || name.startsWith("radio-")) foundationCategories["Component Defaults: Forms"].push([name, value]);
    else if (name.startsWith("shell-") || name.startsWith("screen-")) foundationCategories["Component Defaults: Shells"].push([name, value]);
    else if (name.startsWith("sg-")) foundationCategories["Component Defaults: Sections"].push([name, value]);
    else if (name.startsWith("branding-")) foundationCategories["Component Defaults: Branding"].push([name, value]);
    else if (name.startsWith("spacing-")) foundationCategories["Component Defaults: Spacing"].push([name, value]);
    else if (name.startsWith("hr-")) foundationCategories["Component Defaults: Dividers"].push([name, value]);
    else if (name.startsWith("token-")) foundationCategories["Component Defaults: Tokens"].push([name, value]);
    else foundationCategories["Component Defaults: Other"].push([name, value]);
  }

  const themeSelector = `html[data-design-theme="${config.slug}"]`;

  // Helper to get a foundation category block with sub-section headings
  function fcat(name: string): string {
    const entries = foundationCategories[name];
    if (!entries || entries.length === 0) return "";

    // Grid & Spacing: sort into sub-groups by prefix
    if (name === "Grid & Spacing") {
      const buckets: [string, [string, string][]][] = [
        ["scale", []], ["borders", []], ["sizes", []], ["spacing", []], ["derived", []],
      ];
      const bmap = Object.fromEntries(buckets);
      for (const [n, v] of entries) {
        if (n === "unit" || n === "radius" || n === "off-white") bmap["scale"].push([n, v]);
        else if (n.startsWith("size-border")) bmap["borders"].push([n, v]);
        else if (n.startsWith("size-")) bmap["sizes"].push([n, v]);
        else if (n.startsWith("space-")) bmap["spacing"].push([n, v]);
        else bmap["derived"].push([n, v]); // col-gap etc. that reference space tokens
      }
      let result = `\n  /* ══ ${name} ══ */`;
      for (const [, vars] of buckets) {
        if (vars.length === 0) continue;
        result += "\n" + vars.map(([n, v]) => `  --${n}: ${v};`).join("\n");
      }
      return result;
    }

    // Other non-component, non-foundation categories: flat output
    if (!name.startsWith("Component Defaults:") && !name.startsWith("Foundations:")) {
      return `\n  /* ══ ${name} ══ */\n` +
        entries.map(([n, v]) => `  --${n}: ${v};`).join("\n");
    }

    // Find common prefix shared by ALL entries
    const prefix = inferPrefix(entries);

    // Group by the segment after the common prefix
    const groups: Map<string, [string, string][]> = new Map();
    for (const [n, v] of entries) {
      const rest = n.slice(prefix.length);
      // Use first segment after prefix as sub-group name
      const dashIdx = rest.indexOf("-");
      const sub = dashIdx > 0 ? rest.slice(0, dashIdx) : rest;
      if (!groups.has(sub)) groups.set(sub, []);
      groups.get(sub)!.push([n, v]);
    }

    let result = `\n  /* ══ ${name} ══ */`;
    for (const [sub, vars] of groups) {
      result += `\n    /* ${sub} */\n`;
      result += vars.map(([n, v]) => `  --${n}: ${v};`).join("\n");
    }
    return result;
  }

  // Infer the longest common dash-separated prefix shared by all entries
  function inferPrefix(entries: [string, string][]): string {
    if (entries.length === 0) return "";
    const first = entries[0][0];
    const parts = first.split("-");
    for (let i = 1; i <= parts.length; i++) {
      const candidate = parts.slice(0, i).join("-") + "-";
      if (!entries.every(([n]) => n.startsWith(candidate))) {
        // Previous level was the last common prefix
        if (i === 1) return ""; // No common prefix at all
        return parts.slice(0, i - 1).join("-") + "-";
      }
    }
    return parts.join("-") + "-";
  }

  // Helper to get a YAML group block with sub-section headings
  const yamlGroupMap = new Map(sortedGroups.map((g) => [g.name, g]));
  function ygrp(name: string): string {
    const group = yamlGroupMap.get(name);
    if (!group) return "";

    // Group vars by sub-prefix for sub-headings
    const prefix = inferPrefix(group.vars.map((v) => [v.name, v.value] as [string, string]));
    let vars: string;

    if (prefix && group.vars.length > 4) {
      const groups: Map<string, typeof group.vars> = new Map();
      for (const v of group.vars) {
        const rest = v.name.slice(prefix.length);
        const sub = rest.split("-")[0] || "base";
        if (!groups.has(sub)) groups.set(sub, []);
        groups.get(sub)!.push(v);
      }
      vars = [...groups.entries()]
        .map(([sub, subVars]) =>
          `    /* ${sub} */\n` +
          subVars.map((v) => `  --${v.name}: ${resolved[v.name] ?? v.value};`).join("\n")
        )
        .join("\n");
    } else {
      vars = group.vars.map((v) => `  --${v.name}: ${resolved[v.name] ?? v.value};`).join("\n");
    }

    let extra = "";
    if (name === "Semantic") {
      const scVars = config.semanticClasses
        .map((sc) => {
          const classVars = sc.vars.map((v) => `  --semantic-${sc.name}-${v.name}: ${v.value};`).join("\n");
          return `    /* ${sc.name} */\n${classVars}`;
        })
        .join("\n");
      if (scVars) extra = `\n\n  /* Semantic Classes */\n${scVars}`;
    }
    return `\n  /* ${name} */\n${vars}${extra}`;
  }

  // Merge a YAML group with its foundation category counterpart.
  // YAML entries come first (already resolved), foundation entries fill in the rest (no dupes).
  function mergedSection(yamlName: string, fcatName?: string): string {
    const seen = new Set<string>();
    const all: [string, string][] = [];

    // YAML entries first
    const group = yamlGroupMap.get(yamlName);
    if (group) {
      for (const v of group.vars) {
        const val = resolved[v.name] ?? v.value;
        all.push([v.name, val]);
        seen.add(v.name);
      }
    }

    // Foundation entries that aren't already covered by YAML
    const catName = fcatName ?? yamlName;
    const catEntries = foundationCategories[catName];
    if (catEntries) {
      for (const [n, v] of catEntries) {
        if (!seen.has(n)) {
          all.push([n, v]);
          seen.add(n);
        }
      }
    }

    if (all.length === 0) return "";

    // Grid & Spacing gets sorted into sub-groups
    if (catName === "Grid & Spacing") {
      const buckets: [string, [string, string][]][] = [
        ["scale", []], ["borders", []], ["sizes", []], ["spacing", []], ["derived", []],
      ];
      const bmap = Object.fromEntries(buckets);
      for (const [n, v] of all) {
        if (n === "unit" || n === "radius" || n === "off-white") bmap["scale"].push([n, v]);
        else if (n.startsWith("size-border")) bmap["borders"].push([n, v]);
        else if (n.startsWith("size-")) bmap["sizes"].push([n, v]);
        else if (n.startsWith("space-")) bmap["spacing"].push([n, v]);
        else bmap["derived"].push([n, v]);
      }
      let result = `\n  /* ${yamlName} */`;
      for (const [, vars] of buckets) {
        if (vars.length === 0) continue;
        result += "\n" + vars.map(([n, v]) => `  --${n}: ${v};`).join("\n");
      }
      return result;
    }

    // Default: flat output
    return `\n  /* ${yamlName} */\n` + all.map(([n, v]) => `  --${n}: ${v};`).join("\n");
  }

  // Build sections in the exact desired order
  const sections = [
    // Colors
    ygrp("Primaries - Bauhaus"),
    // Slate vars appended under Surfaces
    [ygrp("Surfaces"), fcat("Slate")?.replace(/\n  \/\* ══ Slate ══ \*\//, "")].filter(Boolean).join("\n"),
    ygrp("Palette"),
    mergedSection("Grid & Spacing"),
    // Foundations
    fcat("Foundations: Typography"),
    fcat("Foundations: Borders & Radius"),
    fcat("Foundations: Transitions"),
    fcat("Foundations: Shadows & Elevation"),
    fcat("Foundations: Opacity"),
    fcat("Foundations: Layout"),
    fcat("Foundations: Micro Label"),
    /* Semantic + Typography + Base */
    ygrp("Typography"),
    ygrp("Semantic"),
    ygrp("Base"),
    // Component defaults (from cascade)
    fcat("Component Defaults: Cards"),
    fcat("Component Defaults: Buttons"),
    fcat("Component Defaults: Indicators"),
    fcat("Component Defaults: Forms"),
    fcat("Component Defaults: Shells"),
    fcat("Component Defaults: Sections"),
    mergedSection("Branding", "Component Defaults: Branding"),
    fcat("Component Defaults: Dividers"),
    fcat("Component Defaults: Tokens"),
    fcat("Component Defaults: Spacing"),
    fcat("Component Defaults: Other"),
    // YAML component overrides
    ygrp("Cards"),
    ygrp("Tokens"),
    ygrp("Buttons"),
    ygrp("Toggle"),
    // HUI groups (dynamic — grab any YAML group starting with "HUI")
    ...sortedGroups.filter((g) => g.name.startsWith("HUI")).map((g) => ygrp(g.name)),
    // Catch-all: any YAML groups not explicitly listed above
    ...(() => {
      const handled = new Set([
        "Primaries - Bauhaus", "Surfaces", "Palette", "Grid & Spacing",
        "Typography", "Semantic", "Base", "Cards", "Tokens", "Buttons",
        "Toggle", "Branding",
        ...sortedGroups.filter((g) => g.name.startsWith("HUI")).map((g) => g.name),
      ]);
      return sortedGroups
        .filter((g) => !handled.has(g.name))
        .map((g) => ygrp(g.name));
    })(),
  ].filter(Boolean);

  // Build TOC — major sections only (first comment per section block)
  const tocNames: string[] = [];
  for (const s of sections) {
    const m = s.match(/\/\* (.+?) \*\//);
    if (!m) continue;
    const name = m[1].replace(/══\s*/g, "").replace(/\s*══/g, "").trim();
    if (name === "Semantic Classes") continue;
    tocNames.push(name);
  }

  const toc = `/*\n * ${config.title} — CSS Custom Properties\n *\n * Table of Contents:\n` +
    tocNames.map((e, i) => ` *   ${String(i + 1).padStart(2, " ")}. ${e}`).join("\n") +
    `\n *\n * Dark mode overrides follow the main block.\n */\n\n`;

  const mainBlock = `${toc}${themeSelector} {\n${sections.join("\n")}\n}`;

  return mainBlock;
}
