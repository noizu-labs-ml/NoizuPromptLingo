"use client";
import { useEffect, useState } from "react";

/**
 * Reports the user's `prefers-reduced-motion` media-query state.
 *
 * Returns `true` when the OS requests reduced motion — callers should skip
 * staggered / dramatic animations and jump to the final state.
 *
 * SSR-safe: defaults to `false` on the server; re-evaluates on mount.
 */
export function useReducedMotion(): boolean {
  const [reduced, setReduced] = useState(false);

  useEffect(() => {
    if (typeof window === "undefined" || !window.matchMedia) return;
    const mq = window.matchMedia("(prefers-reduced-motion: reduce)");
    setReduced(mq.matches);
    const handler = (e: MediaQueryListEvent) => setReduced(e.matches);
    // Safari < 14 uses addListener; modern browsers use addEventListener.
    if (typeof mq.addEventListener === "function") {
      mq.addEventListener("change", handler);
      return () => mq.removeEventListener("change", handler);
    }
    mq.addListener(handler);
    return () => mq.removeListener(handler);
  }, []);

  return reduced;
}
