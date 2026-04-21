"use client";

import clsx from "clsx";
import { MagnifyingGlassIcon, XMarkIcon } from "@heroicons/react/20/solid";

export interface SearchBoxProps {
  value: string;
  onChange: (v: string) => void;
  placeholder?: string;
  onClear?: () => void;
}

export function SearchBox({
  value,
  onChange,
  placeholder = "Search…",
  onClear,
}: SearchBoxProps) {
  const showClear = value.length > 0 && onClear;

  return (
    <div className="relative flex items-center">
      <MagnifyingGlassIcon className="pointer-events-none absolute left-3 h-4 w-4 text-muted" />
      <input
        type="text"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className={clsx(
          "w-full bg-surface-1 border border-border rounded-md",
          "pl-9 pr-3 py-2 text-sm text-foreground placeholder:text-muted",
          "focus-ring transition-colors",
          showClear && "pr-9"
        )}
      />
      {showClear && (
        <button
          type="button"
          onClick={onClear}
          className="focus-ring absolute right-2 rounded p-0.5 text-muted hover:text-foreground transition-colors"
          aria-label="Clear search"
        >
          <XMarkIcon className="h-4 w-4" />
        </button>
      )}
    </div>
  );
}
