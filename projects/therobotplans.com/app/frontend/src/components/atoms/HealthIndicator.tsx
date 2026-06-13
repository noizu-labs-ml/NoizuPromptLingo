"use client";

import React from "react";

/**
 * HealthIndicator — Green/yellow/red status signal for project, service, or goal health.
 *
 * @example
 * ```tsx
 * <HealthIndicator status="green" label="API" />
 * <HealthIndicator status="yellow" label="Latency" variant="compact" />
 * <HealthIndicator status="red" label="DB" variant="expanded" detail={{ factors: [...] }} />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

type HealthStatus = "green" | "yellow" | "red" | "gray";
type HealthVariant = "inline" | "compact" | "expanded";

interface HealthFactor {
  label: string;
  status: HealthStatus;
  detail?: string;
}

interface HealthIndicatorProps {
  /** Health status color */
  status: HealthStatus;
  /** Label displayed alongside the indicator */
  label?: string;
  /** Display variant */
  variant?: HealthVariant;
  /** Breakdown of contributing factors (expanded variant) */
  detail?: { factors: HealthFactor[] };
  /** Click handler for drill-down */
  onClick?: () => void;
  /** Tooltip text on hover */
  tooltip?: string;
}

// ── Color Map ───────────────────────────────────────────────────

const statusColors: Record<HealthStatus, { dot: string; bg: string; text: string }> = {
  green: {
    dot: "var(--success)",
    bg: "color-mix(in srgb, var(--success) 10%, transparent)",
    text: "var(--success)",
  },
  yellow: {
    dot: "var(--warning)",
    bg: "color-mix(in srgb, var(--warning) 10%, transparent)",
    text: "var(--warning)",
  },
  red: {
    dot: "var(--error)",
    bg: "color-mix(in srgb, var(--error) 10%, transparent)",
    text: "var(--error)",
  },
  gray: {
    dot: "var(--text-muted)",
    bg: "color-mix(in srgb, var(--text-muted) 10%, transparent)",
    text: "var(--text-muted)",
  },
};

const statusLabels: Record<HealthStatus, string> = {
  green: "Healthy",
  yellow: "Degraded",
  red: "Critical",
  gray: "Unknown",
};

// ── Component ───────────────────────────────────────────────────

export function HealthIndicator({
  status,
  label,
  variant = "inline",
  detail,
  onClick,
  tooltip,
}: HealthIndicatorProps) {
  const colors = statusColors[status];
  const Tag = onClick ? "button" : "span";
  const interactiveProps = onClick
    ? { type: "button" as const, onClick, style: { cursor: "pointer" } }
    : {};

  if (variant === "inline") {
    return (
      <Tag
        {...interactiveProps}
        title={tooltip ?? statusLabels[status]}
        aria-label={`${label ?? "Health"}: ${statusLabels[status]}`}
        style={{
          display: "inline-flex",
          alignItems: "center",
          gap: "6px",
          fontFamily: "var(--font-body)",
          fontSize: "var(--font-size-sm)",
          color: "var(--text)",
          background: "none",
          border: "none",
          padding: 0,
          lineHeight: 1,
          ...interactiveProps.style,
        }}
      >
        <span
          style={{
            width: 8,
            height: 8,
            borderRadius: "50%",
            background: colors.dot,
            flexShrink: 0,
          }}
        />
        {label && <span>{label}</span>}
      </Tag>
    );
  }

  if (variant === "compact") {
    return (
      <Tag
        {...interactiveProps}
        title={tooltip}
        aria-label={`${label ?? "Health"}: ${statusLabels[status]}`}
        style={{
          display: "inline-flex",
          alignItems: "center",
          gap: "6px",
          padding: "3px 10px",
          borderRadius: "999px",
          background: colors.bg,
          color: colors.text,
          fontFamily: "var(--font-body)",
          fontSize: "var(--font-size-xs)",
          fontWeight: 500,
          border: "none",
          lineHeight: 1,
          ...interactiveProps.style,
        }}
      >
        <span
          style={{
            width: 6,
            height: 6,
            borderRadius: "50%",
            background: colors.dot,
            flexShrink: 0,
          }}
        />
        {label ?? statusLabels[status]}
      </Tag>
    );
  }

  // expanded
  return (
    <div
      role={onClick ? "button" : undefined}
      tabIndex={onClick ? 0 : undefined}
      onClick={onClick}
      onKeyDown={onClick ? (e) => e.key === "Enter" && onClick() : undefined}
      aria-label={`${label ?? "Health"}: ${statusLabels[status]}`}
      style={{
        padding: "var(--space-3)",
        borderRadius: "var(--radius, 6px)",
        border: `1px solid var(--border)`,
        background: "var(--surface)",
        cursor: onClick ? "pointer" : "default",
      }}
    >
      <div style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: detail ? "var(--space-2)" : 0 }}>
        <span
          style={{
            width: 10,
            height: 10,
            borderRadius: "50%",
            background: colors.dot,
            flexShrink: 0,
          }}
        />
        <span
          style={{
            fontFamily: "var(--font-body)",
            fontSize: "var(--font-size-sm)",
            fontWeight: 600,
            color: "var(--text)",
          }}
        >
          {label ?? statusLabels[status]}
        </span>
        <span
          style={{
            fontFamily: "var(--font-mono)",
            fontSize: "var(--font-size-xs)",
            color: colors.text,
            marginLeft: "auto",
          }}
        >
          {statusLabels[status]}
        </span>
      </div>
      {detail?.factors && (
        <div style={{ display: "flex", flexDirection: "column", gap: "4px", paddingLeft: 18 }}>
          {detail.factors.map((f, i) => (
            <div key={i} style={{ display: "flex", alignItems: "center", gap: "6px" }}>
              <span
                style={{
                  width: 6,
                  height: 6,
                  borderRadius: "50%",
                  background: statusColors[f.status].dot,
                  flexShrink: 0,
                }}
              />
              <span
                style={{
                  fontFamily: "var(--font-body)",
                  fontSize: "var(--font-size-xs)",
                  color: "var(--text-secondary)",
                }}
              >
                {f.label}
              </span>
              {f.detail && (
                <span
                  style={{
                    fontFamily: "var(--font-mono)",
                    fontSize: "var(--font-size-2xs, 10px)",
                    color: "var(--text-muted)",
                    marginLeft: "auto",
                  }}
                >
                  {f.detail}
                </span>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default HealthIndicator;
