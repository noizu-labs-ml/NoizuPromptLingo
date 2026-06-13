'use client'

import React, { TextareaHTMLAttributes } from 'react';

export interface TextareaProps extends Omit<TextareaHTMLAttributes<HTMLTextAreaElement>, 'id'> {
  label?: string;
  rows?: number;
  error?: string | boolean;
  helpText?: string;
  id?: string;
  className?: string;
}

export function Textarea({
  label,
  rows = 4,
  error,
  helpText,
  placeholder,
  disabled,
  id,
  name,
  className = '',
  ...rest
}: TextareaProps) {
  const textareaId = id ?? name;
  const errorId = textareaId ? `${textareaId}-error` : undefined;
  const helpId = textareaId ? `${textareaId}-help` : undefined;
  const hasError = Boolean(error);

  const textareaCls = [
    'twp-input',
    'twp-textarea',
    hasError ? 'twp-input-error' : '',
    className,
  ].filter(Boolean).join(' ');

  const describedBy = [
    hasError && errorId ? errorId : '',
    helpText && helpId ? helpId : '',
  ].filter(Boolean).join(' ') || undefined;

  return (
    <div>
      {label && (
        <label htmlFor={textareaId} className="twp-input-label">
          {label}
        </label>
      )}
      <textarea
        id={textareaId}
        name={name}
        rows={rows}
        placeholder={placeholder}
        disabled={disabled}
        aria-invalid={hasError || undefined}
        aria-describedby={describedBy}
        className={textareaCls}
        {...rest}
      />
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

export function TextareaShowcase() {
  return (
    <div className="twp-showcase">
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">basic</div>
        <Textarea
          id="showcase-textarea-basic"
          label="Description"
          placeholder="Enter a description…"
        />
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with help text</div>
        <Textarea
          id="showcase-textarea-help"
          label="Bio"
          placeholder="Tell us about yourself"
          helpText="Maximum 300 characters."
        />
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with error</div>
        <Textarea
          id="showcase-textarea-error"
          label="Message"
          defaultValue="x"
          error="Message must be at least 10 characters."
        />
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">disabled</div>
        <Textarea
          id="showcase-textarea-disabled"
          label="Notes"
          defaultValue="This field cannot be edited."
          disabled
        />
      </div>
    </div>
  );
}
