import type { StyleGuideConfig } from "../types";

export function generateTokenCSS(_config: StyleGuideConfig): string {
  return `/* ═══════════════════════════════════════
   TOKEN CARDS
   ═══════════════════════════════════════ */
.token-grid {
  display: flex;
  flex-wrap: wrap;
  gap: var(--token-grid-gap);
  align-items: flex-start;
}
.token-card {
  background: var(--token-card-background);
  border: var(--token-card-border);
  padding: var(--token-card-padding);
  min-width: var(--token-grid-min-width);
  flex: 1 1 var(--token-grid-min-width);
  overflow: hidden;
}
.token-card-title {
  font-size: var(--token-card-title-font-size);
  font-weight: var(--token-card-title-font-weight);
  text-transform: var(--token-card-title-text-transform);
  letter-spacing: var(--token-card-title-letter-spacing);
  color: var(--token-card-title-color);
  margin-bottom: var(--token-card-title-margin-bottom);
  padding-bottom: var(--token-card-title-padding-bottom);
  border-bottom: var(--token-card-title-border-bottom);
}
.token-row {
  display: flex;
  align-items: center;
  gap: var(--token-row-gap);
  padding: var(--token-row-padding);
  font-family: var(--token-row-font-family);
  font-size: var(--token-row-font-size);
  overflow: hidden;
}
.token-name { color: var(--token-name-color); flex: 1; white-space: nowrap; }
.token-value { color: var(--token-value-color); font-weight: var(--token-value-font-weight); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.token-preview { display: inline-block; flex-shrink: 0; white-space: nowrap; }
.token-preview--color { width: var(--token-preview-color-size); height: var(--token-preview-color-size); border: var(--token-preview-color-border); }
.token-preview--font { font-size: var(--token-preview-font-size); color: var(--token-value-color); }
.token-preview--space { background: var(--token-value-color); max-width: var(--token-preview-space-max-width); max-height: var(--token-preview-space-max-height); }
.token-preview--radius { width: var(--token-preview-radius-size); height: var(--token-preview-radius-size); border: var(--token-preview-radius-border); }
.token-preview--shadow { width: 24px; height: 24px; background: var(--token-card-background); }
.token-preview--size { line-height: 1; color: var(--token-value-color); }`;
}
