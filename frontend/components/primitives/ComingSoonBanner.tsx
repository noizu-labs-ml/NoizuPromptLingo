import clsx from "clsx";
import { ReactNode } from "react";
import { SparklesIcon } from "@heroicons/react/24/outline";

export interface ComingSoonBannerProps {
  /** Defaults to "Preview only". */
  title?: string;
  /** Defaults to a generic stub explanation. */
  description?: ReactNode;
  /** Optional PRD reference appended to the description (e.g. "PRD-004"). */
  prdRef?: string;
  className?: string;
}

/**
 * Warning banner rendered on stub pages to signal that the module is a
 * placeholder pending real implementation. Intentionally warm/amber rather
 * than danger-red — it is informational, not error.
 */
export function ComingSoonBanner({
  title = "Preview only",
  description = "This module is defined as a stub. Real implementation pending.",
  prdRef,
  className,
}: ComingSoonBannerProps) {
  return (
    <div
      role="status"
      className={clsx(
        "rounded-lg border border-warning/30 bg-warning/10 px-4 py-3 flex items-start gap-3",
        className
      )}
    >
      <SparklesIcon
        className="text-warning shrink-0 h-5 w-5 mt-0.5"
        aria-hidden="true"
      />
      <div className="min-w-0">
        <p className="text-sm font-semibold text-warning">{title}</p>
        <p className="text-xs text-warning/80">
          {description}
          {prdRef ? ` — ${prdRef}` : null}
        </p>
      </div>
    </div>
  );
}
