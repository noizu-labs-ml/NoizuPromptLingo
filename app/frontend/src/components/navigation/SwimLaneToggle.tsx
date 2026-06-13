"use client";

import React, { useState } from "react";

/**
 * SwimLaneToggle — Dropdown selector that switches board grouping dimension.
 *
 * @example
 * ```tsx
 * <SwimLaneToggle options={[{ id: "assignee", label: "Assignee" }, { id: "priority", label: "Priority" }, { id: "epic", label: "Epic" }]} selected="assignee" onChange={setGroupBy} />
 * ```
 */

interface SwimLaneOption { id: string; label: string; }

interface SwimLaneToggleProps {
  options: SwimLaneOption[];
  selected: string;
  onChange: (id: string) => void;
}

export function SwimLaneToggle({ options, selected, onChange }: SwimLaneToggleProps) {
  const [open, setOpen] = useState(false);
  const current = options.find((o) => o.id === selected);

  return (
    <div style={{ position: "relative", display: "inline-block" }}>
      <button type="button" onClick={() => setOpen(!open)} aria-haspopup="listbox" aria-expanded={open} aria-label={`Group by: ${current?.label ?? selected}`} style={{ display: "inline-flex", alignItems: "center", gap: "6px", padding: "4px 10px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", cursor: "pointer" }}>
        <span style={{ color: "var(--text-muted)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", textTransform: "uppercase", letterSpacing: "0.04em" }}>Group by:</span>
        <span style={{ fontWeight: 600 }}>{current?.label ?? selected}</span>
        <span style={{ fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>▾</span>
      </button>
      {open && (
        <>
          <div style={{ position: "fixed", inset: 0, zIndex: 9 }} onClick={() => setOpen(false)} />
          <div role="listbox" aria-label="Grouping options" style={{ position: "absolute", top: "100%", left: 0, marginTop: 4, padding: "var(--space-1)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--bg)", boxShadow: "var(--shadow, 0 2px 8px rgba(0,0,0,0.1))", zIndex: 10, minWidth: 120 }}>
            {options.map((opt) => (
              <button key={opt.id} role="option" aria-selected={opt.id === selected} type="button" onClick={() => { onChange(opt.id); setOpen(false); }} style={{ display: "block", width: "100%", textAlign: "left", padding: "4px 8px", borderRadius: 4, border: "none", background: opt.id === selected ? "color-mix(in srgb, var(--info, var(--blue)) 10%, transparent)" : "none", color: opt.id === selected ? "var(--info, var(--blue))" : "var(--text)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontWeight: opt.id === selected ? 600 : 400, cursor: "pointer" }}>
                {opt.label}
              </button>
            ))}
          </div>
        </>
      )}
    </div>
  );
}

export default SwimLaneToggle;
