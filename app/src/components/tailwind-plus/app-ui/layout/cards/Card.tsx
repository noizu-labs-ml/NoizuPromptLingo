'use client'

import React from 'react'

// ─── Types ───────────────────────────────────────────────────────────────────

type CardVariant = 'bordered' | 'elevated' | 'flush'

interface CardProps {
  variant?: CardVariant
  className?: string
  children?: React.ReactNode
}

interface CardSectionProps {
  className?: string
  children?: React.ReactNode
}

// ─── Variant → class map ─────────────────────────────────────────────────────

const variantClass: Record<CardVariant, string> = {
  bordered: 'twp-card',
  elevated: 'twp-card-elevated',
  flush: 'twp-card-flush',
}

// ─── Sub-components ──────────────────────────────────────────────────────────

export function CardHeader({ className = '', children }: CardSectionProps) {
  return (
    <div className={['twp-card-header', className].filter(Boolean).join(' ')}>
      {children}
    </div>
  )
}

export function CardBody({ className = '', children }: CardSectionProps) {
  return (
    <div className={['twp-card-body', className].filter(Boolean).join(' ')}>
      {children}
    </div>
  )
}

export function CardFooter({ className = '', children }: CardSectionProps) {
  return (
    <div className={['twp-card-footer', className].filter(Boolean).join(' ')}>
      {children}
    </div>
  )
}

export function CardTitle({ className = '', children }: CardSectionProps) {
  return (
    <p className={['twp-card-title', className].filter(Boolean).join(' ')}>
      {children}
    </p>
  )
}

export function CardDescription({ className = '', children }: CardSectionProps) {
  return (
    <p className={['twp-card-description', className].filter(Boolean).join(' ')}>
      {children}
    </p>
  )
}

// ─── Root component ───────────────────────────────────────────────────────────

export function Card({ variant = 'bordered', className = '', children }: CardProps) {
  const base = variantClass[variant]
  return (
    <div className={[base, className].filter(Boolean).join(' ')}>
      {children}
    </div>
  )
}

// ─── Compound component attachment ───────────────────────────────────────────

Card.Header = CardHeader
Card.Body = CardBody
Card.Footer = CardFooter
Card.Title = CardTitle
Card.Description = CardDescription

// ─── Showcase ────────────────────────────────────────────────────────────────

export function CardShowcase() {
  return (
    <div className="twp-showcase">

      <div className="twp-showcase-group">
        <p className="twp-showcase-label">bordered (default)</p>
        <Card variant="bordered" className="max-w-sm">
          <CardHeader>
            <CardTitle>Card Title</CardTitle>
            <span className="twp-badge">Action</span>
          </CardHeader>
          <CardBody>
            <CardDescription>
              This is a bordered card. It uses a 1px border and rounded corners from the design system.
            </CardDescription>
          </CardBody>
          <CardFooter>
            <CardDescription>Footer content</CardDescription>
          </CardFooter>
        </Card>
      </div>

      <div className="twp-showcase-group">
        <p className="twp-showcase-label">elevated</p>
        <Card variant="elevated" className="max-w-sm">
          <CardHeader>
            <CardTitle>Elevated Card</CardTitle>
          </CardHeader>
          <CardBody>
            <CardDescription>
              Elevated variant uses a box-shadow instead of a border — suitable for cards on colored backgrounds.
            </CardDescription>
          </CardBody>
        </Card>
      </div>

      <div className="twp-showcase-group">
        <p className="twp-showcase-label">flush (no border, no radius)</p>
        <Card variant="flush" className="max-w-sm">
          <CardBody>
            <CardTitle>Flush Card</CardTitle>
            <CardDescription>
              Full-bleed card with no border or radius. Use inside containers that provide their own frame.
            </CardDescription>
          </CardBody>
        </Card>
      </div>

      <div className="twp-showcase-group">
        <p className="twp-showcase-label">compound usage — header + body only</p>
        <Card className="max-w-sm">
          <CardHeader>
            <div>
              <CardTitle>Notifications</CardTitle>
              <CardDescription>You have 3 unread messages.</CardDescription>
            </div>
          </CardHeader>
          <CardBody>
            <CardDescription>Card body content goes here.</CardDescription>
          </CardBody>
        </Card>
      </div>

    </div>
  )
}
