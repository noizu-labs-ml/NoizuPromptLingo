import * as React from "react";
import { cn } from "@/lib/cn";

export type BadgeVariant = "canon" | "generated" | "flagged" | "success";

export interface BadgeProps extends React.HTMLAttributes<HTMLSpanElement> {
  variant?: BadgeVariant;
}

const variantClasses: Record<BadgeVariant, string> = {
  canon: [
    "bg-canon-muted text-canon",
    "border border-[rgba(26,23,20,0.15)]",
  ].join(" "),

  generated: [
    "bg-generated-muted text-generated",
    "border border-[rgba(139,115,85,0.2)]",
  ].join(" "),

  flagged: [
    "bg-flag-error-muted text-flag-error",
    "border border-[rgba(196,67,43,0.2)]",
  ].join(" "),

  success: [
    "bg-success-muted text-success",
    "border border-[rgba(61,122,74,0.2)]",
  ].join(" "),
};

export const Badge = React.forwardRef<HTMLSpanElement, BadgeProps>(
  ({ variant = "canon", className, children, ...props }, ref) => {
    return (
      <span
        ref={ref}
        className={cn(
          "inline-flex items-center gap-1",
          "px-2.5 py-0.5",
          "rounded-full",
          "font-mono text-[11px] font-medium tracking-[0.02em] uppercase",
          variantClasses[variant],
          className
        )}
        {...props}
      >
        {children}
      </span>
    );
  }
);

Badge.displayName = "Badge";
