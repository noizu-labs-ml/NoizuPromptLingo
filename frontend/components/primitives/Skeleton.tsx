import clsx from "clsx";

export interface SkeletonProps {
  width?: string | number;
  height?: string | number;
  className?: string;
}

export function Skeleton({ width, height, className }: SkeletonProps) {
  return (
    <div
      className={clsx("animate-pulse bg-surface-raised rounded", className)}
      style={{ width, height }}
    />
  );
}
