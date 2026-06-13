"use client";

import React from "react";
import type { StoryData } from "../ProjectGraph.types";
import { PRIORITY_CONFIG, STATUS_CONFIG } from "../ProjectGraph.types";

/**
 * DetailPanel.Story — Full story detail: ID, title, description, progress bar,
 * roles with avatars, acceptance criteria checklist. (Spec §8.1)
 */

interface DetailPanelStoryProps {
  data: StoryData;
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

export function DetailPanelStory({ data, onNavigate }: DetailPanelStoryProps) {
  const pc = PRIORITY_CONFIG[data.priority] ?? PRIORITY_CONFIG.p3;
  const sc = STATUS_CONFIG[data.status] ?? STATUS_CONFIG.pending;

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "2px" }}>
      {/* Story ID + priority */}
      <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)" }}>
          {data.storyId}
        </span>
        <span style={{ padding: "1px 6px", borderRadius: 999, background: `color-mix(in srgb, ${pc.color} 12%, transparent)`, color: pc.color, fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 700 }}>
          {pc.label}
        </span>
      </div>

      {/* Title */}
      <h3 style={{ fontFamily: "var(--font-sans, var(--font-body))", fontSize: "var(--font-size-base, 14px)", fontWeight: 600, color: "var(--text)", margin: "4px 0 2px", lineHeight: 1.4 }}>
        {data.title}
      </h3>

      {/* Description */}
      {data.description && (
        <p style={{ fontFamily: "var(--font-sans, var(--font-body))", fontSize: "var(--font-size-sm)", color: "var(--text-secondary)", margin: 0, lineHeight: 1.5 }}>
          {data.description}
        </p>
      )}

      {/* Progress */}
      <div style={sectionLabel}>Progress</div>
      <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
        <div style={{ flex: 1, height: 4, borderRadius: 2, background: "color-mix(in srgb, var(--text-muted) 15%, transparent)", overflow: "hidden" }}>
          <div style={{ width: `${data.progress}%`, height: "100%", background: sc.color, borderRadius: 2, transition: "width 0.3s" }} />
        </div>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)", flexShrink: 0 }}>
          {data.progress}%
        </span>
      </div>

      {/* Roles */}
      {data.roleAvatars && data.roleAvatars.length > 0 && (
        <>
          <div style={sectionLabel}>Roles</div>
          <div style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
            {data.roleAvatars.map((ra, i) => (
              <div key={i} style={{ display: "flex", alignItems: "center", gap: "6px" }}>
                <span style={{ width: 18, height: 18, borderRadius: ra.isAgent ? "20%" : "50%", background: ra.isAgent ? "var(--violet)" : "var(--text-muted)", color: "#fff", fontSize: "8px", display: "flex", alignItems: "center", justifyContent: "center" }}>
                  {ra.isAgent ? "◇" : "○"}
                </span>
                <span style={{ fontFamily: "var(--font-sans, var(--font-body))", fontSize: "var(--font-size-xs)", color: "var(--text)" }}>
                  {ra.name}
                </span>
              </div>
            ))}
          </div>
        </>
      )}

      {/* Acceptance Criteria */}
      {data.acceptanceCriteria && data.acceptanceCriteria.length > 0 && (
        <>
          <div style={sectionLabel}>Acceptance Criteria</div>
          <div style={{ display: "flex", flexDirection: "column", gap: "3px" }}>
            {data.acceptanceCriteria.map((ac, i) => (
              <div key={i} style={{ display: "flex", alignItems: "flex-start", gap: "6px", fontFamily: "var(--font-sans, var(--font-body))", fontSize: "var(--font-size-xs)", color: ac.done ? "var(--text-muted)" : "var(--text)", textDecoration: ac.done ? "line-through" : "none" }}>
                <span style={{ flexShrink: 0 }}>{ac.done ? "☑" : "☐"}</span>
                <span>{ac.text}</span>
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  );
}

export default DetailPanelStory;
