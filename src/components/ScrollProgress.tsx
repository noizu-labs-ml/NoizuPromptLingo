"use client";

import { motion, useScroll, useTransform, useReducedMotion } from "framer-motion";

export function ScrollProgress() {
  const { scrollYProgress } = useScroll();
  const scaleX = useTransform(scrollYProgress, [0, 1], [0, 1]);
  const reduced = useReducedMotion();

  if (reduced) return null;

  return (
    <motion.div
      role="progressbar"
      aria-label="Page scroll progress"
      style={{ scaleX }}
      className="fixed top-0 left-0 right-0 h-[2px] bg-gold-400 z-[100] origin-left"
    />
  );
}
