'use client'

import React, { InputHTMLAttributes, ReactNode } from 'react';

export interface InputProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'id'> {
  label?: string;
  helpText?: string;
  error?: string | boolean;
  leadingAddon?: string;
  trailingAddon?: string;
  leadingIcon?: ReactNode;
  trailingIcon?: ReactNode;
  id?: string;
  className?: string;
}

export function Input({
  label,
  helpText,
  error,
  leadingAddon,
  trailingAddon,
  leadingIcon,
  trailingIcon,
  id,
  name,
  type = 'text',
  placeholder,
  disabled,
  className = '',
  ...rest
}: InputProps) {
  const inputId = id ?? name;
  const errorId = inputId ? `${inputId}-error` : undefined;
  const helpId = inputId ? `${inputId}-help` : undefined;
  const hasError = Boolean(error);

  const inputCls = [
    'twp-input',
    hasError ? 'twp-input-error' : '',
    leadingIcon ? 'twp-input-has-icon-leading' : '',
    trailingIcon ? 'twp-input-has-icon-trailing' : '',
    className,
  ].filter(Boolean).join(' ');

  const describedBy = [
    hasError && errorId ? errorId : '',
    helpText && helpId ? helpId : '',
  ].filter(Boolean).join(' ') || undefined;

  const inputEl = (
    <input
      id={inputId}
      name={name}
      type={type}
      placeholder={placeholder}
      disabled={disabled}
      aria-invalid={hasError || undefined}
      aria-describedby={describedBy}
      className={inputCls}
      {...rest}
    />
  );

  // Wrap in icon overlay grid if icons present
  const wrappedInput =
    leadingIcon || trailingIcon ? (
      <div className="twp-input-icon-wrapper">
        {inputEl}
        {leadingIcon && (
          <span className="twp-input-icon twp-input-icon-leading" aria-hidden="true">
            {leadingIcon}
          </span>
        )}
        {trailingIcon && (
          <span className="twp-input-icon twp-input-icon-trailing" aria-hidden="true">
            {trailingIcon}
          </span>
        )}
      </div>
    ) : inputEl;

  // Wrap in addon group if addons present
  const fieldEl =
    leadingAddon || trailingAddon ? (
      <div className="twp-input-group">
        {leadingAddon && (
          <span className="twp-input-addon twp-input-addon-leading">{leadingAddon}</span>
        )}
        {wrappedInput}
        {trailingAddon && (
          <span className="twp-input-addon twp-input-addon-trailing">{trailingAddon}</span>
        )}
      </div>
    ) : wrappedInput;

  return (
    <div>
      {label && (
        <label htmlFor={inputId} className="twp-input-label">
          {label}
        </label>
      )}
      {fieldEl}
      {hasError && typeof error === 'string' && (
        <p id={errorId} className="twp-input-error-msg" role="alert">
          {error}
        </p>
      )}
      {helpText && !hasError && (
        <p id={helpId} className="twp-input-help">
          {helpText}
        </p>
      )}
    </div>
  );
}

// ─── Showcase ───────────────────────────────────────────────────────────────

function MailIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="currentColor" width="16" height="16">
      <path d="M2.5 3A1.5 1.5 0 0 0 1 4.5v.793c.026.009.051.02.076.032L7.674 8.51c.206.1.446.1.652 0l6.598-3.185A.755.755 0 0 1 15 5.293V4.5A1.5 1.5 0 0 0 13.5 3h-11Z" />
      <path d="M15 6.954 8.978 9.86a2.25 2.25 0 0 1-1.956 0L1 6.954V11.5A1.5 1.5 0 0 0 2.5 13h11a1.5 1.5 0 0 0 1.5-1.5V6.954Z" />
    </svg>
  );
}

export function InputShowcase() {
  return (
    <div className="twp-showcase">
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">basic</div>
        <Input
          id="showcase-email"
          label="Email address"
          type="email"
          placeholder="you@example.com"
        />
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with help text</div>
        <Input
          id="showcase-username"
          label="Username"
          placeholder="your_handle"
          helpText="Only letters, numbers, and underscores."
        />
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with error</div>
        <Input
          id="showcase-email-error"
          label="Email address"
          type="email"
          defaultValue="not-an-email"
          error="Not a valid email address."
        />
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with leading addon</div>
        <Input
          id="showcase-website"
          label="Company website"
          placeholder="www.example.com"
          leadingAddon="https://"
        />
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with trailing addon</div>
        <Input
          id="showcase-domain"
          label="Subdomain"
          placeholder="acme"
          trailingAddon=".noizu.com"
        />
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with leading icon</div>
        <Input
          id="showcase-icon"
          label="Email"
          type="email"
          placeholder="you@example.com"
          leadingIcon={<MailIcon />}
        />
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">disabled</div>
        <Input
          id="showcase-disabled"
          label="Read-only field"
          defaultValue="cannot edit this"
          disabled
        />
      </div>
    </div>
  );
}
