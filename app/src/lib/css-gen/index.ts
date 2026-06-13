import type { StyleGuideConfig } from "../types";
import { generateVarsCSS } from "./vars";
import { generateCardCSS } from "./cards";
import { generateButtonCSS } from "./buttons";
import { generateSemanticCSS } from "./semantic";
import { generateLayoutCSS } from "./layout";
import { generateGlobalsCSS } from "./globals";
import { generateUtilityCSS } from "./utilities";
import { generateBrandingCSS } from "./branding";
import { generateSectionCSS } from "./sections";
import { generateTokenCSS } from "./tokens";
import { generateSpacingCSS } from "./spacing";
import { generateTypographyClassCSS } from "./typography";
import { generateIndicatorCSS } from "./indicators";
import { generateFormsCSS } from "./forms";
import { generateDividerCSS } from "./dividers";
import { generateShellCSS } from "./shells";
import { generateHUIInteractiveCSS } from "./hui-interactive";
import { generateSwatchCSS } from "./swatches";
import { generateScopedVarsCSS } from "./scoped-vars";
import { generateCssSnippetsCSS } from "./css-snippets";
import { generateCodeTerminalCSS } from "./code-terminal";

export interface CssSection {
  name: string;
  css: string;
  /** YAML source file(s) that drove this section's generation */
  sources?: string[];
}

export function generateCSSSections(config: StyleGuideConfig): CssSection[] {
  const s = (name: string) => `style-guide.${name}.yaml`;
  return [
    { name: "vars", css: generateVarsCSS(config), sources: [s("vars"), s("color-palette"), s("color-modes")] },
    { name: "scoped-vars", css: generateScopedVarsCSS(config), sources: [s("scoped-vars")] },
    { name: "branding", css: generateBrandingCSS(config), sources: ["branding.yaml"] },
    { name: "sections", css: generateSectionCSS(config), sources: [s("design-sections")] },
    { name: "tokens", css: generateTokenCSS(config), sources: [s("vars"), s("color-palette")] },
    { name: "swatches", css: generateSwatchCSS(config), sources: [s("color-palette")] },
    { name: "spacing", css: generateSpacingCSS(config), sources: [s("spacing")] },
    { name: "cards", css: generateCardCSS(), sources: [s("vars")] },
    { name: "buttons", css: generateButtonCSS(config), sources: [s("vars")] },
    { name: "semantic", css: generateSemanticCSS(config), sources: [s("semantic-classes"), s("semantic-groups")] },
    { name: "typography", css: generateTypographyClassCSS(config), sources: [s("typography")] },
    { name: "indicators", css: generateIndicatorCSS(config), sources: [s("vars")] },
    { name: "forms", css: generateFormsCSS(config), sources: [s("vars")] },
    { name: "dividers", css: generateDividerCSS(config), sources: [s("vars")] },
    { name: "shells", css: generateShellCSS(config), sources: [s("shell-layouts")] },
    { name: "hui", css: generateHUIInteractiveCSS(config), sources: [s("vars")] },
    { name: "utilities", css: generateUtilityCSS(config), sources: [s("vars")] },
    { name: "layout", css: generateLayoutCSS(config), sources: [s("page-layouts")] },
    { name: "css-snippets", css: generateCssSnippetsCSS(config), sources: [s("css-snippets")] },
    { name: "code-terminal", css: generateCodeTerminalCSS(config), sources: [s("css-snippets")] },
    { name: "globals", css: generateGlobalsCSS(config), sources: [s("globals")] },
  ];
}

export function generateCSS(config: StyleGuideConfig): string {
  return generateCSSSections(config).map((s) => s.css).join("\n\n");
}
