'use client';

import { useState, type ReactNode } from 'react';
import { Dialog, DialogPanel, DialogTitle } from '@headlessui/react';

export interface ModalProps {
  open: boolean;
  onClose: () => void;
  size?: 'sm' | 'md' | 'lg';
  title?: string;
  children?: ReactNode;
  footer?: ReactNode;
  className?: string;
}

export function Modal({
  open,
  onClose,
  size = 'md',
  title,
  children,
  footer,
  className,
}: ModalProps) {
  const sizeClass = size === 'sm' ? 'twp-modal-sm' : size === 'lg' ? 'twp-modal-lg' : 'twp-modal-md';

  return (
    <Dialog open={open} onClose={onClose} className="twp-modal-backdrop">
      <DialogPanel className={['twp-modal', sizeClass, className].filter(Boolean).join(' ')}>
        {title && (
          <div className="twp-modal-header">
            <DialogTitle className="twp-modal-title">{title}</DialogTitle>
            <button
              type="button"
              className="twp-modal-close"
              onClick={onClose}
              aria-label="Close"
            >
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none" aria-hidden="true">
                <path d="M12 4L4 12M4 4l8 8" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
              </svg>
            </button>
          </div>
        )}

        {children && <div className="twp-modal-body">{children}</div>}

        {footer && <div className="twp-modal-footer">{footer}</div>}
      </DialogPanel>
    </Dialog>
  );
}

export function ModalShowcase() {
  const [open, setOpen] = useState(false);
  const [size, setSize] = useState<'sm' | 'md' | 'lg'>('md');

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
      <div style={{ display: 'flex', gap: 'var(--space-3)', flexWrap: 'wrap' }}>
        {(['sm', 'md', 'lg'] as const).map((s) => (
          <button
            key={s}
            type="button"
            onClick={() => { setSize(s); setOpen(true); }}
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
            Open {s.toUpperCase()} Modal
          </button>
        ))}
      </div>

      <Modal
        open={open}
        onClose={() => setOpen(false)}
        size={size}
        title="Confirm Action"
        footer={
          <>
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
              Confirm
            </button>
          </>
        }
      >
        <p style={{ color: 'var(--text-secondary)', fontSize: 'var(--font-size-base)', margin: 0 }}>
          This is a <strong>{size}</strong> modal using design system tokens. Are you sure you want to proceed?
        </p>
      </Modal>
    </div>
  );
}
