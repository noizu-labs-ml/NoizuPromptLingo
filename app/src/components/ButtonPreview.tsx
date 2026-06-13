"use client";

import type { SemanticClass } from "@styleguide-engine/lib/types";
import { useSemanticSelection } from "./SemanticSelectionContext";

interface Props {
  semanticClasses: SemanticClass[];
}

export function ButtonPreview({ semanticClasses }: Props) {
  const { selected } = useSemanticSelection();
  const sc = semanticClasses.find((c) => c.name === selected) || semanticClasses[0];
  if (!sc) return null;

  return (
    <div
      style={{
        display: "flex",
        flexWrap: "wrap",
        gap: "var(--space-1)",
        padding: "var(--space-2) 0",
        alignItems: "center",
      }}
    >
      <button className={`btn ${sc.class}`}>{sc.title}</button>
      <button className={`btn btn-sm ${sc.class}`}>Small</button>
      <button className={`btn btn-lg ${sc.class}`}>Large</button>
      <button className={`btn btn-outline ${sc.class}`}>Outline</button>
      <button className={`btn btn-ghost ${sc.class}`}>Ghost</button>
      <button className={`btn accent-${sc.class}`}>Accent</button>
      <button className={`btn ${sc.class} rounded`}>Rounded</button>
      <button className={`btn ${sc.class} drop-shadow`}>Shadow</button>
    </div>
  );
}
