import * as React from "react";
import { ZoomIn, ZoomOut, Maximize2, Search } from "lucide-react";
import { cn } from "@/lib/cn";
import type { EntryType } from "@/lib/constants";
import { ENTRY_TYPE_LABELS, ENTRY_TYPES } from "@/lib/constants";

interface GraphControlsProps {
  searchQuery: string;
  onSearchChange: (value: string) => void;
  typeFilter: EntryType | "all";
  onTypeFilterChange: (value: EntryType | "all") => void;
  onZoomIn: () => void;
  onZoomOut: () => void;
  onFitToScreen: () => void;
}

export function GraphControls({
  searchQuery,
  onSearchChange,
  typeFilter,
  onTypeFilterChange,
  onZoomIn,
  onZoomOut,
  onFitToScreen,
}: GraphControlsProps) {
  return (
    <div className="flex items-center gap-3 px-4 py-2.5 border-b border-rule bg-surface">
      {/* Type filter */}
      <div className="relative">
        <select
          value={typeFilter}
          onChange={(e) => onTypeFilterChange(e.target.value as EntryType | "all")}
          className={cn(
            "appearance-none bg-elevated text-ink font-sans text-[13px]",
            "px-3 py-1.5 pr-7 border border-rule rounded-sm",
            "focus:outline-none focus:border-link focus:shadow-[0_0_0_3px_var(--focus-ring)]",
            "cursor-pointer transition-colors duration-200"
          )}
        >
          <option value="all">All Types</option>
          {ENTRY_TYPES.map((type) => (
            <option key={type} value={type}>
              {ENTRY_TYPE_LABELS[type]}
            </option>
          ))}
        </select>
        <span className="pointer-events-none absolute right-2 top-1/2 -translate-y-1/2 text-ink-tertiary text-[10px]">
          ▾
        </span>
      </div>

      {/* Search */}
      <div className="relative flex-1 max-w-xs">
        <Search
          size={14}
          strokeWidth={1.5}
          className="absolute left-2.5 top-1/2 -translate-y-1/2 text-ink-tertiary pointer-events-none"
        />
        <input
          type="text"
          placeholder="Search entries…"
          value={searchQuery}
          onChange={(e) => onSearchChange(e.target.value)}
          className={cn(
            "w-full pl-8 pr-3 py-1.5",
            "bg-elevated text-ink font-sans text-[13px]",
            "border border-rule rounded-sm",
            "placeholder:text-ink-tertiary",
            "focus:outline-none focus:border-link focus:shadow-[0_0_0_3px_var(--focus-ring)]",
            "transition-[border-color,box-shadow] duration-200"
          )}
        />
      </div>

      {/* Spacer */}
      <div className="flex-1" />

      {/* Zoom controls */}
      <div className="flex items-center gap-1">
        <button
          onClick={onZoomOut}
          title="Zoom out"
          className={cn(
            "p-1.5 rounded-sm text-ink-secondary",
            "hover:text-ink hover:bg-elevated",
            "transition-colors duration-200",
            "focus-visible:outline-2 focus-visible:outline-link"
          )}
        >
          <ZoomOut size={15} strokeWidth={1.5} />
        </button>
        <button
          onClick={onZoomIn}
          title="Zoom in"
          className={cn(
            "p-1.5 rounded-sm text-ink-secondary",
            "hover:text-ink hover:bg-elevated",
            "transition-colors duration-200",
            "focus-visible:outline-2 focus-visible:outline-link"
          )}
        >
          <ZoomIn size={15} strokeWidth={1.5} />
        </button>
        <button
          onClick={onFitToScreen}
          title="Fit to screen"
          className={cn(
            "p-1.5 rounded-sm text-ink-secondary",
            "hover:text-ink hover:bg-elevated",
            "transition-colors duration-200",
            "focus-visible:outline-2 focus-visible:outline-link"
          )}
        >
          <Maximize2 size={15} strokeWidth={1.5} />
        </button>
      </div>
    </div>
  );
}
