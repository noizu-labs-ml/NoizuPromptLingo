"use client";

import React, { memo } from "react";
import type { NodeProps } from "@xyflow/react";
import { Handle, Position } from "@xyflow/react";
import type { StoryData } from "../ProjectGraph.types";
import { PRIORITY_CONFIG, STATUS_CONFIG } from "../ProjectGraph.types";

/**
 * StoryNode — The largest graph node. Rounded rectangle with left accent bar,
 * priority badge, progress bar, and role avatar stack. (Spec §3.1)
 */

function StoryNodeInner({ data, selected }: NodeProps & { data: StoryData }) {
  const d = data as StoryData;
  const pc = PRIORITY_CONFIG[d.priority] ?? PRIORITY_CONFIG.p3;
  const sc = STATUS_CONFIG[d.status] ?? STATUS_CONFIG.pending;

  const isBlocked = d.status === "blocked";
  const isDone = d.status === "done";
  const isUnstarted = d.status === "pending";

  return (
    <div
      style={{
        width: 260,
        borderRadius: "var(--radius-md, 6px)",
        border: `1px solid ${selected ? "var(--graph-selection-ring-color, var(--blue))" : isBlocked ? "var(--error)" : "var(--graph-node-border, var(--border))"}`,
        borderLeft: `3px solid ${isDone ? "var(--success)" : pc.color}`,
        background: isBlocked ? "var(--error-tint, color-mix(in srgb, var(--error) 6%, var(--surface)))" : "var(--graph-node-bg, var(--surface))",
        boxShadow: "var(--graph-node-shadow, 0 1px 3px rgba(0,0,0,0.08))",
        opacity: isDone ? 0.6 : 1,
        overflow: "hidden",
        ...(isUnstarted ? { borderStyle: "dashed" } : {}),
      }}
    >
      {/* Handles */}
      <Handle type="target" position={Position.Left} style={{ background: "var(--graph-port-color, var(--blue))", width: 6, height: 6 }} />
      <Handle type="source" position={Position.Right} style={{ background: "var(--graph-port-color, var(--blue))", width: 6, height: 6 }} />

      {/* Header: ID + priority badge */}
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "6px 10px 2px" }}>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>
          {isBlocked && "⚠ "}{isDone && "✓ "}{d.storyId}
        </span>
        <span style={{ padding: "1px 6px", borderRadius: "999px", background: `color-mix(in srgb, ${pc.color} 12%, transparent)`, color: pc.color, fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 700 }}>
          {pc.label}
        </span>
      </div>

      {/* Title */}
      <div style={{ padding: "2px 10px 6px", fontFamily: "var(--font-sans, var(--font-body))", fontSize: "var(--font-size-sm)", fontWeight: 500, color: isUnstarted ? "var(--text-muted)" : "var(--text)", lineHeight: 1.3, overflow: "hidden", display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical" as const }}>
        {d.title}
      </div>

      {/* Footer: progress bar + avatars */}
      <div style={{ padding: "4px 10px 6px", display: "flex", alignItems: "center", gap: "6px" }}>
        <div style={{ flex: 1, height: 2, borderRadius: 1, background: "color-mix(in srgb, var(--text-muted) 15%, transparent)", overflow: "hidden" }}>
          <div style={{ width: `${d.progress}%`, height: "100%", background: isDone ? "var(--success)" : sc.color, borderRadius: 1, transition: "width 0.3s" }} />
        </div>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", flexShrink: 0 }}>{d.progress}%</span>
        {d.roleAvatars && (
          <div style={{ display: "flex", marginLeft: 4 }}>
            {d.roleAvatars.slice(0, 3).map((ra, i) => (
              <span key={i} style={{ width: 16, height: 16, borderRadius: ra.isAgent ? "20%" : "50%", background: ra.isAgent ? "var(--violet)" : "var(--text-muted)", color: "#fff", fontSize: "7px", display: "flex", alignItems: "center", justifyContent: "center", marginLeft: i > 0 ? -4 : 0, border: "1.5px solid var(--surface)", zIndex: 3 - i }}>
                {ra.isAgent ? "◇" : "○"}
              </span>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

export const StoryNode = memo(StoryNodeInner);
export default StoryNode;
