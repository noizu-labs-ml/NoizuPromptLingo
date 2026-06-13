"use client";

import React from "react";

/**
 * GraphLegend — Color/shape legend for the graph. Shows node type shapes,
 * status colors, and edge type styles. (Architecture §4.1)
 */

const legendItemStyle: React.CSSProperties = {
  display: "flex",
  alignItems: "center",
  gap: "4px",
  fontFamily: "var(--font-mono)",
  fontSize: "var(--font-size-2xs, 10px)",
  color: "var(--text-muted)",
};

const NODE_LEGEND = [
  { shape: "rect", label: "Story", color: "var(--surface)", border: "var(--border)" },
  { shape: "circle", label: "Role (human)", color: "var(--text-muted)", border: "transparent" },
  { shape: "hex", label: "Role (agent)", color: "var(--violet)", border: "transparent" },
  { shape: "small-rect", label: "Subtask", color: "var(--surface)", border: "var(--border)" },
  { shape: "diamond", label: "Milestone", color: "var(--surface)", border: "var(--gray-300)" },
  { shape: "trapezoid", label: "Fork / Merge", color: "var(--violet-light, color-mix(in srgb, var(--violet) 8%, var(--surface)))", border: "var(--violet)" },
];

const STATUS_LEGEND = [
  { label: "On track", color: "var(--success)" },
  { label: "At risk", color: "var(--warning)" },
  { label: "Blocked", color: "var(--error)" },
  { label: "Complete", color: "var(--text-muted)" },
];

function ShapeIcon({ shape, color, border }: { shape: string; color: string; border: string }) {
  const size = 10;
  switch (shape) {
    case "circle":
      return <span style={{ width: size, height: size, borderRadius: "50%", background: color, flexShrink: 0 }} />;
    case "hex":
      return <span style={{ width: size, height: size, borderRadius: "20%", background: color, flexShrink: 0 }} />;
    case "diamond":
      return <span style={{ width: 8, height: 8, transform: "rotate(45deg)", border: `1.5px solid ${border}`, background: color, flexShrink: 0 }} />;
    case "small-rect":
      return <span style={{ width: 12, height: 7, borderRadius: 2, border: `1px solid ${border}`, background: color, flexShrink: 0 }} />;
    case "trapezoid":
      return <span style={{ width: 12, height: 8, borderRadius: 2, border: `1.5px solid ${border}`, background: color, flexShrink: 0 }} />;
    default: // rect
      return <span style={{ width: 14, height: 9, borderRadius: 2, border: `1px solid ${border}`, background: color, flexShrink: 0 }} />;
  }
}

export function GraphLegend() {
  return (
    <div
      style={{
        display: "flex",
        gap: "16px",
        padding: "4px 10px",
        borderTop: "1px solid var(--border)",
        background: "var(--surface-alt, var(--surface))",
        flexWrap: "wrap",
      }}
      role="img"
      aria-label="Graph legend"
    >
      {/* Node shapes */}
      <div style={{ display: "flex", gap: "8px", alignItems: "center" }}>
        {NODE_LEGEND.map((item) => (
          <div key={item.label} style={legendItemStyle}>
            <ShapeIcon shape={item.shape} color={item.color} border={item.border} />
            {item.label}
          </div>
        ))}
      </div>

      {/* Separator */}
      <div style={{ width: 1, height: 14, background: "var(--border)", alignSelf: "center" }} />

      {/* Status dots */}
      <div style={{ display: "flex", gap: "8px", alignItems: "center" }}>
        {STATUS_LEGEND.map((item) => (
          <div key={item.label} style={legendItemStyle}>
            <span style={{ width: 6, height: 6, borderRadius: "50%", background: item.color, flexShrink: 0 }} />
            {item.label}
          </div>
        ))}
      </div>
    </div>
  );
}

export default GraphLegend;
