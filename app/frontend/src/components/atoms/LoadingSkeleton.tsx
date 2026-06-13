"use client";

import React from "react";

/**
 * LoadingSkeleton — Animated placeholder mimicking content layout during loading states.
 *
 * @example
 * ```tsx
 * <LoadingSkeleton width={200} height={16} />
 * <LoadingSkeleton variant="circle" width={40} />
 * <LoadingSkeleton variant="card" />
 * <LoadingSkeleton variant="text" lines={3} />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

type SkeletonVariant = "rect" | "circle" | "text" | "card";

interface LoadingSkeletonProps {
  /** Shape variant */
  variant?: SkeletonVariant;
  /** Width in px or CSS string. Defaults to 100% for rect/text, explicit for circle. */
  width?: number | string;
  /** Height in px. Defaults based on variant. */
  height?: number | string;
  /** Number of text lines (text variant only) */
  lines?: number;
  /** Border radius override */
  borderRadius?: number | string;
  /** Additional inline styles */
  style?: React.CSSProperties;
}

// ── Component ───────────────────────────────────────────────────

function SkeletonRect({
  width = "100%",
  height = 16,
  borderRadius = 4,
  style,
}: Pick<LoadingSkeletonProps, "width" | "height" | "borderRadius" | "style">) {
  return (
    <>
      <div
        aria-hidden="true"
        style={{
          width: typeof width === "number" ? `${width}px` : width,
          height: typeof height === "number" ? `${height}px` : height,
          borderRadius: typeof borderRadius === "number" ? `${borderRadius}px` : borderRadius,
          background: "color-mix(in srgb, var(--text-muted) 12%, transparent)",
          animation: "skeleton-shimmer 1.5s ease-in-out infinite",
          ...style,
        }}
      />
      <style>{`
        @keyframes skeleton-shimmer {
          0% { opacity: 1; }
          50% { opacity: 0.4; }
          100% { opacity: 1; }
        }
      `}</style>
    </>
  );
}

export function LoadingSkeleton({
  variant = "rect",
  width,
  height,
  lines = 3,
  borderRadius,
  style,
}: LoadingSkeletonProps) {
  if (variant === "circle") {
    const size = width ?? 40;
    return (
      <SkeletonRect
        width={size}
        height={size}
        borderRadius="50%"
        style={style}
      />
    );
  }

  if (variant === "text") {
    return (
      <div
        role="status"
        aria-label="Loading"
        style={{ display: "flex", flexDirection: "column", gap: "8px", ...style }}
      >
        {Array.from({ length: lines }).map((_, i) => (
          <SkeletonRect
            key={i}
            width={i === lines - 1 ? "60%" : "100%"}
            height={height ?? 14}
            borderRadius={borderRadius ?? 4}
          />
        ))}
      </div>
    );
  }

  if (variant === "card") {
    return (
      <div
        role="status"
        aria-label="Loading"
        style={{
          padding: "var(--space-3)",
          borderRadius: "var(--radius, 6px)",
          border: "1px solid var(--border)",
          background: "var(--surface)",
          display: "flex",
          flexDirection: "column",
          gap: "var(--space-2)",
          ...style,
        }}
      >
        <SkeletonRect width="40%" height={12} />
        <SkeletonRect width="100%" height={20} />
        <SkeletonRect width="75%" height={12} />
        <div style={{ display: "flex", gap: "var(--space-2)", marginTop: "var(--space-1)" }}>
          <SkeletonRect width={60} height={20} borderRadius={999} />
          <SkeletonRect width={80} height={20} borderRadius={999} />
        </div>
      </div>
    );
  }

  // rect (default)
  return (
    <div role="status" aria-label="Loading">
      <SkeletonRect
        width={width}
        height={height}
        borderRadius={borderRadius}
        style={style}
      />
    </div>
  );
}

export default LoadingSkeleton;
