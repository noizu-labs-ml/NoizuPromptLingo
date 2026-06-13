import type { StyleGuideConfig } from "../types";

export function generateHUIInteractiveCSS(_config: StyleGuideConfig): string {
  return `/* ═══════════════════════════════════════
   HEADLESS UI — INTERACTIVE COMPONENTS
   All values driven by --hui-* vars (see style-guide.vars.yaml)
   Namespace: .hui.X (components), .sub-element (children)
   ═══════════════════════════════════════ */

/* ─── Tabs ─── */
.hui.tab-list {
  display: flex;
  border-bottom: var(--hui-tab-list-border-width) solid var(--hui-tab-list-border);
}
.hui.tab {
  padding: var(--hui-tab-padding-y) var(--hui-tab-padding-x);
  font-family: var(--font-sans);
  font-size: var(--hui-tab-font-size);
  font-weight: var(--hui-tab-font-weight);
  color: var(--hui-tab-color);
  border: none;
  border-bottom: var(--hui-tab-indicator-width) solid transparent;
  margin-bottom: var(--hui-tab-indicator-offset);
  background: transparent;
  cursor: pointer;
  outline: none;
  transition: var(--hui-tab-transition);
  white-space: nowrap;
}
.hui.tab[data-selected] {
  color: var(--hui-tab-color-selected);
  border-bottom-color: var(--hui-tab-border-selected);
  font-weight: var(--hui-tab-font-weight-selected);
}
.hui.tab[data-hover]:not([data-selected]) { color: var(--hui-tab-color-hover); }
.hui.tab[data-focus] {
  border-radius: var(--radius) var(--radius) 0 0;
  box-shadow: inset 0 0 0 var(--hui-focus-ring-width) var(--hui-focus-ring-color);
}
.hui.tab-panel {
  padding: var(--space-3) 0;
  font-size: var(--font-size-sm);
  color: var(--hui-tab-panel-color);
  outline: none;
}

/* ─── Menu (Dropdown) ─── */
.hui.menu-btn {
  display: inline-flex;
  align-items: center;
  gap: var(--hui-trigger-gap);
  padding: var(--hui-trigger-padding-y) var(--hui-trigger-padding-x);
  font-family: var(--font-sans);
  font-size: var(--hui-trigger-font-size);
  font-weight: var(--hui-trigger-font-weight);
  color: var(--hui-trigger-color);
  background: var(--hui-trigger-bg);
  border: var(--hui-trigger-border-width) solid var(--hui-trigger-border);
  border-radius: var(--radius);
  cursor: pointer;
  outline: none;
  transition: var(--hui-trigger-transition);
}
.hui.menu-btn[data-open],
.hui.menu-btn[data-hover] { border-color: var(--hui-trigger-border-hover); }
.hui.menu-btn[data-focus] {
  box-shadow: 0 0 0 var(--hui-focus-ring-width) var(--hui-focus-ring-color);
  border-color: var(--hui-field-focus-border);
}
.hui.menu-items {
  position: absolute;
  z-index: var(--hui-panel-z-index);
  min-width: var(--hui-menu-min-width);
  background: var(--hui-panel-bg);
  border: var(--hui-panel-border-width) solid var(--hui-panel-border);
  border-radius: var(--radius);
  box-shadow: var(--hui-panel-shadow);
  padding: var(--hui-panel-padding);
  outline: none;
  margin-top: var(--hui-panel-margin-top);
}
.hui.menu-item {
  display: flex;
  align-items: center;
  gap: var(--hui-panel-item-gap);
  padding: var(--hui-panel-item-padding-y) var(--hui-panel-item-padding-x);
  font-size: var(--hui-panel-item-font-size);
  color: var(--hui-panel-item-color);
  border-radius: calc(var(--radius) - var(--hui-panel-item-radius-inset));
  cursor: pointer;
  outline: none;
  user-select: none;
  transition: var(--hui-panel-item-transition);
}
.hui.menu-item[data-active] {
  background: var(--hui-panel-item-active-bg);
  color: var(--hui-panel-item-active-color);
}
.hui.menu-item[data-disabled] { opacity: var(--hui-panel-item-disabled-opacity); cursor: default; }
.hui.menu-sep {
  height: var(--hui-panel-sep-height);
  background: var(--hui-panel-sep-color);
  margin: var(--hui-panel-sep-margin-y) 0;
}

/* ─── Disclosure ─── */
.hui.disclosure-btn {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  padding: var(--hui-disclosure-padding-y) var(--hui-disclosure-padding-x);
  font-family: var(--font-sans);
  font-size: var(--hui-disclosure-font-size);
  font-weight: var(--hui-disclosure-font-weight);
  color: var(--hui-disclosure-color);
  background: var(--hui-disclosure-bg);
  border: var(--hui-disclosure-border-width) solid var(--hui-disclosure-border);
  border-radius: var(--radius);
  cursor: pointer;
  outline: none;
  transition: var(--hui-disclosure-transition);
  text-align: left;
}
.hui.disclosure-btn[data-hover] { background: var(--hui-disclosure-bg-hover); }
.hui.disclosure-btn[data-focus] {
  box-shadow: 0 0 0 var(--hui-focus-ring-width) var(--hui-focus-ring-color);
  border-color: var(--hui-field-focus-border);
}
.hui.disclosure-btn[data-open] {
  background: var(--hui-disclosure-bg-hover);
  border-radius: var(--radius) var(--radius) 0 0;
}
.disclosure-chevron {
  width: var(--hui-disclosure-chevron-size);
  height: var(--hui-disclosure-chevron-size);
  color: var(--hui-disclosure-chevron-color);
  transition: var(--hui-disclosure-chevron-transition);
  flex-shrink: 0;
}
.hui.disclosure-btn[data-open] .disclosure-chevron { transform: rotate(180deg); }
.hui.disclosure-panel {
  padding: var(--hui-disclosure-padding-y) var(--hui-disclosure-padding-x);
  font-size: var(--hui-disclosure-font-size);
  color: var(--hui-disclosure-panel-color);
  background: var(--hui-disclosure-panel-bg);
  border: var(--hui-disclosure-border-width) solid var(--hui-disclosure-border);
  border-top: none;
  border-radius: 0 0 var(--radius) var(--radius);
  line-height: var(--hui-disclosure-panel-line-height);
}

/* ─── Listbox ─── */
.hui.listbox-wrap { position: relative; }
.hui.listbox-btn {
  display: flex;
  align-items: center;
  position: relative;
  width: 100%;
  height: var(--hui-field-height);
  padding: 0 var(--hui-field-icon-area) 0 var(--hui-field-padding-x);
  font-family: var(--font-sans);
  font-size: var(--hui-field-font-size);
  color: var(--hui-field-color);
  background: var(--hui-field-bg);
  border: var(--hui-field-border-width) solid var(--hui-field-border);
  border-radius: var(--radius);
  cursor: pointer;
  outline: none;
  box-shadow: var(--hui-field-shadow);
  transition: var(--hui-field-transition);
  text-align: left;
  box-sizing: border-box;
}
.hui.listbox-btn::after {
  content: "";
  position: absolute;
  right: var(--hui-field-chevron-offset);
  top: 50%;
  width: var(--hui-field-chevron-size);
  height: var(--hui-field-chevron-size);
  border-right: var(--hui-field-chevron-border-width) solid var(--hui-field-chevron-color);
  border-bottom: var(--hui-field-chevron-border-width) solid var(--hui-field-chevron-color);
  transform: translateY(-75%) rotate(45deg);
  pointer-events: none;
}
.hui.listbox-btn[data-hover]:not([data-open]) { border-color: var(--hui-field-border-hover); }
.hui.listbox-btn[data-open] {
  border-color: var(--hui-field-focus-border);
  box-shadow: 0 0 0 var(--hui-focus-ring-width) var(--hui-focus-ring-color), var(--hui-field-shadow);
}
.hui.listbox-options {
  position: absolute;
  z-index: var(--hui-panel-z-index);
  width: 100%;
  background: var(--hui-panel-bg);
  border: var(--hui-panel-border-width) solid var(--hui-panel-border);
  border-radius: var(--radius);
  box-shadow: var(--hui-panel-shadow);
  padding: var(--hui-panel-padding);
  outline: none;
  margin-top: var(--hui-panel-margin-top);
  max-height: var(--hui-panel-max-height);
  overflow-y: auto;
}
.hui.listbox-option {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--hui-panel-item-padding-y) var(--hui-panel-item-padding-x);
  font-size: var(--hui-panel-item-font-size);
  color: var(--hui-panel-item-color);
  border-radius: calc(var(--radius) - var(--hui-panel-item-radius-inset));
  cursor: pointer;
  outline: none;
  user-select: none;
}
.hui.listbox-option[data-active] {
  background: var(--hui-panel-item-active-bg);
  color: var(--hui-panel-item-active-color);
}
.hui.listbox-option[data-selected] { font-weight: var(--hui-panel-item-selected-weight); }

/* ─── Combobox ─── */
.hui.combo-wrap { position: relative; }
.hui.combo-input {
  display: block;
  width: 100%;
  height: var(--hui-field-height);
  padding: 0 var(--hui-combo-icon-area) 0 var(--hui-field-padding-x);
  font-family: var(--font-sans);
  font-size: var(--hui-field-font-size);
  color: var(--hui-field-color);
  background: var(--hui-field-bg);
  border: var(--hui-field-border-width) solid var(--hui-field-border);
  border-radius: var(--radius);
  outline: none;
  box-shadow: var(--hui-field-shadow);
  transition: var(--hui-field-transition);
  box-sizing: border-box;
}
.hui.combo-input::placeholder { color: var(--hui-combo-placeholder-color); }
.hui.combo-input:focus {
  border-color: var(--hui-field-focus-border);
  box-shadow: 0 0 0 var(--hui-focus-ring-width) var(--hui-focus-ring-color), var(--hui-field-shadow);
}
.hui.combo-btn {
  position: absolute;
  right: 0; top: 0; bottom: 0;
  width: var(--hui-combo-icon-area);
  display: flex;
  align-items: center;
  justify-content: center;
  background: transparent;
  border: none;
  cursor: pointer;
  color: var(--hui-combo-btn-color);
  outline: none;
}
.hui.combo-options {
  position: absolute;
  z-index: var(--hui-panel-z-index);
  width: 100%;
  background: var(--hui-panel-bg);
  border: var(--hui-panel-border-width) solid var(--hui-panel-border);
  border-radius: var(--radius);
  box-shadow: var(--hui-panel-shadow);
  padding: var(--hui-panel-padding);
  outline: none;
  margin-top: var(--hui-panel-margin-top);
  max-height: var(--hui-panel-max-height);
  overflow-y: auto;
}
.hui.combo-option {
  padding: var(--hui-panel-item-padding-y) var(--hui-panel-item-padding-x);
  font-size: var(--hui-panel-item-font-size);
  color: var(--hui-panel-item-color);
  border-radius: calc(var(--radius) - var(--hui-panel-item-radius-inset));
  cursor: pointer;
  outline: none;
  user-select: none;
}
.hui.combo-option[data-active] {
  background: var(--hui-panel-item-active-bg);
  color: var(--hui-panel-item-active-color);
}
.hui.combo-option[data-selected] { font-weight: var(--hui-panel-item-selected-weight); }

/* ─── Popover ─── */
.hui.popover-wrap { position: relative; display: inline-block; }
.hui.popover-btn {
  display: inline-flex;
  align-items: center;
  gap: var(--hui-trigger-gap);
  padding: var(--hui-trigger-padding-y) var(--hui-trigger-padding-x);
  font-family: var(--font-sans);
  font-size: var(--hui-trigger-font-size);
  font-weight: var(--hui-trigger-font-weight);
  color: var(--hui-trigger-color);
  background: var(--hui-trigger-bg);
  border: var(--hui-trigger-border-width) solid var(--hui-trigger-border);
  border-radius: var(--radius);
  cursor: pointer;
  outline: none;
  transition: var(--hui-trigger-transition);
}
.hui.popover-btn[data-hover] { border-color: var(--hui-trigger-border-hover); }
.hui.popover-btn[data-open] {
  border-color: var(--hui-field-focus-border);
  box-shadow: 0 0 0 var(--hui-focus-ring-width) var(--hui-focus-ring-color);
}
.hui.popover-panel {
  position: absolute;
  z-index: var(--hui-panel-z-index);
  background: var(--hui-panel-bg);
  border: var(--hui-panel-border-width) solid var(--hui-panel-border);
  border-radius: var(--radius);
  box-shadow: var(--hui-panel-shadow);
  padding: var(--hui-popover-padding);
  min-width: var(--hui-popover-min-width);
  margin-top: var(--hui-panel-margin-top);
}

/* ─── Dialog ─── */
.hui.dialog-backdrop {
  position: fixed;
  inset: 0;
  background: var(--hui-dialog-backdrop);
  z-index: var(--hui-dialog-backdrop-z-index);
}
.hui.dialog-positioner {
  position: fixed;
  inset: 0;
  z-index: var(--hui-dialog-z-index);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--hui-dialog-positioner-padding);
}
.hui.dialog-panel {
  background: var(--hui-dialog-bg);
  border-radius: var(--radius);
  box-shadow: var(--hui-dialog-shadow);
  padding: var(--hui-dialog-padding);
  max-width: var(--hui-dialog-max-width);
  width: 100%;
}
.hui.dialog-title {
  font-size: var(--font-size-md);
  font-weight: var(--hui-dialog-title-weight);
  color: var(--hui-dialog-title-color);
  margin-bottom: var(--space-2);
}
.hui.dialog-body {
  font-size: var(--font-size-sm);
  color: var(--hui-dialog-body-color);
  line-height: var(--hui-dialog-body-line-height);
  margin-bottom: var(--space-4);
}
.hui.dialog-actions {
  display: flex;
  justify-content: flex-end;
  gap: var(--space-2);
}

/* ─── Checkbox ─── */
.hui.checkbox-wrap {
  display: flex;
  align-items: center;
  gap: var(--hui-control-gap);
  cursor: pointer;
  user-select: none;
}
.checkbox-visual {
  width: var(--hui-control-size);
  height: var(--hui-control-size);
  flex-shrink: 0;
  border-radius: var(--hui-checkbox-radius);
  border: var(--hui-control-border-width) solid var(--hui-control-border);
  background: var(--hui-control-bg);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: var(--hui-control-transition);
  box-shadow: var(--hui-control-shadow);
}
.hui.checkbox-wrap[data-checked] .checkbox-visual {
  background: var(--hui-control-color);
  border-color: var(--hui-control-color);
  box-shadow: none;
}
.checkbox-label {
  font-size: var(--font-size-sm);
  color: var(--hui-control-label-color);
}

/* ─── Switch ─── */
.hui.switch-wrap {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--hui-switch-gap);
  cursor: pointer;
}
.switch-label {
  font-size: var(--font-size-sm);
  color: var(--hui-control-label-color);
  user-select: none;
}
.switch-track {
  width: var(--hui-switch-track-width);
  height: var(--hui-switch-track-height);
  border-radius: var(--hui-switch-track-radius);
  flex-shrink: 0;
  background: var(--hui-switch-track-off-bg);
  position: relative;
  transition: var(--hui-switch-track-transition);
}
.hui.switch-wrap[data-checked] .switch-track {
  background: var(--hui-switch-track-on-bg);
}
.switch-thumb {
  width: var(--hui-switch-thumb-size);
  height: var(--hui-switch-thumb-size);
  border-radius: var(--hui-switch-thumb-radius);
  background: var(--hui-switch-thumb-bg);
  position: absolute;
  top: var(--hui-switch-thumb-inset);
  left: var(--hui-switch-thumb-inset);
  box-shadow: var(--hui-switch-thumb-shadow);
  transition: var(--hui-switch-thumb-transition);
}
.hui.switch-wrap[data-checked] .switch-thumb {
  left: calc(var(--hui-switch-track-width) - var(--hui-switch-thumb-size) - var(--hui-switch-thumb-inset));
}

/* ─── Radio ─── */
.hui.radio-option {
  display: flex;
  align-items: center;
  gap: var(--hui-control-gap);
  cursor: pointer;
  padding: var(--hui-radio-option-padding-y) var(--hui-radio-option-padding-x);
  border: var(--hui-radio-border-width) solid var(--hui-radio-option-border);
  background: var(--hui-control-bg);
  transition: var(--hui-radio-transition);
  user-select: none;
}
.hui.radio-option[data-checked] {
  border-color: var(--hui-radio-option-border-active);
  background: var(--hui-radio-option-bg-active);
}
.radio-dot {
  width: var(--hui-radio-dot-size);
  height: var(--hui-radio-dot-size);
  border-radius: var(--hui-radio-dot-radius);
  flex-shrink: 0;
  border: var(--hui-control-border-width) solid var(--hui-control-border);
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--hui-control-bg);
  transition: var(--hui-control-transition);
}
.hui.radio-option[data-checked] .radio-dot {
  border-color: var(--hui-control-color);
}
.radio-dot-inner {
  display: none;
  width: var(--hui-radio-dot-inner-size);
  height: var(--hui-radio-dot-inner-size);
  border-radius: var(--hui-radio-dot-inner-radius);
  background: var(--hui-control-color);
}
.hui.radio-option[data-checked] .radio-dot-inner {
  display: block;
}
.radio-label {
  font-size: var(--font-size-sm);
  color: var(--hui-control-label-color);
}

/* ─── Showcase grid ─── */
.hui.showcase {
  border-radius: var(--radius);
  border: var(--hui-showcase-border-width) solid var(--hui-showcase-border);
  border-top: var(--hui-showcase-accent-width) solid var(--hui-showcase-accent);
  background: var(--hui-showcase-bg);
}
.hui.showcase-grid {
  display: flex;
  flex-wrap: wrap;
  gap: var(--hui-showcase-grid-gap);
}
.hui.showcase-grid > .hui.showcase-cell {
  flex: 1 1 280px;
  max-width: 100%;
}
.hui.showcase-cell {
  padding: var(--hui-showcase-cell-padding);
  display: flex;
  flex-direction: column;
  min-height: var(--hui-showcase-cell-min-height);
  background: var(--hui-showcase-cell-bg);
  overflow: visible;
}
.showcase-cell-name {
  font-family: var(--font-mono);
  font-size: var(--hui-showcase-label-font-size);
  font-weight: var(--hui-showcase-label-weight);
  letter-spacing: var(--hui-showcase-label-letter-spacing);
  text-transform: uppercase;
  color: var(--hui-showcase-label-color);
  padding-bottom: var(--hui-showcase-label-padding-bottom);
  border-bottom: var(--hui-showcase-label-border-width) solid var(--hui-showcase-cell-border);
  margin-bottom: var(--space-2);
  flex-shrink: 0;
}
.showcase-cell-content { flex: 1; overflow: visible; }
`;
}
