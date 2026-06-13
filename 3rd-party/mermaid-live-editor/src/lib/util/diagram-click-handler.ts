/**
 * Click-handler and title-resolution for inter-diagram links inside rendered SVGs.
 *
 * After mermaid renders the diagram, call:
 *   attachDiagramLinkHandlers(container)  — rewrites hrefs + intercepts clicks
 *   resolveDiagramLinks(container)        — fetches human titles from the API
 */

import type { ResolveResponse } from '$lib/types/api';
import { diagramPath, extractDiagramId, isMermaidLink, navigateToDiagram } from './diagram-links';

/**
 * Find every <a> inside the container whose href starts with `mermaid://`,
 * rewrite the href to the share-view path, and attach a click handler that
 * uses SvelteKit navigation.
 */
export function attachDiagramLinkHandlers(container: HTMLElement): void {
  const anchors = container.querySelectorAll<SVGAElement | HTMLAnchorElement>('a');

  for (const anchor of anchors) {
    // SVG <a> stores its href in xlink:href or href.baseVal
    const href =
      anchor.getAttribute('xlink:href') ??
      anchor.getAttribute('href') ??
      (anchor instanceof SVGAElement ? anchor.href?.baseVal : null) ??
      '';

    if (!isMermaidLink(href)) continue;

    const id = extractDiagramId(href);
    if (!id) continue;

    // Rewrite href so that middle-click / ctrl-click opens in a new tab
    const path = diagramPath(id);
    anchor.setAttribute('href', path);
    if (anchor.hasAttribute('xlink:href')) {
      anchor.setAttribute('xlink:href', path);
    }

    // Intercept left-click for SPA navigation
    anchor.addEventListener('click', (event: Event) => {
      const mouseEvent = event as MouseEvent;
      // Respect modifier keys — let the browser handle new-tab gestures
      if (mouseEvent.metaKey || mouseEvent.ctrlKey || mouseEvent.shiftKey || mouseEvent.altKey) {
        return;
      }
      event.preventDefault();
      void navigateToDiagram(id);
    });

    // Mark as processed to avoid double-binding
    anchor.dataset.mermaidLink = id;
  }
}

/**
 * Collect all diagram IDs referenced by `mermaid://` links inside the
 * container, fetch their titles from the resolve endpoint, and patch the
 * visible text of each link that currently shows the raw ID.
 */
export async function resolveDiagramLinks(container: HTMLElement): Promise<void> {
  const idSet = new Set<string>();

  const anchors = container.querySelectorAll<SVGAElement | HTMLAnchorElement>('a');
  for (const anchor of anchors) {
    const id = anchor.dataset.mermaidLink;
    if (id) idSet.add(id);
  }

  if (idSet.size === 0) return;

  const ids = [...idSet];
  let resolved: Record<string, string> = {};

  try {
    const response = await fetch(
      `/api/diagrams/resolve?ids=${ids.map(encodeURIComponent).join(',')}`
    );
    if (!response.ok) return;
    const body = (await response.json()) as ResolveResponse;
    resolved = body.resolved;
  } catch {
    // API unavailable — leave link text as-is
    return;
  }

  // Patch text content for links whose visible text matches the raw ID
  for (const anchor of anchors) {
    const id = anchor.dataset.mermaidLink;
    if (!id || !resolved[id]) continue;

    const title = resolved[id];
    const textNode = anchor.querySelector('text, span') ?? anchor;
    if (textNode.textContent?.trim() === id) {
      textNode.textContent = title;
    }

    // Also set a tooltip
    anchor.setAttribute('title', title);
  }
}
