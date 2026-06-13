import * as React from "react";
import { cn } from "@/lib/cn";

export type ButtonVariant = "primary" | "secondary" | "ghost" | "generate";
export type ButtonSize = "sm" | "md";

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
}

const variantClasses: Record<ButtonVariant, string> = {
  primary: [
    "bg-accent text-white border-transparent",
    "hover:bg-accent-hover",
    "active:translate-y-px",
    "focus-visible:outline-2 focus-visible:outline-accent focus-visible:outline-offset-2",
    "disabled:opacity-40 disabled:cursor-not-allowed disabled:translate-y-0",
  ].join(" "),

  secondary: [
    "bg-transparent text-ink border border-rule",
    "hover:border-rule-heavy hover:bg-elevated",
    "focus-visible:outline-2 focus-visible:outline-link focus-visible:outline-offset-2",
    "disabled:opacity-40 disabled:cursor-not-allowed",
  ].join(" "),

  ghost: [
    "bg-transparent text-ink-secondary border-transparent",
    "hover:text-ink",
    "focus-visible:outline-2 focus-visible:outline-link focus-visible:outline-offset-2",
    "disabled:opacity-40 disabled:cursor-not-allowed",
  ].join(" "),

  generate: [
    "bg-generated text-white border-transparent",
    "hover:bg-[#7A6345]",
    "active:translate-y-px",
    "focus-visible:outline-2 focus-visible:outline-generated focus-visible:outline-offset-2",
    "disabled:opacity-40 disabled:cursor-not-allowed disabled:translate-y-0",
  ].join(" "),
};

const sizeClasses: Record<ButtonSize, string> = {
  sm: "px-3 py-1.5 text-[13px]",
  md: "px-5 py-2.5 text-[14px]",
};

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = "primary", size = "md", className, children, ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={cn(
          "inline-flex items-center justify-center gap-2",
          "font-sans font-semibold rounded-sm",
          "border transition-all duration-200 ease-[ease]",
          "cursor-pointer select-none",
          variantClasses[variant],
          sizeClasses[size],
          className
        )}
        {...props}
      >
        {children}
      </button>
    );
  }
);

Button.displayName = "Button";
