import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { resolve, relative } from "node:path";

const execFileAsync = promisify(execFile);

const MAX_BUFFER = 64 * 1024 * 1024; // 64MB — large repos / dumps

/**
 * Resolve the git work-tree root that contains `cwd`.
 * Throws a helpful error if `cwd` is not inside a git repository.
 */
export async function gitRoot(cwd: string): Promise<string> {
  try {
    const { stdout } = await execFileAsync(
      "git",
      ["rev-parse", "--show-toplevel"],
      { cwd, maxBuffer: MAX_BUFFER }
    );
    return stdout.trim();
  } catch {
    throw new Error(
      `Not inside a git repository: ${resolve(cwd)} (git rev-parse failed)`
    );
  }
}

/**
 * List git-tracked files under `dir` (respects .gitignore, excludes untracked).
 * Returns paths relative to the git root.
 */
export async function lsFiles(dir: string): Promise<string[]> {
  const root = await gitRoot(dir);
  const absDir = resolve(dir);
  // Limit `git ls-files` to the requested subdirectory via a pathspec.
  const pathspec = relative(root, absDir) || ".";
  const { stdout } = await execFileAsync(
    "git",
    ["ls-files", "-z", "--", pathspec],
    { cwd: root, maxBuffer: MAX_BUFFER }
  );
  return stdout
    .split("\0")
    .map((l) => l.trim())
    .filter((l) => l.length > 0);
}

/** Resolve git root and return both root and the tracked files under `dir`. */
export async function gitRootAndFiles(
  dir: string
): Promise<{ root: string; files: string[] }> {
  const root = await gitRoot(dir);
  const files = await lsFiles(dir);
  return { root, files };
}
