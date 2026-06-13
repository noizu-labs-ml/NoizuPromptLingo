"use client";

import { useRef, ReactNode } from "react";

interface MouseLightCardProps {
  children: ReactNode;
  className?: string;
  lightColor?: string;
}

export function MouseLightCard({
  children,
  className = "",
  lightColor = "rgba(255, 202, 2, 0.06)",
}: MouseLightCardProps) {
  const ref = useRef<HTMLDivElement>(null);

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!ref.current) return;
    const rect = ref.current.getBoundingClientRect();
    const x = ((e.clientX - rect.left) / rect.width) * 100;
    const y = ((e.clientY - rect.top) / rect.height) * 100;
    ref.current.style.setProperty("--mouse-x", `${x}%`);
    ref.current.style.setProperty("--mouse-y", `${y}%`);
    ref.current.style.setProperty("--light-opacity", "1");
  };

  const handleMouseLeave = () => {
    if (ref.current) {
      ref.current.style.setProperty("--light-opacity", "0");
    }
  };

  return (
    <div
      ref={ref}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      className={`relative overflow-hidden ${className}`}
      style={
        {
          "--mouse-x": "50%",
          "--mouse-y": "50%",
          "--light-opacity": "0",
          "--light-color": lightColor,
        } as React.CSSProperties
      }
    >
      <div
        className="absolute inset-0 pointer-events-none transition-opacity duration-300 z-10"
        style={{
          opacity: "var(--light-opacity)" as unknown as number,
          background: `radial-gradient(circle at var(--mouse-x) var(--mouse-y), var(--light-color) 0%, transparent 60%)`,
        }}
      />
      <div className="relative z-0">{children}</div>
    </div>
  );
}
