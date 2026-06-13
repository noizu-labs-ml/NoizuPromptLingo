"use client";
import * as React from "react";
import { EmptyState, ScoreBadge, ThreeVoiceTurn } from "@/components/ui";
import type { RunStep } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";

export interface RunTranscriptProps {
  steps: RunStep[];
  selectedStepId?: string | null;
  onSelectStep: (stepId: string) => void;
}

/**
 * Vertical three-voice transcript. Clicking (or Enter/Space on) a turn
 * opens its `<StepDetail>` in the run detail context panel.
 */
export function RunTranscript({
  steps,
  selectedStepId,
  onSelectStep,
}: RunTranscriptProps) {
  if (steps.length === 0) {
    return (
      <EmptyState
        glyph="search"
        headline="No steps yet"
        body="The run produced no recorded turns."
      />
    );
  }

  return (
    <ol
      style={{ listStyle: "none", padding: 0, margin: 0 }}
      data-cy="run-transcript-list"
    >
      {steps.map((step) => (
        <li
          key={step.id}
          data-cy="run-transcript-item"
          {...cyAttrs({ cyId: step.id, cyValue: step.verdict ?? "" })}
          style={{
            cursor: "pointer",
            outline:
              step.id === selectedStepId ? "2px solid var(--copper)" : "none",
            outlineOffset: 2,
            borderRadius: "var(--radius-sm)",
            padding: "var(--space-1)",
          }}
          onClick={() => onSelectStep(step.id)}
          onKeyDown={(e) => {
            if (e.key === "Enter" || e.key === " ") {
              e.preventDefault();
              onSelectStep(step.id);
            }
          }}
          tabIndex={0}
          role="button"
          aria-label={`Open step ${step.sequence}`}
        >
          <ThreeVoiceTurn
            voice={step.voice}
            turnNumber={step.sequence}
            timestamp={step.started_at ?? undefined}
            content={
              <div>
                <div style={{ whiteSpace: "pre-wrap" }}>{step.content}</div>
                {step.verdict ? (
                  <div
                    style={{
                      marginTop: "var(--space-2)",
                      display: "inline-block",
                    }}
                  >
                    <ScoreBadge
                      state={step.verdict}
                      score={step.score ?? 0}
                    />
                  </div>
                ) : null}
              </div>
            }
          />
        </li>
      ))}
    </ol>
  );
}
