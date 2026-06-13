import * as React from "react";

/**
 * AgentGlyph — plug / adapter icon evoking an external connection.
 * Suggests provider-side wiring.
 */
export function AgentGlyph(props: React.SVGProps<SVGSVGElement>) {
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
      {/* plug body (left) */}
      <rect x="10" y="22" width="18" height="20" rx="3" />
      {/* plug pins */}
      <line x1="15" y1="18" x2="15" y2="22" />
      <line x1="23" y1="18" x2="23" y2="22" />
      {/* cable */}
      <path d="M28 32 C32 32, 32 32, 36 32" />
      {/* socket / adapter (right) */}
      <path d="M36 26 L36 38 C36 42, 40 44, 44 44 L50 44 L50 20 L44 20 C40 20, 36 22, 36 26 Z" />
      {/* socket inner contact */}
      <circle cx="46" cy="32" r="2" />
    </svg>
  );
}
