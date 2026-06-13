"use client";

import React from "react";
import type { LayoutMode, GraphFilters, FilterPreset } from "../ProjectGraph.types";

/**
 * GraphToolbar — Top control bar with zoom controls, fit-view, layout switcher,
 * filter toggle, and preset tabs. (Architecture §4.1, Spec §6.5, §9)
 */

interface GraphToolbarProps {
  layout: LayoutMode;
  onLayoutChange: (layout: LayoutMode) => void;
  onFitView: () => void;
  onZoomIn: () => void;
  onZoomOut: () => void;
  filtersActive: boolean;
  onToggleFilters: () => void;
  presets?: FilterPreset[];
  activePresetId?: string;
  onPresetSelect?: (preset: FilterPreset) => void;
}

const LAYOUT_OPTIONS: { value: LayoutMode; label: string; shortcut: string }[] = [
  { value: "ltr", label: "LTR", shortcut: "1" },
  { value: "radial", label: "Radial", shortcut: "2" },
  { value: "top-down", label: "Top-Down", shortcut: "3" },
  { value: "force", label: "Force", shortcut: "4" },
];

const btnBase: React.CSSProperties = {
  padding: "3px 10px",
  borderRadius: 4,
  border: "1px solid var(--border)",
  background: "none",
  color: "var(--text-secondary)",
  fontFamily: "var(--font-mono)",
  fontSize: "var(--font-size-2xs, 10px)",
  cursor: "pointer",
  lineHeight: 1.4,
};

const btnActive: React.CSSProperties = {
  ...btnBase,
  background: "color-mix(in srgb, var(--info, var(--blue)) 10%, transparent)",
  color: "var(--info, var(--blue))",
  borderColor: "var(--info, var(--blue))",
};

export function GraphToolbar({
  layout,
  onLayoutChange,
  onFitView,
  onZoomIn,
  onZoomOut,
  filtersActive,
  onToggleFilters,
  presets,
  activePresetId,
  onPresetSelect,
}: GraphToolbarProps) {
  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: "6px",
        padding: "6px 10px",
        borderBottom: "1px solid var(--border)",
        background: "var(--surface-alt, var(--surface))",
        flexWrap: "wrap",
      }}
      role="toolbar"
      aria-label="Graph controls"
    >
      {/* Preset tabs */}
      {presets && presets.length > 0 && (
        <div style={{ display: "flex", gap: "2px", marginRight: 8 }}>
          {presets.map((p) => (
            <button
              key={p.id}
              type="button"
              style={activePresetId === p.id ? btnActive : btnBase}
              onClick={() => onPresetSelect?.(p)}
              aria-pressed={activePresetId === p.id}
            >
              {p.label}
            </button>
          ))}
        </div>
      )}

      {/* Layout switcher */}
      <div
        style={{
          display: "flex",
          gap: "1px",
          border: "1px solid var(--border)",
          borderRadius: 4,
          overflow: "hidden",
        }}
        role="radiogroup"
        aria-label="Layout mode"
      >
        {LAYOUT_OPTIONS.map((opt) => (
          <button
            key={opt.value}
            type="button"
            role="radio"
            aria-checked={layout === opt.value}
            title={`${opt.label} layout (${opt.shortcut})`}
            style={{
              padding: "3px 8px",
              border: "none",
              background: layout === opt.value
                ? "color-mix(in srgb, var(--info, var(--blue)) 12%, transparent)"
                : "none",
              color: layout === opt.value ? "var(--info, var(--blue))" : "var(--text-muted)",
              fontFamily: "var(--font-mono)",
              fontSize: "var(--font-size-2xs, 10px)",
              fontWeight: layout === opt.value ? 600 : 400,
              cursor: "pointer",
            }}
            onClick={() => onLayoutChange(opt.value)}
          >
            {opt.label}
          </button>
        ))}
      </div>

      {/* Separator */}
      <div style={{ width: 1, height: 18, background: "var(--border)", margin: "0 4px" }} />

      {/* Zoom controls */}
      <button type="button" style={btnBase} onClick={onZoomIn} title="Zoom in" aria-label="Zoom in">
        +
      </button>
      <button type="button" style={btnBase} onClick={onZoomOut} title="Zoom out" aria-label="Zoom out">
        −
      </button>
      <button type="button" style={btnBase} onClick={onFitView} title="Fit view (F)" aria-label="Fit view">
        Fit
      </button>

      {/* Separator */}
      <div style={{ width: 1, height: 18, background: "var(--border)", margin: "0 4px" }} />

      {/* Filter toggle */}
      <button
        type="button"
        style={filtersActive ? btnActive : btnBase}
        onClick={onToggleFilters}
        aria-pressed={filtersActive}
        title="Toggle filter panel"
      >
        Filters {filtersActive ? "ON" : "OFF"}
      </button>

      {/* Spacer */}
      <div style={{ flex: 1 }} />

      {/* Legend placeholder */}
      <span
        style={{
          fontFamily: "var(--font-mono)",
          fontSize: "var(--font-size-2xs, 10px)",
          color: "var(--text-muted)",
        }}
      >
        1-4: layout · F: fit · Esc: deselect
      </span>
    </div>
  );
}

export default GraphToolbar;
