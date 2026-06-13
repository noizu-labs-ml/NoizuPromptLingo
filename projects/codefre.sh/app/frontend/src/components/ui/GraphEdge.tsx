"use client";
import * as React from "react";

export type GraphEdgeVariant = "default" | "active" | "freeball";

export interface GraphEdgeProps {
  from: { x: number; y: number };
  to: { x: number; y: number };
  variant?: GraphEdgeVariant;
  label?: string;
  /** Bezier curve strength (0..1); default 0.5 */
  curvature?: number;
  className?: string;
  ariaLabel?: string;
}

/**
 * SVG edge between two graph node anchor points. Provides default / active / freeball variants.
 *
 * @example
 * <svg><GraphEdge from={{x:10,y:20}} to={{x:200,y:40}} variant="freeball" label="off-script" /></svg>
 */
export function GraphEdge({
  from,
  to,
  variant = "default",
  label,
  curvature = 0.5,
  className,
  ariaLabel,
}: GraphEdgeProps) {
  const dx = to.x - from.x;
  const c1x = from.x + dx * curvature;
  const c2x = to.x - dx * curvature;
  const d = `M ${from.x} ${from.y} C ${c1x} ${from.y}, ${c2x} ${to.y}, ${to.x} ${to.y}`;

  const classes = [
    "sg-graph-edge",
    variant === "active" ? "sg-graph-edge--active" : "",
    variant === "freeball" ? "sg-graph-edge--freeball" : "",
    className || "",
  ]
    .filter(Boolean)
    .join(" ");

  const midX = (from.x + to.x) / 2;
  const midY = (from.y + to.y) / 2;

  return (
    <g role="img" aria-label={ariaLabel || label || "edge"}>
      <path d={d} className={classes} />
      {label ? (
        <text
          x={midX}
          y={midY - 4}
          fontSize="11"
          fill="var(--text-secondary)"
          fontFamily="var(--font-sans)"
          textAnchor="middle"
        >
          {label}
        </text>
      ) : null}
    </g>
  );
}
