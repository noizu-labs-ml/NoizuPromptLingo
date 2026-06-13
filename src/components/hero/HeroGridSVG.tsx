"use client";

export function HeroGridSVG() {
  return (
    <svg
      viewBox="0 0 1440 800"
      fill="none"
      className="w-full h-full"
      preserveAspectRatio="xMidYMid slice"
    >
      {/* Horizontal grid lines */}
      <line x1="0" y1="160" x2="1440" y2="160" stroke="rgba(255,202,2,0.05)" strokeWidth="1" />
      <line x1="0" y1="320" x2="1440" y2="320" stroke="rgba(255,202,2,0.08)" strokeWidth="1" />
      <line x1="0" y1="480" x2="1440" y2="480" stroke="rgba(255,202,2,0.06)" strokeWidth="1" />
      <line x1="0" y1="640" x2="1440" y2="640" stroke="rgba(255,202,2,0.05)" strokeWidth="1" />

      {/* Vertical grid lines */}
      <line x1="288" y1="0" x2="288" y2="800" stroke="rgba(255,202,2,0.04)" strokeWidth="1" />
      <line x1="576" y1="0" x2="576" y2="800" stroke="rgba(255,202,2,0.06)" strokeWidth="1" />
      <line x1="720" y1="0" x2="720" y2="800" stroke="rgba(255,202,2,0.07)" strokeWidth="1" />
      <line x1="864" y1="0" x2="864" y2="800" stroke="rgba(255,202,2,0.06)" strokeWidth="1" />
      <line x1="1152" y1="0" x2="1152" y2="800" stroke="rgba(255,202,2,0.04)" strokeWidth="1" />

      {/* Intersection dots */}
      <circle cx="720" cy="320" r="3" fill="rgba(255,202,2,0.15)" />
      <circle cx="288" cy="160" r="2" fill="rgba(255,202,2,0.1)" />
      <circle cx="1152" cy="480" r="2" fill="rgba(255,202,2,0.1)" />
      <circle cx="576" cy="640" r="2" fill="rgba(255,202,2,0.08)" />
      <circle cx="864" cy="160" r="1.5" fill="rgba(255,202,2,0.08)" />
    </svg>
  );
}
