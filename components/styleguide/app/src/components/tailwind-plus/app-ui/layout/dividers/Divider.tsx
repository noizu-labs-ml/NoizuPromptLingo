'use client'

import React from 'react'

// ─── Types ───────────────────────────────────────────────────────────────────

interface DividerProps {
  label?: string
  className?: string
}

// ─── Component ───────────────────────────────────────────────────────────────

export function Divider({ label, className = '' }: DividerProps) {
  if (label) {
    return (
      <div className={['twp-divider-with-label', className].filter(Boolean).join(' ')}>
        <span className="twp-divider-label">{label}</span>
      </div>
    )
  }

  return (
    <hr className={['twp-divider', className].filter(Boolean).join(' ')} />
  )
}

// ─── Showcase ────────────────────────────────────────────────────────────────

export function DividerShowcase() {
  return (
    <div className="twp-showcase">

      <div className="twp-showcase-group">
        <p className="twp-showcase-label">plain</p>
        <div>
          <p className="twp-card-description">Content above the divider.</p>
          <Divider />
          <p className="twp-card-description">Content below the divider.</p>
        </div>
      </div>

      <div className="twp-showcase-group">
        <p className="twp-showcase-label">with label (centered)</p>
        <div>
          <p className="twp-card-description">Section one</p>
          <Divider label="or" />
          <p className="twp-card-description">Section two</p>
        </div>
      </div>

      <div className="twp-showcase-group">
        <p className="twp-showcase-label">with longer label</p>
        <div>
          <p className="twp-card-description">Completed items</p>
          <Divider label="Continue with" />
          <p className="twp-card-description">Remaining items</p>
        </div>
      </div>

    </div>
  )
}
