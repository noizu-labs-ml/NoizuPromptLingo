import * as React from "react";

/**
 * DatasetGlyph — stacked records / database puck stack.
 * Evokes a fixture / dataset collection.
 */
export function DatasetGlyph(props: React.SVGProps<SVGSVGElement>) {
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
      {/* top puck */}
      <ellipse cx="32" cy="16" rx="18" ry="5" />
      {/* upper cylinder sides */}
      <path d="M14 16 L14 28" />
      <path d="M50 16 L50 28" />
      <path d="M14 28 C14 31, 22 33, 32 33 C42 33, 50 31, 50 28" />
      {/* middle cylinder sides */}
      <path d="M14 32 L14 44" />
      <path d="M50 32 L50 44" />
      <path d="M14 44 C14 47, 22 49, 32 49 C42 49, 50 47, 50 44" />
      {/* bottom cap */}
      <path d="M14 48 L14 52 C14 55, 22 57, 32 57 C42 57, 50 55, 50 52 L50 48" />
    </svg>
  );
}
