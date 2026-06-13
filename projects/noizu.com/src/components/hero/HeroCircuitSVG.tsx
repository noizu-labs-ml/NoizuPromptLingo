"use client";

import { DrawOnPath } from "@/components/DrawOnPath";
import { useScrollSequence } from "@/components/ScrollSequenceContext";

export function HeroCircuitSVG() {
  const progress = useScrollSequence();

  return (
    <svg
      viewBox="0 0 1440 800"
      fill="none"
      className="w-full h-full"
      preserveAspectRatio="xMidYMid slice"
    >
      {/* Left circuit path */}
      <DrawOnPath
        d="M200 80 L200 280 L480 280 L480 480"
        progress={progress}
        startAt={0.0}
        endAt={0.25}
        stroke="rgba(255,202,2,0.18)"
        strokeWidth={1.5}
      />
      {/* Right circuit path */}
      <DrawOnPath
        d="M820 120 L820 320 L1100 320 L1100 440 L1260 440"
        progress={progress}
        startAt={0.05}
        endAt={0.3}
        stroke="rgba(255,202,2,0.2)"
        strokeWidth={1.5}
      />
      {/* Center path */}
      <DrawOnPath
        d="M600 200 L720 200 L720 400 L900 400"
        progress={progress}
        startAt={0.1}
        endAt={0.3}
        stroke="rgba(255,202,2,0.14)"
        strokeWidth={1}
      />
      {/* Bottom path */}
      <DrawOnPath
        d="M300 500 L300 620 L550 620 L550 700"
        progress={progress}
        startAt={0.15}
        endAt={0.35}
        stroke="rgba(255,202,2,0.15)"
        strokeWidth={1}
      />

      {/* Connection nodes at endpoints */}
      <circle cx="480" cy="480" r="4" fill="rgba(255,202,2,0.25)" />
      <circle cx="1260" cy="440" r="4" fill="rgba(255,202,2,0.25)" />
      <circle cx="900" cy="400" r="3" fill="rgba(255,202,2,0.2)" />
      <circle cx="550" cy="700" r="3" fill="rgba(255,202,2,0.18)" />

      {/* Component rectangles along traces */}
      <rect x="195" y="175" width="10" height="6" rx="1" fill="rgba(255,202,2,0.12)" />
      <rect x="815" y="215" width="10" height="6" rx="1" fill="rgba(255,202,2,0.12)" />
      <rect x="715" y="295" width="10" height="6" rx="1" fill="rgba(255,202,2,0.12)" />
    </svg>
  );
}
