import type { StyleGuideConfig } from "../types";

export function generateSpacingCSS(_config: StyleGuideConfig): string {
  return `/* ═══════════════════════════════════════
   SPACING SHOWCASE
   ═══════════════════════════════════════ */

.spacing-demo {
  display: flex;
  flex-direction: column;
  gap: var(--sg-spacing-gap);
}

.spacing-row {
  display: grid;
  grid-template-columns: var(--sg-spacing-label-width) 1fr var(--sg-spacing-value-width);
  align-items: center;
  gap: var(--space-2);
}

.spacing-label {
  font-family: var(--font-mono);
  font-size: var(--sg-bar-label-font-size);
  color: var(--text-secondary);
  text-align: right;
}

.spacing-bar {
  height: var(--sg-bar-height);
  background: var(--text);
  border-radius: var(--sg-bar-radius);
  min-width: var(--sg-bar-min-width);
}

.spacing-value {
  font-family: var(--font-mono);
  font-size: var(--sg-bar-label-font-size);
  color: var(--text-muted);
}

/* ── Principles ── */

.sg-principles {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.sg-principle {
  font-size: var(--sg-principles-font-size);
  line-height: var(--sg-principles-line-height);
  color: var(--text-secondary);
  padding: var(--space-1) 0;
  border-bottom: var(--border-thin) solid var(--border);
}

.sg-principle strong {
  color: var(--text);
}

/* ── Spacing Diagram ── */

.spacing-diagram {
  border: var(--border-thin) solid var(--border);
  border-radius: var(--radius);
  overflow: hidden;
}

.spacing-diagram-header {
  font-family: var(--font-mono);
  font-size: var(--micro-label-font-size);
  font-weight: var(--micro-label-font-weight);
  text-transform: uppercase;
  letter-spacing: var(--micro-label-letter-spacing);
  color: var(--text-muted);
  padding: var(--space-1) var(--space-2);
  background: var(--surface-alt);
  border-bottom: var(--border-thin) solid var(--border);
}

.spacing-diagram-body {
  padding: var(--space-3);
  background: var(--surface);
}

.spacing-diagram-viewport {
  border: var(--border-thick) solid var(--border-strong);
  border-radius: var(--sg-bar-radius);
  position: relative;
  overflow: hidden;
}

.spacing-diagram-viewport-label {
  font-family: var(--font-mono);
  font-size: var(--micro-label-font-size);
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: var(--sg-section-number-letter-spacing);
  padding: var(--space-half) var(--space-1);
  background: var(--surface-alt);
  border-bottom: var(--border-thin) solid var(--border);
}

.spacing-diagram-cols {
  display: flex;
  align-items: stretch;
  min-height: var(--sg-diagram-min-height);
}

.spacing-diagram-gutter {
  width: var(--sg-diagram-gutter-width);
  min-width: var(--sg-diagram-gutter-width);
  background: repeating-linear-gradient(
    45deg,
    var(--border),
    var(--border) var(--sg-diagram-hatch-width),
    transparent var(--sg-diagram-hatch-width),
    transparent var(--sg-diagram-hatch-gap)
  );
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.spacing-diagram-gutter span {
  font-family: var(--font-mono);
  font-size: var(--sg-diagram-annotation-font-size);
  color: var(--text-muted);
  writing-mode: vertical-rl;
  text-orientation: mixed;
  white-space: nowrap;
}

.spacing-diagram-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.spacing-diagram-block {
  display: flex;
  flex-direction: column;
  border-left: var(--border-thin) solid var(--border);
  border-right: var(--border-thin) solid var(--border);
}

.spacing-diagram-padding {
  height: var(--sg-diagram-padding-height);
  background: repeating-linear-gradient(
    90deg,
    var(--border),
    var(--border) var(--sg-diagram-hatch-width),
    transparent var(--sg-diagram-hatch-width),
    transparent var(--sg-diagram-hatch-gap)
  );
  border-top: var(--border-thin) dashed var(--border-strong);
}

.spacing-diagram-padding--sm {
  height: var(--sg-diagram-padding-height-sm);
}

.spacing-diagram-label {
  padding: var(--space-1) var(--space-2);
}

.spacing-diagram-label-title {
  font-size: var(--sg-diagram-detail-font-size);
  font-weight: var(--sg-diagram-detail-font-weight);
  color: var(--text-secondary);
}

.spacing-diagram-label-meta {
  font-family: var(--font-mono);
  font-size: var(--sg-diagram-note-font-size);
  color: var(--text-muted);
  margin-top: var(--space-quarter);
}`;
}
