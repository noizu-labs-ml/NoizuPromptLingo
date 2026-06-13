"use client";

import * as React from "react";
import { ChevronDown } from "lucide-react";
import { cn } from "@/lib/cn";

export interface SelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  error?: boolean;
}

export const Select = React.forwardRef<HTMLSelectElement, SelectProps>(
  ({ error, className, children, ...props }, ref) => {
    return (
      <div className="relative">
        <select
          ref={ref}
          className={cn(
            "w-full appearance-none",
            "bg-surface text-ink",
            "font-sans text-[15px]",
            "px-3.5 py-2.5 pr-9",
            "border rounded-sm",
            "transition-[border-color,box-shadow] duration-200 ease-[ease]",
            "cursor-pointer",
            "focus:outline-none focus:border-link focus:shadow-[0_0_0_3px_var(--focus-ring)]",
            "disabled:opacity-40 disabled:cursor-not-allowed",
            error
              ? "border-flag-error"
              : "border-rule",
            className
          )}
          {...props}
        >
          {children}
        </select>
        <ChevronDown
          className="absolute right-3 top-1/2 -translate-y-1/2 text-ink-tertiary pointer-events-none"
          size={14}
          strokeWidth={1.5}
        />
      </div>
    );
  }
);

Select.displayName = "Select";
