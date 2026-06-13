"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";

export type StatusState =
  | "pending"
  | "running"
  | "pass"
  | "warn"
  | "fail"
  | "freeball"
  | "cancelled"
  | "error";

export interface StatusPillProps {
  state: StatusState;
  size?: "sm" | "md";
  showIcon?: boolean;
  label?: React.ReactNode;
  className?: string;
  cy?: string;
  cyId?: string | number;
}

const stateClass: Record<StatusState, string> = {
  pending: "",
  running: "",
  pass: "eval-pass",
  warn: "eval-warn",
  fail: "eval-fail",
  freeball: "eval-freeball",
  cancelled: "",
  error: "eval-fail",
};

const defaultLabel: Record<StatusState, string> = {
  pending: "Pending",
  running: "Running",
  pass: "Pass",
  warn: "Warn",
  fail: "Fail",
  freeball: "Freeball",
  cancelled: "Cancelled",
  error: "Error",
};

/** Compact SVG glyphs sized to 12px; use currentColor. */
const stateGlyph: Record<StatusState, React.ReactElement> = {
  pending: (
    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" aria-hidden="true">
      <circle cx="6" cy="6" r="4" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  ),
  running: (
    <svg width="12" height="12" viewBox="0 0 12 12" aria-hidden="true" style={{ animation: "sg-spin 1s linear infinite" }}>
      <circle cx="6" cy="6" r="4" fill="none" stroke="currentColor" strokeWidth="1.5" opacity="0.25" />
      <path d="M6 2a4 4 0 0 1 4 4" stroke="currentColor" strokeWidth="1.5" fill="none" strokeLinecap="round" />
    </svg>
  ),
  pass: (
    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" aria-hidden="true">
      <path d="M2 6.5l2.5 2.5L10 3.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  ),
  warn: (
    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" aria-hidden="true">
      <path d="M6 2 L10.5 10 H1.5 Z" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round" />
      <line x1="6" y1="5" x2="6" y2="7" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
      <circle cx="6" cy="8.5" r="0.5" fill="currentColor" />
    </svg>
  ),
  fail: (
    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" aria-hidden="true">
      <circle cx="6" cy="6" r="4.5" stroke="currentColor" strokeWidth="1.5" />
      <path d="M4.5 4.5l3 3 M7.5 4.5l-3 3" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  ),
  freeball: (
    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" aria-hidden="true">
      <path d="M4 8l4-4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
      <path d="M5.5 4h2.5v2.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  ),
  cancelled: (
    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" aria-hidden="true">
      <circle cx="6" cy="6" r="4.5" stroke="currentColor" strokeWidth="1.5" />
      <line x1="3.5" y1="6" x2="8.5" y2="6" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  ),
  error: (
    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" aria-hidden="true">
      <circle cx="6" cy="6" r="4.5" stroke="currentColor" strokeWidth="1.5" />
      <line x1="6" y1="3.5" x2="6" y2="6.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
      <circle cx="6" cy="8.5" r="0.5" fill="currentColor" />
    </svg>
  ),
};

/**
 * Pill-shaped status indicator with redundant color + glyph encoding.
 *
 * @example
 * <StatusPill state="pass" />
 * <StatusPill state="freeball" label="Off-script" size="sm" />
 */
export function StatusPill({
  state,
  size = "md",
  showIcon = true,
  label,
  className,
  cy = "status-pill",
  cyId,
}: StatusPillProps) {
  const classes = [
    "sg-pill",
    size === "sm" ? "sg-pill--sm" : "",
    stateClass[state],
    className || "",
  ]
    .filter(Boolean)
    .join(" ");

  return (
    <span
      className={classes}
      data-state={state}
      {...cyAttrs({ cy, cyId, cyValue: state })}
    >
      {showIcon ? stateGlyph[state] : null}
      <span>{label ?? defaultLabel[state]}</span>
      <style>{`@keyframes sg-spin { to { transform: rotate(360deg); } }`}</style>
    </span>
  );
}
