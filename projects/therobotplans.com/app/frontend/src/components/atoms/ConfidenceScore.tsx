"use client";

import React from "react";

/**
 * ConfidenceScore — AI confidence level indicator with color-coded display and optional breakdown.
 *
 * @example
 * ```tsx
 * <ConfidenceScore score={0.92} />
 * <ConfidenceScore score={0.45} label="Triage" variant="compact" />
 * <ConfidenceScore score={0.78} variant="expanded" breakdown={[
 *   { factor: "Context match", weight: 0.85 },
 *   { factor: "Historical accuracy", weight: 0.71 },
 * ]} />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

type ConfidenceVariant = "inline" | "compact" | "expanded";

interface ConfidenceFactor {
  factor: string;
  weight: number; // 0-1
}

interface ConfidenceScoreProps {
  /** Confidence value 0-1 */
  score: number;
  /** Optional label */
  label?: string;
  /** Display variant */
  variant?: ConfidenceVariant;
  /** Breakdown factors (expanded variant) */
  breakdown?: ConfidenceFactor[];
  /** Click handler for full analysis */
  onClick?: () => void;
}

// ── Helpers ─────────────────────────────────────────────────────

function confidenceColor(score: number): string {
  if (score >= 0.8) return "var(--success)";
  if (score >= 0.5) return "var(--warning)";
  return "var(--error)";
}

function confidenceLabel(score: number): string {
  if (score >= 0.8) return "High";
  if (score >= 0.5) return "Medium";
  return "Low";
}

function formatPercent(score: number): string {
  return `${Math.round(score * 100)}%`;
}

// ── Component ───────────────────────────────────────────────────

export function ConfidenceScore({
  score,
  label,
  variant = "inline",
  breakdown,
  onClick,
}: ConfidenceScoreProps) {
  const clamped = Math.max(0, Math.min(1, score));
  const color = confidenceColor(clamped);
  const Tag = onClick ? "button" : "span";
  const interactiveProps = onClick ? { type: "button" as const, onClick } : {};

  if (variant === "inline") {
    return (
      <Tag
        {...interactiveProps}
        aria-label={`${label ? label + ": " : ""}Confidence ${formatPercent(clamped)}`}
        title={`${confidenceLabel(clamped)} confidence: ${formatPercent(clamped)}`}
        style={{
          display: "inline-flex",
          alignItems: "center",
          gap: "4px",
          fontFamily: "var(--font-mono)",
          fontSize: "var(--font-size-xs)",
          fontWeight: 600,
          color,
          background: "none",
          border: "none",
          padding: 0,
          cursor: onClick ? "pointer" : "default",
          lineHeight: 1,
        }}
      >
        <span
          style={{
            width: 6,
            height: 6,
            borderRadius: "50%",
            background: color,
            flexShrink: 0,
          }}
        />
        {formatPercent(clamped)}
      </Tag>
    );
  }

  if (variant === "compact") {
    return (
      <Tag
        {...interactiveProps}
        aria-label={`${label ? label + ": " : ""}Confidence ${formatPercent(clamped)}`}
        style={{
          display: "inline-flex",
          alignItems: "center",
          gap: "6px",
          padding: "2px 8px",
          borderRadius: "999px",
          background: `color-mix(in srgb, ${color} 12%, transparent)`,
          color,
          fontFamily: "var(--font-mono)",
          fontSize: "var(--font-size-xs)",
          fontWeight: 600,
          border: "none",
          cursor: onClick ? "pointer" : "default",
          lineHeight: 1,
        }}
      >
        {label && (
          <span style={{ fontFamily: "var(--font-body)", fontWeight: 500 }}>{label}</span>
        )}
        {formatPercent(clamped)}
      </Tag>
    );
  }

  // expanded — with breakdown
  return (
    <div
      role={onClick ? "button" : undefined}
      tabIndex={onClick ? 0 : undefined}
      onClick={onClick}
      onKeyDown={onClick ? (e) => e.key === "Enter" && onClick() : undefined}
      aria-label={`Confidence ${formatPercent(clamped)}`}
      style={{
        padding: "var(--space-3)",
        borderRadius: "var(--radius, 6px)",
        border: "1px solid var(--border)",
        background: "var(--surface)",
        cursor: onClick ? "pointer" : "default",
      }}
    >
      {/* Header */}
      <div style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: breakdown ? "var(--space-2)" : 0 }}>
        <span
          style={{
            width: 10,
            height: 10,
            borderRadius: "50%",
            background: color,
            flexShrink: 0,
          }}
        />
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-lg)", fontWeight: 700, color }}>
          {formatPercent(clamped)}
        </span>
        <span
          style={{
            padding: "1px 6px",
            borderRadius: "999px",
            background: `color-mix(in srgb, ${color} 12%, transparent)`,
            color,
            fontFamily: "var(--font-mono)",
            fontSize: "var(--font-size-2xs, 10px)",
            fontWeight: 600,
            textTransform: "uppercase",
          }}
        >
          {confidenceLabel(clamped)}
        </span>
        {label && (
          <span style={{ fontSize: "var(--font-size-xs)", color: "var(--text-muted)", marginLeft: "auto" }}>
            {label}
          </span>
        )}
      </div>

      {/* Breakdown */}
      {breakdown && breakdown.length > 0 && (
        <div style={{ display: "flex", flexDirection: "column", gap: "4px", paddingLeft: 18 }}>
          {breakdown.map((f, i) => (
            <div key={i} style={{ display: "flex", alignItems: "center", gap: "8px" }}>
              <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text-secondary)", flex: 1 }}>
                {f.factor}
              </span>
              {/* Mini bar */}
              <div
                style={{
                  width: 60,
                  height: 4,
                  borderRadius: 2,
                  background: "color-mix(in srgb, var(--text-muted) 15%, transparent)",
                  overflow: "hidden",
                }}
              >
                <div
                  style={{
                    width: `${Math.round(f.weight * 100)}%`,
                    height: "100%",
                    background: confidenceColor(f.weight),
                    borderRadius: 2,
                  }}
                />
              </div>
              <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", width: 30, textAlign: "right" }}>
                {formatPercent(f.weight)}
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default ConfidenceScore;
