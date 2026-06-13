'use client'

import React from 'react';

export type ButtonVariant = 'primary' | 'secondary' | 'soft' | 'danger' | 'ghost';
export type ButtonSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl';

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  pill?: boolean;
  iconOnly?: boolean;
  children?: React.ReactNode;
  className?: string;
}

export function Button({
  variant = 'primary',
  size = 'md',
  pill = false,
  iconOnly = false,
  disabled = false,
  className = '',
  children,
  ...rest
}: ButtonProps) {
  const cls = [
    'twp-btn',
    `twp-btn-${variant}`,
    size !== 'md' ? `twp-btn-${size}` : '',
    pill ? 'twp-btn-pill' : '',
    iconOnly ? 'twp-btn-icon' : '',
    className,
  ].filter(Boolean).join(' ');

  return (
    <button
      className={cls}
      disabled={disabled}
      aria-disabled={disabled}
      {...rest}
    >
      {children}
    </button>
  );
}

export function ButtonShowcase() {
  const variants: ButtonVariant[] = ['primary', 'secondary', 'soft', 'danger', 'ghost'];
  const sizes: ButtonSize[] = ['xs', 'sm', 'md', 'lg', 'xl'];

  return (
    <div className="twp-showcase">
      {/* All variants at default size */}
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">variants (md)</div>
        <div className="twp-showcase-row">
          {variants.map((v) => (
            <Button key={v} variant={v}>{v}</Button>
          ))}
        </div>
      </div>

      {/* All sizes for primary */}
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">sizes — primary</div>
        <div className="twp-showcase-row">
          {sizes.map((s) => (
            <Button key={s} variant="primary" size={s}>{s}</Button>
          ))}
        </div>
      </div>

      {/* All sizes for secondary */}
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">sizes — secondary</div>
        <div className="twp-showcase-row">
          {sizes.map((s) => (
            <Button key={s} variant="secondary" size={s}>{s}</Button>
          ))}
        </div>
      </div>

      {/* Pill shape */}
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">pill</div>
        <div className="twp-showcase-row">
          {variants.map((v) => (
            <Button key={v} variant={v} pill>{v}</Button>
          ))}
        </div>
      </div>

      {/* Icon-only */}
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">icon-only</div>
        <div className="twp-showcase-row">
          {variants.map((v) => (
            <Button key={v} variant={v} iconOnly aria-label={v}>
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none" aria-hidden="true">
                <circle cx="8" cy="8" r="6" stroke="currentColor" strokeWidth="1.5" />
                <path d="M8 5v3l2 2" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
              </svg>
            </Button>
          ))}
        </div>
      </div>

      {/* Disabled state */}
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">disabled</div>
        <div className="twp-showcase-row">
          {variants.map((v) => (
            <Button key={v} variant={v} disabled>{v}</Button>
          ))}
        </div>
      </div>

      {/* Icon + label (leading) */}
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with leading icon</div>
        <div className="twp-showcase-row">
          {variants.map((v) => (
            <Button key={v} variant={v}>
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none" aria-hidden="true">
                <path d="M8 3v10M3 8h10" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
              </svg>
              {v}
            </Button>
          ))}
        </div>
      </div>
    </div>
  );
}
