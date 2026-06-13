"use client";

import React from "react";

/**
 * StatusIndicator — Semantic status display for system health, agent state, or workflow status.
 * Maps to tobornalp's semantic classes (status-pill, agent-badge, priority-dot).
 *
 * @example
 * ```tsx
 * <StatusIndicator status="active" />
 * <StatusIndicator status="warning" label="Latency Elevated" icon="⚠" />
 * <StatusIndicator status="error" label="Build Failed" icon="✗" pulse />
 * <StatusIndicator status="idle" label="Offline" icon="○" />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

type StatusLevel = "active" | "warning" | "error" | "idle" | "pending" | "info";

interface StatusIndicatorProps {
  /** Semantic status level */
  status: StatusLevel;
  /** Label text (defaults to status name) */
  label?: string;
  /** Optional leading glyph (Unicode or emoji) */
  icon?: string;
  /** Pulse animation for live/active states */
  pulse?: boolean;
  /** Size variant */
  size?: "sm" | "md";
  /** Click handler */
  onClick?: () => void;
}

// ── Config ──────────────────────────────────────────────────────

const statusConfig: Record<StatusLevel, { color: string; bg: string; defaultIcon: string; defaultLabel: string }> = {
  active: {
    color: "var(--success)",
    bg: "color-mix(in srgb, var(--success) 12%, transparent)",
    defaultIcon: "●",
    defaultLabel: "Active",
  },
  warning: {
    color: "var(--warning)",
    bg: "color-mix(in srgb, var(--warning) 12%, transparent)",
    defaultIcon: "⚠",
    defaultLabel: "Warning",
  },
  error: {
    color: "var(--error)",
    bg: "color-mix(in srgb, var(--error) 12%, transparent)",
    defaultIcon: "✗",
    defaultLabel: "Error",
  },
  idle: {
    color: "var(--text-muted)",
    bg: "color-mix(in srgb, var(--text-muted) 10%, transparent)",
    defaultIcon: "○",
    defaultLabel: "Idle",
  },
  pending: {
    color: "var(--info, var(--blue))",
    bg: "color-mix(in srgb, var(--info, var(--blue)) 12%, transparent)",
    defaultIcon: "⏱",
    defaultLabel: "Pending",
  },
  info: {
    color: "var(--info, var(--blue))",
    bg: "color-mix(in srgb, var(--info, var(--blue)) 12%, transparent)",
    defaultIcon: "●",
    defaultLabel: "Info",
  },
};

// ── Component ───────────────────────────────────────────────────

export function StatusIndicator({
  status,
  label,
  icon,
  pulse = false,
  size = "sm",
  onClick,
}: StatusIndicatorProps) {
  const cfg = statusConfig[status];
  const displayIcon = icon ?? cfg.defaultIcon;
  const displayLabel = label ?? cfg.defaultLabel;
  const Tag = onClick ? "button" : "span";

  const fontSize = size === "sm" ? "var(--font-size-2xs, 10px)" : "var(--font-size-xs)";
  const padding = size === "sm" ? "2px 8px" : "3px 10px";
  const iconSize = size === "sm" ? "8px" : "10px";

  return (
    <Tag
      type={onClick ? "button" : undefined}
      onClick={onClick}
      aria-label={displayLabel}
      style={{
        display: "inline-flex",
        alignItems: "center",
        gap: size === "sm" ? "4px" : "5px",
        padding,
        borderRadius: "999px",
        background: cfg.bg,
        color: cfg.color,
        fontFamily: "var(--font-body)",
        fontSize,
        fontWeight: 500,
        lineHeight: 1,
        border: "none",
        cursor: onClick ? "pointer" : "default",
        whiteSpace: "nowrap",
      }}
    >
      <span
        style={{
          fontSize: iconSize,
          lineHeight: 1,
          ...(pulse
            ? {
                animation: "status-pulse 2s ease-in-out infinite",
              }
            : {}),
        }}
      >
        {displayIcon}
      </span>
      {displayLabel}
      {pulse && (
        <style>{`
          @keyframes status-pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.4; }
          }
        `}</style>
      )}
    </Tag>
  );
}

export default StatusIndicator;
