/**
 * Inter-diagram link utilities.
 *
 * Parses `mermaid://DIAGRAM_ID` URLs embedded in rendered SVG <a> elements,
 * resolves their human-readable titles via the backend, and rewrites the
 * links to point at `/d/{id}`.
 */

const MERMAID_PROTOCOL = 'mermaid://';

/** Returns true when `href` uses the mermaid:// protocol. */
export function isMermaidLink(href: string): boolean {
  return href.startsWith(MERMAID_PROTOCOL);
}

/** Extracts the diagram ID from a `mermaid://DIAGRAM_ID` URL. */
export function extractDiagramId(href: string): string | null {
  if (!isMermaidLink(href)) return null;
  const id = href.slice(MERMAID_PROTOCOL.length).split(/[?#]/)[0];
  return id.length > 0 ? id : null;
}

/** Builds a local route path for a diagram share view. */
export function diagramPath(id: string): string {
  return `/d/${encodeURIComponent(id)}`;
}

/**
 * Navigates to a diagram's share page.
 * Uses SvelteKit's `goto` when available, falling back to plain assignment.
 */
export async function navigateToDiagram(id: string): Promise<void> {
  try {
    const { goto } = await import('$app/navigation');
    await goto(diagramPath(id));
  } catch {
    window.location.href = diagramPath(id);
  }
}
