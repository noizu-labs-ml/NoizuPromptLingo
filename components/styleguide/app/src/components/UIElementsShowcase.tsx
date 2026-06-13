"use client";

import { useState } from "react";
import type { SemanticClass, SimpleDesignSection, ColorGroup } from "@styleguide-engine/lib/types";
import { CardShowcase } from "./CardShowcase";
import { ButtonShowcase } from "./ButtonShowcase";
import { FormsShowcase } from "./FormsShowcase";
import { HUIShowcase } from "./HUIShowcase";
import { SemanticClassSummary } from "./SemanticClassSummary";

interface Props {
  semanticClasses: SemanticClass[];
  formsSection?: SimpleDesignSection;
  colorPalette?: ColorGroup[];
}

const TABS = [
  { id: "cards", label: "Cards" },
  { id: "buttons", label: "Buttons" },
  { id: "forms", label: "Forms" },
  { id: "controls", label: "Controls" },
] as const;

type TabId = (typeof TABS)[number]["id"];

export function UIElementsShowcase({ semanticClasses, formsSection, colorPalette }: Props) {
  const [tab, setTab] = useState<TabId>("cards");

  return (
    <div>
      <SemanticClassSummary semanticClasses={semanticClasses} colorPalette={colorPalette} />

      <div className="hui tab-list" style={{ marginBottom: "var(--space-3)" }}>
        {TABS.map((t) => (
          <button
            key={t.id}
            className={`hui tab${tab === t.id ? " hui-tab-selected" : ""}`}
            onClick={() => setTab(t.id)}
            data-selected={tab === t.id || undefined}
          >
            {t.label}
          </button>
        ))}
      </div>

      {tab === "cards" && <CardShowcase semanticClasses={semanticClasses} />}
      {tab === "buttons" && <ButtonShowcase semanticClasses={semanticClasses} />}
      {tab === "forms" && formsSection && <FormsShowcase section={formsSection} />}
      {tab === "controls" && <HUIShowcase semanticClasses={semanticClasses} />}
    </div>
  );
}
