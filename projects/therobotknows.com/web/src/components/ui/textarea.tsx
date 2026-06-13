"use client";

import * as React from "react";
import { cn } from "@/lib/cn";

export interface TextareaProps extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {
  error?: boolean;
}

export const Textarea = React.forwardRef<HTMLTextAreaElement, TextareaProps>(
  ({ error, className, ...props }, ref) => {
    return (
      <textarea
        ref={ref}
        className={cn(
          "w-full min-h-[100px]",
          "bg-surface text-ink",
          "font-body text-[16px] leading-relaxed",
          "p-4",
          "border rounded-lg",
          "resize-vertical",
          "transition-[border-color,box-shadow] duration-200 ease-[ease]",
          "placeholder:text-ink-tertiary placeholder:font-body",
          "focus:outline-none focus:border-link focus:shadow-[0_0_0_3px_var(--focus-ring)]",
          "disabled:opacity-40 disabled:cursor-not-allowed",
          error
            ? "border-flag-error"
            : "border-rule",
          className
        )}
        {...props}
      />
    );
  }
);

Textarea.displayName = "Textarea";
