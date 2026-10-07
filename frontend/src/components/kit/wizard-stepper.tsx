'use client';

import { useEffect, useRef, type ReactNode } from 'react';

/**
 * PRD-020 FR-5 — domain-neutral, fully controlled wizard stepper.
 *
 * Host-owned state: the component never mutates anything; it renders the
 * active step's body via `renderStep` and reports allowed transitions through
 * `onStepChange`. Next/Finish are gated by the active step's `isValid`, Back
 * is disabled at step 0, forward navigation is sequential, and previously
 * visited steps are directly clickable. No MCP/backend imports (NFR-5,
 * contract-tested by `wizard-stepper.contract.test.ts`).
 */
export interface WizardStepDef<S> {
  id: string;
  title: string;
  description?: string;
  /** Gate for Next/Finish on this step; absent = always valid. */
  isValid?: (state: S) => boolean;
  invalidMessage?: string;
}

export interface WizardStepperProps<S> {
  steps: readonly WizardStepDef<S>[];
  /** Host-owned wizard state; the stepper never mutates it. */
  state: S;
  /** 0-based index of the active step. */
  currentStep: number;
  /** Back/Next/step-click; called only when the transition is allowed. */
  onStepChange: (nextStep: number) => void;
  /** Renders the active step's body. */
  renderStep: (step: WizardStepDef<S>, index: number) => ReactNode;
  onCancel?: () => void;
  cancelLabel?: string;
  backLabel?: string;
  nextLabel?: string;
  finishLabel?: string;
  ariaLabel?: string;
}

export default function WizardStepper<S>({
  steps,
  state,
  currentStep,
  onStepChange,
  renderStep,
  onCancel,
  cancelLabel = 'Cancel',
  backLabel = 'Back',
  nextLabel = 'Next',
  finishLabel = 'Finish',
  ariaLabel = 'Wizard',
}: WizardStepperProps<S>) {
  const total = steps.length;
  const stepIndex = Math.min(Math.max(currentStep, 0), Math.max(total - 1, 0));
  const step = steps[stepIndex];
  const atFirst = currentStep === 0;
  const atLast = stepIndex === total - 1;

  // Gate for the CURRENT step only; absent isValid = always valid.
  const gated = step?.isValid ? step.isValid(state) === false : false;
  const gateMessage = gated ? step?.invalidMessage ?? '' : '';

  const headingRef = useRef<HTMLHeadingElement | null>(null);

  // Focus the step heading after every step change (NFR-4 / FR-5 a11y).
  useEffect(() => {
    headingRef.current?.focus();
  }, [stepIndex]);

  // Sequential forward navigation; previously visited (earlier) steps are
  // directly clickable; a one-step advance obeys the same gate as Next.
  function goTo(next: number) {
    if (next === stepIndex) return;
    if (next < 0 || next > total - 1) return;
    if (next > stepIndex && (gated || next > stepIndex + 1)) return;
    onStepChange(next);
  }

  return (
    <div className="wizard-stepper" role="group" aria-label={ariaLabel}>
      {/* Transitions disabled under prefers-reduced-motion (FR-5). */}
      <style>{`@media (prefers-reduced-motion: reduce) { .wizard-stepper, .wizard-stepper * { transition: none !important; animation: none !important; } }`}</style>

      <div aria-live="polite" style={{ fontSize: 11, color: 'var(--text-3)', marginBottom: 8 }}>
        {`Step ${stepIndex + 1} of ${total}`}
      </div>

      <ol
        style={{
          display: 'flex',
          gap: 8,
          flexWrap: 'wrap',
          listStyle: 'none',
          margin: 0,
          padding: 0,
          marginBottom: 16,
        }}
      >
        {steps.map((s, index) => {
          const active = index === stepIndex;
          const reachable = index < stepIndex;
          const label = `${index + 1}. ${s.title}`;

          return (
            <li key={s.id}>
              <button
                type="button"
                aria-current={active ? 'step' : undefined}
                disabled={!active && !reachable}
                onClick={() => goTo(index)}
                className={`sg-btn sg-btn--sm ${active ? 'sg-btn--black' : 'sg-btn--outline'}`}
                style={{ opacity: reachable || active ? 1 : 0.5 }}
              >
                {label}
              </button>
            </li>
          );
        })}
      </ol>

      <h3
        ref={headingRef}
        tabIndex={-1}
        style={{ outline: 'none', margin: '0 0 4px', fontSize: 16 }}
      >
        {step?.title}
      </h3>
      {step?.description ? (
        <p className="sg-page-intro" style={{ marginTop: 0 }}>
          {step.description}
        </p>
      ) : null}

      <div>{renderStep(step, stepIndex)}</div>

      {gated && gateMessage ? (
        <p role="alert" style={{ color: 'var(--text-3)', fontSize: 12 }}>
          {gateMessage}
        </p>
      ) : null}

      <div style={{ display: 'flex', gap: 8, marginTop: 16, flexWrap: 'wrap' }}>
        {onCancel ? (
          <button
            type="button"
            className="sg-btn sg-btn--outline sg-btn--sm"
            onClick={onCancel}
          >
            {cancelLabel}
          </button>
        ) : null}
        <button
          type="button"
          className="sg-btn sg-btn--outline sg-btn--sm"
          onClick={() => goTo(stepIndex - 1)}
          disabled={atFirst}
        >
          {backLabel}
        </button>
        <button
          type="button"
          className="sg-btn sg-btn--black sg-btn--sm"
          onClick={() => (atLast ? onStepChange(stepIndex) : goTo(stepIndex + 1))}
          disabled={gated}
        >
          {atLast ? finishLabel : nextLabel}
        </button>
      </div>
    </div>
  );
}
