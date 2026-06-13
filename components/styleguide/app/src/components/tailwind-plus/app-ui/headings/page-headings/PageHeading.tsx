'use client'

import React from 'react';

export interface PageHeadingProps {
  title: string;
  subtitle?: string;
  meta?: React.ReactNode;
  actions?: React.ReactNode;
  className?: string;
}

export function PageHeading({ title, subtitle, meta, actions, className = '' }: PageHeadingProps) {
  return (
    <div className={['twp-heading twp-page-heading', className].filter(Boolean).join(' ')}>
      <div>
        {meta && <div className="twp-heading-meta">{meta}</div>}
        <h1 className="twp-heading-title">{title}</h1>
        {subtitle && <p className="twp-heading-subtitle">{subtitle}</p>}
      </div>
      {actions && <div className="twp-heading-actions">{actions}</div>}
    </div>
  );
}

export function PageHeadingShowcase() {
  return (
    <div className="twp-showcase">
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">simple</div>
        <PageHeading title="Page Title" />
      </div>
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with subtitle</div>
        <PageHeading title="Page Title" subtitle="A description of what this page is about." />
      </div>
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with meta + actions</div>
        <PageHeading
          title="Page Title"
          subtitle="A description of what this page is about."
          meta={<span>Dashboard / Settings</span>}
          actions={
            <>
              <button className="twp-btn twp-btn-secondary">Cancel</button>
              <button className="twp-btn twp-btn-primary">Save</button>
            </>
          }
        />
      </div>
    </div>
  );
}
