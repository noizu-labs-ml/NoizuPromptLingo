"use client";

import React from "react";

/**
 * ProjectCard — Project summary card with health indicator, methodology badge, progress bar, deadline.
 * Depends on: HealthIndicator (T0), ProgressBar (T0), Badge (T0).
 *
 * @example
 * ```tsx
 * <ProjectCard name="Auth Service" health="green" methodology="Scrum" progress={72} variant="compact" />
 * <ProjectCard name="tobornalp" health="yellow" methodology="Kanban" progress={45} nextMilestone="2026-06-15" riskScore={3} variant="expanded" onClick={handleNav} />
 * ```
 */

type Health = "green" | "yellow" | "red";
type ProjectVariant = "compact" | "expanded";

interface ProjectCardProps {
  name: string;
  health: Health;
  methodology?: string;
  progress: number;
  nextMilestone?: string;
  riskScore?: number;
  variant?: ProjectVariant;
  onClick?: () => void;
}

const healthColors: Record<Health, string> = {
  green: "var(--success)",
  yellow: "var(--warning)",
  red: "var(--error)",
};

export function ProjectCard({ name, health, methodology, progress, nextMilestone, riskScore, variant = "compact", onClick }: ProjectCardProps) {
  const clamped = Math.max(0, Math.min(100, progress));
  const interactive = !!onClick;

  if (variant === "compact") {
    return (
      <div
        role={interactive ? "button" : undefined} tabIndex={interactive ? 0 : undefined}
        onClick={onClick} onKeyDown={interactive ? (e) => e.key === "Enter" && onClick?.() : undefined}
        aria-label={`${name}: ${health}`}
        style={{ display: "flex", alignItems: "center", gap: "10px", padding: "var(--space-2) var(--space-3)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", cursor: interactive ? "pointer" : "default" }}
      >
        <span style={{ width: 8, height: 8, borderRadius: "50%", background: healthColors[health], flexShrink: 0 }} />
        <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontWeight: 500, color: "var(--text)", flex: 1, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{name}</span>
        <div style={{ width: 80, height: 4, borderRadius: 2, background: "color-mix(in srgb, var(--text-muted) 15%, transparent)", overflow: "hidden", flexShrink: 0 }}>
          <div style={{ width: `${clamped}%`, height: "100%", background: healthColors[health], borderRadius: 2, transition: "width 0.3s" }} />
        </div>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", width: 30, textAlign: "right" }}>{clamped}%</span>
      </div>
    );
  }

  return (
    <div
      role={interactive ? "button" : undefined} tabIndex={interactive ? 0 : undefined}
      onClick={onClick} onKeyDown={interactive ? (e) => e.key === "Enter" && onClick?.() : undefined}
      aria-label={name}
      style={{ padding: "var(--space-3)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", cursor: interactive ? "pointer" : "default", display: "flex", flexDirection: "column", gap: "var(--space-2)" }}
    >
      <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
        <span style={{ width: 10, height: 10, borderRadius: "50%", background: healthColors[health], flexShrink: 0 }} />
        <span style={{ fontFamily: "var(--font-heading, var(--font-body))", fontSize: "var(--font-size-base)", fontWeight: 600, color: "var(--text)", flex: 1 }}>{name}</span>
        {methodology && <span style={{ padding: "1px 8px", borderRadius: "999px", border: "1px solid var(--border)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-secondary)" }}>{methodology}</span>}
      </div>
      <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
        <div style={{ flex: 1, height: 6, borderRadius: 3, background: "color-mix(in srgb, var(--text-muted) 15%, transparent)", overflow: "hidden" }}>
          <div style={{ width: `${clamped}%`, height: "100%", background: healthColors[health], borderRadius: 3, transition: "width 0.3s" }} />
        </div>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", fontWeight: 600, color: "var(--text)" }}>{clamped}%</span>
      </div>
      <div style={{ display: "flex", gap: "var(--space-3)", flexWrap: "wrap" }}>
        {nextMilestone && <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>📅 {nextMilestone}</span>}
        {riskScore != null && riskScore > 0 && <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: riskScore >= 7 ? "var(--error)" : riskScore >= 4 ? "var(--warning)" : "var(--text-muted)" }}>⚠ Risk: {riskScore}/10</span>}
      </div>
    </div>
  );
}

export default ProjectCard;
