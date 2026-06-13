"use client";

import type { SimpleDesignSection, DesignComponent } from "@styleguide-engine/lib/types";
import { Subsection } from "./pkg/subsection";
import { CheckboxRadioDemo } from "@styleguide-engine/components/demos/CheckboxRadioDemo";
import {
  TextInputDemo,
  SelectDemo,
  TextareaDemo,
  FormLayoutDemo,
  ValidationDemo,
} from "@styleguide-engine/components/demos/FormFieldDemos";

interface Props {
  section: SimpleDesignSection;
}

const DEMOS: Record<string, React.ReactNode> = {
  "text-input":     <TextInputDemo />,
  "select":         <SelectDemo />,
  "checkbox-radio": <CheckboxRadioDemo />,
  "textarea":       <TextareaDemo />,
  "form-layout":    <FormLayoutDemo />,
  "validation":     <ValidationDemo />,
};

// ─── Single form section ───

function FormSection({ component }: { component: DesignComponent }) {
  const demo = DEMOS[component.name];
  const slug = `form-${component.name}`;

  return (
    <Subsection id={slug} title={component.title}>
      <div className="flex flex-col gap-[var(--space-3)]">
        {demo && <div className="sg-demo-box">{demo}</div>}
        <div className="flex flex-col gap-[var(--space-2)]">
          <PrincipleRow label="Principle" colorClass="text-principle" text={component.principle} />
          <PrincipleRow label="Approach"  colorClass="text-approach"  text={component.approach} />
          <PrincipleRow label="Why"       colorClass="text-why"       text={component.rationale} italic />
        </div>
      </div>
    </Subsection>
  );
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

// ─── Main component ───

export function FormsShowcase({ section }: Props) {
  return (
    <div>
      <p className="sg-description">
        {section.description}
      </p>
      <div>
        {section.components.map((c, i) => (
          <FormSection
            key={c.name}
            component={c}
          />
        ))}
      </div>
    </div>
  );
}
