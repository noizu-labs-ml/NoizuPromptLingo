/**
 * derobot.is logo — 3D isometric egghead robot.
 * Wide head, tiny body, violet eyes with rx=1.
 * Uses currentColor for stroke so it adapts to context.
 */

export function Logo({ size = 32, showText = true }: { size?: number; showText?: boolean }) {
  const aspect = 72 / 52; // viewBox width/height ratio
  const w = size * aspect;
  const h = size;

  return (
    <span style={{ display: "inline-flex", alignItems: "center", gap: 10 }}>
      <svg
        width={w}
        height={h}
        viewBox="-12 -10 72 52"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.2"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        {/* Head cube */}
        <path d="M5 2h38v16H5z M5 2l6-5h38l-6 5 M43 2l6-5v16l-6 5" />
        {/* Eyes */}
        <rect x="10" y="7" width="8" height="6" rx="1" stroke="var(--blue)" strokeWidth="1.2" fill="var(--blue)" fillOpacity="0.6" />
        <rect x="30" y="7" width="8" height="6" rx="1" stroke="var(--blue)" strokeWidth="1.2" fill="var(--blue)" fillOpacity="0.6" />
        {/* Body cube */}
        <path d="M18 22h12v8H18z M18 22l3-2h12l-3 2 M30 22l3-2v8l-3 2" />
        {/* Arms */}
        <path d="M18 24h-4v4h4 M30 24h4v4h-4" />
        {/* Legs */}
        <path d="M21 30v5h3v-5 M24 30v5h3v-5" />
      </svg>
      {showText && (
        <span style={{
          fontFamily: "var(--font-sans)",
          fontSize: size * 0.7,
          fontWeight: 700,
          letterSpacing: "-0.03em",
          lineHeight: 1,
          color: "currentColor",
        }}>
          derobot.is
        </span>
      )}
    </span>
  );
}
