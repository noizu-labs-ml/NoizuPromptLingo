import * as React from "react";

/**
 * RunGlyph — stylized play triangle inside a circle, with
 * a soft aura tick-marks evoking execution / a forge spark.
 */
export function RunGlyph(props: React.SVGProps<SVGSVGElement>) {
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
      {/* outer aura */}
      <circle cx="32" cy="32" r="24" strokeDasharray="2 4" opacity="0.6" />
      {/* inner dial */}
      <circle cx="32" cy="32" r="16" />
      {/* play triangle */}
      <path d="M27 24 L42 32 L27 40 Z" />
    </svg>
  );
}
