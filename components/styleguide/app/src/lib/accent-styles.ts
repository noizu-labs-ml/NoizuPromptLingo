import type { AccentStyle } from "./types";

function mix(color: string, pct: number): string {
  return `color-mix(in srgb, ${color} ${pct}%, transparent)`;
}

export function getAccentCSS(style: AccentStyle, accentColor: string): string {
  const map: Record<AccentStyle, string> = {
    "bottom-bar": `border-bottom: var(--card-border-width-accent) var(--card-border-style) ${accentColor};`,
    "bottom-bar-glow": `border-bottom: var(--card-border-width-accent) var(--card-border-style) ${accentColor}; box-shadow: 0 4px 12px ${mix(accentColor, 20)};`,
    "left-border": `border-left: var(--card-border-width-accent) var(--card-border-style) ${accentColor};`,
    "left-dashed": `border-left: var(--card-border-width-accent) dashed ${accentColor};`,
    "outer-shadow": `box-shadow: 0 0 0 1px ${accentColor}, 0 4px 6px -1px rgba(0, 0, 0, 0.05);`,
    "inner-shadow": `box-shadow: inset 0 0 0 2px ${accentColor}, inset 0 2px 4px rgba(0, 0, 0, 0.05);`,
    "outer-glow": `box-shadow: 0 0 0 1px ${accentColor}, 0 0 12px 2px ${mix(accentColor, 40)};`,
    "inner-glow": `box-shadow: inset 0 0 0 1px ${accentColor}, inset 0 0 12px ${mix(accentColor, 27)};`,
    none: "",
  };
  return map[style] || map["bottom-bar"];
}

export function getAccentShadowOnly(style: AccentStyle, accentColor: string): string {
  const map: Record<AccentStyle, string> = {
    "bottom-bar": "",
    "bottom-bar-glow": `box-shadow: 0 4px 12px ${mix(accentColor, 20)};`,
    "left-border": "",
    "left-dashed": "",
    "outer-shadow": `box-shadow: 0 0 0 1px ${accentColor}, 0 4px 6px -1px rgba(0, 0, 0, 0.05);`,
    "inner-shadow": `box-shadow: inset 0 0 0 2px ${accentColor}, inset 0 2px 4px rgba(0, 0, 0, 0.05);`,
    "outer-glow": `box-shadow: 0 0 0 1px ${accentColor}, 0 0 12px 2px ${mix(accentColor, 40)};`,
    "inner-glow": `box-shadow: inset 0 0 0 1px ${accentColor}, inset 0 0 12px ${mix(accentColor, 27)};`,
    none: "",
  };
  return map[style] || "";
}

export function getHoverCSS(style: AccentStyle, accentColor: string): string {
  if (style.includes("shadow") || style.includes("glow")) {
    return `box-shadow: 0 0 0 2px ${accentColor}, 0 8px 12px -1px rgba(0, 0, 0, 0.08);`;
  }
  return "";
}
