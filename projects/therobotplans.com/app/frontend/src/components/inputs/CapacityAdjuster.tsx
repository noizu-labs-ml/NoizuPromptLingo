"use client";

import React from "react";

/**
 * CapacityAdjuster — Team capacity configuration with per-member availability sliders.
 *
 * @example
 * ```tsx
 * <CapacityAdjuster members={[{ id: "1", name: "Marcus", defaultHours: 40 }]} overrides={{ "1": 32 }} onChange={setOverrides} />
 * ```
 */

interface TeamMember { id: string; name: string; type?: "human" | "agent"; defaultHours: number; pto?: boolean; }
type CapacityVariant = "compact" | "expanded";

interface CapacityAdjusterProps {
  members: TeamMember[];
  defaultCapacity?: number;
  overrides: Record<string, number>;
  onChange: (overrides: Record<string, number>) => void;
  variant?: CapacityVariant;
}

export function CapacityAdjuster({ members, defaultCapacity = 40, overrides, onChange, variant = "expanded" }: CapacityAdjusterProps) {
  const totalCapacity = members.reduce((sum, m) => sum + (overrides[m.id] ?? m.defaultHours), 0);
  const maxTotal = members.length * defaultCapacity;
  const pct = maxTotal > 0 ? Math.round((totalCapacity / maxTotal) * 100) : 0;

  const handleChange = (id: string, hours: number) => {
    onChange({ ...overrides, [id]: Math.max(0, Math.min(defaultCapacity, hours)) });
  };

  if (variant === "compact") {
    return (
      <div style={{ display: "flex", alignItems: "center", gap: "8px", padding: "var(--space-2)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)" }}>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", fontWeight: 600, color: "var(--text)" }}>{totalCapacity}h</span>
        <div style={{ flex: 1, height: 6, borderRadius: 3, background: "color-mix(in srgb, var(--text-muted) 15%, transparent)", overflow: "hidden" }}>
          <div style={{ width: `${pct}%`, height: "100%", background: pct >= 80 ? "var(--success)" : pct >= 50 ? "var(--warning)" : "var(--error)", borderRadius: 3, transition: "width 0.3s" }} />
        </div>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>{pct}% of {maxTotal}h</span>
      </div>
    );
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-2)", padding: "var(--space-3)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)" }}>
      {/* Total summary */}
      <div style={{ display: "flex", alignItems: "center", gap: "8px", paddingBottom: "var(--space-2)", borderBottom: "1px solid var(--border)" }}>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.06em", color: "var(--text-muted)" }}>Team Capacity</span>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-lg)", fontWeight: 700, color: "var(--text)", marginLeft: "auto" }}>{totalCapacity}h</span>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)" }}>/ {maxTotal}h</span>
      </div>

      {/* Per-member sliders */}
      {members.map((m) => {
        const hours = overrides[m.id] ?? m.defaultHours;
        const memberPct = defaultCapacity > 0 ? Math.round((hours / defaultCapacity) * 100) : 0;
        return (
          <div key={m.id} style={{ display: "flex", alignItems: "center", gap: "8px" }}>
            <span style={{ width: 20, height: 20, borderRadius: m.type === "agent" ? "20%" : "50%", background: m.type === "agent" ? "var(--violet, #7C3AED)" : "var(--text-muted)", color: "#fff", fontSize: "8px", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
              {m.type === "agent" ? "⬢" : m.name.charAt(0).toUpperCase()}
            </span>
            <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: m.pto ? "var(--warning)" : "var(--text)", flex: "0 0 80px", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
              {m.name}{m.pto ? " 🏖" : ""}
            </span>
            <input type="range" min={0} max={defaultCapacity} value={hours} onChange={(e) => handleChange(m.id, parseInt(e.target.value))} style={{ flex: 1, accentColor: "var(--info, var(--blue))" }} aria-label={`${m.name} hours`} />
            <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", fontWeight: 600, color: "var(--text)", width: 36, textAlign: "right" }}>{hours}h</span>
            <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", width: 30, textAlign: "right" }}>{memberPct}%</span>
          </div>
        );
      })}
    </div>
  );
}

export default CapacityAdjuster;
