"use client";

import React, { useState, useEffect } from "react";

/**
 * TimeDisplay — Renders timestamps as relative ("2h ago") or absolute ("2026-05-27 14:30") with live ticking.
 *
 * @example
 * ```tsx
 * <TimeDisplay date={new Date("2026-05-27T12:00:00Z")} />
 * <TimeDisplay date="2026-05-27T12:00:00Z" format="absolute" />
 * <TimeDisplay date={Date.now() - 3600000} live />
 * <TimeDisplay date="2026-06-01T00:00:00Z" format="countdown" label="Sprint ends" />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

type TimeFormat = "relative" | "absolute" | "countdown";

interface TimeDisplayProps {
  /** Date value — Date object, ISO string, or timestamp */
  date: Date | string | number;
  /** Display format */
  format?: TimeFormat;
  /** Live-update relative times (tick every 60s) */
  live?: boolean;
  /** Label prefix (countdown mode) */
  label?: string;
  /** Urgency thresholds for countdown coloring (minutes). Default: { warn: 60, critical: 15 } */
  urgency?: { warn: number; critical: number };
  /** Click handler */
  onClick?: () => void;
}

// ── Helpers ─────────────────────────────────────────────────────

function toDate(d: Date | string | number): Date {
  if (d instanceof Date) return d;
  return new Date(d);
}

function relativeTime(date: Date): string {
  const now = Date.now();
  const diffMs = now - date.getTime();
  const future = diffMs < 0;
  const absDiff = Math.abs(diffMs);

  const minutes = Math.floor(absDiff / 60000);
  const hours = Math.floor(absDiff / 3600000);
  const days = Math.floor(absDiff / 86400000);

  if (minutes < 1) return future ? "just now" : "just now";
  if (minutes < 60) return future ? `in ${minutes}m` : `${minutes}m ago`;
  if (hours < 24) return future ? `in ${hours}h` : `${hours}h ago`;
  if (days < 30) return future ? `in ${days}d` : `${days}d ago`;
  const months = Math.floor(days / 30);
  return future ? `in ${months}mo` : `${months}mo ago`;
}

function absoluteTime(date: Date): string {
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

function countdownTime(date: Date): { text: string; minutesLeft: number } {
  const diffMs = date.getTime() - Date.now();
  if (diffMs <= 0) return { text: "expired", minutesLeft: 0 };

  const totalMinutes = Math.floor(diffMs / 60000);
  const days = Math.floor(totalMinutes / 1440);
  const hours = Math.floor((totalMinutes % 1440) / 60);
  const minutes = totalMinutes % 60;

  const parts: string[] = [];
  if (days > 0) parts.push(`${days}d`);
  if (hours > 0) parts.push(`${hours}h`);
  if (minutes > 0 || parts.length === 0) parts.push(`${minutes}m`);

  return { text: parts.join(" "), minutesLeft: totalMinutes };
}

// ── Component ───────────────────────────────────────────────────

export function TimeDisplay({
  date,
  format = "relative",
  live = false,
  label,
  urgency = { warn: 60, critical: 15 },
  onClick,
}: TimeDisplayProps) {
  const [, setTick] = useState(0);
  const dateObj = toDate(date);

  useEffect(() => {
    if (!live) return;
    const interval = setInterval(() => setTick((t) => t + 1), 60000);
    return () => clearInterval(interval);
  }, [live]);

  const Tag = onClick ? "button" : "time";
  const interactiveProps = onClick ? { type: "button" as const, onClick } : {};

  if (format === "countdown") {
    const { text, minutesLeft } = countdownTime(dateObj);
    const color =
      minutesLeft <= urgency.critical
        ? "var(--error)"
        : minutesLeft <= urgency.warn
          ? "var(--warning)"
          : "var(--text-secondary)";

    return (
      <Tag
        {...interactiveProps}
        dateTime={dateObj.toISOString()}
        title={absoluteTime(dateObj)}
        aria-label={`${label ? label + ": " : ""}${text} remaining`}
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
        {label && <span style={{ fontWeight: 400, color: "var(--text-muted)" }}>{label}</span>}
        <span>⏱</span>
        {text}
      </Tag>
    );
  }

  if (format === "absolute") {
    return (
      <Tag
        {...interactiveProps}
        dateTime={dateObj.toISOString()}
        title={relativeTime(dateObj)}
        style={{
          fontFamily: "var(--font-mono)",
          fontSize: "var(--font-size-xs)",
          color: "var(--text-muted)",
          background: "none",
          border: "none",
          padding: 0,
          cursor: onClick ? "pointer" : "default",
        }}
      >
        {absoluteTime(dateObj)}
      </Tag>
    );
  }

  // relative (default)
  return (
    <Tag
      {...interactiveProps}
      dateTime={dateObj.toISOString()}
      title={absoluteTime(dateObj)}
      style={{
        fontFamily: "var(--font-mono)",
        fontSize: "var(--font-size-xs)",
        color: "var(--text-muted)",
        background: "none",
        border: "none",
        padding: 0,
        cursor: onClick ? "pointer" : "default",
      }}
    >
      {relativeTime(dateObj)}
    </Tag>
  );
}

export default TimeDisplay;
