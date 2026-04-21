"use client";

import clsx from "clsx";
import { forwardRef, ReactNode } from "react";

export type InputSize = "sm" | "md";

export interface InputProps
  extends Omit<React.InputHTMLAttributes<HTMLInputElement>, "prefix" | "size"> {
  /** Show error styling. A string is accepted for co-location; `FormField` renders the message. */
  error?: boolean | string;
  /** Slot rendered absolute-positioned inside the input's left edge. */
  prefixEl?: ReactNode;
  /** Slot rendered absolute-positioned inside the input's right edge. */
  suffixEl?: ReactNode;
  /**
   * Visual sizing. Named `inputSize` because native `<input size>` is a
   * different integer-typed attribute.
   */
  inputSize?: InputSize;
}

const sizeClasses: Record<InputSize, string> = {
  sm: "text-xs px-2.5 py-1",
  md: "text-sm px-3 py-1.5",
};

export const Input = forwardRef<HTMLInputElement, InputProps>(function Input(
  {
    error,
    prefixEl,
    suffixEl,
    inputSize = "md",
    className,
    disabled,
    type,
    ...rest
  },
  ref,
) {
  const hasError = Boolean(error);
  const hasAffix = Boolean(prefixEl || suffixEl);

  const inputEl = (
    <input
      ref={ref}
      type={type ?? "text"}
      disabled={disabled}
      aria-invalid={hasError || undefined}
      className={clsx(
        "w-full bg-surface-1 border border-border rounded-sm text-foreground placeholder:text-subtle focus-ring transition-colors",
        sizeClasses[inputSize],
        prefixEl && "pl-8",
        suffixEl && "pr-8",
        hasError &&
          "border-danger focus-visible:shadow-[0_0_0_3px_hsl(var(--danger)/0.25)]",
        disabled && "opacity-60 cursor-not-allowed bg-surface-0",
        className,
      )}
      {...rest}
    />
  );

  if (!hasAffix) return inputEl;

  return (
    <div className="relative flex items-center w-full">
      {prefixEl && (
        <span
          className="pointer-events-none absolute left-2.5 top-1/2 -translate-y-1/2 flex items-center text-subtle"
          aria-hidden="true"
        >
          {prefixEl}
        </span>
      )}
      {inputEl}
      {suffixEl && (
        <span
          className="pointer-events-none absolute right-2.5 top-1/2 -translate-y-1/2 flex items-center text-subtle"
          aria-hidden="true"
        >
          {suffixEl}
        </span>
      )}
    </div>
  );
});
