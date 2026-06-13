"use client";

import React from "react";

/**
 * StreakCounter — Numeric display of consecutive completions with personal best and break warning.
 *
 * @example
 * ```tsx
 * <StreakCounter current={12} personalBest={15} />
 * <StreakCounter current={15} personalBest={15} />  // Shows "NEW PB!" badge
 * <StreakCounter current={3} personalBest={12} atRisk gracePeriod={1} />
 * <StreakCounter current={7} personalBest={20} variant="compact" />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

type StreakVariant = "inline" | "compact";

interface StreakCounterProps {
  /** Current streak count */
  current: number;
  /** All-time personal best */
  personalBest: number;
  /** Number of grace period days remaining (0 = no grace left) */
  gracePeriod?: number;
  /** Whether the streak is at risk of breaking */
  atRisk?: boolean;
  /** Display variant */
  variant?: StreakVariant;
  /** Click handler for full history */
  onClick?: () => void;
}

// ── Component ───────────────────────────────────────────────────

export function StreakCounter({
  current,
  personalBest,
  gracePeriod = 0,
  atRisk = false,
  variant = "inline",
  onClick,
}: StreakCounterProps) {
  const isNewPB = current >= personalBest && current > 0;
  const Tag = onClick ? "button" : "span";
  const interactiveProps = onClick ? { type: "button" as const, onClick } : {};

  if (variant === "inline") {
    return (
      <Tag
        {...interactiveProps}
        aria-label={`${current} day streak${isNewPB ? ", new personal best" : ""}${atRisk ? ", at risk" : ""}`}
        title={`Streak: ${current} · Best: ${personalBest}${atRisk ? " · At risk!" : ""}`}
        style={{
          display: "inline-flex",
          alignItems: "center",
          gap: "4px",
          fontFamily: "var(--font-mono)",
          fontSize: "var(--font-size-sm)",
          fontWeight: 700,
          color: atRisk ? "var(--warning)" : isNewPB ? "var(--success)" : "var(--text)",
          background: "none",
          border: "none",
          padding: 0,
          cursor: onClick ? "pointer" : "default",
          lineHeight: 1,
        }}
      >
        <span style={{ fontSize: "var(--font-size-base)" }}>{atRisk ? "⚠" : "🔥"}</span>
        {current}
      </Tag>
    );
  }

  // compact
  return (
    <Tag
      {...interactiveProps}
      aria-label={`${current} day streak, personal best ${personalBest}${atRisk ? ", at risk" : ""}`}
      style={{
        display: "inline-flex",
        alignItems: "center",
        gap: "8px",
        padding: "4px 12px",
        borderRadius: "var(--radius, 6px)",
        background: atRisk
          ? "color-mix(in srgb, var(--warning) 10%, transparent)"
          : "color-mix(in srgb, var(--success) 8%, transparent)",
        border: `1px solid ${atRisk ? "var(--warning)" : "var(--border)"}`,
        fontFamily: "var(--font-mono)",
        fontSize: "var(--font-size-sm)",
        cursor: onClick ? "pointer" : "default",
      }}
    >
      {/* Flame + count */}
      <span style={{ display: "flex", alignItems: "center", gap: "4px" }}>
        <span style={{ fontSize: "var(--font-size-base)" }}>{atRisk ? "⚠" : "🔥"}</span>
        <span style={{ fontWeight: 700, color: "var(--text)", fontSize: "var(--font-size-lg)" }}>
          {current}
        </span>
      </span>

      {/* Personal best badge */}
      {isNewPB ? (
        <span
          style={{
            padding: "1px 6px",
            borderRadius: "999px",
            background: "var(--success)",
            color: "#fff",
            fontSize: "var(--font-size-2xs, 10px)",
            fontWeight: 700,
            textTransform: "uppercase",
            letterSpacing: "0.04em",
          }}
        >
          PB!
        </span>
      ) : (
        <span style={{ fontSize: "var(--font-size-xs)", color: "var(--text-muted)" }}>
          best: {personalBest}
        </span>
      )}

      {/* At-risk warning */}
      {atRisk && gracePeriod > 0 && (
        <span style={{ fontSize: "var(--font-size-2xs, 10px)", color: "var(--warning)", fontWeight: 600 }}>
          {gracePeriod}d left
        </span>
      )}
    </Tag>
  );
}

export default StreakCounter;
