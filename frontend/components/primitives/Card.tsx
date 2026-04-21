"use client";

import clsx from "clsx";
import { ReactNode } from "react";

export type CardDensity = "compact" | "normal" | "spacious";
export type CardSurface = 0 | 1 | 2 | "elevated";

export interface CardProps {
  children: ReactNode;
  className?: string;
  /**
   * @deprecated Use `density` instead. When `false`, padding is omitted.
   * When `true` (default), the density token decides padding.
   */
  padded?: boolean;
  /** Padding density. Defaults to `"normal"` (p-4). */
  density?: CardDensity;
  /** Background surface tier. Defaults to `0` (bg-surface-0). */
  surface?: CardSurface;
  /** Adds subtle hover elevation + stronger border transition. */
  hoverable?: boolean;
}

const densityClasses: Record<CardDensity, string> = {
  compact: "p-3",
  normal: "p-4",
  spacious: "p-6",
};

const surfaceClasses: Record<"0" | "1" | "2" | "elevated", string> = {
  "0": "bg-surface-0",
  "1": "bg-surface-1",
  "2": "bg-surface-2",
  elevated: "bg-elevated shadow-ambient",
};

export function Card({
  children,
  className,
  padded = true,
  density = "normal",
  surface = 0,
  hoverable = false,
}: CardProps) {
  const surfaceKey = (surface === "elevated" ? "elevated" : String(surface)) as
    | "0"
    | "1"
    | "2"
    | "elevated";

  return (
    <div
      className={clsx(
        "border border-border rounded-lg",
        surfaceClasses[surfaceKey],
        padded && densityClasses[density],
        hoverable &&
          "hover:shadow-ambient hover:border-border-strong transition-shadow cursor-pointer",
        className
      )}
    >
      {children}
    </div>
  );
}
