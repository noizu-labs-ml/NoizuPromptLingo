"use client";

import React, { memo } from "react";
import type { NodeProps } from "@xyflow/react";
import { Handle, Position } from "@xyflow/react";
import type { RoleData } from "../ProjectGraph.types";

/**
 * RoleNode — Job slot node with avatar (circle=human, hexagon=agent),
 * role name, and subtask progress badge. (Spec §3.2)
 */

function RoleNodeInner({ data, selected }: NodeProps & { data: RoleData }) {
  const d = data as RoleData;
  const assigned = !!d.assignee;
  const allDone = d.subtaskProgress.done === d.subtaskProgress.total && d.subtaskProgress.total > 0;
  const activeColor = d.isAgent ? "var(--violet)" : "var(--blue)";
  const topAccent = allDone ? "var(--success)" : assigned ? activeColor : "var(--gray-300)";

  return (
    <div style={{ width: 180, borderRadius: "var(--radius-md, 6px)", border: `1px solid ${selected ? "var(--blue)" : "var(--graph-node-border, var(--border))"}`, borderTop: `2px solid ${topAccent}`, background: "var(--surface-alt, var(--surface))", boxShadow: "var(--graph-node-shadow, 0 1px 3px rgba(0,0,0,0.08))", opacity: allDone ? 0.6 : 1, display: "flex", flexDirection: "column", alignItems: "center", padding: "10px 8px 8px", gap: "4px" }}>
      <Handle type="target" position={Position.Left} style={{ background: "var(--graph-port-color, var(--blue))", width: 6, height: 6 }} />
      <Handle type="source" position={Position.Right} style={{ background: "var(--graph-port-color, var(--blue))", width: 6, height: 6 }} />

      {/* Avatar */}
      <div style={{ width: 32, height: 32, borderRadius: d.isAgent ? "20%" : "50%", border: assigned ? "none" : "2px dashed var(--gray-300)", background: assigned ? (d.isAgent ? "var(--violet)" : "var(--text-muted)") : "transparent", display: "flex", alignItems: "center", justifyContent: "center", color: assigned ? "#fff" : "var(--gray-300)", fontSize: assigned ? "14px" : "16px", fontWeight: 600, transition: "all 0.2s" }}>
        {assigned ? (d.isAgent ? "⬢" : (d.assignee!.name.charAt(0).toUpperCase())) : "+"}
        {allDone && assigned && <span style={{ position: "absolute", fontSize: "10px", color: "var(--success)" }}>✓</span>}
      </div>

      {/* Role name */}
      <span style={{ fontFamily: "var(--font-sans, var(--font-body))", fontSize: "var(--font-size-xs)", fontWeight: 500, color: assigned ? "var(--text)" : "var(--text-muted)", textAlign: "center" }}>
        {assigned ? d.assignee!.name : d.roleName}
      </span>

      {/* Subtitle (role title when assigned) */}
      {assigned && d.roleName !== d.assignee!.name && (
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>{d.roleName}</span>
      )}

      {/* Progress badge */}
      <span style={{ padding: "1px 8px", borderRadius: "999px", background: allDone ? "color-mix(in srgb, var(--success) 12%, transparent)" : "color-mix(in srgb, var(--info, var(--blue)) 12%, transparent)", color: allDone ? "var(--success)" : "var(--info, var(--blue))", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600 }}>
        {d.subtaskProgress.done}/{d.subtaskProgress.total}
      </span>
    </div>
  );
}

export const RoleNode = memo(RoleNodeInner);
export default RoleNode;
