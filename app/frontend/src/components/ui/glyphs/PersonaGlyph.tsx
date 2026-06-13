import * as React from "react";

/**
 * PersonaGlyph — voice bubble with three wavelets, echoing
 * the three-voice system (user / inner-voice / agent).
 */
export function PersonaGlyph(props: React.SVGProps<SVGSVGElement>) {
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
      {/* speech bubble */}
      <path d="M12 16 L52 16 C54 16, 56 18, 56 20 L56 40 C56 42, 54 44, 52 44 L28 44 L20 52 L20 44 L14 44 C12 44, 10 42, 10 40 L10 20 C10 18, 12 16, 14 16 Z" />
      {/* three wavelets */}
      <path d="M20 26 C22 23, 24 23, 26 26" />
      <path d="M30 28 C33 22, 36 22, 39 28" />
      <path d="M43 26 C45 23, 47 23, 49 26" />
      {/* baseline dots */}
      <circle cx="23" cy="34" r="1" fill="currentColor" />
      <circle cx="34" cy="34" r="1" fill="currentColor" />
      <circle cx="46" cy="34" r="1" fill="currentColor" />
    </svg>
  );
}
