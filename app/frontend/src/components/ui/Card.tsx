"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";

export type CardVariant =
  | "default"
  | "active"
  | "pass"
  | "warn"
  | "fail"
  | "freeball";

export interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: CardVariant;
  interactive?: boolean;
  asChild?: boolean;
  cy?: string;
  cyId?: string | number;
  cyScope?: string;
}

/**
 * Forge card — inherits graph-node DNA (1.5px border, 6px radius, 20px padding).
 *
 * @example
 * <Card variant="pass" interactive>Script #1</Card>
 */
export function Card({
  variant = "default",
  interactive = false,
  asChild = false,
  className,
  children,
  cy,
  cyId,
  cyScope,
  ...rest
}: CardProps) {
  const evalVariants: Record<string, string> = {
    pass: "eval-pass",
    warn: "eval-warn",
    fail: "eval-fail",
    freeball: "eval-freeball",
    active: "sg-card--active",
    default: "",
  };

  const classes = [
    "sg-card",
    interactive ? "sg-card--interactive" : "",
    evalVariants[variant] || "",
    className || "",
  ]
    .filter(Boolean)
    .join(" ");

  const sharedProps = {
    className: classes,
    ...cyAttrs({ cy, cyId, cyScope }),
    "data-interactive": interactive ? "true" : undefined,
  };

  if (asChild) {
    return (
      <span {...sharedProps} {...(rest as React.HTMLAttributes<HTMLSpanElement>)}>
        {children}
      </span>
    );
  }
  return (
    <div {...sharedProps} {...rest}>
      {children}
    </div>
  );
}
