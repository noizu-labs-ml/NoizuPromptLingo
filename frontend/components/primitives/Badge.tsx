"use client";

import clsx from "clsx";
import { ReactNode } from "react";

export type BadgeVariant =
  | "default"
  | "success"
  | "warning"
  | "danger"
  | "info"
  | "accent"
  | "dot";

export type BadgeDotTone =
  | "default"
  | "accent"
  | "success"
  | "warning"
  | "danger"
  | "info";

export interface BadgeProps {
  children?: ReactNode;
  variant?: BadgeVariant;
  size?: "sm" | "md";
  /**
   * When true, prepends a small 6px filled circle (in the variant's text
   * color) before the children. Distinct from the `dot` variant, which
   * renders ONLY a circle with no pill chrome.
   */
  dot?: boolean;
  /**
   * Tint applied to the `dot` *variant* only (the standalone circle). Has no
   * effect when `variant !== "dot"` — in that case the leading `dot` uses the
   * variant's own color. Defaults to `"default"`.
   */
  tone?: BadgeDotTone;
  className?: string;
}

const variantClasses: Record<Exclude<BadgeVariant, "dot">, string> = {
  default: "bg-muted/16 text-muted",
  success: "bg-success/16 text-success",
  warning: "bg-warning/16 text-warning",
  danger: "bg-danger/16 text-danger",
  info: "bg-info/16 text-info",
  accent: "bg-accent/16 text-accent",
};

const sizeClasses: Record<NonNullable<BadgeProps["size"]>, string> = {
  sm: "px-1.5 py-0.5 text-xs",
  md: "px-2.5 py-1 text-sm",
};

/** Color used by the dot-variant and the optional leading dot. */
const dotColor: Record<Exclude<BadgeVariant, "dot">, string> = {
  default: "bg-muted",
  success: "bg-success",
  warning: "bg-warning",
  danger: "bg-danger",
  info: "bg-info",
  accent: "bg-accent",
};

const toneColor: Record<BadgeDotTone, string> = {
  default: "bg-muted",
  accent: "bg-accent",
  success: "bg-success",
  warning: "bg-warning",
  danger: "bg-danger",
  info: "bg-info",
};

export function Badge({
  children,
  variant = "default",
  size = "sm",
  dot = false,
  tone = "default",
  className,
}: BadgeProps) {
  // `dot` variant: just a small filled circle, no pill chrome.
  if (variant === "dot") {
    return (
      <span
        className={clsx(
          "inline-block h-1.5 w-1.5 rounded-full",
          toneColor[tone],
          className
        )}
        aria-hidden="true"
      />
    );
  }

  return (
    <span
      className={clsx(
        "inline-flex items-center gap-1.5 rounded-full font-medium",
        variantClasses[variant],
        sizeClasses[size],
        className
      )}
    >
      {dot && (
        <span
          className={clsx(
            "inline-block h-1.5 w-1.5 rounded-full shrink-0",
            dotColor[variant]
          )}
          aria-hidden="true"
        />
      )}
      {children}
    </span>
  );
}
