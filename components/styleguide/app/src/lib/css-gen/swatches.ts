import type { StyleGuideConfig } from "../types";

export function generateSwatchCSS(_config: StyleGuideConfig): string {
  return `/* ═══════════════════════════════════════
   COLOR SWATCHES
   ═══════════════════════════════════════ */

/* ─── Grid ─── */
.sg-palette-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: var(--space-1);
}

/* ─── Swatch cell — checkerboard reveals alpha ─── */
.sg-palette-swatch {
  background: repeating-conic-gradient(var(--border) 0% 25%, var(--surface) 0% 50%) 0 0 / 12px 12px;
  border: var(--border-thin) solid var(--border);
  height: var(--space-10);
  position: relative;
}

/* ─── Color overlay ─── */
.sg-palette-swatch-inner {
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: var(--space-1);
  cursor: pointer;
  position: relative;
}

/* ─── Label ─── */
.sg-palette-swatch-label {
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-bold);
}

/* ─── Value / hex ─── */
.sg-palette-swatch-value {
  font-size: var(--font-size-xs);
  font-family: var(--font-mono);
  opacity: 0.7;
  display: block;
}

/* ─── Swatch text inherits color from .bg-{name} contrast ─── */
.sg-palette-swatch-label,
.sg-palette-swatch-value {
  color: inherit;
}

/* ─── Copied flash ─── */
.sg-palette-swatch-copied {
  position: absolute;
  top: var(--space-1);
  right: var(--space-1);
  font-size: var(--font-size-xs);
  font-family: var(--font-mono);
  font-weight: var(--font-weight-bold);
  color: var(--white);
  background: rgba(0,0,0,0.6);
  padding: var(--border-heavy) 6px;
}

/* ─── Hover popunder ─── */
.sg-swatch-popunder {
  display: none;
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  z-index: 20;
  background: var(--surface);
  border: var(--border-thin) solid var(--border);
  box-shadow: 0 4px 12px rgba(0,0,0,0.1), 0 1px 4px rgba(0,0,0,0.06);
  padding: var(--space-half) 0;
  font-family: var(--font-mono);
  font-size: var(--font-size-xs);
}
.sg-palette-swatch:hover .sg-swatch-popunder {
  display: block;
}
.sg-swatch-popunder-row {
  display: flex;
  align-items: center;
  gap: var(--space-1);
  padding: var(--border-heavy) var(--space-1);
  cursor: pointer;
  color: var(--text-secondary);
  white-space: nowrap;
}
.sg-swatch-popunder-row:hover {
  background: var(--surface-alt);
  color: var(--text);
}
.sg-swatch-popunder-row .sg-swatch-popunder-icon {
  flex-shrink: 0;
  width: 14px;
  height: 14px;
  color: var(--text-muted);
}
.sg-swatch-popunder-row:hover .sg-swatch-popunder-icon {
  color: var(--text-secondary);
}
.sg-swatch-popunder-row.copied {
  color: var(--success);
}

/* ─── Notes ─── */
.sg-palette-notes {
  margin-top: var(--space-1);
}
.sg-palette-note {
  display: flex;
  align-items: center;
  gap: var(--space-1);
  padding: var(--space-half) 0;
  font-family: var(--font-mono);
  font-size: var(--font-size-sm);
  color: var(--text-muted);
}
.sg-palette-note-dot {
  width: var(--space-2);
  height: var(--space-2);
  flex-shrink: 0;
}`;
}
