"use client";

import { createContext, useContext } from "react";
import type { MotionValue } from "framer-motion";

export const ScrollSequenceContext = createContext<MotionValue<number> | null>(null);

export function useScrollSequence() {
  const ctx = useContext(ScrollSequenceContext);
  if (!ctx) throw new Error("useScrollSequence must be used within ScrollSequence");
  return ctx;
}
