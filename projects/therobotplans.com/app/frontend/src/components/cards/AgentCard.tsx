"use client";

import React from "react";

/**
 * AgentCard — AI agent team member card with avatar, name, role, status, current task.
 *
 * @example
 * ```tsx
 * <AgentCard name="PM Agent" role="Project Manager" status="active" variant="inline" />
 * <AgentCard name="QA Bot" role="Test Engineer" status="paused" currentTask="Running regression suite" onPauseResume={toggle} variant="compact" />
 * ```
 */

type AgentStatus = "active" | "paused" | "idle" | "error";
type AgentVariant = "inline" | "compact" | "expanded";

interface AgentCardProps {
  name: string;
  role: string;
  status: AgentStatus;
  currentTask?: string;
  avatar?: string;
  variant?: AgentVariant;
  onPauseResume?: () => void;
  onClick?: () => void;
}

const statusConfig: Record<AgentStatus, { color: string; label: string; icon: string }> = {
  active: { color: "var(--success)", label: "Active", icon: "●" },
  paused: { color: "var(--warning)", label: "Paused", icon: "⏸" },
  idle: { color: "var(--text-muted)", label: "Idle", icon: "○" },
  error: { color: "var(--error)", label: "Error", icon: "✗" },
};

function AgentAvatar({ name, size = 28 }: { name: string; size?: number }) {
  return (
    <span style={{ display: "inline-flex", alignItems: "center", justifyContent: "center", width: size, height: size, borderRadius: "20%", background: "var(--violet, #7C3AED)", color: "#fff", fontSize: size * 0.4, fontWeight: 600, flexShrink: 0, lineHeight: 1 }}>
      ⬢
    </span>
  );
}

export function AgentCard({ name, role, status, currentTask, variant = "compact", onPauseResume, onClick }: AgentCardProps) {
  const sc = statusConfig[status];
  const interactive = !!onClick;

  if (variant === "inline") {
    return (
      <span role={interactive ? "button" : undefined} tabIndex={interactive ? 0 : undefined} onClick={onClick} onKeyDown={interactive ? (e) => e.key === "Enter" && onClick?.() : undefined} aria-label={`${name}: ${sc.label}`} style={{ display: "inline-flex", alignItems: "center", gap: "6px", cursor: interactive ? "pointer" : "default" }}>
        <AgentAvatar name={name} size={20} />
        <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", color: "var(--text)" }}>{name}</span>
        <span style={{ width: 6, height: 6, borderRadius: "50%", background: sc.color, flexShrink: 0 }} title={sc.label} />
      </span>
    );
  }

  if (variant === "compact") {
    return (
      <div role={interactive ? "button" : undefined} tabIndex={interactive ? 0 : undefined} onClick={onClick} onKeyDown={interactive ? (e) => e.key === "Enter" && onClick?.() : undefined} aria-label={name} style={{ padding: "var(--space-2) var(--space-3)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", cursor: interactive ? "pointer" : "default", display: "flex", flexDirection: "column", gap: "6px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
          <AgentAvatar name={name} />
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontWeight: 600, color: "var(--text)" }}>{name}</div>
            <div style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>{role}</div>
          </div>
          <span style={{ padding: "2px 8px", borderRadius: "999px", background: `color-mix(in srgb, ${sc.color} 12%, transparent)`, color: sc.color, fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600 }}>{sc.icon} {sc.label}</span>
        </div>
        {currentTask && <div style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text-secondary)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>→ {currentTask}</div>}
        {onPauseResume && (
          <button type="button" onClick={(e) => { e.stopPropagation(); onPauseResume(); }} style={{ alignSelf: "flex-start", padding: "2px 10px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text-secondary)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-2xs, 10px)", cursor: "pointer" }}>
            {status === "active" ? "⏸ Pause" : "▶ Resume"}
          </button>
        )}
      </div>
    );
  }

  // expanded
  return (
    <div role={interactive ? "button" : undefined} tabIndex={interactive ? 0 : undefined} onClick={onClick} onKeyDown={interactive ? (e) => e.key === "Enter" && onClick?.() : undefined} aria-label={name} style={{ padding: "var(--space-3)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", cursor: interactive ? "pointer" : "default", display: "flex", flexDirection: "column", gap: "var(--space-2)" }}>
      <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
        <AgentAvatar name={name} size={36} />
        <div style={{ flex: 1 }}>
          <div style={{ fontFamily: "var(--font-heading, var(--font-body))", fontSize: "var(--font-size-base)", fontWeight: 600, color: "var(--text)" }}>{name}</div>
          <div style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)" }}>{role}</div>
        </div>
        <span style={{ padding: "2px 8px", borderRadius: "999px", background: `color-mix(in srgb, ${sc.color} 12%, transparent)`, color: sc.color, fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600 }}>{sc.icon} {sc.label}</span>
      </div>
      {currentTask && <div style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", color: "var(--text-secondary)", padding: "var(--space-1) var(--space-2)", borderRadius: 4, background: "color-mix(in srgb, var(--text-muted) 6%, transparent)" }}>Current: {currentTask}</div>}
      <div style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", fontStyle: "italic" }}>Metrics panel — available after integration</div>
      {onPauseResume && (
        <button type="button" onClick={(e) => { e.stopPropagation(); onPauseResume(); }} style={{ alignSelf: "flex-start", padding: "4px 12px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text-secondary)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", cursor: "pointer" }}>
          {status === "active" ? "⏸ Pause Agent" : "▶ Resume Agent"}
        </button>
      )}
    </div>
  );
}

export default AgentCard;
