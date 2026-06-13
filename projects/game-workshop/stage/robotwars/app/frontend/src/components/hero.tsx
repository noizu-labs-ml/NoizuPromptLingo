"use client";

// hero.tsx — client boundary for the landing hero.
//
// Responsibilities:
//   1. Lazy-load the heavy three.js diorama only in the browser (ssr: false),
//      so the marketing page's first paint isn't blocked by the 3D bundle.
//   2. Feature-detect WebGL; if absent, render a static, on-brand SVG gem so
//      low-end / locked-down browsers still get a polished hero.
//
// The accelerated path and the fallback share the same .trw-hero-stage frame,
// so layout is identical either way (no CLS on hydration).

import dynamic from "next/dynamic";
import { useEffect, useState } from "react";
import { hasWebGL } from "@/lib/webgl";

const HeroDiorama = dynamic(() => import("./hero-diorama"), {
  ssr: false,
  loading: () => <HeroFallback caption="Spinning up the GPU…" />,
});

function HeroFallback({ caption }: { caption: string }) {
  return (
    <div className="trw-hero-fallback" role="img" aria-label="TheRobotWars SPARK crystal">
      <svg viewBox="0 0 200 200" width="220" height="220" aria-hidden="true">
        <defs>
          <radialGradient id="trw-gem" cx="50%" cy="40%" r="65%">
            <stop offset="0%" stopColor="#FFF3D6" />
            <stop offset="55%" stopColor="#FFD54F" />
            <stop offset="100%" stopColor="#FFB347" />
          </radialGradient>
        </defs>
        <polygon
          points="100,24 156,70 134,150 66,150 44,70"
          fill="url(#trw-gem)"
          stroke="#5C4A72"
          strokeWidth="2"
        />
        <polygon points="100,24 134,150 100,100" fill="#FFFFFF" opacity="0.18" />
        <polygon points="100,24 66,150 100,100" fill="#5C4A72" opacity="0.12" />
        <polygon points="44,70 100,100 66,150" fill="#5C4A72" opacity="0.18" />
      </svg>
      <span className="trw-hero-caption">{caption}</span>
    </div>
  );
}

export function Hero() {
  // Start in a neutral state, decide on the client after mount.
  const [mode, setMode] = useState<"pending" | "webgl" | "fallback">("pending");

  useEffect(() => {
    setMode(hasWebGL() ? "webgl" : "fallback");
  }, []);

  return (
    <div className="trw-hero-stage">
      {mode === "webgl" ? (
        <HeroDiorama />
      ) : (
        <HeroFallback
          caption={
            mode === "fallback" ? "Powered by your device — illustration mode" : ""
          }
        />
      )}
    </div>
  );
}
