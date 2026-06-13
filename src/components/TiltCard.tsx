"use client";

import { useRef, ReactNode } from "react";
import { useReducedMotion } from "framer-motion";

interface TiltCardProps {
  children: ReactNode;
  maxTilt?: number;
  className?: string;
}

export function TiltCard({ children, maxTilt = 5, className = "" }: TiltCardProps) {
  const ref = useRef<HTMLDivElement>(null);
  const reduced = useReducedMotion();

  const handleMouseMove = (e: React.MouseEvent) => {
    if (reduced || !ref.current) return;
    const rect = ref.current.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width - 0.5;
    const y = (e.clientY - rect.top) / rect.height - 0.5;
    ref.current.style.transform = `perspective(1000px) rotateY(${x * maxTilt}deg) rotateX(${-y * maxTilt}deg)`;
  };

  const handleMouseLeave = () => {
    if (ref.current) {
      ref.current.style.transform = "perspective(1000px) rotateY(0deg) rotateX(0deg)";
    }
  };

  return (
    <div
      ref={ref}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      className={className}
      style={{ transition: "transform 300ms ease-out", transformStyle: "preserve-3d" }}
    >
      {children}
    </div>
  );
}
