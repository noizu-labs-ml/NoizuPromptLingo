'use client'

import React, { ReactNode } from 'react'

// ─── Types ───────────────────────────────────────────────────────────────────

interface DescriptionItem {
  term: string
  detail: ReactNode
}

interface DescriptionListProps {
  items: DescriptionItem[]
  striped?: boolean
  bordered?: boolean
  className?: string
}

// ─── DescriptionList ─────────────────────────────────────────────────────────

export function DescriptionList({
  items,
  striped = false,
  bordered = false,
  className = '',
}: DescriptionListProps) {
  const classes = [
    'twp-dl',
    striped ? 'twp-dl-striped' : '',
    bordered ? 'twp-dl-bordered' : '',
    className,
  ]
    .filter(Boolean)
    .join(' ')

  return (
    <dl className={classes}>
      {items.map((item, i) => (
        <div key={i} className="twp-dl-item">
          <dt className="twp-dl-term">{item.term}</dt>
          <dd className="twp-dl-detail">{item.detail}</dd>
        </div>
      ))}
    </dl>
  )
}

// ─── Showcase ────────────────────────────────────────────────────────────────

const sampleItems: DescriptionItem[] = [
  { term: 'Full name', detail: 'Margaret Atwood' },
  { term: 'Email', detail: 'margaret@example.com' },
  { term: 'Role', detail: 'Senior Engineer' },
  { term: 'Department', detail: 'Platform Infrastructure' },
  { term: 'Location', detail: 'Toronto, ON' },
  { term: 'Status', detail: 'Active' },
]

export function DescriptionListShowcase() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
      <div>
        <p style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-muted)', marginBottom: 'var(--space-2)' }}>
          Default
        </p>
        <DescriptionList items={sampleItems} />
      </div>

      <div>
        <p style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-muted)', marginBottom: 'var(--space-2)' }}>
          Striped
        </p>
        <DescriptionList items={sampleItems} striped />
      </div>

      <div>
        <p style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-muted)', marginBottom: 'var(--space-2)' }}>
          Bordered
        </p>
        <DescriptionList items={sampleItems} bordered />
      </div>

      <div>
        <p style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-muted)', marginBottom: 'var(--space-2)' }}>
          Striped + Bordered
        </p>
        <DescriptionList items={sampleItems} striped bordered />
      </div>
    </div>
  )
}
