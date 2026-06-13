"use client";
import * as React from "react";
import { ScoreBadge } from "@/components/ui";
import type { RunScore, RunStep, RunVerdict } from "@/lib/api";

export interface StepDetailProps {
  step: RunStep;
  scores: RunScore[];
}

/**
 * Context-panel body rendered when a user clicks a transcript turn or a
 * graph node. Shows the step content, judge rationale (if any), and any
 * per-expectation scores attached to the step.
 */
export function StepDetail({ step, scores }: StepDetailProps) {
  return (
    <div>
      <section style={{ marginBottom: "var(--space-5)" }}>
        <SectionHeading>Content</SectionHeading>
        <div
          style={{
            fontSize: "var(--text-body)",
            whiteSpace: "pre-wrap",
            padding: "var(--space-3)",
            background: "var(--bg-well)",
            borderRadius: "var(--radius-sm)",
            border: "1px solid var(--border-subtle)",
          }}
        >
          {step.content}
        </div>
      </section>

      {step.rationale ? (
        <section style={{ marginBottom: "var(--space-5)" }}>
          <SectionHeading color="var(--copper)">Judge rationale</SectionHeading>
          <p
            style={{
              fontSize: "var(--text-small)",
              fontWeight: 500,
              color: "var(--copper)",
              background: "var(--copper-wash)",
              borderLeft: "3px solid var(--copper-dim)",
              padding: "var(--space-2) var(--space-3)",
              borderRadius: "var(--radius-sm)",
              margin: 0,
            }}
          >
            {step.rationale}
          </p>
        </section>
      ) : null}

      {scores.length > 0 ? (
        <section>
          <SectionHeading>Expectations</SectionHeading>
          <ul
            style={{
              listStyle: "none",
              padding: 0,
              margin: 0,
              display: "grid",
              gap: "var(--space-2)",
            }}
          >
            {scores.map((s) => (
              <ScoreRow key={s.id} score={s} />
            ))}
          </ul>
        </section>
      ) : null}
    </div>
  );
}

function SectionHeading({
  children,
  color,
}: {
  children: React.ReactNode;
  color?: string;
}) {
  return (
    <h3
      style={{
        fontSize: "var(--text-h3)",
        fontWeight: 600,
        margin: "0 0 var(--space-2)",
        color,
      }}
    >
      {children}
    </h3>
  );
}

function ScoreRow({ score }: { score: RunScore }) {
  return (
    <li
      style={{
        padding: "var(--space-2) var(--space-3)",
        border: "1px solid var(--border-default)",
        borderRadius: "var(--radius-sm)",
      }}
    >
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          gap: "var(--space-2)",
        }}
      >
        <span style={{ fontSize: "var(--text-small)" }}>{score.label}</span>
        <ScoreBadge state={score.verdict} score={score.value} />
      </div>
      {score.rationale ? (
        <p
          style={{
            fontSize: "var(--text-caption)",
            color: "var(--text-secondary)",
            margin: "var(--space-1) 0 0",
          }}
        >
          {score.rationale}
        </p>
      ) : null}
    </li>
  );
}

/** Fallback mapping from run status → verdict glyph state. */
export function deriveVerdictFromRun(
  status: string,
  explicit: RunVerdict | null | undefined,
): RunVerdict {
  if (explicit) return explicit;
  switch (status) {
    case "pass":
      return "pass";
    case "warn":
      return "warn";
    case "fail":
    case "error":
    case "cancelled":
      return "fail";
    default:
      return "freeball";
  }
}
