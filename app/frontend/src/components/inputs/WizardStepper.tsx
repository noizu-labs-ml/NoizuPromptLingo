"use client";

import React from "react";

/**
 * WizardStepper — Multi-step progress indicator for wizard flows with validation status.
 *
 * @example
 * ```tsx
 * <WizardStepper steps={[{ label: "Details", isComplete: true, isValid: true }, { label: "Config" }, { label: "Review" }]} currentStep={1} onStepClick={goToStep} />
 * ```
 */

interface WizardStep { label: string; description?: string; isComplete?: boolean; isValid?: boolean; }
type StepperVariant = "inline" | "compact" | "expanded";

interface WizardStepperProps {
  steps: WizardStep[];
  currentStep: number;
  onStepClick?: (index: number) => void;
  allowSkip?: boolean;
  variant?: StepperVariant;
}

export function WizardStepper({ steps, currentStep, onStepClick, allowSkip = false, variant = "compact" }: WizardStepperProps) {
  const canClick = (i: number) => onStepClick && (allowSkip || i <= currentStep || (steps[i - 1]?.isComplete));

  if (variant === "inline") {
    return (
      <div role="navigation" aria-label={`Step ${currentStep + 1} of ${steps.length}`} style={{ display: "flex", alignItems: "center", gap: 0 }}>
        {steps.map((step, i) => {
          const active = i === currentStep;
          const complete = step.isComplete || i < currentStep;
          return (
            <React.Fragment key={i}>
              {i > 0 && <div style={{ flex: 1, height: 2, minWidth: 12, background: complete ? "var(--info, var(--blue))" : "color-mix(in srgb, var(--text-muted) 20%, transparent)" }} />}
              <div onClick={canClick(i) ? () => onStepClick!(i) : undefined} aria-current={active ? "step" : undefined} style={{ width: active ? 10 : 8, height: active ? 10 : 8, borderRadius: "50%", background: complete ? "var(--info, var(--blue))" : active ? "var(--info, var(--blue))" : "color-mix(in srgb, var(--text-muted) 25%, transparent)", cursor: canClick(i) ? "pointer" : "default", boxShadow: active ? "0 0 0 2px var(--bg), 0 0 0 4px var(--info, var(--blue))" : "none", display: "flex", alignItems: "center", justifyContent: "center" }}>
                {complete && <span style={{ color: "#fff", fontSize: "6px" }}>✓</span>}
              </div>
            </React.Fragment>
          );
        })}
      </div>
    );
  }

  if (variant === "compact") {
    return (
      <div role="navigation" aria-label={`Step ${currentStep + 1} of ${steps.length}`} style={{ display: "flex", alignItems: "center", gap: 0 }}>
        {steps.map((step, i) => {
          const active = i === currentStep;
          const complete = step.isComplete || i < currentStep;
          const invalid = active && step.isValid === false;
          return (
            <React.Fragment key={i}>
              {i > 0 && <div style={{ flex: 1, height: 2, minWidth: 16, background: complete ? "var(--info, var(--blue))" : "color-mix(in srgb, var(--text-muted) 20%, transparent)" }} />}
              <div onClick={canClick(i) ? () => onStepClick!(i) : undefined} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: "4px", cursor: canClick(i) ? "pointer" : "default" }}>
                <div style={{ width: 24, height: 24, borderRadius: "50%", background: complete ? "var(--info, var(--blue))" : active ? "var(--info, var(--blue))" : "color-mix(in srgb, var(--text-muted) 15%, transparent)", border: invalid ? "2px solid var(--error)" : active ? "2px solid var(--info, var(--blue))" : "none", color: complete || active ? "#fff" : "var(--text-muted)", display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 700 }}>
                  {complete ? "✓" : i + 1}
                </div>
                <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-2xs, 10px)", color: active ? "var(--text)" : "var(--text-muted)", fontWeight: active ? 600 : 400, whiteSpace: "nowrap" }}>{step.label}</span>
              </div>
            </React.Fragment>
          );
        })}
      </div>
    );
  }

  // expanded — with descriptions and validation
  return (
    <div role="navigation" aria-label={`Step ${currentStep + 1} of ${steps.length}`} style={{ display: "flex", flexDirection: "column", gap: "var(--space-1)" }}>
      {steps.map((step, i) => {
        const active = i === currentStep;
        const complete = step.isComplete || i < currentStep;
        const invalid = active && step.isValid === false;
        return (
          <div key={i} onClick={canClick(i) ? () => onStepClick!(i) : undefined} style={{ display: "flex", alignItems: "flex-start", gap: "10px", padding: "var(--space-2)", borderRadius: "var(--radius, 6px)", background: active ? "color-mix(in srgb, var(--info, var(--blue)) 6%, transparent)" : "transparent", border: active ? "1px solid var(--info, var(--blue))" : "1px solid transparent", cursor: canClick(i) ? "pointer" : "default" }}>
            <div style={{ width: 28, height: 28, borderRadius: "50%", background: complete ? "var(--info, var(--blue))" : active ? "var(--info, var(--blue))" : "color-mix(in srgb, var(--text-muted) 15%, transparent)", border: invalid ? "2px solid var(--error)" : "none", color: complete || active ? "#fff" : "var(--text-muted)", display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", fontWeight: 700, flexShrink: 0 }}>
              {complete ? "✓" : i + 1}
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontWeight: active ? 600 : 500, color: active ? "var(--text)" : complete ? "var(--text-secondary)" : "var(--text-muted)" }}>{step.label}</div>
              {step.description && <div style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)", marginTop: 2 }}>{step.description}</div>}
              {invalid && <div style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--error)", marginTop: 2 }}>⚠ Validation required</div>}
            </div>
          </div>
        );
      })}
    </div>
  );
}

export default WizardStepper;
