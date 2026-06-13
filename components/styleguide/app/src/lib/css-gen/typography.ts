import type { StyleGuideConfig, TypographyClass } from "../types";

const CSS_PROPS: (keyof TypographyClass)[] = [
  "font-family",
  "font-size",
  "font-weight",
  "font-style",
  "line-height",
  "letter-spacing",
  "text-transform",
  "color",
];

export function generateTypographyClassCSS(config: StyleGuideConfig): string {
  if (!config.typographyClasses.length) return "";

  const rules = config.typographyClasses.map((tc) => {
    const declarations = CSS_PROPS.filter((p) => tc[p] !== undefined)
      .map((p) => `  ${p}: ${tc[p]};`)
      .join("\n");
    return `.${tc.class} {\n${declarations}\n}`;
  });

  return `/* ═══════════════════════════════════════
   TYPOGRAPHY CLASSES
   ═══════════════════════════════════════ */\n${rules.join("\n\n")}`;
}
