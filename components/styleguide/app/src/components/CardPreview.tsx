"use client";

import type { SemanticClass } from "@styleguide-engine/lib/types";
import { useSemanticSelection } from "./SemanticSelectionContext";

interface Props {
  semanticClasses: SemanticClass[];
}

export function CardPreview({ semanticClasses }: Props) {
  const { selected } = useSemanticSelection();
  const active = semanticClasses.find((sc) => sc.name === selected) || semanticClasses[0];
  if (!active) return null;

  const neighbours = [
    semanticClasses[(semanticClasses.indexOf(active) + 1) % semanticClasses.length],
    semanticClasses[(semanticClasses.indexOf(active) + 2) % semanticClasses.length],
  ];
  const samples = [active, ...neighbours];

  return (
    <div
      style={{
        display: "grid",
        gridTemplateColumns: "repeat(3, 1fr)",
        gap: "var(--card-grid-gap)",
        padding: "var(--space-2) 0",
      }}
    >
      {samples.map((sc) => (
        <div key={sc.name} className={`card ${sc.class}`}>
          <div className="card-header">
            <h3 className="card-title">{sc.title}</h3>
          </div>
          <div className="card-body">
            <p style={{ fontSize: "var(--font-size-sm)" }}>{sc.description}</p>
          </div>
        </div>
      ))}
    </div>
  );
}
