"use client";

import React from "react";

/**
 * MethodologySelector — Card-based picker for project methodologies with visual previews.
 *
 * @example
 * ```tsx
 * <MethodologySelector options={[{ id: "scrum", name: "Scrum", description: "Sprint-based iterative delivery" }]} selected="scrum" onChange={setMethodology} />
 * ```
 */

interface MethodologyOption { id: string; name: string; description?: string; icon?: string; }
type SelectorVariant = "compact" | "expanded";

interface MethodologySelectorProps {
  options: MethodologyOption[];
  selected?: string;
  onChange: (id: string) => void;
  variant?: SelectorVariant;
}

const defaultOptions: MethodologyOption[] = [
  { id: "scrum", name: "Scrum", description: "Sprint-based iterative delivery with ceremonies", icon: "🔄" },
  { id: "kanban", name: "Kanban", description: "Continuous flow with WIP limits", icon: "📋" },
  { id: "waterfall", name: "Waterfall", description: "Sequential phases with gate reviews", icon: "📐" },
  { id: "hybrid", name: "Hybrid", description: "Custom blend of methodologies", icon: "⚙" },
];

export function MethodologySelector({ options = defaultOptions, selected, onChange, variant = "expanded" }: MethodologySelectorProps) {
  if (variant === "compact") {
    return (
      <div style={{ display: "flex", gap: "4px", flexWrap: "wrap" }}>
        {options.map((opt) => {
          const active = opt.id === selected;
          return (
            <button key={opt.id} type="button" onClick={() => onChange(opt.id)} aria-pressed={active} style={{ display: "flex", alignItems: "center", gap: "4px", padding: "4px 12px", borderRadius: "999px", border: `1px solid ${active ? "var(--info, var(--blue))" : "var(--border)"}`, background: active ? "color-mix(in srgb, var(--info, var(--blue)) 10%, transparent)" : "var(--surface)", color: active ? "var(--info, var(--blue))" : "var(--text)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontWeight: active ? 600 : 400, cursor: "pointer" }}>
              {opt.icon && <span>{opt.icon}</span>}
              {opt.name}
            </button>
          );
        })}
      </div>
    );
  }

  // expanded — card grid
  return (
    <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(180px, 1fr))", gap: "var(--space-2)" }}>
      {options.map((opt) => {
        const active = opt.id === selected;
        return (
          <button key={opt.id} type="button" onClick={() => onChange(opt.id)} aria-pressed={active} style={{ padding: "var(--space-3)", borderRadius: "var(--radius, 6px)", border: `2px solid ${active ? "var(--info, var(--blue))" : "var(--border)"}`, background: active ? "color-mix(in srgb, var(--info, var(--blue)) 6%, transparent)" : "var(--surface)", cursor: "pointer", textAlign: "left", display: "flex", flexDirection: "column", gap: "6px" }}>
            {opt.icon && <span style={{ fontSize: "var(--font-size-xl, 22px)" }}>{opt.icon}</span>}
            <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontWeight: 600, color: active ? "var(--info, var(--blue))" : "var(--text)" }}>{opt.name}</span>
            {opt.description && <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)", lineHeight: 1.3 }}>{opt.description}</span>}
            {active && <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--info, var(--blue))", fontWeight: 600 }}>✓ Selected</span>}
          </button>
        );
      })}
    </div>
  );
}

export default MethodologySelector;
