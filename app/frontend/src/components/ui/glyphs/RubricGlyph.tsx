import * as React from "react";

/**
 * RubricGlyph — ruler with tiered marks forming a ladder scale.
 * Evokes a graded evaluation rubric.
 */
export function RubricGlyph(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      width="64"
      height="64"
      viewBox="0 0 64 64"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.5"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      {...props}
    >
      {/* ruler body */}
      <rect x="12" y="10" width="18" height="44" rx="1" />
      {/* tick marks (ladder) */}
      <line x1="12" y1="18" x2="22" y2="18" />
      <line x1="12" y1="26" x2="26" y2="26" />
      <line x1="12" y1="34" x2="22" y2="34" />
      <line x1="12" y1="42" x2="26" y2="42" />
      <line x1="12" y1="50" x2="22" y2="50" />
      {/* tier bars climbing right */}
      <rect x="36" y="46" width="6" height="8" />
      <rect x="44" y="36" width="6" height="18" />
      <rect x="52" y="22" width="6" height="32" />
    </svg>
  );
}
