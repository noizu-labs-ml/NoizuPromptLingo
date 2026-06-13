"use client";

import React from "react";

/**
 * StepProgress — Wizard/flow step indicator showing current position in a multi-step process.
 *
 * @example
 * ```tsx
 * <StepProgress steps={["Details", "Config", "Review", "Deploy"]} current={1} />
 * <StepProgress steps={["Draft", "Review", "Approved"]} current={2} variant="compact" />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

type StepVariant = "inline" | "compact";

interface StepProgressProps {
  /** Step labels in order */
  steps: string[];
  /** Current step index (0-based) */
  current: number;
  /** Display variant */
  variant?: StepVariant;
  /** Click handler for navigating to a step */
  onStepClick?: (index: number) => void;
}

// ── Component ───────────────────────────────────────────────────

export function StepProgress({
  steps,
  current,
  variant = "inline",
  onStepClick,
}: StepProgressProps) {
  if (variant === "compact") {
    return (
      <span
        aria-label={`Step ${current + 1} of ${steps.length}: ${steps[current]}`}
        style={{
          fontFamily: "var(--font-mono)",
          fontSize: "var(--font-size-xs)",
          color: "var(--text-muted)",
        }}
      >
        <span style={{ fontWeight: 700, color: "var(--text)" }}>{current + 1}</span>
        <span style={{ margin: "0 2px" }}>/</span>
        <span>{steps.length}</span>
        <span style={{ margin: "0 4px" }}>·</span>
        <span style={{ color: "var(--text-secondary)" }}>{steps[current]}</span>
      </span>
    );
  }

  // inline — full step dots with labels
  return (
    <div
      role="navigation"
      aria-label={`Step ${current + 1} of ${steps.length}`}
      style={{ display: "flex", alignItems: "center", gap: 0 }}
    >
      {steps.map((step, i) => {
        const isComplete = i < current;
        const isCurrent = i === current;
        const isFuture = i > current;

        return (
          <React.Fragment key={i}>
            {/* Connector line (before each step except the first) */}
            {i > 0 && (
              <div
                style={{
                  flex: 1,
                  height: 2,
                  minWidth: 16,
                  background: isComplete || isCurrent
                    ? "var(--info, var(--blue))"
                    : "color-mix(in srgb, var(--text-muted) 20%, transparent)",
                  transition: "background 0.2s",
                }}
              />
            )}

            {/* Step dot + label */}
            <div
              role={onStepClick ? "button" : undefined}
              tabIndex={onStepClick ? 0 : undefined}
              onClick={onStepClick ? () => onStepClick(i) : undefined}
              onKeyDown={onStepClick ? (e) => e.key === "Enter" && onStepClick(i) : undefined}
              aria-label={`${step}${isComplete ? " (complete)" : isCurrent ? " (current)" : ""}`}
              aria-current={isCurrent ? "step" : undefined}
              style={{
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                gap: "4px",
                cursor: onStepClick ? "pointer" : "default",
              }}
            >
              <div
                style={{
                  width: isCurrent ? 12 : 8,
                  height: isCurrent ? 12 : 8,
                  borderRadius: "50%",
                  background: isComplete
                    ? "var(--info, var(--blue))"
                    : isCurrent
                      ? "var(--info, var(--blue))"
                      : "color-mix(in srgb, var(--text-muted) 25%, transparent)",
                  border: isCurrent ? "2px solid var(--bg)" : "none",
                  boxShadow: isCurrent ? "0 0 0 2px var(--info, var(--blue))" : "none",
                  transition: "all 0.2s",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                }}
              >
                {isComplete && (
                  <span style={{ color: "#fff", fontSize: "7px", lineHeight: 1 }}>✓</span>
                )}
              </div>
              <span
                style={{
                  fontFamily: "var(--font-body)",
                  fontSize: "var(--font-size-2xs, 10px)",
                  color: isFuture ? "var(--text-muted)" : "var(--text-secondary)",
                  fontWeight: isCurrent ? 600 : 400,
                  whiteSpace: "nowrap",
                }}
              >
                {step}
              </span>
            </div>
          </React.Fragment>
        );
      })}
    </div>
  );
}

export default StepProgress;
