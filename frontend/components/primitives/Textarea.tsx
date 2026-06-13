"use client";

import clsx from "clsx";
import { forwardRef } from "react";

export type TextareaResize = "none" | "y" | "x" | "both";

export interface TextareaProps
  extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {
  /** Show error styling. A string is accepted for co-location; `FormField` renders the message. */
  error?: boolean | string;
  /** When true, render the content with a mono font at a smaller size. */
  mono?: boolean;
  /** Resize affordance. Defaults to `"y"` (vertical only). */
  resize?: TextareaResize;
}

const resizeClasses: Record<TextareaResize, string> = {
  none: "resize-none",
  y: "resize-y",
  x: "resize-x",
  both: "resize",
};

export const Textarea = forwardRef<HTMLTextAreaElement, TextareaProps>(
  function Textarea(
    { error, mono = false, resize = "y", className, disabled, ...rest },
    ref,
  ) {
    const hasError = Boolean(error);
    return (
      <textarea
        ref={ref}
        disabled={disabled}
        aria-invalid={hasError || undefined}
        className={clsx(
          "w-full bg-surface-1 border border-border rounded-sm px-3 py-2 text-sm text-foreground placeholder:text-subtle focus-ring transition-colors",
          resizeClasses[resize],
          mono && "font-mono text-xs",
          hasError &&
            "border-danger focus-visible:shadow-[0_0_0_3px_hsl(var(--danger)/0.25)]",
          disabled && "opacity-60 cursor-not-allowed bg-surface-0",
          className,
        )}
        {...rest}
      />
    );
  },
);
