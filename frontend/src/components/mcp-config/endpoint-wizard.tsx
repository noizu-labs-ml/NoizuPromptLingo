'use client';

import { useCallback, useEffect, useMemo, useReducer, useState } from 'react';
import { WizardStepper, type WizardStepDef } from '@/components/kit';
import ToolPicker from '@/components/mcp-config/tool-picker';
import {
  initialWizardState,
  proposalToConfig,
  reduceWizard,
  type EndpointWizardState,
  type WizardSource,
  type WizardToolSelection,
} from '@/components/mcp-config/endpoint-wizard-state';
import {
  api,
  type McpCustomGroup,
  type McpCustomScope,
  type SlugAvailabilityResponse,
} from '@/lib/api';

/**
 * PRD-020 FR-6 — 3-step endpoint creation wizard (US-108/110/111):
 *   1. identity: name / description / auto-slug (+ inline availability check)
 *   2. LLM clarifying questions — skippable to the manual picker (D2); on
 *      llm_unavailable the wizard falls back automatically (D3)
 *   3. review proposed tools with Enabled/Visible toggles, optional "Add
 *      more" via the manual picker, then a single POST /endpoints create.
 *
 * Clone mode (FR-4) enters via `clone_prefill`, prefills step 1 from the
 * source, and Continue submits directly (steps 2-3 skipped).
 */
export interface EndpointWizardProps {
  open: boolean;
  catalog: McpCustomGroup[];
  onClose: () => void;
  onCreated?: (endpoint: McpCustomScope) => void;
  /** When set, the wizard opens in clone mode (FR-4): prefilled step 1,
   * Continue submits directly (steps 2-3 skipped). */
  cloneSource?: (WizardSource & { name: string; description: string }) | null;
}

const SLUG_FORMAT = /^[a-z0-9][a-z0-9-]{0,62}$/;

function isValidSlugFormat(slug: string): boolean {
  return SLUG_FORMAT.test(slug);
}

function answersToArray(answers: Record<string, string | string[]>) {
  return Object.entries(answers)
    .filter(([, value]) => (typeof value === 'string' ? value.trim() !== '' : true))
    .map(([question_id, value]) => ({
      question_id,
      answer: Array.isArray(value) ? value.join(', ') : value,
    }));
}

