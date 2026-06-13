import fs from "fs";
import path from "path";
import type { StyleGuideConfig, JsxSnippet } from "../types";
import { topoSort } from "../topo-sort";
import { collateImports, extractImports } from "./collate-imports";

const GENERATED_DIR = path.join(process.cwd(), "src", "components", "generated");

function ensureDir() {
  if (!fs.existsSync(GENERATED_DIR)) {
    fs.mkdirSync(GENERATED_DIR, { recursive: true });
  }
}

function snippetHeader(s: JsxSnippet): string {
  const lines: string[] = [];
  lines.push(`// @${s.slug}`);
  const label = [s.name, s.title].filter(Boolean).join(": ");
  if (label) lines.push(`// ${label}`);
  if (s.description) {
    for (const line of s.description.split("\n")) {
      lines.push(`// ${line}`);
    }
  }
  if (s.dependencies?.length) {
    lines.push(`// depends: ${s.dependencies.join(", ")}`);
  }
  return lines.join("\n");
}

function assembleFile(snippets: JsxSnippet[], loads: { path: string; force?: boolean }[], themeDir: string): string {
  const sorted = topoSort(snippets);

  // ── Phase 2: Import collation ──────────────────────────────────────────────
  // Gather all import sources per snippet:
  //   1. Explicit `imports` array entries (already-parsed import strings)
  //   2. Import lines extracted from the snippet body
  //
  // After collation, each snippet body has its own import lines stripped so
  // they don't appear twice in the output.

  const importSourcesPerSnippet: string[][] = [];
  const strippedBodies: string[] = [];

  for (const s of sorted) {
    const { importStatements: bodyImports, remainder } = extractImports(s.body);
    const explicitImports = s.imports ?? [];
    importSourcesPerSnippet.push([...explicitImports, ...bodyImports]);
    strippedBodies.push(remainder);
  }

  const importBlock = collateImports(importSourcesPerSnippet);

  // ── Assemble output ────────────────────────────────────────────────────────

  const parts: string[] = [];
  parts.push("// Auto-generated from YAML jsx-snippets — do not edit manually");
  parts.push('"use client";\n');

  if (importBlock) {
    parts.push(importBlock);
    parts.push(""); // blank line after imports
  }

  for (let i = 0; i < sorted.length; i++) {
    const s = sorted[i];
    const body = strippedBodies[i].trimEnd();

    // Skip snippets that had only import statements (no remaining body)
    if (!body) continue;

    parts.push(snippetHeader(s));
    parts.push(body);
    parts.push(""); // blank line between snippets
  }

  // Append jsx-load file contents
  for (const load of loads) {
    const filePath = path.resolve(themeDir, load.path);
    if (!fs.existsSync(filePath)) {
      console.error(`[jsx-load] File not found: ${filePath}`);
      continue;
    }
    const content = fs.readFileSync(filePath, "utf-8");
    parts.push(`// loaded: ${load.path}`);
    parts.push(content.trimEnd());
    parts.push("");
  }

  return parts.join("\n");
}

/**
 * Generate JSX files from jsx-snippets config.
 * Writes to src/components/generated/{section}.tsx
 * Only writes if content differs to avoid unnecessary rebuilds.
 */
export function generateJsxFiles(config: StyleGuideConfig): void {
  const snippets = config.jsxSnippets;
  const loads = config.jsxLoads;
  if (!snippets.length && !loads.length) return;

  ensureDir();

  // Group snippets by target-section
  const groups = new Map<string, JsxSnippet[]>();
  for (const s of snippets) {
    const section = s["target-section"];
    if (!groups.has(section)) groups.set(section, []);
    groups.get(section)!.push(s);
  }

  // Group loads by target-section
  const loadGroups = new Map<string, typeof loads>();
  for (const l of loads) {
    const section = l["target-section"];
    if (!loadGroups.has(section)) loadGroups.set(section, []);
    loadGroups.get(section)!.push(l);
  }

  // Merge section keys
  const allSections = new Set([...groups.keys(), ...loadGroups.keys()]);

  for (const section of allSections) {
    const sectionSnippets = groups.get(section) || [];
    const sectionLoads = loadGroups.get(section) || [];
    const content = assembleFile(sectionSnippets, sectionLoads, config.themeDir);
    const filePath = path.join(GENERATED_DIR, `${section}.tsx`);

    // Only write if changed
    const existing = fs.existsSync(filePath) ? fs.readFileSync(filePath, "utf-8") : "";
    if (content !== existing) {
      fs.writeFileSync(filePath, content, "utf-8");
    }
  }
}
