import type { StyleGuideConfig } from "../types";

export function generateFormsCSS(_config: StyleGuideConfig): string {
  return `/* ═══════════════════════════════════════
   FORM CONTROLS  (HUI-compatible)
   ═══════════════════════════════════════ */

/* ─── Field group ─── */
.field-group {
  display: flex;
  flex-direction: column;
  gap: var(--field-label-gap);
}

/* ─── Label ─── */
.field-label {
  display: block;
  font-family: var(--font-mono);
  font-size: var(--field-label-font-size);
  font-weight: var(--field-label-font-weight);
  letter-spacing: var(--field-label-letter-spacing);
  text-transform: uppercase;
  color: var(--text-secondary);
  user-select: none;
}

/* ─── Base controls ─── */
.field-input,
.field-select,
.field-textarea {
  display: block;
  width: 100%;
  box-sizing: border-box;
  font-family: var(--font-sans);
  font-size: var(--field-font-size);
  font-weight: var(--font-weight-normal);
  color: var(--text);
  background: var(--field-bg);
  border: var(--field-border-width) solid var(--field-border-color);
  border-radius: var(--radius);
  outline: none;
  box-shadow: var(--field-shadow);
  transition: var(--field-transition);
}

.field-input  { height: var(--field-height); padding: 0 var(--field-padding-x); }
.field-select { height: var(--field-height); padding: 0 var(--field-select-padding-right) 0 var(--field-padding-x); }
.field-textarea {
  padding: var(--field-textarea-padding);
  min-height: var(--field-textarea-min-height);
  resize: none;
  line-height: var(--field-textarea-line-height);
}

/* ─── Hover ─── */
.field-input:hover:not(:focus):not(.field-error):not(.field-warning):not(.field-success),
.field-select:hover:not(:focus):not(.field-error):not(.field-warning):not(.field-success),
.field-textarea:hover:not(:focus):not(.field-error):not(.field-warning):not(.field-success) {
  border-color: var(--border-strong);
}

/* ─── Focus ─── */
.field-input:focus,
.field-select:focus,
.field-textarea:focus {
  border-color: var(--brand-blue);
  box-shadow:
    var(--field-focus-ring),
    var(--field-shadow);
}

/* ─── Placeholder ─── */
.field-input::placeholder,
.field-textarea::placeholder {
  color: var(--text-muted);
  font-weight: var(--font-weight-normal);
}

/* ─── Validation: inset left bar + tinted bg ─── */
.field-input.field-error,
.field-select.field-error,
.field-textarea.field-error {
  border-color: var(--error);
  background: color-mix(in srgb, var(--error-tint) 55%, var(--surface));
  box-shadow: inset var(--field-validation-bar-width) 0 0 0 var(--error);
}
.field-input.field-warning,
.field-select.field-warning,
.field-textarea.field-warning {
  border-color: var(--warning);
  background: color-mix(in srgb, var(--warning-tint) 55%, var(--surface));
  box-shadow: inset var(--field-validation-bar-width) 0 0 0 var(--warning);
}
.field-input.field-success,
.field-select.field-success,
.field-textarea.field-success {
  border-color: var(--success);
  background: color-mix(in srgb, var(--success-tint) 55%, var(--surface));
  box-shadow: inset var(--field-validation-bar-width) 0 0 0 var(--success);
}

/* ─── Select chevron ─── */
.field-select {
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='7' viewBox='0 0 12 7'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%23757575' stroke-width='1.5' fill='none' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right var(--field-padding-x) center;
  cursor: pointer;
}

/* ─── Hint / Description ─── */
.field-hint {
  font-family: var(--font-mono);
  font-size: var(--field-hint-font-size);
  color: var(--text-muted);
  line-height: var(--field-hint-line-height);
  margin-top: var(--field-hint-margin-top);
  margin-left: var(--field-hint-margin-left);
}
.field-hint.field-error   { color: var(--error); margin-left: 0; }
.field-hint.field-warning { color: var(--warning); margin-left: 0; }
.field-hint.field-success { color: var(--success); margin-left: 0; }

/* ─── Char count ─── */
.field-char-count {
  font-family: var(--font-mono);
  font-size: var(--field-label-font-size);
  color: var(--text-muted);
  text-align: right;
  line-height: var(--field-char-count-line-height);
}
.field-char-count.field-warning { color: var(--warning); }
.field-char-count.field-error   { color: var(--error); }

/* ─── Layout helpers ─── */
.field-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-2);
}

.field-section-heading {
  font-family: var(--font-mono);
  font-size: var(--field-label-font-size);
  font-weight: var(--field-label-font-weight);
  letter-spacing: var(--field-label-letter-spacing);
  text-transform: uppercase;
  color: var(--text-muted);
  padding-bottom: var(--fieldset-legend-padding);
  border-bottom: var(--fieldset-border-width) solid var(--border);
  margin-bottom: var(--fieldset-legend-margin-bottom);
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: var(--space-2);
  padding-top: var(--space-3);
  border-top: var(--border-thin) solid var(--border);
  margin-top: var(--space-2);
}

/* ─── Native checkbox/radio (fallback / non-HUI) ─── */
.field-checkbox-group,
.field-radio-group {
  display: flex;
  flex-direction: column;
  gap: var(--field-group-gap);
}
.field-checkbox-row,
.field-radio-row {
  display: flex;
  align-items: center;
  gap: var(--field-group-gap);
  font-family: var(--font-sans);
  font-size: var(--field-checkbox-font-size);
  cursor: pointer;
  user-select: none;
}
.field-checkbox-row input[type="checkbox"],
.field-radio-row    input[type="radio"] {
  width: var(--control-size);
  height: var(--control-size);
  accent-color: var(--brand-blue);
  cursor: pointer;
  flex-shrink: 0;
}

/* ═══════════════════════════════════════
   HEADLESS UI — element styles
   HUI components render semantic HTML and
   expose data-* attributes for state.
   ═══════════════════════════════════════ */

/* ─── Field / Fieldset (layout wrapper) ─── */
/* HUI <Field> renders a <div>, <Fieldset> renders a <fieldset> */
[data-slot="control"] {
  display: flex;
  flex-direction: column;
  gap: var(--field-label-gap);
}
fieldset[data-slot="fieldset"],
fieldset {
  border: none;
  padding: 0;
  margin: 0;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

/* ─── Label / Legend ─── */
/* HUI <Label> renders a <label>, <Legend> renders a <legend> */
[data-slot="label"],
label {
  display: block;
  font-family: var(--font-mono);
  font-size: var(--field-label-font-size);
  font-weight: var(--field-label-font-weight);
  letter-spacing: var(--field-label-letter-spacing);
  text-transform: uppercase;
  color: var(--text-secondary);
  user-select: none;
  cursor: default;
}
[data-slot="legend"],
legend {
  font-family: var(--font-mono);
  font-size: var(--field-label-font-size);
  font-weight: var(--field-label-font-weight);
  letter-spacing: var(--field-label-letter-spacing);
  text-transform: uppercase;
  color: var(--text-muted);
  padding-bottom: var(--fieldset-legend-padding);
  border-bottom: var(--fieldset-border-width) solid var(--border);
  width: 100%;
  float: left;
  margin-bottom: var(--space-1);
}

/* ─── Description ─── */
/* HUI <Description> renders a <p> */
[data-slot="description"] {
  font-family: var(--font-mono);
  font-size: var(--field-hint-font-size);
  color: var(--text-muted);
  line-height: var(--field-hint-line-height);
  margin: 0;
}

/* ─── Input ─── */
/* HUI <Input> renders an <input>; data-focus, data-hover, data-invalid */
[data-slot="input"] {
  display: block;
  width: 100%;
  box-sizing: border-box;
  height: var(--field-height);
  padding: 0 var(--field-padding-x);
  font-family: var(--font-sans);
  font-size: var(--field-font-size);
  font-weight: var(--font-weight-normal);
  color: var(--text);
  background: var(--field-bg);
  border: var(--field-border-width) solid var(--field-border-color);
  border-radius: var(--radius);
  outline: none;
  box-shadow: var(--field-shadow);
  transition: var(--field-transition);
}
[data-slot="input"]::placeholder { color: var(--text-muted); }
[data-slot="input"]:hover:not(:focus) { border-color: var(--border-strong); }
[data-slot="input"]:focus,
[data-slot="input"][data-focus] {
  border-color: var(--brand-blue);
  box-shadow:
    var(--field-focus-ring),
    var(--field-shadow);
}
[data-slot="input"][data-invalid],
[data-slot="input"].field-error {
  border-color: var(--error);
  background: color-mix(in srgb, var(--error-tint) 55%, var(--surface));
  box-shadow: inset var(--field-validation-bar-width) 0 0 0 var(--error);
}

/* ─── Select ─── */
/* HUI <Select> renders a <select> */
[data-slot="select"] {
  display: block;
  width: 100%;
  box-sizing: border-box;
  height: var(--field-height);
  padding: 0 var(--field-select-padding-right) 0 var(--field-padding-x);
  font-family: var(--font-sans);
  font-size: var(--field-font-size);
  color: var(--text);
  background: var(--field-bg);
  border: var(--field-border-width) solid var(--field-border-color);
  border-radius: var(--radius);
  outline: none;
  box-shadow: var(--field-shadow);
  transition: var(--field-transition);
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='7' viewBox='0 0 12 7'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%23757575' stroke-width='1.5' fill='none' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right var(--field-padding-x) center;
  cursor: pointer;
}
[data-slot="select"]:hover:not(:focus) { border-color: var(--border-strong); }
[data-slot="select"]:focus,
[data-slot="select"][data-focus] {
  border-color: var(--brand-blue);
  box-shadow:
    var(--field-focus-ring),
    var(--field-shadow);
}
[data-slot="select"][data-invalid],
[data-slot="select"].field-error {
  border-color: var(--error);
  background-color: color-mix(in srgb, var(--error-tint) 55%, var(--surface));
  box-shadow: inset var(--field-validation-bar-width) 0 0 0 var(--error);
}

/* ─── Textarea ─── */
/* HUI <Textarea> renders a <textarea> */
[data-slot="textarea"] {
  display: block;
  width: 100%;
  box-sizing: border-box;
  padding: var(--field-textarea-padding);
  min-height: var(--field-textarea-min-height);
  font-family: var(--font-sans);
  font-size: var(--field-font-size);
  color: var(--text);
  background: var(--field-bg);
  border: var(--field-border-width) solid var(--field-border-color);
  border-radius: var(--radius);
  outline: none;
  box-shadow: var(--field-shadow);
  transition: var(--field-transition);
  resize: none;
  line-height: var(--field-textarea-line-height);
}
[data-slot="textarea"]::placeholder { color: var(--text-muted); }
[data-slot="textarea"]:hover:not(:focus) { border-color: var(--border-strong); }
[data-slot="textarea"]:focus,
[data-slot="textarea"][data-focus] {
  border-color: var(--brand-blue);
  box-shadow:
    var(--field-focus-ring),
    var(--field-shadow);
}
[data-slot="textarea"][data-invalid],
[data-slot="textarea"].field-error {
  border-color: var(--error);
  background: color-mix(in srgb, var(--error-tint) 55%, var(--surface));
  box-shadow: inset var(--field-validation-bar-width) 0 0 0 var(--error);
}

/* ─── Checkbox ─── */
/* HUI <Checkbox> — our CheckboxRadioDemo renders its own visual,
   but these rules cover any bare usage of the HUI Checkbox element */
[data-slot="checkbox"] {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: var(--control-size);
  height: var(--control-size);
  border: var(--control-border-width) solid var(--control-border-color);
  border-radius: var(--radius);
  background: var(--surface);
  flex-shrink: 0;
  cursor: pointer;
  transition: var(--control-transition);
  box-shadow: var(--control-shadow);
}
[data-slot="checkbox"][data-checked] {
  background: var(--control-checked-color);
  border-color: var(--control-checked-color);
}
[data-slot="checkbox"][data-focus] {
  box-shadow: var(--field-focus-ring);
}

/* ─── Switch ─── */
/* HUI <Switch> — our SwitchGroup renders its own visual,
   but these rules cover any bare usage */
[data-slot="switch"] {
  display: inline-flex;
  align-items: center;
  width: var(--switch-width);
  height: var(--switch-height);
  border-radius: var(--switch-radius);
  background: var(--border);
  border: none;
  cursor: pointer;
  transition: var(--switch-transition);
  position: relative;
  flex-shrink: 0;
}
[data-slot="switch"][data-checked] {
  background: var(--control-checked-color);
}
[data-slot="switch"]::after {
  content: '';
  position: absolute;
  width: var(--switch-thumb-size);
  height: var(--switch-thumb-size);
  border-radius: var(--switch-thumb-radius);
  background: var(--white);
  left: var(--switch-thumb-inset);
  box-shadow: var(--switch-thumb-shadow);
  transition: var(--switch-thumb-transition);
}
[data-slot="switch"][data-checked]::after { left: var(--switch-thumb-checked-pos); }
[data-slot="switch"][data-focus] {
  box-shadow: var(--field-focus-ring);
}

/* ─── RadioGroup / Radio ─── */
/* HUI <Radio> — our demo renders its own visual, these are bare fallbacks */
[data-slot="radio"] {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: var(--radio-size);
  height: var(--radio-size);
  border-radius: 50%;
  border: var(--radio-border-width) solid var(--control-border-color);
  background: var(--surface);
  flex-shrink: 0;
  cursor: pointer;
  transition: var(--control-transition);
}
[data-slot="radio"][data-checked] {
  border-color: var(--control-checked-color);
  background: var(--surface);
  box-shadow: var(--radio-inner-shadow);
}
[data-slot="radio"][data-focus] {
  box-shadow: var(--field-focus-ring);
}`;
}
