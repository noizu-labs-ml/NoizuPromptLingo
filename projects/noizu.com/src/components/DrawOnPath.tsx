"use client";

import { motion, useTransform, type MotionValue } from "framer-motion";

interface DrawOnPathProps {
  d: string;
  progress: MotionValue<number>;
  startAt?: number;
  endAt?: number;
  stroke?: string;
  strokeWidth?: number;
  glow?: boolean;
  glowColor?: string;
  glowWidth?: number;
  className?: string;
}

export function DrawOnPath({
  d,
  progress,
  startAt = 0,
  endAt = 1,
  stroke = "rgba(255,202,2,0.12)",
  strokeWidth = 1.5,
  glow = false,
  glowColor = "rgba(255,202,2,0.3)",
  glowWidth = 6,
  className = "",
}: DrawOnPathProps) {
  // drawFraction: 1 = fully hidden, 0 = fully drawn
  const drawFraction = useTransform(progress, [startAt, endAt], [1, 0]);

  return (
    <>
      {/* Glow layer — blurred, wider behind the main path */}
      {glow && (
        <motion.path
          d={d}
          pathLength={1}
          stroke={glowColor}
          strokeWidth={glowWidth}
          fill="none"
          strokeLinecap="round"
          style={{
            strokeDasharray: 1,
            strokeDashoffset: drawFraction,
            filter: `blur(${glowWidth}px)`,
          }}
        />
      )}
      {/* Main path */}
      <motion.path
        d={d}
        pathLength={1}
        stroke={stroke}
        strokeWidth={strokeWidth}
        fill="none"
        strokeLinecap="round"
        className={className}
        style={{
          strokeDasharray: 1,
          strokeDashoffset: drawFraction,
        }}
      />
    </>
  );
}
