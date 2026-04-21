"use client";

import clsx from "clsx";
import { XMarkIcon } from "@heroicons/react/20/solid";

export interface TagProps {
  label: string;
  onRemove?: () => void;
  active?: boolean;
}

export function Tag({ label, onRemove, active = false }: TagProps) {
  return (
    <span
      className={clsx(
        "inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-medium border",
        active
          ? "bg-accent/15 text-accent border-accent/30"
          : "bg-surface-1/80 text-muted border-border/50"
      )}
    >
      {label}
      {onRemove && (
        <button
          type="button"
          onClick={onRemove}
          className={clsx(
            "focus-ring rounded-full p-0.5 hover:bg-black/10 transition-colors",
            active ? "text-accent" : "text-muted"
          )}
          aria-label={`Remove ${label}`}
        >
          <XMarkIcon className="h-3 w-3" />
        </button>
      )}
    </span>
  );
}
