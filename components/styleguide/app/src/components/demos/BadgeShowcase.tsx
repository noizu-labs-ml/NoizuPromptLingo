"use client";

import React from "react";

// ─── Badge Props ────────────────────────────────────────────────────────────

type BadgeColor =
  | "default"
  | "blue"
  | "violet"
  | "emerald"
  | "amber"
  | "red"
  | "rose"
  | "cyan"
  | "gray";

type BadgeSize = "sm" | "md";

type BadgeVariant = "filled" | "outline" | "subtle";

interface BadgeProps {
  /** Display label */
  label: string;
  /** Semantic or palette color. Maps to theme CSS vars. */
  color?: BadgeColor;
  /** sm (inline) or md (standard) */
  size?: BadgeSize;
  /** filled (solid bg), outline (border only), subtle (tinted bg) */
  variant?: BadgeVariant;
  /** Optional leading glyph — Unicode or emoji */
  icon?: string;
  /** Click handler — if provided, badge renders as button */
  onClick?: () => void;
}

// ─── Color Map ──────────────────────────────────────────────────────────────

const colorMap: Record<
  BadgeColor,
  { fg: string; bg: string; border: string; subtleBg: string }
> = {
  default: {
    fg: "var(--text-secondary)",
    bg: "var(--gray-500)",
    border: "var(--gray-400)",
    subtleBg: "color-mix(in srgb, var(--gray-500) 10%, transparent)",
  },
  blue: {
    fg: "var(--blue)",
    bg: "var(--blue)",
    border: "var(--blue)",
    subtleBg: "var(--blue-light)",
  },
  violet: {
    fg: "var(--violet)",
    bg: "var(--violet)",
    border: "var(--violet)",
    subtleBg: "var(--violet-light)",
  },
  emerald: {
    fg: "var(--emerald, var(--success))",
    bg: "var(--emerald, var(--success))",
    border: "var(--emerald, var(--success))",
    subtleBg: "var(--emerald-light, var(--success-tint))",
  },
  amber: {
    fg: "var(--amber, var(--warning))",
    bg: "var(--amber, var(--warning))",
    border: "var(--amber, var(--warning))",
    subtleBg: "var(--amber-light, var(--warning-tint))",
  },
  red: {
    fg: "var(--error)",
    bg: "var(--error)",
    border: "var(--error)",
    subtleBg: "var(--error-tint)",
  },
  rose: {
    fg: "var(--rose, var(--error))",
    bg: "var(--rose, var(--error))",
    border: "var(--rose, var(--error))",
    subtleBg: "var(--rose-light, var(--error-tint))",
  },
  cyan: {
    fg: "var(--cyan, var(--info))",
    bg: "var(--cyan, var(--info))",
    border: "var(--cyan, var(--info))",
    subtleBg: "var(--cyan-light, var(--info-tint))",
  },
  gray: {
    fg: "var(--text-muted)",
    bg: "var(--gray-400)",
    border: "var(--gray-300)",
    subtleBg: "color-mix(in srgb, var(--gray-400) 10%, transparent)",
  },
};

// ─── Badge Component ────────────────────────────────────────────────────────

export function Badge({
  label,
  color = "default",
  size = "sm",
  variant = "subtle",
  icon,
  onClick,
}: BadgeProps) {
  const c = colorMap[color] || colorMap.default;

  const baseStyle: React.CSSProperties = {
    display: "inline-flex",
    alignItems: "center",
    gap: size === "sm" ? "3px" : "5px",
    fontFamily: "var(--font-sans)",
    fontWeight: 500,
    lineHeight: 1,
    borderRadius: "999px",
    whiteSpace: "nowrap",
    border: "none",
    cursor: onClick ? "pointer" : "default",
    transition: "opacity 0.15s",
    ...(size === "sm"
      ? { fontSize: "var(--font-size-2xs, 10px)", padding: "2px 8px" }
      : { fontSize: "var(--font-size-xs, 11px)", padding: "3px 10px" }),
  };

  const variantStyle: React.CSSProperties =
    variant === "filled"
      ? { background: c.bg, color: "#FFFFFF" }
      : variant === "outline"
        ? {
            background: "transparent",
            color: c.fg,
            border: `1px solid ${c.border}`,
            // re-adjust padding to compensate for border
            padding: size === "sm" ? "1px 7px" : "2px 9px",
          }
        : {
            // subtle (default)
            background: c.subtleBg,
            color: c.fg,
          };

  const style = { ...baseStyle, ...variantStyle };

  const content = (
    <>
      {icon && <span style={{ fontSize: size === "sm" ? "9px" : "11px" }}>{icon}</span>}
      {label}
    </>
  );

  if (onClick) {
    return (
      <button type="button" onClick={onClick} style={style}>
        {content}
      </button>
    );
  }

  return <span style={style}>{content}</span>;
}

// ─── Showcase Demo ──────────────────────────────────────────────────────────

