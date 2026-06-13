"use client";

import React from "react";
import type { GraphFilters, NodeStatus, GraphNodeType } from "../ProjectGraph.types";
import { STATUS_CONFIG, PRIORITY_CONFIG } from "../ProjectGraph.types";

/**
 * FilterPanel — Horizontal filter bar with multi-toggle chips for status,
 * priority, and node type. (Spec §9.1)
 */

interface FilterPanelProps {
  filters: GraphFilters;
  onChange: (filters: GraphFilters) => void;
}

const chipBase: React.CSSProperties = {
  padding: "2px 8px",
  borderRadius: 999,
  border: "1px solid var(--border)",
  background: "none",
  color: "var(--text-muted)",
  fontFamily: "var(--font-sans, var(--font-body))",
  fontSize: "var(--font-size-2xs, 10px)",
  cursor: "pointer",
  transition: "all 0.15s",
};

function chipActive(color: string): React.CSSProperties {
  return {
    ...chipBase,
    background: `color-mix(in srgb, ${color} 12%, transparent)`,
    color,
    borderColor: color,
    fontWeight: 600,
  };
}

const STATUS_OPTIONS: NodeStatus[] = ["pending", "in-progress", "in-review", "blocked", "done"];
const PRIORITY_OPTIONS: ("p0" | "p1" | "p2" | "p3")[] = ["p0", "p1", "p2", "p3"];
const NODE_TYPE_OPTIONS: { value: GraphNodeType; label: string }[] = [
  { value: "story", label: "Stories" },
  { value: "role", label: "Roles" },
  { value: "subtask", label: "Subtasks" },
  { value: "milestone", label: "Milestones" },
  { value: "fork", label: "Forks" },
  { value: "merge", label: "Merges" },
];

function toggleInArray<T>(arr: T[] | undefined, value: T): T[] {
  const current = arr ?? [];
  return current.includes(value)
    ? current.filter((v) => v !== value)
    : [...current, value];
}

export function FilterPanel({ filters, onChange }: FilterPanelProps) {
  const toggleStatus = (s: NodeStatus) =>
    onChange({ ...filters, status: toggleInArray(filters.status, s) });

  const togglePriority = (p: "p0" | "p1" | "p2" | "p3") =>
    onChange({ ...filters, priority: toggleInArray(filters.priority, p) });

  const toggleNodeType = (t: GraphNodeType) =>
    onChange({ ...filters, nodeTypes: toggleInArray(filters.nodeTypes, t) });

  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: "12px",
        padding: "6px 10px",
        borderBottom: "1px solid var(--border)",
        background: "color-mix(in srgb, var(--text-muted) 3%, transparent)",
        flexWrap: "wrap",
      }}
      role="group"
      aria-label="Graph filters"
    >
      {/* Status */}
      <div style={{ display: "flex", alignItems: "center", gap: "4px" }}>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", marginRight: 2 }}>
          Status
        </span>
        {STATUS_OPTIONS.map((s) => {
          const active = filters.status?.includes(s);
          const cfg = STATUS_CONFIG[s];
          return (
            <button
              key={s}
              type="button"
              style={active ? chipActive(cfg.color) : chipBase}
              onClick={() => toggleStatus(s)}
              aria-pressed={!!active}
            >
              {cfg.label}
            </button>
          );
        })}
      </div>

      {/* Separator */}
      <div style={{ width: 1, height: 16, background: "var(--border)" }} />

      {/* Priority */}
      <div style={{ display: "flex", alignItems: "center", gap: "4px" }}>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", marginRight: 2 }}>
          Priority
        </span>
        {PRIORITY_OPTIONS.map((p) => {
          const active = filters.priority?.includes(p);
          const cfg = PRIORITY_CONFIG[p];
          return (
            <button
              key={p}
              type="button"
              style={active ? chipActive(cfg.color) : chipBase}
              onClick={() => togglePriority(p)}
              aria-pressed={!!active}
            >
              {cfg.label}
            </button>
          );
        })}
      </div>

      {/* Separator */}
      <div style={{ width: 1, height: 16, background: "var(--border)" }} />

      {/* Node types */}
      <div style={{ display: "flex", alignItems: "center", gap: "4px" }}>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", marginRight: 2 }}>
          Type
        </span>
        {NODE_TYPE_OPTIONS.map(({ value, label }) => {
          const active = filters.nodeTypes?.includes(value);
          return (
            <button
              key={value}
              type="button"
              style={active ? chipActive("var(--info, var(--blue))") : chipBase}
              onClick={() => toggleNodeType(value)}
              aria-pressed={!!active}
            >
              {label}
            </button>
          );
        })}
      </div>
    </div>
  );
}

export default FilterPanel;
