import clsx from "clsx";

export type SkeletonGridShape = "card" | "row" | "tile" | "table";

export interface SkeletonGridProps {
  /** Number of skeleton placeholders to render. Defaults to 6. */
  count?: number;
  /** Visual shape of each placeholder; controls wrapper layout + item size. */
  as?: SkeletonGridShape;
  /** Optional className override for the wrapper. */
  className?: string;
}

const wrapperClasses: Record<SkeletonGridShape, string> = {
  card: "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4",
  row: "flex flex-col gap-2",
  tile: "grid grid-cols-2 md:grid-cols-4 gap-3",
  table: "flex flex-col gap-0.5",
};

const itemClasses: Record<SkeletonGridShape, string> = {
  card: "h-28 rounded-lg bg-surface-1 animate-shimmer",
  row: "h-12 rounded-lg bg-surface-1 animate-shimmer",
  tile: "h-20 rounded-lg bg-surface-1 animate-shimmer",
  table: "h-10 rounded bg-surface-1 animate-shimmer",
};

/**
 * Renders `count` loading placeholders shaped like the target component.
 * Use in place of ad-hoc `[1, 2, 3].map(...)` skeleton stacks.
 */
export function SkeletonGrid({
  count = 6,
  as = "card",
  className,
}: SkeletonGridProps) {
  return (
    <div
      className={clsx(wrapperClasses[as], className)}
      aria-hidden="true"
      data-skeleton-shape={as}
    >
      {Array.from({ length: count }).map((_, i) => (
        <div key={i} className={itemClasses[as]} />
      ))}
    </div>
  );
}
