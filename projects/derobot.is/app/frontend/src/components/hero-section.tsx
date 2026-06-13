"use client";

import { useState } from "react";
import { Logo } from "@/components/logo";
import { VerbCycle } from "@/components/verb-cycle";
import { BlurTagline, FlyingTextLayer } from "@/components/blur-tagline";

export function HeroSection() {
  const [flyActive, setFlyActive] = useState(false);

  return (
    <section className="relative flex min-h-[80vh] flex-col items-center justify-center px-6 text-center bg-[var(--surface)] overflow-hidden">
      {/* Flying text — full section, behind everything */}
      <FlyingTextLayer active={flyActive} />

      {/* Content — above flying text */}
      <div style={{ position: "relative", zIndex: 1 }}>
        <div className="flex justify-center">
          <Logo size={96} showText={false} />
        </div>
        <div className="relative mt-4 pb-16" style={{ width: "min(90vw, 900px)" }}>
          <div className="grid items-baseline pb-12" style={{ gridTemplateColumns: "1fr 8px 8px 1fr" }}>
            <h1 className="sg-page-title text-[var(--text)] font-[family-name:var(--font-display)] text-6xl md:text-8xl tracking-tight leading-none text-right">
              derobot.is
            </h1>
            <div />
            <div />
            <div className="text-left overflow-hidden">
              <VerbCycle variant="hero" size="lg" />
            </div>
          </div>
          <hr className="absolute left-1/2 -translate-x-1/2 border-0 h-[3px] bg-[var(--text-link)]" style={{ bottom: "42px", width: "min(80vw, 700px)" }} />
        </div>
      </div>

      {/* Blurred tagline anchored to bottom */}
      <div className="absolute bottom-8 left-0 right-0 flex justify-center select-none py-6" style={{ zIndex: 1 }}>
        <BlurTagline onHoverChange={setFlyActive} />
      </div>
    </section>
  );
}
