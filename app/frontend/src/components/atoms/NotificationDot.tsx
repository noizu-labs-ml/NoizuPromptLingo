"use client";

import React from "react";

/**
 * NotificationDot — Numeric count badge overlaid on nav items or icons for unread/pending counts.
 *
 * @example
 * ```tsx
 * <div style={{ position: "relative" }}>
 *   <NavIcon />
 *   <NotificationDot count={5} />
 * </div>
 *
 * <NotificationDot count={142} max={99} />  // Renders "99+"
 * <NotificationDot count={0} />             // Hidden (nothing renders)
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

interface NotificationDotProps {
  /** Unread/pending count */
  count: number;
  /** Max display value (shows "N+" above this). Default: 99. */
  max?: number;
  /** Force visibility even when count is 0 (shows empty dot) */
  visible?: boolean;
  /** Color override. Default: var(--error). */
  color?: string;
  /** Position style: absolute (overlay on parent) or inline */
  position?: "absolute" | "inline";
}

// ── Component ───────────────────────────────────────────────────

export function NotificationDot({
  count,
  max = 99,
  visible,
  color = "var(--error)",
  position = "absolute",
}: NotificationDotProps) {
  const show = visible || count > 0;
  if (!show) return null;

  const displayText = count > max ? `${max}+` : count > 0 ? String(count) : "";
  const isDot = count === 0; // visible=true but count=0 → show dot only

  const baseStyle: React.CSSProperties = {
    display: "inline-flex",
    alignItems: "center",
    justifyContent: "center",
    background: color,
    color: "#fff",
    fontFamily: "var(--font-mono)",
    fontSize: "var(--font-size-2xs, 10px)",
    fontWeight: 700,
    lineHeight: 1,
    borderRadius: "999px",
    border: "2px solid var(--bg)",
    minWidth: isDot ? 8 : 18,
    height: isDot ? 8 : 18,
    padding: isDot ? 0 : "0 5px",
    whiteSpace: "nowrap",
  };

  const positionStyle: React.CSSProperties =
    position === "absolute"
      ? {
          position: "absolute",
          top: isDot ? -2 : -6,
          right: isDot ? -2 : -8,
          zIndex: 1,
        }
      : {};

  return (
    <span
      aria-label={count > 0 ? `${count} notifications` : "notification indicator"}
      style={{ ...baseStyle, ...positionStyle }}
    >
      {displayText}
    </span>
  );
}

export default NotificationDot;
