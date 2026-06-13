import type { StyleGuideConfig } from "../types";
import { getAccentCSS, getAccentShadowOnly, getHoverCSS } from "../accent-styles";

function contrastText(value: string): string {
  let r = 128, g = 128, b = 128;
  if (value.startsWith("#") && value.length >= 7) {
    r = parseInt(value.slice(1, 3), 16);
    g = parseInt(value.slice(3, 5), 16);
    b = parseInt(value.slice(5, 7), 16);
  } else {
    const m = value.match(/rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/);
    if (m) { r = +m[1]; g = +m[2]; b = +m[3]; }
  }
  return (r * 0.299 + g * 0.587 + b * 0.114) > 150 ? "var(--black)" : "var(--white)";
}

function resolveAccent(sc: { vars: { name: string; value: string }[] }, flatVars: Record<string, string>): string {
  const accentVar = sc.vars.find((v) => v.name === "accent");
  if (!accentVar) return "var(--white)";
  const ref = accentVar.value.replace(/var\(--/, "").replace(/\)/, "");
  const resolved = flatVars[ref];
  return resolved ? contrastText(resolved) : "var(--white)";
}

export function generateSemanticCSS(config: StyleGuideConfig): string {
  return config.semanticClasses
    .map((sc) => {
      const accentStyle = sc.accentStyle;
      const accentColor = `var(--semantic-${sc.name}-accent)`;
      const backgroundColor = `var(--semantic-${sc.name}-background)`;
      const textColor = `var(--semantic-${sc.name}-color)`;
      const textOnColor = resolveAccent(sc, config.flatVars);

      const accentCSS = getAccentCSS(accentStyle, accentColor);
      const hoverCSS = getHoverCSS(accentStyle, accentColor);

      const TEXT_PROPS = new Set(["font-family", "font-weight", "font-size", "font-style", "letter-spacing", "text-transform"]);
      const RESERVED_VARS = new Set(["accent", "background", "color", ...TEXT_PROPS]);
      const BTN_TEXT_PROPS = new Set(["font-family", "font-weight", "font-style", "letter-spacing", "text-transform"]);
      const cardStyleVars = sc.vars
        .filter((v) => !RESERVED_VARS.has(v.name))
        .map((v) => `  ${v.name}: var(--semantic-${sc.name}-${v.name});`)
        .join("\n");

      const btnTypographyVars = sc.vars
        .filter((v) => BTN_TEXT_PROPS.has(v.name))
        .map((v) => `  ${v.name}: var(--semantic-${sc.name}-${v.name});`)
        .join("\n");

      // card-accent-side: "top" (default) or "left" (sumi-e)
      const side = config.flatVars["card-accent-side"] || "top";
      const accentBorderProp = `border-${side}`;

      let css = `/* ${sc.title} (${accentStyle}) */

/* ── .card.${sc.class} — full semantic: thick colored ${side} border, colored sides, text colored ── */
.card.${sc.class} {
  border-color: ${accentColor};
  ${accentBorderProp}: var(--card-border-width-accent) var(--card-border-style) ${accentColor};
  color: ${accentColor};${cardStyleVars ? `\n${cardStyleVars}` : ""}
}
.card.${sc.class} .card-header { color: ${accentColor}; }
.card.${sc.class} .card-title { color: inherit; }
.card.${sc.class} .card-tag { background: ${accentColor}; color: ${textOnColor}; }
.card.${sc.class} .card-footer { color: ${accentColor}; }
.card.${sc.class}.drop-shadow {
  box-shadow: 0 8px 24px color-mix(in srgb, ${accentColor} 35%, transparent), 0 2px 6px color-mix(in srgb, ${accentColor} 20%, transparent);
}

/* ── .card.accent-${sc.class} — accent only: thick colored ${side} border, default other sides ── */
.card.accent-${sc.class} {
  ${accentBorderProp}: var(--card-border-width-accent) var(--card-border-style) ${accentColor};${getAccentShadowOnly(accentStyle, accentColor) ? `\n  ${getAccentShadowOnly(accentStyle, accentColor)}` : ''}
}
.card.accent-${sc.class} .card-header::after {
  display: none;
}
.card.accent-${sc.class}.drop-shadow {
  box-shadow: 0 8px 24px color-mix(in srgb, ${accentColor} 35%, transparent), 0 2px 6px color-mix(in srgb, ${accentColor} 20%, transparent);
}

/* accent-* on header standalone */
.card-header.accent-${sc.class} {
  border-bottom: var(--card-border-width-accent) var(--card-border-style) ${accentColor};
}`;

      if (hoverCSS) {
        css += `\n.card.${sc.class} .card-header.accent-${sc.class}:hover {\n  ${hoverCSS}\n}`;
      }

      css += `

/* .card-header.${sc.class} — semantic class on header */
.card-header.${sc.class} {
  background: ${accentColor};
  color: ${textOnColor};
  border-left: none; border-right: none; border-top: none; border-bottom: none;
}
.card-header.${sc.class}::after {
  border-bottom-color: rgba(255,255,255,0.25);
}
.card-header.${sc.class} .card-title { color: inherit; }
.card-header.${sc.class} .card-tag { background: ${accentColor}; color: ${textOnColor}; }

/* Applied at body level */
.card-body.${sc.class} {
  background: ${backgroundColor};
  color: ${textColor};
  border: none;
}

/* Applied at footer level */
.card-footer.${sc.class} {
  background: ${accentColor};
  color: ${textOnColor};
  border-left: none; border-right: none; border-bottom: none;
}
.card-footer.${sc.class}::before {
  border-top-color: rgba(255,255,255,0.25);
}`;

      if (sc.name === "disabled") {
        css += `\n.card.disabled { cursor: not-allowed; opacity: 0.6; }
.card-header.disabled,
.card-body.disabled,
.card-footer.disabled { pointer-events: none; }`;
      }

      // Button semantic rules
      css += `

/* Button: .btn.${sc.class} */
.btn.${sc.class} {
  background: ${accentColor};
  border-color: ${accentColor};
  color: ${textOnColor};
  position: relative;
  overflow: hidden;
  transition: background var(--btn-transition), border-color var(--btn-transition), box-shadow var(--transition-slow) ease;${btnTypographyVars ? `\n${btnTypographyVars}` : ""}
}
.btn.${sc.class}::before {
  content: '';
  position: absolute;
  inset: 0;
  z-index: 0;
  background: linear-gradient(
    135deg,
    rgba(255,255,255,0),
    rgba(255,255,255,0.22),
    rgba(255,255,255,0),
    rgba(0,0,0,0.18)
  );
  background-size: 300% 300%;
  opacity: 0;
  transition: opacity var(--transition-slow) ease;
  pointer-events: none;
}
.btn.${sc.class}:hover {
  background: color-mix(in srgb, ${accentColor} 85%, black);
  border-color: color-mix(in srgb, ${accentColor} 85%, black);
}
.btn.${sc.class}.drop-shadow {
  box-shadow: 0 8px 24px color-mix(in srgb, ${accentColor} 35%, transparent), 0 2px 6px color-mix(in srgb, ${accentColor} 20%, transparent);
}

/* Button ghost: .btn.btn-ghost.${sc.class} */
.btn.btn-ghost.${sc.class} {
  background: transparent;
  border-color: transparent;
  color: ${accentColor};
}
.btn.btn-ghost.${sc.class}:hover {
  background: color-mix(in srgb, ${accentColor} 10%, transparent);
}

/* Button outline: .btn.btn-outline.${sc.class} */
.btn.btn-outline.${sc.class} {
  background: transparent;
  border-color: ${accentColor};
  color: ${accentColor};
}
.btn.btn-outline.${sc.class}:hover {
  background: color-mix(in srgb, ${accentColor} 10%, transparent);
}

/* Button accent: .btn.accent-${sc.class} — bottom border + inset bottom shadow only */
.btn.accent-${sc.class} {
  border-bottom-color: ${accentColor};
  border-bottom-width: 2px;
  box-shadow: inset 0 -3px 6px color-mix(in srgb, ${accentColor} 25%, transparent);
}
.btn.accent-${sc.class}.drop-shadow {
  box-shadow: inset 0 -3px 6px color-mix(in srgb, ${accentColor} 25%, transparent), 0 8px 24px color-mix(in srgb, ${accentColor} 35%, transparent);
}

/* Button outline accent: .btn.btn-outline.accent-${sc.class} */
.btn.btn-outline.accent-${sc.class} {
  border-color: ${accentColor};
  color: ${accentColor};
}
.btn.btn-outline.accent-${sc.class}:hover {
  background: color-mix(in srgb, ${accentColor} 10%, transparent);
}

/* Selected state: fade in animated gradient overlay via ::before */
.btn.${sc.class}.btn-selected {
  border-color: color-mix(in srgb, ${accentColor} 70%, black);
  box-shadow: inset 0 2px 6px color-mix(in srgb, ${accentColor} 40%, black), inset 0 1px 2px rgba(0,0,0,0.3);
}
.btn.${sc.class}.btn-selected::before {
  opacity: 1;
  animation: btn-selected-gradient 2.5s ease infinite;
}`;

      if (sc.name === "disabled") {
        css += `\n.btn.disabled { cursor: not-allowed; opacity: 0.6; pointer-events: none; }`;
      }

      // HUI semantic rules (new .hui.X namespace)
      css += `

/* HUI: Trigger buttons */
.hui.menu-btn.${sc.class},
.hui.popover-btn.${sc.class} {
  border-color: ${accentColor};
  color: ${textColor};
}
.hui.menu-btn.${sc.class}[data-hover],
.hui.popover-btn.${sc.class}[data-hover] {
  background: ${backgroundColor};
}

/* HUI: Overlay panels */
.hui.menu-items.${sc.class},
.hui.listbox-options.${sc.class},
.hui.combo-options.${sc.class},
.hui.popover-panel.${sc.class} {
  ${accentBorderProp}: var(--hui-showcase-accent-width) solid ${accentColor};
  border-color: color-mix(in srgb, ${accentColor} 40%, var(--hui-panel-border));
  background: ${backgroundColor};
}

/* HUI: Listbox & Combobox field-style triggers */
.hui.listbox-btn.${sc.class} {
  border-color: color-mix(in srgb, ${accentColor} 40%, var(--hui-field-border));
}
.hui.listbox-btn.${sc.class}[data-open] {
  border-color: ${accentColor};
  box-shadow: 0 0 0 var(--hui-focus-ring-width) color-mix(in srgb, ${accentColor} 25%, transparent), var(--hui-field-shadow);
}
.hui.listbox-btn.${sc.class}::after {
  border-right-color: ${accentColor};
  border-bottom-color: ${accentColor};
}
.hui.combo-input.${sc.class} {
  border-color: color-mix(in srgb, ${accentColor} 40%, var(--hui-field-border));
}
.hui.combo-input.${sc.class}:focus {
  border-color: ${accentColor};
  box-shadow: 0 0 0 var(--hui-focus-ring-width) color-mix(in srgb, ${accentColor} 25%, transparent), var(--hui-field-shadow);
}
.hui.combo-btn.${sc.class} {
  color: ${accentColor};
}

/* HUI: Dialog */
.hui.dialog-panel.${sc.class} {
  ${accentBorderProp}: var(--hui-showcase-accent-width) solid ${accentColor};
}
.hui.dialog-panel.${sc.class} .dialog-title {
  color: ${accentColor};
}

/* HUI: Tabs */
.hui.tab-list.${sc.class} .hui.tab[data-selected] {
  color: ${accentColor};
  border-bottom-color: ${accentColor};
}

/* HUI: Disclosure */
.hui.disclosure-btn.${sc.class} {
  border-color: ${accentColor};
  background: ${backgroundColor};
}

/* HUI: Controls — on state */
.hui.checkbox-wrap.${sc.class}[data-checked] .checkbox-visual {
  background: ${accentColor};
  border-color: ${accentColor};
}
.hui.switch-wrap.${sc.class}[data-checked] .switch-track {
  background: ${accentColor};
}
.hui.radio-option.${sc.class}[data-checked] {
  border-color: ${accentColor};
  background: ${backgroundColor};
}
.hui.radio-option.${sc.class}[data-checked] .radio-dot {
  border-color: ${accentColor};
}
.hui.radio-option.${sc.class}[data-checked] .radio-dot-inner {
  background: ${accentColor};
}

/* HUI: Controls — off state (semantic tints the unchecked appearance) */
.hui.checkbox-wrap.${sc.class}:not([data-checked]) .checkbox-visual {
  border-color: color-mix(in srgb, ${accentColor} 40%, var(--hui-control-border));
}
.hui.switch-wrap.${sc.class}:not([data-checked]) .switch-track {
  background: color-mix(in srgb, ${accentColor} 25%, var(--hui-switch-track-off-bg));
}
.hui.radio-option.${sc.class}:not([data-checked]) {
  border-color: color-mix(in srgb, ${accentColor} 30%, var(--hui-radio-option-border));
}
.hui.radio-option.${sc.class}:not([data-checked]) .radio-dot {
  border-color: color-mix(in srgb, ${accentColor} 40%, var(--hui-control-border));
}

/* HUI: Showcase accent */
.hui.showcase.${sc.class} {
  border-top-color: ${accentColor};
}
.hui.showcase.accent-${sc.class} {
  border-top-color: ${accentColor};
}

/* Forms: fieldset.${sc.class} — tinted container, cascades to children */
fieldset.${sc.class} {
  background: ${backgroundColor};
  ${accentBorderProp}: var(--card-border-width-accent) var(--card-border-style) ${accentColor};
  border-radius: var(--radius);
  padding: var(--space-3);
}
fieldset.${sc.class} legend,
fieldset.${sc.class} [data-slot="legend"] {
  color: ${accentColor};
  border-bottom-color: ${accentColor};
}
fieldset.${sc.class} label,
fieldset.${sc.class} [data-slot="label"] {
  color: ${accentColor};
}
fieldset.${sc.class} .field-input,
fieldset.${sc.class} .field-select,
fieldset.${sc.class} .field-textarea,
fieldset.${sc.class} [data-slot="input"],
fieldset.${sc.class} [data-slot="select"],
fieldset.${sc.class} [data-slot="textarea"] {
  border-color: color-mix(in srgb, ${accentColor} 40%, var(--field-border-color));
}
fieldset.${sc.class} .field-input:focus,
fieldset.${sc.class} .field-select:focus,
fieldset.${sc.class} .field-textarea:focus,
fieldset.${sc.class} [data-slot="input"]:focus,
fieldset.${sc.class} [data-slot="select"]:focus,
fieldset.${sc.class} [data-slot="textarea"]:focus {
  border-color: ${accentColor};
  box-shadow: 0 0 0 var(--hui-focus-ring-width) color-mix(in srgb, ${accentColor} 25%, transparent), var(--field-shadow);
}
fieldset.${sc.class} .field-hint,
fieldset.${sc.class} [data-slot="description"] {
  color: color-mix(in srgb, ${accentColor} 60%, var(--text-muted));
}

/* Forms: .field-group.${sc.class} — per-field semantic */
.field-group.${sc.class} label,
.field-group.${sc.class} [data-slot="label"] {
  color: ${accentColor};
}
.field-group.${sc.class} .field-input,
.field-group.${sc.class} .field-select,
.field-group.${sc.class} .field-textarea,
.field-group.${sc.class} [data-slot="input"],
.field-group.${sc.class} [data-slot="select"],
.field-group.${sc.class} [data-slot="textarea"] {
  border-color: color-mix(in srgb, ${accentColor} 40%, var(--field-border-color));
}
.field-group.${sc.class} .field-input:focus,
.field-group.${sc.class} .field-select:focus,
.field-group.${sc.class} .field-textarea:focus,
.field-group.${sc.class} [data-slot="input"]:focus,
.field-group.${sc.class} [data-slot="select"]:focus,
.field-group.${sc.class} [data-slot="textarea"]:focus {
  border-color: ${accentColor};
  box-shadow: 0 0 0 var(--hui-focus-ring-width) color-mix(in srgb, ${accentColor} 25%, transparent), var(--field-shadow);
}
.field-group.${sc.class} .field-hint,
.field-group.${sc.class} [data-slot="description"] {
  color: color-mix(in srgb, ${accentColor} 60%, var(--text-muted));
}`;

      return css;
    })
    .join("\n\n");
}
