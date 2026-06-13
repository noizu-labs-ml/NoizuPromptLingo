import * as React from "react";

/**
 * PromptGlyph — document with variable braces {{ }} suggesting
 * a parameterized prompt.
 */
export function PromptGlyph(props: React.SVGProps<SVGSVGElement>) {
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
      {/* document outline with folded corner */}
      <path d="M16 10 L42 10 L52 20 L52 54 L16 54 Z" />
      <path d="M42 10 L42 20 L52 20" />
      {/* body text lines */}
      <line x1="22" y1="30" x2="46" y2="30" />
      <line x1="22" y1="44" x2="38" y2="44" />
      {/* curly brace pair over middle row */}
      <path d="M25 36 C23 36, 23 38, 23 39 C23 40, 22 40, 22 40 C22 40, 23 40, 23 41 C23 42, 23 40, 25 40" />
      <path d="M43 36 C45 36, 45 38, 45 39 C45 40, 46 40, 46 40 C46 40, 45 40, 45 41 C45 42, 45 40, 43 40" />
      <line x1="29" y1="38" x2="39" y2="38" />
    </svg>
  );
}
