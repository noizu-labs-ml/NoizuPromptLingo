"use client";
import * as React from "react";
import type { RunVerdict } from "@/lib/api";
import { ScoreBadge } from "@/components/ui";
import { cyAttrs } from "@/utils/cypress";

export interface VerdictBannerProps {
  verdict: RunVerdict;
  score?: number | null;
  durationMs?: number | null;
  agentName?: string | null;
  personaName?: string | null;
  startedAt?: string | null;
  /** When true, plays the state-specific verdict-reveal animation. */
  revealing: boolean;
}

const LABELS: Record<RunVerdict, string> = {
  pass: "PASS",
  warn: "WARN",
  fail: "FAIL",
  freeball: "FREEBALL",
};

/**
 * 80 px verdict banner with eval glyph, giant label, and run metadata.
 * Plays its state-specific reveal animation when `revealing` becomes true.
 *
 * Glyphs match the Forge spec in `design/direction-d-forge.md`:
 *   pass    — The Seal (rounded-rect node silhouette + checkmark stroke)
 *   warn    — The Flag (node + exclamation + filled dot)
 *   fail    — The Break (node + offset diagonal lines)
 *   freeball — The Drift (dashed node + drift arrow)
 */
export function VerdictBanner({
  verdict,
  score,
  durationMs,
  agentName,
  personaName,
  startedAt,
  revealing,
}: VerdictBannerProps) {
  const cls = [
    "sg-verdict-banner",
    `eval-${verdict}`,
    revealing ? "is-revealing" : "",
  ]
    .filter(Boolean)
    .join(" ");

  return (
    <div
      className={cls}
      role="status"
      aria-live="polite"
      aria-label={`Verdict: ${LABELS[verdict]}`}
      {...cyAttrs({ cy: "verdict-banner", cyValue: verdict })}
    >
      <div className="sg-verdict-banner__glyph" aria-hidden="true">
        {verdict === "pass" ? <SealGlyph /> : null}
        {verdict === "warn" ? <FlagGlyph /> : null}
        {verdict === "fail" ? <BreakGlyph /> : null}
        {verdict === "freeball" ? <DriftGlyph /> : null}
      </div>
      <div>
        <div
          className="sg-verdict-banner__label"
          data-cy="verdict-label"
        >
          {LABELS[verdict]}
        </div>
      </div>
      <div
        className="sg-verdict-banner__meta"
        data-cy="verdict-meta"
      >
        {typeof score === "number" ? (
          <ScoreBadge state={verdict} score={score} />
        ) : null}
        {typeof durationMs === "number" ? (
          <span data-cy="verdict-duration">{formatDuration(durationMs)}</span>
        ) : null}
        {agentName ? <span data-cy="verdict-agent">via {agentName}</span> : null}
        {personaName ? (
          <span data-cy="verdict-persona">as {personaName}</span>
        ) : null}
        {startedAt ? <span data-cy="verdict-started">{startedAt}</span> : null}
      </div>
    </div>
  );
}

function SealGlyph() {
  return (
    <svg
      width="48"
      height="48"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.5"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <rect x="3" y="5" width="18" height="14" rx="3" />
      <path className="sg-verdict-stroke" d="M8.5 12.5l2.5 2.5 5-5" />
    </svg>
  );
}

function FlagGlyph() {
  return (
    <svg
      width="48"
      height="48"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.5"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <rect x="3" y="5" width="18" height="14" rx="3" />
      <line x1="12" y1="9" x2="12" y2="13" />
      <circle cx="12" cy="15.5" r="0.75" fill="currentColor" stroke="none" />
    </svg>
  );
}

function BreakGlyph() {
  return (
    <svg
      width="48"
      height="48"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.5"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <rect x="3" y="5" width="18" height="14" rx="3" />
      {/* Break lines — offset by 1 px for the fractured effect. */}
      <path d="M9 9.5l6 5.5" />
      <path d="M15 9l-6 6" />
    </svg>
  );
}

function DriftGlyph() {
  return (
    <svg
      width="48"
      height="48"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.5"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <rect x="3" y="5" width="18" height="14" rx="3" strokeDasharray="4 3" />
      <path className="sg-verdict-arrow" d="M10 14l4.5-4.5" />
      <path className="sg-verdict-arrow" d="M11.5 9.5h3v3" />
    </svg>
  );
}

function formatDuration(ms: number): string {
  if (ms < 1000) return `${ms}ms`;
  if (ms < 60_000) return `${(ms / 1000).toFixed(1)}s`;
  const mins = Math.floor(ms / 60_000);
  const secs = Math.round((ms % 60_000) / 1000);
  return `${mins}m ${secs}s`;
}
