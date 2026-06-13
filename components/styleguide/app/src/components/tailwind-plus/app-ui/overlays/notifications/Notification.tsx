'use client'

import { useState } from 'react'
import {
  CheckCircleIcon,
  XCircleIcon,
  ExclamationTriangleIcon,
  InformationCircleIcon,
  XMarkIcon,
} from '@heroicons/react/24/outline'

export type NotificationVariant = 'success' | 'danger' | 'warning' | 'info'

export interface NotificationAction {
  label: string
  onClick: () => void
}

export interface NotificationProps {
  variant?: NotificationVariant
  title?: string
  children?: React.ReactNode
  icon?: React.ReactNode
  actions?: NotificationAction[]
  dismissible?: boolean
  onDismiss?: () => void
  className?: string
}

const DEFAULT_ICONS: Record<NotificationVariant, React.ReactNode> = {
  success: <CheckCircleIcon         aria-hidden="true" />,
  danger:  <XCircleIcon             aria-hidden="true" />,
  warning: <ExclamationTriangleIcon aria-hidden="true" />,
  info:    <InformationCircleIcon   aria-hidden="true" />,
}

export function Notification({
  variant = 'info',
  title,
  children,
  icon,
  actions = [],
  dismissible = false,
  onDismiss,
  className = '',
}: NotificationProps) {
  const [dismissed, setDismissed] = useState(false)

  if (dismissed) return null

  const handleDismiss = () => {
    setDismissed(true)
    onDismiss?.()
  }

  const cls = [
    'twp-notification',
    `twp-notification-${variant}`,
    className,
  ].filter(Boolean).join(' ')

  const resolvedIcon = icon !== undefined ? icon : DEFAULT_ICONS[variant]

  return (
    <div className={cls} role="status" aria-live="polite">
      {resolvedIcon && (
        <div className="twp-notification-icon">
          {resolvedIcon}
        </div>
      )}

      <div className="twp-notification-content">
        {title && <p className="twp-notification-title">{title}</p>}
        {children && <div className="twp-notification-body">{children}</div>}

        {actions.length > 0 && (
          <div className="twp-notification-actions">
            {actions.map((action, i) => (
              <button
                key={i}
                type="button"
                className="twp-notification-action"
                onClick={action.onClick}
              >
                {action.label}
              </button>
            ))}
          </div>
        )}
      </div>

      {dismissible && (
        <button
          type="button"
          className="twp-notification-dismiss"
          onClick={handleDismiss}
          aria-label="Dismiss notification"
        >
          <XMarkIcon aria-hidden="true" />
        </button>
      )}
    </div>
  )
}

/* ─── Showcase ─── */

const VARIANTS: NotificationVariant[] = ['success', 'danger', 'warning', 'info']

export function NotificationShowcase() {
  return (
    <div className="twp-showcase">

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">all variants — title only</div>
        <div className="twp-showcase-col">
          {VARIANTS.map((v) => (
            <Notification key={v} variant={v} title={`${v.charAt(0).toUpperCase() + v.slice(1)}: operation completed`} />
          ))}
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">title + description</div>
        <div className="twp-showcase-col">
          {VARIANTS.map((v) => (
            <Notification key={v} variant={v} title={`${v.charAt(0).toUpperCase() + v.slice(1)}`}>
              <p>This is a supporting message with additional context about what happened.</p>
            </Notification>
          ))}
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">with actions</div>
        <div className="twp-showcase-col">
          {VARIANTS.map((v) => (
            <Notification
              key={v}
              variant={v}
              title={`${v.charAt(0).toUpperCase() + v.slice(1)}`}
              actions={[
                { label: 'View', onClick: () => {} },
                { label: 'Dismiss', onClick: () => {} },
              ]}
            >
              <p>Your file has been uploaded successfully and is now processing.</p>
            </Notification>
          ))}
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">dismissible</div>
        <div className="twp-showcase-col">
          {VARIANTS.map((v) => (
            <Notification key={v} variant={v} dismissible title={`${v.charAt(0).toUpperCase() + v.slice(1)}: dismiss me`}>
              <p>Click × to dismiss this notification.</p>
            </Notification>
          ))}
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">actions + dismissible</div>
        <div className="twp-showcase-col">
          {VARIANTS.map((v) => (
            <Notification
              key={v}
              variant={v}
              dismissible
              title={`${v.charAt(0).toUpperCase() + v.slice(1)}`}
              actions={[{ label: 'Undo', onClick: () => {} }]}
            >
              <p>Changes saved. You can undo within 5 seconds.</p>
            </Notification>
          ))}
        </div>
      </div>

      <div className="twp-showcase-group">
        <div className="twp-showcase-label">no icon (custom slot)</div>
        <div className="twp-showcase-col">
          <Notification variant="info" icon={null} title="Custom — no icon">
            <p>Icon prop set to null removes the icon entirely.</p>
          </Notification>
        </div>
      </div>

    </div>
  )
}