export function BadgeShowcase() {
  const allColors: BadgeColor[] = [
    "default",
    "blue",
    "violet",
    "emerald",
    "amber",
    "red",
    "rose",
    "cyan",
    "gray",
  ];

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-4)" }}>
      {/* ── Variants ── */}
      <div>
        <div
          style={{
            fontFamily: "var(--font-mono)",
            fontSize: "var(--font-size-xs)",
            fontWeight: 600,
            textTransform: "uppercase",
            letterSpacing: "0.06em",
            color: "var(--text-muted)",
            marginBottom: "var(--space-1)",
          }}
        >
          Variants
        </div>
        <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-1)" }}>
          <Badge label="Subtle" color="blue" variant="subtle" />
          <Badge label="Filled" color="blue" variant="filled" />
          <Badge label="Outline" color="blue" variant="outline" />
        </div>
      </div>

      {/* ── Colors (subtle) ── */}
      <div>
        <div
          style={{
            fontFamily: "var(--font-mono)",
            fontSize: "var(--font-size-xs)",
            fontWeight: 600,
            textTransform: "uppercase",
            letterSpacing: "0.06em",
            color: "var(--text-muted)",
            marginBottom: "var(--space-1)",
          }}
        >
          Colors — Subtle
        </div>
        <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-1)" }}>
          {allColors.map((c) => (
            <Badge key={c} label={c} color={c} variant="subtle" />
          ))}
        </div>
      </div>

      {/* ── Colors (filled) ── */}
      <div>
        <div
          style={{
            fontFamily: "var(--font-mono)",
            fontSize: "var(--font-size-xs)",
            fontWeight: 600,
            textTransform: "uppercase",
            letterSpacing: "0.06em",
            color: "var(--text-muted)",
            marginBottom: "var(--space-1)",
          }}
        >
          Colors — Filled
        </div>
        <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-1)" }}>
          {allColors.map((c) => (
            <Badge key={c} label={c} color={c} variant="filled" />
          ))}
        </div>
      </div>

      {/* ── Colors (outline) ── */}
      <div>
        <div
          style={{
            fontFamily: "var(--font-mono)",
            fontSize: "var(--font-size-xs)",
            fontWeight: 600,
            textTransform: "uppercase",
            letterSpacing: "0.06em",
            color: "var(--text-muted)",
            marginBottom: "var(--space-1)",
          }}
        >
          Colors — Outline
        </div>
        <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-1)" }}>
          {allColors.map((c) => (
            <Badge key={c} label={c} color={c} variant="outline" />
          ))}
        </div>
      </div>

      {/* ── Sizes ── */}
      <div>
        <div
          style={{
            fontFamily: "var(--font-mono)",
            fontSize: "var(--font-size-xs)",
            fontWeight: 600,
            textTransform: "uppercase",
            letterSpacing: "0.06em",
            color: "var(--text-muted)",
            marginBottom: "var(--space-1)",
          }}
        >
          Sizes
        </div>
        <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-1)", alignItems: "center" }}>
          <Badge label="Small (sm)" color="blue" size="sm" />
          <Badge label="Medium (md)" color="blue" size="md" />
        </div>
      </div>

      {/* ── With Icons ── */}
      <div>
        <div
          style={{
            fontFamily: "var(--font-mono)",
            fontSize: "var(--font-size-xs)",
            fontWeight: 600,
            textTransform: "uppercase",
            letterSpacing: "0.06em",
            color: "var(--text-muted)",
            marginBottom: "var(--space-1)",
          }}
        >
          With Icons
        </div>
        <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-1)" }}>
          <Badge label="Active" color="emerald" icon="●" size="md" />
          <Badge label="Warning" color="amber" icon="⚠" size="md" />
          <Badge label="Error" color="red" icon="✗" size="md" />
          <Badge label="Agent" color="violet" icon="⬢" size="md" />
          <Badge label="Queued" color="cyan" icon="⏱" size="md" />
        </div>
      </div>

      {/* ── Real-World Usage ── */}
      <div>
        <div
          style={{
            fontFamily: "var(--font-mono)",
            fontSize: "var(--font-size-xs)",
            fontWeight: 600,
            textTransform: "uppercase",
            letterSpacing: "0.06em",
            color: "var(--text-muted)",
            marginBottom: "var(--space-1)",
          }}
        >
          Real-World Usage
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-2)" }}>
          {/* Priority badges */}
          <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-1)", alignItems: "center" }}>
            <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)", width: 80 }}>Priority</span>
            <Badge label="P0 Critical" color="red" variant="filled" size="md" />
            <Badge label="P1 High" color="amber" variant="subtle" size="md" />
            <Badge label="P2 Medium" color="blue" variant="subtle" size="md" />
            <Badge label="P3 Low" color="gray" variant="subtle" size="md" />
          </div>
          {/* Methodology badges */}
          <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-1)", alignItems: "center" }}>
            <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)", width: 80 }}>Method</span>
            <Badge label="Scrum" color="blue" variant="outline" />
            <Badge label="Kanban" color="violet" variant="outline" />
            <Badge label="Waterfall" color="cyan" variant="outline" />
          </div>
          {/* Agent status badges */}
          <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-1)", alignItems: "center" }}>
            <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)", width: 80 }}>Agent</span>
            <Badge label="Active" color="emerald" icon="●" />
            <Badge label="Working" color="violet" icon="⬢" />
            <Badge label="Idle" color="gray" icon="○" />
          </div>
          {/* Source badges */}
          <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-1)", alignItems: "center" }}>
            <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)", width: 80 }}>Source</span>
            <Badge label="Manual" color="default" />
            <Badge label="AI Suggested" color="violet" icon="⚡" />
            <Badge label="Imported" color="cyan" />
          </div>
        </div>
      </div>
    </div>
  );
}
