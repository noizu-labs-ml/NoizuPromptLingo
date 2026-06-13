"use client";

/* eslint-disable @next/next/no-img-element */
import Link from "next/link";
import { motion, useTransform } from "framer-motion";
import { ScrollSequence } from "@/components/ScrollSequence";
import { useScrollSequence } from "@/components/ScrollSequenceContext";
import { HeroGridSVG } from "@/components/hero/HeroGridSVG";
import { MagneticButton } from "@/components/MagneticButton";
import { FadeIn } from "@/components/FadeIn";

function HeroContent() {
  const progress = useScrollSequence();

  // Text stays fully visible through most of scroll, fades only at the end
  const textOpacity = useTransform(progress, [0, 0.6, 0.85, 1], [1, 1, 0.8, 0.3]);
  const textY = useTransform(progress, [0, 1], [0, -15]);

  // Fiber burst: starts invisible, fades in, zooms, blurs, fades out
  const burstOpacity = useTransform(progress, [0, 0.15, 0.4, 0.7, 1], [0, 0.3, 0.5, 0.35, 0]);
  const burstScale = useTransform(progress, [0, 0.7], [0.5, 1.6]);
  const burstBlur = useTransform(progress, [0, 0.3, 0.7], [2, 4, 16]);
  const burstFilter = useTransform(burstBlur, (b) => `saturate(0.7) sepia(0.1) brightness(0.5) blur(${b}px)`);
  // Gentle parallax lag — small offset so it scrolls smoother
  const burstY = useTransform(progress, [0, 1], ["0%", "5%"]);
  const particleY = useTransform(progress, [0, 1], ["0%", "4%"]);

  // Gold particle overlay
  const particleOpacity = useTransform(progress, [0, 0.2, 0.5], [0.1, 0.25, 0.35]);

  return (
    <div role="region" aria-label="Hero section" className="relative w-full h-[85vh]">
      {/* Bright fiber optic burst — parallax lag, soft rounded edges */}
      <motion.div
        role="presentation"
        aria-label="Fiber optic burst"
        style={{ opacity: burstOpacity, scale: burstScale, y: burstY }}
        className="absolute -inset-y-[15%] inset-x-0 pointer-events-none flex items-center justify-center"
      >
        <motion.img
          src="/images/screen-overlay-fiber-optics.png"
          alt=""
          className="w-[90%] h-[85%] object-cover rounded-[80px]"
          style={{
            filter: burstFilter,
            maskImage: "radial-gradient(ellipse 85% 80% at 50% 45%, black 40%, transparent 75%)",
            WebkitMaskImage: "radial-gradient(ellipse 85% 80% at 50% 45%, black 40%, transparent 75%)",
          }}
        />
      </motion.div>

      {/* Gold particle overlay — slightly different parallax speed + bottom fade */}
      <motion.div
        role="presentation"
        aria-label="Gold particles"
        style={{
          opacity: particleOpacity,
          y: particleY,
        }}
        className="absolute -inset-y-[10%] inset-x-0 mix-blend-screen pointer-events-none"
      >
        <img
          src="/images/screen-overlay-gold-particles.png"
          alt=""
          className="w-full h-full object-cover"
          style={{
            maskImage: "linear-gradient(to bottom, black 60%, transparent 100%)",
            WebkitMaskImage: "linear-gradient(to bottom, black 60%, transparent 100%)",
          }}
        />
      </motion.div>

      {/* Content — fully visible on load, fades on scroll */}
      <motion.div
        role="banner"
        aria-label="Hero content"
        style={{ opacity: textOpacity, y: textY }}
        className="relative z-20 flex items-center h-full pt-20"
      >
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="max-w-3xl">
            <h1 className="text-5xl sm:text-7xl font-bold tracking-tight text-white leading-[1.1]">
              Leadership in{" "}
              <span className="gradient-text">performance</span> and{" "}
              <span className="gradient-text">scale</span>.
            </h1>

            <p className="mt-8 text-xl sm:text-2xl text-zinc-300 leading-relaxed max-w-2xl">
              Fractional CTO and principal-level engineering. Driving
              performance, scalability, best practices, and strategic change to
              help businesses thrive.
            </p>

            <div className="mt-10 flex flex-wrap gap-4">
              <MagneticButton
                href="/#services"
                className="px-6 py-3 bg-gold-400 hover:bg-gold-300 text-zinc-950 text-sm font-medium rounded-xl transition-colors inline-block"
              >
                View Services
              </MagneticButton>
              <MagneticButton
                href="/projects"
                className="px-6 py-3 glass glass-hover text-white text-sm font-medium rounded-xl inline-block"
              >
                Open Source Projects
              </MagneticButton>
            </div>
          </div>
        </div>
      </motion.div>
    </div>
  );
}

function HeroFallback() {
  return (
    <section className="pt-32 pb-20 sm:pt-44 sm:pb-32 relative overflow-hidden">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <FadeIn className="max-w-3xl">
          <h1 className="text-5xl sm:text-7xl font-bold tracking-tight text-white leading-[1.1]">
            Leadership in <span className="gradient-text">performance</span> and{" "}
            <span className="gradient-text">scale</span>.
          </h1>
          <p className="mt-8 text-xl sm:text-2xl text-zinc-300 leading-relaxed max-w-2xl">
            Fractional CTO and principal-level engineering. Driving performance, scalability, best
            practices, and strategic change to help businesses thrive.
          </p>
          <div className="mt-10 flex flex-wrap gap-4">
            <Link
              href="/#services"
              className="px-6 py-3 bg-gold-400 hover:bg-gold-300 text-zinc-950 text-sm font-medium rounded-xl transition-colors"
            >
              View Services
            </Link>
            <Link
              href="/projects"
              className="px-6 py-3 glass glass-hover text-white text-sm font-medium rounded-xl"
            >
              Open Source Projects
            </Link>
          </div>
        </FadeIn>
      </div>
    </section>
  );
}

/**
 * Fixed background layer — stays behind all sections from hero through services.
 * Separate from the scroll sequence so it doesn't disappear when the sticky container unpins.
 */
export function HeroBackground() {
  return (
    <div role="presentation" aria-label="Background graphics" className="fixed inset-0 z-0 pointer-events-none">
      {/* Photo layers at low opacity */}
      <div className="absolute inset-0 opacity-30">
        <img
          src="/images/screen-overlay-fiber-optics.png"
          alt=""
          className="w-full h-full object-cover"
          style={{ filter: "saturate(0.5) sepia(0.2) brightness(0.35) blur(8px)" }}
        />
      </div>
      <div className="absolute inset-0 opacity-25">
        <img
          src="/images/screen-overlay-circuit-traces.png"
          alt=""
          className="w-full h-full object-cover"
          style={{ filter: "saturate(0.65) sepia(0.15) brightness(0.45) contrast(1.15)" }}
        />
      </div>
      <div className="absolute inset-0 opacity-30 mix-blend-screen">
        <img
          src="/images/screen-overlay-gold-particles.png"
          alt=""
          className="w-full h-full object-cover"
        />
      </div>
      {/* SVG grid */}
      <div className="absolute inset-0 opacity-80">
        <HeroGridSVG />
      </div>
    </div>
  );
}

export function HeroSequence({ zIndex }: { zIndex?: number }) {
  return (
    <ScrollSequence scrollHeight="170vh" fallback={<HeroFallback />} zIndex={zIndex}>
      <HeroContent />
    </ScrollSequence>
  );
}
