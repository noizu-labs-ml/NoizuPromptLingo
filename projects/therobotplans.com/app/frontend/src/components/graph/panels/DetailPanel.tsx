"use client";

import React from "react";
import type { GraphNode } from "../ProjectGraph.types";
import { DetailPanelStory } from "./DetailPanel.Story";
import { DetailPanelRole } from "./DetailPanel.Role";
import { DetailPanelSubtask } from "./DetailPanel.Subtask";
import { DetailPanelFallback } from "./DetailPanel.Fallback";

/**
 * DetailPanel — Right sidebar that shows full context for the selected node.
 * Routes to type-specific sub-panels. (Architecture §5, Spec §8)
 *
 * 340px wide, slides in from right. Uses CSS custom properties from theme.
 */

interface DetailPanelProps {
  node: GraphNode | null;
  onClose: () => void;
  onNavigate: (id: string) => void;
  side?: "right" | "bottom";
}

const panelStyle: React.CSSProperties = {
  width: 340,
  background: "var(--bg, var(--surface))",
  borderLeft: "1px solid var(--border)",
  display: "flex",
  flexDirection: "column",
  overflow: "hidden",
};

const panelBottomStyle: React.CSSProperties = {
  ...panelStyle,
  width: "100%",
  height: 280,
  borderLeft: "none",
  borderTop: "1px solid var(--border)",
};

const headerStyle: React.CSSProperties = {
  display: "flex",
  alignItems: "center",
  gap: "6px",
  padding: "8px 12px",
  borderBottom: "1px solid var(--border)",
};

const badgeStyle = (color: string): React.CSSProperties => ({
  padding: "1px 6px",
  borderRadius: 999,
  background: `color-mix(in srgb, ${color} 12%, transparent)`,
  color,
  fontFamily: "var(--font-mono)",
  fontSize: "var(--font-size-2xs, 10px)",
  fontWeight: 600,
});

const closeBtnStyle: React.CSSProperties = {
  marginLeft: "auto",
  background: "none",
  border: "none",
  color: "var(--text-muted)",
  fontSize: 14,
  cursor: "pointer",
  padding: "2px 6px",
  borderRadius: 4,
  lineHeight: 1,
};

function statusColor(status?: string): string {
  switch (status) {
    case "done": return "var(--success)";
    case "blocked": return "var(--error)";
    case "in-progress": return "var(--blue)";
    case "in-review": return "var(--info, var(--blue))";
    default: return "var(--text-muted)";
  }
}

export function DetailPanel({ node, onClose, onNavigate, side = "right" }: DetailPanelProps) {
  if (!node) return null;

  const data = node.data as Record<string, unknown>;
  const nodeStatus = (data.status as string) ?? undefined;

  return (
    <aside
      style={side === "bottom" ? panelBottomStyle : panelStyle}
      role="complementary"
      aria-label="Node details"
    >
      {/* Header */}
      <div style={headerStyle}>
        <span style={badgeStyle("var(--info, var(--blue))")}>{node.type}</span>
        {nodeStatus && <span style={badgeStyle(statusColor(nodeStatus))}>{nodeStatus}</span>}
        <button type="button" onClick={onClose} style={closeBtnStyle} aria-label="Close detail panel">
          ✕
        </button>
      </div>

      {/* Type-specific content */}
      <div style={{ flex: 1, overflow: "auto", padding: "10px 12px" }}>
        {node.type === "story" && <DetailPanelStory data={node.data as any} onNavigate={onNavigate} />}
        {node.type === "role" && <DetailPanelRole data={node.data as any} />}
        {node.type === "subtask" && <DetailPanelSubtask data={node.data as any} onNavigate={onNavigate} />}
        {node.type !== "story" && node.type !== "role" && node.type !== "subtask" && (
          <DetailPanelFallback node={node} />
        )}
      </div>
    </aside>
  );
}

export default DetailPanel;
