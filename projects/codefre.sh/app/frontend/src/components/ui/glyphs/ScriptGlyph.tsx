import * as React from "react";

/**
 * ScriptGlyph — abstract graph nodes connected by directed edges.
 * Evokes a DAG / conversation flow.
 */
export function ScriptGlyph(props: React.SVGProps<SVGSVGElement>) {
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
      {/* edges (drawn first, behind) */}
      <path d="M16 20 L28 32" />
      <path d="M28 32 L16 44" />
      <path d="M28 32 L48 32" />
      {/* arrowheads */}
      <path d="M25 30 L28 32 L26 35" />
      <path d="M19 42 L16 44 L18 47" />
      <path d="M45 30 L48 32 L45 34" />
      {/* nodes */}
      <rect x="8" y="14" width="14" height="12" rx="2" />
      <rect x="22" y="26" width="14" height="12" rx="2" />
      <rect x="8" y="38" width="14" height="12" rx="2" />
      <rect x="42" y="26" width="14" height="12" rx="2" />
    </svg>
  );
}
