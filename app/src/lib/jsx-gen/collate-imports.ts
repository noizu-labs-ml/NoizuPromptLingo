/**
 * Import collation for JSX snippet assembly.
 *
 * Parses import statements from snippet bodies and imports[] arrays,
 * deduplicates and merges named imports across snippets targeting the same
 * output file, then emits a sorted, deduplicated import block.
 *
 * Supported import forms:
 *   import DefaultExport from "module"
 *   import { Named, Imports } from "module"
 *   import DefaultExport, { Named } from "module"
 *   import "module"                          (side-effect only)
 *   import type { Named } from "module"
 *   import type DefaultExport from "module"
 */

export interface ParsedImport {
  raw: string;
  isType: boolean;
  defaultImport: string | null;
  namedImports: string[];    // each entry is already trimmed, e.g. "useState", "useEffect as useEff"
  sideEffectOnly: boolean;   // import "module" with no bindings
  moduleSpecifier: string;   // bare value, no quotes
}

// Matches the full import statement on a single line (most real-world cases).
// Multi-line imports (opening brace on one line, closing on another) are
// handled by the multi-line pre-processor below.
const SINGLE_LINE_IMPORT_RE =
  /^import\s+(type\s+)?([\s\S]*?)\s+from\s+["']([^"']+)["']\s*;?\s*$/;

const SIDE_EFFECT_IMPORT_RE = /^import\s+["']([^"']+)["']\s*;?\s*$/;

/**
 * Given a raw import string (possibly spanning multiple lines due to
 * multi-line named-import lists), normalise it to a single line for parsing.
 */
function normaliseLine(raw: string): string {
  return raw.replace(/\s+/g, " ").trim();
}

/**
 * Parse named imports from the interior of `{ ... }`.
 * Handles aliases: `useState`, `useEffect as eff`, etc.
 */
function parseNamedImports(inner: string): string[] {
  return inner
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);
}

/**
 * Parse a single normalised import statement string into a ParsedImport.
 * Returns null if the string is not a valid import statement.
 */
export function parseImportStatement(raw: string): ParsedImport | null {
  const line = normaliseLine(raw);

  // Side-effect import: import "module"
  const seMatch = SIDE_EFFECT_IMPORT_RE.exec(line);
  if (seMatch) {
    return {
      raw,
      isType: false,
      defaultImport: null,
      namedImports: [],
      sideEffectOnly: true,
      moduleSpecifier: seMatch[1],
    };
  }

  const m = SINGLE_LINE_IMPORT_RE.exec(line);
  if (!m) return null;

  const isType = Boolean(m[1]?.trim());
  const bindingsPart = m[2].trim();
  const moduleSpecifier = m[3];

  let defaultImport: string | null = null;
  let namedImports: string[] = [];

  if (bindingsPart.includes("{")) {
    // Has named imports — may also have a default before the brace
    const braceStart = bindingsPart.indexOf("{");
    const braceEnd = bindingsPart.lastIndexOf("}");
    const inner = bindingsPart.slice(braceStart + 1, braceEnd);
    namedImports = parseNamedImports(inner);

    const beforeBrace = bindingsPart.slice(0, braceStart).trim().replace(/,$/, "").trim();
    if (beforeBrace) defaultImport = beforeBrace;
  } else {
    // Only a default import (or a namespace import like * as X)
    defaultImport = bindingsPart || null;
  }

  return {
    raw,
    isType,
    defaultImport,
    namedImports,
    sideEffectOnly: false,
    moduleSpecifier,
  };
}

/**
 * Extract all import statements from a block of source text.
 *
 * Returns:
 *   importStatements — the full raw import strings found
 *   remainder        — the source text with import lines removed
 */
export function extractImports(source: string): {
  importStatements: string[];
  remainder: string;
} {
  const lines = source.split("\n");
  const importStatements: string[] = [];
  const remainderLines: string[] = [];

  let i = 0;
  while (i < lines.length) {
    const line = lines[i];
    const trimmed = line.trim();

    if (trimmed.startsWith("import ") || trimmed === "import") {
      // Collect potentially multi-line import (open brace without close brace)
      let accumulated = line;
      let openBraces = (line.match(/\{/g) || []).length;
      let closeBraces = (line.match(/\}/g) || []).length;

      while (openBraces > closeBraces && i + 1 < lines.length) {
        i++;
        accumulated += "\n" + lines[i];
        openBraces += (lines[i].match(/\{/g) || []).length;
        closeBraces += (lines[i].match(/\}/g) || []).length;
      }

      importStatements.push(accumulated.trim());
    } else {
      remainderLines.push(line);
    }
    i++;
  }

  // Strip leading blank lines from remainder
  let start = 0;
  while (start < remainderLines.length && remainderLines[start].trim() === "") {
    start++;
  }

  return {
    importStatements,
    remainder: remainderLines.slice(start).join("\n"),
  };
}

// ─── Merging ───

interface MergedImport {
  isType: boolean;
  defaultImport: string | null;
  namedImports: Set<string>;
  sideEffectOnly: boolean;
  moduleSpecifier: string;
  /** Insertion order index — determines sort stability within a tier */
  order: number;
}

