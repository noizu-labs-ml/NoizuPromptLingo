"use client";

import React from "react";

/**
 * OkrNode — Tree node for Objective or Key Result with progress, visibility badge, linked item count.
 *
 * @example
 * ```tsx
 * <OkrNode title="Increase ARR to $1M" type="objective" progress={65} visibility="org" linkedItemCount={12} />
 * <OkrNode title="Close 15 enterprise deals" type="key_result" progress={40} visibility="team" linkedItemCount={3} stale variant="compact" />
 * ```
 */

type OkrType = "objective" | "key_result";
type Visibility = "personal" | "team" | "org";
type OkrVariant = "inline" | "compact" | "expanded";

interface OkrNodeProps {
  title: string;
  type: OkrType;
  progress: number;
  visibility?: Visibility;
  linkedItemCount?: number;
  stale?: boolean;
  expanded?: boolean;
  variant?: OkrVariant;
  onToggle?: () => void;
  onClick?: () => void;
}

const visConfig: Record<Visibility, { label: string; icon: string }> = {
  personal: { label: "Personal", icon: "👤" },
  team: { label: "Team", icon: "👥" },
  org: { label: "Org", icon: "🏢" },
};

function progressColor(v: number): string {
  if (v >= 70) return "var(--success)";
  if (v >= 30) return "var(--warning)";
  return "var(--error)";
}

export function OkrNode({ title, type, progress, visibility = "team", linkedItemCount, stale = false, expanded, variant = "compact", onToggle, onClick }: OkrNodeProps) {
  const clamped = Math.max(0, Math.min(100, progress));
  const color = progressColor(clamped);
  const vis = visConfig[visibility];
  const isObjective = type === "objective";
  const interactive = !!onClick;

  if (variant === "inline") {
    return (
      <span role={interactive ? "button" : undefined} tabIndex={interactive ? 0 : undefined} onClick={onClick} onKeyDown={interactive ? (e) => e.key === "Enter" && onClick?.() : undefined} aria-label={`${title}: ${clamped}%`} style={{ display: "inline-flex", alignItems: "center", gap: "6px", cursor: interactive ? "pointer" : "default" }}>
        {onToggle && <button type="button" onClick={(e) => { e.stopPropagation(); onToggle(); }} style={{ background: "none", border: "none", cursor: "pointer", padding: 0, fontSize: "var(--font-size-xs)", color: "var(--text-muted)", transform: expanded ? "rotate(90deg)" : "none", transition: "transform 0.15s" }}>›</button>}
        <span style={{ fontFamily: "var(--font-body)", fontSize: isObjective ? "var(--font-size-sm)" : "var(--font-size-xs)", fontWeight: isObjective ? 600 : 400, color: "var(--text)" }}>{title}</span>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600, color }}>{clamped}%</span>
        {stale && <span title="Stale" style={{ color: "var(--warning)", fontSize: "var(--font-size-xs)" }}>⚠</span>}
      </span>
    );
  }

  if (variant === "compact") {
    return (
      <div role={interactive ? "button" : undefined} tabIndex={interactive ? 0 : undefined} onClick={onClick} onKeyDown={interactive ? (e) => e.key === "Enter" && onClick?.() : undefined} aria-label={title} style={{ padding: "var(--space-2) var(--space-3)", borderRadius: "var(--radius, 6px)", border: `1px solid ${stale ? "var(--warning)" : "var(--border)"}`, background: "var(--surface)", cursor: interactive ? "pointer" : "default", display: "flex", flexDirection: "column", gap: "6px", borderLeft: `3px solid ${color}` }}>
        <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
          {onToggle && <button type="button" onClick={(e) => { e.stopPropagation(); onToggle(); }} aria-label={expanded ? "Collapse" : "Expand"} style={{ background: "none", border: "none", cursor: "pointer", padding: 0, fontSize: "var(--font-size-sm)", color: "var(--text-muted)", transform: expanded ? "rotate(90deg)" : "none", transition: "transform 0.15s" }}>›</button>}
          <span style={{ fontFamily: "var(--font-body)", fontSize: isObjective ? "var(--font-size-sm)" : "var(--font-size-xs)", fontWeight: isObjective ? 600 : 500, color: "var(--text)", flex: 1 }}>{title}</span>
          <span style={{ padding: "1px 6px", borderRadius: "999px", background: "color-mix(in srgb, var(--text-muted) 10%, transparent)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>{vis.icon} {vis.label}</span>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
          <div style={{ flex: 1, height: 4, borderRadius: 2, background: "color-mix(in srgb, var(--text-muted) 15%, transparent)", overflow: "hidden" }}>
            <div style={{ width: `${clamped}%`, height: "100%", background: color, borderRadius: 2, transition: "width 0.3s" }} />
          </div>
          <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600, color }}>{clamped}%</span>
          {stale && <span title="Stale — needs update" style={{ color: "var(--warning)", fontSize: "10px" }}>⚠</span>}
        </div>
      </div>
    );
  }

  // expanded
  return (
    <div role={interactive ? "button" : undefined} tabIndex={interactive ? 0 : undefined} onClick={onClick} onKeyDown={interactive ? (e) => e.key === "Enter" && onClick?.() : undefined} aria-label={title} style={{ padding: "var(--space-3)", borderRadius: "var(--radius, 6px)", border: `1px solid ${stale ? "var(--warning)" : "var(--border)"}`, background: "var(--surface)", cursor: interactive ? "pointer" : "default", display: "flex", flexDirection: "column", gap: "var(--space-2)", borderLeft: `3px solid ${color}` }}>
      <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
        {onToggle && <button type="button" onClick={(e) => { e.stopPropagation(); onToggle(); }} aria-label={expanded ? "Collapse" : "Expand"} style={{ background: "none", border: "none", cursor: "pointer", padding: 0, fontSize: "var(--font-size-base)", color: "var(--text-muted)", transform: expanded ? "rotate(90deg)" : "none", transition: "transform 0.15s" }}>›</button>}
        <span style={{ fontFamily: isObjective ? "var(--font-heading, var(--font-body))" : "var(--font-body)", fontSize: isObjective ? "var(--font-size-base)" : "var(--font-size-sm)", fontWeight: isObjective ? 700 : 500, color: "var(--text)", flex: 1 }}>{title}</span>
        <span style={{ padding: "1px 6px", borderRadius: "999px", background: "color-mix(in srgb, var(--text-muted) 10%, transparent)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>{vis.icon} {vis.label}</span>
      </div>
      <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
        <div style={{ flex: 1, height: 6, borderRadius: 3, background: "color-mix(in srgb, var(--text-muted) 15%, transparent)", overflow: "hidden" }}>
          <div style={{ width: `${clamped}%`, height: "100%", background: color, borderRadius: 3, transition: "width 0.3s" }} />
        </div>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", fontWeight: 700, color }}>{clamped}%</span>
      </div>
      <div style={{ display: "flex", gap: "var(--space-3)", flexWrap: "wrap" }}>
        {linkedItemCount != null && <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>🔗 {linkedItemCount} linked item{linkedItemCount !== 1 ? "s" : ""}</span>}
        {stale && <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--warning)", fontWeight: 600 }}>⚠ Stale — needs check-in</span>}
      </div>
    </div>
  );
}

export default OkrNode;
