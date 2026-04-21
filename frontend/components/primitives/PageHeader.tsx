"use client";

import { ReactNode } from "react";
import { heading, text } from "@/lib/ui/typography";

export interface PageHeaderProps {
  title: string;
  description?: string;
  actions?: ReactNode;
  /**
   * Small label or breadcrumb row rendered above the title.
   * Uses `text-label text-subtle`. Useful for detail-page eyebrows
   * like "Tool / Search" or a crumb trail.
   */
  eyebrow?: ReactNode;
}

export function PageHeader({
  title,
  description,
  actions,
  eyebrow,
}: PageHeaderProps) {
  return (
    <div className="flex items-start justify-between gap-4">
      <div className="flex flex-col gap-2">
        {eyebrow && (
          <div className="text-label uppercase text-subtle flex items-center gap-2">
            {eyebrow}
          </div>
        )}
        <h1 className={heading.display}>{title}</h1>
        {description && <p className={text.muted}>{description}</p>}
      </div>
      {actions && (
        <div className="flex items-center gap-2 shrink-0">{actions}</div>
      )}
    </div>
  );
}