export default function EndpointWizard({
  open,
  catalog,
  onClose,
  onCreated,
  cloneSource = null,
}: EndpointWizardProps) {
  const [state, dispatch] = useReducer(reduceWizard, undefined, initialWizardState);
  const [step, setStep] = useState(0);
  const [showPicker, setShowPicker] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);

  // Fresh wizard on every open (clean discard of the previous attempt); clone
  // mode prefills step 1 from the source via the pinned clone_prefill action.
  useEffect(() => {
    if (open) {
      if (cloneSource) {
        dispatch({ type: 'clone_prefill', source: cloneSource });
      } else {
        dispatch({ type: 'cancel' });
      }
      setStep(0);
      setShowPicker(false);
      setSubmitError(null);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, cloneSource]);

  // FR-1 client integration: debounced ~300ms availability check; request
  // failures degrade silently (slugStatus stays null -> submit-time handling).
  useEffect(() => {
    if (!open || !state.slug) {
      dispatch({ type: 'slug_status', status: null });
      return;
    }
    if (!isValidSlugFormat(state.slug)) {
      const invalid: SlugAvailabilityResponse = { available: false, reason: 'invalid' };
      dispatch({ type: 'slug_status', status: invalid });
      return;
    }

    let cancelled = false;
    const timer = setTimeout(async () => {
      try {
        const result = await api.checkSlugAvailable(state.slug);
        if (!cancelled) dispatch({ type: 'slug_status', status: result });
      } catch {
        // Silent degrade (FR-1): submit-time conflict handling covers it.
      }
    }, 300);

    return () => {
      cancelled = true;
      clearTimeout(timer);
    };
  }, [open, state.slug]);

  // Step 2 entry: ask for clarifying questions (create mode only).
  useEffect(() => {
    if (!open || step !== 1 || state.mode !== 'create') return;
    if (state.status !== 'idle' || state.questions.length > 0) return;

    let cancelled = false;
    dispatch({ type: 'status', value: 'loading-questions' });

    (async () => {
      try {
        const res = await api.proposeEndpointTools({
          name: state.name.trim() || undefined,
          description: state.description.trim(),
        });
        if (cancelled) return;

        if (res.status === 'questions') {
          dispatch({ type: 'questions_received', questions: res.questions });
        } else {
          // proposal at step-entry time, or llm_unavailable: both route onward.
          if (res.status === 'proposal') {
            dispatch({ type: 'proposal_received', tools: res.tools, summary: res.summary });
          } else {
            dispatch({ type: 'llm_unavailable' });
          }
          dispatch({ type: 'status', value: 'idle' });
        }
      } catch {
        if (!cancelled) {
          dispatch({ type: 'llm_unavailable' });
          dispatch({ type: 'status', value: 'idle' });
        }
      }
    })();

    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, step, state.mode, state.status, state.questions.length]);

  const identityValid = useMemo(() => {
    const slugOk =
      isValidSlugFormat(state.slug) && !(state.slugStatus && !state.slugStatus.available);
    return slugOk && state.description.trim() !== '';
  }, [state.slug, state.slugStatus, state.description]);

  const reviewValid = state.selections.length > 0;

  const steps: readonly WizardStepDef<EndpointWizardState>[] = useMemo(() => {
    const identity: WizardStepDef<EndpointWizardState> = {
      id: 'identity',
      title: state.mode === 'clone' ? 'Clone endpoint' : 'Describe this endpoint',
      description:
        state.mode === 'clone'
          ? 'Prefilled from the source — adjust anything, then create your copy.'
          : 'What is this endpoint for? The description drives the tool suggestions.',
      isValid: () => identityValid,
      invalidMessage:
        'A valid, available slug and a short description are required to continue.',
    };

    if (state.mode === 'clone') return [identity];

    return [
      identity,
      {
        id: 'clarify',
        title: 'A few questions',
        description: 'Answer to sharpen the suggestions, or pick tools manually.',
      },
      {
        id: 'review',
        title: 'Review proposed tools',
        description: 'Toggle Enabled/Visible per tool, then create the endpoint.',
        isValid: () => reviewValid,
        invalidMessage: 'Add at least one tool before creating the endpoint.',
      },
    ];
  }, [state.mode, identityValid, reviewValid]);

  const groupOf = useCallback(
    (name: string): string =>
      catalog.find((group) => group.tools.some((tool) => tool.name === name))?.id ?? 'other',
    [catalog],
  );

  /** FR-6 step 2 continue: fire the proposal round with the answers verbatim. */
  async function requestProposal() {
    dispatch({ type: 'status', value: 'loading-proposal' });

    try {
      const res = await api.proposeEndpointTools({
        name: state.name.trim() || undefined,
        description: state.description.trim(),
        answers: answersToArray(state.answers),
      });

      if (res.status === 'proposal') {
        dispatch({ type: 'proposal_received', tools: res.tools, summary: res.summary });
        dispatch({ type: 'status', value: 'idle' });
        setStep(2);
      } else if (res.status === 'questions') {
        dispatch({ type: 'questions_received', questions: res.questions });
        dispatch({ type: 'status', value: 'idle' });
      } else {
        dispatch({ type: 'llm_unavailable' });
        dispatch({ type: 'status', value: 'idle' });
      }
    } catch {
      dispatch({ type: 'llm_unavailable' });
      dispatch({ type: 'status', value: 'idle' });
    }
  }

  async function handleStepChange(next: number) {
    if (next === step) {
      // Finish on the final step = submit.
      await submit();
      return;
    }

    if (step === 0 && state.mode === 'clone') {
      await submit();
      return;
    }

    setStep(next);
  }

  function pickerSelections(names: string[]): WizardToolSelection[] {
    return names.map((name) => ({ name, group: groupOf(name), enabled: true, visible: true }));
  }

  async function submit() {
    if (state.status === 'submitting') return;
    setSubmitError(null);
    dispatch({ type: 'status', value: 'submitting' });

    try {
      const base = {
        name: state.name.trim(),
        slug: state.slug.trim(),
        description: state.description.trim(),
      };

      let input: Parameters<typeof api.createMcpEndpoint>[0];

      if (state.mode === 'clone') {
        const source: WizardSource | undefined = state.source;
        input =
          source?.kind === 'template' && source.slug
            ? { ...base, source_slug: source.slug }
            : { ...base, source_id: source?.id };
      } else {
        input = { ...base, config: proposalToConfig(state.selections) };
      }

      const res = await api.createMcpEndpoint(input);
      onCreated?.(res.endpoint);
      onClose();
    } catch (err) {
      // 409 or 422-with-errors.slug etc: stay on the current step, inline error,
      // wizard state intact (FR-6 / FR-4).
      setSubmitError(err instanceof Error ? err.message : 'Could not create the endpoint.');
      dispatch({ type: 'status', value: 'idle' });
    }
  }

  function renderIdentity() {
    const slugUnavailable = state.slugStatus && !state.slugStatus.available;

    return (
      <div style={{ display: 'grid', gap: 10 }}>
        <div className="sg-field">
          <label htmlFor="wizard-name">Name</label>
          <input
            id="wizard-name"
            className="gh-add-form__input"
            value={state.name}
            onChange={(e) => dispatch({ type: 'set_name', value: e.target.value })}
            placeholder="Support bot"
          />
        </div>

        <div className="sg-field">
          <label htmlFor="wizard-description">Description</label>
          <textarea
            id="wizard-description"
            className="gh-add-form__input"
            rows={3}
            value={state.description}
            onChange={(e) => dispatch({ type: 'set_description', value: e.target.value })}
            placeholder="What should this endpoint be able to do?"
          />
        </div>

        <div className="sg-field">
          <label htmlFor="wizard-slug">Slug</label>
          <input
            id="wizard-slug"
            className="gh-add-form__input font-mono"
            value={state.slug}
            onChange={(e) => dispatch({ type: 'set_slug', value: e.target.value })}
            placeholder="support-bot"
          />
          {state.slug && !isValidSlugFormat(state.slug) ? (
            <p style={{ fontSize: 12, color: 'var(--text-3)', margin: '4px 0 0' }}>
              Lowercase letters, numbers and hyphens; must start alphanumeric (max 63).
            </p>
          ) : null}
          {slugUnavailable && state.slugStatus?.reason !== 'invalid' ? (
            <p style={{ fontSize: 12, color: 'var(--text-3)', margin: '4px 0 0' }}>
              {state.slugStatus?.reason === 'reserved'
                ? 'That slug is reserved.'
                : 'That slug is already taken.'}
              {state.slugStatus?.suggestion ? (
                <>
                  {' '}
                  Try{' '}
                  <button
                    type="button"
                    className="sg-btn sg-btn--outline sg-btn--sm"
                    onClick={() => dispatch({ type: 'set_slug', value: state.slugStatus!.suggestion! })}
                  >
                    {state.slugStatus.suggestion}
                  </button>
                </>
              ) : null}
            </p>
          ) : null}
        </div>

        {submitError ? <p role="alert" style={{ color: 'var(--text-3)' }}>{submitError}</p> : null}
      </div>
    );
  }

  function renderClarify() {
    if (state.status === 'fallback' || showPicker) {
      return (
        <ToolPicker
          catalog={catalog}
          selected={Object.fromEntries(state.selections.map((s) => [s.name, true]))}
          fallbackNotice={
            state.status === 'fallback'
              ? 'Automatic suggestions are unavailable — pick the tools to include below. Everything you entered so far is preserved.'
              : null
          }
          onConfirm={(names) => {
            dispatch({ type: 'add_selections', selections: pickerSelections(names) });
            setShowPicker(false);
            if (state.status === 'fallback') setStep(2);
          }}
          onCancel={state.status === 'fallback' ? undefined : () => setShowPicker(false)}
        />
      );
    }

    if (state.status === 'loading-questions' || state.status === 'loading-proposal') {
      return <p className="sg-page-intro">Thinking about useful tools…</p>;
    }

    return (
      <div style={{ display: 'grid', gap: 12 }}>
        <button
          type="button"
          className="sg-btn sg-btn--outline sg-btn--sm"
          onClick={() => dispatch({ type: 'skip_to_manual' })}
        >
          Pick tools manually
        </button>

        {state.questions.length === 0 ? (
          <p className="sg-page-intro" style={{ margin: 0 }}>
            No clarifying questions — continue to get suggestions.
          </p>
        ) : null}

        {state.questions.map((question) => {
          const answer = state.answers[question.id];
          const answerText = typeof answer === 'string' ? answer : '';

          return (
          <div key={question.id} className="sg-field">
            <label htmlFor={`q-${question.id}`}>{question.prompt}</label>
            {question.kind === 'text' ? (
              <input
                id={`q-${question.id}`}
                className="gh-add-form__input"
                value={answerText}
                onChange={(e) =>
                  dispatch({ type: 'set_answer', questionId: question.id, value: e.target.value })
                }
              />
            ) : question.kind === 'single' ? (
              <select
                id={`q-${question.id}`}
                value={answerText}
                onChange={(e) =>
                  dispatch({ type: 'set_answer', questionId: question.id, value: e.target.value })
                }
              >
                <option value="">(skip)</option>
                {(question.options ?? []).map((option) => (
                  <option key={option} value={option}>
                    {option}
                  </option>
                ))}
              </select>
            ) : (
              <div style={{ display: 'grid', gap: 4 }}>
                {(question.options ?? []).map((option) => {
                  const current = Array.isArray(answer) ? answer : [];
                  const checkedNow = current.includes(option);
                  const next = checkedNow ? current.filter((v) => v !== option) : [...current, option];
                  return (
                    <label key={option} style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                      <input
                        type="checkbox"
                        checked={checkedNow}
                        onChange={() =>
                          dispatch({ type: 'set_answer', questionId: question.id, value: next.join(', ') })
                        }
                      />
                      {option}
                    </label>
                  );
                })}
              </div>
            )}
          </div>
          );
        })}
      </div>
    );
  }

  function renderReview() {
    return (
      <div style={{ display: 'grid', gap: 10 }}>
        {state.proposalSummary ? (
          <p className="sg-page-intro" style={{ margin: 0 }}>
            {state.proposalSummary}
          </p>
        ) : null}

        {state.selections.length === 0 ? (
          <p className="sg-page-intro" style={{ margin: 0 }}>
            No tools selected yet — add some below.
          </p>
        ) : null}

        <ul style={{ listStyle: 'none', margin: 0, padding: 0, display: 'grid', gap: 8 }}>
          {state.selections.map((selection) => (
            <li
              key={selection.name}
              style={{
                border: '1px solid var(--border-1, #ddd)',
                borderRadius: 8,
                padding: 10,
                display: 'grid',
                gap: 6,
              }}
            >
              <div>
                <span className="font-mono" style={{ fontSize: 13 }}>
                  {selection.name}
                </span>
                <span style={{ fontSize: 11, color: 'var(--text-3)' }}> · {selection.group}</span>
              </div>
              {selection.rationale ? (
                <p style={{ margin: 0, fontSize: 12, color: 'var(--text-3)' }}>
                  {selection.rationale}
                </p>
              ) : null}
              <div style={{ display: 'flex', gap: 16 }}>
                <label style={{ display: 'flex', gap: 6, alignItems: 'center', fontSize: 12 }}>
                  <input
                    type="checkbox"
                    checked={selection.enabled}
                    onChange={(e) =>
                      dispatch({
                        type: 'toggle_selection',
                        name: selection.name,
                        field: 'enabled',
                        value: e.target.checked,
                      })
                    }
                  />
                  Enabled
                </label>
                <label style={{ display: 'flex', gap: 6, alignItems: 'center', fontSize: 12 }}>
                  <input
                    type="checkbox"
                    checked={selection.visible}
                    onChange={(e) =>
                      dispatch({
                        type: 'toggle_selection',
                        name: selection.name,
                        field: 'visible',
                        value: e.target.checked,
                      })
                    }
                  />
                  Visible
                </label>
              </div>
            </li>
          ))}
        </ul>

        {showPicker ? (
          <ToolPicker
            catalog={catalog}
            selected={Object.fromEntries(state.selections.map((s) => [s.name, true]))}
            onConfirm={(names) => {
              dispatch({ type: 'add_selections', selections: pickerSelections(names) });
              setShowPicker(false);
            }}
            onCancel={() => setShowPicker(false)}
          />
        ) : (
          <button
            type="button"
            className="sg-btn sg-btn--outline sg-btn--sm"
            onClick={() => setShowPicker(true)}
          >
            Add more
          </button>
        )}

        {submitError ? <p role="alert" style={{ color: 'var(--text-3)' }}>{submitError}</p> : null}
      </div>
    );
  }

  function renderStep(_stepDef: WizardStepDef<EndpointWizardState>, index: number) {
    if (index === 0) return renderIdentity();
    if (index === 1) return renderClarify();
    return renderReview();
  }

  if (!open) return null;

  const busy = state.status === 'loading-questions' || state.status === 'loading-proposal' || state.status === 'submitting';

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-label="Create endpoint"
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 900,
        display: 'flex',
        alignItems: 'flex-start',
        justifyContent: 'center',
        padding: '8vh 16px 16px',
        background: 'rgba(0,0,0,0.5)',
        overflowY: 'auto',
      }}
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div
        className="dash-panel"
        style={{ width: '100%', maxWidth: 640, background: 'var(--bg-1, #fff)', padding: 16 }}
      >
        {busy ? <p className="sg-page-intro" aria-live="polite">Working…</p> : null}
        <WizardStepper
          steps={steps}
          state={state}
          currentStep={step}
          onStepChange={handleStepChange}
          renderStep={renderStep}
          onCancel={onClose}
          finishLabel={state.mode === 'clone' ? 'Create copy' : 'Create endpoint'}
          ariaLabel="Endpoint creation wizard"
        />
      </div>
    </div>
  );
}
