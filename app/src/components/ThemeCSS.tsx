"use client";

import { useEffect, useRef } from "react";

interface Props {
  /** Theme slugs that have per-theme CSS files in /themes/{slug}.css */
  themeSlugs: string[];
  /** The default/initial theme slug (from server config) */
  defaultTheme: string;
}

/**
 * Lazy-loads per-theme CSS files. Only the active theme's stylesheet is enabled.
 *
 * When `data-design-theme` changes on <html>, this component swaps which
 * <link> tag is enabled. All theme stylesheets are preloaded as disabled
 * to make switching instant.
 *
 * To use lazy loading instead of the monolithic CSS:
 * 1. Remove `@import "./design-system.generated.css"` from globals.css
 * 2. Add <ThemeCSS> to layout.tsx
 */
export function ThemeCSS({ themeSlugs, defaultTheme }: Props) {
  const linksRef = useRef<Map<string, HTMLLinkElement>>(new Map());

  useEffect(() => {
    const links = linksRef.current;

    // Create <link> tags for each theme
    for (const slug of themeSlugs) {
      if (links.has(slug)) continue;
      const link = document.createElement("link");
      link.rel = "stylesheet";
      link.href = `/themes/${slug}.css`;
      link.dataset.themeStylesheet = slug;
      // Only enable the active theme
      link.disabled = slug !== defaultTheme;
      document.head.appendChild(link);
      links.set(slug, link);
    }

    // Activate the current theme from the DOM (may differ from defaultTheme
    // if the inline script in <head> already set it from localStorage)
    const current = document.documentElement.getAttribute("data-design-theme");
    if (current && current !== defaultTheme) {
      activateTheme(current);
    }

    // Watch for theme attribute changes
    const observer = new MutationObserver((mutations) => {
      for (const m of mutations) {
        if (m.attributeName === "data-design-theme") {
          const next = document.documentElement.getAttribute("data-design-theme");
          if (next) activateTheme(next);
        }
      }
    });
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["data-design-theme"],
    });

    function activateTheme(slug: string) {
      for (const [s, link] of links) {
        link.disabled = s !== slug;
      }
    }

    return () => {
      observer.disconnect();
      // Clean up injected link tags
      for (const link of links.values()) {
        link.remove();
      }
      links.clear();
    };
  }, [themeSlugs, defaultTheme]);

  return null;
}
