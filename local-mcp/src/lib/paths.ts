import { resolve, relative, isAbsolute, sep } from "node:path";

/**
 * Resolve `p` against `root` and guard against escaping `root` via `../`,
 * absolute paths, or symlink-style traversal expressed in the literal path.
 *
 * Returns the resolved absolute path. Throws if the result lands outside root.
 */
export function resolveWithin(root: string, p: string): string {
  const absRoot = resolve(root);
  const target = isAbsolute(p) ? resolve(p) : resolve(absRoot, p);
  const rel = relative(absRoot, target);

  // `rel` starting with ".." (or being an absolute path on a different volume)
  // means `target` is not contained within `absRoot`.
  if (rel === "" ) {
    return target;
  }
  if (rel.startsWith("..") && (rel.length === 2 || rel[2] === sep)) {
    throw new Error(`Path escapes root: ${p} (root: ${absRoot})`);
  }
  if (isAbsolute(rel)) {
    throw new Error(`Path escapes root: ${p} (root: ${absRoot})`);
  }
  return target;
}
