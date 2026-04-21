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
        "inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-medium",
        active
          ? "bg-brand-500/20 text-brand-400 border border-brand-500/40"
          : "bg-surface-raised text-foreground border border-border"
      )}
    >
      {label}
      {onRemove && (
        <button
          type="button"
          onClick={onRemove}
          className={clsx(
            "rounded-full p-0.5 hover:bg-black/10 transition-colors",
            active ? "text-brand-400" : "text-muted"
          )}
          aria-label={`Remove ${label}`}
        >
          <XMarkIcon className="h-3 w-3" />
        </button>
      )}
    </span>
  );
}
