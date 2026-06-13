"use client";

/* eslint-disable @next/next/no-img-element */
import { useState } from "react";
import { motion, useTransform } from "framer-motion";
import { ScrollSequence } from "@/components/ScrollSequence";
import { useScrollSequence } from "@/components/ScrollSequenceContext";
import { MagneticButton } from "@/components/MagneticButton";
import { ContactModal } from "@/components/ContactModal";
import { FadeIn } from "@/components/FadeIn";

function CTAContent() {
  const [contactOpen, setContactOpen] = useState(false);
  const progress = useScrollSequence();

  // Beacon point grows
  const beaconScale = useTransform(progress, [0, 0.15, 0.45], [1, 1, 50]);
  const beaconOpacity = useTransform(progress, [0, 0.1, 0.35, 0.5], [0.6, 0.8, 0.4, 0]);

  // Glow expands
  const glowScale = useTransform(progress, [0.2, 0.6], [0, 1]);
  const glowOpacity = useTransform(progress, [0.2, 0.5], [0, 0.12]);

  // Background layers
  const bgOpacity = useTransform(progress, [0.1, 0.4], [0, 1]);

  // Card reveals
  const cardOpacity = useTransform(progress, [0.35, 0.55], [0, 1]);
  const cardY = useTransform(progress, [0.35, 0.55], [40, 0]);
  const cardScale = useTransform(progress, [0.35, 0.55], [0.95, 1]);

  // Buttons
  const btnOpacity = useTransform(progress, [0.55, 0.7], [0, 1]);
  const btnY = useTransform(progress, [0.55, 0.7], [20, 0]);

  // Particle convergence
  const convOpacity = useTransform(progress, [0.3, 0.6], [0, 0.3]);
  const convScale = useTransform(progress, [0.3, 0.7], [1.5, 1]);

  return (
    <div className="relative w-full min-h-screen bg-zinc-950 flex items-center justify-center overflow-hidden">
      {/* Beacon dot */}
      <motion.div
        role="presentation"
        style={{ scale: beaconScale, opacity: beaconOpacity }}
        className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-2 h-2 rounded-full bg-gold-400"
      />

      {/* Expanding glow */}
      <motion.div
        role="presentation"
        style={{ scale: glowScale, opacity: glowOpacity }}
        className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] rounded-full bg-gold-400 blur-[100px]"
      />

      {/* Background photo layers */}
      <motion.div
        role="presentation"
        aria-label="CTA background"
        style={{ opacity: bgOpacity }}
        className="absolute inset-0 overflow-hidden pointer-events-none"
      >
        <div className="absolute inset-0 opacity-25">
          <img
            src="/images/screen-overlay-fiber-optics.png"
            alt=""
            className="w-full h-full object-cover"
            style={{ filter: "saturate(0.6) sepia(0.15) brightness(0.4) blur(6px)" }}
          />
        </div>
        <div className="absolute inset-0 opacity-30 mix-blend-screen">
          <img
            src="/images/screen-overlay-gold-particles.png"
            alt=""
            className="w-full h-full object-cover"
          />
        </div>
      </motion.div>

      {/* Particle convergence */}
      <motion.div
        role="presentation"
        style={{
          opacity: convOpacity,
          scale: convScale,
        }}
        className="absolute inset-0 mix-blend-screen"
      >
        <img
          src="/images/screen-overlay-gold-particles.png"
          alt=""
          className="w-full h-full object-cover"
          loading="lazy"
        />
      </motion.div>

      {/* CTA Card */}
      <motion.div
        style={{ opacity: cardOpacity, y: cardY, scale: cardScale }}
        className="relative z-10 mx-auto max-w-3xl px-6"
      >
        <div className="glass glow rounded-3xl">
          <div className="px-8 py-14 sm:px-16 sm:py-20 text-center">
            <h2 className="text-3xl sm:text-4xl font-bold text-white mb-4">
              Let&apos;s work together
            </h2>
            <p className="text-base text-zinc-300 max-w-xl mx-auto mb-8">
              Looking for fractional technology leadership or principal-level engineering expertise?
              Let&apos;s discuss how I can help.
            </p>
            <motion.div
              style={{ opacity: btnOpacity, y: btnY }}
              className="flex flex-wrap justify-center gap-4"
            >
              <MagneticButton
                onClick={() => setContactOpen(true)}
                className="px-6 py-3 bg-gold-400 hover:bg-gold-300 text-black text-sm font-medium rounded-xl transition-colors inline-block"
              >
                Get in Touch
              </MagneticButton>
              <MagneticButton
                href="https://github.com/noizu-labs"
                target="_blank"
                rel="noopener noreferrer"
                className="px-6 py-3 glass glass-hover text-white text-sm font-medium rounded-xl inline-flex items-center gap-2"
              >
                <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
                </svg>
                GitHub
              </MagneticButton>
            </motion.div>
          </div>
        </div>
      </motion.div>

      <ContactModal open={contactOpen} onClose={() => setContactOpen(false)} />
    </div>
  );
}

function CTAFallback() {
  const [contactOpen, setContactOpen] = useState(false);

  return (
    <section id="contact" className="py-20 sm:py-28">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <FadeIn>
          <div className="glass glow rounded-3xl">
            <div className="px-8 py-16 sm:px-16 sm:py-24 text-center">
              <h2 className="text-3xl sm:text-4xl font-bold text-white mb-4">
                Let&apos;s work together
              </h2>
              <p className="text-base text-zinc-300 max-w-xl mx-auto mb-8">
                Looking for fractional technology leadership or principal-level engineering expertise?
                Let&apos;s discuss how I can help.
              </p>
              <div className="flex flex-wrap justify-center gap-4">
                <button onClick={() => setContactOpen(true)} className="px-6 py-3 bg-gold-400 hover:bg-gold-300 text-black text-sm font-medium rounded-xl transition-colors">
                  Get in Touch
                </button>
                <a href="https://github.com/noizu-labs" target="_blank" rel="noopener noreferrer" className="px-6 py-3 glass glass-hover text-white text-sm font-medium rounded-xl inline-flex items-center gap-2">
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
                  </svg>
                  GitHub
                </a>
              </div>
            </div>
          </div>
        </FadeIn>
      </div>
      <ContactModal open={contactOpen} onClose={() => setContactOpen(false)} />
    </section>
  );
}

export function CTASequence({ zIndex }: { zIndex?: number }) {
  return (
    <ScrollSequence scrollHeight="150vh" fallback={<CTAFallback />} id="contact" zIndex={zIndex}>
      <CTAContent />
    </ScrollSequence>
  );
}
