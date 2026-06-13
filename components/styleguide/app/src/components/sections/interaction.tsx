import { CollapsibleSection } from "@styleguide-engine/components/CollapsibleSection";
import { SubsectionTabs } from "@styleguide-engine/components/SubsectionTabs";
import { SemanticClassReference } from "@styleguide-engine/components/SemanticClassReference";
import { SemanticClassSummary } from "@styleguide-engine/components/SemanticClassSummary";
import { StatusIndicatorShowcase } from "@styleguide-engine/components/StatusIndicatorShowcase";
import { CardShowcase } from "@styleguide-engine/components/CardShowcase";
import { ButtonShowcase } from "@styleguide-engine/components/ButtonShowcase";
import { FormsShowcase } from "@styleguide-engine/components/FormsShowcase";
import { HUIShowcase } from "@styleguide-engine/components/HUIShowcase";
import { CardPreview } from "@styleguide-engine/components/CardPreview";
import { ButtonPreview } from "@styleguide-engine/components/ButtonPreview";
import { Badge, BadgeShowcase } from "@styleguide-engine/components/demos/BadgeShowcase";
import type { CssSnippet } from "@styleguide-engine/lib/types";
import type { SectionProps } from "./section-props";

export function SemanticClassesSection({ number, id, title, desc, config }: SectionProps) {
  if (!config.semanticClasses?.length) return null;
  return (
    <CollapsibleSection
      number={number} id={id} title={title} desc={desc} defaultOpen={true}
      collapsedContent={<SemanticClassSummary semanticClasses={config.semanticClasses} colorPalette={config.colorPalette} />}
    >
      <SemanticClassReference semanticClasses={config.semanticClasses} semanticGroups={config.semanticGroups} />
    </CollapsibleSection>
  );
}

export function StatusIndicatorsSection({ number, id, title, desc, config }: SectionProps) {
  const section = config.designSections.find((s) => s.name === "status-indicators");
  if (!section) return null;
  return (
    <CollapsibleSection number={number} id={id} title={title} desc={desc} defaultOpen={true}>
      <StatusIndicatorShowcase section={section} />
    </CollapsibleSection>
  );
}

export function UIElementsSection({ number, id, title, desc, config }: SectionProps) {
  if (!config.semanticClasses?.length) return null;
  const formsSection = config.designSections.find((s) => s.name === "forms");
  const tabs = [
    { id: "ui-cards", title: "Cards", content: <CardShowcase semanticClasses={config.semanticClasses} /> },
    { id: "ui-buttons", title: "Buttons", content: <ButtonShowcase semanticClasses={config.semanticClasses} /> },
    ...(formsSection ? [{ id: "ui-forms", title: "Forms", content: <FormsShowcase section={formsSection} /> }] : []),
    { id: "ui-controls", title: "Controls", content: <HUIShowcase semanticClasses={config.semanticClasses} /> },
  ];
  return (
    <CollapsibleSection
      number={number} id={id} title={title} desc={desc} defaultOpen={true}
      collapsedContent={
        <div style={{ display: "flex", gap: "var(--space-2)", padding: "var(--space-2) 0" }}>
          <CardPreview semanticClasses={config.semanticClasses} />
          <ButtonPreview semanticClasses={config.semanticClasses} />
        </div>
      }
    >
      <SemanticClassSummary semanticClasses={config.semanticClasses} colorPalette={config.colorPalette} />
      <SubsectionTabs tabs={tabs} />
    </CollapsibleSection>
  );
}

export function CustomComponentsSection({ number, id, title, desc, config }: SectionProps) {
  // Read CSS snippet definitions from theme config for the specs table
  const snippetNames = ["agent-badge", "priority-dot", "status-pill"];
  const snippets = (config.cssSnippets || []).filter((s) =>
    snippetNames.includes(s.slug)
  );

  return (
    <CollapsibleSection number={number} id={id} title={title} desc={desc} defaultOpen={true}>
      {/* ── Badge Component ── */}
      <div style={{ marginBottom: "var(--space-6)" }}>
        <div style={{ display: "flex", alignItems: "center", gap: "var(--space-2)", marginBottom: "var(--space-1)" }}>
          <h4 style={{
            fontFamily: "var(--font-heading, var(--font-body))",
            fontSize: "var(--font-size-lg)",
            fontWeight: 600,
            color: "var(--text)",
            margin: 0,
          }}>
            Badge
          </h4>
          <Badge label="T0" color="blue" variant="filled" size="sm" />
          <Badge label="9 dependents" color="violet" variant="subtle" size="sm" />
          <Badge label="11 screens" color="emerald" variant="subtle" size="sm" />
        </div>
        <p style={{
          fontFamily: "var(--font-body)",
          fontSize: "var(--font-size-sm)",
          color: "var(--text-secondary)",
          marginBottom: "var(--space-3)",
          maxWidth: 640,
        }}>
          Small label indicating type, source, methodology, or status with color coding.
          Used across 11 screens and depended on by 9 other components (item-card, project-card,
          agent-card, okr-node, template-card, time-block-card, deploy-summary, linked-items-section,
          approval-chain-display). The most foundational component in the system.
        </p>

        <BadgeShowcase />
      </div>

      {/* ── CSS Snippet Reference ── */}
      {snippets.length > 0 && (
        <div style={{ marginTop: "var(--space-4)" }}>
          <div style={{
            fontFamily: "var(--font-mono)",
            fontSize: "var(--font-size-xs)",
            fontWeight: 600,
            textTransform: "uppercase",
            letterSpacing: "0.06em",
            color: "var(--text-muted)",
            marginBottom: "var(--space-2)",
          }}>
            Related CSS Snippets
          </div>
          <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-2)" }}>
            {snippets.map((s: CssSnippet) => (
              <div
                key={s.slug}
                style={{
                  padding: "var(--space-2) var(--space-3)",
                  background: "var(--surface-alt, var(--bg))",
                  border: "1px solid var(--border)",
                  borderRadius: "var(--radius, 6px)",
                }}
              >
                <div style={{
                  fontFamily: "var(--font-mono)",
                  fontSize: "var(--font-size-sm)",
                  fontWeight: 600,
                  color: "var(--text)",
                  marginBottom: 2,
                }}>
                  .{s.slug}
                </div>
                <div style={{
                  fontSize: "var(--font-size-xs)",
                  color: "var(--text-muted)",
                }}>
                  {s.description}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </CollapsibleSection>
  );
}
