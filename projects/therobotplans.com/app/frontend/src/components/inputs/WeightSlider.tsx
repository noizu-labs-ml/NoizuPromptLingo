"use client";

import React from "react";

/**
 * WeightSlider — Set of linked sliders that must sum to a target (default 100%).
 *
 * @example
 * ```tsx
 * <WeightSlider items={[{ id: "a", label: "Accuracy", value: 40 }, { id: "b", label: "Speed", value: 60 }]} onChange={setWeights} mustSumTo={100} />
 * ```
 */

interface WeightItem { id: string; label: string; value: number; }

interface WeightSliderProps {
  items: WeightItem[];
  onChange: (items: WeightItem[]) => void;
  mustSumTo?: number;
  minValue?: number;
  variant?: "compact" | "expanded";
}

export function WeightSlider({ items, onChange, mustSumTo = 100, minValue = 0, variant = "expanded" }: WeightSliderProps) {
  const currentSum = items.reduce((s, i) => s + i.value, 0);
  const valid = currentSum === mustSumTo;

  const handleChange = (id: string, newValue: number) => {
    const clamped = Math.max(minValue, Math.min(mustSumTo, newValue));
    const idx = items.findIndex((i) => i.id === id);
    if (idx === -1) return;

    const delta = clamped - items[idx].value;
    const others = items.filter((_, i) => i !== idx);
    const othersSum = others.reduce((s, i) => s + i.value, 0);

    const updated = items.map((item, i) => {
      if (i === idx) return { ...item, value: clamped };
      if (othersSum === 0) return { ...item, value: Math.round((mustSumTo - clamped) / others.length) };
      const proportion = item.value / othersSum;
      return { ...item, value: Math.max(minValue, Math.round(item.value - delta * proportion)) };
    });

    // Fix rounding errors
    const newSum = updated.reduce((s, i) => s + i.value, 0);
    if (newSum !== mustSumTo && updated.length > 1) {
      const lastOther = updated.findIndex((_, i) => i !== idx);
      if (lastOther >= 0) updated[lastOther].value += mustSumTo - newSum;
    }

    onChange(updated);
  };

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: variant === "compact" ? "4px" : "var(--space-2)" }}>
      {items.map((item) => (
        <div key={item.id} style={{ display: "flex", alignItems: "center", gap: "8px" }}>
          <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text)", width: variant === "compact" ? 60 : 100, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap", flexShrink: 0 }}>{item.label}</span>
          <input type="range" min={minValue} max={mustSumTo} value={item.value} onChange={(e) => handleChange(item.id, parseInt(e.target.value))} style={{ flex: 1, accentColor: "var(--info, var(--blue))" }} aria-label={`${item.label} weight`} />
          <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", fontWeight: 600, color: "var(--text)", width: 36, textAlign: "right" }}>{item.value}%</span>
        </div>
      ))}
      {/* Sum indicator */}
      <div style={{ display: "flex", justifyContent: "flex-end", gap: "4px" }}>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: valid ? "var(--success)" : "var(--error)", fontWeight: 600 }}>
          {valid ? `✓ Total: ${currentSum}%` : `⚠ Total: ${currentSum}% (must be ${mustSumTo}%)`}
        </span>
      </div>
    </div>
  );
}

export default WeightSlider;
