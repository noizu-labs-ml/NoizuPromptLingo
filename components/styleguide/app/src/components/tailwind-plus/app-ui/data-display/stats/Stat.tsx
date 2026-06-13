'use client'

import React, { ReactNode } from 'react'

// ─── Types ───────────────────────────────────────────────────────────────────

interface Trend {
  value: string
  direction: 'up' | 'down'
}

interface StatProps {
  label: string
  value: string | number
  trend?: Trend
  icon?: ReactNode
  className?: string
}

interface StatGroupProps {
  children: ReactNode
  className?: string
}

// ─── Stat ────────────────────────────────────────────────────────────────────

export function Stat({ label, value, trend, icon, className = '' }: StatProps) {
  return (
    <div className={`twp-stat ${className}`}>
      {icon && <div className="twp-stat-icon">{icon}</div>}
      <div className="twp-stat-value">{value}</div>
      <div className="twp-stat-label">{label}</div>
      {trend && (
        <div
          className={`twp-stat-trend ${
            trend.direction === 'up' ? 'twp-stat-trend-up' : 'twp-stat-trend-down'
          }`}
        >
          <span aria-hidden="true">{trend.direction === 'up' ? '↑' : '↓'}</span>
          <span>{trend.value}</span>
        </div>
      )}
    </div>
  )
}

// ─── StatGroup ───────────────────────────────────────────────────────────────

export function StatGroup({ children, className = '' }: StatGroupProps) {
  return <div className={`twp-stat-group ${className}`}>{children}</div>
}

// ─── Showcase ────────────────────────────────────────────────────────────────

export function StatShowcase() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
      <StatGroup>
        <Stat label="Total Revenue" value="$48,295" trend={{ value: '12% this month', direction: 'up' }} />
        <Stat label="Active Users" value="3,842" trend={{ value: '4% this week', direction: 'down' }} />
        <Stat label="Conversion Rate" value="5.27%" trend={{ value: '0.8% this month', direction: 'up' }} />
        <Stat label="Avg. Order Value" value="$124" />
        <Stat
          label="Uptime"
          value="99.9%"
          icon={
            <svg viewBox="0 0 20 20" fill="currentColor" width="20" height="20">
              <path
                fillRule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z"
                clipRule="evenodd"
              />
            </svg>
          }
        />
        <Stat label="Support Tickets" value="17" trend={{ value: '3 since yesterday', direction: 'up' }} />
      </StatGroup>
    </div>
  )
}
