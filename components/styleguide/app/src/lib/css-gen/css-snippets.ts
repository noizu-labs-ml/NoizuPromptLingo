import type { StyleGuideConfig, CssSnippet } from "../types";
import { topoSort } from "../topo-sort";
import fs from "fs";
import path from "path";

/** Built-in CSS section names — used for conflict detection with css-load */
export const BUILTIN_SECTIONS = new Set([
  "vars", "scoped-vars", "branding", "sections", "tokens", "swatches", "spacing",
  "cards", "buttons", "semantic", "typography", "indicators", "forms", "dividers",
  "shells", "hui", "utilities", "layout", "globals",
]);

function wrapDescription(text: string, width = 76): string {
  const words = text.split(/\s+/);
  const lines: string[] = [];
  let current = "";
  for (const word of words) {
    if (current.length + word.length + 1 > width) {
      lines.push(` * ${current}`);
      current = word;
    } else {
      current = current ? `${current} ${word}` : word;
    }
  }
  if (current) lines.push(` * ${current}`);
  return lines.join("\n");
}

function snippetHeader(snippet: CssSnippet): string {
  const parts: string[] = ["/**"];
  const label = [snippet["target-section"], snippet.title].filter(Boolean).join(": ");
  if (label) parts.push(` * ${label}`);
  if (snippet.description) {
    parts.push(" *");
    parts.push(wrapDescription(snippet.description));
  }
  parts.push(" */");
  return parts.join("\n");
}

export function generateCssSnippetsCSS(config: StyleGuideConfig): string {
  const snippets = config.cssSnippets;
  const loads = config.cssLoads;
  if (!snippets.length && !loads.length) return "";

  // Group snippets by target-section
  const groups = new Map<string, CssSnippet[]>();
  for (const s of snippets) {
    const target = s["target-section"] || "ungrouped";
    if (!groups.has(target)) groups.set(target, []);
    groups.get(target)!.push(s);
  }

  const parts: string[] = [];

  // Emit snippet groups
  for (const [target, group] of groups) {
    const sorted = topoSort(group);
    const sectionParts: string[] = [];
    for (const s of sorted) {
      sectionParts.push(snippetHeader(s));
      sectionParts.push(s.body.trimEnd());
    }
    parts.push(`/* ── ${target} ── */\n${sectionParts.join("\n\n")}`);
  }

  // Append css-load file contents
  for (const load of loads) {
    const target = load["target-section"];
    // Conflict check
    if (BUILTIN_SECTIONS.has(target) && !load.force) {
      console.error(`[css-load] Error: target-section "${target}" conflicts with built-in section. Use force: true to override.`);
      continue;
    }
    if (BUILTIN_SECTIONS.has(target) && load.force) {
      console.warn(`[css-load] Warning: force-loading into built-in section "${target}"`);
    }
    const filePath = path.resolve(config.themeDir, load.path);
    if (!fs.existsSync(filePath)) {
      console.error(`[css-load] File not found: ${filePath}`);
      continue;
    }
    const content = fs.readFileSync(filePath, "utf-8");
    parts.push(`/* ── ${target} (loaded: ${load.path}) ── */\n${content.trimEnd()}`);
  }

  return parts.join("\n\n");
}
