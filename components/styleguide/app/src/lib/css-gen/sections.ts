import type { StyleGuideConfig } from "../types";

export function generateSectionCSS(_config: StyleGuideConfig): string {
  return `/* ═══════════════════════════════════════
   SECTION HEADERS
   ═══════════════════════════════════════ */
.sg-section-header {
  border-bottom: var(--sg-border);
  margin-bottom: var(--space-3);
  padding-bottom: var(--space-2);
  display: flex;
  align-items: flex-start;
  gap: var(--space-2);
  margin-top: var(--space-6);
}
.sg-section-number {
  font-family: var(--micro-label-font-family);
  font-size: var(--micro-label-font-size);
  font-weight: var(--micro-label-font-weight);
  color: var(--sg-section-number-color);
  background: var(--sg-section-number-bg);
  border: var(--sg-section-number-border);
  border-radius: var(--sg-section-number-radius);
  padding: var(--sg-section-number-padding);
  letter-spacing: var(--sg-section-number-letter-spacing);
  white-space: nowrap;
}
.sg-section-title-group {
  flex: 1;
}
.sg-section-title {
  font-family: var(--sg-section-title-font-family);
  font-size: var(--sg-section-title-font-size);
  font-weight: var(--font-weight-bold);
  letter-spacing: var(--sg-section-title-letter-spacing);
  text-transform: var(--sg-section-title-text-transform);
  color: var(--sg-section-title-color);
  margin-bottom: var(--space-quarter);
  display: flex;
  align-items: baseline;
  gap: var(--space-1);
}
.sg-section-desc {
  font-size: var(--font-size-sm);
  color: var(--sg-section-desc-color);
  font-family: var(--sg-section-desc-font-family);
  line-height: var(--line-height-normal);
}

/* ─── Type Specimen Card ─── */
.sg-type-specimen {
  background: var(--sg-type-specimen-bg);
  border: var(--sg-type-specimen-border);
  border-bottom: var(--sg-type-specimen-border-bottom);
  border-radius: var(--sg-type-specimen-radius);
  padding: var(--sg-type-specimen-padding);
  margin: var(--sg-type-specimen-margin);
}
.sg-type-specimen .font-mono.font-bold {
  color: var(--sg-type-specimen-name-color);
  font-family: var(--sg-type-specimen-name-font);
}

/* ─── Subsection Title ─── */
.sg-subsection-title,
.sg-subsection {
  font-family: var(--micro-label-font-family);
  font-size: var(--micro-label-font-size);
  font-weight: var(--micro-label-font-weight);
  text-transform: var(--micro-label-text-transform);
  letter-spacing: var(--micro-label-letter-spacing);
  color: var(--text-muted);
  margin-bottom: var(--space-2);
  margin-top: var(--space-4);
  padding-bottom: var(--space-1);
  border-bottom: var(--sg-border);
}

/* ─── Section Groups ─── */
.sg-group {
  margin-top: var(--space-8);
  padding-top: var(--space-8);
  border-top: var(--sg-border);
}
.sg-group:first-child, .sg-group:first-of-type {
  border-top: none;
  padding-top: 0;
}
.sg-group-header {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  cursor: pointer;
  user-select: none;
  padding-bottom: var(--space-2);
  margin-bottom: 0;
}
.sg-group-label {
  font-family: var(--micro-label-font-family);
  font-size: var(--micro-label-font-size);
  font-weight: var(--micro-label-font-weight);
  text-transform: var(--micro-label-text-transform);
  letter-spacing: var(--letter-spacing-widest);
  color: var(--text-muted);
  white-space: nowrap;
}
.sg-group-line {
  flex: 1;
  height: var(--border-thick);
  background: var(--text-muted);
}
.sg-group-toggle {
  font-size: var(--font-size-xs);
  color: var(--text-muted);
  transition: transform var(--transition-medium) ease;
  display: inline-flex;
  align-items: center;
}
.sg-group-contents {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: var(--sg-group-content-gap);
}
.sg-group-content-item {
  font-family: var(--micro-label-font-family);
  font-size: var(--micro-label-font-size);
  color: var(--text-muted);
  padding: var(--sg-group-content-padding);
  border: var(--sg-border);
  white-space: nowrap;
  letter-spacing: 0.03em;
  transition: color var(--transition-fast), border-color var(--transition-fast);
}
.sg-group-header:hover .sg-group-content-item {
  color: var(--text-secondary);
  border-color: var(--border-strong);
}
.sg-group-content-item .sg-group-item-num {
  color: var(--border);
  margin-right: var(--sg-group-item-margin-right);
}

/* ─── Showcase Utilities ─── */

/* Section head label — used above subsections (e.g. "UI Glyphs", "Typography") */
.sg-section-head {
  font-family: var(--micro-label-font-family);
  font-size: var(--font-size-sm);
  font-weight: var(--micro-label-font-weight);
  letter-spacing: var(--letter-spacing-label);
  text-transform: var(--micro-label-text-transform);
  color: var(--text-muted);
  margin-bottom: var(--space-2);
}

/* Principle row — 3-col flex: label | text */
.sg-principle-row {
  display: flex;
  gap: var(--space-3);
  align-items: baseline;
}
.sg-principle-label {
  font-size: var(--font-size-sm);
  font-family: var(--micro-label-font-family);
  font-weight: var(--micro-label-font-weight);
  letter-spacing: var(--sg-section-number-letter-spacing);
  text-transform: var(--micro-label-text-transform);
  white-space: nowrap;
  min-width: var(--sg-principle-label-width);
  padding-top: var(--sg-hairline);
  flex-shrink: 0;
}
.sg-principle-text {
  font-size: var(--font-size-sm);
  line-height: var(--line-height-relaxed);
  color: var(--text);
  margin: 0;
}
.sg-principle-text.muted {
  color: var(--text-secondary);
  font-style: italic;
}

/* ─── Principle Label Colors ─── */
.text-principle { color: var(--brand-red); }
.text-approach  { color: var(--text-muted); }
.text-why       { color: var(--brand-blue); }
.dark .text-principle { color: color-mix(in srgb, var(--brand-red) 75%, white); }
.dark .text-why       { color: color-mix(in srgb, var(--brand-blue) 75%, white); }

/* Demo container — gray-50 box with border */
.sg-demo-box {
  padding: var(--space-3);
  background: var(--surface-alt);
  border: var(--sg-border);
}

/* ─── Anchor Headings ─── */
.sg-anchor-heading {
  cursor: pointer;
  display: flex;
  align-items: baseline;
  gap: var(--space-1);
}
.sg-anchor-heading-icon {
  font-size: var(--font-size-lg);
  user-select: none;
}

/* Section description text */
.sg-description {
  font-size: var(--font-size-sm);
  color: var(--text-muted);
  margin-bottom: var(--space-2);
  max-width: var(--sg-description-max-width);
  line-height: var(--line-height-relaxed);
}

/* ─── Preview / Code Toggle ─── */
.sg-preview-code {
  border: var(--sg-border);
  margin-bottom: var(--space-3);
}
.sg-preview-code-tabs {
  display: flex;
  align-items: center;
  gap: 0;
  border-bottom: var(--sg-border);
  background: var(--surface-alt);
}
.sg-preview-code-tab {
  font-family: var(--micro-label-font-family);
  font-size: var(--micro-label-font-size);
  font-weight: var(--font-weight-semibold);
  text-transform: var(--micro-label-text-transform);
  letter-spacing: var(--letter-spacing-label);
  padding: var(--space-1) var(--space-2);
  background: none;
  border: none;
  border-bottom: var(--border-thick) solid transparent;
  color: var(--text-muted);
  cursor: pointer;
  transition: color var(--transition-base) ease, border-color var(--transition-base) ease;
}
.sg-preview-code-tab:hover {
  color: var(--text-secondary);
}
.sg-preview-code-tab.active {
  color: var(--text);
  border-bottom-color: var(--text);
}
.sg-preview-code-copy {
  margin-left: auto;
  font-family: var(--micro-label-font-family);
  font-size: var(--micro-label-font-size);
  font-weight: var(--font-weight-semibold);
  padding: var(--space-half) var(--space-1);
  margin-right: var(--space-1);
  background: var(--surface);
  border: var(--sg-border);
  color: var(--text-muted);
  cursor: pointer;
}
.sg-preview-code-copy:hover {
  color: var(--text);
  border-color: var(--border-strong);
}
.sg-preview-code-preview {
  padding: var(--space-3);
  background: var(--surface);
}

/* ─── Screen Frame Mockups ─── */
.screen-frame {
  background: var(--surface);
  border: var(--border-thick) solid var(--text);
  overflow: hidden;
  margin-bottom: var(--space-4);
  box-shadow: var(--sg-screen-shadow);
}
.screen-titlebar {
  background: var(--surface-inverse);
  padding: var(--size-2xs) var(--size-space-2);
  display: flex;
  align-items: center;
  gap: var(--space-1);
}
.screen-dot {
  width: var(--size-2xs);
  height: var(--size-2xs);
  border-radius: var(--radius-circle);
  background: var(--border-strong);
}
.screen-dot:first-child { background: var(--brand-red); }
.screen-dot:nth-child(2) { background: var(--brand-yellow); }
.screen-dot:nth-child(3) { background: var(--success); }
.screen-url {
  font-family: var(--micro-label-font-family);
  font-size: var(--micro-label-font-size);
  color: var(--text-muted);
  margin-left: var(--space-1);
  background: var(--surface-alt);
  padding: var(--border-heavy) var(--space-1-mid);
  flex: 1;
  max-width: var(--sg-screen-url-max-width);
}
.screen-body {
  padding: 0;
  aspect-ratio: 16 / 9;
  display: flex;
  align-items: stretch;
  background: var(--surface);
  color: var(--text);
}
.screen-body > * {
  width: 100%;
  height: 100%;
}
.screen-label {
  font-family: var(--micro-label-font-family);
  font-size: var(--font-size-2xs);
  font-weight: var(--font-weight-semibold);
  text-transform: var(--micro-label-text-transform);
  letter-spacing: var(--letter-spacing-wider);
  color: var(--text-muted);
  margin-bottom: var(--space-1);
}

/* ─── Color Mode Toggle ─── */
.sg-mode-toggle {
  display: inline-flex;
  border: 1px solid transparent;
  border-radius: var(--radius-md);
  overflow: hidden;
}
.sg-mode-toggle-option {
  font-family: var(--micro-label-font-family);
  font-size: var(--micro-label-font-size);
  font-weight: var(--font-weight-medium);
  padding: var(--space-half) var(--space-2);
  background: transparent;
  color: color-mix(in srgb, var(--text-inverse) 60%, transparent);
  border: none;
  cursor: pointer;
  transition: color var(--transition-base) ease, background var(--transition-base) ease;
  white-space: nowrap;
}
.sg-mode-toggle-left { border-radius: var(--radius-md) 0 0 var(--radius-md); }
.sg-mode-toggle-right { border-radius: 0 var(--radius-md) var(--radius-md) 0; }
.sg-mode-toggle-option:hover {
  color: var(--text-inverse);
}
.sg-mode-toggle-active {
  background: color-mix(in srgb, var(--text-inverse) 15%, transparent);
  color: var(--text-inverse);
  font-weight: var(--font-weight-bold);
}

/* ─── Floating Controls Wrapper ─── */
.sg-floating-controls {
  position: fixed;
  bottom: var(--space-3);
  left: 50%;
  transform: translateX(-50%);
  z-index: var(--z-floating);
  display: flex;
  align-items: center;
  gap: var(--space-2);
}

/* ─── Floating Layout Bar ─── */
.sg-layout-bar,
.sg-mode-bar {
  background: var(--surface-inverse);
  color: var(--text-inverse);
  border: 1px solid transparent;
  box-shadow: var(--shadow-floating);
  border-radius: var(--radius-md);
  padding: var(--space-half);
}
.sg-layout-bar-group {
  display: flex;
  gap: var(--space-quarter);
}
.sg-layout-bar-option {
  font-family: var(--micro-label-font-family);
  font-size: var(--micro-label-font-size);
  font-weight: var(--font-weight-medium);
  padding: var(--space-1) var(--space-2);
  border-radius: var(--radius-md);
  border: none;
  background: transparent;
  color: color-mix(in srgb, var(--text-inverse) 60%, transparent);
  cursor: pointer;
  transition: color var(--transition-base) ease, background var(--transition-base) ease;
  white-space: nowrap;
}
.sg-layout-bar-option:hover {
  color: var(--text-inverse);
  background: color-mix(in srgb, var(--text-inverse) 10%, transparent);
}
.sg-layout-bar-option[data-checked] {
  color: var(--text-inverse);
  background: color-mix(in srgb, var(--text-inverse) 15%, transparent);
  font-weight: var(--font-weight-bold);
}
.sg-mode-active-light {
  background: var(--white) !important;
  color: var(--black) !important;
  border-radius: var(--radius-md);
}
.sg-mode-active-dark {
  background: var(--black) !important;
  color: var(--white) !important;
  border-radius: var(--radius-md);
}`;
}
