'use client'

import { useState, useId } from 'react';

export interface RadioOption {
  value: string;
  label: string;
  description?: string;
}

export interface RadioGroupProps {
  legend?: string;
  description?: string;
  options: RadioOption[];
  value?: string;
  onChange?: (value: string) => void;
  name?: string;
  disabled?: boolean;
  className?: string;
}

export function RadioGroup({
  legend,
  description,
  options,
  value,
  onChange,
  name,
  disabled = false,
  className = '',
}: RadioGroupProps) {
  const [internalValue, setInternalValue] = useState<string>('');
  const isControlled = value !== undefined;
  const selectedValue = isControlled ? value : internalValue;

  const uid = useId();
  const groupName = name ?? `${uid}-radio`;
  const descriptionId = description ? `${uid}-group-desc` : undefined;

  function handleChange(optionValue: string) {
    if (disabled) return;
    if (!isControlled) setInternalValue(optionValue);
    onChange?.(optionValue);
  }

  return (
    <fieldset
      className={['twp-radio-group', className].filter(Boolean).join(' ')}
      aria-describedby={descriptionId}
      disabled={disabled}
    >
      {legend && (
        <legend className="twp-radio-group-legend">{legend}</legend>
      )}
      {description && (
        <p id={descriptionId} className="twp-radio-group-description">
          {description}
        </p>
      )}
      {options.map((option) => {
        const optId = `${uid}-${option.value}`;
        const optDescId = option.description ? `${optId}-desc` : undefined;
        const isChecked = selectedValue === option.value;

        return (
          <div key={option.value} className="twp-radio-field">
            <input
              id={optId}
              type="radio"
              name={groupName}
              value={option.value}
              checked={isChecked}
              disabled={disabled}
              aria-describedby={optDescId}
              onChange={() => handleChange(option.value)}
              className="twp-radio"
            />
            <div className="twp-radio-label-group">
              <label htmlFor={optId} className="twp-radio-label">
                {option.label}
              </label>
              {option.description && (
                <span id={optDescId} className="twp-radio-description">
                  {option.description}
                </span>
              )}
            </div>
          </div>
        );
      })}
    </fieldset>
  );
}

// ── Showcase ────────────────────────────────────────────────────────────────

const PLAN_OPTIONS: RadioOption[] = [
  { value: 'starter', label: 'Starter', description: 'Perfect for side projects and solo founders.' },
  { value: 'pro', label: 'Pro', description: 'For growing teams that need more power.' },
  { value: 'enterprise', label: 'Enterprise', description: 'Advanced controls and SLA guarantees.' },
];

const SIMPLE_OPTIONS: RadioOption[] = [
  { value: 'email', label: 'Email' },
  { value: 'sms', label: 'SMS' },
  { value: 'push', label: 'Push notification' },
];

export function RadioGroupShowcase() {
  const [plan, setPlan] = useState('pro');
  const [notify, setNotify] = useState('email');

  return (
    <div className="twp-showcase">

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">simple (no descriptions)</div>
        <div className="twp-showcase-row" style={{ alignItems: 'flex-start' }}>
          <RadioGroup
            legend="Notification method"
            options={SIMPLE_OPTIONS}
            value={notify}
            onChange={setNotify}
          />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with descriptions</div>
        <div className="twp-showcase-row" style={{ alignItems: 'flex-start' }}>
          <RadioGroup
            legend="Pricing plan"
            description="Choose the plan that best fits your needs."
            options={PLAN_OPTIONS}
            value={plan}
            onChange={setPlan}
          />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">disabled</div>
        <div className="twp-showcase-row" style={{ alignItems: 'flex-start' }}>
          <RadioGroup
            legend="Region"
            options={[
              { value: 'us', label: 'United States' },
              { value: 'eu', label: 'Europe' },
              { value: 'ap', label: 'Asia Pacific' },
            ]}
            value="us"
            onChange={() => {}}
            disabled
          />
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">uncontrolled (internal state)</div>
        <div className="twp-showcase-row" style={{ alignItems: 'flex-start' }}>
          <RadioGroup
            legend="Preferred contact"
            options={SIMPLE_OPTIONS}
          />
        </div>
      </div>

    </div>
  );
}
