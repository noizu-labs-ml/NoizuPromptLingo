'use client';

import { Dialog, DialogPanel, DialogTitle, Transition, TransitionChild } from '@headlessui/react';
import { Fragment, useState, type ReactNode } from 'react';
import { kitBtnSm } from './shared';

export interface SlideOverTab {
  id: string;
  label: string;
  content: ReactNode;
}

interface SlideOverSidebarProps {
  open: boolean;
  onClose: () => void;
  title?: ReactNode;
  /** Tabs to render in the sidebar header; each tab swaps the body content. */
  tabs?: SlideOverTab[];
  /** Controlled active tab id (pair with onTabChange). */
  activeTab?: string;
  /** Uncontrolled initial tab when activeTab is not provided. */
  initialTabId?: string;
  onTabChange?: (id: string) => void;
  /** Sidebar width in px (default 420). */
  width?: number;
  /** Which edge the panel slides in from (default right). */
  side?: 'left' | 'right';
  /** Extra footer content (e.g. Save/Cancel). */
  footer?: ReactNode;
}

/**
 * Slide-over sidebar panel with optional tabbed content. Built on Headless UI
 * Dialog for overlay, ESC-close, click-outside and focus trapping. Tab state
 * works controlled (activeTab + onTabChange) or uncontrolled (initialTabId).
 *
 * Intended host: scope settings ("Edit Scope" / "Manage Clients" tabs).
 */
export default function SlideOverSidebar({
  open,
  onClose,
  title,
  tabs = [],
  activeTab,
  initialTabId,
  onTabChange,
  width = 420,
  side = 'right',
  footer,
}: SlideOverSidebarProps) {
  const [internalTab, setInternalTab] = useState<string | null>(initialTabId ?? tabs[0]?.id ?? null);
  const currentTabId = activeTab ?? internalTab;
  const activeTabDef = tabs.find((t) => t.id === currentTabId) ?? tabs[0] ?? null;

  function selectTab(id: string) {
    if (activeTab === undefined) setInternalTab(id);
    onTabChange?.(id);
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
            justifyContent: side === 'right' ? 'flex-end' : 'flex-start',
            pointerEvents: 'none',
          }}
        >
          <TransitionChild
            as={Fragment}
            enter="transition ease-out duration-200"
            enterFrom={side === 'right' ? 'translate-x-full' : '-translate-x-full'}
            enterTo="translate-x-0"
            leave="transition ease-in duration-150"
            leaveFrom="translate-x-0"
            leaveTo={side === 'right' ? 'translate-x-full' : '-translate-x-full'}
          >
            <DialogPanel
              style={{
                pointerEvents: 'auto',
                width,
                maxWidth: '100vw',
                height: '100%',
                display: 'flex',
                flexDirection: 'column',
                background: 'var(--bg-2)',
                borderLeft: side === 'right' ? '1px solid var(--border)' : undefined,
                borderRight: side === 'left' ? '1px solid var(--border)' : undefined,
                boxShadow: '0 0 32px rgba(0,0,0,0.4)',
              }}
            >
              {/* Header */}
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  gap: 8,
                  padding: '12px 16px',
                  borderBottom: '1px solid var(--border)',
                }}
              >
                {title ? (
                  <DialogTitle style={{ fontSize: 13, fontWeight: 600, margin: 0, color: 'var(--text-0)' }}>
                    {title}
                  </DialogTitle>
                ) : (
                  <span />
                )}
                <button type="button" onClick={onClose} style={kitBtnSm} aria-label="Close sidebar">
                  ✕
                </button>
              </div>

              {/* Tabs */}
              {tabs.length > 0 ? (
                <div
                  role="tablist"
                  aria-label="Sidebar sections"
                  style={{
                    display: 'flex',
                    borderBottom: '1px solid var(--border)',
                    background: 'var(--bg-3)',
                  }}
                >
                  {tabs.map((t) => {
                    const selected = activeTabDef?.id === t.id;
                    return (
                      <button
                        key={t.id}
                        type="button"
                        role="tab"
                        id={`slideover-tab-${t.id}`}
                        aria-selected={selected}
                        aria-controls={`slideover-panel-${t.id}`}
                        onClick={() => selectTab(t.id)}
                        style={{
                          flex: 1,
                          padding: '8px 12px',
                          fontSize: 12,
                          fontWeight: selected ? 600 : 400,
                          border: 0,
                          borderBottom: `2px solid ${selected ? 'var(--accent)' : 'transparent'}`,
                          background: 'transparent',
                          color: selected ? 'var(--text-0)' : 'var(--text-2)',
                          cursor: 'pointer',
                          fontFamily: 'var(--font)',
                        }}
                      >
                        {t.label}
                      </button>
                    );
                  })}
                </div>
              ) : null}

              {/* Body */}
              <div
                role="tabpanel"
                id={activeTabDef ? `slideover-panel-${activeTabDef.id}` : undefined}
                aria-labelledby={activeTabDef ? `slideover-tab-${activeTabDef.id}` : undefined}
                style={{
                  flex: 1,
                  overflowY: 'auto',
                  padding: 16,
                }}
              >
                {activeTabDef ? activeTabDef.content : null}
              </div>

              {/* Footer */}
              {footer ? (
                <div
                  style={{
                    padding: '10px 16px',
                    borderTop: '1px solid var(--border)',
                    background: 'var(--bg-3)',
                  }}
                >
                  {footer}
                </div>
              ) : null}
            </DialogPanel>
          </TransitionChild>
        </div>
      </Dialog>
    </Transition>
  );
}
