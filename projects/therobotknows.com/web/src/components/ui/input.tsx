"use client";

import * as React from "react";
import { cn } from "@/lib/cn";

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  error?: boolean;
}

export const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ error, className, ...props }, ref) => {
    return (
      <input
        ref={ref}
        className={cn(
          "w-full",
          "bg-surface text-ink",
          "font-sans text-[15px]",
          "px-3.5 py-2.5",
          "border rounded-sm",
          "transition-[border-color,box-shadow] duration-200 ease-[ease]",
          "placeholder:text-ink-tertiary",
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

Input.displayName = "Input";
