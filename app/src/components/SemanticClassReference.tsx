"use client";

import { useState } from "react";
import type { SemanticClass, SemanticGroup } from "@styleguide-engine/lib/types";

interface Props {
  semanticClasses: SemanticClass[];
  semanticGroups: SemanticGroup[];
}

export function SemanticClassReference({ semanticClasses, semanticGroups }: Props) {
  const [search, setSearch] = useState("");

  const filtered = semanticClasses.filter(
    (sc) =>
      !search ||
      sc.name.includes(search.toLowerCase()) ||
      sc.title.toLowerCase().includes(search.toLowerCase()) ||
      sc.description.toLowerCase().includes(search.toLowerCase())
  );

  const renderCard = (sc: SemanticClass) => (
    <div key={sc.name} className={`card accent-${sc.class}`}>
      <div className="card-header">
        <h3 className="card-title">{sc.title}</h3>
        <span
          className={`text-${sc.class}`}
          style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", marginLeft: "auto" }}
        >
          {sc.name}
        </span>
      </div>
      <div className="card-body">
        <p style={{ fontSize: "var(--font-size-sm)", color: "var(--text-secondary)", lineHeight: 1.6, marginBottom: "var(--space-1)" }}>
          {sc.description}
        </p>
        <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-half)" }}>
          {[`.${sc.class}`, `.accent-${sc.class}`, `.text-${sc.class}`].map((cls) => (
            <code
              key={cls}
              style={{
                fontFamily: "var(--font-mono)",
                fontSize: "var(--font-size-xs)",
                color: "var(--text-muted)",
                background: "var(--surface-alt)",
                padding: "var(--space-half) var(--space-1)",
                border: "1px solid var(--border)",
              }}
            >
              {cls}
            </code>
          ))}
        </div>
        {sc.vars.filter((v) => !["accent", "background", "color"].includes(v.name)).length > 0 && (
          <div style={{ marginTop: "var(--space-1)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)" }}>
            {sc.vars
              .filter((v) => !["accent", "background", "color"].includes(v.name))
              .map((v) => v.name)
              .join(", ")}
          </div>
        )}
      </div>
    </div>
  );

  return (
    <div>
      <input
        type="text"
        placeholder="Filter semantic classes..."
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        style={{
          width: "100%",
          padding: "var(--space-1) var(--space-2)",
          fontSize: "var(--font-size-sm)",
          fontFamily: "var(--font-mono)",
          border: "1px solid var(--card-border-color)",
          borderRadius: "var(--radius)",
          background: "var(--surface)",
          color: "var(--base-font-color)",
          marginBottom: "var(--space-3)",
        }}
      />

      <div className="card-grid">{filtered.map(renderCard)}</div>
      {filtered.length === 0 && (
        <p style={{ color: "var(--text-muted)", fontSize: "var(--font-size-sm)", marginTop: "var(--space-2)" }}>
          No matching semantic classes.
        </p>
      )}
    </div>
  );
}
