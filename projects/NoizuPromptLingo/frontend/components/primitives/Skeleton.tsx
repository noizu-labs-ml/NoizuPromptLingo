import clsx from "clsx";

export interface SkeletonProps {
  width?: string | number;
  height?: string | number;
  className?: string;
}

export function Skeleton({ width, height, className }: SkeletonProps) {
  return (
    <div
      className={clsx("rounded bg-surface-1 animate-shimmer", className)}
      style={{ width, height }}
    />
  );
}
