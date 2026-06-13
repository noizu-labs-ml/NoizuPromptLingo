import type { SimpleDesignSection, DesignComponent } from "@styleguide-engine/lib/types";

interface Props {
  sections: SimpleDesignSection[];
}

function PrincipleRow({ label, colorClass, text, italic }: { label: string; colorClass: string; text: string; italic?: boolean }) {
  return (
    <div className="sg-principle-row">
      <div className={`sg-principle-label ${colorClass}`}>
        {label}
      </div>
      <p className={`sg-principle-text${italic ? " muted" : ""}`}>
        {text}
      </p>
    </div>
  );
}

function ComponentSection({ component, isLast }: { component: DesignComponent; isLast: boolean }) {
  return (
    <div>
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          gap: "var(--space-2)",
          padding: "var(--space-3) 0",
        }}
      >
        <h3
          style={{
            fontSize: "var(--font-size-md)",
            fontWeight: 700,
            letterSpacing: "-0.01em",
            marginBottom: "var(--space-1)",
          }}
        >
          {component.title}
        </h3>
        <PrincipleRow label="Principle" colorClass="text-principle" text={component.principle} />
        <PrincipleRow label="Approach"  colorClass="text-approach"  text={component.approach} />
        <PrincipleRow label="Why"       colorClass="text-why"       text={component.rationale} italic />
      </div>
      {!isLast && (
        <div style={{ borderTop: "1px solid var(--border)" }} />
      )}
    </div>
  );
}

export function DesignSectionShowcase({ sections }: Props) {
  if (!sections.length) return null;

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-6)" }}>
      {sections.map((section) => (
        <div key={section.name}>
          <p style={{ fontSize: "var(--font-size-sm)", color: "var(--text-muted)", marginBottom: "var(--space-2)", maxWidth: 640 }}>
            {section.description}
          </p>
          <div>
            {section.components.map((c, i) => (
              <ComponentSection
                key={c.name}
                component={c}
                isLast={i === section.components.length - 1}
              />
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}
