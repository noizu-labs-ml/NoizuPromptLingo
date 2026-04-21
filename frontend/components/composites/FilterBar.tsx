"use client";

import clsx from "clsx";
import { ReactNode } from "react";
import { Button } from "@/components/primitives/Button";

export interface FilterBarProps {
  /** The search box (usually <SearchBox>) or any search input. */
  search?: ReactNode;

  /**
   * One or more filter dropdowns (usually <FilterListbox>) rendered as flex
   * siblings.
   */
  filters?: ReactNode;

  /**
   * Secondary controls like mode toggles or tag clouds. Rendered on a
   * second row if present.
   */
  secondary?: ReactNode;

  /**
   * "Clear" button target — whether any filters/search are active. If
   * true, renders a "Clear" text button on the right.
   */
  hasActive?: boolean;

  /** Called when user clicks Clear. */
  onClear?: () => void;

  /** Right-aligned summary text (e.g. "12 results"). */
  summary?: ReactNode;

  className?: string;
}

/**
 * FilterBar wraps the filter controls that appear at the top of list pages:
 * a search input, one or more dropdown filters, an optional secondary row
 * (mode toggles, tag clouds, etc.), a right-aligned summary, and a "Clear"
 * action when filters/search are active.
 *
 * All slots are optional so the bar can grow alongside list features; with
 * zero props it degrades to an empty bordered container.
 */
export function FilterBar({
  search,
  filters,
  secondary,
  hasActive,
  onClear,
  summary,
  className,
}: FilterBarProps) {
  const showRightCluster = Boolean(summary) || Boolean(hasActive);

  return (
    <div
      className={clsx(
        "rounded-lg border border-border bg-surface-0 p-3 flex flex-col gap-3",
        className,
      )}
    >
      <div className="flex flex-wrap items-center gap-3">
        {search && (
          <div className="flex-1 min-w-[240px]">{search}</div>
        )}
        {filters && (
          <div className="flex items-center gap-2">{filters}</div>
        )}
        {showRightCluster && (
          <div className="ml-auto flex items-center gap-3">
            {summary && (
              <span className="text-xs text-subtle">{summary}</span>
            )}
            {hasActive && (
              <Button variant="ghost" size="sm" onClick={onClear}>
                Clear
              </Button>
            )}
          </div>
        )}
      </div>
      {secondary && (
        <div className="flex flex-wrap items-center gap-2 pt-2 border-t border-border/60">
          {secondary}
        </div>
      )}
    </div>
  );
}
