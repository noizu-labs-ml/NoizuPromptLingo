"use client";

import { motion, useTransform, type MotionValue } from "framer-motion";

/** PCB pad — circle with inner dot */
export function PcbPad({ cx, cy, at, progress, r = 5 }: {
  cx: number; cy: number; at: number; r?: number;
  progress: MotionValue<number>;
}) {
  const opacity = useTransform(progress, [at, at + 0.05], [0, 1]);
  const scale = useTransform(progress, [at, at + 0.05], [0, 1]);
  return (
    <motion.g style={{ opacity, scale }}>
      <circle cx={cx} cy={cy} r={r} fill="rgba(255,202,2,0.1)" stroke="rgba(255,202,2,0.4)" strokeWidth={1.2} />
      <circle cx={cx} cy={cy} r={r * 0.35} fill="rgba(255,202,2,0.6)" />
    </motion.g>
  );
}

/** PCB via — small junction dot */
export function PcbVia({ cx, cy, at, progress }: {
  cx: number; cy: number; at: number;
  progress: MotionValue<number>;
}) {
  const opacity = useTransform(progress, [at, at + 0.03], [0, 1]);
  return (
    <motion.g style={{ opacity }}>
      <circle cx={cx} cy={cy} r={3.5} fill="rgba(255,202,2,0.08)" stroke="rgba(255,202,2,0.35)" strokeWidth={0.8} />
      <circle cx={cx} cy={cy} r={1.5} fill="rgba(255,202,2,0.5)" />
    </motion.g>
  );
}
