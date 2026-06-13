"use client";

import React from "react";

/**
 * MetricCard — Single KPI display with value, label, trend indicator, and optional sparkline.
 *
 * @example
 * ```tsx
 * <MetricCard value="2,847" label="Total Tasks" trend="up" trendValue="+12%" />
 * <MetricCard value="99.97%" label="Uptime" trend="flat" variant="compact" />
 * <MetricCard value={42} label="Open Bugs" trend="down" trendValue="-8" sparklineData={[50,48,45,44,42]} variant="expanded" />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

type MetricTrend = "up" | "down" | "flat";
type MetricVariant = "inline" | "compact" | "expanded";

interface MetricCardProps {
  /** Display value (number or formatted string) */
  value: number | string;
  /** Metric label */
  label: string;
  /** Trend direction */
  trend?: MetricTrend;
  /** Trend delta string (e.g., "+12%", "-3") */
  trendValue?: string;
  /** Sparkline data points for expanded variant */
  sparklineData?: number[];
  /** Display variant */
  variant?: MetricVariant;
  /** Click handler for drill-down */
  onClick?: () => void;
}

// ── Helpers ─────────────────────────────────────────────────────

const trendConfig: Record<MetricTrend, { icon: string; color: string }> = {
  up: { icon: "↑", color: "var(--success)" },
  down: { icon: "↓", color: "var(--error)" },
  flat: { icon: "→", color: "var(--text-muted)" },
};

function MiniSparkline({ data, width = 80, height = 24 }: { data: number[]; width?: number; height?: number }) {
  if (data.length < 2) return null;
  const min = Math.min(...data);
  const max = Math.max(...data);
  const range = max - min || 1;
  const padding = 2;
  const w = width - padding * 2;
  const h = height - padding * 2;

  const points = data
    .map((v, i) => {
      const x = padding + (i / (data.length - 1)) * w;
      const y = padding + h - ((v - min) / range) * h;
      return `${x},${y}`;
    })
    .join(" ");

  return (
    <svg width={width} height={height} viewBox={`0 0 ${width} ${height}`} aria-hidden="true">
      <polyline
        points={points}
        fill="none"
        stroke="var(--info)"
        strokeWidth={1.5}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

// ── Component ───────────────────────────────────────────────────

export function MetricCard({
  value,
  label,
  trend,
  trendValue,
  sparklineData,
  variant = "compact",
  onClick,
}: MetricCardProps) {
  const tc = trend ? trendConfig[trend] : null;

  if (variant === "inline") {
    return (
      <span
        role={onClick ? "button" : undefined}
        tabIndex={onClick ? 0 : undefined}
        onClick={onClick}
        onKeyDown={onClick ? (e) => e.key === "Enter" && onClick() : undefined}
        style={{
          display: "inline-flex",
          alignItems: "baseline",
          gap: "6px",
          fontFamily: "var(--font-body)",
          cursor: onClick ? "pointer" : "default",
        }}
      >
        <span style={{ fontWeight: 700, fontSize: "var(--font-size-base)", color: "var(--text)" }}>
          {value}
        </span>
        <span style={{ fontSize: "var(--font-size-xs)", color: "var(--text-muted)" }}>{label}</span>
        {tc && (
          <span style={{ fontSize: "var(--font-size-xs)", color: tc.color, fontWeight: 600 }}>
            {tc.icon} {trendValue}
          </span>
        )}
      </span>
    );
  }

  const cardStyle: React.CSSProperties = {
    padding: "var(--space-3)",
    borderRadius: "var(--radius, 6px)",
    border: "1px solid var(--border)",
    background: "var(--surface)",
    cursor: onClick ? "pointer" : "default",
    display: "flex",
    flexDirection: "column",
    gap: "var(--space-1)",
    minWidth: 140,
  };

  return (
    <div
      role={onClick ? "button" : undefined}
      tabIndex={onClick ? 0 : undefined}
      onClick={onClick}
      onKeyDown={onClick ? (e) => e.key === "Enter" && onClick() : undefined}
      aria-label={`${label}: ${value}`}
      style={cardStyle}
    >
      {/* Label */}
      <span
        style={{
          fontFamily: "var(--font-mono)",
          fontSize: "var(--font-size-2xs, 10px)",
          fontWeight: 600,
          textTransform: "uppercase",
          letterSpacing: "0.06em",
          color: "var(--text-muted)",
        }}
      >
        {label}
      </span>

      {/* Value + Trend */}
      <div style={{ display: "flex", alignItems: "baseline", gap: "8px" }}>
        <span
          style={{
            fontFamily: "var(--font-heading, var(--font-body))",
            fontSize: variant === "expanded" ? "var(--font-size-2xl, 28px)" : "var(--font-size-xl, 22px)",
            fontWeight: 700,
            color: "var(--text)",
            lineHeight: 1.1,
          }}
        >
          {value}
        </span>
        {tc && (
          <span
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: "2px",
              fontFamily: "var(--font-mono)",
              fontSize: "var(--font-size-xs)",
              fontWeight: 600,
              color: tc.color,
            }}
          >
            {tc.icon} {trendValue}
          </span>
        )}
      </div>

      {/* Sparkline (expanded only) */}
      {variant === "expanded" && sparklineData && sparklineData.length >= 2 && (
        <div style={{ marginTop: "var(--space-1)" }}>
          <MiniSparkline data={sparklineData} width={120} height={28} />
        </div>
      )}
    </div>
  );
}

export default MetricCard;
