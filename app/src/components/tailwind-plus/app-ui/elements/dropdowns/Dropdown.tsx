'use client'

import { ReactNode } from 'react';
import { Menu, MenuButton, MenuItem, MenuItems } from '@headlessui/react';

export interface DropdownItem {
  label?: string;
  onClick?: () => void;
  href?: string;
  divider?: boolean;
  header?: string;
  active?: boolean;
}

export interface DropdownProps {
  trigger: ReactNode;
  items: DropdownItem[];
  align?: 'left' | 'right';
  className?: string;
}

export function Dropdown({
  trigger,
  items,
  align = 'left',
  className = '',
}: DropdownProps) {
  const menuAlignCls = align === 'right' ? 'twp-dropdown-menu-right' : 'twp-dropdown-menu-left';

  return (
    <Menu as="div" className={['twp-dropdown', className].filter(Boolean).join(' ')}>
      <MenuButton as="div" style={{ display: 'inline-flex', cursor: 'pointer' }}>
        {trigger}
      </MenuButton>

      <MenuItems
        transition
        className={['twp-dropdown-menu', menuAlignCls].join(' ')}
      >
        {items.map((item, idx) => {
          if (item.divider) {
            return <div key={idx} className="twp-dropdown-divider" role="separator" />;
          }

          if (item.header) {
            return (
              <div key={idx} className="twp-dropdown-header">
                {item.header}
              </div>
            );
          }

          const itemCls = ['twp-dropdown-item', item.active ? 'twp-dropdown-item-active' : '']
            .filter(Boolean)
            .join(' ');

          return (
            <MenuItem key={idx}>
              {item.href ? (
                <a href={item.href} className={itemCls}>
                  {item.label}
                </a>
              ) : (
                <button type="button" className={itemCls} onClick={item.onClick}>
                  {item.label}
                </button>
              )}
            </MenuItem>
          );
        })}
      </MenuItems>
    </Menu>
  );
}

const DEMO_ITEMS: DropdownItem[] = [
  { header: 'Account' },
  { label: 'Profile', href: '#' },
  { label: 'Settings', onClick: () => {} },
  { divider: true },
  { label: 'Active item', onClick: () => {}, active: true },
  { divider: true },
  { label: 'Sign out', onClick: () => {} },
];

const SIMPLE_ITEMS: DropdownItem[] = [
  { label: 'Edit', onClick: () => {} },
  { label: 'Duplicate', onClick: () => {} },
  { divider: true },
  { label: 'Delete', onClick: () => {} },
];

function TriggerButton({ label }: { label: string }) {
  return (
    <button
      type="button"
      className="twp-btn twp-btn-secondary"
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: '0.25rem',
        padding: 'var(--space-1) var(--space-2)',
        fontSize: 'var(--font-size-sm)',
        fontWeight: 500,
        background: 'var(--surface-alt)',
        border: '1px solid var(--border)',
        borderRadius: 'var(--radius)',
        color: 'var(--text)',
        cursor: 'pointer',
        fontFamily: 'var(--font-sans)',
      }}
    >
      {label}
      <svg width="12" height="12" viewBox="0 0 12 12" aria-hidden="true" style={{ marginLeft: 2 }}>
        <path d="M2 4l4 4 4-4" stroke="currentColor" strokeWidth="1.5" fill="none" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    </button>
  );
}

export function DropdownShowcase() {
  return (
    <div className="twp-showcase">
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">align left — with header, dividers, active item</div>
        <div className="twp-showcase-row" style={{ minHeight: 200 }}>
          <Dropdown
            trigger={<TriggerButton label="Options" />}
            items={DEMO_ITEMS}
            align="left"
          />
        </div>
      </div>
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">align right — simple</div>
        <div className="twp-showcase-row" style={{ minHeight: 160, justifyContent: 'flex-end' }}>
          <Dropdown
            trigger={<TriggerButton label="Actions" />}
            items={SIMPLE_ITEMS}
            align="right"
          />
        </div>
      </div>
    </div>
  );
}
