"use client";

import { useThemeConfig } from "./ThemeConfigContext";
import { HUIShowcase } from "./HUIShowcase";
import { CardShowcase } from "./CardShowcase";
import { ButtonShowcase } from "./ButtonShowcase";
import { FormsShowcase } from "./FormsShowcase";
import { UIElementsShowcase } from "./UIElementsShowcase";
import { TypographyShowcase } from "./TypographyShowcase";
import { ColorPalette } from "./ColorPalette";
import { DesignTokens } from "./DesignTokens";
import { CssViewer } from "./CssViewer";
import { YamlConfigViewer } from "./YamlConfigViewer";
import { SnippetShowcase } from "./SnippetShowcase";
import { SemanticClassSummary } from "./SemanticClassSummary";
import type { CssSection } from "@styleguide-engine/lib/css-gen";

const NEEDS_PICKER = new Set(["hui", "controls", "cards", "buttons", "forms", "ui"]);

interface Props {
  name: string;
  allCssSections: Record<string, CssSection[]>;
  allStyleGuideFiles: Record<string, { name: string; content: string }[]>;
  allBrandingYamls: Record<string, string>;
}

export function ThemeAwareSectionContent({ name, allCssSections, allStyleGuideFiles, allBrandingYamls }: Props) {
  const { config, activeSlug } = useThemeConfig();

  const formsSection = config.designSections.find((s) => s.name === "forms");
  const cssSections = allCssSections[activeSlug] || Object.values(allCssSections)[0] || [];
  const styleGuideFiles = allStyleGuideFiles[activeSlug] || Object.values(allStyleGuideFiles)[0] || [];
  const brandingYaml = allBrandingYamls[activeSlug] || Object.values(allBrandingYamls)[0] || "";

  function renderSection() {
    switch (name) {
      case "hui":
      case "controls":
        return <HUIShowcase semanticClasses={config.semanticClasses} />;
      case "cards":
        return <CardShowcase semanticClasses={config.semanticClasses} />;
      case "buttons":
        return <ButtonShowcase semanticClasses={config.semanticClasses} />;
      case "forms":
        return formsSection ? <FormsShowcase section={formsSection} /> : <p>No forms section found.</p>;
      case "ui":
        return <UIElementsShowcase semanticClasses={config.semanticClasses} formsSection={formsSection} />;
      case "typography":
        return <TypographyShowcase config={config} />;
      case "color":
        return <ColorPalette palette={config.colorPalette} semanticClasses={config.semanticClasses} semanticGroups={config.semanticGroups} />;
      case "tokens":
        return <DesignTokens groups={config.vars.groups} flatVars={config.flatVars} semanticClasses={config.semanticClasses} semanticGroups={config.semanticGroups} />;
      case "css":
        return <CssViewer sections={cssSections} />;
      case "config":
        return <YamlConfigViewer styleGuideFiles={styleGuideFiles} brandingYaml={brandingYaml} />;
      case "snippets":
        return <SnippetShowcase config={config} />;
      default:
        return <p>Unknown section: <code>{name}</code></p>;
    }
  }

  return (
    <>
      {NEEDS_PICKER.has(name) && config.semanticClasses.length > 0 && (
        <SemanticClassSummary semanticClasses={config.semanticClasses} colorPalette={config.colorPalette} />
      )}
      {renderSection()}
    </>
  );
}
