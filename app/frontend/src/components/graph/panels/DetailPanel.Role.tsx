"use client";

import React from "react";
import type { RoleData } from "../ProjectGraph.types";

/**
 * DetailPanel.Role — Role detail: avatar, name, role title, assigned items,
 * capacity bar. (Spec §8.2)
 */

interface DetailPanelRoleProps {
  data: RoleData;
}

const sectionLabel: React.CSSProperties = {
  fontFamily: "var(--font-mono)",
  fontSize: "var(--font-size-2xs, 10px)",
  color: "var(--text-muted)",
  textTransform: "uppercase",
  letterSpacing: "0.06em",
  margin: "12px 0 6px",
};

export function DetailPanelRole({ data }: DetailPanelRoleProps) {
  const assigned = !!data.assignee;
  const { done, total } = data.subtaskProgress;
  const pct = total > 0 ? Math.round((done / total) * 100) : 0;
  const isAgent = data.isAgent;
  const accentColor = isAgent ? "var(--violet)" : "var(--blue)";

  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: "4px", paddingTop: 8 }}>
      {/* Avatar */}
      <div style={{
        width: 48,
        height: 48,
        borderRadius: isAgent ? "20%" : "50%",
        border: assigned ? "none" : "2px dashed var(--gray-300)",
        background: assigned ? accentColor : "transparent",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        color: assigned ? "#fff" : "var(--gray-300)",
        fontSize: assigned ? "20px" : "22px",
        fontWeight: 600,
      }}>
        {assigned ? (isAgent ? "⬢" : data.assignee!.name.charAt(0).toUpperCase()) : "+"}
      </div>

      {/* Name */}
      <span style={{ fontFamily: "var(--font-sans, var(--font-body))", fontSize: "var(--font-size-base, 14px)", fontWeight: 600, color: "var(--text)", textAlign: "center" }}>
        {assigned ? data.assignee!.name : data.roleName}
      </span>

      {/* Role title */}
      {assigned && data.roleName !== data.assignee!.name && (
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)" }}>
          {data.roleName}
        </span>
      )}

      {/* Status badge */}
      {isAgent && assigned && (
        <span style={{ padding: "1px 8px", borderRadius: 999, background: "color-mix(in srgb, var(--violet) 12%, transparent)", color: "var(--violet)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600 }}>
          agent
        </span>
      )}

      {/* Subtask progress */}
      <div style={sectionLabel}>Subtask Progress</div>
      <div style={{ width: "100%", display: "flex", alignItems: "center", gap: "8px" }}>
        <div style={{ flex: 1, height: 4, borderRadius: 2, background: "color-mix(in srgb, var(--text-muted) 15%, transparent)", overflow: "hidden" }}>
          <div style={{ width: `${pct}%`, height: "100%", background: done === total && total > 0 ? "var(--success)" : accentColor, borderRadius: 2, transition: "width 0.3s" }} />
        </div>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)", flexShrink: 0 }}>
          {done}/{total}
        </span>
      </div>

      {/* Workload note */}
      {!assigned && (
        <>
          <div style={sectionLabel}>Status</div>
          <span style={{ fontFamily: "var(--font-sans, var(--font-body))", fontSize: "var(--font-size-xs)", color: "var(--warning)", fontStyle: "italic" }}>
            Unassigned — this role slot needs a team member
          </span>
        </>
      )}
    </div>
  );
}

export default DetailPanelRole;
