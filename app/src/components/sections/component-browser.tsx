import { CollapsibleSection } from "@styleguide-engine/components/CollapsibleSection";
import { ComponentBrowser } from "@styleguide-engine/components/ComponentBrowser";
import type { SectionProps } from "./section-props";

export function ComponentBrowserSection({ number, id, title, desc, config }: SectionProps) {
  return (
    <CollapsibleSection number={number} id={id} title={title} desc={desc} defaultOpen={true}>
      <ComponentBrowser semanticClasses={config.semanticClasses} embedded />
    </CollapsibleSection>
  );
}
