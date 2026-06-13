'use client';

import { useState, type ReactNode } from 'react';
import { Dialog, DialogPanel, DialogTitle } from '@headlessui/react';

export interface DrawerProps {
  open: boolean;
  onClose: () => void;
  side?: 'left' | 'right';
  size?: 'sm' | 'md' | 'lg';
  title?: string;
  children?: ReactNode;
  footer?: ReactNode;
  className?: string;
}

export function Drawer({
  open,
  onClose,
  side = 'right',
  size = 'md',
  title,
  children,
  footer,
  className,
}: DrawerProps) {
  const sideClass = side === 'left' ? 'twp-drawer-left' : 'twp-drawer-right';
  const sizeClass = size === 'sm' ? 'twp-drawer-sm' : size === 'lg' ? 'twp-drawer-lg' : '';

  return (
    <Dialog open={open} onClose={onClose}>
      <div className="twp-drawer-backdrop" aria-hidden="true" />
      <DialogPanel
        className={['twp-drawer', sideClass, sizeClass, className].filter(Boolean).join(' ')}
      >
        {title && (
          <div className="twp-drawer-header">
            <DialogTitle
              style={{
                fontSize: 'var(--font-size-lg)',
                fontWeight: 600,
                color: 'var(--text)',
                fontFamily: 'var(--font-sans)',
                margin: 0,
              }}
            >
              {title}
            </DialogTitle>
            <button
              type="button"
              className="twp-drawer-close"
              onClick={onClose}
              aria-label="Close"
            >
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none" aria-hidden="true">
                <path d="M12 4L4 12M4 4l8 8" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
              </svg>
            </button>
          </div>
        )}

        {children && <div className="twp-drawer-body">{children}</div>}

        {footer && <div className="twp-drawer-footer">{footer}</div>}
      </DialogPanel>
    </Dialog>
  );
}

export function DrawerShowcase() {
  const [open, setOpen] = useState(false);
  const [side, setSide] = useState<'left' | 'right'>('right');
  const [size, setSize] = useState<'sm' | 'md' | 'lg'>('md');

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
      <div style={{ display: 'flex', gap: 'var(--space-3)', flexWrap: 'wrap' }}>
        {(['left', 'right'] as const).map((s) =>
          (['sm', 'md', 'lg'] as const).map((sz) => (
            <button
              key={`${s}-${sz}`}
              type="button"
              onClick={() => { setSide(s); setSize(sz); setOpen(true); }}
              style={{
                padding: 'var(--space-2) var(--space-4)',
                borderRadius: 'var(--radius)',
                border: '1px solid var(--border)',
                background: 'var(--surface)',
                color: 'var(--text)',
                fontFamily: 'var(--font-sans)',
                fontSize: 'var(--font-size-sm)',
                cursor: 'pointer',
              }}
            >
              {s} / {sz}
            </button>
          ))
        )}
      </div>

      <Drawer
        open={open}
        onClose={() => setOpen(false)}
        side={side}
        size={size}
        title="Drawer Panel"
        footer={
          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 'var(--space-3)' }}>
            <button
              type="button"
              onClick={() => setOpen(false)}
              style={{
                padding: 'var(--space-2) var(--space-4)',
                borderRadius: 'var(--radius)',
                border: '1px solid var(--border)',
                background: 'transparent',
                color: 'var(--text)',
                fontFamily: 'var(--font-sans)',
                fontSize: 'var(--font-size-sm)',
                cursor: 'pointer',
              }}
            >
              Cancel
            </button>
            <button
              type="button"
              onClick={() => setOpen(false)}
              style={{
                padding: 'var(--space-2) var(--space-4)',
                borderRadius: 'var(--radius)',
                border: 'none',
                background: 'var(--brand-blue)',
                color: '#fff',
                fontFamily: 'var(--font-sans)',
                fontSize: 'var(--font-size-sm)',
                cursor: 'pointer',
              }}
            >
              Save
            </button>
          </div>
        }
      >
        <p style={{ color: 'var(--text-secondary)', fontSize: 'var(--font-size-base)', margin: 0 }}>
          This is a <strong>{size}</strong> drawer sliding in from the <strong>{side}</strong>.
          Content goes here using design system tokens.
        </p>
      </Drawer>
    </div>
  );
}
