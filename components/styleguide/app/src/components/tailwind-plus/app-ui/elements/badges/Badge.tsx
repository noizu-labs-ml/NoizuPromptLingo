'use client'

export type BadgeVariant = 'muted' | 'danger' | 'warning' | 'success' | 'info' | 'accent' | 'purple' | 'pink';
export type BadgeShape = 'flat' | 'border' | 'pill' | 'pill-border';
export type BadgeSize = 'sm' | 'md';

export interface BadgeProps {
  children: React.ReactNode;
  variant?: BadgeVariant;
  shape?: BadgeShape;
  size?: BadgeSize;
  dot?: boolean;
  removable?: boolean;
  onRemove?: () => void;
  className?: string;
}

export function Badge({
  children,
  variant = 'muted',
  shape = 'flat',
  size = 'md',
  dot = false,
  removable = false,
  onRemove,
  className = '',
}: BadgeProps) {
  const cls = [
    'twp-badge',
    `twp-badge-${variant}`,
    shape !== 'flat' ? `twp-badge-${shape}` : '',
    size === 'sm' ? 'twp-badge-sm' : '',
    className,
  ].filter(Boolean).join(' ');

  return (
    <span className={cls}>
      {dot && (
        <svg className="twp-badge-dot" viewBox="0 0 6 6" aria-hidden="true">
          <circle cx="3" cy="3" r="3" />
        </svg>
      )}
      {children}
      {removable && (
        <button type="button" className="twp-badge-remove" onClick={onRemove}>
          <span className="sr-only">Remove</span>
          <svg viewBox="0 0 14 14" aria-hidden="true">
            <path d="M4 4l6 6m0-6l-6 6" />
          </svg>
        </button>
      )}
    </span>
  );
}

export function BadgeShowcase() {
  const variants: BadgeVariant[] = ['muted', 'danger', 'warning', 'success', 'info', 'accent', 'purple', 'pink'];
  const shapes: { shape: BadgeShape; label: string }[] = [
    { shape: 'flat', label: 'flat' },
    { shape: 'border', label: 'border' },
    { shape: 'pill', label: 'pill' },
    { shape: 'pill-border', label: 'pill + border' },
  ];

  return (
    <div className="twp-showcase">
      {shapes.map(({ shape, label }) => (
        <div key={shape} className="twp-showcase-group">
          <div className="twp-showcase-label">{label}</div>
          <div className="twp-showcase-row">
            {variants.map((v) => (
              <Badge key={v} variant={v} shape={shape}>{v}</Badge>
            ))}
          </div>
        </div>
      ))}
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with dot</div>
        <div className="twp-showcase-row">
          {variants.map((v) => (
            <Badge key={v} variant={v} dot>{v}</Badge>
          ))}
        </div>
      </div>
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">removable</div>
        <div className="twp-showcase-row">
          {variants.map((v) => (
            <Badge key={v} variant={v} removable>{v}</Badge>
          ))}
        </div>
      </div>
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">small + border</div>
        <div className="twp-showcase-row">
          {variants.map((v) => (
            <Badge key={v} variant={v} size="sm" shape="border">{v}</Badge>
          ))}
        </div>
      </div>
    </div>
  );
}
