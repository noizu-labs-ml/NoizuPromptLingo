"use client";

import React from "react";
import type { GraphNode } from "../ProjectGraph.types";

/**
 * DetailPanel.Fallback — Generic detail for milestone, fork, merge, and
 * any future node types. Renders data as key-value pairs. (Architecture §5.1)
 */

interface DetailPanelFallbackProps {
  node: GraphNode;
}

const kvRow: React.CSSProperties = {
  display: "flex",
  gap: "8px",
  marginBottom: 4,
  alignItems: "flex-start",
};

const kvLabel: React.CSSProperties = {
  fontFamily: "var(--font-mono)",
  fontSize: "var(--font-size-2xs, 10px)",
  color: "var(--text-muted)",
  minWidth: 80,
  flexShrink: 0,
};

const kvValue: React.CSSProperties = {
  fontFamily: "var(--font-sans, var(--font-body))",
  fontSize: "var(--font-size-xs)",
  color: "var(--text)",
  wordBreak: "break-word",
};

export function DetailPanelFallback({ node }: DetailPanelFallbackProps) {
  const data = node.data as Record<string, unknown>;

  // Render known fields as readable KV pairs, skip complex objects for now
  const entries = Object.entries(data).filter(([, v]) => {
    const t = typeof v;
    return t === "string" || t === "number" || t === "boolean";
  });

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "2px" }}>
      <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)", textTransform: "uppercase", letterSpacing: "0.06em", marginBottom: 8 }}>
        {node.type} details
      </span>

      {entries.length === 0 ? (
        <span style={{ fontFamily: "var(--font-sans, var(--font-body))", fontSize: "var(--font-size-xs)", color: "var(--text-muted)", fontStyle: "italic" }}>
          No additional details available
        </span>
      ) : (
        entries.map(([key, value]) => (
          <div key={key} style={kvRow}>
            <span style={kvLabel}>{key}</span>
            <span style={kvValue}>{String(value)}</span>
          </div>
        ))
      )}
    </div>
  );
}

export default DetailPanelFallback;
