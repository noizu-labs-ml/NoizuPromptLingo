"use client";

import clsx from "clsx";
import Link from "next/link";
import { Fragment, ReactNode } from "react";
import {
  ArrowLeftIcon,
  ChevronRightIcon,
} from "@heroicons/react/24/outline";
import { PageHeader } from "@/components/primitives/PageHeader";

export interface BreadcrumbItem {
  label: ReactNode;
  /** If omitted, rendered as static text (current page). */
  href?: string;
}

export interface DetailHeaderProps {
  /** Trail of crumbs, last item usually current page (no href). */
  breadcrumbs?: BreadcrumbItem[];

  /**
   * Href for the back arrow — usually the parent list page. Omit if
   * breadcrumbs handle navigation.
   */
  backHref?: string;

  /** Back link label (e.g. "Back to tasks"). Default: "Back". */
  backLabel?: string;

  /** Passed through to PageHeader. */
  title: string;
  description?: ReactNode;
  actions?: ReactNode;

  className?: string;
}

/**
 * DetailHeader wraps PageHeader with a breadcrumb trail + optional back
 * link. Absorbs the repeated "Back to X · Parent › Current" + title/actions
 * pattern used across the 8+ detail routes.
 */
export function DetailHeader({
  breadcrumbs,
  backHref,
  backLabel = "Back",
  title,
  description,
  actions,
  className,
}: DetailHeaderProps) {
  const hasCrumbs = Boolean(breadcrumbs && breadcrumbs.length > 0);
  const hasBack = Boolean(backHref);
  const showTrail = hasBack || hasCrumbs;

  // PageHeader's description is typed as string | undefined; stringify
  // ReactNode consumers by only passing through when it's a string, else
  // render inline via eyebrow-like slot below title. To keep the API simple
  // we coerce non-string descriptions to empty and render them ourselves.
  const descriptionIsString = typeof description === "string";

  return (
    <div className={clsx("flex flex-col gap-3", className)}>
      {showTrail && (
        <div className="flex items-center gap-2 text-xs text-muted flex-wrap">
          {hasBack && (
            <Link
              href={backHref!}
              className="inline-flex items-center gap-1 hover:text-foreground transition-colors focus-ring rounded"
            >
              <ArrowLeftIcon className="h-3.5 w-3.5" />
              {backLabel}
            </Link>
          )}
          {hasBack && hasCrumbs && (
            <span className="text-subtle" aria-hidden="true">
              ·
            </span>
          )}
          {hasCrumbs &&
            breadcrumbs!.map((crumb, i) => {
              const isLast = i === breadcrumbs!.length - 1;
              return (
                <Fragment key={i}>
                  {crumb.href ? (
                    <Link
                      href={crumb.href}
                      className="hover:text-foreground transition-colors focus-ring rounded"
                    >
                      {crumb.label}
                    </Link>
                  ) : (
                    <span
                      className="text-foreground"
                      aria-current={isLast ? "page" : undefined}
                    >
                      {crumb.label}
                    </span>
                  )}
                  {!isLast && (
                    <ChevronRightIcon
                      className="h-3 w-3 text-subtle shrink-0"
                      aria-hidden="true"
                    />
                  )}
                </Fragment>
              );
            })}
        </div>
      )}
      <PageHeader
        title={title}
        description={descriptionIsString ? (description as string) : undefined}
        actions={actions}
      />
      {!descriptionIsString && description && (
        <div className="text-sm text-muted">{description}</div>
      )}
    </div>
  );
}
