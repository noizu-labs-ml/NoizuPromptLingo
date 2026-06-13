'use client'

import { useState, useId, useEffect, useRef } from 'react';

export interface CheckboxProps {
  label?: string;
  description?: string;
  checked?: boolean;
  onChange?: (checked: boolean) => void;
  disabled?: boolean;
  id?: string;
  name?: string;
  indeterminate?: boolean;
  className?: string;
}

function CheckIcon() {
  return (
    <svg viewBox="0 0 10 10" fill="none" aria-hidden="true" style={{ width: '0.625rem', height: '0.625rem' }}>
      <path
        d="M1.5 5l2.5 2.5 4.5-4.5"
        stroke="currentColor"
        strokeWidth={1.75}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function IndeterminateIcon() {
  return (
    <svg viewBox="0 0 10 10" fill="none" aria-hidden="true" style={{ width: '0.625rem', height: '0.625rem' }}>
      <path
        d="M2 5h6"
        stroke="currentColor"
        strokeWidth={1.75}
        strokeLinecap="round"
      />
    </svg>
  );
}

export function Checkbox({
  label,
  description,
  checked,
  onChange,
  disabled = false,
  id,
  name,
  indeterminate = false,
  className = '',
}: CheckboxProps) {
  const [internalChecked, setInternalChecked] = useState(false);
  const isControlled = checked !== undefined;
  const isChecked = isControlled ? checked : internalChecked;

  const uid = useId();
  const inputId = id ?? `${uid}-checkbox`;
  const descriptionId = description ? `${uid}-desc` : undefined;

  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (inputRef.current) {
      inputRef.current.indeterminate = indeterminate;
    }
  }, [indeterminate]);

  function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
    if (disabled) return;
    const next = e.target.checked;
    if (!isControlled) setInternalChecked(next);
    onChange?.(next);
  }

  const showIcon = isChecked || indeterminate;
  const iconCls = ['twp-checkbox-icon', showIcon ? 'twp-checkbox-icon-visible' : ''].filter(Boolean).join(' ');

  const checkboxEl = (
    <div className="twp-checkbox-wrapper">
      <input
        ref={inputRef}
        id={inputId}
        name={name}
        type="checkbox"
        className="twp-checkbox"
        checked={isChecked}
        disabled={disabled}
        aria-describedby={descriptionId}
        onChange={handleChange}
      />
      <span className={iconCls} aria-hidden="true">
        {indeterminate ? <IndeterminateIcon /> : <CheckIcon />}
      </span>
    </div>
  );

  if (!label && !description) {
    return <div className={className || undefined}>{checkboxEl}</div>;
  }

  return (
    <div className={['twp-checkbox-field', className].filter(Boolean).join(' ')}>
      {checkboxEl}
      <div className="twp-checkbox-label-group">
        {label && (
          <label htmlFor={inputId} className="twp-checkbox-label">
            {label}
          </label>
        )}
        {description && (
          <span id={descriptionId} className="twp-checkbox-description">
            {description}
          </span>
        )}
      </div>
    </div>
  );
}

// ── Showcase ────────────────────────────────────────────────────────────────

export function CheckboxShowcase() {
  const [controlled, setControlled] = useState(false);
  const [multi, setMulti] = useState({ a: true, b: false, c: true });

  const allChecked = Object.values(multi).every(Boolean);
  const someChecked = Object.values(multi).some(Boolean) && !allChecked;

  function toggleAll(next: boolean) {
    setMulti({ a: next, b: next, c: next });
  }

  return (
    <div className="twp-showcase">

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">unchecked</div>
        <div className="twp-showcase-row">
          <Checkbox />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">checked</div>
        <div className="twp-showcase-row">
          <Checkbox checked={true} onChange={() => {}} />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">controlled (click to toggle)</div>
        <div className="twp-showcase-row">
          <Checkbox checked={controlled} onChange={setControlled} />
          <span style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-muted)' }}>
            {controlled ? 'checked' : 'unchecked'}
          </span>
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">indeterminate</div>
        <div className="twp-showcase-row">
          <Checkbox indeterminate checked={false} onChange={() => {}} />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with label</div>
        <div className="twp-showcase-row">
          <Checkbox label="Remember me" />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with label + description</div>
        <div className="twp-showcase-row" style={{ maxWidth: '24rem' }}>
          <Checkbox
            label="Marketing emails"
            description="Get notified about new products, features, and updates."
          />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">disabled (unchecked)</div>
        <div className="twp-showcase-row">
          <Checkbox disabled label="Disabled option" />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">disabled (checked)</div>
        <div className="twp-showcase-row">
          <Checkbox disabled checked={true} onChange={() => {}} label="Locked setting" />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">select-all pattern</div>
        <div className="twp-showcase-row" style={{ flexDirection: 'column', gap: 'var(--space-1)', alignItems: 'flex-start' }}>
          <Checkbox
            label="Select all"
            checked={allChecked}
            indeterminate={someChecked}
            onChange={toggleAll}
          />
          <div style={{ paddingLeft: 'var(--space-3)', display: 'flex', flexDirection: 'column', gap: 'var(--space-half)' }}>
            <Checkbox label="Option A" checked={multi.a} onChange={v => setMulti(p => ({ ...p, a: v }))} />
            <Checkbox label="Option B" checked={multi.b} onChange={v => setMulti(p => ({ ...p, b: v }))} />
            <Checkbox label="Option C" checked={multi.c} onChange={v => setMulti(p => ({ ...p, c: v }))} />
          </div>
        </div>
      </div>

    </div>
  );
}
