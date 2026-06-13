'use client'

export type ProgressBarVariant = 'default' | 'success' | 'warning' | 'danger';
export type ProgressBarSize = 'sm' | 'md' | 'lg';

export interface ProgressBarProps {
  value: number;
  variant?: ProgressBarVariant;
  size?: ProgressBarSize;
  label?: string;
  className?: string;
}

export function ProgressBar({
  value,
  variant = 'default',
  size = 'md',
  label,
  className = '',
}: ProgressBarProps) {
  const clamped = Math.min(100, Math.max(0, value));

  const trackCls = [
    'twp-progress',
    size === 'sm' ? 'twp-progress-sm' : '',
    size === 'lg' ? 'twp-progress-lg' : '',
    variant !== 'default' ? `twp-progress-${variant}` : '',
    className,
  ].filter(Boolean).join(' ');

  return (
    <div style={{ width: '100%' }}>
      {label && <div className="twp-progress-label">{label}</div>}
      <div className={trackCls} role="progressbar" aria-valuenow={clamped} aria-valuemin={0} aria-valuemax={100}>
        <div className="twp-progress-bar" style={{ width: `${clamped}%` }} />
      </div>
    </div>
  );
}

export function ProgressBarShowcase() {
  const variants: { variant: ProgressBarVariant; label: string; value: number }[] = [
    { variant: 'default', label: 'default — 65%', value: 65 },
    { variant: 'success', label: 'success — 80%', value: 80 },
    { variant: 'warning', label: 'warning — 45%', value: 45 },
    { variant: 'danger',  label: 'danger — 25%',  value: 25 },
  ];

  return (
    <div className="twp-showcase">
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">variants</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-2)', width: '100%', maxWidth: '24rem' }}>
          {variants.map(({ variant, label, value }) => (
            <ProgressBar key={variant} variant={variant} value={value} label={label} />
          ))}
        </div>
      </div>
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">sizes</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-2)', width: '100%', maxWidth: '24rem' }}>
          <ProgressBar size="sm" value={60} label="sm — 60%" />
          <ProgressBar size="md" value={60} label="md — 60%" />
          <ProgressBar size="lg" value={60} label="lg — 60%" />
        </div>
      </div>
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">edge values</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-2)', width: '100%', maxWidth: '24rem' }}>
          <ProgressBar value={0}   label="0%" />
          <ProgressBar value={50}  label="50%" />
          <ProgressBar value={100} label="100%" variant="success" />
        </div>
      </div>
    </div>
  );
}
