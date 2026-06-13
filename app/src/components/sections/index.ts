import type { SectionProps } from "./section-props";
import { TypographySection, ColorSection, SpacingSection, DividersSection, GlyphsSection, CodeBlocksSection, TerminalSection } from "./visual-foundation";
import { ShellLayoutsSection, ContentLayoutsSection, SiteArchetypesSection, NavigationSection } from "./structure";
import { SemanticClassesSection, StatusIndicatorsSection, UIElementsSection, CustomComponentsSection } from "./interaction";
import { InkEffectsSection } from "./ink-effects";
import { ScreensSection } from "./screens";
import { TailwindPlusSection } from "./tailwind-plus";
import { DesignTokensSection, GeneratedCssSection, ThemeConfigSection, SnippetsSection, OverridesSection } from "./reference";
import { ComponentBrowserSection } from "./component-browser";

export type { SectionProps } from "./section-props";

export const sectionRegistry: Record<string, (props: SectionProps) => React.ReactNode> = {
  "typography": TypographySection,
  "color": ColorSection,
  "spacing": SpacingSection,
  "dividers": DividersSection,
  "glyphs": GlyphsSection,
  "shell-layouts": ShellLayoutsSection,
  "content-layouts": ContentLayoutsSection,
  "site-archetypes": SiteArchetypesSection,
  "navigation": NavigationSection,
  "semantic-classes": SemanticClassesSection,
  "status-indicators": StatusIndicatorsSection,
  "ui-elements": UIElementsSection,
  "custom-components": CustomComponentsSection,
  "tailwind-plus": TailwindPlusSection,
  "design-tokens": DesignTokensSection,
  "generated-css": GeneratedCssSection,
  "theme-config": ThemeConfigSection,
  "snippets": SnippetsSection,
  "overrides": OverridesSection,
  "code-blocks": CodeBlocksSection,
  "terminal": TerminalSection,
  "ink-effects": InkEffectsSection,
  "screens": ScreensSection,
  "component-browser": ComponentBrowserSection,
};
