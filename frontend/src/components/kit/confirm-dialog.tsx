'use client';

import { Dialog, DialogPanel, DialogTitle, Transition, TransitionChild } from '@headlessui/react';
import { Fragment, useState, type ReactNode } from 'react';

export interface ConfirmDialogProps {
  open: boolean;
  onClose: () => void;
  title: string;
  /** Body copy — the question the user is confirming. */
  children?: ReactNode;
  /** Confirm button text (default "Confirm"). */
  confirmLabel?: string;
  /** Cancel button text (default "Cancel"). */
  cancelLabel?: string;
  /** Danger styling for irreversible actions (revoke / delete). */
  destructive?: boolean;
  /**
   * Sync or async action. The dialog stays open with a busy confirm button
   * until the promise settles, and closes on success. A rejection keeps it
   * open so the user can retry — callers surface the failure themselves
   * (inline error panel or toast).
   */
  onConfirm?: () => void | Promise<void>;
}

/**
 * Confirmation modal replacing window.confirm/prompt sites. Built on
 * Headless UI Dialog for overlay, ESC-close, backdrop-click close and focus
 * trapping (same mechanism as kit/slideover-sidebar.tsx).
 */
export default function ConfirmDialog({
  open,
  onClose,
  title,
  children,
  confirmLabel = 'Confirm',
  cancelLabel = 'Cancel',
  destructive = false,
  onConfirm,
}: ConfirmDialogProps) {
  const [busy, setBusy] = useState(false);

  async function handleConfirm() {
    if (!onConfirm) {
      onClose();
      return;
    }
    setBusy(true);
    try {
      await onConfirm();
      onClose();
    } catch {
      // Caller reported the failure; stay open for retry.
    } finally {
      setBusy(false);
    }
  }

  return (
    <Transition show={open} as={Fragment}>
      <Dialog onClose={onClose} className="relative z-[900]">
        {/* Overlay */}
        <TransitionChild
          as={Fragment}
          enter="ease-out duration-200"
          enterFrom="opacity-0"
          enterTo="opacity-100"
          leave="ease-in duration-150"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <div
            style={{
              position: 'fixed',
              inset: 0,
              background: 'rgba(0,0,0,0.5)',
            }}
            aria-hidden="true"
          />
        </TransitionChild>

        <div
          style={{
            position: 'fixed',
            inset: 0,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: 16,
            pointerEvents: 'none',
          }}
        >
          <TransitionChild
            as={Fragment}
            enter="ease-out duration-200"
            enterFrom="opacity-0"
            enterTo="opacity-100"
            leave="ease-in duration-150"
            leaveFrom="opacity-100"
            leaveTo="opacity-0"
          >
            <DialogPanel
              style={{
                pointerEvents: 'auto',
                width: 400,
                maxWidth: '100%',
                background: 'var(--bg-2)',
                border: '1px solid var(--border)',
                borderRadius: 'var(--radius-md)',
                boxShadow: '0 0 32px rgba(0,0,0,0.4)',
                padding: 16,
              }}
            >
              <DialogTitle
                style={{ fontSize: 14, fontWeight: 600, margin: 0, color: 'var(--text-0)' }}
              >
                {title}
              </DialogTitle>
              {children ? (
                <div style={{ fontSize: 13, lineHeight: 1.6, color: 'var(--text-2)', marginTop: 8, marginBottom: 16 }}>
                  {children}
                </div>
              ) : (
                <div style={{ marginBottom: 16 }} />
              )}
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 8 }}>
                <button
                  type="button"
                  className="sg-btn sg-btn--outline sg-btn--sm"
                  onClick={onClose}
                  disabled={busy}
                >
                  {cancelLabel}
                </button>
                <button
                  type="button"
                  className={`sg-btn sg-btn--sm ${destructive ? 'sg-btn--danger' : 'sg-btn--black'}`}
                  onClick={() => void handleConfirm()}
                  disabled={busy}
                >
                  {busy ? 'Working…' : confirmLabel}
                </button>
              </div>
            </DialogPanel>
          </TransitionChild>
        </div>
      </Dialog>
    </Transition>
  );
}
