import * as React from "react";

/**
 * ReviewGlyph — checkmark badge with a flag, evoking
 * adjudication / flagged review.
 */
export function ReviewGlyph(props: React.SVGProps<SVGSVGElement>) {
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
      {/* shield/badge */}
      <path d="M20 12 L40 12 C42 12, 44 14, 44 16 L44 36 C44 44, 38 50, 32 54 C26 50, 20 44, 20 36 L20 16 C20 14, 22 12, 20 12 Z" />
      {/* checkmark */}
      <path d="M26 32 L30 36 L38 26" />
      {/* flag pole + pennant (upper right) */}
      <line x1="50" y1="10" x2="50" y2="30" />
      <path d="M50 12 L58 14 L50 18 Z" />
    </svg>
  );
}
