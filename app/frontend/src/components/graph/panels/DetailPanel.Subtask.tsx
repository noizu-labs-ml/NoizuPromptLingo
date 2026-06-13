"use client";

import React from "react";
import type { SubtaskData } from "../ProjectGraph.types";
import { STATUS_CONFIG } from "../ProjectGraph.types";

/**
 * DetailPanel.Subtask — Subtask detail: title, done/not-done, parent story
 * link, assignee, status. (Spec §8.3)
 */

interface DetailPanelSubtaskProps {
  data: SubtaskData;
  onNavigate: (id: string) => void;
}

const sectionLabel: React.CSSProperties = {
  fontFamily: "var(--font-mono)",
  fontSize: "var(--font-size-2xs, 10px)",
  color: "var(--text-muted)",
  textTransform: "uppercase",
  letterSpacing: "0.06em",
  margin: "12px 0 6px",
};

const fieldRow: React.CSSProperties = {
  display: "flex",
  alignItems: "center",
  gap: "6px",
  marginBottom: 4,
};

const fieldLabel: React.CSSProperties = {
  fontFamily: "var(--font-mono)",
  fontSize: "var(--font-size-2xs, 10px)",
  color: "var(--text-muted)",
  width: 70,
  flexShrink: 0,
};

const fieldValue: React.CSSProperties = {
  fontFamily: "var(--font-sans, var(--font-body))",
  fontSize: "var(--font-size-xs)",
  color: "var(--text)",
};

export function DetailPanelSubtask({ data, onNavigate }: DetailPanelSubtaskProps) {
  const sc = STATUS_CONFIG[data.status] ?? STATUS_CONFIG.pending;
  const isDone = data.status === "done";

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "2px" }}>
      {/* Task ID */}
      <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)" }}>
        {data.taskId}
      </span>

      {/* Title */}
      <h3 style={{ fontFamily: "var(--font-sans, var(--font-body))", fontSize: "var(--font-size-base, 14px)", fontWeight: 600, color: "var(--text)", margin: "4px 0 2px", lineHeight: 1.4, textDecoration: isDone ? "line-through" : "none", opacity: isDone ? 0.6 : 1 }}>
        {data.title}
      </h3>

      {/* Status */}
      <div style={fieldRow}>
        <span style={fieldLabel}>Status</span>
        <span style={{ width: 6, height: 6, borderRadius: "50%", background: sc.dotColor, flexShrink: 0 }} />
        <span style={{ ...fieldValue, color: sc.color }}>{sc.label}</span>
      </div>

      {/* Assigned via (role) */}
      <div style={fieldRow}>
        <span style={fieldLabel}>Role</span>
        <span style={fieldValue}>{data.assignedVia}</span>
      </div>

      {/* Agent work indicator */}
      {data.isAgentWork && (
        <div style={fieldRow}>
          <span style={fieldLabel}>Worker</span>
          <span style={{ padding: "1px 6px", borderRadius: 999, background: "color-mix(in srgb, var(--violet) 12%, transparent)", color: "var(--violet)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600 }}>
            agent
          </span>
        </div>
      )}

      {/* Description */}
      {data.description && (
        <>
          <div style={sectionLabel}>Description</div>
          <p style={{ fontFamily: "var(--font-sans, var(--font-body))", fontSize: "var(--font-size-xs)", color: "var(--text-secondary)", margin: 0, lineHeight: 1.5 }}>
            {data.description}
          </p>
        </>
      )}

      {/* Parent story link */}
      <div style={sectionLabel}>Parent Story</div>
      <button
        type="button"
        onClick={() => onNavigate(data.parentStoryId ?? data.assignedVia)}
        style={{
          background: "none",
          border: "1px solid var(--border)",
          borderRadius: 4,
          padding: "4px 8px",
          color: "var(--info, var(--blue))",
          fontFamily: "var(--font-mono)",
          fontSize: "var(--font-size-xs)",
          cursor: "pointer",
          textAlign: "left",
        }}
      >
        Navigate to parent →
      </button>
    </div>
  );
}

export default DetailPanelSubtask;
