"use client";

import React, { useState } from "react";

/**
 * CollapsiblePanel — Expandable/collapsible content section with header, badge, and animated toggle.
 *
 * @example
 * ```tsx
 * <CollapsiblePanel title="Advanced Options" defaultExpanded={false}>
 *   <p>Content here</p>
 * </CollapsiblePanel>
 * <CollapsiblePanel title="Comments" badge={5} defaultExpanded>
 *   <CommentList />
 * </CollapsiblePanel>
 * ```
 */

interface CollapsiblePanelProps {
  title: string;
  defaultExpanded?: boolean;
  badge?: string | number;
  children: React.ReactNode;
  onToggle?: (expanded: boolean) => void;
}

export function CollapsiblePanel({ title, defaultExpanded = false, badge, children, onToggle }: CollapsiblePanelProps) {
  const [expanded, setExpanded] = useState(defaultExpanded);

  const toggle = () => {
    const next = !expanded;
    setExpanded(next);
    onToggle?.(next);
  };

  return (
    <div style={{ borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", overflow: "hidden" }}>
      <button
        type="button"
        onClick={toggle}
        onKeyDown={(e) => (e.key === "Enter" || e.key === " ") && (e.preventDefault(), toggle())}
        aria-expanded={expanded}
        style={{
          display: "flex",
          alignItems: "center",
          gap: "8px",
          width: "100%",
          padding: "var(--space-2) var(--space-3)",
          background: "none",
          border: "none",
          cursor: "pointer",
          textAlign: "left",
        }}
      >
        <span style={{ fontSize: "var(--font-size-xs)", color: "var(--text-muted)", transform: expanded ? "rotate(90deg)" : "rotate(0deg)", transition: "transform 0.15s", lineHeight: 1 }}>
          ›
        </span>
        <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontWeight: 600, color: "var(--text)", flex: 1 }}>
          {title}
        </span>
        {badge != null && (
          <span style={{ minWidth: 18, height: 18, borderRadius: "999px", background: "color-mix(in srgb, var(--info, var(--blue)) 12%, transparent)", color: "var(--info, var(--blue))", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 700, display: "flex", alignItems: "center", justifyContent: "center", padding: "0 5px", lineHeight: 1 }}>
            {badge}
          </span>
        )}
      </button>
      {expanded && (
        <div style={{ padding: "0 var(--space-3) var(--space-3)", borderTop: "1px solid var(--border)" }}>
          {children}
        </div>
      )}
    </div>
  );
}

export default CollapsiblePanel;
