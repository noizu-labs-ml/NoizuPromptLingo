"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";

export type ButtonVariant = "primary" | "secondary" | "ghost" | "eval";
export type ButtonSize = "sm" | "md" | "lg";
export type EvalState = "pass" | "warn" | "fail" | "freeball";

export interface ButtonProps
  extends Omit<React.ButtonHTMLAttributes<HTMLButtonElement>, "onClick"> {
  /** Visual treatment */
  variant?: ButtonVariant;
  /** Size step */
  size?: ButtonSize;
  /** Eval state — required when variant="eval" */
  evalState?: EvalState;
  /** Show spinner + disable */
  loading?: boolean;
  /** Left-side glyph */
  iconLeft?: React.ReactNode;
  /** Right-side glyph */
  iconRight?: React.ReactNode;
  /** When set, render as anchor */
  href?: string;
  /** Render as child (span) instead of button */
  asChild?: boolean;
  /** Click handler (also for anchor) */
  onClick?: (e: React.MouseEvent<HTMLElement>) => void;
  /** data-cy */
  cy?: string;
  cyId?: string | number;
  cyScope?: string;
  cyValue?: string | number;
}

const variantClass: Record<ButtonVariant, string> = {
  primary: "sg-btn sg-btn--primary",
  secondary: "sg-btn sg-btn--outline",
  ghost: "sg-btn sg-btn--ghost",
  eval: "sg-btn",
};

const sizeClass: Record<ButtonSize, string> = {
  sm: "sg-btn--sm",
  md: "",
  lg: "",
};

/**
 * Forge-native button. Supports primary/secondary/ghost + eval-state variants.
 *
 * @example
 * <Button variant="primary" cy="submit">Save</Button>
 * <Button variant="eval" evalState="pass">Promote</Button>
 * <Button href="/runs/123" variant="ghost">View run</Button>
 */
export function Button({
  variant = "primary",
  size = "md",
  evalState,
  loading = false,
  iconLeft,
  iconRight,
  href,
  asChild = false,
  className,
  children,
  disabled,
  cy,
  cyId,
  cyScope,
  cyValue,
  onClick,
  style,
  ...rest
}: ButtonProps) {
  const classes = [
    variantClass[variant],
    sizeClass[size],
    variant === "eval" && evalState ? `eval-${evalState}` : "",
    className || "",
  ]
    .filter(Boolean)
    .join(" ");

  const content = (
    <>
      {loading ? <Spinner /> : iconLeft}
      {children ? <span className="sg-btn__label">{children}</span> : null}
      {iconRight}
    </>
  );

  const sharedProps = {
    className: classes,
    style,
    ...cyAttrs({ cy, cyId, cyScope, cyValue }),
    onClick: disabled || loading ? undefined : onClick,
  };

  if (href && !disabled) {
    return (
      <a href={href} {...sharedProps}>
        {content}
      </a>
    );
  }
  if (asChild) {
    return <span {...sharedProps}>{content}</span>;
  }
  return (
    <button
      type="button"
      disabled={disabled || loading}
      aria-busy={loading || undefined}
      {...sharedProps}
      {...rest}
    >
      {content}
    </button>
  );
}

function Spinner() {
  return (
    <svg
      width="14"
      height="14"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      aria-hidden="true"
      style={{ animation: "sg-spin 0.8s linear infinite" }}
    >
      <circle cx="12" cy="12" r="9" opacity="0.25" />
      <path d="M12 3a9 9 0 0 1 9 9" />
      <style>{`@keyframes sg-spin { to { transform: rotate(360deg); } }`}</style>
    </svg>
  );
}
