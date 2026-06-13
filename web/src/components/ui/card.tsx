import * as React from "react";
import { cn } from "@/lib/cn";

export type CardStatus = "default" | "canon" | "generated" | "flagged";

export interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  status?: CardStatus;
  hoverable?: boolean;
}

const statusClasses: Record<CardStatus, string> = {
  default: "border-l-rule-subtle",
  canon:   "border-l-[3px] border-l-canon",
  generated: "border-l-[3px] border-l-generated [border-left-style:dashed]",
  flagged: "border-l-[3px] border-l-flag-error bg-flag-error-muted",
};

export const Card = React.forwardRef<HTMLDivElement, CardProps>(
  ({ status = "default", hoverable = true, className, children, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={cn(
          "bg-surface",
          "border border-rule-subtle rounded-lg",
          "p-6",
          "transition-[border-color,box-shadow] duration-200 ease-[ease]",
          hoverable && "hover:border-rule hover:shadow-[0_2px_8px_rgba(0,0,0,0.04)]",
          statusClasses[status],
          className
        )}
        {...props}
      >
        {children}
      </div>
    );
  }
);

Card.displayName = "Card";
