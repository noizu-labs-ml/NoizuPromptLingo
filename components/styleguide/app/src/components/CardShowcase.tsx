"use client";

import type { SemanticClass } from "@styleguide-engine/lib/types";
import { useSemanticSelection } from "./SemanticSelectionContext";
import { SemanticClassSelect } from "./SemanticClassSelect";
import { PreviewCode } from "./pkg/preview-code";

interface Props {
  semanticClasses: SemanticClass[];
}

interface CardVariant {
  title: string;
  note: string;
  appliedTo: string;
  cardClass: (cls: string) => string;
  headerClass?: (cls: string) => string;
  bodyClass?: (cls: string) => string;
  footerClass?: (cls: string) => string;
  tagClass?: (cls: string) => string;
}

const VARIANTS: CardVariant[] = [
  { title: "Accent Only", note: "Border and shadow only. Default text colors.", appliedTo: ".card",
    cardClass: (c) => `card accent-${c}` },
  { title: "Card Level Only", note: "Semantic class only. Colors and bg.", appliedTo: ".card",
    cardClass: (c) => `card ${c}` },
  { title: "Header Level", note: "Semantic class only on header element.", appliedTo: ".card-header",
    cardClass: () => "card", headerClass: (c) => `card-header ${c}`, tagClass: (c) => `card-tag inline ${c}` },
  { title: "Body Level", note: "Semantic class only on body element.", appliedTo: ".card-body",
    cardClass: () => "card", bodyClass: (c) => `card-body ${c}`, tagClass: (c) => `card-tag inline ${c}` },
  { title: "Footer Level", note: "Semantic class only on footer element.", appliedTo: ".card-footer",
    cardClass: () => "card", footerClass: (c) => `card-footer ${c}`, tagClass: (c) => `card-tag inline ${c}` },
  { title: "Accent + Rounded", note: "Accent border with rounded corners.", appliedTo: ".card",
    cardClass: (c) => `card accent-${c} rounded` },
  { title: "Accent + Shadow", note: "Accent border with colored drop shadow.", appliedTo: ".card",
    cardClass: (c) => `card accent-${c} drop-shadow` },
  { title: "Semantic + Shadow", note: "Semantic colors with colored drop shadow.", appliedTo: ".card",
    cardClass: (c) => `card ${c} drop-shadow` },
];

function cardToHtml(v: CardVariant, sc: SemanticClass): string {
  const cls = sc.class;
  const tag = v.tagClass ? v.tagClass(cls) : "card-tag inline";
  const hdr = v.headerClass ? v.headerClass(cls) : "card-header";
  const bdy = v.bodyClass ? v.bodyClass(cls) : "card-body";
  const ftr = v.footerClass ? v.footerClass(cls) : "card-footer";
  return `<div class="${v.cardClass(cls)}">
  <div class="${hdr}">
    <h3 class="card-title">${v.title}</h3>
    <div class="${tag}">${v.cardClass(cls).replace("card ", "")}</div>
  </div>
  <div class="${bdy}">
    <p>${sc.description}</p>
    <p class="card-body-note">${v.note}</p>
  </div>
  <div class="${ftr}">
    <span>Applied to: ${v.appliedTo}</span>
    <span class="ml-auto">${sc.name}</span>
  </div>
</div>`;
}

export function CardShowcase({ semanticClasses }: Props) {
  const { selected: selectedClass, setSelected: setSelectedClass } = useSemanticSelection();

  const sc =
    semanticClasses.find((c) => c.name === selectedClass) || semanticClasses[0];

  if (!sc) return null;

  const allCode = VARIANTS.map((v) => cardToHtml(v, sc)).join("\n\n");

  return (
    <div>
      <div style={{ marginBottom: "var(--space-3)" }}>
        <SemanticClassSelect semanticClasses={semanticClasses} />
      </div>

      <PreviewCode html={allCode}>
        <div className="card-grid">
          {VARIANTS.map((v) => {
            const cls = sc.class;
            const tag = v.tagClass ? v.tagClass(cls) : "card-tag inline";
            const hdr = v.headerClass ? v.headerClass(cls) : "card-header";
            const bdy = v.bodyClass ? v.bodyClass(cls) : "card-body";
            const ftr = v.footerClass ? v.footerClass(cls) : "card-footer";
            return (
              <div key={v.title} className={v.cardClass(cls)}>
                <div className={hdr}>
                  <h3 className="card-title">{v.title}</h3>
                  <div className={tag}>{v.cardClass(cls).replace("card ", "")}</div>
                </div>
                <div className={bdy}>
                  <p>{sc.description}</p>
                  <p className="card-body-note">{v.note}</p>
                </div>
                <div className={ftr}>
                  <span>Applied to: {v.appliedTo}</span>
                  <span className="ml-auto">{sc.name}</span>
                </div>
              </div>
            );
          })}
        </div>
      </PreviewCode>
    </div>
  );
}
