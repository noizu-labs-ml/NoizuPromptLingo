"use client";

import React from "react";

/**
 * ProgressBar — Visual progress indicator with completion percentage, optional target line, and segments.
 *
 * @example
 * ```tsx
 * <ProgressBar value={65} />
 * <ProgressBar value={72} target={80} label="Sprint Progress" variant="compact" />
 * <ProgressBar value={45} segments={[{ value: 25, color: "var(--success)", label: "Done" }, { value: 20, color: "var(--warning)", label: "In Progress" }]} variant="expanded" />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

type ProgressVariant = "inline" | "compact" | "expanded";

interface ProgressSegment {
  value: number;
  color: string;
  label: string;
}

interface ProgressBarProps {
  /** Progress value 0-100 */
  value: number;
  /** Optional target line position 0-100 */
  target?: number;
  /** Display variant */
  variant?: ProgressVariant;
  /** Label text */
  label?: string;
  /** Bar color (CSS value or var). Defaults to status-based color. */
  color?: string;
  /** Breakdown segments (expanded variant). Values should sum to ≤ 100. */
  segments?: ProgressSegment[];
  /** Click handler for drill-down */
  onClick?: () => void;
}

// ── Helpers ─────────────────────────────────────────────────────

function progressColor(value: number): string {
  if (value >= 80) return "var(--success)";
  if (value >= 40) return "var(--warning)";
  return "var(--error)";
}

// ── Component ───────────────────────────────────────────────────

export function ProgressBar({
  value,
  target,
  variant = "inline",
  label,
  color,
  segments,
  onClick,
}: ProgressBarProps) {
  const clamped = Math.max(0, Math.min(100, value));
  const barColor = color ?? progressColor(clamped);
  const height = variant === "inline" ? 4 : 8;

  const trackStyle: React.CSSProperties = {
    position: "relative",
    width: "100%",
    height,
    borderRadius: height / 2,
    background: "color-mix(in srgb, var(--text-muted) 15%, transparent)",
    overflow: "hidden",
    cursor: onClick ? "pointer" : "default",
  };

  const renderBar = () => {
    if (segments && segments.length > 0) {
      let offset = 0;
      return segments.map((seg, i) => {
        const left = offset;
        offset += seg.value;
        return (
          <div
            key={i}
            title={`${seg.label}: ${seg.value}%`}
            style={{
              position: "absolute",
              left: `${left}%`,
              top: 0,
              bottom: 0,
              width: `${seg.value}%`,
              background: seg.color,
              transition: "width 0.3s ease",
            }}
          />
        );
      });
    }
    return (
      <div
        style={{
          position: "absolute",
          left: 0,
          top: 0,
          bottom: 0,
          width: `${clamped}%`,
          background: barColor,
          borderRadius: height / 2,
          transition: "width 0.3s ease",
        }}
      />
    );
  };

  const renderTarget = () => {
    if (target == null) return null;
    return (
      <div
        title={`Target: ${target}%`}
        style={{
          position: "absolute",
          left: `${Math.max(0, Math.min(100, target))}%`,
          top: -2,
          bottom: -2,
          width: 2,
          background: "var(--text)",
          opacity: 0.5,
          zIndex: 1,
        }}
      />
    );
  };

  if (variant === "inline") {
    return (
      <div
        role="progressbar"
        aria-valuenow={clamped}
        aria-valuemin={0}
        aria-valuemax={100}
        aria-label={label ?? `${clamped}% complete`}
        onClick={onClick}
        style={trackStyle}
      >
        {renderBar()}
        {renderTarget()}
      </div>
    );
  }

  if (variant === "compact") {
    return (
      <div
        onClick={onClick}
        style={{ display: "flex", flexDirection: "column", gap: "4px", cursor: onClick ? "pointer" : "default" }}
      >
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
          {label && (
            <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text-secondary)" }}>
              {label}
            </span>
          )}
          <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", fontWeight: 600, color: "var(--text)" }}>
            {clamped}%
          </span>
        </div>
        <div role="progressbar" aria-valuenow={clamped} aria-valuemin={0} aria-valuemax={100} aria-label={label ?? `${clamped}% complete`} style={trackStyle}>
          {renderBar()}
          {renderTarget()}
        </div>
      </div>
    );
  }

  // expanded — with segments legend
  return (
    <div onClick={onClick} style={{ display: "flex", flexDirection: "column", gap: "6px", cursor: onClick ? "pointer" : "default" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
        {label && (
          <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontWeight: 600, color: "var(--text)" }}>
            {label}
          </span>
        )}
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", fontWeight: 600, color: "var(--text)" }}>
          {clamped}%{target != null && ` / ${target}%`}
        </span>
      </div>
      <div role="progressbar" aria-valuenow={clamped} aria-valuemin={0} aria-valuemax={100} aria-label={label ?? `${clamped}% complete`} style={{ ...trackStyle, height: 10, borderRadius: 5 }}>
        {renderBar()}
        {renderTarget()}
      </div>
      {segments && segments.length > 0 && (
        <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-2)" }}>
          {segments.map((seg, i) => (
            <div key={i} style={{ display: "flex", alignItems: "center", gap: "4px" }}>
              <span style={{ width: 8, height: 8, borderRadius: 2, background: seg.color, flexShrink: 0 }} />
              <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>
                {seg.label} ({seg.value}%)
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default ProgressBar;
