'use client';

import React, { ReactNode } from 'react';

export interface StackedListItem {
  title: string;
  subtitle?: string;
  leading?: ReactNode;
  trailing?: ReactNode;
}

export interface StackedListProps {
  items: StackedListItem[];
  flush?: boolean;
  className?: string;
}

export function StackedList({ items, flush = false, className = '' }: StackedListProps) {
  const listClasses = [
    'twp-stacked-list',
    flush ? 'twp-stacked-list-flush' : '',
    className,
  ]
    .filter(Boolean)
    .join(' ');

  return (
    <ul className={listClasses} role="list">
      {items.map((item, i) => (
        <li key={i} className="twp-stacked-list-item">
          {item.leading && (
            <span style={{ flexShrink: 0 }}>{item.leading}</span>
          )}
          <span style={{ flex: 1, minWidth: 0 }}>
            <span className="twp-stacked-list-item-title" style={{ display: 'block' }}>
              {item.title}
            </span>
            {item.subtitle && (
              <span className="twp-stacked-list-item-subtitle" style={{ display: 'block' }}>
                {item.subtitle}
              </span>
            )}
          </span>
          {item.trailing && (
            <span style={{ flexShrink: 0 }}>{item.trailing}</span>
          )}
        </li>
      ))}
    </ul>
  );
}

export function StackedListShowcase() {
  const items: StackedListItem[] = [
    {
      title: 'Alice Nguyen',
      subtitle: 'alice@example.com',
      leading: (
        <span
          style={{
            width: 32,
            height: 32,
            borderRadius: '50%',
            background: 'var(--surface-alt)',
            border: '1px solid var(--border)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: 'var(--font-size-xs)',
            color: 'var(--text-muted)',
          }}
        >
          AN
        </span>
      ),
      trailing: (
        <span style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-muted)' }}>Admin</span>
      ),
    },
    {
      title: 'Bob Martinez',
      subtitle: 'bob@example.com',
      leading: (
        <span
          style={{
            width: 32,
            height: 32,
            borderRadius: '50%',
            background: 'var(--surface-alt)',
            border: '1px solid var(--border)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: 'var(--font-size-xs)',
            color: 'var(--text-muted)',
          }}
        >
          BM
        </span>
      ),
      trailing: (
        <span style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-muted)' }}>Member</span>
      ),
    },
    {
      title: 'Carol Smith',
      subtitle: 'carol@example.com',
      leading: (
        <span
          style={{
            width: 32,
            height: 32,
            borderRadius: '50%',
            background: 'var(--surface-alt)',
            border: '1px solid var(--border)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: 'var(--font-size-xs)',
            color: 'var(--text-muted)',
          }}
        >
          CS
        </span>
      ),
      trailing: (
        <span style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-muted)' }}>Viewer</span>
      ),
    },
  ];

  const simpleItems: StackedListItem[] = [
    { title: 'Project Alpha', subtitle: 'Due Jan 15' },
    { title: 'Project Beta', subtitle: 'Due Feb 3' },
    { title: 'Project Gamma', subtitle: 'Due Mar 20' },
  ];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
      <div>
        <p style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-muted)', marginBottom: 'var(--space-2)' }}>
          With leading avatar and trailing label
        </p>
        <StackedList items={items} />
      </div>
      <div>
        <p style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-muted)', marginBottom: 'var(--space-2)' }}>
          Simple (flush)
        </p>
        <StackedList items={simpleItems} flush />
      </div>
    </div>
  );
}
