import React from 'react';

interface CardTag {
  label?: React.ReactNode;
  bg?: string;
  color?: string;
}

interface StyleGuideCardProps {
  variant?: string;
  title?: React.ReactNode;
  body?: React.ReactNode;
  tags?: (CardTag | string)[];
  id?: React.ReactNode;
  children?: React.ReactNode;
}

export function StyleGuideCard({ variant, title, body, tags, id, children }: StyleGuideCardProps) {
  const cls = ['card', variant && `card-${variant}`].filter(Boolean).join(' ');
  return (
    <div className={cls}>
      {id && <div style={{ fontFamily: 'var(--font-mono)', fontSize: "var(--font-size-xs)", fontWeight: 600, color: 'var(--text-muted)', marginBottom: 4 }}>{id}</div>}
      {title && <div className="card-title">{title}</div>}
      {body && <div className="card-body">{body}</div>}
      {children}
      {tags && (
        <div style={{ display: 'flex', gap: "var(--space-half)", marginTop: 'var(--space-2)' }}>
          {tags.map((t, i) => (
            <span key={i} className="card-tag" style={typeof t === 'object' && t.bg ? { background: t.bg, color: t.color } : undefined}>
              {typeof t === 'object' ? t.label : t}
            </span>
          ))}
        </div>
      )}
    </div>
  );
}
