import type { StyleGuideConfig } from "../types";

export function generateButtonCSS(_config: StyleGuideConfig): string {
  return `/* ═══════════════════════════════════════
   BUTTONS
   ═══════════════════════════════════════ */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-1);
  padding: var(--btn-padding-y) var(--btn-padding-x);
  font-family: var(--btn-font-family);
  font-size: var(--btn-font-size);
  font-weight: var(--btn-font-weight);
  line-height: var(--btn-line-height);
  letter-spacing: var(--btn-letter-spacing);
  background: var(--btn-background);
  color: var(--btn-color);
  border: var(--btn-border-width) var(--btn-border-style) var(--btn-border-color);
  cursor: pointer;
  transition: all var(--btn-transition);
  text-decoration: none;
  white-space: nowrap;
  user-select: none;
}
.btn:hover {
  background: var(--btn-hover-background);
  border-color: var(--btn-hover-border-color);
}
.btn:active {
  transform: translateY(var(--btn-active-offset));
}
.btn:focus-visible {
  outline: var(--hui-focus-ring-width) solid var(--brand-blue);
  outline-offset: var(--space-quarter);
}

/* Size modifiers */
.btn.btn-sm {
  font-size: var(--btn-sm-font-size);
  padding: var(--btn-sm-padding-y) var(--btn-sm-padding-x);
}
.btn.btn-lg {
  font-size: var(--btn-lg-font-size);
  padding: var(--btn-lg-padding-y) var(--btn-lg-padding-x);
}
.btn.btn-xl {
  font-size: var(--btn-xl-font-size);
  padding: var(--btn-xl-padding-y) var(--btn-xl-padding-x);
}

/* Outline modifier */
.btn.btn-outline {
  background: var(--btn-outline-background);
  color: var(--btn-outline-color);
}
.btn.btn-outline:hover {
  background: var(--btn-outline-hover-background);
}

/* Ghost modifier */
.btn.btn-ghost {
  background: transparent;
  border-color: transparent;
  color: var(--btn-outline-color);
}
.btn.btn-ghost:hover {
  background: var(--btn-outline-hover-background);
}

/* Composable modifiers */
.btn.rounded {
  border-radius: var(--btn-rounded-radius);
}
.btn.drop-shadow {
  box-shadow: var(--btn-drop-shadow);
}

/* Selected state animation keyframe */
@keyframes btn-selected-gradient {
  0%   { background-position: 0% 50%; }
  50%  { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}`;
}
