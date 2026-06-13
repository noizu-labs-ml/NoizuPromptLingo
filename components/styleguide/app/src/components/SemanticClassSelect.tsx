"use client";

import { useState } from "react";
import { Combobox, ComboboxInput, ComboboxButton, ComboboxOptions, ComboboxOption } from "@headlessui/react";
import type { SemanticClass, ColorGroup } from "@styleguide-engine/lib/types";
import { useSemanticSelection } from "./SemanticSelectionContext";

/** Unified entry for the combobox — semantic class or palette color */
interface Entry {
  name: string;
  title: string;
  group: string;
  /** CSS class to apply as a pill (semantic classes have generated rules) */
  cssClass?: string;
  /** Raw CSS color value for swatch (palette colors) */
  swatch?: string;
}

interface Props {
  semanticClasses: SemanticClass[];
  colorPalette?: ColorGroup[];
}

/** Groups we pull palette colors from */
const PALETTE_GROUPS = new Set(["Brand", "Palette", "Semantic States"]);

function buildEntries(semanticClasses: SemanticClass[], colorPalette?: ColorGroup[]): Entry[] {
  const entries: Entry[] = semanticClasses.map((sc) => ({
    name: sc.name,
    title: sc.title,
    group: "Semantic",
    cssClass: sc.class,
  }));

  if (colorPalette) {
    for (const cg of colorPalette) {
      if (!PALETTE_GROUPS.has(cg.group)) continue;
      for (const c of cg.colors) {
        const slug = c.name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");
        // Skip if a semantic class already covers this name
        if (entries.some((e) => e.name === slug)) continue;
        entries.push({
          name: slug,
          title: `${cg.group}: ${c.name}`,
          group: cg.group,
          swatch: c.value,
        });
      }
    }
  }

  return entries;
}

export function SemanticClassSelect({ semanticClasses, colorPalette }: Props) {
  const { selected, setSelected } = useSemanticSelection();
  const entries = buildEntries(semanticClasses, colorPalette);
  const active = entries.find((e) => e.name === selected) || entries[0];
  const [query, setQuery] = useState("");

  const q = query.toLowerCase();
  const filtered = q
    ? entries.filter((e) =>
        e.name.includes(q) || e.title.toLowerCase().includes(q) || e.group.toLowerCase().includes(q)
      )
    : entries;

  if (!active) return null;

  return (
    <Combobox
      value={selected}
      onChange={(v) => { if (v) setSelected(v); }}
    >
      <div className="relative inline-block">
        <div className="flex items-center gap-[var(--space-1)]">
          {/* Active pill */}
          {active.cssClass ? (
            <span
              className={`btn btn-sm ${active.cssClass}`}
              style={{ pointerEvents: "none", minWidth: 0, padding: "2px 8px", fontSize: "var(--font-size-xs)" }}
            >
              {active.name}
            </span>
          ) : (
            <span
              className="btn btn-sm"
              style={{ pointerEvents: "none", minWidth: 0, padding: "2px 8px", fontSize: "var(--font-size-xs)", borderColor: "var(--border)" }}
            >
              <span
                className="inline-block w-2.5 h-2.5 rounded-full mr-1 align-middle"
                style={{ background: active.swatch }}
              />
              {active.name}
            </span>
          )}
          <div className="relative">
            <ComboboxInput
              className="hui combo-input"
              style={{ minWidth: 200 }}
              displayValue={(name: string) => entries.find((e) => e.name === name)?.name ?? name}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search classes & colors..."
            />
            <ComboboxButton className="hui combo-btn">
              <svg width="12" height="7" viewBox="0 0 12 7" fill="none" className="shrink-0">
                <path d="M1 1l5 5 5-5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </ComboboxButton>
          </div>
        </div>
        <ComboboxOptions className="hui combo-options" style={{ minWidth: 300, maxHeight: 320 }}>
          {filtered.length === 0 ? (
            <div className="px-[var(--space-2)] py-[var(--space-1)] text-[length:var(--font-size-sm)] text-[var(--text-muted)]">
              No matches
            </div>
          ) : (
            filtered.map((entry) => (
              <ComboboxOption key={entry.name} value={entry.name} className="hui combo-option">
                <span className="flex items-center gap-[var(--space-1)] w-full">
                  {entry.cssClass ? (
                    <span
                      className={`btn btn-sm ${entry.cssClass}`}
                      style={{ pointerEvents: "none", minWidth: 0, padding: "1px 6px", fontSize: "10px", lineHeight: "1.4" }}
                    >
                      {entry.name}
                    </span>
                  ) : (
                    <span className="flex items-center gap-1 shrink-0">
                      <span
                        className="inline-block w-3 h-3 rounded-full border border-[var(--border)]"
                        style={{ background: entry.swatch }}
                      />
                      <span className="font-mono text-[10px] font-semibold">{entry.name}</span>
                    </span>
                  )}
                  <span className="text-[length:var(--font-size-xs)] text-[var(--text-muted)] truncate">
                    {entry.title}
                  </span>
                </span>
              </ComboboxOption>
            ))
          )}
        </ComboboxOptions>
      </div>
    </Combobox>
  );
}
