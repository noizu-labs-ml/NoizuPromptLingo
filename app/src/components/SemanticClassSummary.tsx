"use client";

import type { SemanticClass, ColorGroup } from "@styleguide-engine/lib/types";
import { useSemanticSelection } from "./SemanticSelectionContext";
import { SemanticClassSelect } from "./SemanticClassSelect";

const QUICK_PICK = ["primary", "danger", "success", "warning", "info", "regal", "brand"];

interface Props {
  semanticClasses: SemanticClass[];
  colorPalette?: ColorGroup[];
}

export function SemanticClassSummary({ semanticClasses, colorPalette }: Props) {
  const { selected, setSelected } = useSemanticSelection();

  const quickClasses = QUICK_PICK
    .map((name) => semanticClasses.find((sc) => sc.name === name))
    .filter((sc): sc is SemanticClass => !!sc);

  return (
    <div className="flex items-center gap-[var(--space-1)] py-[var(--space-2)] flex-wrap">
      <div className="hidden @sm:flex flex-wrap gap-[var(--space-1)] items-center">
        {quickClasses.map((sc) => (
          <button
            key={sc.name}
            className={`btn btn-sm text-[length:var(--font-size-xs)] ${sc.class}${selected === sc.name ? " btn-selected" : ""}`}
            onClick={() => setSelected(sc.name)}
          >
            {sc.name}
          </button>
        ))}
      </div>
      <div className="hidden @sm:block w-px self-stretch bg-border mx-[var(--space-half)]" />
      <div className="shrink-0">
        <SemanticClassSelect semanticClasses={semanticClasses} colorPalette={colorPalette} />
      </div>
    </div>
  );
}
