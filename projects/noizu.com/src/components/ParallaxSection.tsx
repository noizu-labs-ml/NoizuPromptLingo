"use client";

import { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";
import clsx from "clsx";

export function ParallaxSection({
  children,
  className = "",
  bgClassName = "",
  id,
}: {
  children: React.ReactNode;
  className?: string;
  bgClassName?: string;
  id?: string;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"],
  });

  const y = useTransform(scrollYProgress, [0, 1], ["-8%", "8%"]);

  return (
    <div ref={ref} id={id} className={clsx("relative overflow-hidden", className)}>
      {/* Parallax background layer - no opacity animation */}
      <motion.div
        style={{ y }}
        className={clsx("absolute inset-0 -inset-y-[15%] -z-10", bgClassName)}
      />
      {/* Content */}
      <div className="relative z-10">{children}</div>
    </div>
  );
}

export function FloatingOrb({
  className = "",
  speed = 0.5,
}: {
  className?: string;
  speed?: number;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"],
  });

  const y = useTransform(scrollYProgress, [0, 1], ["0%", `${-30 * speed}%`]);
  const scale = useTransform(scrollYProgress, [0, 0.5, 1], [0.85, 1.05, 0.9]);

  return (
    <div ref={ref} className="absolute inset-0 -z-10 overflow-hidden">
      <motion.div style={{ y, scale }} className={className} />
    </div>
  );
}

/**
 * A card with a warm gradient spotlight that sweeps across as the user scrolls into view.
 */
export function GradientCard({
  children,
  className = "",
}: {
  children: React.ReactNode;
  className?: string;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"],
  });

  // Spotlight sweeps right to left
  const spotlightX = useTransform(scrollYProgress, [0, 1], [140, -40]);
  // Glow fades in as card enters viewport
  const glowOpacity = useTransform(scrollYProgress, [0, 0.3, 0.8, 1], [0, 0.8, 1, 0.9]);

  return (
    <div ref={ref} className={clsx("relative rounded-3xl overflow-hidden", className)}>
      {/* Static warm base */}
      <div className="absolute inset-0 bg-gradient-to-br from-orange-500/20 via-orange-700/12 to-gold-800/8 rounded-3xl" />

      {/* Sweeping spotlight */}
      <motion.div
        className="absolute inset-0 pointer-events-none rounded-3xl"
        style={{
          opacity: glowOpacity,
          background: useMotionTemplate(spotlightX),
        }}
      />

      {/* Content */}
      <div className="relative backdrop-blur-xl bg-zinc-800/50 rounded-3xl shadow-[inset_0_1px_0_0_rgba(251,146,60,0.1)]">
        {children}
      </div>
    </div>
  );
}

/**
 * Full-width section with a scroll-driven warm gradient sweep behind the content.
 * Lighter than GradientCard — used for section headings/banners.
 */
export function GradientBanner({
  children,
  className = "",
  id,
}: {
  children: React.ReactNode;
  className?: string;
  id?: string;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"],
  });

  // Right to left, slower (full scroll range)
  const spotlightX = useTransform(scrollYProgress, [0, 1], [130, -30]);
  const glowOpacity = useTransform(scrollYProgress, [0, 0.15, 0.5, 0.85, 1], [0, 1, 1, 1, 0.3]);

  return (
    <section ref={ref} id={id} className={clsx("relative overflow-hidden", className)}>
      {/* Sweeping warm spotlight */}
      <motion.div
        className="absolute inset-0 -z-10 pointer-events-none"
        style={{
          opacity: glowOpacity,
          background: useBannerGradient(spotlightX),
        }}
      />
      {children}
    </section>
  );
}

/**
 * Creates a motion-driven radial gradient background string.
 */
function useMotionTemplate(x: ReturnType<typeof useTransform<number, number>>) {
  return useTransform(x, (v) =>
    `radial-gradient(ellipse 50% 80% at ${v}% 30%, rgba(234, 120, 30, 0.22) 0%, rgba(255, 202, 2, 0.06) 50%, transparent 80%)`
  );
}

function useBannerGradient(x: ReturnType<typeof useTransform<number, number>>) {
  return useTransform(x, (v) =>
    `radial-gradient(ellipse 70% 80% at ${v}% 40%, rgba(234, 120, 30, 0.30) 0%, rgba(255, 170, 2, 0.12) 40%, transparent 70%)`
  );
}
