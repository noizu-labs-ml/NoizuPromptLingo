"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";
import { Breadcrumbs, type BreadcrumbItem } from "./Breadcrumbs";

export interface PageHeaderProps {
  title: React.ReactNode;
  subtitle?: React.ReactNode;
  breadcrumbs?: BreadcrumbItem[];
  actions?: React.ReactNode;
  className?: string;
  cy?: string;
}

/**
 * Standard page header — breadcrumbs above, title + actions row below.
 *
 * @example
 * <PageHeader
 *   title="Scripts"
 *   subtitle="Behavioral evaluation graphs"
 *   breadcrumbs={[{label:"library"}, {label:"scripts", current:true}]}
 *   actions={<Button variant="primary">+ New</Button>}
 * />
 */
export function PageHeader({
  title,
  subtitle,
  breadcrumbs,
  actions,
  className,
  cy = "page-header",
}: PageHeaderProps) {
  return (
    <header className={className} {...cyAttrs({ cy })}>
      {breadcrumbs && breadcrumbs.length > 0 ? (
        <Breadcrumbs items={breadcrumbs} />
      ) : null}
      <div className="sg-page-header">
        <div>
          <h1 className="sg-page-header__title" {...cyAttrs({ cy: "page-title" })}>
            {title}
          </h1>
          {subtitle ? (
            <p
              className="sg-page-header__subtitle"
              {...cyAttrs({ cy: "page-subtitle" })}
            >
              {subtitle}
            </p>
          ) : null}
        </div>
        {actions ? (
          <div className="sg-page-actions" {...cyAttrs({ cy: "page-actions" })}>
            {actions}
          </div>
        ) : null}
      </div>
    </header>
  );
}
