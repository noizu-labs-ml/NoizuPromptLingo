"use client";

import clsx from "clsx";
import { ReactNode } from "react";
import { focusRing } from "@/lib/utils/focusRing";

export interface SegmentedOption<V extends string> {
  value: V;
  label: ReactNode;
  icon?: ReactNode;
}

export interface SegmentedProps<V extends string> {
  value: V;
  onChange: (value: V) => void;
  options: SegmentedOption<V>[];
  /** Visual size. Defaults to `"md"`. */
  size?: "sm" | "md";
  className?: string;
  "aria-label"?: string;
}

const sizeClasses: Record<NonNullable<SegmentedProps<string>["size"]>, string> = {
  sm: "py-0.5 px-2 text-[11px]",
  md: "px-3 py-1 text-xs",
};

/**
 * Pill-style multi-option toggle. Generic over the value type `V` so callers
 * get literal-union narrowing on `onChange`.
 */
export function Segmented<V extends string>({
  value,
  onChange,
  options,
  size = "md",
  className,
  "aria-label": ariaLabel,
}: SegmentedProps<V>) {
  return (
    <div
      role="tablist"
      aria-label={ariaLabel}
      className={clsx(
        "inline-flex rounded-md border border-border bg-surface-0 p-0.5",
        className
      )}
    >
      {options.map((opt) => {
        const active = opt.value === value;
        return (
          <button
            key={opt.value}
            type="button"
            role="tab"
            aria-selected={active}
            onClick={() => onChange(opt.value)}
            className={clsx(
              "inline-flex items-center gap-1.5 rounded font-medium transition-colors",
              sizeClasses[size],
              focusRing,
              active
                ? "bg-accent text-accent-on shadow-ambient"
                : "text-muted hover:text-foreground hover:bg-surface-1"
            )}
          >
            {opt.icon && (
              <span className="inline-flex shrink-0" aria-hidden="true">
                {opt.icon}
              </span>
            )}
            {opt.label}
          </button>
        );
      })}
    </div>
  );
}
