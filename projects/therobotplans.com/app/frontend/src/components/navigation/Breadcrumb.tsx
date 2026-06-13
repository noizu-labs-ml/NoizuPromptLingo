"use client";

import React from "react";

/**
 * Breadcrumb — Hierarchical path indicator with clickable ancestors and smart truncation.
 *
 * @example
 * ```tsx
 * <Breadcrumb path={[{ label: "Projects", href: "/projects" }, { label: "tobornalp", href: "/projects/tobornalp" }, { label: "Sprint 14" }]} />
 * <Breadcrumb path={longPath} maxVisible={3} separator="›" />
 * ```
 */

interface BreadcrumbItem { label: string; href?: string; }

interface BreadcrumbProps {
  path: BreadcrumbItem[];
  separator?: string;
  maxVisible?: number;
  onNavigate?: (href: string) => void;
}

export function Breadcrumb({ path, separator = "›", maxVisible = 4, onNavigate }: BreadcrumbProps) {
  if (path.length === 0) return null;

  let visibleItems = path;
  let truncated = false;

  if (path.length > maxVisible) {
    const first = path[0];
    const last = path.slice(-(maxVisible - 1));
    visibleItems = [first, { label: "…" }, ...last];
    truncated = true;
  }

  return (
    <nav aria-label="Breadcrumb" style={{ display: "flex", alignItems: "center", gap: "4px", flexWrap: "wrap" }}>
      {visibleItems.map((item, i) => {
        const isLast = i === visibleItems.length - 1;
        const isEllipsis = item.label === "…";

        return (
          <React.Fragment key={i}>
            {i > 0 && (
              <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)", userSelect: "none" }} aria-hidden="true">
                {separator}
              </span>
            )}
            {isEllipsis ? (
              <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)" }}>…</span>
            ) : isLast ? (
              <span aria-current="page" style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontWeight: 600, color: "var(--text)" }}>
                {item.label}
              </span>
            ) : item.href ? (
              <button
                type="button"
                onClick={() => onNavigate?.(item.href!)}
                style={{ background: "none", border: "none", padding: 0, fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text-secondary)", cursor: "pointer", textDecoration: "none" }}
              >
                {item.label}
              </button>
            ) : (
              <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text-secondary)" }}>{item.label}</span>
            )}
          </React.Fragment>
        );
      })}
    </nav>
  );
}

export default Breadcrumb;
