"use client";

import React, { memo } from "react";
import type { NodeProps } from "@xyflow/react";
import { Handle, Position } from "@xyflow/react";
import type { SubtaskData } from "../ProjectGraph.types";
import { STATUS_CONFIG } from "../ProjectGraph.types";

/**
 * SubtaskNode — Smallest node. Status dot + title + task ID. (Spec §3.3)
 */

function SubtaskNodeInner({ data, selected }: NodeProps & { data: SubtaskData }) {
  const d = data as SubtaskData;
  const sc = STATUS_CONFIG[d.status] ?? STATUS_CONFIG.pending;
  const isDone = d.status === "done";
  const isBlocked = d.status === "blocked";
  const isInProgress = d.status === "in-progress";
  const agentColor = d.isAgentWork ? "var(--violet)" : sc.dotColor;

  return (
    <div style={{
      width: 160,
      padding: "5px 8px",
      borderRadius: "var(--radius-sm, 4px)",
      border: `1px ${isBlocked ? "dashed" : "solid"} ${selected ? "var(--blue)" : isBlocked ? "var(--error)" : "var(--graph-node-border, var(--border))"}`,
      background: isBlocked ? "var(--error-tint, color-mix(in srgb, var(--error) 6%, var(--surface)))" : "var(--graph-node-bg, var(--surface))",
      opacity: isDone ? 0.5 : 1,
      display: "flex",
      alignItems: "center",
      gap: "6px",
      ...(isInProgress ? { boxShadow: `0 0 4px ${agentColor}40` } : {}),
    }}>
      <Handle type="target" position={Position.Left} style={{ background: "var(--graph-port-color, var(--blue))", width: 5, height: 5 }} />
      <Handle type="source" position={Position.Right} style={{ background: "var(--graph-port-color, var(--blue))", width: 5, height: 5 }} />

      {/* Status dot */}
      <span style={{ width: 6, height: 6, borderRadius: "50%", background: isInProgress && d.isAgentWork ? "var(--violet)" : sc.dotColor, flexShrink: 0 }} />

      {/* Title */}
      <span style={{ fontFamily: "var(--font-sans, var(--font-body))", fontSize: "var(--font-size-xs)", color: "var(--text)", flex: 1, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap", textDecoration: isDone ? "line-through" : "none" }}>
        {d.title}
      </span>

      {/* Task ID */}
      <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", flexShrink: 0 }}>
        {d.taskId.replace(/^T-0*/, "")}
      </span>
    </div>
  );
}

export const SubtaskNode = memo(SubtaskNodeInner);
export default SubtaskNode;
