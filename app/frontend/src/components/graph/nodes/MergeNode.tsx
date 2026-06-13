"use client";

import React, { memo } from "react";
import type { NodeProps } from "@xyflow/react";
import { Handle, Position } from "@xyflow/react";
import type { MergeData } from "../ProjectGraph.types";

/**
 * MergeNode — Inverted trapezoid (wider at top) convergence point. (Spec §17.3)
 */

function MergeNodeInner({ data, selected }: NodeProps & { data: MergeData }) {
  const d = data as MergeData;
  const isDecided = d.status === "decided";
  const borderColor = isDecided ? "var(--graph-merge-border-resolved, var(--success))" : "var(--graph-merge-border-pending, var(--violet))";

  return (
    <div style={{
      width: 200,
      padding: "8px 12px",
      borderRadius: "var(--radius-md, 6px)",
      border: `2px ${isDecided ? "solid" : "dashed"} ${selected ? "var(--blue)" : borderColor}`,
      background: isDecided ? "var(--graph-merge-bg-resolved, color-mix(in srgb, var(--success) 6%, var(--surface)))" : "var(--surface-alt, var(--surface))",
      clipPath: "polygon(0% 0%, 100% 0%, 92% 100%, 8% 100%)", // inverted trapezoid
      display: "flex",
      flexDirection: "column",
      gap: "4px",
    }}>
      <Handle type="target" position={Position.Top} style={{ background: isDecided ? "var(--success)" : "var(--violet)", width: 6, height: 6 }} />
      <Handle type="source" position={Position.Right} style={{ background: isDecided ? "var(--success)" : "var(--violet)", width: 6, height: 6 }} />

      {/* Header */}
      <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
        <span style={{ fontSize: "var(--font-size-sm)" }}>⑃</span>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.08em", color: isDecided ? "var(--success)" : "var(--violet)" }}>MERGE</span>
        {d.decidedBy && (
          <span style={{ marginLeft: "auto", width: 16, height: 16, borderRadius: "20%", background: "var(--violet)", color: "#fff", fontSize: "8px", display: "flex", alignItems: "center", justifyContent: "center" }}>⬢</span>
        )}
      </div>

      {/* Result */}
      {isDecided ? (
        <>
          <span style={{ fontFamily: "var(--font-sans, var(--font-body))", fontSize: "var(--font-size-sm)", fontWeight: 500, color: "var(--text)" }}>
            Winner: {d.winnerId ?? "—"}
          </span>
          {d.rationale && (
            <span style={{ fontFamily: "var(--font-sans, var(--font-body))", fontSize: "var(--font-size-xs)", color: "var(--text-secondary)", fontStyle: "italic" }}>
              "{d.rationale}"
            </span>
          )}
        </>
      ) : (
        <span style={{ fontFamily: "var(--font-sans, var(--font-body))", fontSize: "var(--font-size-xs)", color: "var(--text-muted)", fontStyle: "italic" }}>
          Awaiting evaluation...
        </span>
      )}
    </div>
  );
}

export const MergeNode = memo(MergeNodeInner);
export default MergeNode;
