"use client";

import React, { memo } from "react";
import type { NodeProps } from "@xyflow/react";
import { Handle, Position } from "@xyflow/react";
import type { ForkData } from "../ProjectGraph.types";

/**
 * ForkNode — Agent decision fork. Trapezoid shape (wider at bottom), violet accent,
 * branch count, pulsing when evaluating. (Spec §17.1)
 */

function ForkNodeInner({ data, selected }: NodeProps & { data: ForkData }) {
  const d = data as ForkData;
  const isEvaluating = d.status === "evaluating";
  const isDecided = d.status === "decided";
  const isStale = d.status === "stale";
  const borderColor = isDecided ? "var(--success)" : isStale ? "var(--gray-400)" : "var(--graph-fork-border, var(--violet))";

  return (
    <div style={{
      width: 200,
      padding: "8px 12px",
      borderRadius: "var(--radius-md, 6px)",
      border: `2px solid ${selected ? "var(--blue)" : borderColor}`,
      background: "var(--graph-fork-bg, var(--violet-light, color-mix(in srgb, var(--violet) 8%, var(--surface))))",
      clipPath: "polygon(8% 0%, 92% 0%, 100% 100%, 0% 100%)", // trapezoid wider at bottom
      display: "flex",
      flexDirection: "column",
      gap: "4px",
      ...(isEvaluating ? { animation: "fork-pulse 3s ease-in-out infinite" } : {}),
    }}>
      <Handle type="target" position={Position.Left} style={{ background: "var(--violet)", width: 6, height: 6 }} />
      <Handle type="source" position={Position.Bottom} style={{ background: "var(--violet)", width: 6, height: 6 }} />

      {/* Header */}
      <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
        <span style={{ fontSize: "var(--font-size-sm)" }}>⑂</span>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.08em", color: "var(--violet)" }}>FORK</span>
        {/* Agent badge */}
        <span style={{ marginLeft: "auto", width: 16, height: 16, borderRadius: "20%", background: "var(--violet)", color: "#fff", fontSize: "8px", display: "flex", alignItems: "center", justifyContent: "center" }}>⬢</span>
      </div>

      {/* Question */}
      <span style={{ fontFamily: "var(--font-sans, var(--font-body))", fontSize: "var(--font-size-sm)", fontWeight: 500, color: "var(--text)", lineHeight: 1.3 }}>
        {d.question}
      </span>

      {/* Status + branch count */}
      <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
        {isEvaluating && <span style={{ padding: "1px 6px", borderRadius: "999px", background: "color-mix(in srgb, var(--violet) 15%, transparent)", color: "var(--violet)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600 }}>evaluating</span>}
        {isDecided && <span style={{ padding: "1px 6px", borderRadius: "999px", background: "color-mix(in srgb, var(--success) 12%, transparent)", color: "var(--success)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600 }}>decided</span>}
        {isStale && <span style={{ padding: "1px 6px", borderRadius: "999px", background: "color-mix(in srgb, var(--warning) 12%, transparent)", color: "var(--warning)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600 }}>⚠ stale</span>}
        <span style={{ marginLeft: "auto", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>{d.branches.length} branches</span>
      </div>

      {isDecided && d.winnerId && (
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--success)" }}>
          → {d.branches.find((b) => b.id === d.winnerId)?.label ?? "selected"}
        </span>
      )}

      {isEvaluating && <style>{`@keyframes fork-pulse { 0%,100% { opacity: 1; } 50% { opacity: 0.6; } }`}</style>}
    </div>
  );
}

export const ForkNode = memo(ForkNodeInner);
export default ForkNode;
