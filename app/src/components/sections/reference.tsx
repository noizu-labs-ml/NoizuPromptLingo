import { CollapsibleSection } from "@styleguide-engine/components/CollapsibleSection";
import { SubsectionTabs } from "@styleguide-engine/components/SubsectionTabs";
import { CoreTokensSection, HUITokensSection, ExtendedTokensSection } from "@styleguide-engine/components/DesignTokens";
import { CssViewer } from "@styleguide-engine/components/CssViewer";
import { YamlConfigViewer } from "@styleguide-engine/components/YamlConfigViewer";
import { OverrideManager } from "@styleguide-engine/components/OverrideManager";
import { CssSnippetsPanel, JsxSnippetsPanel } from "@styleguide-engine/components/SnippetShowcase";
import type { SectionProps } from "./section-props";

export function DesignTokensSection({ number, id, title, desc, config }: SectionProps) {
  if (!config.vars?.groups?.length) return null;
  const tokenProps = { groups: config.vars.groups, flatVars: config.flatVars, semanticClasses: config.semanticClasses, semanticGroups: config.semanticGroups };
  const tabs = [
    { id: "tokens-core", title: "Core", content: <CoreTokensSection {...tokenProps} /> },
    { id: "tokens-hui", title: "Headless UI", content: <HUITokensSection groups={config.vars.groups} flatVars={config.flatVars} /> },
    { id: "tokens-extended", title: "Extended", content: <ExtendedTokensSection groups={config.vars.groups} flatVars={config.flatVars} /> },
  ];
  return (
    <CollapsibleSection number={number} id={id} title={title} desc={desc} defaultOpen={true}>
      <SubsectionTabs tabs={tabs} />
    </CollapsibleSection>
  );
}

export function GeneratedCssSection({ number, id, title, desc, cssSections }: SectionProps) {
  if (!cssSections) return null;
  return (
    <CollapsibleSection number={number} id={id} title={title} desc={desc} defaultOpen={true}>
      <CssViewer sections={cssSections} />
    </CollapsibleSection>
  );
}

export function ThemeConfigSection({ number, id, title, desc, styleGuideFiles, brandingYaml }: SectionProps) {
  if (!styleGuideFiles || !brandingYaml) return null;
  return (
    <CollapsibleSection number={number} id={id} title={title} desc={desc} defaultOpen={true}>
      <YamlConfigViewer styleGuideFiles={styleGuideFiles} brandingYaml={brandingYaml} />
    </CollapsibleSection>
  );
}

export function SnippetsSection({ number, id, title, desc, config }: SectionProps) {
  if (!config.cssSnippets?.length && !config.jsxSnippets?.length) return null;
  const hasBoth = config.cssSnippets?.length > 0 && config.jsxSnippets?.length > 0;
  if (!hasBoth) {
    return (
      <CollapsibleSection number={number} id={id} title={title} desc={desc} defaultOpen={true}>
        {config.cssSnippets?.length > 0 ? <CssSnippetsPanel config={config} /> : <JsxSnippetsPanel config={config} />}
      </CollapsibleSection>
    );
  }
  const tabs = [
    { id: "snippets-css", title: `CSS (${config.cssSnippets.length})`, content: <CssSnippetsPanel config={config} /> },
    { id: "snippets-jsx", title: `JSX (${config.jsxSnippets.length})`, content: <JsxSnippetsPanel config={config} /> },
  ];
  return (
    <CollapsibleSection number={number} id={id} title={title} desc={desc} defaultOpen={true}>
      <SubsectionTabs tabs={tabs} />
    </CollapsibleSection>
  );
}

export function OverridesSection({ number, id, title, desc }: SectionProps) {
  return (
    <CollapsibleSection number={number} id={id} title={title} desc={desc} defaultOpen={true}>
      <OverrideManager />
    </CollapsibleSection>
  );
}
