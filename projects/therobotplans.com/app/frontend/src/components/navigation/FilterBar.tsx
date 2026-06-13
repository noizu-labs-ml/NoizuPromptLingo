"use client";

import React, { useState } from "react";

/**
 * FilterBar — Horizontal bar of filter controls that narrow displayed content.
 * Used across 17 screens — the most referenced T1 component.
 *
 * @example
 * ```tsx
 * <FilterBar
 *   filters={[
 *     { id: "status", label: "Status", type: "select", options: ["open","closed","in-progress"] },
 *     { id: "priority", label: "Priority", type: "select", options: ["p0","p1","p2","p3"] },
 *     { id: "assignee", label: "Assignee", type: "select", options: ["Marcus","Sarah","PM Agent"] },
 *   ]}
 *   activeFilters={{ status: "open" }}
 *   onChange={(filters) => setFilters(filters)}
 * />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

type FilterType = "select" | "toggle" | "search";

interface FilterDefinition {
  id: string;
  label: string;
  type: FilterType;
  options?: string[];
  placeholder?: string;
}

interface FilterPreset {
  id: string;
  label: string;
  filters: Record<string, string | boolean>;
}

type FilterValues = Record<string, string | boolean>;

type FilterVariant = "inline" | "compact" | "expanded";

interface FilterBarProps {
  /** Filter definitions */
  filters: FilterDefinition[];
  /** Current active filter values */
  activeFilters?: FilterValues;
  /** Change callback */
  onChange: (filters: FilterValues) => void;
  /** Show clear-all button */
  showClear?: boolean;
  /** Saved filter presets */
  presets?: FilterPreset[];
  /** Display variant */
  variant?: FilterVariant;
}

// ── Sub-Components ──────────────────────────────────────────────

function FilterChip({
  label,
  value,
  onRemove,
}: {
  label: string;
  value: string | boolean;
  onRemove: () => void;
}) {
  return (
    <span
      style={{
        display: "inline-flex",
        alignItems: "center",
        gap: "4px",
        padding: "2px 8px",
        borderRadius: "999px",
        background: "color-mix(in srgb, var(--info, var(--blue)) 12%, transparent)",
        color: "var(--info, var(--blue))",
        fontFamily: "var(--font-body)",
        fontSize: "var(--font-size-2xs, 10px)",
        fontWeight: 500,
        lineHeight: 1,
      }}
    >
      <span style={{ color: "var(--text-muted)" }}>{label}:</span>
      <span style={{ fontWeight: 600 }}>{String(value)}</span>
      <button
        type="button"
        onClick={(e) => { e.stopPropagation(); onRemove(); }}
        aria-label={`Remove ${label} filter`}
        style={{
          background: "none",
          border: "none",
          padding: 0,
          cursor: "pointer",
          color: "var(--info, var(--blue))",
          fontSize: "var(--font-size-xs)",
          lineHeight: 1,
          marginLeft: 2,
        }}
      >
        ✕
      </button>
    </span>
  );
}

function SelectFilter({
  filter,
  value,
  onChange,
}: {
  filter: FilterDefinition;
  value?: string;
  onChange: (value: string) => void;
}) {
  return (
    <select
      aria-label={filter.label}
      value={value ?? ""}
      onChange={(e) => onChange(e.target.value)}
      style={{
        padding: "4px 8px",
        borderRadius: "var(--radius, 6px)",
        border: "1px solid var(--border)",
        background: "var(--surface)",
        color: "var(--text)",
        fontFamily: "var(--font-body)",
        fontSize: "var(--font-size-xs)",
        cursor: "pointer",
        minWidth: 80,
      }}
    >
      <option value="">{filter.label}</option>
      {filter.options?.map((opt) => (
        <option key={opt} value={opt}>{opt}</option>
      ))}
    </select>
  );
}

function ToggleFilter({
  filter,
  value,
  onChange,
}: {
  filter: FilterDefinition;
  value?: boolean;
  onChange: (value: boolean) => void;
}) {
  const active = !!value;
  return (
    <button
      type="button"
      aria-label={filter.label}
      aria-pressed={active}
      onClick={() => onChange(!active)}
      style={{
        padding: "4px 10px",
        borderRadius: "999px",
        border: `1px solid ${active ? "var(--info, var(--blue))" : "var(--border)"}`,
        background: active ? "color-mix(in srgb, var(--info, var(--blue)) 12%, transparent)" : "var(--surface)",
        color: active ? "var(--info, var(--blue))" : "var(--text-secondary)",
        fontFamily: "var(--font-body)",
        fontSize: "var(--font-size-xs)",
        fontWeight: active ? 600 : 400,
        cursor: "pointer",
        transition: "all 0.15s",
      }}
    >
      {filter.label}
    </button>
  );
}

function SearchFilter({
  filter,
  value,
  onChange,
}: {
  filter: FilterDefinition;
  value?: string;
  onChange: (value: string) => void;
}) {
  return (
    <input
      type="text"
      aria-label={filter.label}
      placeholder={filter.placeholder ?? `Search ${filter.label.toLowerCase()}...`}
      value={value ?? ""}
      onChange={(e) => onChange(e.target.value)}
      style={{
        padding: "4px 8px",
        borderRadius: "var(--radius, 6px)",
        border: "1px solid var(--border)",
        background: "var(--surface)",
        color: "var(--text)",
        fontFamily: "var(--font-body)",
        fontSize: "var(--font-size-xs)",
        minWidth: 120,
        outline: "none",
      }}
    />
  );
}

