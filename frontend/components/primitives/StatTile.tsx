import clsx from "clsx";
import Link from "next/link";
import { ReactNode } from "react";
import { heading } from "@/lib/ui/typography";
import { focusRing } from "@/lib/utils/focusRing";

export type StatTileTrend = "up" | "down" | "flat";

export interface StatTileDelta {
  /** The numeric/textual change, e.g. "+12" or "-3%". */
  value: ReactNode;
  /** Controls arrow glyph + color. Defaults to "flat". */
  trend?: StatTileTrend;
}

export interface StatTileProps {
  /** Uppercase label ("tasks", "sessions"). Rendered via typography.label. */
  label: ReactNode;
  /** Large value — usually a number. */
  value: ReactNode;
  /** Optional delta chip beneath the value. */
  delta?: StatTileDelta;
  /** Optional icon rendered next to the label. */
  icon?: ReactNode;
  /** When provided, the whole tile becomes a Next.js Link. */
  href?: string;
  className?: string;
}

const trendClasses: Record<StatTileTrend, string> = {
  up: "text-success",
  down: "text-danger",
  flat: "text-subtle",
};

const trendGlyph: Record<StatTileTrend, string> = {
  up: "▲",
  down: "▼",
  flat: "—",
};

function Delta({ value, trend = "flat" }: StatTileDelta) {
  return (
    <span
      className={clsx(
        "inline-flex items-center gap-1 text-xs font-mono",
        trendClasses[trend]
      )}
    >
      <span aria-hidden="true">{trendGlyph[trend]}</span>
      <span>{value}</span>
    </span>
  );
}

function TileContent({
  label,
  value,
  delta,
  icon,
}: Pick<StatTileProps, "label" | "value" | "delta" | "icon">) {
  return (
    <>
      <div className={clsx("flex items-center gap-2", heading.label)}>
        {icon && (
          <span className="inline-flex shrink-0" aria-hidden="true">
            {icon}
          </span>
        )}
        <span>{label}</span>
      </div>
      <div className="text-2xl font-semibold font-sans text-foreground tabular-nums">
        {value}
      </div>
      {delta && <Delta value={delta.value} trend={delta.trend} />}
    </>
  );
}

const shellClasses =
  "rounded-lg bg-surface-0 border border-border p-4 flex flex-col gap-2 " +
  "hover:border-border-strong hover:shadow-ambient transition-shadow";

/**
 * Stat card primitive used on dashboards. Displays a label + large value,
 * with optional trend delta and icon. Becomes a link when `href` is set.
 */
export function StatTile({
  label,
  value,
  delta,
  icon,
  href,
  className,
}: StatTileProps) {
  if (href) {
    return (
      <Link href={href} className={clsx(shellClasses, focusRing, className)}>
        <TileContent label={label} value={value} delta={delta} icon={icon} />
      </Link>
    );
  }
  return (
    <div className={clsx(shellClasses, className)}>
      <TileContent label={label} value={value} delta={delta} icon={icon} />
    </div>
  );
}
