"use client";

/* eslint-disable @next/next/no-img-element */
import { motion, useTransform } from "framer-motion";
import { useScrollSequence } from "@/components/ScrollSequenceContext";

export function HeroPhotoLayers() {
  const progress = useScrollSequence();

  // Deep layer: fiber optics — builds up as user scrolls, blur clears
  const deepOpacity = useTransform(progress, [0.1, 0.4, 0.8], [0.05, 0.3, 0.2]);
  const deepBlur = useTransform(progress, [0.1, 0.6], [20, 4]);
  const deepFilter = useTransform(deepBlur, (b) => `saturate(0.5) sepia(0.2) brightness(0.4) blur(${b}px)`);
  const deepY = useTransform(progress, [0, 1], ["5%", "-5%"]);

  // Mid layer: circuit traces — clip-path reveals from center
  const midOpacity = useTransform(progress, [0.15, 0.5, 0.8], [0, 0.25, 0.15]);
  const midClip = useTransform(progress, [0.1, 0.55], [0, 100]);
  const midClipPath = useTransform(midClip, (v) => `circle(${v}% at 50% 50%)`);
  const midY = useTransform(progress, [0, 1], ["3%", "-8%"]);

  // Particle overlay — builds up and drifts upward
  const particleOpacity = useTransform(progress, [0.2, 0.5, 0.9], [0, 0.4, 0.25]);
  const particleY = useTransform(progress, [0, 1], ["10%", "-15%"]);

  return (
    <>
      {/* Deep layer: fiber optics */}
      <motion.div
        style={{ opacity: deepOpacity, y: deepY }}
        className="absolute inset-0 -inset-y-[15%]"
      >
        <motion.img
          src="/images/screen-overlay-fiber-optics.png"
          alt=""
          className="w-full h-full object-cover"
          style={{ filter: deepFilter }}
          loading="eager"
        />
      </motion.div>

      {/* Mid layer: circuit traces */}
      <motion.div
        style={{
          opacity: midOpacity,
          y: midY,
          clipPath: midClipPath,
        }}
        className="absolute inset-0 -inset-y-[10%]"
      >
        <img
          src="/images/screen-overlay-circuit-traces.png"
          alt=""
          className="w-full h-full object-cover"
          style={{ filter: "saturate(0.65) sepia(0.15) brightness(0.5) contrast(1.15)" }}
          loading="eager"
        />
      </motion.div>

      {/* Particle overlay */}
      <motion.div
        style={{ opacity: particleOpacity, y: particleY }}
        className="absolute inset-0 -inset-y-[20%] mix-blend-screen"
      >
        <img
          src="/images/screen-overlay-gold-particles.png"
          alt=""
          className="w-full h-full object-cover"
          loading="eager"
        />
      </motion.div>
    </>
  );
}
