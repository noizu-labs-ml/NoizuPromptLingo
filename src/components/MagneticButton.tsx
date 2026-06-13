"use client";

import { useRef, ReactNode } from "react";
import { useReducedMotion } from "framer-motion";

interface MagneticButtonProps {
  children: ReactNode;
  strength?: number;
  className?: string;
  href?: string;
  onClick?: () => void;
  target?: string;
  rel?: string;
}

export function MagneticButton({
  children,
  strength = 0.15,
  className = "",
  href,
  onClick,
  target,
  rel,
}: MagneticButtonProps) {
  const ref = useRef<HTMLDivElement>(null);
  const reduced = useReducedMotion();

  const handleMouseMove = (e: React.MouseEvent) => {
    if (reduced || !ref.current) return;
    const rect = ref.current.getBoundingClientRect();
    const x = e.clientX - rect.left - rect.width / 2;
    const y = e.clientY - rect.top - rect.height / 2;
    ref.current.style.transform = `translate(${x * strength}px, ${y * strength}px)`;
  };

  const handleMouseLeave = () => {
    if (ref.current) {
      ref.current.style.transform = "translate(0, 0)";
    }
  };

  const inner = href ? (
    <a href={href} target={target} rel={rel} className={className}>
      {children}
    </a>
  ) : (
    <button onClick={onClick} className={className}>
      {children}
    </button>
  );

  return (
    <div
      ref={ref}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      style={{ transition: "transform 200ms ease-out", display: "inline-block" }}
    >
      {inner}
    </div>
  );
}
