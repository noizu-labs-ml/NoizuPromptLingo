import type { StyleGuideConfig } from "@styleguide-engine/lib/types";
import type { CssSection } from "@styleguide-engine/lib/css-gen";

export interface SectionProps {
  number: string;
  id: string;
  title: string;
  desc: string;
  config: StyleGuideConfig;
  cssSections?: CssSection[];
  styleGuideFiles?: { name: string; content: string }[];
  brandingYaml?: string;
}
