'use client'

import React from 'react'

// ─── Types ───────────────────────────────────────────────────────────────────

export type AvatarSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl'
export type AvatarStatus = 'online' | 'offline'

export interface AvatarProps {
  /** Image URL */
  src?: string
  /** Alt text for image */
  alt?: string
  /** Fallback initials when no src provided */
  initials?: string
  /** Avatar size */
  size?: AvatarSize
  /** Rounded square shape instead of circular */
  rounded?: boolean
  /** Online/offline status dot */
  status?: AvatarStatus
  className?: string
}

export interface AvatarGroupProps {
  children: React.ReactNode
  className?: string
}

// ─── Placeholder Icon ─────────────────────────────────────────────────────────

function PlaceholderIcon() {
  return (
    <svg
      className="twp-avatar-placeholder"
      viewBox="0 0 24 24"
      fill="currentColor"
      aria-hidden="true"
    >
      <path d="M12 12c2.7 0 4.8-2.1 4.8-4.8S14.7 2.4 12 2.4 7.2 4.5 7.2 7.2 9.3 12 12 12zm0 2.4c-3.2 0-9.6 1.6-9.6 4.8v2.4h19.2v-2.4c0-3.2-6.4-4.8-9.6-4.8z" />
    </svg>
  )
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

export function Avatar({
  src,
  alt = '',
  initials,
  size = 'md',
  rounded = false,
  status,
  className = '',
}: AvatarProps) {
  const avatarClasses = [
    'twp-avatar',
    `twp-avatar-${size}`,
    rounded ? 'twp-avatar-rounded' : '',
    className,
  ]
    .filter(Boolean)
    .join(' ')

  const avatarEl = (
    <span className={avatarClasses}>
      {src ? (
        <img src={src} alt={alt} />
      ) : initials ? (
        <span className="twp-avatar-initials" aria-label={alt || initials}>
          {initials}
        </span>
      ) : (
        <PlaceholderIcon />
      )}
    </span>
  )

  if (status) {
    return (
      <span className="twp-avatar-wrapper">
        {avatarEl}
        <span
          className={[
            'twp-avatar-status',
            status === 'online' ? 'twp-avatar-status-online' : 'twp-avatar-status-offline',
          ].join(' ')}
          aria-label={status}
        />
      </span>
    )
  }

  return avatarEl
}

// ─── AvatarGroup ──────────────────────────────────────────────────────────────

export function AvatarGroup({ children, className = '' }: AvatarGroupProps) {
  return (
    <div className={['twp-avatar-group', className].filter(Boolean).join(' ')}>
      {children}
    </div>
  )
}

// ─── Showcase ─────────────────────────────────────────────────────────────────

const DEMO_IMG =
  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80'

const DEMO_IMGS = [
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
  'https://images.unsplash.com/photo-1550525811-e5869dd03032?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
  'https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
]

function Row({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div style={{ marginBottom: '1.5rem' }}>
      <p
        style={{
          fontSize: 'var(--font-size-xs)',
          color: 'var(--text-muted)',
          marginBottom: '0.5rem',
          fontFamily: 'var(--font-sans)',
        }}
      >
        {label}
      </p>
      <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', flexWrap: 'wrap' }}>
        {children}
      </div>
    </div>
  )
}

export function AvatarShowcase() {
  return (
    <div style={{ padding: '1.5rem' }}>
      {/* Circular sizes */}
      <Row label="Circular — image — all sizes">
        {(['xs', 'sm', 'md', 'lg', 'xl'] as AvatarSize[]).map((s) => (
          <Avatar key={s} src={DEMO_IMG} alt="Demo user" size={s} />
        ))}
      </Row>

      {/* Rounded sizes */}
      <Row label="Rounded — image — all sizes">
        {(['xs', 'sm', 'md', 'lg', 'xl'] as AvatarSize[]).map((s) => (
          <Avatar key={s} src={DEMO_IMG} alt="Demo user" size={s} rounded />
        ))}
      </Row>

      {/* Initials */}
      <Row label="Initials fallback">
        {(['xs', 'sm', 'md', 'lg', 'xl'] as AvatarSize[]).map((s) => (
          <Avatar key={s} initials="KR" alt="Keith Rings" size={s} />
        ))}
      </Row>

      {/* Placeholder icon */}
      <Row label="Placeholder icon">
        {(['xs', 'sm', 'md', 'lg', 'xl'] as AvatarSize[]).map((s) => (
          <Avatar key={s} size={s} />
        ))}
      </Row>

      {/* Status dots */}
      <Row label="Status — online / offline">
        <Avatar src={DEMO_IMG} alt="Online user" size="md" status="online" />
        <Avatar src={DEMO_IMG} alt="Offline user" size="md" status="offline" />
        <Avatar src={DEMO_IMG} alt="Online user" size="lg" status="online" />
        <Avatar initials="AB" size="md" status="online" />
        <Avatar size="md" status="offline" />
      </Row>

      {/* Rounded with status */}
      <Row label="Rounded with status">
        <Avatar src={DEMO_IMG} alt="Online" size="md" rounded status="online" />
        <Avatar src={DEMO_IMG} alt="Offline" size="lg" rounded status="offline" />
        <Avatar initials="KR" size="md" rounded status="online" />
      </Row>

      {/* Group stacked */}
      <Row label="Avatar group — stacked">
        <AvatarGroup>
          {DEMO_IMGS.map((img, i) => (
            <Avatar key={i} src={img} alt={`User ${i + 1}`} size="sm" />
          ))}
        </AvatarGroup>
        <AvatarGroup>
          {DEMO_IMGS.map((img, i) => (
            <Avatar key={i} src={img} alt={`User ${i + 1}`} size="md" />
          ))}
        </AvatarGroup>
      </Row>

      {/* Group with initials mix */}
      <Row label="Avatar group — mixed (image + initials + placeholder)">
        <AvatarGroup>
          <Avatar src={DEMO_IMGS[0]} alt="User 1" size="md" />
          <Avatar initials="AB" size="md" />
          <Avatar size="md" />
          <Avatar src={DEMO_IMGS[2]} alt="User 3" size="md" />
        </AvatarGroup>
      </Row>
    </div>
  )
}
