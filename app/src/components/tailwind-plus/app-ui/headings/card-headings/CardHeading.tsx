'use client'

import React from 'react';

export interface CardHeadingProps {
  title: string;
  subtitle?: string;
  actions?: React.ReactNode;
  className?: string;
}

export function CardHeading({ title, subtitle, actions, className = '' }: CardHeadingProps) {
  return (
    <div className={['twp-heading twp-card-heading', className].filter(Boolean).join(' ')}>
      <div>
        <h3 className="twp-heading-title">{title}</h3>
        {subtitle && <p className="twp-heading-subtitle">{subtitle}</p>}
      </div>
      {actions && <div className="twp-heading-actions">{actions}</div>}
    </div>
  );
}

export function CardHeadingShowcase() {
  return (
    <div className="twp-showcase">
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">simple</div>
        <div style={{ border: '1px solid var(--border)', borderRadius: 'var(--radius)', padding: 'var(--space-3)' }}>
          <CardHeading title="Card Title" />
        </div>
      </div>
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with subtitle</div>
        <div style={{ border: '1px solid var(--border)', borderRadius: 'var(--radius)', padding: 'var(--space-3)' }}>
          <CardHeading title="Card Title" subtitle="Supporting detail text." />
        </div>
      </div>
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with actions</div>
        <div style={{ border: '1px solid var(--border)', borderRadius: 'var(--radius)', padding: 'var(--space-3)' }}>
          <CardHeading
            title="Card Title"
            subtitle="Supporting detail text."
            actions={<button className="twp-btn twp-btn-secondary">Edit</button>}
          />
        </div>
      </div>
    </div>
  );
}
