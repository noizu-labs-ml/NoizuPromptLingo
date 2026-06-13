"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";

export type SkeletonVariant = "text" | "card" | "row" | "graph-node" | "table";

export interface LoadingSkeletonProps {
  variant?: SkeletonVariant;
  count?: number;
  width?: string | number;
  height?: string | number;
  className?: string;
  cy?: string;
}

const variantDefaults: Record<SkeletonVariant, { h: string; w: string }> = {
  text: { h: "14px", w: "100%" },
  card: { h: "120px", w: "100%" },
  row: { h: "48px", w: "100%" },
  "graph-node": { h: "80px", w: "240px" },
  table: { h: "36px", w: "100%" },
};

/**
 * Shimmering skeleton placeholder. Respects prefers-reduced-motion.
 *
 * @example
 * <LoadingSkeleton variant="card" count={3} />
 */
export function LoadingSkeleton({
  variant = "text",
  count = 1,
  width,
  height,
  className,
  cy = "skeleton",
}: LoadingSkeletonProps) {
  const def = variantDefaults[variant];
  const h = height ?? def.h;
  const w = width ?? def.w;

  const items: React.ReactElement[] = [];
  for (let i = 0; i < count; i++) {
    items.push(
      <span
        key={i}
        aria-hidden="true"
        className={["sg-skeleton", className || ""].filter(Boolean).join(" ")}
        style={{
          width: typeof w === "number" ? `${w}px` : w,
          height: typeof h === "number" ? `${h}px` : h,
          marginBottom: count > 1 ? "8px" : undefined,
        }}
        {...cyAttrs({ cy, cyId: i })}
      />
    );
  }

  return (
    <div role="status" aria-busy="true" aria-label="Loading">
      {items}
    </div>
  );
}
