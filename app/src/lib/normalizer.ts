import path from "path";
import type { SimpleStyleGuideConfig, SimpleVarGroup, StyleGuideConfig, Var, SpacingContexts, GlyphLanguage } from "./types";
import { resolveDefaults } from "./css-gen/defaults";

function recordToVars(input: Record<string, string> | { name: string; value: string }[] | null | undefined): Var[] {
  if (!input) return [];
  // Array format: [{ name: "accent", value: "var(--error)" }, ...]
  if (Array.isArray(input)) {
    return input.map((v) => ({ name: v.name, value: v.value }));
  }
  // Record format: { accent: "var(--error)", ... }
  return Object.entries(input).map(([name, value]) => ({ name, value }));
}

function flattenVarGroups(groups: SimpleVarGroup[]): Record<string, string> {
  const flat: Record<string, string> = {};
  for (const g of groups) {
    if (!g.vars) continue;
    for (const [name, value] of Object.entries(g.vars)) {
      flat[name] = value;
    }
  }
  return flat;
}

export function normalizeConfig(input: SimpleStyleGuideConfig, themeDir?: string): StyleGuideConfig {
  return {
    name: input.name,
    slug: input.slug,
    title: input.title,
    description: input.description,
    vars: {
      groups: input.vars.groups.map((g) => ({
        name: g.name,
        vars: recordToVars(g.vars),
      })),
    },
    flatVars: resolveDefaults(flattenVarGroups(input.vars.groups)),
    semanticGroups: input["semantic-groups"] || [],
    semanticClasses: (input["semantic-classes"] || []).map((sc) => ({
      name: sc.name,
      class: sc.class,
      group: sc.group,
      title: sc.title,
      description: sc.description,
      note: sc.note,
      accentStyle: sc["accent-style"],
      vars: recordToVars(sc.vars),
    })),
    pageLayouts: (input["page-layouts"] || []).map((pl) => ({
      name: pl.name,
      title: pl.title,
      description: pl.description,
      selector: pl.selector,
      vars: recordToVars(pl.vars),
      chrome: pl.chrome,
    })),
    typography: input.typography || [],
    typographyClasses: input["typography-classes"] || [],
    designSections: input["design-sections"] || [],
    shellLayouts: input["shell-layouts"] || [],
    colorPalette: (input["color-palette"] || []).map((cg) => ({
      group: cg.group,
      description: cg.description,
      colors: cg.colors.map((c) => ({
        ...c,
        cssClass: (c as { cssClass?: string }).cssClass || c.name.toLowerCase().replace(/\s+/g, "-"),
      })),
      notes: cg.notes,
    })),
    globals: input.globals || "",
    toast: input.toast ?? {},
    spacingContexts: normalizeSpacingContexts(input["spacing-contexts"]),
    glyphLanguage: (input["glyph-language"] as GlyphLanguage | undefined) ?? undefined,
    colorModes: input["color-modes"] ? {
      light: input["color-modes"].light,
      dark: input["color-modes"].dark,
    } : undefined,
    scopedVars: input["scoped-vars"] ? {
      prefix: input["scoped-vars"].prefix ?? "theme",
      sections: input["scoped-vars"].sections || {},
      vars: input["scoped-vars"].vars || [],
    } : undefined,
    cssSnippets: input["css-snippets"] || [],
    jsxSnippets: input["jsx-snippets"] || [],
    cssLoads: input["css-load"] || [],
    jsxLoads: input["jsx-load"] || [],
    themeDir: themeDir ?? path.join(process.cwd(), "src", "config", "theme-style-guide"),
  };
}

function normalizeSpacingContexts(raw: SimpleStyleGuideConfig["spacing-contexts"]): SpacingContexts | undefined {
  if (!raw) return undefined;
  return {
    grid: raw.grid
      ? { columns: raw.grid.columns, gutterToken: raw.grid["gutter-token"], marginToken: raw.grid["margin-token"] }
      : { columns: 12, gutterToken: "col-gap", marginToken: "space-5" },
    pageContainer: raw["page-container"]
      ? { maxWidth: raw["page-container"]["max-width"], paddingXToken: raw["page-container"]["padding-x-token"], paddingYToken: raw["page-container"]["padding-y-token"] }
      : { maxWidth: "1280px", paddingXToken: "space-5", paddingYToken: "space-4" },
    sectionSpacing: (raw["section-spacing"] || []).map((s) => ({ role: s.role, token: s.token })),
  };
}
