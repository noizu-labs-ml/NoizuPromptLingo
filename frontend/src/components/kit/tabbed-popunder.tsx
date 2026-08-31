'use client';

import { Dialog, DialogPanel, DialogTitle, Transition, TransitionChild } from '@headlessui/react';
import { Fragment, useState, type ReactNode } from 'react';

export interface TabbedPopunderTab {
  id: string;
  label: string;
  /** Renders the tab body. Called only for the active tab. */
  render: () => ReactNode;
}

interface TabbedPopunderProps {
  open: boolean;
  onClose: () => void;
  title?: ReactNode;
  /** Tab config — label + render pairs (e.g. claude cli / grok / codex / opencode). */
  tabs: TabbedPopunderTab[];
  /** Controlled active tab id (pair with onTabChange). */
  activeTab?: string;
  /** Uncontrolled initial tab when activeTab is not provided. */
  initialTabId?: string;
  onTabChange?: (id: string) => void;
  /** Max panel width in px (default 640). */
  maxWidth?: number;
}

/**
 * Modal "popunder" with a config-driven tab selector — a centered dialog with
 * overlay, ESC-close, click-outside and focus trapping (Headless UI Dialog).
 * Tab state works controlled (activeTab + onTabChange) or uncontrolled.
 *
 * Intended host: "Setup MCP" per-CLI instructions (W3).
 */
export default function TabbedPopunder({
  open,
  onClose,
  title,
  tabs,
  activeTab,
  initialTabId,
  onTabChange,
  maxWidth = 640,
}: TabbedPopunderProps) {
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
            style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)' }}
            aria-hidden="true"
          />
        </TransitionChild>

        <div
          style={{
            position: 'fixed',
            inset: 0,
            display: 'flex',
            alignItems: 'flex-start',
            justifyContent: 'center',
            padding: '8vh 16px 16px',
            pointerEvents: 'none',
          }}
        >
          <TransitionChild
            as={Fragment}
            enter="transition ease-out duration-200"
            enterFrom="opacity-0 translate-y-2"
            enterTo="opacity-100 translate-y-0"
            leave="transition ease-in duration-150"
            leaveFrom="opacity-100 translate-y-0"
            leaveTo="opacity-0 translate-y-2"
          >
            <DialogPanel
              style={{
                pointerEvents: 'auto',
                width: '100%',
                maxWidth,
                maxHeight: '84vh',
                display: 'flex',
                flexDirection: 'column',
                background: 'var(--bg-2)',
                border: '1px solid var(--border)',
                borderRadius: 'var(--radius-md)',
                boxShadow: '0 16px 48px rgba(0,0,0,0.45)',
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
                <button
                  type="button"
                  onClick={onClose}
                  aria-label="Close dialog"
                  style={{
                    padding: '2px 8px',
                    fontSize: 12,
                    borderRadius: 4,
                    border: '1px solid var(--border)',
                    background: 'transparent',
                    color: 'var(--text-2)',
                    cursor: 'pointer',
                    fontFamily: 'var(--font)',
                  }}
                >
                  ✕
                </button>
              </div>

              {/* Tab bar */}
              <div
                role="tablist"
                aria-label="Sections"
                style={{
                  display: 'flex',
                  gap: 4,
                  padding: '8px 12px 0',
                  borderBottom: '1px solid var(--border)',
                  background: 'var(--bg-3)',
                  overflowX: 'auto',
                }}
              >
                {tabs.map((t) => {
                  const selected = activeTabDef?.id === t.id;
                  return (
                    <button
                      key={t.id}
                      type="button"
                      role="tab"
                      id={`popunder-tab-${t.id}`}
                      aria-selected={selected}
                      aria-controls={`popunder-panel-${t.id}`}
                      onClick={() => selectTab(t.id)}
                      style={{
                        padding: '7px 12px',
                        fontSize: 12,
                        fontWeight: selected ? 600 : 400,
                        border: 0,
                        borderBottom: `2px solid ${selected ? 'var(--accent)' : 'transparent'}`,
                        background: 'transparent',
                        color: selected ? 'var(--text-0)' : 'var(--text-2)',
                        cursor: 'pointer',
                        fontFamily: 'var(--font)',
                        whiteSpace: 'nowrap',
                      }}
                    >
                      {t.label}
                    </button>
                  );
                })}
              </div>

              {/* Body */}
              <div
                role="tabpanel"
                id={activeTabDef ? `popunder-panel-${activeTabDef.id}` : undefined}
                aria-labelledby={activeTabDef ? `popunder-tab-${activeTabDef.id}` : undefined}
                style={{ flex: 1, overflowY: 'auto', padding: 16 }}
              >
                {activeTabDef ? activeTabDef.render() : null}
              </div>
            </DialogPanel>
          </TransitionChild>
        </div>
      </Dialog>
    </Transition>
  );
}
