/**
 * LCS-based unified line diff for mermaid diagram source code.
 *
 * Returns a flat array of diff lines suitable for rendering in DiagramDiff.svelte.
 */

export interface DiffLine {
  type: 'added' | 'removed' | 'unchanged';
  content: string;
  /** 1-based line number in the original (source) text — null for added lines */
  oldLineNumber: number | null;
  /** 1-based line number in the new (target) text — null for removed lines */
  newLineNumber: number | null;
}

export interface DiffStats {
  added: number;
  removed: number;
  unchanged: number;
}

/**
 * Compute the Longest Common Subsequence table for two string arrays.
 * Returns a 2D matrix where lcs[i][j] = length of LCS of a[0..i-1] and b[0..j-1].
 */
function buildLCSTable(a: string[], b: string[]): number[][] {
  const m = a.length;
  const n = b.length;
  const table: number[][] = Array.from({ length: m + 1 }, () => new Array<number>(n + 1).fill(0));

  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      if (a[i - 1] === b[j - 1]) {
        table[i][j] = table[i - 1][j - 1] + 1;
      } else {
        table[i][j] = Math.max(table[i - 1][j], table[i][j - 1]);
      }
    }
  }
  return table;
}

/**
 * Back-trace the LCS table to produce a unified diff.
 */
// eslint-disable-next-line @typescript-eslint/no-unused-vars
function _backtrack(
  table: number[][],
  a: string[],
  b: string[],
  i: number,
  j: number,
  result: DiffLine[],
  counters: { old: number; new: number }
): void {
  if (i > 0 && j > 0 && a[i - 1] === b[j - 1]) {
    _backtrack(table, a, b, i - 1, j - 1, result, counters);
    counters.old++;
    counters.new++;
    result.push({
      type: 'unchanged',
      content: a[i - 1],
      oldLineNumber: counters.old,
      newLineNumber: counters.new
    });
  } else if (j > 0 && (i === 0 || table[i][j - 1] >= table[i - 1][j])) {
    _backtrack(table, a, b, i, j - 1, result, counters);
    counters.new++;
    result.push({
      type: 'added',
      content: b[j - 1],
      oldLineNumber: null,
      newLineNumber: counters.new
    });
  } else if (i > 0) {
    _backtrack(table, a, b, i - 1, j, result, counters);
    counters.old++;
    result.push({
      type: 'removed',
      content: a[i - 1],
      oldLineNumber: counters.old,
      newLineNumber: null
    });
  }
}

/**
 * Iterative version of the LCS back-track to avoid stack overflow on large diffs.
 */
function backtrackIterative(table: number[][], a: string[], b: string[]): DiffLine[] {
  const actions: { type: 'unchanged' | 'added' | 'removed'; ai: number; bj: number }[] = [];
  let i = a.length;
  let j = b.length;

  while (i > 0 || j > 0) {
    if (i > 0 && j > 0 && a[i - 1] === b[j - 1]) {
      actions.push({ type: 'unchanged', ai: i - 1, bj: j - 1 });
      i--;
      j--;
    } else if (j > 0 && (i === 0 || table[i][j - 1] >= table[i - 1][j])) {
      actions.push({ type: 'added', ai: -1, bj: j - 1 });
      j--;
    } else {
      actions.push({ type: 'removed', ai: i - 1, bj: -1 });
      i--;
    }
  }

  // Reverse because we built the list from the end
  actions.reverse();

  let oldLine = 0;
  let newLine = 0;
  return actions.map((action) => {
    switch (action.type) {
      case 'unchanged':
        oldLine++;
        newLine++;
        return {
          type: 'unchanged' as const,
          content: a[action.ai],
          oldLineNumber: oldLine,
          newLineNumber: newLine
        };
      case 'added':
        newLine++;
        return {
          type: 'added' as const,
          content: b[action.bj],
          oldLineNumber: null,
          newLineNumber: newLine
        };
      case 'removed':
        oldLine++;
        return {
          type: 'removed' as const,
          content: a[action.ai],
          oldLineNumber: oldLine,
          newLineNumber: null
        };
    }
  });
}

/**
 * Compute a unified line diff between `oldText` and `newText`.
 */
export function computeDiff(oldText: string, newText: string): DiffLine[] {
  const a = oldText.split('\n');
  const b = newText.split('\n');
  const table = buildLCSTable(a, b);
  return backtrackIterative(table, a, b);
}

/** Summarize a diff into add/remove/unchanged counts. */
export function computeDiffStats(lines: DiffLine[]): DiffStats {
  const stats: DiffStats = { added: 0, removed: 0, unchanged: 0 };
  for (const line of lines) {
    stats[line.type]++;
  }
  return stats;
}
