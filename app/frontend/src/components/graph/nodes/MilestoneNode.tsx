"use client";

import React, { memo } from "react";
import type { NodeProps } from "@xyflow/react";
import { Handle, Position } from "@xyflow/react";
import type { MilestoneData } from "../ProjectGraph.types";

/**
 * MilestoneNode — Diamond gate node with progress fill. (Spec §3.4)
 */

const statusStyle: Record<string, { border: string; fill: string }> = {
  "not-reached": { border: "var(--gray-300)", fill: "transparent" },
  approaching: { border: "var(--blue)", fill: "var(--blue)" },
  satisfied: { border: "var(--success)", fill: "var(--success)" },
  overdue: { border: "var(--error)", fill: "var(--error)" },
};

function MilestoneNodeInner({ data, selected }: NodeProps & { data: MilestoneData }) {
  const d = data as MilestoneData;
  const ss = statusStyle[d.status] ?? statusStyle["not-reached"];
  const fillPct = d.status === "satisfied" ? 100 : d.progress;

  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: "4px" }}>
      <Handle type="target" position={Position.Left} style={{ background: "var(--graph-port-color, var(--blue))", width: 5, height: 5 }} />
      <Handle type="source" position={Position.Right} style={{ background: "var(--graph-port-color, var(--blue))", width: 5, height: 5 }} />

      {/* Diamond */}
      <div style={{ width: 40, height: 40, transform: "rotate(45deg)", borderRadius: 4, border: `2px solid ${selected ? "var(--blue)" : ss.border}`, background: "var(--surface)", overflow: "hidden", position: "relative", ...(d.status === "overdue" ? { animation: "milestone-pulse 2s ease-in-out infinite" } : {}) }}>
        {/* Fill from bottom */}
        <div style={{ position: "absolute", bottom: 0, left: 0, right: 0, height: `${fillPct}%`, background: ss.fill, opacity: 0.3, transition: "height 0.5s" }} />
      </div>

      {/* Label */}
      <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text)", fontWeight: 500, textAlign: "center", maxWidth: 100 }}>
        {d.title}
      </span>

      {/* Date */}
      {d.dueDate && (
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>
          {d.dueDate}
        </span>
      )}

      {d.status === "overdue" && <style>{`@keyframes milestone-pulse { 0%,100% { border-color: var(--error); } 50% { border-color: transparent; } }`}</style>}
    </div>
  );
}

export const MilestoneNode = memo(MilestoneNodeInner);
export default MilestoneNode;
