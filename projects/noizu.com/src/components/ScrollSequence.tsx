"use client";

import { useRef, ReactNode } from "react";
import { useScroll, useReducedMotion } from "framer-motion";
import { ScrollSequenceContext } from "./ScrollSequenceContext";
import { useMediaQuery } from "@/hooks/useMediaQuery";

interface ScrollSequenceProps {
  children: ReactNode;
  fallback?: ReactNode;
  scrollHeight?: string;
  mobileScrollHeight?: string;
  className?: string;
  id?: string;
  zIndex?: number;
  sticky?: boolean;
}

export function ScrollSequence({
  children,
  fallback,
  scrollHeight = "300vh",
  mobileScrollHeight,
  className = "",
  id,
  zIndex = 1,
  sticky = true,
}: ScrollSequenceProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const isMobile = useMediaQuery("(max-width: 767px)");
  const reduced = useReducedMotion();

  const { scrollYProgress } = useScroll({
    target: containerRef,
    // Sticky: progress tracks container from top-top to bottom-bottom (pinned scroll)
    // Non-sticky: progress tracks element visibility through viewport
    offset: sticky
      ? ["start start", "end end"]
      : ["start end", "end start"],
  });

  // Mobile or reduced motion: render fallback
  if ((isMobile || reduced) && fallback) {
    return <div id={id}>{fallback}</div>;
  }

  const height = isMobile && mobileScrollHeight ? mobileScrollHeight : scrollHeight;

  return (
    <ScrollSequenceContext.Provider value={scrollYProgress}>
      <div
        ref={containerRef}
        style={{
          // Sticky sections need fixed height for scroll distance
          // Non-sticky sections size to content
          ...(sticky ? { height } : {}),
          clipPath: "inset(0)",
          zIndex,
        }}
        className={`relative ${className}`}
        id={id}
      >
        <div className={sticky ? "sticky top-0 min-h-screen" : ""}>
          {children}
        </div>
      </div>
    </ScrollSequenceContext.Provider>
  );
}
