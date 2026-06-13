"use client";

import { useRef, ReactNode } from "react";
import { motion, useScroll, useTransform, useReducedMotion } from "framer-motion";

interface SVGParallaxLayerProps {
  children: ReactNode;
  speed: number;
  fadeOut?: boolean;
  className?: string;
}

export function SVGParallaxLayer({
  children,
  speed,
  fadeOut = true,
  className = "",
}: SVGParallaxLayerProps) {
  const ref = useRef<HTMLDivElement>(null);
  const reduced = useReducedMotion();
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"],
  });

  const y = useTransform(scrollYProgress, [0, 1], [`${-speed * 15}%`, `${speed * 15}%`]);
  const opacityFadeOut = useTransform(scrollYProgress, [0, 0.2, 0.8, 1], [0, 1, 1, 0]);
  const opacityFadeIn = useTransform(scrollYProgress, [0, 0.2], [0, 1]);
  const opacity = fadeOut ? opacityFadeOut : opacityFadeIn;

  if (reduced) {
    return (
      <div ref={ref} className={`absolute inset-0 pointer-events-none ${className}`}>
        {children}
      </div>
    );
  }

  return (
    <motion.div
      ref={ref}
      style={{ y, opacity }}
      className={`absolute inset-0 pointer-events-none ${className}`}
    >
      {children}
    </motion.div>
  );
}
