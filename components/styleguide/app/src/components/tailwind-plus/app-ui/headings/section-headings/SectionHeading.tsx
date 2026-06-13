'use client'

import React from 'react';

export interface SectionHeadingProps {
  title: string;
  subtitle?: string;
  actions?: React.ReactNode;
  className?: string;
}

export function SectionHeading({ title, subtitle, actions, className = '' }: SectionHeadingProps) {
  return (
    <div className={['twp-heading twp-section-heading', className].filter(Boolean).join(' ')}>
      <div>
        <h2 className="twp-heading-title">{title}</h2>
        {subtitle && <p className="twp-heading-subtitle">{subtitle}</p>}
      </div>
      {actions && <div className="twp-heading-actions">{actions}</div>}
    </div>
  );
}

export function SectionHeadingShowcase() {
  return (
    <div className="twp-showcase">
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">simple</div>
        <SectionHeading title="Section Title" />
      </div>
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with subtitle</div>
        <SectionHeading title="Section Title" subtitle="A brief description of this section." />
      </div>
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with actions</div>
        <SectionHeading
          title="Section Title"
          subtitle="A brief description of this section."
          actions={<button className="twp-btn twp-btn-primary">Add Item</button>}
        />
      </div>
    </div>
  );
}
