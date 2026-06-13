"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";

export interface BreadcrumbItem {
  label: string;
  href?: string;
  current?: boolean;
}

export interface BreadcrumbsProps {
  items: BreadcrumbItem[];
  separator?: React.ReactNode;
  className?: string;
  cy?: string;
}

/**
 * Mono 12px breadcrumb trail; copper current item; `›` separator.
 *
 * @example
 * <Breadcrumbs items={[{label: "scripts", href: "/scripts"}, {label: "onboarding", current: true}]} />
 */
export function Breadcrumbs({
  items,
  separator = "›",
  className,
  cy = "breadcrumbs",
}: BreadcrumbsProps) {
  return (
    <nav
      aria-label="Breadcrumb"
      className={["sg-breadcrumbs", className || ""].filter(Boolean).join(" ")}
      {...cyAttrs({ cy })}
    >
      {items.map((item, i) => {
        const isCurrent = item.current || i === items.length - 1;
        const itemClass = [
          "sg-breadcrumbs__item",
          isCurrent ? "sg-breadcrumbs__item--current" : "",
        ]
          .filter(Boolean)
          .join(" ");

        return (
          <React.Fragment key={`${item.label}-${i}`}>
            {i > 0 ? (
              <span className="sg-breadcrumbs__sep" aria-hidden="true">
                {separator}
              </span>
            ) : null}
            {item.href && !isCurrent ? (
              <a
                href={item.href}
                className={itemClass}
                {...cyAttrs({ cy: "breadcrumb-item", cyId: i })}
              >
                {item.label}
              </a>
            ) : (
              <span
                className={itemClass}
                aria-current={isCurrent ? "page" : undefined}
                {...cyAttrs({ cy: "breadcrumb-item", cyId: i })}
              >
                {item.label}
              </span>
            )}
          </React.Fragment>
        );
      })}
    </nav>
  );
}
