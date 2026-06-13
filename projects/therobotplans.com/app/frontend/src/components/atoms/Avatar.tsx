"use client";

import React from "react";

/**
 * Avatar — User or agent avatar with image, initials fallback, and type indicator.
 *
 * @example
 * ```tsx
 * <Avatar name="Marcus Reeves" />
 * <Avatar name="PM Agent" type="agent" />
 * <Avatar name="Sarah Kim" src="/avatars/sarah.jpg" size="lg" />
 * <Avatar name="QA Bot" type="agent" status="active" />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

type AvatarSize = "xs" | "sm" | "md" | "lg";
type AvatarType = "human" | "agent";
type AvatarStatus = "active" | "idle" | "offline";

interface AvatarProps {
  /** Display name (used for initials fallback and aria-label) */
  name: string;
  /** Image URL */
  src?: string;
  /** Size variant */
  size?: AvatarSize;
  /** Human or agent indicator */
  type?: AvatarType;
  /** Online status dot */
  status?: AvatarStatus;
  /** Click handler */
  onClick?: () => void;
}

// ── Helpers ─────────────────────────────────────────────────────

const sizes: Record<AvatarSize, { px: number; font: string; statusDot: number }> = {
  xs: { px: 20, font: "var(--font-size-2xs, 10px)", statusDot: 6 },
  sm: { px: 28, font: "var(--font-size-xs)", statusDot: 7 },
  md: { px: 36, font: "var(--font-size-sm)", statusDot: 8 },
  lg: { px: 48, font: "var(--font-size-base)", statusDot: 10 },
};

const statusColors: Record<AvatarStatus, string> = {
  active: "var(--success)",
  idle: "var(--warning)",
  offline: "var(--text-muted)",
};

function getInitials(name: string): string {
  return name
    .split(/\s+/)
    .map((w) => w[0])
    .filter(Boolean)
    .slice(0, 2)
    .join("")
    .toUpperCase();
}

/** Deterministic hue from name for initials-only avatars */
function nameToHue(name: string): number {
  let hash = 0;
  for (let i = 0; i < name.length; i++) {
    hash = name.charCodeAt(i) + ((hash << 5) - hash);
  }
  return Math.abs(hash) % 360;
}

// ── Component ───────────────────────────────────────────────────

export function Avatar({
  name,
  src,
  size = "md",
  type = "human",
  status,
  onClick,
}: AvatarProps) {
  const s = sizes[size];
  const initials = getInitials(name);
  const hue = nameToHue(name);
  const Tag = onClick ? "button" : "div";
  const [imgError, setImgError] = React.useState(false);

  const showImage = src && !imgError;

  return (
    <Tag
      type={onClick ? "button" : undefined}
      onClick={onClick}
      aria-label={`${name}${type === "agent" ? " (agent)" : ""}`}
      style={{
        position: "relative",
        display: "inline-flex",
        alignItems: "center",
        justifyContent: "center",
        width: s.px,
        height: s.px,
        borderRadius: type === "agent" ? "20%" : "50%",
        background: showImage
          ? "transparent"
          : `hsl(${hue}, 45%, ${type === "agent" ? "35%" : "55%"})`,
        overflow: "hidden",
        border: "none",
        padding: 0,
        cursor: onClick ? "pointer" : "default",
        flexShrink: 0,
      }}
    >
      {showImage ? (
        <img
          src={src}
          alt={name}
          onError={() => setImgError(true)}
          style={{
            width: "100%",
            height: "100%",
            objectFit: "cover",
          }}
        />
      ) : (
        <span
          style={{
            fontFamily: "var(--font-body)",
            fontSize: s.font,
            fontWeight: 600,
            color: "#fff",
            lineHeight: 1,
            userSelect: "none",
          }}
        >
          {type === "agent" ? "⬢" : initials}
        </span>
      )}

      {/* Agent type indicator (small hexagon badge) */}
      {type === "agent" && size !== "xs" && (
        <span
          style={{
            position: "absolute",
            bottom: -1,
            right: -1,
            width: s.statusDot + 2,
            height: s.statusDot + 2,
            background: "var(--violet, #7C3AED)",
            borderRadius: 2,
            border: "1.5px solid var(--bg)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <span style={{ color: "#fff", fontSize: "5px", lineHeight: 1 }}>⚡</span>
        </span>
      )}

      {/* Status dot */}
      {status && (
        <span
          style={{
            position: "absolute",
            bottom: type === "agent" ? -1 : 0,
            right: type === "agent" ? (size !== "xs" ? s.statusDot + 4 : -1) : 0,
            width: s.statusDot,
            height: s.statusDot,
            borderRadius: "50%",
            background: statusColors[status],
            border: "1.5px solid var(--bg)",
          }}
        />
      )}
    </Tag>
  );
}

export default Avatar;
