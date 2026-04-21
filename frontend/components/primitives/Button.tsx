"use client";

import clsx from "clsx";
import { forwardRef, ReactNode } from "react";
import { ArrowPathIcon } from "@heroicons/react/24/outline";

export type ButtonVariant =
  | "primary"
  | "secondary"
  | "ghost"
  | "danger"
  | "icon";
export type ButtonSize = "sm" | "md" | "lg";

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  /** Visual style. Defaults to `"primary"`. */
  variant?: ButtonVariant;
  /** Height / padding tier. Defaults to `"md"`. Ignored for `variant="icon"`. */
  size?: ButtonSize;
  /** Swap leading icon with a spinner and disable interaction. */
  loading?: boolean;
  /** Icon rendered before the label. */
  leadingIcon?: ReactNode;
  /** Icon rendered after the label. */
  trailingIcon?: ReactNode;
  /**
   * Slot-style rendering is not implemented yet — reserved for future use.
   * When `true` today the component still renders a `<button>`.
   */
  asChild?: boolean;
}

const variantClasses: Record<ButtonVariant, string> = {
  primary:
    "bg-accent text-accent-on hover:bg-accent-soft",
  secondary:
    "bg-surface-1 text-foreground border border-border hover:bg-surface-2 hover:border-border-strong",
  ghost:
    "text-foreground hover:bg-surface-1",
  danger:
    "bg-danger text-white hover:bg-danger/90",
  icon:
    "text-muted hover:text-foreground hover:bg-surface-1 p-1.5 rounded-md",
};

const sizeClasses: Record<ButtonSize, string> = {
  sm: "text-xs px-2.5 py-1 h-7 rounded gap-1.5",
  md: "text-sm px-3 py-1.5 h-8 rounded-md gap-2",
  lg: "text-sm px-4 py-2 h-10 rounded-md gap-2",
};

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  function Button(
    {
      variant = "primary",
      size = "md",
      loading = false,
      leadingIcon,
      trailingIcon,
      asChild: _asChild,
      className,
      disabled,
      children,
      type,
      ...rest
    },
    ref,
  ) {
    const isDisabled = disabled || loading;
    const isIcon = variant === "icon";

    const leading = loading ? (
      <ArrowPathIcon className="h-3.5 w-3.5 animate-spin-slow" />
    ) : (
      leadingIcon
    );

    return (
      <button
        ref={ref}
        type={type ?? "button"}
        disabled={isDisabled}
        aria-busy={loading || undefined}
        className={clsx(
          "inline-flex items-center justify-center font-medium transition-colors focus-ring",
          variantClasses[variant],
          // Size styles are skipped for icon variant (it defines its own padding/radius).
          !isIcon && sizeClasses[size],
          isDisabled && "opacity-50 cursor-not-allowed",
          className,
        )}
        {...rest}
      >
        {leading}
        {children}
        {trailingIcon}
      </button>
    );
  },
);
