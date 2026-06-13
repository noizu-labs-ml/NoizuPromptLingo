"use client";

import * as React from "react";
import { Search } from "lucide-react";
import { cn } from "@/lib/cn";

export interface SearchInputProps extends React.InputHTMLAttributes<HTMLInputElement> {}

export const SearchInput = React.forwardRef<HTMLInputElement, SearchInputProps>(
  ({ className, ...props }, ref) => {
    return (
      <div className={cn("relative", className)}>
        <Search
          className="absolute left-3 top-1/2 -translate-y-1/2 text-ink-tertiary pointer-events-none"
          size={16}
          strokeWidth={1.5}
        />
        <input
          ref={ref}
          type="search"
          className={cn(
            "w-full",
            "bg-elevated text-ink",
            "font-sans text-[15px]",
            "pl-10 pr-4 py-3",
            "border border-rule-subtle rounded-lg",
            "transition-[border-color,background-color,box-shadow] duration-200 ease-[ease]",
            "placeholder:text-ink-tertiary",
            "focus:outline-none focus:bg-surface focus:border-rule focus:shadow-[0_2px_8px_rgba(0,0,0,0.06)]"
          )}
          {...props}
        />
      </div>
    );
  }
);

SearchInput.displayName = "SearchInput";
