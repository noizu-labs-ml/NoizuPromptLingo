"use client";

import clsx from "clsx";
import { forwardRef } from "react";
import { ChevronDownIcon } from "@heroicons/react/24/outline";

export type SelectSize = "sm" | "md";

export interface SelectProps
  extends Omit<React.SelectHTMLAttributes<HTMLSelectElement>, "size"> {
  /** Show error styling. A string is accepted for co-location; `FormField` renders the message. */
  error?: boolean | string;
  /**
   * Visual sizing. Named `inputSize` to match `Input` — native `<select size>`
   * is a separate integer attribute.
   */
  inputSize?: SelectSize;
}

const sizeClasses: Record<SelectSize, string> = {
  sm: "text-xs pl-2.5 pr-8 py-1",
  md: "text-sm pl-3 pr-8 py-1.5",
};

export const Select = forwardRef<HTMLSelectElement, SelectProps>(function Select(
  { error, inputSize = "md", className, disabled, children, ...rest },
  ref,
) {
  const hasError = Boolean(error);

  return (
    <div
      className={clsx(
        "relative inline-flex items-center w-full",
        className,
      )}
    >
      <select
        ref={ref}
        disabled={disabled}
        aria-invalid={hasError || undefined}
        className={clsx(
          "appearance-none w-full bg-surface-1 border border-border rounded-sm text-foreground focus-ring transition-colors",
          sizeClasses[inputSize],
          hasError &&
            "border-danger focus-visible:shadow-[0_0_0_3px_hsl(var(--danger)/0.25)]",
          disabled && "opacity-60 cursor-not-allowed bg-surface-0",
        )}
        {...rest}
      >
        {children}
      </select>
      <ChevronDownIcon
        aria-hidden="true"
        className="pointer-events-none absolute right-2 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-subtle"
      />
    </div>
  );
});
