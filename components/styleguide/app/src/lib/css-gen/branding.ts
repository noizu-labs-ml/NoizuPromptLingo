import type { StyleGuideConfig } from "../types";

export function generateBrandingCSS(_config: StyleGuideConfig): string {
  return `/* ═══════════════════════════════════════
   PRODUCT BRANDING
   Layout handled by Tailwind classes on the component.
   ═══════════════════════════════════════ */
.product-branding {
  border: var(--branding-border);
  margin-bottom: var(--space-8);
}
.product-branding-logo {
  background: var(--branding-logo-bg);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-6);
  min-height: var(--space-25);
}
.product-branding-logo svg {
  max-width: var(--branding-logo-max-width);
  max-height: var(--branding-logo-max-height);
}
.product-branding-logo-placeholder {
  width: var(--branding-placeholder-width);
  height: var(--branding-placeholder-height);
  border: var(--branding-placeholder-border);
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: var(--micro-label-font-family);
  font-size: var(--micro-label-font-size);
  color: var(--micro-label-color);
  text-transform: var(--micro-label-text-transform);
  letter-spacing: var(--micro-label-letter-spacing);
}
.product-branding-content {
  padding: var(--space-4);
}
.product-branding-name {
  font-size: var(--branding-name-font-size);
  font-weight: var(--branding-name-font-weight);
  letter-spacing: var(--branding-name-letter-spacing);
  margin-bottom: var(--space-3);
  padding-bottom: var(--space-2);
  border-bottom: var(--branding-name-border);
}
.product-branding-field-label {
  font-family: var(--micro-label-font-family);
  font-size: var(--micro-label-font-size);
  font-weight: var(--micro-label-font-weight);
  text-transform: var(--micro-label-text-transform);
  letter-spacing: var(--micro-label-letter-spacing);
  color: var(--micro-label-color);
  margin-bottom: var(--size-dot);
}
.product-branding-field-value {
  font-size: var(--branding-field-value-font-size);
  line-height: var(--branding-field-value-line-height);
  color: var(--branding-field-value-color);
}
.product-branding-tags {
  display: flex;
  flex-wrap: wrap;
  gap: var(--branding-keyword-gap);
  margin-top: var(--branding-keyword-margin-top);
}
.product-branding-tag {
  font-family: var(--micro-label-font-family);
  font-size: var(--micro-label-font-size);
  font-weight: var(--font-weight-medium);
  padding: var(--branding-keyword-padding);
  border: var(--branding-keyword-border);
  color: var(--branding-keyword-color);
}`;
}
