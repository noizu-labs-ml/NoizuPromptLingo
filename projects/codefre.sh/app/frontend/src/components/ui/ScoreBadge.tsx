"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";
import type { EvalState } from "./Button";

export interface ScoreBadgeProps {
  state: EvalState;
  score: number;
  /** Optional compact sparkline; array of values in 0..1 */
  sparkline?: number[];
  /** Decimal places (default 2) */
  precision?: number;
  className?: string;
  cy?: string;
  cyId?: string | number;
}

/**
 * Compact score indicator. Shows state-colored bg, numeric score, optional sparkline.
 *
 * @example
 * <ScoreBadge state="pass" score={0.92} sparkline={[0.8, 0.82, 0.9, 0.92]} />
 */
export function ScoreBadge({
  state,
  score,
  sparkline,
  precision = 2,
  className,
  cy = "score-badge",
  cyId,
}: ScoreBadgeProps) {
  const classes = ["sg-score-badge", `eval-${state}`, className || ""]
    .filter(Boolean)
    .join(" ");

  return (
    <span className={classes} {...cyAttrs({ cy, cyId, cyValue: state })}>
      <span>{score.toFixed(precision)}</span>
      {sparkline && sparkline.length > 1 ? (
        <Sparkline values={sparkline} />
      ) : null}
    </span>
  );
}

function Sparkline({ values }: { values: number[] }) {
  const w = 32;
  const h = 12;
  const max = Math.max(...values, 1);
  const min = Math.min(...values, 0);
  const range = max - min || 1;
  const step = w / (values.length - 1);
  const pts = values
    .map((v, i) => `${i * step},${h - ((v - min) / range) * h}`)
    .join(" ");

  return (
    <svg width={w} height={h} aria-hidden="true" style={{ marginLeft: 4 }}>
      <polyline
        points={pts}
        fill="none"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
        strokeLinecap="round"
      />
    </svg>
  );
}

export interface ScoreBarProps {
  state: EvalState;
  value: number;
  className?: string;
}

/** Horizontal fill bar variant. */
export function ScoreBar({ state, value, className }: ScoreBarProps) {
  const clamped = Math.max(0, Math.min(1, value));
  return (
    <span className={["sg-score-bar", className || ""].filter(Boolean).join(" ")}>
      <span
        className={`sg-score-bar__fill eval-${state}`}
        style={{ width: `${clamped * 100}%`, display: "block" }}
      />
    </span>
  );
}
