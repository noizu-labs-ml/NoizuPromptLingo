'use client'

import { useState, useId } from 'react';

export type ToggleSize = 'sm' | 'md';

export interface ToggleProps {
  /** Controlled checked state. If omitted the component manages its own state. */
  checked?: boolean;
  onChange?: (checked: boolean) => void;
  size?: ToggleSize;
  withIcon?: boolean;
  disabled?: boolean;
  label?: string;
  description?: string;
  className?: string;
  /** When a label is present, place it to the left of the toggle (full-width justify). */
  labelLeft?: boolean;
}

function XIcon() {
  return (
    <svg fill="none" viewBox="0 0 12 12" style={{ width: '0.75rem', height: '0.75rem' }} aria-hidden="true">
      <path
        d="M4 8l2-2m0 0l2-2M6 6L4 4m2 2l2 2"
        stroke="currentColor"
        strokeWidth={2}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function CheckIcon() {
  return (
    <svg fill="currentColor" viewBox="0 0 12 12" style={{ width: '0.75rem', height: '0.75rem' }} aria-hidden="true">
      <path d="M3.707 5.293a1 1 0 00-1.414 1.414l1.414-1.414zM5 8l-.707.707a1 1 0 001.414 0L5 8zm4.707-3.293a1 1 0 00-1.414-1.414l1.414 1.414zm-7.414 2l2 2 1.414-1.414-2-2-1.414 1.414zm3.414 2l4-4-1.414-1.414-4 4 1.414 1.414z" />
    </svg>
  );
}

function ToggleTrack({
  isChecked,
  isDisabled,
  size,
  withIcon,
  inputId,
  labelId,
  descriptionId,
  onToggle,
}: {
  isChecked: boolean;
  isDisabled: boolean;
  size: ToggleSize;
  withIcon: boolean;
  inputId: string;
  labelId?: string;
  descriptionId?: string;
  onToggle: () => void;
}) {
  const trackCls = [
    'twp-toggle',
    size === 'sm' ? 'twp-toggle-sm' : '',
    isChecked ? 'twp-toggle-checked' : '',
    isDisabled ? 'twp-toggle-disabled' : '',
  ].filter(Boolean).join(' ');

  const knobCls = [
    'twp-toggle-knob',
    isChecked ? 'twp-toggle-knob-checked' : '',
  ].filter(Boolean).join(' ');

  return (
    <div
      className={trackCls}
      aria-disabled={isDisabled || undefined}
      onClick={isDisabled ? undefined : onToggle}
    >
      <span className={knobCls}>
        {withIcon && (
          <>
            <span
              aria-hidden="true"
              className={[
                'twp-toggle-icon-off',
                isChecked ? 'twp-toggle-icon-off-hidden' : '',
              ].filter(Boolean).join(' ')}
            >
              <XIcon />
            </span>
            <span
              aria-hidden="true"
              className={[
                'twp-toggle-icon-on',
                isChecked ? 'twp-toggle-icon-on-visible' : '',
              ].filter(Boolean).join(' ')}
            >
              <CheckIcon />
            </span>
          </>
        )}
      </span>
      <input
        id={inputId}
        type="checkbox"
        role="switch"
        checked={isChecked}
        disabled={isDisabled}
        aria-checked={isChecked}
        aria-labelledby={labelId}
        aria-describedby={descriptionId}
        onChange={onToggle}
        className="twp-toggle-input"
      />
    </div>
  );
}

export function Toggle({
  checked,
  onChange,
  size = 'md',
  withIcon = false,
  disabled = false,
  label,
  description,
  className = '',
  labelLeft = false,
}: ToggleProps) {
  const [internalChecked, setInternalChecked] = useState(false);
  const isControlled = checked !== undefined;
  const isChecked = isControlled ? checked : internalChecked;

  const uid = useId();
  const inputId = `${uid}-toggle`;
  const labelId = label ? `${uid}-label` : undefined;
  const descriptionId = description ? `${uid}-desc` : undefined;

  function handleToggle() {
    if (disabled) return;
    const next = !isChecked;
    if (!isControlled) setInternalChecked(next);
    onChange?.(next);
  }

  const track = (
    <ToggleTrack
      isChecked={isChecked}
      isDisabled={disabled}
      size={size}
      withIcon={withIcon}
      inputId={inputId}
      labelId={labelId}
      descriptionId={descriptionId}
      onToggle={handleToggle}
    />
  );

  if (!label && !description) {
    return <div className={className || undefined}>{track}</div>;
  }

  const fieldCls = [
    'twp-toggle-field',
    labelLeft ? 'twp-toggle-field-left' : '',
    className,
  ].filter(Boolean).join(' ');

  return (
    <div className={fieldCls}>
      {track}
      <div className="twp-toggle-label-group">
        {label && (
          <label id={labelId} htmlFor={inputId} className="twp-toggle-label">
            {label}
          </label>
        )}
        {description && (
          <span id={descriptionId} className="twp-toggle-description">
            {description}
          </span>
        )}
      </div>
    </div>
  );
}

// ── Showcase ────────────────────────────────────────────────────────────────

export function ToggleShowcase() {
  const [controlled, setControlled] = useState(true);

  return (
    <div className="twp-showcase">

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">default (off)</div>
        <div className="twp-showcase-row">
          <Toggle />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">default (on)</div>
        <div className="twp-showcase-row">
          <Toggle checked={true} onChange={() => {}} />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">controlled (click to toggle)</div>
        <div className="twp-showcase-row">
          <Toggle checked={controlled} onChange={setControlled} />
          <span style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-muted)' }}>
            {controlled ? 'on' : 'off'}
          </span>
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">small</div>
        <div className="twp-showcase-row">
          <Toggle size="sm" />
          <Toggle size="sm" checked={true} onChange={() => {}} />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with icon</div>
        <div className="twp-showcase-row">
          <Toggle withIcon />
          <Toggle withIcon checked={true} onChange={() => {}} />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with label</div>
        <div className="twp-showcase-row">
          <Toggle label="Enable notifications" />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with label + description</div>
        <div className="twp-showcase-row" style={{ maxWidth: '28rem' }}>
          <Toggle
            label="Available to hire"
            description="Let recruiters and employers know you are open to new opportunities."
          />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">label left (justify layout)</div>
        <div className="twp-showcase-row" style={{ maxWidth: '28rem', width: '100%' }}>
          <Toggle
            label="Dark mode"
            description="Switch the interface to a dark color scheme."
            labelLeft
            checked={controlled}
            onChange={setControlled}
            className="w-full"
          />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">disabled (off)</div>
        <div className="twp-showcase-row">
          <Toggle disabled />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">disabled (on)</div>
        <div className="twp-showcase-row">
          <Toggle disabled checked={true} onChange={() => {}} />
        </div>
      </div>

    </div>
  );
}
