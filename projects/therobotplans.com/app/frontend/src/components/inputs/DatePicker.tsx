"use client";

import React, { useState } from "react";

/**
 * DatePicker — Inline date/time selector with relative options and calendar dropdown.
 *
 * @example
 * ```tsx
 * <DatePicker value="2026-06-01" onChange={setDate} />
 * <DatePicker value="2026-06-01" onChange={setDate} showTime relativeOptions={["Tomorrow","Next week","Next month"]} variant="compact" />
 * ```
 */

type DateVariant = "inline" | "compact" | "expanded";

interface DatePickerProps {
  value?: string;
  onChange: (date: string) => void;
  showTime?: boolean;
  relativeOptions?: string[];
  minDate?: string;
  maxDate?: string;
  variant?: DateVariant;
  placeholder?: string;
}

function addDays(d: Date, n: number): string { const r = new Date(d); r.setDate(r.getDate() + n); return r.toISOString().split("T")[0]; }
function relativeToDate(label: string): string {
  const now = new Date();
  if (label === "Tomorrow") return addDays(now, 1);
  if (label === "Next week") return addDays(now, 7);
  if (label === "Next month") return addDays(now, 30);
  if (label === "End of week") { const d = 5 - now.getDay(); return addDays(now, d >= 0 ? d : d + 7); }
  return addDays(now, 1);
}

export function DatePicker({ value, onChange, showTime = false, relativeOptions = ["Tomorrow", "Next week", "Next month"], minDate, maxDate, variant = "compact", placeholder = "Set date" }: DatePickerProps) {
  const [open, setOpen] = useState(false);

  if (variant === "inline") {
    return (
      <span onClick={() => setOpen(!open)} style={{ position: "relative", display: "inline-block" }}>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: value ? "var(--text)" : "var(--text-muted)", cursor: "pointer", textDecoration: "underline", textDecorationStyle: "dotted" }}>
          {value || placeholder}
        </span>
        {open && (
          <>
            <div style={{ position: "fixed", inset: 0, zIndex: 9 }} onClick={() => setOpen(false)} />
            <div style={{ position: "absolute", top: "100%", left: 0, marginTop: 4, padding: "var(--space-2)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--bg)", boxShadow: "var(--shadow, 0 4px 12px rgba(0,0,0,0.15))", zIndex: 10, minWidth: 180 }}>
              <input type={showTime ? "datetime-local" : "date"} value={value ?? ""} min={minDate} max={maxDate} onChange={(e) => { onChange(e.target.value); setOpen(false); }} style={{ width: "100%", padding: "4px 6px", borderRadius: 4, border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)" }} autoFocus />
              {relativeOptions.length > 0 && (
                <div style={{ display: "flex", flexWrap: "wrap", gap: "4px", marginTop: "var(--space-1)" }}>
                  {relativeOptions.map((opt) => (
                    <button key={opt} type="button" onClick={() => { onChange(relativeToDate(opt)); setOpen(false); }} style={{ padding: "2px 8px", borderRadius: "999px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text-secondary)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-2xs, 10px)", cursor: "pointer" }}>{opt}</button>
                  ))}
                </div>
              )}
            </div>
          </>
        )}
      </span>
    );
  }

  // compact / expanded
  return (
    <div style={{ position: "relative", display: "inline-block" }}>
      <button type="button" onClick={() => setOpen(!open)} style={{ display: "flex", alignItems: "center", gap: "6px", padding: "4px 10px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", color: value ? "var(--text)" : "var(--text-muted)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", cursor: "pointer" }}>
        <span>📅</span>
        {value || placeholder}
      </button>
      {open && (
        <>
          <div style={{ position: "fixed", inset: 0, zIndex: 9 }} onClick={() => setOpen(false)} />
          <div style={{ position: "absolute", top: "100%", left: 0, marginTop: 4, padding: "var(--space-2)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--bg)", boxShadow: "var(--shadow, 0 4px 12px rgba(0,0,0,0.15))", zIndex: 10, minWidth: 200 }}>
            <input type={showTime ? "datetime-local" : "date"} value={value ?? ""} min={minDate} max={maxDate} onChange={(e) => { onChange(e.target.value); setOpen(false); }} style={{ width: "100%", padding: "4px 6px", borderRadius: 4, border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)" }} autoFocus />
            {relativeOptions.length > 0 && (
              <div style={{ display: "flex", flexWrap: "wrap", gap: "4px", marginTop: "var(--space-2)", paddingTop: "var(--space-1)", borderTop: "1px solid var(--border)" }}>
                {relativeOptions.map((opt) => (
                  <button key={opt} type="button" onClick={() => { onChange(relativeToDate(opt)); setOpen(false); }} style={{ padding: "3px 10px", borderRadius: "999px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text-secondary)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", cursor: "pointer" }}>{opt}</button>
                ))}
              </div>
            )}
            {value && (
              <button type="button" onClick={() => { onChange(""); setOpen(false); }} style={{ marginTop: "var(--space-1)", width: "100%", padding: "3px", borderRadius: 4, border: "none", background: "none", color: "var(--text-muted)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-2xs, 10px)", cursor: "pointer" }}>Clear date</button>
            )}
          </div>
        </>
      )}
    </div>
  );
}

export default DatePicker;
