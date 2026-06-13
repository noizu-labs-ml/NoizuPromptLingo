'use client'

import React from 'react';
import { Button } from '../buttons/Button';

export interface ButtonGroupProps {
  children: React.ReactNode;
  className?: string;
}

export function ButtonGroup({ children, className = '' }: ButtonGroupProps) {
  const cls = ['twp-btn-group', className].filter(Boolean).join(' ');
  return (
    <div className={cls} role="group">
      {children}
    </div>
  );
}

// ─── Icons ────────────────────────────────────────────────────────────────────

function IconLeft() {
  return (
    <svg width="14" height="14" viewBox="0 0 14 14" fill="none" aria-hidden="true">
      <path d="M9 11L5 7l4-4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function IconRight() {
  return (
    <svg width="14" height="14" viewBox="0 0 14 14" fill="none" aria-hidden="true">
      <path d="M5 3l4 4-4 4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function IconList() {
  return (
    <svg width="14" height="14" viewBox="0 0 14 14" fill="none" aria-hidden="true">
      <path d="M2 4h10M2 7h10M2 10h10" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

function IconGrid() {
  return (
    <svg width="14" height="14" viewBox="0 0 14 14" fill="none" aria-hidden="true">
      <rect x="2" y="2" width="4" height="4" rx="0.5" stroke="currentColor" strokeWidth="1.5" />
      <rect x="8" y="2" width="4" height="4" rx="0.5" stroke="currentColor" strokeWidth="1.5" />
      <rect x="2" y="8" width="4" height="4" rx="0.5" stroke="currentColor" strokeWidth="1.5" />
      <rect x="8" y="8" width="4" height="4" rx="0.5" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

function IconSort() {
  return (
    <svg width="14" height="14" viewBox="0 0 14 14" fill="none" aria-hidden="true">
      <path d="M2 4h6M2 7h4M2 10h2" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
      <path d="M10 3v8M10 11l-2-2M10 11l2-2" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

// ─── Showcase ─────────────────────────────────────────────────────────────────

export function ButtonGroupShowcase() {
  return (
    <div className="twp-showcase">
      {/* Three joined secondary buttons */}
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">3 secondary buttons joined</div>
        <div className="twp-showcase-row">
          <ButtonGroup>
            <Button variant="secondary">Previous</Button>
            <Button variant="secondary">Today</Button>
            <Button variant="secondary">Next</Button>
          </ButtonGroup>
        </div>
      </div>

      {/* Three with icons (icon + label) */}
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with icons</div>
        <div className="twp-showcase-row">
          <ButtonGroup>
            <Button variant="secondary"><IconLeft />Back</Button>
            <Button variant="secondary"><IconSort />Sort</Button>
            <Button variant="secondary">Next<IconRight /></Button>
          </ButtonGroup>
        </div>
      </div>

      {/* Icon-only group */}
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">icon-only group</div>
        <div className="twp-showcase-row">
          <ButtonGroup>
            <Button variant="secondary" iconOnly aria-label="List view"><IconList /></Button>
            <Button variant="secondary" iconOnly aria-label="Grid view"><IconGrid /></Button>
            <Button variant="secondary" iconOnly aria-label="Sort"><IconSort /></Button>
          </ButtonGroup>
        </div>
      </div>

      {/* Small size */}
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">small size</div>
        <div className="twp-showcase-row">
          <ButtonGroup>
            <Button variant="secondary" size="sm">Draft</Button>
            <Button variant="secondary" size="sm">Review</Button>
            <Button variant="secondary" size="sm">Published</Button>
          </ButtonGroup>
        </div>
      </div>
    </div>
  );
}
