import type { StyleGuideConfig, ScopedVarsConfig, ScopedVar, ScopedVarSectionValue } from "../types";

/**
 * Generate CSS from scoped-vars config.
 *
 * Produces two kinds of output:
 * 1. Variable declarations scoped to section selectors
 * 2. CSS rules that consume those variables (selector + selector-body)
 */
export function generateScopedVarsCSS(config: StyleGuideConfig): string {
  const sv = config.scopedVars;
  if (!sv || !sv.vars?.length) return "";

  const globalPrefix = sv.prefix ?? "theme";
  const sections = sv.sections || {};

  // Collect var declarations per CSS selector
  const declarations = new Map<string, string[]>();
  // Collect consuming CSS rules
  const rules: { selector: string; body: string }[] = [];
  // Collect alias mappings: bare name → prefixed var reference
  // e.g. "--surface" → "var(--theme-surface)"
  const aliases = new Map<string, { prefixedName: string; selector: string }>();

  // Find the first section to use as default for simple vars
  const defaultSectionName = Object.keys(sections)[0];
  const defaultSection = defaultSectionName ? sections[defaultSectionName] : null;

  for (const v of sv.vars) {
    if (v.values && typeof v.values === "object" && !Array.isArray(v.values)) {
      // Suffixed map: values: { suffix: value } — lands in default section
      emitSuffixedVar(v, v.values, globalPrefix, defaultSection, declarations);
    } else if (typeof v.value === "string") {
      // Simple var: single value, no sections
      emitSimpleVar(v, v.value, globalPrefix, defaultSection, declarations);
    } else if (Array.isArray(v.value)) {
      // Sectioned var: different values per section
      emitSectionedVar(v, v.value, globalPrefix, sections, declarations);
    }

    // Emit consuming rule if selector + selector-body defined
    if (v.selector && v["selector-body"]) {
      rules.push({ selector: v.selector, body: v["selector-body"] });
    }
  }

  // Build alias map from all declarations
  // For each prefixed var like --theme-surface, create --surface: var(--theme-surface)
  for (const [selector, decls] of declarations) {
    for (const decl of decls) {
      const match = decl.match(/^(--(\w+)-(.+?)):\s/);
      if (match) {
        const [, prefixedName, prefix, bareName] = match;
        // Only alias if there's a real prefix (not layout vars which already use layout- naming)
        if (prefix && prefix !== "layout") {
          const bareVarName = `--${bareName}`;
          if (!aliases.has(bareVarName)) {
            aliases.set(bareVarName, { prefixedName, selector });
          }
        }
      }
    }
  }

  // Build output
  const parts: string[] = [];

  // Emit variable declarations grouped by selector
  for (const [selector, decls] of declarations) {
    parts.push(`${selector} {\n${decls.map((d) => `  ${d}`).join("\n")}\n}`);
  }

  // Emit alias layer: bare names → prefixed vars
  // Group aliases by their source selector
  if (aliases.size > 0) {
    const aliasBySelector = new Map<string, string[]>();
    for (const [bareName, { prefixedName, selector }] of aliases) {
      if (!aliasBySelector.has(selector)) aliasBySelector.set(selector, []);
      aliasBySelector.get(selector)!.push(`  ${bareName}: var(${prefixedName});`);
    }
    for (const [selector, aliasDecls] of aliasBySelector) {
      parts.push(`/* Alias layer: bare names → themed vars */\n${selector} {\n${aliasDecls.join("\n")}\n}`);
    }
  }

  // Emit consuming rules
  for (const rule of rules) {
    parts.push(`${rule.selector} {\n  ${rule.body}\n}`);
  }

  return parts.join("\n\n");
}

function varName(prefix: string, name: string, suffix?: string): string {
  const base = prefix ? `--${prefix}-${name}` : `--${name}`;
  return suffix ? `${base}-${suffix}` : base;
}

function addDecl(map: Map<string, string[]>, selector: string, decl: string) {
  if (!map.has(selector)) map.set(selector, []);
  map.get(selector)!.push(decl);
}

function emitSuffixedVar(
  v: ScopedVar,
  values: Record<string, string>,
  globalPrefix: string,
  defaultSection: { selector: string; prefix?: string } | null,
  declarations: Map<string, string[]>,
) {
  const prefix = defaultSection?.prefix ?? globalPrefix;
  const selector = defaultSection?.selector || ":root";
  for (const [suffix, val] of Object.entries(values)) {
    const vn = varName(prefix, v.name, suffix);
    addDecl(declarations, selector, `${vn}: ${val};`);
  }
}

function emitSimpleVar(
  v: ScopedVar,
  value: string,
  globalPrefix: string,
  defaultSection: { selector: string; prefix?: string } | null,
  declarations: Map<string, string[]>,
) {
  const prefix = defaultSection?.prefix ?? globalPrefix;
  const selector = defaultSection?.selector || ":root";
  const vn = varName(prefix, v.name);
  addDecl(declarations, selector, `${vn}: ${value};`);
}

function emitSectionedVar(
  v: ScopedVar,
  entries: ScopedVarSectionValue[],
  globalPrefix: string,
  sections: Record<string, { selector: string; prefix?: string }>,
  declarations: Map<string, string[]>,
) {
  for (const entry of entries) {
    const section = sections[entry.section];
    if (!section) {
      console.warn(`[scoped-vars] Unknown section "${entry.section}" for var "${v.name}" — skipping`);
      continue;
    }
    const prefix = section.prefix ?? globalPrefix;

    if (entry.value !== undefined && entry.suffix) {
      // Single value with explicit suffix
      const vn = varName(prefix, v.name, entry.suffix);
      addDecl(declarations, section.selector, `${vn}: ${entry.value};`);
    } else if (entry.value !== undefined && !entry.suffix) {
      // Single value, no suffix
      const vn = varName(prefix, v.name);
      addDecl(declarations, section.selector, `${vn}: ${entry.value};`);
    } else if (entry.values) {
      // Multi-value: each key is a suffix
      for (const [suffix, val] of Object.entries(entry.values)) {
        const vn = varName(prefix, v.name, suffix);
        addDecl(declarations, section.selector, `${vn}: ${val};`);
      }
    }
  }
}