/**
 * Merge a list of parsed imports for the same module specifier.
 * - Named imports are unioned (deduped by exact string including aliases)
 * - Default import: first non-null wins; warn if conflicting defaults exist
 * - Side-effect-only: absorbed if there are real bindings; kept if only side-effect imports exist
 * - isType: true only if ALL imports for this module are type-only
 */
function mergeForModule(imports: ParsedImport[], order: number): MergedImport {
  const namedImports = new Set<string>();
  let defaultImport: string | null = null;
  let hasSideEffectOnly = false;
  let hasRealBindings = false;
  let allType = true;

  for (const imp of imports) {
    if (imp.sideEffectOnly) {
      hasSideEffectOnly = true;
      continue;
    }
    hasRealBindings = true;
    if (!imp.isType) allType = false;

    if (imp.defaultImport) {
      if (defaultImport === null) {
        defaultImport = imp.defaultImport;
      } else if (defaultImport !== imp.defaultImport) {
        console.warn(
          `[collate-imports] Conflicting default imports for "${imports[0].moduleSpecifier}": ` +
          `"${defaultImport}" vs "${imp.defaultImport}" — keeping first`
        );
      }
    }

    for (const n of imp.namedImports) {
      namedImports.add(n);
    }
  }

  return {
    isType: hasRealBindings ? allType : false,
    defaultImport,
    namedImports,
    sideEffectOnly: hasSideEffectOnly && !hasRealBindings,
    moduleSpecifier: imports[0].moduleSpecifier,
    order,
  };
}

// ─── Ordering ───

type ImportTier = 0 | 1 | 2 | 3;

/**
 * Classify a module specifier into a sort tier:
 *   0 — react (always first)
 *   1 — react-dom, react-* (react ecosystem)
 *   2 — other third-party packages (no . or / prefix)
 *   3 — local imports (starts with . or /)
 */
function importTier(moduleSpecifier: string): ImportTier {
  if (moduleSpecifier === "react") return 0;
  if (moduleSpecifier.startsWith("react-") || moduleSpecifier === "react-dom") return 1;
  if (moduleSpecifier.startsWith(".") || moduleSpecifier.startsWith("/")) return 3;
  return 2;
}

// ─── Emission ───

/**
 * Render a MergedImport back to a TypeScript import statement string.
 */
function renderImport(merged: MergedImport): string {
  const typeKeyword = merged.isType ? "type " : "";

  if (merged.sideEffectOnly) {
    return `import "${merged.moduleSpecifier}";`;
  }

  const namedList = [...merged.namedImports].sort();
  const hasParts = merged.defaultImport || namedList.length > 0;

  if (!hasParts) {
    // Degenerate — emit side-effect form
    return `import "${merged.moduleSpecifier}";`;
  }

  const parts: string[] = [];
  if (merged.defaultImport) parts.push(merged.defaultImport);
  if (namedList.length > 0) parts.push(`{ ${namedList.join(", ")} }`);

  return `import ${typeKeyword}${parts.join(", ")} from "${merged.moduleSpecifier}";`;
}

// ─── Public API ───

/**
 * Collate import statements from multiple sources (one per snippet).
 *
 * Each entry in `importSources` is the complete list of raw import statement
 * strings for one snippet (from both its `imports[]` field and extracted from
 * its body).
 *
 * Returns a finalised, deduplicated, sorted import block string ready to
 * prepend to the generated file.
 */
export function collateImports(importSources: string[][]): string {
  // Map from moduleSpecifier → list of ParsedImports (in encounter order)
  const byModule = new Map<string, ParsedImport[]>();
  // Track insertion order per module for stable sort within tiers
  const moduleOrder = new Map<string, number>();
  let orderCounter = 0;

  for (const source of importSources) {
    for (const raw of source) {
      const parsed = parseImportStatement(raw);
      if (!parsed) {
        console.warn(`[collate-imports] Could not parse import: ${raw.slice(0, 80)}`);
        continue;
      }
      const key = parsed.moduleSpecifier;
      if (!byModule.has(key)) {
        byModule.set(key, []);
        moduleOrder.set(key, orderCounter++);
      }
      byModule.get(key)!.push(parsed);
    }
  }

  // Merge per module
  const merged: MergedImport[] = [];
  for (const [specifier, imports] of byModule) {
    merged.push(mergeForModule(imports, moduleOrder.get(specifier)!));
  }

  // Sort: by tier, then by insertion order within tier
  merged.sort((a, b) => {
    const tierDiff = importTier(a.moduleSpecifier) - importTier(b.moduleSpecifier);
    if (tierDiff !== 0) return tierDiff;
    return a.order - b.order;
  });

  if (merged.length === 0) return "";

  // Emit with blank lines between tiers
  const lines: string[] = [];
  let lastTier: ImportTier | null = null;
  for (const m of merged) {
    const tier = importTier(m.moduleSpecifier);
    if (lastTier !== null && tier !== lastTier) {
      lines.push(""); // blank line between tiers
    }
    lines.push(renderImport(m));
    lastTier = tier;
  }

  return lines.join("\n");
}
