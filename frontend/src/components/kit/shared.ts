'use client';

import type { CSSProperties } from 'react';

/**
 * Shared style primitives for the ui-kit components.
 * Matches the repo convention of CSS-variable inline styling
 * (see components/mcp-setup-panel.tsx).
 */

export const kitBtnSm: CSSProperties = {
  padding: '4px 10px',
  fontSize: 11,
  borderRadius: 4,
  border: '1px solid var(--border)',
  background: 'var(--bg-2)',
  color: 'var(--text-1)',
  cursor: 'pointer',
  fontFamily: 'var(--font)',
};

export const kitBtnDanger: CSSProperties = {
  ...kitBtnSm,
  borderColor: 'var(--red, #b91c1c)',
  color: 'var(--red, #b91c1c)',
};

export const kitInput: CSSProperties = {
  padding: '4px 8px',
  fontSize: 12,
  borderRadius: 4,
  border: '1px solid var(--border)',
  background: 'var(--bg-3)',
  color: 'var(--text-1)',
  fontFamily: 'var(--font)',
};

export const kitFieldLabel: CSSProperties = {
  display: 'block',
  fontSize: 10,
  fontWeight: 600,
  color: 'var(--text-3)',
  marginBottom: 2,
  textTransform: 'uppercase',
  letterSpacing: '0.04em',
};

export const kitMenuSurface: CSSProperties = {
  background: 'var(--bg-2)',
  border: '1px solid var(--border)',
  borderRadius: 6,
  boxShadow: '0 8px 24px rgba(0,0,0,0.35)',
  padding: 4,
  minWidth: 180,
  zIndex: 1000,
};

export const kitMenuItem = (opts: { destructive?: boolean; disabled?: boolean }): CSSProperties => ({
  display: 'flex',
  alignItems: 'center',
  gap: 8,
  width: '100%',
  padding: '6px 10px',
  fontSize: 12,
  border: 0,
  borderRadius: 4,
  textAlign: 'left',
  cursor: opts.disabled ? 'default' : 'pointer',
  fontFamily: 'var(--font)',
  background: 'transparent',
  color: opts.disabled
    ? 'var(--text-3)'
    : opts.destructive
      ? 'var(--red, #ef4444)'
      : 'var(--text-1)',
  opacity: opts.disabled ? 0.55 : 1,
});
