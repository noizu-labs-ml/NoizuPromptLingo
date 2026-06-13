'use client'

import { useState } from 'react'
import {
  ExclamationTriangleIcon,
  XCircleIcon,
  CheckCircleIcon,
  InformationCircleIcon,
  XMarkIcon,
} from '@heroicons/react/24/outline'

export type AlertVariant = 'warning' | 'danger' | 'success' | 'info'

export interface AlertProps {
  variant?: AlertVariant
  title?: string
  children?: React.ReactNode
  accent?: boolean
  dismissible?: boolean
  onDismiss?: () => void
  icon?: React.ReactNode
  className?: string
}

const DEFAULT_ICONS: Record<AlertVariant, React.ReactNode> = {
  warning: <ExclamationTriangleIcon className="twp-alert-icon" aria-hidden="true" />,
  danger:  <XCircleIcon             className="twp-alert-icon" aria-hidden="true" />,
  success: <CheckCircleIcon         className="twp-alert-icon" aria-hidden="true" />,
  info:    <InformationCircleIcon   className="twp-alert-icon" aria-hidden="true" />,
}

export function Alert({
  variant = 'info',
  title,
  children,
  accent = false,
  dismissible = false,
  onDismiss,
  icon,
  className = '',
}: AlertProps) {
  const [dismissed, setDismissed] = useState(false)

  if (dismissed) return null

  const handleDismiss = () => {
    setDismissed(true)
    onDismiss?.()
  }

  const cls = [
    'twp-alert',
    `twp-alert-${variant}`,
    accent ? 'twp-alert-accent' : '',
    className,
  ].filter(Boolean).join(' ')

  const resolvedIcon = icon !== undefined ? icon : DEFAULT_ICONS[variant]

  return (
    <div className={cls} role="alert">
      {resolvedIcon}

      <div className="twp-alert-content">
        {title && <p className="twp-alert-title">{title}</p>}
        {children && <div className="twp-alert-body">{children}</div>}
      </div>

      {dismissible && (
        <button
          type="button"
          className="twp-alert-dismiss"
          onClick={handleDismiss}
          aria-label="Dismiss"
        >
          <XMarkIcon aria-hidden="true" />
        </button>
      )}
    </div>
  )
}

/* ─── Showcase ─── */

const VARIANTS: AlertVariant[] = ['warning', 'danger', 'success', 'info']

export function AlertShowcase() {
  return (
    <div className="twp-showcase">

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">all variants — title only</div>
        <div className="twp-showcase-col">
          {VARIANTS.map((v) => (
            <Alert key={v} variant={v} title={`${v.charAt(0).toUpperCase() + v.slice(1)}: something needs your attention`} />
          ))}
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">title + description</div>
        <div className="twp-showcase-col">
          {VARIANTS.map((v) => (
            <Alert key={v} variant={v} title={`${v.charAt(0).toUpperCase() + v.slice(1)}`}>
              <p>This is a supporting description that provides more context about the alert.</p>
            </Alert>
          ))}
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">description only (no title)</div>
        <div className="twp-showcase-col">
          {VARIANTS.map((v) => (
            <Alert key={v} variant={v}>
              <p>You have no credits left. Purchase a plan to continue.</p>
            </Alert>
          ))}
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with accent border</div>
        <div className="twp-showcase-col">
          {VARIANTS.map((v) => (
            <Alert key={v} variant={v} accent title={`${v.charAt(0).toUpperCase() + v.slice(1)}`}>
              <p>Left accent border using currentColor — no extra color declarations needed.</p>
            </Alert>
          ))}
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">dismissible</div>
        <div className="twp-showcase-col">
          {VARIANTS.map((v) => (
            <Alert key={v} variant={v} dismissible title={`${v.charAt(0).toUpperCase() + v.slice(1)}: dismiss me`}>
              <p>Click the × button to dismiss this alert.</p>
            </Alert>
          ))}
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">accent + dismissible</div>
        <div className="twp-showcase-col">
          {VARIANTS.map((v) => (
            <Alert key={v} variant={v} accent dismissible title={`${v.charAt(0).toUpperCase() + v.slice(1)}`}>
              <p>Accent border combined with dismiss button.</p>
            </Alert>
          ))}
        </div>
      </div>

    </div>
  )
}
