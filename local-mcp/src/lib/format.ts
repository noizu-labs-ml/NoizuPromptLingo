import { readFile } from "node:fs/promises";

/** Default directory names ignored by traversal-based tools. */
export const DEFAULT_IGNORE = ["**/node_modules/**", "**/.git/**", "**/dist/**"];

/**
 * Read a file as UTF-8 text. Throws a tagged error on binary/decode failure so
 * callers can skip the file and note it rather than crashing.
 */
export async function readText(absPath: string): Promise<string> {
  const buf = await readFile(absPath);
  // Heuristic: a NUL byte in the first 8KB means binary.
  const probe = buf.subarray(0, 8192);
  if (probe.includes(0)) {
    throw new Error("BINARY");
  }
  return buf.toString("utf8");
}

/** Format file contents as a dump block: `# path\n---\n<contents>\n* * *\n`. */
export function dumpBlock(relPath: string, contents: string): string {
  return `# ${relPath}\n---\n${contents}\n* * *\n`;
}

/** Prefix each line with a right-aligned line number, cat -n style. */
export function withLineNumbers(text: string, startLine = 1): string {
  const lines = text.split("\n");
  // Drop a trailing empty line produced by a final newline.
  if (lines.length > 0 && lines[lines.length - 1] === "") {
    lines.pop();
  }
  const width = String(startLine + lines.length - 1).length;
  return lines
    .map((line, i) => `${String(startLine + i).padStart(width, " ")}\t${line}`)
    .join("\n");
}

/** Build a RegExp from a pattern string, raising a friendly error on bad regex. */
export function buildRegex(pattern: string, ignoreCase = false): RegExp {
  try {
    return new RegExp(pattern, ignoreCase ? "i" : "");
  } catch (e) {
    throw new Error(
      `Invalid regular expression: ${pattern} (${(e as Error).message})`
    );
  }
}
