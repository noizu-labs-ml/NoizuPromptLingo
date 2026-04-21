"use client";

import clsx from "clsx";
import { ReactNode } from "react";
import { heading } from "@/lib/ui/typography";

export interface EmptyStateProps {
  icon?: ReactNode;
  title: string;
  description?: string;
  action?: ReactNode;
}

export function EmptyState({ icon, title, description, action }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center gap-3 py-16 px-4 text-center">
      {icon && (
        <div
          className={clsx(
            "bg-surface-1 rounded-full p-3 mb-2 text-muted",
            "[&>svg]:h-12 [&>svg]:w-12"
          )}
        >
          {icon}
        </div>
      )}
      <h3 className={heading.title}>{title}</h3>
      {description && (
        <p className="text-sm text-muted max-w-md mx-auto">{description}</p>
      )}
      {action && <div className="mt-2">{action}</div>}
    </div>
  );
}