// ── Component ───────────────────────────────────────────────────

export function FilterBar({
  filters,
  activeFilters = {},
  onChange,
  showClear = true,
  presets,
  variant = "compact",
}: FilterBarProps) {
  const [showPresets, setShowPresets] = useState(false);

  const activeCount = Object.keys(activeFilters).filter((k) => activeFilters[k] !== "" && activeFilters[k] !== false).length;

  const handleChange = (id: string, value: string | boolean) => {
    const next = { ...activeFilters };
    if (value === "" || value === false) {
      delete next[id];
    } else {
      next[id] = value;
    }
    onChange(next);
  };

  const handleClear = () => onChange({});

  const handlePreset = (preset: FilterPreset) => {
    onChange(preset.filters);
    setShowPresets(false);
  };

  // ── Inline variant: chip-based active filters ──
  if (variant === "inline") {
    return (
      <div
        role="toolbar"
        aria-label="Active filters"
        style={{ display: "flex", flexWrap: "wrap", gap: "6px", alignItems: "center" }}
      >
        {Object.entries(activeFilters).map(([key, val]) => {
          const def = filters.find((f) => f.id === key);
          if (!val || val === "") return null;
          return (
            <FilterChip
              key={key}
              label={def?.label ?? key}
              value={val}
              onRemove={() => handleChange(key, "")}
            />
          );
        })}
        {activeCount > 0 && showClear && (
          <button
            type="button"
            onClick={handleClear}
            style={{
              background: "none",
              border: "none",
              color: "var(--text-muted)",
              fontFamily: "var(--font-body)",
              fontSize: "var(--font-size-2xs, 10px)",
              cursor: "pointer",
              textDecoration: "underline",
              padding: 0,
            }}
          >
            Clear all
          </button>
        )}
      </div>
    );
  }

  // ── Compact / Expanded: row of filter controls ──
  return (
    <div
      role="toolbar"
      aria-label="Filters"
      style={{
        display: "flex",
        flexWrap: "wrap",
        gap: "8px",
        alignItems: "center",
        padding: "var(--space-2) 0",
      }}
    >
      {/* Filter controls */}
      {filters.map((f) => {
        if (f.type === "select") {
          return (
            <SelectFilter
              key={f.id}
              filter={f}
              value={activeFilters[f.id] as string | undefined}
              onChange={(v) => handleChange(f.id, v)}
            />
          );
        }
        if (f.type === "toggle") {
          return (
            <ToggleFilter
              key={f.id}
              filter={f}
              value={activeFilters[f.id] as boolean | undefined}
              onChange={(v) => handleChange(f.id, v)}
            />
          );
        }
        if (f.type === "search") {
          return (
            <SearchFilter
              key={f.id}
              filter={f}
              value={activeFilters[f.id] as string | undefined}
              onChange={(v) => handleChange(f.id, v)}
            />
          );
        }
        return null;
      })}

      {/* Presets dropdown */}
      {presets && presets.length > 0 && (
        <div style={{ position: "relative" }}>
          <button
            type="button"
            onClick={() => setShowPresets(!showPresets)}
            style={{
              padding: "4px 8px",
              borderRadius: "var(--radius, 6px)",
              border: "1px solid var(--border)",
              background: "var(--surface)",
              color: "var(--text-secondary)",
              fontFamily: "var(--font-body)",
              fontSize: "var(--font-size-xs)",
              cursor: "pointer",
            }}
          >
            Presets ▾
          </button>
          {showPresets && (
            <div
              style={{
                position: "absolute",
                top: "100%",
                left: 0,
                marginTop: 4,
                padding: "var(--space-1)",
                borderRadius: "var(--radius, 6px)",
                border: "1px solid var(--border)",
                background: "var(--bg)",
                boxShadow: "var(--shadow, 0 2px 8px rgba(0,0,0,0.1))",
                zIndex: 10,
                minWidth: 120,
              }}
            >
              {presets.map((p) => (
                <button
                  key={p.id}
                  type="button"
                  onClick={() => handlePreset(p)}
                  style={{
                    display: "block",
                    width: "100%",
                    textAlign: "left",
                    padding: "4px 8px",
                    borderRadius: 4,
                    border: "none",
                    background: "none",
                    color: "var(--text)",
                    fontFamily: "var(--font-body)",
                    fontSize: "var(--font-size-xs)",
                    cursor: "pointer",
                  }}
                >
                  {p.label}
                </button>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Clear all */}
      {activeCount > 0 && showClear && (
        <button
          type="button"
          onClick={handleClear}
          style={{
            background: "none",
            border: "none",
            color: "var(--text-muted)",
            fontFamily: "var(--font-body)",
            fontSize: "var(--font-size-xs)",
            cursor: "pointer",
            textDecoration: "underline",
            padding: 0,
            marginLeft: "auto",
          }}
        >
          Clear {activeCount} filter{activeCount > 1 ? "s" : ""}
        </button>
      )}

      {/* Active filter chips (expanded variant shows below) */}
      {variant === "expanded" && activeCount > 0 && (
        <div style={{ width: "100%", display: "flex", flexWrap: "wrap", gap: "6px", paddingTop: "var(--space-1)" }}>
          {Object.entries(activeFilters).map(([key, val]) => {
            const def = filters.find((f) => f.id === key);
            if (!val || val === "") return null;
            return (
              <FilterChip
                key={key}
                label={def?.label ?? key}
                value={val}
                onRemove={() => handleChange(key, "")}
              />
            );
          })}
        </div>
      )}
    </div>
  );
}

export default FilterBar;
