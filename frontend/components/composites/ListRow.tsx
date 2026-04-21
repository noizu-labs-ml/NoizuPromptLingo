"use client";

import clsx from "clsx";
import Link from "next/link";
import { KeyboardEvent, ReactNode } from "react";
import { Card } from "@/components/primitives/Card";
import { focusRing } from "@/lib/utils/focusRing";

export interface ListRowProps {
  /** Primary content on the left — usually title + optional description below. */
  children: ReactNode;

  /** Right-side actions — badges, status selects, timestamps. */
  actions?: ReactNode;

  /** If set, the whole row is a next/link Link and is keyboard-focusable. */
  href?: string;

  /** If set (and no href), wraps in a button — for onRowClick patterns. */
  onClick?: () => void;

  /** Render as a disclosure/expanded row — adds left border accent. */
  selected?: boolean;

  /** Spacing density — passed through to the wrapped Card. */
  density?: "compact" | "normal";

  className?: string;
}

/**
 * ListRow is a row-shaped `Card` with distinct left-content and
 * right-actions slots. Used by `/tasks`, `/artifacts`, and anywhere list
 * items should be clickable (via `href` or `onClick`) with trailing
 * controls such as badges or status selects.
 */
export function ListRow({
  children,
  actions,
  href,
  onClick,
  selected,
  density = "compact",
  className,
}: ListRowProps) {
  const interactive = Boolean(href) || Boolean(onClick);

  const cardClassName = clsx(
    selected && "border-l-2 border-l-accent pl-3",
    className,
  );

  const content = (
    <Card
      density={density}
      hoverable={interactive}
      className={cardClassName}
    >
      <div className="flex items-center gap-3">
        <div className="flex-1 min-w-0">{children}</div>
        {actions && (
          <div className="flex items-center gap-2 shrink-0">{actions}</div>
        )}
      </div>
    </Card>
  );

  if (href) {
    return (
      <Link href={href} className={clsx("block rounded-lg", focusRing)}>
        {content}
      </Link>
    );
  }

  if (onClick) {
    const handleKeyDown = (event: KeyboardEvent<HTMLDivElement>) => {
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        onClick();
      }
    };

    return (
      <div
        role="button"
        tabIndex={0}
        onClick={onClick}
        onKeyDown={handleKeyDown}
        className={clsx("block rounded-lg cursor-pointer", focusRing)}
      >
        {content}
      </div>
    );
  }

  return content;
}
