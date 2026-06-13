"use client";

import { useState, useEffect } from "react";
import { useReducedMotion } from "framer-motion";

interface TypedTextProps {
  text: string;
  speed?: number;
  startDelay?: number;
  className?: string;
}

export function TypedText({
  text,
  speed = 30,
  startDelay = 800,
  className = "",
}: TypedTextProps) {
  const [count, setCount] = useState(0);
  const [started, setStarted] = useState(false);
  const reduced = useReducedMotion();

  useEffect(() => {
    if (reduced) {
      setCount(text.length);
      return;
    }
    const delayTimer = setTimeout(() => setStarted(true), startDelay);
    return () => clearTimeout(delayTimer);
  }, [startDelay, reduced, text.length]);

  useEffect(() => {
    if (!started || count >= text.length) return;
    const timer = setTimeout(() => setCount(c => c + 1), speed);
    return () => clearTimeout(timer);
  }, [started, count, text.length, speed]);

  return (
    <span className={className}>
      {text.slice(0, count)}
      {count < text.length && (
        <span className="inline-block w-[2px] h-[1em] bg-gold-400 ml-0.5 animate-pulse align-middle" />
      )}
    </span>
  );
}
