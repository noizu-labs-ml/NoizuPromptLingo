"use client";

import { CONTAINER_BREAKPOINTS } from "@styleguide-engine/components/LayoutBar";

/**
 * Drop this inside any element to show container-query breakpoint rulers
 * relative to that element's left edge. The parent must have `position: relative`.
 *
 * Usage:
 *   <div className="relative">
 *     <BreakpointRuler />
 *     {children}
 *   </div>
 */
export function BreakpointRuler() {
  return (
    <div className="container-breakpoint-rulers">
      {CONTAINER_BREAKPOINTS.map((bp) => (
        <div key={bp.name} className="container-bp-ruler" data-bp={bp.bp} style={{ left: `${bp.rem}rem` }}>
          <span className="container-bp-label">{bp.name} {bp.rem}rem</span>
        </div>
      ))}
    </div>
  );
}
