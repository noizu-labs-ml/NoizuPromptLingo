/**
 * Topological sort for snippet ordering.
 * Items without dependencies come first.
 * Warns on cycles and appends remaining items in original order.
 */
export function topoSort<T extends { slug: string; dependencies?: string[] }>(items: T[]): T[] {
  const bySlug = new Map(items.map((item) => [item.slug, item]));
  const visited = new Set<string>();
  const result: T[] = [];

  function visit(item: T, stack: Set<string>) {
    if (visited.has(item.slug)) return;
    if (stack.has(item.slug)) {
      console.warn(`[topo-sort] Cycle detected involving "${item.slug}" — inserting in original order`);
      return;
    }
    stack.add(item.slug);
    for (const dep of item.dependencies || []) {
      const depItem = bySlug.get(dep);
      if (depItem) visit(depItem, stack);
    }
    stack.delete(item.slug);
    if (!visited.has(item.slug)) {
      visited.add(item.slug);
      result.push(item);
    }
  }

  for (const item of items) {
    visit(item, new Set());
  }

  // Append any items missed due to cycles
  for (const item of items) {
    if (!visited.has(item.slug)) {
      result.push(item);
    }
  }

  return result;
}
