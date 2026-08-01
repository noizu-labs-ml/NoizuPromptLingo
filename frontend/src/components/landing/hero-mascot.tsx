"use client";

import { useEffect, useRef } from "react";

type HeroMascotProps = {
  src: string;
  label?: string;
};

/** Floating vault companion for the Tobor Locker landing hero. */
export function HeroMascot({ src, label = "tobor · locker" }: HeroMascotProps) {
  const rootRef = useRef<HTMLDivElement>(null);
  const imgWrapRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const root = rootRef.current;
    if (!root) return;
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;

    let frame = 0;
    const onScroll = () => {
      cancelAnimationFrame(frame);
      frame = requestAnimationFrame(() => {
        const rect = root.getBoundingClientRect();
        const vh = window.innerHeight || 1;
        const progress = 1 - (rect.top + rect.height) / (vh + rect.height);
        const t = Math.min(1, Math.max(0, progress));
        const shift = (t - 0.5) * 2;
        if (imgWrapRef.current) {
          imgWrapRef.current.style.transform = `translate3d(${shift * -14}px, ${shift * 20}px, 0)`;
        }
      });
    };

    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => {
      cancelAnimationFrame(frame);
      window.removeEventListener("scroll", onScroll);
    };
  }, []);

  return (
    <div ref={rootRef} className="tlk-hero-mascot" aria-hidden="true">
      <div className="tlk-hero-mascot__glow" />
      <div ref={imgWrapRef} className="tlk-hero-mascot__wrap">
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src={src} alt="" className="tlk-hero-mascot__img" width={220} height={242} />
      </div>
      <span className="tlk-hero-mascot__label">{label}</span>
    </div>
  );
}
