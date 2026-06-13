"use client";

import React, { useState, useRef, useEffect } from "react";

/**
 * RationalePopover — Hover/click popover explaining AI reasoning with optional factor breakdown.
 *
 * @example
 * ```tsx
 * <RationalePopover rationale="High confidence based on 12 similar past triages" trigger="hover">
 *   <span>Why this suggestion?</span>
 * </RationalePopover>
 * <RationalePopover rationale="Matched 3 patterns" factors={[{ label: "Context", weight: 0.9 }, { label: "History", weight: 0.7 }]} trigger="click">
 *   <button>ℹ️</button>
 * </RationalePopover>
 * ```
 */

interface RationaleFactor { label: string; weight: number; }

interface RationalePopoverProps {
  rationale: string;
  trigger?: "hover" | "click";
  factors?: RationaleFactor[];
  children: React.ReactNode;
}

function factorColor(w: number): string {
  if (w >= 0.8) return "var(--success)";
  if (w >= 0.5) return "var(--warning)";
  return "var(--error)";
}

export function RationalePopover({ rationale, trigger = "hover", factors, children }: RationalePopoverProps) {
  const [open, setOpen] = useState(false);
  const wrapperRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (trigger !== "click" || !open) return;
    const handleClickOutside = (e: MouseEvent) => {
      if (wrapperRef.current && !wrapperRef.current.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [open, trigger]);

  const hoverProps = trigger === "hover" ? { onMouseEnter: () => setOpen(true), onMouseLeave: () => setOpen(false) } : {};
  const clickProps = trigger === "click" ? { onClick: () => setOpen(!open) } : {};

  return (
    <div ref={wrapperRef} style={{ position: "relative", display: "inline-block" }} {...hoverProps} {...clickProps}>
      {children}
      {open && (
        <div role="tooltip" style={{ position: "absolute", top: "100%", left: "50%", transform: "translateX(-50%)", marginTop: 8, padding: "var(--space-2) var(--space-3)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--bg)", boxShadow: "var(--shadow, 0 4px 12px rgba(0,0,0,0.15))", zIndex: 20, minWidth: 200, maxWidth: 320 }}>
          {/* Arrow */}
          <div style={{ position: "absolute", top: -4, left: "50%", transform: "translateX(-50%) rotate(45deg)", width: 8, height: 8, background: "var(--bg)", borderTop: "1px solid var(--border)", borderLeft: "1px solid var(--border)" }} />

          <p style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text)", margin: 0, lineHeight: 1.5 }}>{rationale}</p>

          {factors && factors.length > 0 && (
            <div style={{ marginTop: "var(--space-2)", display: "flex", flexDirection: "column", gap: "4px", borderTop: "1px solid var(--border)", paddingTop: "var(--space-1)" }}>
              <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.06em", color: "var(--text-muted)" }}>Factors</span>
              {factors.map((f, i) => (
                <div key={i} style={{ display: "flex", alignItems: "center", gap: "6px" }}>
                  <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-secondary)", flex: 1, minWidth: 0, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{f.label}</span>
                  <div style={{ width: 50, height: 3, borderRadius: 1.5, background: "color-mix(in srgb, var(--text-muted) 15%, transparent)", overflow: "hidden" }}>
                    <div style={{ width: `${Math.round(f.weight * 100)}%`, height: "100%", background: factorColor(f.weight), borderRadius: 1.5 }} />
                  </div>
                  <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", width: 28, textAlign: "right" }}>{Math.round(f.weight * 100)}%</span>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

export default RationalePopover;
